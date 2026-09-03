function validation = finalize_stage2b_kao_presentation_revision(projectRoot, ...
        figureIndices)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    end
    cfg = stage_2b_kao_config(projectRoot);
    affectedFigures = [5; 6; 7; 9];
    if nargin < 2 || isempty(figureIndices)
        figureIndices = affectedFigures;
    end
    figureIndices = figureIndices(:);
    assert(all(ismember(figureIndices, affectedFigures)));
    auditRoot = fullfile(cfg.resultsRoot, 'audit');
    baselineArtifact = readtable(fullfile(cfg.resultsRoot, ...
        'final_artifact_manifest_sha256.csv'), TextType='string', ...
        VariableNamingRule='preserve');
    baselineCode = readtable(fullfile(cfg.resultsRoot, ...
        'final_code_manifest_sha256.csv'), TextType='string', ...
        VariableNamingRule='preserve');
    stage1Baseline = readtable(fullfile(auditRoot, ...
        'stage1_after_figure5_freeze.csv'), TextType='string', ...
        VariableNamingRule='preserve');
    stage2aBaseline = readtable(fullfile(auditRoot, ...
        'stage2a_after_figure5_freeze.csv'), TextType='string', ...
        VariableNamingRule='preserve');
    cerebellumBaseline = readtable(fullfile(auditRoot, ...
        'stage2b_cerebellum_after_figure5_freeze.csv'), TextType='string', ...
        VariableNamingRule='preserve');
    assert(verify_manifest(projectRoot, stage1Baseline));
    assert(verify_manifest(projectRoot, stage2aBaseline));
    assert(verify_manifest(projectRoot, cerebellumBaseline));

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
    beforeHashes = manifest_figure_hashes(baselineArtifact, figureInventory);
    completePath = fullfile(cfg.resultsRoot, 'stage2b_kao_gate3_complete.mat');
    completeHashBefore = sha256_file(completePath);

    saved = load(completePath, 'complete');
    cfg.workPlotsPngRoot = cfg.plotsPngRoot;
    cfg.workPlotsFigRoot = cfg.plotsFigRoot;
    revised = create_stage2b_kao_gate3_figures(cfg, saved.complete, ...
        figureIndices);
    assert(isequal(revised.Figure, figureIndices));
    requiredBarCounts = [0; 0; 0; 0; 4; 7; 7; 0; 2];
    for row = 1:height(revised)
        handle = openfig(revised.FIG(row), 'invisible');
        cleanup = onCleanup(@() close(handle));
        assert(numel(findall(handle, 'Type', 'bar')) >= ...
            requiredBarCounts(revised.Figure(row)));
        if revised.Figure(row) == 9
            titles = string(get(findall(handle, 'Type', 'text'), 'String'));
            assert(any(contains(titles, ...
                'Independent 10,000-draw null per network')));
        end
        clear cleanup;
    end

    afterHashes = current_figure_hashes(projectRoot, figureInventory);
    changed = any(beforeHashes ~= afterHashes, 2);
    assert(isequal(find(changed), figureIndices));
    assert(sha256_file(completePath) == completeHashBefore);
    verify_canonical_plot_tree(cfg, basenames);
    assert(verify_manifest(projectRoot, stage1Baseline));
    assert(verify_manifest(projectRoot, stage2aBaseline));
    assert(verify_manifest(projectRoot, cerebellumBaseline));

    panelAudit = table( ...
        [5; 6; 6; 6; 6; 6; 7; 7; 7; 7; 9], ...
        ["F"; "A"; "B"; "D"; "E"; "F"; "A"; "B"; "C"; "F"; "D"], ...
        ["Endpoint error at 100/200 ms"; "Feedback-input k95"; ...
        "Feedback-input participation ratio"; "Preparation cortical PR"; ...
        "Movement cortical PR"; "Integrated feedback effort"; ...
        "Spectral abscissa"; "Worst instantaneous Q rate"; ...
        "Worst instantaneous Euclidean rate"; "Q95 dimension"; ...
        "Observed/null alignment ensemble summary"], ...
        repmat("Bar + median +/- bootstrap SE + network values", 11, 1), ...
        'VariableNames', {'Figure','Panel','Quantity','RevisedDisplay'});
    writetable(panelAudit, fullfile(auditRoot, ...
        'presentation_revision_scalar_bar_panel_audit.csv'));

    validation = struct();
    validation.Status = cfg.status;
    validation.Scope = 'PRESENTATION ONLY';
    validation.AffectedFigures = affectedFigures.';
    validation.RegeneratedFigures = figureIndices.';
    validation.ChangedFiguresMatchAuthorization = true;
    validation.SciencePayloadHashUnchanged = true;
    validation.Stage1FrozenManifestVerified = true;
    validation.Stage2aFrozenManifestVerified = true;
    validation.Stage2bCerebellumManifestVerified = true;
    validation.CanonicalPngCount = 9;
    validation.CanonicalFigCount = 9;
    validation.Figure10Present = false;
    validation.SupersededCanonicalPlotArtifactsPresent = false;
    validationPath = fullfile(auditRoot, ...
        'presentation_revision_validation.json');
    write_json(validationPath, validation);

    artifactPaths = unique([baselineArtifact.Path; ...
        "results/stage_2b_kao/audit/presentation_revision_scalar_bar_panel_audit.csv"; ...
        "results/stage_2b_kao/audit/presentation_revision_validation.json"], ...
        'stable');
    artifactManifest = build_manifest(projectRoot, artifactPaths);
    writetable(artifactManifest, fullfile(cfg.resultsRoot, ...
        'final_artifact_manifest_sha256.csv'));
    codePaths = unique([baselineCode.Path; ...
        "analysis/stage_2b_shared/finalize_stage2b_kao_presentation_revision.m"; ...
        "workflows/diagnostics/stage_2b_kao/" + ...
            "run_stage_2b_kao_presentation_revision.m"], 'stable');
    codeManifest = build_manifest(projectRoot, codePaths);
    writetable(codeManifest, fullfile(cfg.resultsRoot, ...
        'final_code_manifest_sha256.csv'));
    assert(verify_manifest(projectRoot, artifactManifest));
    assert(verify_manifest(projectRoot, codeManifest));
    validation.ArtifactManifestEntries = height(artifactManifest);
    validation.CodeManifestEntries = height(codeManifest);
    write_json(validationPath, validation);
    artifactManifest = build_manifest(projectRoot, artifactPaths);
    writetable(artifactManifest, fullfile(cfg.resultsRoot, ...
        'final_artifact_manifest_sha256.csv'));
    assert(verify_manifest(projectRoot, artifactManifest));
