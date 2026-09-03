clear;
close all;
clc;

projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(projectRoot, 'config'));
addpath(fullfile(projectRoot, 'src', 'published_generator'));
addpath(fullfile(projectRoot, 'src', 'stage_2a'));
addpath(fullfile(projectRoot, 'src', 'stage_2b_kao'));
addpath(fullfile(projectRoot, 'analysis', 'published_generator'));
addpath(fullfile(projectRoot, 'analysis', 'stage_2a'));
addpath(fullfile(projectRoot, 'analysis', 'stage_2b_shared'));
addpath(fullfile(projectRoot, 'figures'));
addpath(fullfile(projectRoot, 'figures', 'stage_2b_shared'));

files = [ ...
    "figures/stage_2b_shared/create_stage2b_kao_gate3_figures.m"; ...
    "analysis/stage_2b_shared/finalize_stage2b_kao_presentation_revision.m"; ...
    "workflows/diagnostics/stage_2b_kao/" + ...
        "run_stage_2b_kao_presentation_revision.m"];
for file = files.'
    issues = checkcode(fullfile(projectRoot, file), '-id');
    if ~isempty(issues)
        for issue = 1:numel(issues)
            fprintf('%s:%d %s\n', issues(issue).id, issues(issue).line, ...
                issues(issue).message);
        end
        error('Code Analyzer issues in %s.', file);
    end
end

validation = finalize_stage2b_kao_presentation_revision(projectRoot);
fprintf('Status: %s\n', validation.Status);
fprintf('Presentation-only figures changed: %s\n', ...
    mat2str(validation.AffectedFigures));
fprintf('Canonical PNG/FIG pairs: %d/%d\n', ...
    validation.CanonicalPngCount, validation.CanonicalFigCount);
fprintf('Stage 1 / Stage 2A / Stage 2B-Cerebellum frozen: %d / %d / %d\n', ...
    validation.Stage1FrozenManifestVerified, ...
    validation.Stage2aFrozenManifestVerified, ...
    validation.Stage2bCerebellumManifestVerified);
fprintf('Artifact/code manifest entries: %d/%d\n', ...
    validation.ArtifactManifestEntries, validation.CodeManifestEntries);
