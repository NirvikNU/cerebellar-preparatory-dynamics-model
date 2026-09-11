function report = stage3_prediction_production(root)
    cfg=stage3_prediction_paths(root);
    loaded=load(fullfile(cfg.predRoot,'preflight_repair.mat'),'report');
    assert(strcmp(loaded.report.status,'PASS') && loaded.report.suppliedStepTests);
    assert(~isfile(fullfile(cfg.predRoot,'production_complete.mat')));
    loaded=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=loaded.registry;
    loaded=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); controllers=loaded.controllers;
    targets=repelem(1:8,cfg.trials); trials=repmat(1:cfg.trials,1,8);
    report=struct('status','running','task',cfg.task,'completed',0,'checks',zeros(120,10));
    started=tic;
    try
        for network=1:10
            loaded=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',network)),'model'); m=loaded.model;
            loaded=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',network)),'ref'); ref=loaded.ref;
            noise=stage3_prediction_noise(m,network,targets,trials);
            for level=1:3
                for policy=1:4
                    path=fullfile(cfg.predCache,sprintf('n%02d_s%d_p%d.mat',network,level,policy));
                    assert(~isfile(path),'Refuse to overwrite a stochastic cache.');
                    report.currentCase=[network level policy];
                    out=stage3_prediction_replay(m,registry.primary{network},controllers{network}, ...
                        cfg.policyFlags(policy,:),targets,cfg.noiseLevels(level),noise);
                    out.network=network; out.policy=policy; out.trials=trials;
                    out.noiseLevelIndex=level;
                    out.boundsPass=out.nativeRateMax<=ref.rateLimit && out.nativeStateNormMax<=ref.stateLimit;
                    out.dimensionOrder='saved time, neuron, trial (target-major; 30 trials per target)';
                    save(path,'out','-v7.3');
                    assert(out.boundsPass,'Stage3Prediction:Safety','Frozen state/rate bound exceeded.');
                    assert(all(out.windowsOK),'Stage3Prediction:Windows','Required noisy-trial window missing.');
                    report.completed=report.completed+1;
                    report.checks(report.completed,:)=[network,cfg.noiseLevels(level),policy, ...
                        out.nativeRateMax,ref.rateLimit,out.nativeStateNormMax,ref.stateLimit, ...
                        min(out.moMs),max(out.moMs),toc(started)];
                    fprintf('Production %d/120: n%02d s=%.2f policy%d, native safety/windows PASS, %.1fs\n', ...
                        report.completed,network,cfg.noiseLevels(level),policy,toc(started));
                end
            end
        end
        report.status='PASS';
    catch exception
        report.status='STOP'; report.errorIdentifier=exception.identifier;
        report.errorMessage=exception.message; report.stack=exception.stack;
        save(fullfile(cfg.predRoot,'production_stop.mat'),'report');
        stage3_write_json(fullfile(cfg.predRoot,'production_stop.json'),report);
        rethrow(exception);
    end
    save(fullfile(cfg.predRoot,'production_complete.mat'),'report');
    stage3_write_json(fullfile(cfg.predRoot,'production_complete.json'),report);
end
