function params = model_params()
    params.project.version = 'finalized-intact-v1-retrained-2026-08-19';
    params.seed.initialization = 1729;
    params.seed.trainingTask = 1730;
    params.seed.trainingNoise = 1731;
    params.seed.validationTask = 1732;
    params.seed.validationNoise = 1733;
    params.seed.deterministicEvaluation = 1734;
    params.seed.noisyEvaluation = 1735;
    params.seed.delayEvaluation = 1736;

    params.task.numTargets = 8;
    params.task.targetAnglesDeg = [-90 -45 0 45 90 135 180 225];
    params.task.targetRadiusM = 0.06;
    params.task.cueTimeMs = 0;
    params.task.minimumGoTimeMs = 500;
    params.task.maximumGoTimeMs = 600;
    params.task.canonicalGoTimeMs = 550;
    params.task.movementDurationMs = 500;
    params.task.maximumTrialDurationMs = 1100;

    params.model.numCorticalUnits = 100;
    params.model.activation = 'tanh';
    params.model.tauMs = 20;
    params.model.dtMs = 5;
    params.model.targetInputSize = 8;
    params.model.cerebellarHiddenUnits = 12;
    params.model.cerebellarRank = 5;
    params.model.cerebellarInputSize = 9;
    params.model.recurrentInitializationGain = 0.5;
    params.model.initialStateBaseline = 0;

    params.noise.sigmaInitial = 0.05;
    params.noise.sigmaDynamic = 0.05;
    params.noise.useDuringTraining = true;
    params.noise.useDuringEvaluation = true;

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
    params.training.stageAIterations = 1000;
    params.training.stageBMaxIterations = 4000;
    params.training.useGpuIfAvailable = true;
    params.training.useAcceleratedGradientFunction = false;
    params.training.stageABaseLearnRate = 1e-3;
    params.training.stageBBaseLearnRate = 3e-4;
    params.training.stageBLearnRateDropIteration = 2500;
    params.training.learnRateDropFactor = 0.3;
    params.training.gradientDecayFactor = 0.9;
    params.training.squaredGradientDecayFactor = 0.999;
    params.training.adamEpsilon = 1e-8;
    params.training.gradientThreshold = 1;
    params.training.displayEvery = 50;
    params.training.validationFrequency = 50;
    params.training.validationTrialsPerTarget = 8;
    params.training.minimumStageBIterations = 2000;
    params.training.earlyStoppingPatienceUpdates = 1000;
    params.training.minimumValidationImprovement = 1e-5;
    params.training.positionLossWeight = 5;
    params.training.velocityLossWeight = 3;
    params.training.terminalPositionLossWeight = 25;
    params.training.terminalVelocityLossWeight = 10;
    params.training.preGoLossWeight = 50;
    params.training.jointLimitLossWeight = 0.05;
    params.training.torqueLossWeight = 0.05;
    params.training.activityRegularization = 1e-4;
    params.training.weightRegularization = 1e-5;
    params.training.learningRateMultipliers.Wtarg = 1.0;
    params.training.learningRateMultipliers.Wgo = 1.0;
    params.training.learningRateMultipliers.WcbHidden = 1.0;
    params.training.learningRateMultipliers.bcbHidden = 1.0;
    params.training.learningRateMultipliers.WcbLatent = 1.0;
    params.training.learningRateMultipliers.bcbLatent = 1.0;
    params.training.learningRateMultipliers.Wout = 1.0;
    params.training.learningRateMultipliers.Wrec = 0.1;
    params.training.learningRateMultipliers.Ucb = 0.0;

    params.evaluation.deterministicTrialsPerTarget = 1;
    params.evaluation.trialsPerTarget = 20;
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
    params.plot.targetColors = [ ...
        1.0000, 0,      0.1600; ...
        1.0000, 0.6010, 0; ...
        0.2549, 0.4118, 0.8824; ...
        0,      1.0000, 0.1476; ...
        0.2510, 0.8784, 0.8157; ...
        0.3137, 0.7843, 0.4706; ...
        0.4827, 0,      1.0000; ...
        1.0000, 0,      0.7500];

    params.files.model = fullfile('results', 'intact_model.mat');
    params.files.trainingHistory = ...
        fullfile('results', 'intact_training_history.mat');
    params.files.numericalSummary = ...
        fullfile('results', 'intact_numerical_summary.mat');
    params.files.evaluation = ...
        fullfile('results', 'intact_evaluation.mat');
    params.files.figureRoot = fullfile('plots', 'v1_intact');
end
