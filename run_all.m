clearvars;
close all;
clc;

projectRoot = fileparts(mfilename('fullpath'));
projectFolders = {'config', 'src', 'analysis', 'figures'};
for folderIndex = 1:numel(projectFolders)
    addpath(fullfile(projectRoot, projectFolders{folderIndex}));
end

params = model_params();
params.files.model = fullfile(projectRoot, params.files.model);
params.files.trainingHistory = ...
    fullfile(projectRoot, params.files.trainingHistory);
params.files.numericalSummary = ...
    fullfile(projectRoot, params.files.numericalSummary);
params.files.evaluation = ...
    fullfile(projectRoot, params.files.evaluation);
params.files.figureRoot = ...
    fullfile(projectRoot, params.files.figureRoot);

requiredDirectories = {fullfile(projectRoot, 'results'), ...
    fullfile(params.files.figureRoot, 'behavior'), ...
    fullfile(params.files.figureRoot, 'neural'), ...
    fullfile(params.files.figureRoot, 'cerebellar'), ...
    fullfile(params.files.figureRoot, 'plant')};
for directoryIndex = 1:numel(requiredDirectories)
    if ~isfolder(requiredDirectories{directoryIndex})
        mkdir(requiredDirectories{directoryIndex});
    end
end

assert_deep_learning_toolbox();
fprintf(['Retraining intact V1 with balanced 64-trial minibatches, ', ...
    'fixed U_cb, and staged deterministic/noisy optimization.\n']);
[learnedModel, trainingHistory] = train_intact_model(params);

fprintf('Evaluating deterministic canonical 550-ms-delay trials.\n');
deterministicTask = build_reach_task(params, ...
    params.evaluation.deterministicTrialsPerTarget, ...
    params.task.canonicalGoTimeMs);
deterministicSimulation = simulate_intact_model(learnedModel, ...
    deterministicTask, params, params.seed.deterministicEvaluation, false);
deterministicDiagnostics = compute_intact_diagnostics(learnedModel, ...
    deterministicSimulation, deterministicTask, params, ...
    trainingHistory.bestValidationTotalLoss);

fprintf('Evaluating noisy canonical 550-ms-delay trials.\n');
noisyTask = build_reach_task(params, params.evaluation.trialsPerTarget, ...
    params.task.canonicalGoTimeMs);
noisySimulation = simulate_intact_model(learnedModel, noisyTask, params, ...
    params.seed.noisyEvaluation, true);
noisyDiagnostics = compute_intact_diagnostics(learnedModel, ...
    noisySimulation, noisyTask, params, ...
    trainingHistory.bestValidationTotalLoss);

fprintf('Evaluating deterministic and noisy 500-600 ms delays.\n');
delayRobustness.deterministic = evaluate_delay_robustness( ...
    learnedModel, params, false, ...
    params.evaluation.deterministicTrialsPerTarget, ...
    params.seed.delayEvaluation);
delayRobustness.noisy = evaluate_delay_robustness(learnedModel, ...
    params, true, params.evaluation.trialsPerTarget, ...
    params.seed.delayEvaluation + 1000);
validation = validate_intact_diagnostics( ...
    deterministicDiagnostics, noisyDiagnostics, params);

model = learnedModel;
model.metadata.projectVersion = params.project.version;
model.metadata.trainedAt = char(datetime('now', 'TimeZone', 'local', ...
    'Format', 'yyyy-MM-dd HH:mm:ss Z'));
model.metadata.intactOnly = true;
model.metadata.frozenForFutureLesions = true;
model.metadata.targetInput = '8-D one-hot identity only';
model.metadata.cerebellarInput = ...
    '8-D one-hot identity plus normalized elapsed cue time';
model.metadata.cerebellarReceivesGo = false;
model.metadata.cerebellarReceivesStateFeedback = false;
model.metadata.motorOutput = 'shoulder and elbow torque';
model.metadata.targetAnglesDeg = params.task.targetAnglesDeg;
model.metadata.targetColors = params.plot.targetColors;
model.metadata.batchSize = params.training.batchSize;
model.metadata.bestValidationIteration = ...
    trainingHistory.bestValidationIteration;
model.metadata.UcbFrozen = true;
model.metadata.WrecLearningRateMultiplier = ...
    params.training.learningRateMultipliers.Wrec;
model.diagnostics.deterministic = deterministicDiagnostics.metrics;
model.diagnostics.noisy = noisyDiagnostics.metrics;
model.plasticity.normalizedWrecChange = ...
    trainingHistory.normalizedWrecChange;
model.plasticity.absoluteUcbChange = trainingHistory.absoluteUcbChange;
model.validation = validation;

numericalSummary = build_intact_numerical_summary(trainingHistory, ...
    deterministicDiagnostics, noisyDiagnostics, delayRobustness, ...
    validation, params);
evaluationSummary.deterministic.diagnostics = deterministicDiagnostics;
evaluationSummary.noisy.diagnostics = noisyDiagnostics;
evaluationSummary.delayRobustness = delayRobustness;
evaluationSummary.validation = validation;

save(params.files.model, 'model', 'params', '-v7.3');
save(params.files.trainingHistory, 'trainingHistory', 'params', '-v7.3');
save(params.files.numericalSummary, 'numericalSummary', 'params');
save(params.files.evaluation, 'evaluationSummary', 'params', '-v7.3');

figureFiles = create_intact_diagnostic_plots( ...
    noisyDiagnostics, delayRobustness, noisyTask, params);
print_intact_summary(numericalSummary);

fprintf('Saved trained checkpoint: %s\n', params.files.model);
fprintf('Saved training history: %s\n', params.files.trainingHistory);
fprintf('Saved numerical summary: %s\n', params.files.numericalSummary);
fprintf('Saved evaluation summary: %s\n', params.files.evaluation);
fprintf('Saved %d figure files:\n', numel(figureFiles));
for fileIndex = 1:numel(figureFiles)
    fprintf('  %s\n', figureFiles{fileIndex});
end

if validation.allPassed
    fprintf('All configured retrained intact V1 checks passed.\n');
else
    warning('IntactModel:Validation', ...
        ['One or more retrained intact V1 behavioral criteria did not ', ...
        'pass; the criteria were not relaxed.']);
end
fprintf(['Improved intact V1 workflow complete. No lesion, cerebellar ', ...
    'scaling, retraining-after-lesion, or V2 analysis was run.\n']);
