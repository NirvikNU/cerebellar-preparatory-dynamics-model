function report = stage3_postgo_production(root)
    cfg=stage3_postgo_paths(root);
    assert(isfile(fullfile(root,'artifacts','manifests','stage3_cortical_state_feasibility','POSTGO_INPUTS_BEFORE.csv')));
    assert(~isfile(fullfile(cfg.postRoot,'production_complete.mat')));
    targets=repelem(1:8,30); trials=repmat(1:30,1,8);
    report=struct('status','running','task',cfg.task,'completed',0,'identity',zeros(40,6));
    started=tic;
    try
        for network=1:10
            loaded=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',network)),'model'); m=loaded.model;
            loaded=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',network)),'ref'); ref=loaded.ref;
            noise=stage3_prediction_noise(m,network,targets,trials);
            prepSteps=round(.5/m.dt); hashes=cell(240,1);
            for j=1:240
                seed=310000000+10000*network+100*targets(j)+trials(j);
                stream=RandStream('mt19937ar','Seed',seed);
                initial=randn(stream,m.n,1);
                process=randn(stream,m.n,prepSteps+m.nInternalSteps);
                assert(isequal(initial,noise.initial(:,j)));
                assert(isequal(process,reshape(noise.process(:,j,:),m.n,[])));
                digest=java.security.MessageDigest.getInstance('SHA-256');
                post=process(:,prepSteps+1:end);
                digest.update(typecast(post(:),'int8'));
                hashes{j}=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
            end
            postNoise=noise.process(:,:,prepSteps+1:end);
            for policy=1:4
                outputPath=fullfile(cfg.postCache,sprintf('n%02d_p%d.mat',network,policy));
                assert(~isfile(outputPath),'Refuse to overwrite a causal replay cache.');
                loaded=load(fullfile(cfg.predCache,sprintf('n%02d_s2_p%d.mat',network,policy)),'out'); full=loaded.out;
                assert(isequal(full.targets,targets) && isequal(full.trials,trials));
                assert(isequal(full.seeds,noise.seeds) && full.s==.1);
                assert(isequal(full.go,reshape(permute(full.states(501,:,:),[2 3 1]),m.n,[])));
                intervalError=0;
                for savedStep=[1 11 101 501 598]
                    x=reshape(permute(full.states(500+savedStep,:,:),[2 3 1]),m.n,[]);
                    for sub=0:4
                        step=(savedStep-1)*5+sub;
                        force=-x+m.W*max(x,0)+m.h+published_movement_input(step*m.dt,m);
                        x=x+(m.dt/m.tau)*force+.1*sqrt(2*m.dt/m.tau)*postNoise(:,:,step+1);
                    end
                    expected=reshape(permute(full.states(501+savedStep,:,:),[2 3 1]),m.n,[]);
                    intervalError=max(intervalError,max(abs(x-expected),[],'all'));
                end
                assert(intervalError<1e-10,'Saved Full trajectory cannot be matched to its exact stream.');
                deterministicPrep=stage3_bio_load(cfg,network,policy);
                replay=struct('network',network,'policy',policy,'targets',targets,'trials',trials, ...
                    'seeds',noise.seeds,'postNoiseSHA256',{hashes},'intervalError',intervalError);
                replay.prep=stage3_postgo_movement(m,full.go,[],0);
                replay.post=stage3_postgo_movement(m,deterministicPrep.go(:,targets),postNoise,.1);
                replay.deterministic=stage3_postgo_movement(m,deterministicPrep.go,[],0);
                reference=simulate_published_cortex(m,deterministicPrep.go,true);
                [theta,hand]=simulate_published_arm(m,reference.torque);
                deterministicError=max([max(abs(reference.rates-max(replay.deterministic.states,0)),[],'all'), ...
                    max(abs(reference.torque-replay.deterministic.torque),[],'all'), ...
                    max(abs(reference.finalState-replay.deterministic.finalState),[],'all'), ...
                    max(abs(theta-replay.deterministic.theta),[],'all'),max(abs(hand-replay.deterministic.hand),[],'all')]);
                oldMovementError=0;
                oldPath=fullfile(cfg.bioCache,sprintf('movement_n%02d_p%d.mat',network,policy));
                if isfile(oldPath)
                    loaded=load(oldPath,'evidence'); evidence=loaded.evidence;
                    oldMovementError=max([max(abs(evidence.initialState-deterministicPrep.go),[],'all'), ...
                        max(abs(evidence.hand-hand),[],'all'),max(abs(evidence.movement.rates-reference.rates),[],'all')]);
                end
                assert(deterministicError<1e-10 && oldMovementError<1e-10,'Deterministic movement fidelity failed.');
                names={'prep','post','deterministic'};
                for z=1:3
                    item=replay.(names{z});
                    assert(item.nativeRateMax<=ref.rateLimit && item.nativeStateNormMax<=ref.stateLimit);
                    assert(all(item.windowsOK),'Own-event analysis window unavailable.');
                end
                assert(isequal(replay.prep.go,full.go));
                replay.deterministicError=deterministicError; replay.oldMovementError=oldMovementError;
                save(outputPath,'replay','-v7.3');
                report.completed=report.completed+1;
                report.identity(report.completed,:)=[network policy intervalError deterministicError oldMovementError toc(started)];
                fprintf('Causal replay %d/40: identity, deterministic fidelity, safety and windows PASS (%.1fs)\n',report.completed,toc(started));
            end
        end
        report.status='PASS';
    catch exception
        report.status='STOP'; report.error=exception.message; report.stack=exception.stack;
        save(fullfile(cfg.postRoot,'production_stop.mat'),'report');
        stage3_write_json(fullfile(cfg.postRoot,'production_stop.json'),report);
        rethrow(exception);
    end
    save(fullfile(cfg.postRoot,'production_complete.mat'),'report');
    stage3_write_json(fullfile(cfg.postRoot,'production_complete.json'),report);
end
