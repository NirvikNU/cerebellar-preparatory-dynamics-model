function outcome = run_v3_deterministic_training(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(mfilename('fullpath'));
    end
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src'));
    addpath(fullfile(projectRoot, 'analysis'));
    addpath(fullfile(projectRoot, 'figures'));
    params = v3_model_params();
    run = v3_deterministic_run_params(params);
    fixed = construct_v3_hybrid_recurrence(params, projectRoot);
    initialModel = initialize_v3_model(params, fixed);
    initialWrec = gather(extractdata(initialModel.Wrec));
    outputDirectory = fullfile(projectRoot, params.files.resultRoot);
    if ~isfolder(outputDirectory)
        mkdir(outputDirectory);
    end
    checkpointPath = fullfile(projectRoot, run.files.checkpoint);
    fprintf(['Starting deterministic intact V3 training: %d updates max, ', ...
        '64 balanced trials/update, delays 500:10:700 ms, no noise.\n'], ...
        run.maximumUpdates);
    [bestModel, history] = train_v3_deterministic( ...
        initialModel, params, run, checkpointPath);
    if ~isequal(initialWrec, bestModel.Wrec)
        error('V3Training:FinalWrecChanged', ...
            'Best-model Wrec is not bitwise identical to initialization.');
    end
    canonical = evaluate_v3_canonical(bestModel, params, run);
    delayEvaluation = evaluate_v3_delay_range(bestModel, params, run);
    validation = validate_v3_deterministic( ...
        canonical.metrics, delayEvaluation, run);
    figureFiles = create_v3_intact_plots( ...
        canonical, delayEvaluation, history, params, run);
    wrecSha256 = array_sha256(initialWrec);

    modelArtifact.model = bestModel;
    modelArtifact.params = params;
    modelArtifact.run = run;
    modelArtifact.fixedHybrid = fixed.hybrid;
    modelArtifact.WrecSha256 = wrecSha256;
    modelArtifact.WrecExactUnchanged = true;
    save(fullfile(projectRoot, run.files.bestModel), ...
        'modelArtifact', '-v7.3');
    save(fullfile(projectRoot, run.files.trainingHistory), ...
        'history', 'params', 'run', '-v7.3');
    save(fullfile(projectRoot, run.files.canonicalEvaluation), ...
        'canonical', '-v7.3');
    save(fullfile(projectRoot, run.files.delayEvaluation), ...
        'delayEvaluation', '-v7.3');
    writetable(canonical.byTarget, ...
        fullfile(projectRoot, run.files.targetTable));
    writetable(delayEvaluation.byTarget, ...
        fullfile(projectRoot, run.files.delayTable));
    summary.params = params;
    summary.run = run;
    summary.training = history;
    summary.canonicalMetrics = canonical.metrics;
    summary.delaySummary = delayEvaluation.summary;
    summary.validation = validation;
    summary.figureFiles = figureFiles;
    summary.WrecSha256 = wrecSha256;
    summary.WrecExactUnchanged = true;
    save(fullfile(projectRoot, run.files.summary), 'summary', '-v7.3');

    outcome.model = bestModel;
    outcome.history = history;
    outcome.canonical = canonical;
    outcome.delayEvaluation = delayEvaluation;
    outcome.validation = validation;
    outcome.figureFiles = figureFiles;
    outcome.WrecSha256 = wrecSha256;
    fprintf(['V3 deterministic complete: updates=%d best=%d ', ...
        'bestVal=%.9g runtime=%.2f min meanEndpoint=%.3f mm ', ...
        'worstTarget=%.3f mm terminal=%.6f m/s preGo=%.6f m/s ', ...
        'hold=%.3f mm pass=%d\n'], history.updatesCompleted, ...
        history.bestIteration, history.bestValidationLoss, ...
        history.elapsedSeconds / 60, ...
        1000 * canonical.metrics.meanEndpointErrorM, ...
        1000 * canonical.metrics.worstTargetEndpointErrorM, ...
        canonical.metrics.meanTerminalSpeedMPerSec, ...
        canonical.metrics.preGoRmsSpeedMPerSec, ...
        1000 * canonical.metrics.meanHoldErrorM, validation.passed);
    fprintf('Wrec exact unchanged: 1 | SHA-256 %s\n', wrecSha256);
    fprintf('No noise or cerebellar lesion was run.\n');
end

function hash = array_sha256(value)
    bytes = typecast(single(value(:)), 'uint8');
    engine = java.security.MessageDigest.getInstance('SHA-256');
    engine.update(typecast(bytes, 'int8'));
    digest = typecast(engine.digest(), 'uint8');
    hash = upper(reshape(dec2hex(digest, 2).', 1, []));
end
