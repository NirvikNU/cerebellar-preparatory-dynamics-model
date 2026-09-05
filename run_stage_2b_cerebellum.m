clear; close all; clc;

rootDirectory = fileparts(mfilename('fullpath'));
addpath(fullfile(rootDirectory, 'config'));
addpath(fullfile(rootDirectory, 'src', 'published_generator'));
addpath(fullfile(rootDirectory, 'src', 'stage_2a'));
addpath(fullfile(rootDirectory, 'src', 'stage_2b_kao'));
addpath(fullfile(rootDirectory, 'src', 'stage_2b_cerebellum'));
addpath(fullfile(rootDirectory, 'analysis', 'published_generator'));
addpath(fullfile(rootDirectory, 'analysis', 'stage_2a'));
addpath(fullfile(rootDirectory, 'analysis', 'stage_2b_shared'));
addpath(fullfile(rootDirectory, 'figures', 'stage_2b_shared'));

cfg = stage_2b_cerebellum_config(rootDirectory);
fprintf(['Gate 4B-C: auditing the interrupted Stage 2B-Cerebellum run from ' ...
    'saved Gate-4A/4B outputs.\n']);
audit = audit_stage2b_cerebellum_gate4b(cfg);
figureAudit = create_stage2b_cerebellum_gate4b_figures(cfg, audit);
save(fullfile(cfg.currentResultsRoot, 'stage2b_cerebellum_gate4b_complete.mat'), ...
    'audit', 'figureAudit', '-v7.3');

fprintf('\nGate 4B-C acceptance: %s\n', audit.acceptance.Status);
fprintf('Controllers: %d/%d structural passes; targets: %d/%d passes.\n', ...
    sum(audit.controllerValidation.AllStructuralChecksPass), ...
    height(audit.controllerValidation), ...
    sum(audit.targetValidation.AllTargetChecksPass), ...
    height(audit.targetValidation));
fprintf('Figures: %d PNG/FIG pairs created and reopened.\n', ...
    sum(figureAudit.FigReopenPass));
