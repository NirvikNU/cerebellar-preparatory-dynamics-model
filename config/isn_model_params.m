function params = isn_model_params()
    params.project.version = 'v1-hennequin-isn-intact-2026-08-21';
    params.seed = struct('initialization', 1729, 'trainingTask', 1730, ...
        'trainingNoise', 1731, 'validationTask', 1732, ...
        'validationNoise', 1733, 'deterministicEvaluation', 1734, ...
        'noisyEvaluation', 1735, 'delayEvaluation', 1736, ...
        'baselineRates', 1737, 'positiveControl', 1738);

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
    params.model.cerebellarInputSize = 8;
    params.model.cerebellarTauMs = 150;
    params.model.cerebellarInitialState = zeros(5, 1);
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

    params.plant.L1 = 0.15;
    params.plant.L2 = 0.21;
    params.plant.m1 = 0.30;
    params.plant.m2 = 0.30;
    params.plant.lc1 = 0.07;
    params.plant.lc2 = 0.12;
    params.plant.I1 = 0.005;
    params.plant.I2 = 0.009;
    params.plant.damping = [0.0050 0.0025; 0.0025 0.0050];
    params.plant.initialJointAnglesRad = deg2rad([0; 90]);
    params.plant.initialJointVelocityRadPerSec = [0; 0];
    params.plant.jointLowerLimitsRad = deg2rad([-45; 0]);
    params.plant.jointUpperLimitsRad = deg2rad([135; 135]);
    params.plant.jointPenaltyMarginRad = deg2rad(8);
    params.plant.jointPenaltySoftnessRad = deg2rad(2);
    params.plant.torqueGuidelineNm = 0.25;
    params.plant.torquePenaltySoftnessNm = 0.025;
    params.plant.useHardSafetyClipping = true;
    params.plant.hardTorqueSafetyLimitNm = 0.50;

    params.training.batchSize = 64;
    params.training.trialsPerTarget = 8;
    params.training.validationTrialsPerTarget = 8;
    params.training.useGpuIfAvailable = true;
    params.training.benchmarkAcceleratedExecution = true;
    params.training.benchmarkRepetitions = 3;
    params.training.stage1MaxIterations = 4000;
    params.training.stage2MaxIterations = 2500;
    params.training.stage3MaxIterations = 2500;
    params.training.stage1LearnRate = 1e-3;
    params.training.stage2LearnRate = 3e-4;
    params.training.stage3LearnRate = 1e-4;
    params.training.gradientDecayFactor = 0.9;
    params.training.squaredGradientDecayFactor = 0.999;
    params.training.adamEpsilon = 1e-8;
    params.training.gradientThreshold = 1;
    params.training.validationFrequency = 50;
    params.training.displayEvery = 50;
    params.training.checkpointFrequency = 250;
    params.training.earlyStoppingPatienceUpdates = 1000;
    params.training.minimumValidationImprovement = 1e-6;
    params.training.learningRatePlateauPatienceUpdates = 300;
    params.training.learningRateDropFactor = 0.5;
    params.training.minimumLearningRateFraction = 0.01;
    params.training.preGoPositionLossWeight = 200;
    params.training.preGoVelocityLossWeight = 100;
    params.training.preGoTorqueLossWeight = 1;
    params.training.endpointUrgencyLossWeight = 10;
    params.training.terminalPositionLossWeight = 100;
    params.training.terminalVelocityLossWeight = 50;
    params.training.holdPositionLossWeight = 100;
    params.training.holdVelocityLossWeight = 50;
    params.training.controlEffortLossWeight = 1e-3;
    params.training.jointLimitLossWeight = 0.05;
    params.training.torqueLimitLossWeight = 0.05;
    params.training.activityRegularization = 1e-5;
    params.training.weightRegularization = 1e-6;
    fields = {'Wtarg', 'Wgo', 'WcbHidden', 'bcbHidden', ...
        'WcbLatent', 'bcbLatent', 'Ucb', 'Wout'};
    for fieldIndex = 1:numel(fields)
        params.training.learningRateMultipliers.(fields{fieldIndex}) = 1;
    end
    params.training.learningRateMultipliers.Wout = 0.01;

    params.positiveControl.numTemporalBasis = 33;
    params.positiveControl.basisWidthMs = 60;
    params.positiveControl.maxIterations = 1500;
    params.positiveControl.controlLearnRate = 1e-5;
    params.positiveControl.readoutLearnRate = 1e-7;
    params.positiveControl.gradientThreshold = 1;
    params.positiveControl.validationFrequency = 50;
    params.positiveControl.controlEffortWeight = 1e-5;

    params.evaluation.deterministicTrialsPerTarget = 1;
    params.evaluation.noisyTrialsPerTarget = 20;
    params.evaluation.delayValuesMs = 500:10:600;
    params.evaluation.latePreparationStartMs = 400;
    params.evaluation.latePreparationEndMs = 495;
    params.evaluation.jpcaNumPcs = 6;
    params.validation.maxMeanEndpointErrorM = 0.003;
    params.validation.maxTargetAveragedEndpointErrorM = 0.005;
    params.validation.maxTerminalSpeedMPerSec = 0.02;
    params.validation.maxDeterministicPreGoRmsSpeedMPerSec = 0.002;
    params.validation.maxNoisyPreGoRmsSpeedMPerSec = 0.015;
    params.validation.maxJointContactFraction = 1e-3;
    params.validation.maxTorqueSaturationFraction = 1e-3;

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
    params.files.positiveControlRoot = ...
        fullfile('results', 'validation_hennequin');
    params.files.model = fullfile('results', 'v1_isn_intact', ...
        'intact_model.mat');
    params.files.trainingHistory = fullfile('results', ...
        'v1_isn_intact', 'training_history.mat');
    params.files.evaluation = fullfile('results', ...
        'v1_isn_intact', 'evaluation.mat');
    params.files.numericalSummary = fullfile('results', ...
        'v1_isn_intact', 'numerical_summary.mat');
    params.files.figureRoot = fullfile('plots', 'v1_isn_intact');
    params.files.positiveControlFigureRoot = ...
        fullfile('plots', 'validation_hennequin');
end
