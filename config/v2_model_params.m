function params = v2_model_params()
    params.project.version = 'v2-no-plant-intact-2026-08-22';
    params.seed = struct('initialization', 1729, 'trainingTask', 1730, ...
        'trainingNoise', 1731, 'validationTask', 1732, ...
        'validationNoise', 1733, 'deterministicEvaluation', 1734, ...
        'noisyEvaluation', 1735, 'delayEvaluation', 1736, ...
        'baselineRates', 1737);

    params.task.numTargets = 8;
    params.task.targetAnglesDeg = [-90 -45 0 45 90 135 180 225];
    params.task.targetRadiusM = 0.06;
    params.task.minimumGoTimeMs = 500;
    params.task.maximumGoTimeMs = 600;
    params.task.canonicalGoTimeMs = 550;
    params.task.goPulseDurationMs = 75;
    params.task.movementDurationMs = 500;
    params.task.holdDurationMs = 200;
    params.task.maximumTrialDurationMs = 1300;

    params.model.numCorticalUnits = 200;
    params.model.activation = 'relu';
    params.model.tauMs = 150;
    params.model.dtMs = 5;
    params.model.targetInputSize = 8;
    params.model.cerebellarHiddenUnits = 180;
    params.model.cerebellarRank = 5;
    params.model.cerebellarTauMs = 150;
    params.model.baselineMeanHz = 5;
    params.model.baselineStdHz = 5;
    params.model.requiredGpuName = 'NVIDIA RTX 6000 Ada Generation';
    params.model.isnSourceRepository = ...
        'https://github.com/marineschimel/why-prep-2';
    params.model.isnSourceCommit = ...
        '09d1949a43c0b5066a888b0ceb2a951e70539992';
    params.model.isnSourcePath = 'data/w_rec';
    params.model.isnSourceSha256 = ...
        '1E5DC654FD9EAE46E2F01C0BB67118378CE6AE9007227A1A3BF5488EA39B411D';
    params.model.isnSpectralAbscissaLimit = 0.8;

    params.noise.sigmaInitialHz = 0.5;
    params.noise.sigmaDynamicHz = 0.5;

    params.training.batchSize = 64;
    params.training.trialsPerTarget = 8;
    params.training.validationTrialsPerTarget = 8;
    params.training.useGpu = true;
    params.training.benchmarkUpdates = 20;
    params.training.benchmarkRepetitions = 3;
    params.training.acceleratedWarmupCalls = 6;
    params.training.maximumSecondsPerUpdateAfterWarmup = 3;
    params.training.maximumEstimatedRuntimeSeconds = 3600;
    params.training.stageAMaxIterations = 2000;
    params.training.stageBMaxIterations = 1000;
    params.training.stageALearnRate = 1e-3;
    params.training.stageBLearnRate = 1e-4;
    params.training.gradientDecayFactor = 0.9;
    params.training.squaredGradientDecayFactor = 0.999;
    params.training.adamEpsilon = 1e-8;
    params.training.gradientThreshold = 1;
    params.training.validationFrequency = 25;
    params.training.displayEvery = 25;
    params.training.checkpointFrequency = 250;
    params.training.earlyStoppingPatienceUpdates = 400;
    params.training.minimumValidationImprovement = 1e-5;
    params.training.learningRatePlateauPatienceUpdates = 200;
    params.training.learningRateDropFactor = 0.5;
    params.training.minimumLearningRateFraction = 0.01;
    params.training.velocityScaleMPerSec = 0.25;
    params.training.preGoPositionLossWeight = 200;
    params.training.preGoVelocityLossWeight = 100;
    params.training.endpointUrgencyLossWeight = 10;
    params.training.terminalPositionLossWeight = 100;
    params.training.terminalVelocityLossWeight = 50;
    params.training.holdPositionLossWeight = 100;
    params.training.holdVelocityLossWeight = 50;
    params.training.velocityEffortLossWeight = 1e-3;
    params.training.activityRegularization = 1e-5;
    params.training.weightRegularization = 1e-6;
    fields = {'Wtarg', 'Wgo', 'WcbHidden', 'bcbHidden', ...
        'WcbLatent', 'bcbLatent', 'Ucb', 'Wout'};
    for fieldIndex = 1:numel(fields)
        params.training.learningRateMultipliers.(fields{fieldIndex}) = 1;
    end
    params.training.learningRateMultipliers.Wout = 0.001;

    params.evaluation.deterministicTrialsPerTarget = 1;
    params.evaluation.noisyTrialsPerTarget = 20;
    params.evaluation.delayValuesMs = 500:10:600;
    params.evaluation.latePreparationStartMs = 400;
    params.evaluation.latePreparationEndMs = 495;
    params.validation.maxMeanEndpointErrorM = 0.003;
    params.validation.maxTargetAveragedEndpointErrorM = 0.005;
    params.validation.maxTerminalSpeedMPerSec = 0.02;
    params.validation.maxDeterministicPreGoRmsSpeedMPerSec = 0.002;
    params.validation.maxNoisyPreGoRmsSpeedMPerSec = 0.015;
    params.validation.maxMeanHoldErrorM = 0.005;
    params.validation.maxMeanHoldSpeedMPerSec = 0.02;

    params.plot.visible = 'off';
    params.plot.fontSize = 16;
    params.plot.tickDirection = 'out';
    params.plot.axisColor = 'k';
    params.plot.axisLineWidth = 0.5;
    params.plot.lineWidth = 2;
    params.plot.referenceLineWidth = 1.2;
    params.plot.resolution = 300;
    params.plot.preGoDisplayMs = 300;
    params.plot.targetColors = [1 0 0.16; 1 0.601 0; ...
        0.2549 0.4118 0.8824; 0 1 0.1476; ...
        0.2510 0.8784 0.8157; 0.3137 0.7843 0.4706; ...
        0.4827 0 1; 1 0 0.75];

    params.files.isnMatrix = fullfile('config', 'why_prep_2_w_rec.txt');
    params.files.resultRoot = fullfile('results', 'v2_no_plant_intact');
    params.files.figureRoot = fullfile('plots', 'v2_no_plant_intact');
    params.files.model = fullfile(params.files.resultRoot, 'intact_model.mat');
    params.files.trainingHistory = fullfile(params.files.resultRoot, ...
        'training_history.mat');
    params.files.deterministicEvaluation = fullfile( ...
        params.files.resultRoot, 'deterministic_evaluation.mat');
    params.files.noisyEvaluation = fullfile(params.files.resultRoot, ...
        'noisy_evaluation.mat');
    params.files.delayEvaluation = fullfile(params.files.resultRoot, ...
        'delay_robustness.mat');
    params.files.numericalSummary = fullfile(params.files.resultRoot, ...
        'numerical_summary.mat');
    params.files.runtimeBenchmark = fullfile(params.files.resultRoot, ...
        'runtime_benchmark.mat');
end
