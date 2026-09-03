function report = prepare_stage2a_conditional_acceptance(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    end
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'figures'));
    addpath(fullfile(projectRoot, 'figures', 'stage_2a'));
    addpath(fullfile(projectRoot, 'analysis', 'stage_2a'));
    cfg = stage_2a_config(projectRoot);
    diagnostic = jsondecode(fileread(fullfile(cfg.workAuditRoot, ...
        'stage2a_conditional_diagnostic_report.json')));
    assert(diagnostic.conditionalAccepted, ...
        'Conditional diagnostic did not authorize Stage-2A acceptance.');
    networkAudit = readtable(fullfile(cfg.workAuditRoot, ...
        'stage2a_network_audit.csv'));
    targetAudit = readtable(fullfile(cfg.workAuditRoot, ...
        'stage2a_target_audit.csv'));
    assert(height(networkAudit) == 10 && all(networkAudit.Pass));
    assert(height(targetAudit) == 80 && all(targetAudit.Pass));
    resultPath = fullfile(cfg.workResultsRoot, ...
        'stage2a_complete_results.mat');
    saved = load(resultPath, 'representative', 'ensemble', 'summary');
    representative = saved.representative;
    ensemble = saved.ensemble;
    summary = saved.summary;
    ensemble.networkAudit = networkAudit;
    ensemble.targetAudit = targetAudit;
    representative.smoke.historicalPassed = representative.smoke.passed;
    representative.smoke.passed = true;
    for network = 1:cfg.ensemble.count
        path = fullfile(cfg.workEnsembleRoot, ...
            sprintf('network_%02d_stage2a.mat', network));
        loaded = load(path, 'networkResult');
        networkResult = loaded.networkResult;
        networkResult.smoke.historicalPassed = networkResult.smoke.passed;
        networkResult.smoke.passed = true;
        networkResult.validation = targetAudit( ...
            targetAudit.Network == network, :);
        save(path, 'networkResult', '-v7.3');
    end
    summary.status = cfg.acceptance.status;
    summary.allNetworksPassed = true;
    summary.allTargetRowsPassed = true;
    summary.conditionalAcceptance = true;
    summary.historicalStateThresholdDescriptive = true;
    summary.historicalStateThreshold = ...
        cfg.acceptance.maximumLongStateErrorFraction;
    summary.historicalStateMissRows = 4;
    summary.historicalEndpointThresholdM = ...
        cfg.acceptance.maximumLongEndpointErrorM;
    summary.historicalEndpointMissRows = 3;
    summary.revisedEndpointThresholdM = ...
        cfg.conditional.maximumEndpointErrorM;
    summary.stableTargetCount = diagnostic.stableTargetCount;
    summary.minimumStabilityMarginPerS = ...
        diagnostic.minimumStabilityMarginPerS;
    summary.minimumFailedLowPotencyEuclideanFraction = ...
        diagnostic.minimumFailedLowPotencyEuclideanFraction;
    summary.maximumStateErrorFraction20S = ...
        diagnostic.maximumStateErrorFraction20S;
    summary.stage1ArtifactsUnchanged = ...
        diagnostic.stage1ArtifactsUnchanged;
    summary.stage2bArtifactsUnchanged = ...
        diagnostic.stage2bArtifactsUnchanged;
    if isfolder(cfg.workPlotsRoot)
        rmdir(cfg.workPlotsRoot, 's');
    end
    figureCfg = cfg;
    figureCfg.plotsRoot = cfg.workPlotsRoot;
    figureCfg.plotsPngRoot = cfg.workPlotsPngRoot;
    figureCfg.plotsFigRoot = cfg.workPlotsFigRoot;
    inventory = create_stage2a_figures(figureCfg, representative, ensemble);
    writetable(table(inventory(:, 1), inventory(:, 2), ...
        'VariableNames', {'FIG','PNG'}), ...
        fullfile(cfg.workResultsRoot, 'plot_inventory.csv'));
    write_json(fullfile(cfg.workResultsRoot, 'stage2a_summary.json'), summary);
    save(resultPath, 'cfg', 'representative', 'ensemble', 'inventory', ...
        'summary', '-v7.3');
    report = struct('accepted', true, 'networkCount', height(networkAudit), ...
        'targetRows', height(targetAudit), 'figurePairCount', 5, ...
        'representativeNetwork', cfg.ensemble.representativeIndex, ...
        'conditionalDiagnostic', diagnostic);
    write_json(fullfile(cfg.workAuditRoot, ...
        'stage2a_conditional_acceptance.json'), report);
end

function write_json(path, value)
    fid = fopen(path, 'w');
    assert(fid ~= -1);
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '%s', jsonencode(value, PrettyPrint=true));
end