end

function hashes = manifest_figure_hashes(manifest, inventory)
    hashes = strings(height(inventory), 2);
    for row = 1:height(inventory)
        pngRow = manifest.Path == inventory.PNG(row);
        figRow = manifest.Path == inventory.FIG(row);
        assert(sum(pngRow) == 1 && sum(figRow) == 1);
        hashes(row, :) = [manifest.SHA256(pngRow), manifest.SHA256(figRow)];
    end
end

function hashes = current_figure_hashes(projectRoot, inventory)
    hashes = strings(height(inventory), 2);
    for row = 1:height(inventory)
        hashes(row, :) = [sha256_file(fullfile(projectRoot, inventory.PNG(row))), ...
            sha256_file(fullfile(projectRoot, inventory.FIG(row)))];
    end
end

function verify_canonical_plot_tree(cfg, basenames)
    png = dir(fullfile(cfg.plotsPngRoot, '*.png'));
    fig = dir(fullfile(cfg.plotsFigRoot, '*.fig'));
    assert(numel(png) == 9 && numel(fig) == 9);
    assert(isequal(sort(erase(string({png.name}), '.png')).', sort(basenames)));
    assert(isequal(sort(erase(string({fig.name}), '.fig')).', sort(basenames)));
    assert(~isfolder(fullfile(cfg.projectRoot, 'plots', ...
        'stage_2b_kao_gate3_work')));
    for index = 1:numel(png)
        information = imfinfo(fullfile(png(index).folder, png(index).name));
        assert(information.Width >= 2000 && information.Height >= 1000);
    end
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

function write_json(path, value)
    fileId = fopen(path, 'w');
    assert(fileId >= 0);
    cleanup = onCleanup(@() fclose(fileId));
    fprintf(fileId, '%s\n', jsonencode(value, 'PrettyPrint', true));
end
