function cfg = stage_2b_cerebellum_config(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end
    cfg.projectRoot = projectRoot;
    cfg.stage1 = published_generator_config(projectRoot);
    cfg.stage2a = stage_2a_config(projectRoot);
    cfg.resultsRoot = fullfile(projectRoot, 'results', 'stage_2b_cerebellum');
    cfg.currentResultsRoot = fullfile(cfg.resultsRoot, 'current');
    cfg.currentAuditRoot = fullfile(cfg.currentResultsRoot, 'audit');
    cfg.currentTablesRoot = fullfile(cfg.currentResultsRoot, 'tables');
    cfg.currentEnsembleRoot = fullfile(cfg.currentResultsRoot, 'ensemble');
    cfg.plotsRoot = fullfile(projectRoot, 'plots', 'stage_2b_cerebellum');
    cfg.plotsPngRoot = fullfile(cfg.plotsRoot, 'png');
    cfg.plotsFigRoot = fullfile(cfg.plotsRoot, 'fig');
    cfg.workRoot = fullfile(projectRoot, 'results', ...
        'stage_2b_cerebellum_gate4a_work');
    cfg.workResultsRoot = fullfile(cfg.workRoot, 'current');
    cfg.workAuditRoot = fullfile(cfg.workRoot, 'audit');
    cfg.workEnsembleRoot = fullfile(cfg.workResultsRoot, 'ensemble');
    cfg.workPlotsRoot = fullfile(projectRoot, 'plots', ...
        'stage_2b_cerebellum_gate4a_work');
    cfg.workPlotsPngRoot = fullfile(cfg.workPlotsRoot, 'png');
    cfg.workPlotsFigRoot = fullfile(cfg.workPlotsRoot, 'fig');

    cfg.controller.lambda = 0.1;
    cfg.controller.stateDimension = 200;
    cfg.controller.inputDimension = 200; % observation is full 200D
    cfg.controller.actuatorDimension = 13; % actuation is 13D
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
    cfg.validation.jacobianDirectionalTolerance = 5e-5;
    cfg.validation.eigenBoundaryScaleFactor = 100;
    cfg.validation.pbhRelativeTolerance = 1e-10;
    cfg.validation.orthonormalTolerance = 1e-10;
    cfg.validation.feedbackZeroTolerance = 1e-14;
    cfg.validation.upstreamEqualityTolerance = 1e-12;

    cfg.analysis.densePreparationDurationsS = (0:0.010:0.500).';
    cfg.analysis.errorThresholds = [0.1; 0.01; 1e-4];
    cfg.analysis.finiteTimesS = [0.050; 0.100; 0.200; 0.300];

    cfg.plot = cfg.stage1.plot;
    cfg.plot.fontSize = 12;
    cfg.plot.axisLineWidth = 0.3;
    cfg.status = ['STAGE 2B-CEREBELLUM ACCEPTED — FROZEN — ' ...
        '13-CHANNEL PROSPECTIVE-POTENCY CONTROLLER'];
end
