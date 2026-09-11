function report = stage3_prediction_preflight(root)
    cfg=stage3_prediction_paths(root);
    output=fullfile(cfg.predRoot,'preflight.mat');
    assert(~isfile(output),'Refuse to overwrite prior prediction preflight.');
    assert(isfile(fullfile(cfg.manifestRoot,'PREDICTION_INPUTS_BEFORE.csv')));
    report=struct('task',cfg.task,'status','running','stage','initialization', ...
        'predictionOutcomesGenerated',false,'productionStarted',false);
    evidence=struct;
    try
        report.stage='isolated leak';
        tau=.15; dt=.0002; s=.1; stream=RandStream('mt19937ar','Seed',cfg.leakSeed);
        a=1-dt/tau; expectedSD=s/sqrt(1-dt/(2*tau));
        x=expectedSD*randn(stream,20000,1); lag=[];
        for step=1:10000
            x=a*x+s*sqrt(2*dt/tau)*randn(stream,20000,1);
            if step==9950, lag=x; end
        end
        cc=corrcoef(lag,x);
        report.leak=struct('sampleSD',std(x),'expectedSD',expectedSD, ...
            'lag10msCorrelation',cc(1,2),'expectedCorrelation',a^50, ...
            'diffusionVariance',(s*sqrt(2/tau))^2*dt);
        assert(abs(std(x)/expectedSD-1)<=.02 && abs(cc(1,2)-a^50)<=.02, ...
            'Stage3Prediction:Leak','Isolated-leak scaling failed.');
        assert(abs(report.leak.diffusionVariance-2*s^2*dt/tau)<1e-16);
        report.stage='common random numbers';
        loaded=load(fullfile(cfg.ensembleRoot,'network_01.mat'),'model'); m=loaded.model;
        loaded=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); d=loaded.registry.primary{1};
        loaded=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); c=loaded.controllers{1};
        loaded=load(fullfile(cfg.cacheRoot,'reference_01.mat'),'ref'); ref=loaded.ref;
        report.modelMetadata=struct('n',m.n,'tau',m.tau,'dt',m.dt, ...
            'nSamples',m.nSamples,'nInternalSteps',m.nInternalSteps, ...
            'rateLimit',ref.rateLimit,'stateLimit',ref.stateLimit);
        noise=stage3_prediction_noise(m,1,[1 5],[1 1]);
        for policy=1:4
            repeat=stage3_prediction_noise(m,1,[1 5],[1 1]);
            assert(isequal(noise,repeat));
        end
        other=stage3_prediction_noise(m,1,1,2);
        assert(~isequal(noise.initial(:,1),other.initial));
        report.commonRandomNumbers=true;
        report.stage='deterministic limit';
        zero.initial=zeros(m.n,8); zero.process=zeros(m.n,8,round(.5/m.dt)+m.nInternalSteps);
        zero.seeds=zeros(1,8); report.deterministic=zeros(4,5);
        for policy=1:4
            saved=stage3_bio_load(cfg,1,policy);
            replay=stage3_prediction_replay(m,d,c,cfg.policyFlags(policy,:),1:8,0,zero);
            movement=simulate_published_cortex(m,saved.go,true);
            [~,hand]=simulate_published_arm(m,movement.torque);
            errors=[max(abs(replay.states(1:501,:,:)-saved.states),[],'all'), ...
                max(abs(replay.go-saved.go),[],'all'), ...
                max(abs(max(replay.states(501:end,:,:),0)-movement.rates),[],'all'), ...
                max(abs(replay.torque-movement.torque),[],'all'), ...
                max(abs(replay.hand-hand),[],'all')];
            report.deterministic(policy,:)=errors;
            assert(all(errors<=cfg.deterministicTolerance),'Stage3Prediction:Deterministic','s=0 fidelity failed.');
        end
        clear zero saved replay movement hand
        report.stage='coupled step and safety';
        fine=noise; fine.process=zeros(m.n,2,2*size(noise.process,3));
        for j=1:2
            target=[1 5]; stream=RandStream('mt19937ar','Seed',319100000+target(j));
            bridge=reshape(randn(stream,m.n,size(noise.process,3)),m.n,1,[]);
            fine.process(:,j,1:2:end)=(noise.process(:,j,:)+bridge)/sqrt(2);
            fine.process(:,j,2:2:end)=(noise.process(:,j,:)-bridge)/sqrt(2);
        end
        evidence.noise=noise; evidence.fineNoise=fine;
        assert(max(abs((fine.process(:,:,1:2:end)+fine.process(:,:,2:2:end))/sqrt(2)-noise.process),[],'all')<1e-14);
        report.stepChecks=zeros(0,10);
        for level=1:3
            for policy=1:4
                report.currentCase=struct('network',1,'targets',[1 5],'trial',1, ...
                    's',cfg.noiseLevels(level),'policy',policy);
                coarse=stage3_prediction_replay(m,d,c,cfg.policyFlags(policy,:),[1 5],cfg.noiseLevels(level),noise);
                finer=stage3_prediction_replay(m,d,c,cfg.policyFlags(policy,:),[1 5],cfg.noiseLevels(level),fine,.0001);
                stateError=sqrt(mean((coarse.states-finer.states).^2,'all'))/max(1,sqrt(mean(finer.states.^2,'all')));
                handError=sqrt(mean((coarse.hand(:,[1 3],:)-finer.hand(:,[1 3],:)).^2,'all'));
                maxRate=max(coarse.nativeRateMax,finer.nativeRateMax);
                maxState=max(coarse.nativeStateNormMax,finer.nativeStateNormMax);
                safety=maxRate<=ref.rateLimit && maxState<=ref.stateLimit;
                windows=all(coarse.windowsOK) && all(finer.windowsOK);
                report.stepChecks(end+1,:)=[cfg.noiseLevels(level),policy,stateError,handError, ...
                    maxRate,ref.rateLimit,maxState,ref.stateLimit,safety,windows];
                evidence.coarse=coarse; evidence.finer=finer;
                assert(safety,'Stage3Prediction:Safety','Existing state/rate safety limit exceeded.');
                assert(windows,'Stage3Prediction:Windows','Required trial window unavailable.');
                assert(stateError<=cfg.stateRmsTolerance && handError<=cfg.handRmsToleranceM, ...
                    'Stage3Prediction:Step','Coupled step convergence failed.');
                fprintf('Preflight s=%.2f policy=%d state RMS %.3g, hand RMS %.3g m: PASS\n',cfg.noiseLevels(level),policy,stateError,handError);
            end
        end
        report.status='PASS'; report.stage='complete';
    catch exception
        report.status='STOP'; report.errorIdentifier=exception.identifier;
        report.errorMessage=exception.message; report.stack=exception.stack;
        save(fullfile(cfg.predCache,'preflight_evidence.mat'),'evidence','-v7.3');
        save(output,'report');
        stage3_write_json(fullfile(cfg.predRoot,'preflight.json'),report);
        rethrow(exception);
    end
    save(fullfile(cfg.predCache,'preflight_evidence.mat'),'evidence','-v7.3');
    save(output,'report');
    stage3_write_json(fullfile(cfg.predRoot,'preflight.json'),report);
    disp(report);
end
