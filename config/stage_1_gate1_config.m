function cfg = stage_1_gate1_config(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end
    cfg = published_generator_config(projectRoot);
    cfg.gate1.resultsRoot = fullfile(cfg.resultsRoot, 'current');
    cfg.gate1.ensembleRoot = fullfile(cfg.gate1.resultsRoot, 'ensemble');
    cfg.gate1.targetRoot = fullfile(cfg.gate1.resultsRoot, 'targets');
    cfg.gate1.auditRoot = fullfile(cfg.gate1.resultsRoot, 'audit');
    cfg.gate1.historyRoot = fullfile(cfg.resultsRoot, 'audit_history');
    cfg.gate1.targetAnglesDeg = [-90, -45, 0, 45, 90, 135, 180, 225];
    cfg.gate1.targetLabels = "T" + string(1:8);
    cfg.gate1.radiusM = 0.10;
    cfg.gate1.targetDurationS = 0.6;
    cfg.gate1.targetDtS = 1e-3;
    cfg.gate1.targetTorqueSeed = 20260831;
    cfg.gate1.rejectionSampling.recurrentSeedStart = 2026083110;
    cfg.gate1.rejectionSampling.calibrationSeedStart = 2026084110;
    cfg.gate1.rejectionSampling.acceptedCount = 10;
    cfg.gate1.rejectionSampling.maximumAttempts = 100;
    cfg.gate1.rejectionSampling.workRoot = fullfile(cfg.resultsRoot, ...
        'rejection_sampling_work');
    cfg.gate1.rejectionSampling.attemptRoot = fullfile( ...
        cfg.gate1.rejectionSampling.workRoot, 'attempts');
    cfg.gate1.rejectionSampling.acceptedRoot = fullfile( ...
        cfg.gate1.rejectionSampling.workRoot, 'accepted');
    cfg.gate1.rejectionSampling.auditRoot = fullfile( ...
        cfg.gate1.rejectionSampling.workRoot, 'audit');
    cfg.gate1.networkCount = 10;
    cfg.gate1.n = 200;
    cfg.gate1.nE = 160;
    cfg.gate1.nI = 40;
    cfg.gate1.connectionProbability = 0.2;
    cfg.gate1.initialSpectralRadius = 1.2;
    cfg.gate1.socLearningRate = 1.0;
    cfg.gate1.socStopSpectralAbscissa = 0.81;
    cfg.gate1.dcEigenvalue = -10;
    cfg.gate1.spontaneousMean = 1;
    cfg.gate1.spontaneousStd = 0.15;
    cfg.gate1.xstarStd = 0.2;
    cfg.gate1.readoutRegularization = 1 / (cfg.gate1.nE * 2);
    cfg.gate1.trajectoryWeight = 1 / 8;
    cfg.gate1.weightedTorqueScale = [1; 3];
    cfg.gate1.maxCalibrationIterations = 500000;
    cfg.gate1.calibrationMoveCostStop = 5e-4;
    cfg.gate1.calibrationRelativeChangeStop = 1e-4;
    cfg.gate1.targetTorqueMaxIterations = 2500;
    cfg.gate1.targetTorqueGradientTolerance = 1e-7;
    cfg.gate1.targetTorqueRelativeChangeTolerance = 1e-8;
    cfg.gate1.lbfgsHistorySize = 10;
    cfg.gate1.maxLineSearchIterations = 20;
    cfg.gate1.useGpu = true;
    cfg.gate1.validation.gradientRelativeTolerance = 5e-4;
    cfg.gate1.validation.maxAngleErrorDeg = 2.0;
    cfg.gate1.validation.maxRadiusErrorM = 0.01;
    cfg.gate1.validation.maxWeightedTorqueCost = 2e-3;
    cfg.gate1.validation.maxEndpointErrorM = 0.02;
    cfg.gate1.validation.targetRadiusToleranceM = 2e-4;
    cfg.gate1.sourceCommit = cfg.upstreamCommit;
    cfg.gate1.status = 'ACCEPTED - FROZEN / STAGE 1 ONLY';
end
