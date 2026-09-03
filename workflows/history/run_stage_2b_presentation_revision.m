clearvars;
close all;
clc;

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'config'));
addpath(fullfile(projectRoot, 'src', 'published_generator'));
addpath(fullfile(projectRoot, 'src', 'stage_2b_kao'));
addpath(fullfile(projectRoot, 'analysis', 'stage_2b_shared'));
addpath(fullfile(projectRoot, 'figures', 'stage_2b_shared'));
cfgKao = stage_2b_kao_config(projectRoot);
cfgCerebellum = stage_2b_cerebellum_config(projectRoot);
frozenFile = fullfile(cfgCerebellum.resultsRoot, ...
    'stage2b_cerebellum_complete_results.mat');
assert(isfile(frozenFile), 'Frozen Stage 2B-Cerebellum result file is missing.');
fprintf('Stage 2B CURRENT AUTHORIZED REVISION: analysis and presentation only.\n');
fprintf('Loading frozen results; no controller will be derived, trained, or tuned.\n');
saved = load(frozenFile, 'model', 'results', 'kao', 'cerebellum');
model = saved.model;
results = saved.results;
assert(isequaln(results.controllers{2}.K, saved.kao.K));
assert(isequaln(results.controllers{3}.K, saved.cerebellum.K));
assert(isequaln(results.controllers{3}.B, saved.cerebellum.B));
assert(results.controllers{2}.lambda == saved.kao.lambda);
assert(results.controllers{3}.lambda == saved.cerebellum.lambda);

resultRoots = {cfgKao.resultsRoot, cfgCerebellum.resultsRoot};
revisionFile = fullfile(cfgCerebellum.resultsRoot, ...
    'stage2b_presentation_revision_results.mat');
if isfile(revisionFile)
    cached = load(revisionFile, 'revision', 'analysisRuntimeSeconds');
    revision = cached.revision;
    analysisRuntimeSeconds = cached.analysisRuntimeSeconds;
    assert(strcmp(revision.version, 'CURRENT AUTHORIZED REVISION 2026-08-30'));
    fprintf('Reusing verified revised-analysis cache after figure-only restart.\n');
else
    startTime = tic;
    revision = run_stage2b_presentation_revision_analysis(model, results);
    analysisRuntimeSeconds = toc(startTime);
end
for rootIndex = 1:numel(resultRoots)
    root = resultRoots{rootIndex};
    writetable(revision.inputSummary, fullfile(root, ...
        'revised_controller_input_dimensionality_summary.csv'));
    writetable(revision.inputSpectrum, fullfile(root, ...
        'revised_controller_input_cumulative_variance.csv'));
    writetable(revision.inputTimeCourse, fullfile(root, ...
        'revised_controller_input_time_course.csv'));
    writetable(revision.alignment, fullfile(root, ...
        'revised_preparatory_dimensionality_and_alignment.csv'));
    writetable(revision.alignmentNull, fullfile(root, ...
        'revised_alignment_null_10000.csv'));
    writetable(revision.alignmentSpectrum, fullfile(root, ...
        'revised_prep_move_cumulative_variance.csv'));
    writetable(revision.rotation, fullfile(root, ...
        'revised_prep_move_rotation.csv'));
    writetable(revision.flow.grid, fullfile(root, ...
        'revised_flow_field_nonlinear_and_linearized.csv'));
    writetable(revision.flow.diagnostics, fullfile(root, ...
        'revised_flow_field_diagnostic_summary.csv'));
    writetable(revision.flow.selection, fullfile(root, ...
        'revised_flow_representative_target_selection.csv'));
    save(fullfile(root, 'stage2b_presentation_revision_results.mat'), ...
        'revision', 'analysisRuntimeSeconds', '-v7.3');
end

inventory = create_stage2b_revised_figures(cfgKao, cfgCerebellum, ...
    model, results, revision);
architectureInventory = create_stage2b_architecture_diagrams(cfgKao, cfgCerebellum);
for rootIndex = 1:numel(resultRoots)
    stageName = string(results.controllers{rootIndex + 1}.name);
    writetable(inventory(inventory.Stage == stageName, :), ...
        fullfile(resultRoots{rootIndex}, 'plot_inventory.csv'));
    writetable(architectureInventory(architectureInventory.Stage == stageName, :), ...
        fullfile(resultRoots{rootIndex}, 'architecture_inventory.csv'));
end

for stage = 1:2
    cfg = {cfgKao, cfgCerebellum}; cfg = cfg{stage};
    pngFiles = dir(fullfile(cfg.plotsPngRoot, '*.png'));
    figFiles = dir(fullfile(cfg.plotsFigRoot, '*.fig'));
    assert(numel(pngFiles) == 10 && numel(figFiles) == 10);
    pngNames = sort(erase(string({pngFiles.name}), '.png'));
    figNames = sort(erase(string({figFiles.name}), '.fig'));
    assert(isequal(pngNames, figNames));
    for index = 1:numel(figFiles)
        handle = openfig(fullfile(figFiles(index).folder, figFiles(index).name), ...
            'invisible');
        assert(isgraphics(handle)); close(handle);
    end
    for index = 1:numel(pngFiles)
        information = imfinfo(fullfile(pngFiles(index).folder, pngFiles(index).name));
        assert(information.Width >= 2000 && information.Height >= 1000);
    end
end

summary = struct('status', 'COMPLETE - AWAITING SCIENTIFIC REVIEW', ...
    'revision', revision.version, 'analysisRuntimeSeconds', analysisRuntimeSeconds, ...
    'controllersFrozen', true, 'training', 'none', 'tuning', 'none', ...
    'temporalSubsamplingS', revision.temporalSubsamplingS, ...
    'preparationWindowFromTargetOnsetS', revision.preparationWindowFromTargetOnsetS, ...
    'modelMovementOnsetOffsetS', revision.modelMovementOnsetOffsetS, ...
    'movementWindowFromMovementOnsetS', revision.movementWindowFromMovementOnsetS, ...
    'movementWindowFromControlRemovalS', revision.movementWindowFromControlRemovalS, ...
    'representativeFlowTarget', revision.flow.target, ...
    'representativeTargetRule', ['minimum standardized Euclidean distance to the ' ...
        'across-target median of the predeclared all-controller metric vector'], ...
    'inputDimensionality', table2struct(revision.inputSummary), ...
    'alignment', table2struct(revision.alignment), ...
    'flowDiagnostic', table2struct(revision.flow.diagnostics));
for rootIndex = 1:numel(resultRoots)
    file = fullfile(resultRoots{rootIndex}, 'stage2b_presentation_revision_summary.json');
    fid = fopen(file, 'w');
    assert(fid >= 0);
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '%s', jsonencode(summary, PrettyPrint=true));
    clear cleanup;
end
fprintf(['REVISION COMPLETE: analysis %.1f s; stage-specific 10-figure sets, ' ...
    'architecture PNG/SVG pairs, and machine-readable outputs verified.\n'], ...
    analysisRuntimeSeconds);
clearvars;
close all;
