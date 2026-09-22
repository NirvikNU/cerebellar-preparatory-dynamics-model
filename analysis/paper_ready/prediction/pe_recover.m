function audit = pe_recover(root)
    cfg=pe_paths(root); base=fullfile(root,'results','paper_ready');
    guard=jsondecode(fileread(fullfile(cfg.manifest,'PREFLIGHT.json'))); assert(strcmp(guard.status,'PASS'));
    audit=struct('status','RUNNING','errors',zeros(10,4,7),'initialReuse',10, ...
        'prepRecovered',30,'neuralMovementRecovered',40,'armReplayed',false);
    started=tic;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        old=load(fullfile(base,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'policies','moves','c','d');
        g=load(fullfile(base,'cache',sprintf('grid_n%02d.mat',n)),'intact');
        noise=paper_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
        for p=1:4
            output=fullfile(cfg.raw,sprintf('series_n%02d_p%d.mat',n,p)); assert(~isfile(output));
            prior=old.policies{p}; mov=old.moves{p};
            if p==1, prep=g.intact; else, prep=paper_prepare(m,{old.d},old.c,cfg.policyFlags(p,:),.1,.1,noise,m.dt,true,false); end
            err=[max(abs(prep.initial-prior.initial),[],'all'),max(abs(prep.go-prior.go),[],'all'), ...
                max(abs(prep.lateRates-prior.lateRates),[],'all'),max(abs(prep.meanRates-prior.meanRates),[],'all')];
            assert(max(err)<1e-10,'Saved preparation mismatch: stop, no fit.');
            assert(isequal(prep.seeds,prior.seeds) && prep.rateMax<=ref.rateLimit && prep.stateMax<=ref.stateLimit);
            % Existing Intact components may refer to another equivalent geometry;
            % do not reinterpret those fields or regenerate the arm/event evidence.
            state=mov.go; movement=zeros(m.nSamples,200,240); torque=zeros(size(mov.torque));
            stride=round(m.samplingDt/m.dt); sample=0; transitionError=0;
            for step=0:m.nInternalSteps-1
                rates=max(state,0);
                if mod(step,stride)==0
                    sample=sample+1; movement(sample,:,:)=permute(state,[3 1 2]);
                    torque(sample,:,:)=permute(m.C*rates,[3 1 2]);
                end
                next=state+m.dt/m.tau*(-state+m.W*rates+m.h+published_movement_input(step*m.dt,m));
                for k=1:numel(mov.audit)
                    if step==mov.audit(k).step
                        transitionError=max(transitionError,max(abs(state-mov.audit(k).x),[],'all'));
                        transitionError=max(transitionError,max(abs(next-mov.audit(k).next),[],'all'));
                    end
                end
                assert(all(isfinite(next),'all')); state=next;
            end
            err(5:7)=[max(abs(torque-mov.torque),[],'all'),max(abs(state-mov.finalState),[],'all'),transitionError];
            assert(sample==m.nSamples && max(err)<1e-10 && ~any(mov.missingWindow));
            audit.errors(n,p,:)=err;
            prepStates=prep.states; moMs=mov.moMs; scale=ref.scale;
            f=pe_features(prepStates,movement,moMs,scale);
            provenance=struct('network',n,'policy',p,'lambda',10,'alpha',.5,'beta',1, ...
                'seeds',prior.seeds,'flags',cfg.policyFlags(p,:),'maxErrors',err,'noiseAfterGO',false);
            save(output,'prepStates','movement','moMs','scale','f','provenance','-v7.3');
            fprintf('Recovered and verified network%d policy%d %.1fs\n',n,p,toc(started));
            clear prep prepStates movement torque f
        end
        clear g old noise
    end
    audit.status='PASS'; audit.elapsedSeconds=toc(started);
    save(fullfile(cfg.dest,'recovery.mat'),'audit'); paper_json(fullfile(cfg.dest,'recovery.json'),audit);
end
