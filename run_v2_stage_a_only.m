function outcome = run_v2_stage_a_only(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(mfilename('fullpath'));
    end
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src'));
    addpath(fullfile(projectRoot, 'analysis'));
    addpath(fullfile(projectRoot, 'figures'));
    params = v2_model_params();
    params.training.stageAMaxIterations = 1000;
    params.training.validationFrequency = 50;
    params.training.displayEvery = 50;
    params.training.checkpointFrequency = 250;
    params = resolve_output_paths(params, projectRoot);
    paths = stage_a_paths(params);
    create_directories(params, paths);
    fixed = load_hennequin_isn(params, projectRoot);
    initialModel = initialize_v2_model(params, fixed);
    verify_one_balanced_batch(params);
    fprintf(['Launching bounded Stage A deterministic acquisition: ', ...
        'maximum 1,000 updates; Stage B is disabled.\n']);
    [bestModel, history] = train_v2_stage(initialModel, params, 'A', ...
        true, paths.checkpoint);
    fprintf(['Stage A optimizer finished after %d updates in %.2f min; ', ...
        'best update %d, best validation loss %.6f.\n'], ...
        history.updatesCompleted, history.elapsedSeconds / 60, ...
        history.bestIteration, history.bestValidationLoss);

    evaluation = evaluate_v2_canonical(bestModel, params, false, ...
        params.evaluation.deterministicTrialsPerTarget, ...
        params.seed.deterministicEvaluation);
    delay = evaluate_v2_delay_robustness(bestModel, params, false, ...
        params.evaluation.deterministicTrialsPerTarget, ...
        params.seed.delayEvaluation);
    validation = validate_v2_stage_a(evaluation.diagnostics, delay, params);
    trainingHistory.stageA = history;
    delayRobustness.deterministic = delay;
    figureFiles = create_v2_diagnostic_plots(evaluation, [], ...
        delayRobustness, trainingHistory, params);
    summary = build_v2_stage_a_summary(bestModel, fixed, history, ...
        evaluation, delay, validation, figureFiles, paths, params);
    model = bestModel;
    model.metadata = stage_a_metadata(summary, fixed);
    save(paths.model, 'model', 'params', '-v7.3');
    save(paths.history, 'history', 'params', '-v7.3');
    save(paths.evaluation, 'evaluation', 'params', '-v7.3');
    save(paths.delay, 'delay', 'params', '-v7.3');
    save(paths.summary, 'summary', 'params');
    print_stage_a_summary(summary);
    outcome.completed = true;
    outcome.summary = summary;
    outcome.validation = validation;
    outcome.figureFiles = figureFiles;
    outcome.stageBRun = false;
    outcome.lesionRun = false;
end

function params = resolve_output_paths(params, projectRoot)
    names = fieldnames(params.files);
    for nameIndex = 1:numel(names)
        name = names{nameIndex};
        if ~strcmp(name, 'isnMatrix')
            params.files.(name) = fullfile(projectRoot, params.files.(name));
        end
    end
end

function paths = stage_a_paths(params)
    root = params.files.resultRoot;
    paths.checkpoint = fullfile(root, 'stage_a_checkpoint_latest.mat');
    paths.model = fullfile(root, 'stage_a_best_model.mat');
    paths.history = fullfile(root, 'stage_a_training_history.mat');
    paths.evaluation = fullfile(root, ...
        'stage_a_deterministic_evaluation.mat');
    paths.delay = fullfile(root, 'stage_a_delay_robustness.mat');
    paths.summary = fullfile(root, 'stage_a_numerical_summary.mat');
end

function create_directories(params, paths)
    directories = {params.files.resultRoot, params.files.figureRoot, ...
        fileparts(paths.checkpoint)};
    for directoryIndex = 1:numel(directories)
        if ~isfolder(directories{directoryIndex})
            mkdir(directories{directoryIndex});
        end
    end
end

function verify_one_balanced_batch(params)
    stream = RandStream('mt19937ar', 'Seed', ...
        params.seed.trainingTask + 7000);
    task = sample_balanced_v2_task(params, ...
        params.training.trialsPerTarget, stream);
    counts = accumarray(task.targetIndex(:), 1, ...
        [params.task.numTargets 1]);
    allowedDelays = params.task.minimumGoTimeMs:params.model.dtMs: ...
        params.task.maximumGoTimeMs;
    expectedTimeSteps = params.task.maximumTrialDurationMs / ...
        params.model.dtMs + 1;
    passed = task.numTrials == params.training.batchSize && ...
        all(counts == params.training.trialsPerTarget) && ...
        all(ismember(double(task.goTimeMs), allowedDelays)) && ...
        task.numTimeSteps == expectedTimeSteps && ...
        isequal(size(task.preGoMask), ...
        [params.training.batchSize expectedTimeSteps]);
    if ~passed
        error('V2Model:StageABatchPreflight', ...
            'Balanced fixed-shape Stage A batch verification failed.');
    end
    fprintf(['Stage A batch verified once: 64 trials, 8/target, ', ...
        'delays 500:5:600 ms, fixed mask 64-by-%d, neural noise off.\n'], ...
        expectedTimeSteps);
end

function metadata = stage_a_metadata(summary, fixed)
    metadata.scope = summary.scope;
    metadata.bestIteration = summary.training.bestIteration;
    metadata.bestValidationLoss = summary.training.bestValidationLoss;
    metadata.validation = summary.validation;
    metadata.fixedWrec = true;
    metadata.WrecSha256 = fixed.sourceSha256;
    metadata.stageBRun = false;
    metadata.lesionRun = false;
end

function print_stage_a_summary(summary)
    metrics = summary.metrics;
    fprintf(['Stage A best: endpoint %.3f mm, worst target %.3f mm, ', ...
        'terminal %.5f m/s, pre-go %.5f m/s, hold %.3f mm at ', ...
        '%.5f m/s; all deterministic checks passed %d.\n'], ...
        1000 * metrics.meanEndpointErrorM, ...
        1000 * metrics.maximumTargetAveragedEndpointErrorM, ...
        metrics.meanTerminalSpeedMPerSec, ...
        metrics.preGoRmsSpeedMPerSec, ...
        1000 * metrics.meanHoldErrorM, metrics.meanHoldSpeedMPerSec, ...
        summary.validation.allPassed);
    fprintf('Recommendation: %s. Stage B and lesion work were not run.\n', ...
        summary.recommendation);
end
