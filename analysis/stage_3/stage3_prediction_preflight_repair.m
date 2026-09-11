function report = stage3_prediction_preflight_repair(root)
    % Binding repair only: reuse passed checks and the original random draws.
    cfg=stage3_prediction_paths(root);
    output=fullfile(cfg.predRoot,'preflight_repair.mat');
    assert(~isfile(output),'Refuse to overwrite repaired preflight evidence.');
    loaded=load(fullfile(cfg.predRoot,'preflight.mat'),'report'); prior=loaded.report;
    assert(strcmp(prior.status,'STOP') && prior.commonRandomNumbers);
    assert(all(prior.deterministic<=cfg.deterministicTolerance,'all'));
    loaded=load(fullfile(cfg.predCache,'preflight_evidence.mat'),'evidence');
    noise=loaded.evidence.noise; fine=loaded.evidence.fineNoise;
    loaded=load(fullfile(cfg.ensembleRoot,'network_01.mat'),'model'); m=loaded.model;
    loaded=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); d=loaded.registry.primary{1};
    loaded=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); c=loaded.controllers{1};
    loaded=load(fullfile(cfg.cacheRoot,'reference_01.mat'),'ref'); ref=loaded.ref;
    report=struct('task',cfg.task,'status','running','priorPassedChecks',prior, ...
        'productionStarted',false,'predictionOutcomesGenerated',false, ...
        'stepChecks',zeros(0,12),'suppliedStepTests',false);
    evidence=struct('pairs',{cell(3,4)});
    try
        for level=1:3
            for policy=1:4
                report.currentCase=struct('network',1,'targets',[1 5],'trial',1, ...
                    's',cfg.noiseLevels(level),'policy',policy);
                % Omitted dt and explicit .0001 exercise the two guard branches.
                coarse=stage3_prediction_replay(m,d,c,cfg.policyFlags(policy,:),[1 5],cfg.noiseLevels(level),noise);
                finer=stage3_prediction_replay(m,d,c,cfg.policyFlags(policy,:),[1 5],cfg.noiseLevels(level),fine,.0001);
                evidence.pairs{level,policy}=struct('coarse',coarse,'fine',finer);
                assert(coarse.dt==.0002 && finer.dt==.0001, ...
                    'Stage3Prediction:OptionalStep','Supplied or omitted step is incorrect.');
                assert(isequal(coarse.timeGOms,finer.timeGOms) && isequal(size(coarse.states),size(finer.states)));
                report.suppliedStepTests=true;
                stateError=sqrt(mean((coarse.states-finer.states).^2,'all'))/max(1,sqrt(mean(finer.states.^2,'all')));
                handError=sqrt(mean((coarse.hand(:,[1 3],:)-finer.hand(:,[1 3],:)).^2,'all'));
                maxRate=max(coarse.nativeRateMax,finer.nativeRateMax);
                maxState=max(coarse.nativeStateNormMax,finer.nativeStateNormMax);
                safety=maxRate<=ref.rateLimit && maxState<=ref.stateLimit;
                windows=all(coarse.windowsOK) && all(finer.windowsOK);
                report.stepChecks(end+1,:)=[cfg.noiseLevels(level),policy,stateError,handError, ...
                    maxRate,ref.rateLimit,maxState,ref.stateLimit,safety,windows,coarse.dt,finer.dt];
                assert(safety,'Stage3Prediction:Safety','Existing state/rate safety limit exceeded.');
                assert(windows,'Stage3Prediction:Windows','Required trial window unavailable.');
                assert(stateError<=cfg.stateRmsTolerance && handError<=cfg.handRmsToleranceM, ...
                    'Stage3Prediction:Step','Coupled step convergence failed.');
                fprintf('Repaired preflight s=%.2f policy=%d: state RMS %.6g; hand RMS %.6g m PASS\n', ...
                    cfg.noiseLevels(level),policy,stateError,handError);
            end
        end
        report.status='PASS';
    catch exception
        report.status='STOP'; report.errorIdentifier=exception.identifier;
        report.errorMessage=exception.message; report.stack=exception.stack;
        save(fullfile(cfg.predCache,'preflight_repair_evidence.mat'),'evidence','-v7.3');
        save(output,'report');
        stage3_write_json(fullfile(cfg.predRoot,'preflight_repair.json'),report);
        rethrow(exception);
    end
    save(fullfile(cfg.predCache,'preflight_repair_evidence.mat'),'evidence','-v7.3');
    save(output,'report');
    stage3_write_json(fullfile(cfg.predRoot,'preflight_repair.json'),report);
    disp(report);
end
