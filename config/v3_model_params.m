function params = v3_model_params()
    params.project.version = 'v3-romano-hennequin-hybrid-scaffold-2026-08-22';
    params.seed = struct('initialization', 1729, 'trainingTask', 1730, ...
        'trainingNoise', 1731, 'smokeSimulation', 1734, ...
        'baselineRates', 1737, 'hybridBasis', 31831, ...
        'geometryNull', 31832);

    params.task.numTargets = 8;
    params.task.targetAnglesDeg = [-90 -45 0 45 90 135 180 225];
    params.task.targetRadiusM = 0.06;
    params.task.delayGridMs = 500:10:700;
    params.task.minimumGoTimeMs = 500;
    params.task.maximumGoTimeMs = 700;
    params.task.canonicalGoTimeMs = 600;
    params.task.goPulseDurationMs = 75;
    params.task.movementDurationMs = 500;
    params.task.holdDurationMs = 200;
    params.task.maximumTrialDurationMs = 1400;

    params.model.numCorticalUnits = 200;
    params.model.activation = 'relu';
    params.model.tauMs = 150;
    params.model.dtMs = 5;
    params.model.targetInputSize = 8;
    params.model.cerebellarInputNames = {'targetIdentity'};
    params.model.cerebellarHiddenUnits = 12;
    params.model.cerebellarRank = 5;
    params.model.cerebellarTauMs = 150;
    params.model.baselineMeanHz = 5;
    params.model.baselineStdHz = 5;

    params.hybrid.kPrep = 10;
    params.hybrid.kMove = 10;
    params.hybrid.randomSeed = params.seed.hybridBasis;
    params.hybrid.preparationBlockScale = 0.55;
    params.hybrid.movementDiagonalScale = 0.45;
    params.hybrid.movementNonNormalScale = 3.0;
    params.hybrid.prepToMovementCouplingScale = 0.75;
    params.hybrid.backgroundScale = 0.20;
    params.hybrid.referenceSpectralAbscissaFraction = 0.90;
    params.hybrid.maximumReferenceFrobeniusFraction = 0.25;

    params.reference.repository = ...
        'https://github.com/marineschimel/why-prep-2';
    params.reference.commit = ...
        '09d1949a43c0b5066a888b0ceb2a951e70539992';
    params.reference.path = 'data/w_rec';
    params.reference.sha256 = ...
        '1E5DC654FD9EAE46E2F01C0BB67118378CE6AE9007227A1A3BF5488EA39B411D';

    params.initialization.targetScale = 0.05;
    params.initialization.goScale = 0.55;
    params.initialization.cerebellarProjectionScale = 0.05;
    params.initialization.cerebellarHiddenScale = 1;
    params.initialization.cerebellarLatentScale = 0.1;
    params.initialization.readoutScale = 1e-4;

    params.noise.sigmaInitialHz = 0;
    params.noise.sigmaDynamicHz = 0;

    params.training.batchSize = 64;
    params.training.trialsPerTarget = 8;
    params.training.velocityScaleMPerSec = 0.25;
    params.training.latePreGoWindowMs = 150;
    params.training.preGoPositionLossWeight = 200;
    params.training.preGoVelocityLossWeight = 100;
    params.training.latePreGoVelocityLossWeight = 50;
    params.training.endpointUrgencyLossWeight = 10;
    params.training.terminalPositionLossWeight = 100;
    params.training.terminalVelocityLossWeight = 50;
    params.training.holdPositionLossWeight = 100;
    params.training.holdVelocityLossWeight = 50;
    params.training.velocityEffortLossWeight = 1e-3;
    params.training.activityRegularization = 1e-5;
    params.training.weightRegularization = 1e-6;
    params.training.learningRateMultipliers = struct( ...
        'Wtarg', 1, 'Wgo', 1, 'WcbHidden', 1, 'bcbHidden', 1, ...
        'WcbLatent', 1, 'bcbLatent', 1, 'Ucb', 1, 'Wout', 0.001);

    params.analysis.preparatoryWindowMs = 300;
    params.analysis.movementWindowMs = 300;
    params.analysis.varianceThreshold = 0.95;
    params.analysis.smokeNullSamples = 5;

    params.smoke.delaysMs = [500 600 700];
    params.smoke.optimizerLearnRate = 1e-3;
    params.smoke.numericTolerance = 1e-6;
    params.smoke.useGpuForGradients = true;

    params.files.referenceMatrix = fullfile('config', ...
        'why_prep_2_w_rec.txt');
    params.files.resultRoot = fullfile('results', 'v3_hybrid');
    params.files.figureRoot = fullfile('plots', 'v3_hybrid');
    params.files.smokeCheckpoint = fullfile(params.files.resultRoot, ...
        'smoke', 'v3_smoke_checkpoint.mat');
end
