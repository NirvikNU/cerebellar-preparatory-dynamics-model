function run = v3_deterministic_run_params(params)
    if ~strcmp(params.project.version, ...
            'v3-romano-hennequin-hybrid-scaffold-2026-08-22')
        error('V3Training:ConfigVersion', ...
            'Deterministic training requires the committed Step-3B config.');
    end
    run.maximumUpdates = 2000;
    run.baseLearnRate = 1e-3;
    run.gradientDecayFactor = 0.9;
    run.squaredGradientDecayFactor = 0.999;
    run.adamEpsilon = 1e-8;
    run.gradientThreshold = 1;
    run.validationTrialsPerTarget = 8;
    run.validationFrequency = 25;
    run.displayEvery = 25;
    run.checkpointFrequency = 250;
    run.earlyStoppingPatienceUpdates = 400;
    run.minimumValidationImprovement = 1e-5;
    run.learningRatePlateauPatienceUpdates = 200;
    run.learningRateDropFactor = 0.5;
    run.minimumLearningRateFraction = 0.01;
    run.acceleratedWarmupCalls = 6;
    run.useAccelerated = true;
    run.requiredGpuName = 'NVIDIA RTX 6000 Ada Generation';
    run.seed.validationTask = 1732;
    run.seed.validationNoise = 1733;
    run.seed.canonicalEvaluation = 1734;
    run.seed.delayEvaluation = 1736;
    run.acceptance.maxMeanEndpointErrorM = 0.003;
    run.acceptance.maxWorstTargetEndpointErrorM = 0.005;
    run.acceptance.maxTerminalSpeedMPerSec = 0.02;
    run.acceptance.maxPreGoRmsSpeedMPerSec = 0.002;
    run.acceptance.maxMeanHoldErrorM = 0.005;
    run.acceptance.maxMeanHoldSpeedMPerSec = 0.02;
    run.files.checkpoint = fullfile(params.files.resultRoot, ...
        'deterministic_checkpoint_latest.mat');
    run.files.bestModel = fullfile(params.files.resultRoot, ...
        'deterministic_best_model.mat');
    run.files.trainingHistory = fullfile(params.files.resultRoot, ...
        'deterministic_training_history.mat');
    run.files.canonicalEvaluation = fullfile(params.files.resultRoot, ...
        'deterministic_canonical_evaluation.mat');
    run.files.delayEvaluation = fullfile(params.files.resultRoot, ...
        'deterministic_delay_evaluation.mat');
    run.files.summary = fullfile(params.files.resultRoot, ...
        'deterministic_summary.mat');
    run.files.targetTable = fullfile(params.files.resultRoot, ...
        'deterministic_canonical_by_target.csv');
    run.files.delayTable = fullfile(params.files.resultRoot, ...
        'deterministic_delay_by_target.csv');
    run.plot.visible = 'off';
    run.plot.fontSize = 14;
    run.plot.resolution = 300;
    run.plot.lineWidth = 1.8;
    run.plot.targetColors = [1 0 0.16; 1 0.601 0; ...
        0.2549 0.4118 0.8824; 0 1 0.1476; ...
        0.2510 0.8784 0.8157; 0.3137 0.7843 0.4706; ...
        0.4827 0 1; 1 0 0.75];
end
