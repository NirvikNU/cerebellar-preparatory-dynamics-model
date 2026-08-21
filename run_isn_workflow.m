function outcome = run_isn_workflow(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(mfilename('fullpath'));
    end
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src'));
    addpath(fullfile(projectRoot, 'analysis'));
    addpath(fullfile(projectRoot, 'figures'));
    assert_deep_learning_toolbox();
    params = isn_model_params();
    params = resolve_output_paths(params, projectRoot);
    create_output_directories(params);
    fixed = load_hennequin_isn(params, projectRoot);
    outcome = struct('completed', false, 'reason', 'not started');

    positiveControl = obtain_positive_control(params, fixed, projectRoot);
    create_hennequin_positive_control_plot(positiveControl, fixed, params);
    if ~positiveControl.passed
        outcome.reason = 'Hennequin positive control did not pass.';
        outcome.positiveControl = positiveControl;
        save(fullfile(params.files.positiveControlRoot, ...
            'positive_control_failure.mat'), 'outcome', 'params');
        error('IsnModel:PositiveControlFailed', ...
            ['The high-dimensional time-varying positive control did ', ...
            'not meet the frozen behavioral criteria. Structured V1 ', ...
            'training was not started.']);
    end

    initialModel = initialize_isn_model(params, fixed);
    executionBenchmark = benchmark_isn_gradient_execution( ...
        initialModel, params);
    fprintf(['Gradient benchmark: ordinary %.3f s/update, accelerated ', ...
        '%.3f s/update (%.2fx); selected %s.\n'], ...
        executionBenchmark.ordinarySecondsPerIteration, ...
        executionBenchmark.acceleratedSecondsPerIteration, ...
        executionBenchmark.speedup, execution_label( ...
        executionBenchmark.useAccelerated));
    useAccelerated = executionBenchmark.useAccelerated;

    [stage1Model, stage1History] = train_isn_stage(initialModel, ...
        params, 1, useAccelerated, latest_checkpoint_path(1, params));
    stage1Diagnostics = evaluate_canonical(stage1Model, params, false, ...
        params.evaluation.deterministicTrialsPerTarget, ...
        params.seed.deterministicEvaluation);
    stage1Gate = deterministic_gate(stage1Diagnostics.metrics, params);
    save_stage_checkpoint(1, stage1Model, stage1History, ...
        stage1Diagnostics, stage1Gate, params);
    if ~stage1Gate.allPassed
        error('IsnModel:Stage1Failed', ...
            ['Stage 1 did not establish deterministic endpoint accuracy, ', ...
            'pre-go stationarity, stopping, and safety. Later stages ', ...
            'were not run.']);
    end

    [stage2Model, stage2History] = train_isn_stage(stage1Model, ...
        params, 2, useAccelerated, latest_checkpoint_path(2, params));
    stage2Diagnostics = evaluate_canonical(stage2Model, params, false, ...
        params.evaluation.deterministicTrialsPerTarget, ...
        params.seed.deterministicEvaluation + 100);
    stage2Delay = evaluate_isn_delay_robustness(stage2Model, params, ...
        false, params.evaluation.deterministicTrialsPerTarget, ...
        params.seed.delayEvaluation);
    stage2Gate = delay_gate(stage2Delay, params, false);
    save_stage_checkpoint(2, stage2Model, stage2History, ...
        stage2Diagnostics, stage2Gate, params);
    if ~stage2Gate.allPassed
        error('IsnModel:Stage2Failed', ...
            ['Stage 2 did not meet the frozen deterministic criteria ', ...
            'across 500--600 ms delays. Noise training was not run.']);
    end

    [learnedModel, stage3History] = train_isn_stage(stage2Model, ...
        params, 3, useAccelerated, latest_checkpoint_path(3, params));
    deterministic = evaluate_canonical(learnedModel, params, false, ...
        params.evaluation.deterministicTrialsPerTarget, ...
        params.seed.deterministicEvaluation);
    noisy = evaluate_canonical(learnedModel, params, true, ...
        params.evaluation.noisyTrialsPerTarget, ...
        params.seed.noisyEvaluation);
    deterministicDelay = evaluate_isn_delay_robustness(learnedModel, ...
        params, false, params.evaluation.deterministicTrialsPerTarget, ...
        params.seed.delayEvaluation);
    noisyDelay = evaluate_isn_delay_robustness(learnedModel, params, ...
        true, params.evaluation.noisyTrialsPerTarget, ...
        params.seed.delayEvaluation + 1000);
    canonicalValidation = validate_isn_diagnostics( ...
        deterministic.diagnostics, noisy.diagnostics, params);
    deterministicDelayValidation = delay_gate( ...
        deterministicDelay, params, false);
    noisyDelayValidation = delay_gate(noisyDelay, params, true);
    validation.canonical = canonicalValidation;
    validation.deterministicDelay = deterministicDelayValidation;
    validation.noisyDelay = noisyDelayValidation;
    validation.allPassed = canonicalValidation.allPassed && ...
        deterministicDelayValidation.allPassed && ...
        noisyDelayValidation.allPassed;

    stage3Gate = validation;
    save_stage_checkpoint(3, learnedModel, stage3History, ...
        noisy.diagnostics, stage3Gate, params);
    trainingHistory.stage1 = stage1History;
    trainingHistory.stage2 = stage2History;
    trainingHistory.stage3 = stage3History;
    trainingHistory.executionBenchmark = executionBenchmark;
    model = learnedModel;
    model.metadata = model_metadata(params, fixed, validation);
    model.diagnostics.deterministic = deterministic.diagnostics.metrics;
    model.diagnostics.noisy = noisy.diagnostics.metrics;
    model.validation = validation;
    evaluation.deterministic = deterministic;
    evaluation.noisy = noisy;
    evaluation.delayRobustness.deterministic = deterministicDelay;
    evaluation.delayRobustness.noisy = noisyDelay;
    evaluation.validation = validation;
    numericalSummary = build_summary(positiveControl, fixed, ...
        trainingHistory, evaluation, params);
    save(params.files.model, 'model', 'params', '-v7.3');
    save(params.files.trainingHistory, 'trainingHistory', 'params', '-v7.3');
    save(params.files.evaluation, 'evaluation', 'params', '-v7.3');
    save(params.files.numericalSummary, 'numericalSummary', 'params');
    figureFiles = create_isn_diagnostic_plots(noisy.diagnostics, ...
        deterministicDelay, noisyDelay, noisy.task, params);
    outcome.completed = true;
    outcome.reason = 'Intact Hennequin-ISN workflow completed.';
    outcome.validation = validation;
    outcome.numericalSummary = numericalSummary;
    outcome.figureFiles = figureFiles;
    fprintf(['Intact Hennequin-ISN workflow complete. No lesion, ', ...
        'cerebellar scaling, lesion retraining, or V2 analysis was run.\n']);
end

function params = resolve_output_paths(params, projectRoot)
    fields = {'positiveControlRoot', 'model', 'trainingHistory', ...
        'evaluation', 'numericalSummary', 'figureRoot', ...
        'positiveControlFigureRoot'};
    for fieldIndex = 1:numel(fields)
        name = fields{fieldIndex};
        params.files.(name) = fullfile(projectRoot, params.files.(name));
    end
end

function create_output_directories(params)
    directories = {params.files.positiveControlRoot, ...
        fileparts(params.files.model), params.files.figureRoot, ...
        params.files.positiveControlFigureRoot};
    for directoryIndex = 1:numel(directories)
        if ~isfolder(directories{directoryIndex})
            mkdir(directories{directoryIndex});
        end
    end
end

function result = obtain_positive_control(params, fixed, projectRoot)
    resultPath = fullfile(params.files.positiveControlRoot, ...
        'positive_control.mat');
    if isfile(resultPath)
        loaded = load(resultPath, 'result');
        result = loaded.result;
        complete = isfield(result, 'history') && ...
            numel(result.history.loss) == params.positiveControl.maxIterations;
        if complete
            fprintf('Using completed Hennequin positive-control result.\n');
            return;
        end
    end
    result = run_hennequin_positive_control(params, fixed, projectRoot);
end

function result = evaluate_canonical(model, params, noisy, trials, seed)
    task = build_isn_reach_task(params, trials, ...
        params.task.canonicalGoTimeMs, []);
    simulation = simulate_isn_model(model, task, params, seed, noisy);
    result.task = task;
    result.diagnostics = compute_isn_diagnostics(model, simulation, ...
        task, params);
end

function gate = deterministic_gate(metrics, params)
    gate.meanEndpointAccuracyPassed = metrics.meanEndpointErrorM <= ...
        params.validation.maxMeanEndpointErrorM;
    gate.maximumEndpointAccuracyPassed = ...
        metrics.maximumTargetAveragedEndpointErrorM <= ...
        params.validation.maxTargetAveragedEndpointErrorM;
    gate.preGoStationarityPassed = ...
        metrics.preGoRmsEndpointSpeedMPerSec <= ...
        params.validation.maxDeterministicPreGoRmsSpeedMPerSec;
    gate.terminalSpeedPassed = metrics.meanTerminalSpeedMPerSec <= ...
        params.validation.maxTerminalSpeedMPerSec;
    gate.jointSafetyPassed = metrics.hardJointLimitContactFraction <= ...
        params.validation.maxJointContactFraction;
    gate.torqueSafetyPassed = metrics.hardTorqueSaturationFraction <= ...
        params.validation.maxTorqueSaturationFraction;
    gate.allPassed = all(cellfun(@(value) islogical(value) && value, ...
        struct2cell(gate)));
end

function gate = delay_gate(robustness, params, noisy)
    gate.meanEndpointAccuracyPassed = all( ...
        robustness.meanEndpointErrorM <= ...
        params.validation.maxMeanEndpointErrorM);
    gate.maximumEndpointAccuracyPassed = all( ...
        robustness.maximumTargetAveragedEndpointErrorM <= ...
        params.validation.maxTargetAveragedEndpointErrorM);
    gate.terminalSpeedPassed = all( ...
        robustness.meanTerminalSpeedMPerSec <= ...
        params.validation.maxTerminalSpeedMPerSec);
    if noisy
        speedLimit = params.validation.maxNoisyPreGoRmsSpeedMPerSec;
    else
        speedLimit = ...
            params.validation.maxDeterministicPreGoRmsSpeedMPerSec;
    end
    gate.preGoStationarityPassed = all( ...
        robustness.preGoRmsEndpointSpeedMPerSec <= speedLimit);
    gate.allPassed = all(cellfun(@(value) islogical(value) && value, ...
        struct2cell(gate)));
end

function save_stage_checkpoint(number, model, history, diagnostics, gate, params)
    path = fullfile(fileparts(params.files.model), ...
        sprintf('checkpoint_stage%d.mat', number));
    save(path, 'model', 'history', 'diagnostics', 'gate', 'params', '-v7.3');
end

function path = latest_checkpoint_path(number, params)
    path = fullfile(fileparts(params.files.model), ...
        sprintf('training_stage%d_latest.mat', number));
end

function metadata = model_metadata(params, fixed, validation)
    metadata.projectVersion = params.project.version;
    metadata.trainedAt = char(datetime('now', 'TimeZone', 'local', ...
        'Format', 'yyyy-MM-dd HH:mm:ss Z'));
    metadata.intactOnly = true;
    metadata.fixedHennequinBackbone = true;
    metadata.fixedBaseline = true;
    metadata.cortex = '200-unit ReLU, tau 150 ms';
    metadata.targetInput = 'continuous 8-D one-hot identity';
    metadata.goInput = '75-ms cortical pulse';
    metadata.cerebellarInput = 'target identity and elapsed cue time only';
    metadata.cerebellarReceivesGo = false;
    metadata.cerebellarReceivesStateFeedback = false;
    metadata.cerebellarDynamics = ...
        'c_inf(q)+exp(-t/150 ms)*(0-c_inf(q))';
    metadata.motorOutput = 'shoulder and elbow torque';
    metadata.targetAnglesDeg = params.task.targetAnglesDeg;
    metadata.targetColors = params.plot.targetColors;
    metadata.batchSize = params.training.batchSize;
    metadata.WrecSourceSha256 = fixed.sourceSha256;
    metadata.WrecSourceCommit = fixed.sourceCommit;
    metadata.WrecSpectralAbscissa = fixed.spectralAbscissa;
    metadata.validation = validation;
end

function summary = build_summary(positiveControl, fixed, history, evaluation, params)
    summary.projectVersion = params.project.version;
    summary.positiveControl = positiveControl.metrics;
    summary.positiveControlPassed = positiveControl.passed;
    summary.fixedBackbone.spectralAbscissa = fixed.spectralAbscissa;
    summary.fixedBackbone.spectralRadius = fixed.spectralRadius;
    summary.fixedBackbone.nonnormalCommutator = fixed.nonnormalCommutator;
    summary.fixedBackbone.sourceSha256 = fixed.sourceSha256;
    summary.training.stage1Updates = history.stage1.updatesCompleted;
    summary.training.stage2Updates = history.stage2.updatesCompleted;
    summary.training.stage3Updates = history.stage3.updatesCompleted;
    summary.training.executionBenchmark = history.executionBenchmark;
    summary.deterministic = evaluation.deterministic.diagnostics.metrics;
    summary.noisy = evaluation.noisy.diagnostics.metrics;
    summary.validation = evaluation.validation;
end

function label = execution_label(useAccelerated)
    if useAccelerated
        label = 'dlaccelerate';
    else
        label = 'ordinary dlfeval';
    end
end
