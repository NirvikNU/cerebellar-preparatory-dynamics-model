function validation = finalize_stage2b_kao_figure5_freeze(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    end
    cfg = stage_2b_kao_config(projectRoot);
    auditRoot = fullfile(cfg.resultsRoot, 'audit');
    diagnostic = load(fullfile(auditRoot, ...
        'figure5_final_diagnostic.mat'), 'audit');
    assert(~diagnostic.audit.BugFound);

    baselineArtifact = readtable(fullfile(cfg.resultsRoot, ...
        'final_artifact_manifest_sha256.csv'), TextType='string', ...
        VariableNamingRule='preserve');
    baselineCode = readtable(fullfile(cfg.resultsRoot, ...
        'final_code_manifest_sha256.csv'), TextType='string', ...
        VariableNamingRule='preserve');
    basenames = [ ...
        "01_stage2b_controller_derivation_and_fixed_points"; ...
        "02_stage2b_cortical_preparation_go_movement_trajectories"; ...
        "03_stage2b_preparatory_error_dynamics"; ...
        "04_stage2b_reaches_by_preparation_duration"; ...
        "05_stage2b_movement_error_by_preparation_duration"; ...
        "06_stage2b_cortical_and_controller_dimensionality"; ...
        "07_stage2b_local_stability_and_finite_time_control"; ...
        "08_stage2b_prospective_potency_geometry"; ...
        "09_stage2b_prep_move_alignment_and_amplification"];
    figureInventory = table((1:9).', basenames, ...
        "plots/stage_2b_kao/png/" + basenames + ".png", ...
        "plots/stage_2b_kao/fig/" + basenames + ".fig", ...
        'VariableNames', {'Figure','Basename','PNG','FIG'});
    beforeFigureHashes = strings(height(figureInventory), 2);
    for row = 1:height(figureInventory)
        pngRow = baselineArtifact.Path == figureInventory.PNG(row);
        figRow = baselineArtifact.Path == figureInventory.FIG(row);
        assert(sum(pngRow) == 1 && sum(figRow) == 1);
        beforeFigureHashes(row, 1) = baselineArtifact.SHA256(pngRow);
        beforeFigureHashes(row, 2) = baselineArtifact.SHA256(figRow);
    end

    saved = load(fullfile(cfg.resultsRoot, ...
        'stage2b_kao_gate3_complete.mat'), 'complete');
    cfg.workPlotsPngRoot = cfg.plotsPngRoot;
    cfg.workPlotsFigRoot = cfg.plotsFigRoot;
    revised = create_stage2b_kao_gate3_figures(cfg, saved.complete, 5);
    assert(height(revised) == 1 && revised.Figure == 5);
    handle = openfig(revised.FIG, 'invisible');
    cleanup = onCleanup(@() close(handle));
    textObjects = findall(handle, 'Type', 'text');
    stringsInFigure = string(get(textObjects, 'String'));
    assert(any(contains(stringsInFigure, ...
        'Stage 2B-Kao: endpoint error lower at 200 ms in 10/10 networks')));
    assert(any(contains(stringsInFigure, ...
        'Stage 2A: endpoint error lower at 200 ms in 0/10 networks')));
    clear cleanup;

    afterFigureHashes = strings(height(figureInventory), 2);
    for row = 1:height(figureInventory)
        afterFigureHashes(row, 1) = sha256_file(fullfile(projectRoot, ...
            figureInventory.PNG(row)));
        afterFigureHashes(row, 2) = sha256_file(fullfile(projectRoot, ...
            figureInventory.FIG(row)));
    end
    changedFigures = any(beforeFigureHashes ~= afterFigureHashes, 2);
    assert(isequal(find(changedFigures), 5));

    stage1Baseline = readtable(fullfile(auditRoot, 'stage1_after.csv'), ...
        TextType='string', VariableNamingRule='preserve');
    stage2aBaseline = readtable(fullfile(auditRoot, 'stage2a_after.csv'), ...
        TextType='string', VariableNamingRule='preserve');
    cerebellumBaseline = readtable(fullfile(auditRoot, ...
        'stage2b_cerebellum_after.csv'), TextType='string', ...
        VariableNamingRule='preserve');
    assert(verify_manifest(projectRoot, stage1Baseline));
    assert(verify_manifest(projectRoot, stage2aBaseline));
    assert(verify_manifest(projectRoot, cerebellumBaseline));
    writetable(stage1Baseline, fullfile(auditRoot, ...
        'stage1_after_figure5_freeze.csv'));
    writetable(stage2aBaseline, fullfile(auditRoot, ...
        'stage2a_after_figure5_freeze.csv'));
    writetable(cerebellumBaseline, fullfile(auditRoot, ...
        'stage2b_cerebellum_after_figure5_freeze.csv'));

    summaryPath = fullfile(cfg.resultsRoot, 'stage2b_kao_gate3_summary.json');
    summary = jsondecode(fileread(summaryPath));
    summary.status = cfg.status;
    summary.figure5FinalDiagnosticPassed = true;
    summary.figure5BugFound = false;
    summary.stage2aEndpointLowerAt200NetworkCount = 0;
    summary.stage2bKaoEndpointLowerAt200NetworkCount = 10;
    summary.stage2aNonmonotonicityInterpretation = ...
        ['Genuine naive-trajectory property: prospective-Q error and torque ' ...
        'RMS decrease, but signed torque-error impulse and downstream joint/' ...
        'hand endpoint errors increase from 100 to 200 ms.'];
    fileId = fopen(summaryPath, 'w');
    summaryCleanup = onCleanup(@() fclose(fileId));
    fprintf(fileId, '%s\n', jsonencode(summary, 'PrettyPrint', true));
    clear summaryCleanup;

    validation = struct();
    validation.Status = cfg.status;
    validation.DiagnosticPassed = true;
    validation.BugFound = false;
    validation.OnlyFigure5Changed = isequal(find(changedFigures), 5);
    validation.Figure5Reopened = true;
    validation.Stage1FrozenManifestVerified = true;
    validation.Stage2aFrozenManifestVerified = true;
    validation.Stage2bCerebellumManifestVerified = true;
    validation.CanonicalFigureCount = height(figureInventory);
    validation.Figure10Present = isfile(fullfile(cfg.plotsPngRoot, ...
        '10_stage2b_movement_amplification_and_prep_move_rotation.png')) || ...
        isfile(fullfile(cfg.plotsFigRoot, ...
        '10_stage2b_movement_amplification_and_prep_move_rotation.fig'));
    assert(validation.CanonicalFigureCount == 9);
    assert(~validation.Figure10Present);

    validationPath = fullfile(auditRoot, ...
        'figure5_final_freeze_validation.json');
    fileId = fopen(validationPath, 'w');
    validationCleanup = onCleanup(@() fclose(fileId));
    fprintf(fileId, '%s\n', jsonencode(validation, 'PrettyPrint', true));
    clear validationCleanup;

    artifactPaths = baselineArtifact.Path;
    addedArtifacts = [ ...
        "results/stage_2b_kao/audit/figure5_final_100_vs_200_network_audit.csv"; ...
        "results/stage_2b_kao/audit/figure5_final_trace_diagnostic.csv"; ...
        "results/stage_2b_kao/audit/figure5_final_diagnostic.mat"; ...
        "results/stage_2b_kao/audit/figure5_final_diagnostic.json"; ...
        "results/stage_2b_kao/audit/figure5_final_freeze_validation.json"; ...
        "results/stage_2b_kao/audit/stage1_after_figure5_freeze.csv"; ...
        "results/stage_2b_kao/audit/stage2a_after_figure5_freeze.csv"; ...
        "results/stage_2b_kao/audit/stage2b_cerebellum_after_figure5_freeze.csv"];
    artifactPaths = unique([artifactPaths; addedArtifacts], 'stable');
    artifactManifest = build_manifest(projectRoot, artifactPaths);
    writetable(artifactManifest, fullfile(cfg.resultsRoot, ...
        'final_artifact_manifest_sha256.csv'));

    codePaths = baselineCode.Path;
    addedCode = [ ...
        "analysis/stage_2b_shared/audit_stage2b_kao_figure5_final.m"; ...
        "analysis/stage_2b_shared/finalize_stage2b_kao_figure5_freeze.m"; ...
        "workflows/diagnostics/stage_2b_kao/" + ...
            "run_stage_2b_kao_figure5_final_diagnostic.m"];
    codePaths = unique([codePaths; addedCode], 'stable');
    codeManifest = build_manifest(projectRoot, codePaths);
    writetable(codeManifest, fullfile(cfg.resultsRoot, ...
        'final_code_manifest_sha256.csv'));
    assert(verify_manifest(projectRoot, artifactManifest));
    assert(verify_manifest(projectRoot, codeManifest));
end

function manifest = build_manifest(projectRoot, paths)
    paths = string(paths);
    bytes = zeros(numel(paths), 1);
    sha256 = strings(numel(paths), 1);
    for row = 1:numel(paths)
        path = fullfile(projectRoot, paths(row));
        assert(isfile(path), 'Manifest path is missing: %s', path);
        info = dir(path);
        bytes(row) = info.bytes;
        sha256(row) = sha256_file(path);
    end
    manifest = table(paths, bytes, sha256, ...
        'VariableNames', {'Path','Bytes','SHA256'});
end

function matched = verify_manifest(projectRoot, manifest)
    matched = true;
    if ismember('SHA256', manifest.Properties.VariableNames)
        expected = manifest.SHA256;
    else
        expected = manifest.Sha256;
    end
    for row = 1:height(manifest)
        path = fullfile(projectRoot, manifest.Path(row));
        if ~isfile(path) || sha256_file(path) ~= expected(row)
            matched = false;
            return;
        end
    end
end
