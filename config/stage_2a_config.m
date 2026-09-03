function cfg = stage_2a_config(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end
    stage1 = published_generator_config(projectRoot);
    cfg.projectRoot = projectRoot;
    cfg.stage1 = stage1;
    cfg.resultsRoot = fullfile(projectRoot, 'results', 'stage_2a');
    cfg.plotsRoot = fullfile(projectRoot, 'plots', 'stage_2a');
    cfg.plotsPngRoot = fullfile(cfg.plotsRoot, 'png');
    cfg.plotsFigRoot = fullfile(cfg.plotsRoot, 'fig');
    cfg.workRoot = fullfile(projectRoot, 'results', 'stage_2a_gate2_work');
    cfg.workResultsRoot = fullfile(cfg.workRoot, 'current');
    cfg.workAuditRoot = fullfile(cfg.workRoot, 'audit');
    cfg.workEnsembleRoot = fullfile(cfg.workResultsRoot, 'ensemble');
    cfg.workPlotsRoot = fullfile(projectRoot, 'plots', 'stage_2a_gate2_work');
    cfg.workPlotsPngRoot = fullfile(cfg.workPlotsRoot, 'png');
    cfg.workPlotsFigRoot = fullfile(cfg.workPlotsRoot, 'fig');
    cfg.ensemble.stage1Root = fullfile(projectRoot, 'results', 'stage_1', ...
        'current', 'ensemble');
    cfg.ensemble.count = 10;
    cfg.ensemble.representativeIndex = 1;
    cfg.ensemble.bootstrapSamples = 10000;
    cfg.ensemble.bootstrapSeed = 2026083120;
    cfg.ensemble.bootstrapMethod = [ ...
        'Nonparametric network bootstrap: resample the 10 accepted networks ' ...
        'with replacement, compute the median across resampled networks, ' ...
        'and report the standard deviation across bootstrap medians.'];
    cfg.preparation.maximumDurationS = 5.0;
    cfg.preparation.metricDurationsS = (0:0.10:5.0).';
    cfg.preparation.representativeDurationsS = [0, 0.25, 0.50, 1.0, 2.0, 5.0].';
    cfg.preparation.errorReductionFractions = [0.50, 0.80, 0.90, 0.95];
    cfg.acceptance.fixedPointResidualTolerance = 1e-12;
    cfg.acceptance.goContinuityTolerance = 1e-12;
    cfg.acceptance.maximumLongStateErrorFraction = 1e-2;
    cfg.acceptance.maximumLongProspectiveErrorFraction = 1e-4;
    cfg.acceptance.maximumLongEndpointErrorM = 1e-3;
    cfg.acceptance.maximumLongHandNrmse = 1e-2;
    cfg.acceptance.maximumLongTorqueNrmse = 1e-2;
    cfg.conditional.extendedDurationS = 40.0;
    cfg.conditional.primaryDiagnosticDurationS = 20.0;
    cfg.conditional.tailWindowS = [10.0, 20.0];
    cfg.conditional.maximumNormalizedStateAt20S = 1e-4;
    cfg.conditional.maximumTwentyToFiveStateRatio = 1e-2;
    cfg.conditional.maximumEndpointErrorM = 0.02 * 0.10;
    cfg.conditional.potencyFraction = 0.95;
    cfg.conditional.minimumLowPotencyEuclideanFraction = 0.5;
    cfg.conditional.failedRows = [1, 2; 3, 6; 4, 6; 6, 7];
    cfg.acceptance.requiredNetworkCount = 10;
    cfg.acceptance.requiredTargetRows = 80;
    cfg.acceptance.status = 'STAGE 2A ACCEPTED — NAIVE FEEDFORWARD BASELINE';
    cfg.plot = stage1.plot;
end
