function cfg = stage_2b_kao_config(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end
    cfg.projectRoot = projectRoot;
    cfg.stage1 = published_generator_config(projectRoot);
    cfg.stage2a = stage_2a_config(projectRoot);
    cfg.resultsRoot = fullfile(projectRoot, 'results', 'stage_2b_kao');
    cfg.plotsRoot = fullfile(projectRoot, 'plots', 'stage_2b_kao');
    cfg.plotsPngRoot = fullfile(cfg.plotsRoot, 'png');
    cfg.plotsFigRoot = fullfile(cfg.plotsRoot, 'fig');
    cfg.workRoot = fullfile(projectRoot, 'results', ...
        'stage_2b_kao_gate3_work');
    cfg.workResultsRoot = fullfile(cfg.workRoot, 'current');
    cfg.workAuditRoot = fullfile(cfg.workRoot, 'audit');
    cfg.workEnsembleRoot = fullfile(cfg.workResultsRoot, 'ensemble');
    cfg.workPlotsRoot = fullfile(projectRoot, 'plots', ...
        'stage_2b_kao_gate3_work');
    cfg.workPlotsPngRoot = fullfile(cfg.workPlotsRoot, 'png');
    cfg.workPlotsFigRoot = fullfile(cfg.workPlotsRoot, 'fig');
    cfg.sourceRoot = fullfile(projectRoot, 'third_party', ...
        'kao_optimal_preparation', 'local_cache', ...
        'kao_optimal_preparation');
    cfg.upstreamCommit = '40077d2da16e68ab2ab2cff59ec692b97315980b';
    cfg.controller.lambda = 0.1;
    cfg.controller.stateDimension = 200;
    cfg.controller.inputDimension = 200;
    cfg.controller.qTrace = 200;
    cfg.ensemble.stage1Root = fullfile(projectRoot, 'results', 'stage_1', ...
        'current', 'ensemble');
    cfg.ensemble.stage2aRoot = fullfile(projectRoot, 'results', 'stage_2a', ...
        'current', 'ensemble');
    cfg.ensemble.count = 10;
    cfg.ensemble.representativeIndex = 1;
    cfg.ensemble.bootstrapSamples = 10000;
    cfg.ensemble.bootstrapSeed = 2026090101;
    cfg.preparation.maximumDurationS = 0.500;
    cfg.preparation.metricDurationsS = [0; 0.025; 0.050; 0.100; ...
        0.200; 0.300; 0.500; 0.600; 1.0; 2.0; 5.0];
    cfg.validation.careResidualTolerance = 1e-10;
    cfg.validation.fixedPointTolerance = 1e-11;
    cfg.validation.jacobianRelativeTolerance = 5e-5;
    cfg.validation.qTraceTolerance = 1e-10;
    cfg.validation.sourceBenchmarkProspectiveFraction50ms = 0.10;
    cfg.validation.sourceBenchmarkEndpointError200msM = 0.05;
    cfg.validation.jacobianDirectionalTolerance = 5e-5;
    cfg.validation.savedGainTolerance = 0;
    cfg.analysis.densePreparationDurationsS = (0:0.010:0.500).';
    cfg.analysis.representativeDurationsS = ...
        [0; 0.050; 0.100; 0.200; 0.300; 0.500];
    cfg.analysis.markedDurationsS = ...
        [0.050; 0.100; 0.200; 0.300; 0.500];
    cfg.analysis.errorThresholds = [0.1; 0.01; 1e-4];
    cfg.analysis.temporalSubsamplingS = 0.010;
    cfg.analysis.preparationTimesS = (0.150:0.010:0.440).';
    cfg.analysis.movementOnsetAfterControlRemovalS = 0.100;
    cfg.analysis.movementTimesFromOnsetS = (-0.050:0.010:0.240).';
    cfg.analysis.randomSubspaceDraws = 10000;
    cfg.analysis.projectVarianceThreshold = 0.95;
    cfg.analysis.sourceVarianceThreshold = 0.80;
    cfg.analysis.nullSeedBase = 2026090200;
    cfg.analysis.sourceNullSeedBase = 2026090300;
    cfg.analysis.finiteTimesS = [0.050; 0.100; 0.200; 0.300];
    cfg.analysis.cloudSeed = 2026090401;
    cfg.analysis.cloudDirectionsPerTarget = 16;
    cfg.analysis.cloudPerturbationNorm = 0.050;
    cfg.analysis.cloudDurationS = 0.300;
    cfg.analysis.flowGridExtent = 0.25;
    cfg.analysis.flowGridPoints = 17;
    cfg.analysis.flowTrajectoryRadius = 0.15;
    cfg.analysis.flowTrajectoryCount = 8;
    cfg.analysis.amplificationDurationS = 0.600;
    cfg.plot = cfg.stage1.plot;
    cfg.plot.fontSize = 12;
    cfg.plot.axisLineWidth = 0.3;
    cfg.status = ['STAGE 2B-KAO ACCEPTED — FROZEN — UNRESTRICTED KAO-LQR ' ...
        'PREPARATORY CONTROLLER'];
end
