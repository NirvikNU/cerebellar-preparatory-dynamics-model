clear;
projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(genpath(projectRoot));
sourceFile = fullfile(projectRoot, 'results', 'stage_2b_kao', ...
    'diagnostics', 'active_set_gate2', ...
    'gate2_active_set_diagnostics_complete.mat');
assert(isfile(sourceFile), 'Saved Gate-2 diagnostic payload is missing.');
loaded = load(sourceFile, 'results', 'representative', 'diagnostic');
cfg = stage_2b_kao_config(projectRoot);

stage1Target = loaded.results.stage1Target;
frozenTarget = loaded.results.frozenRegimeTarget;
assert(sum(stage1Target.SwitchingFraction > 0) == 8);
assert(sum(frozenTarget.EndpointErrorM > 0) == 8);
assert(sum(loaded.results.stage1Overlap.UnionSetJaccard == 1) == 280);
assert(all(loaded.results.validation.Passed));

figureSource = struct();
figureSource.activeOccupancy = squeeze(mean( ...
    loaded.representative.movement.activeRaster, 1));
figureSource.inactiveOccupancy = 1 - figureSource.activeOccupancy;
figureSource.meanRatesRaw = loaded.representative.movement.meanRatesRaw;
figureSource.meanRatesNormalized = ...
    loaded.representative.movement.meanRatesNormalized;
figureSource.neuronOrdering = ...
    loaded.representative.movement.neuronOrdering;
figureSource.switchingFractionPercent = nan(10, 8);
figureSource.frozenEndpointMismatchMm = nan(10, 8);
for row = 1:height(stage1Target)
    network = stage1Target.Network(row);
    target = stage1Target.Target(row);
    figureSource.switchingFractionPercent(network, target) = ...
        100 * stage1Target.SwitchingFraction(row);
end
for row = 1:height(frozenTarget)
    network = frozenTarget.Network(row);
    target = frozenTarget.Target(row);
    figureSource.frozenEndpointMismatchMm(network, target) = ...
        1000 * frozenTarget.EndpointErrorM(row);
end
assert(all(isfinite(figureSource.switchingFractionPercent), 'all'));
assert(all(isfinite(figureSource.frozenEndpointMismatchMm), 'all'));

outputFile = fullfile(loaded.diagnostic.resultsRoot, ...
    'gate2_active_set_figure_refinement.mat');
save(outputFile, 'figureSource', '-v7.3');
figureFiles = create_gate2_active_set_figures(cfg, loaded.diagnostic, ...
    loaded.results, loaded.representative);

figurePaths = {figureFiles.stage1Representative.fig, ...
    figureFiles.stage1Quantitative.fig, ...
    figureFiles.preparationSufficiency.fig};
for index = 1:numel(figurePaths)
    handle = openfig(figurePaths{index}, 'invisible');
    assert(~isempty(findall(handle, 'Type', 'axes')));
    close(handle);
end
codeFiles = {mfilename('fullpath'), fullfile(projectRoot, 'figures', ...
    'stage_2b_shared', 'create_gate2_active_set_figures.m')};
for index = 1:numel(codeFiles)
    messages = checkcode(codeFiles{index}, '-id');
    assert(isempty(messages), ...
        'Code Analyzer reported an issue in %s.', codeFiles{index});
end
fprintf(['GATE 2 FIGURE REFINEMENT PASS: 72/80 exact, 8/80 switching, ' ...
    '280/280 Jaccard values equal 1; three FIG/PNG pairs regenerated.\n']);
