clear;
close all;
clc;

rootDirectory = fileparts(mfilename('fullpath'));
addpath(fullfile(rootDirectory, 'config'));
addpath(fullfile(rootDirectory, 'src', 'published_generator'));
addpath(fullfile(rootDirectory, 'src', 'stage_2a'));
addpath(fullfile(rootDirectory, 'src', 'stage_2b_kao'));
addpath(fullfile(rootDirectory, 'analysis', 'published_generator'));
addpath(fullfile(rootDirectory, 'analysis', 'stage_2a'));
addpath(fullfile(rootDirectory, 'analysis', 'stage_2b_shared'));
addpath(fullfile(rootDirectory, 'figures'));
addpath(fullfile(rootDirectory, 'figures', 'published_generator'));
addpath(fullfile(rootDirectory, 'figures', 'stage_2b_shared'));

cfg = stage_2b_kao_config(rootDirectory);
require_kao_reference(cfg.stage1);
requiredDirectories = {cfg.workRoot, cfg.workResultsRoot, cfg.workAuditRoot, ...
    cfg.workEnsembleRoot, cfg.workPlotsRoot, cfg.workPlotsPngRoot, ...
    cfg.workPlotsFigRoot};
for directoryIndex = 1:numel(requiredDirectories)
    if ~exist(requiredDirectories{directoryIndex}, 'dir')
        mkdir(requiredDirectories{directoryIndex});
    end
end

fprintf('Stage 2B-Kao Gate 3: validating components on network 1...\n');
componentAudit = validate_stage2b_kao_gate3_components(cfg);
save(fullfile(cfg.workAuditRoot, 'component_validation.mat'), 'componentAudit', '-v7.3');
componentJson = jsonencode(componentAudit, 'PrettyPrint', true);
componentFileId = fopen(fullfile(cfg.workAuditRoot, 'component_validation.json'), 'w');
componentCleanup = onCleanup(@() fclose(componentFileId));
fprintf(componentFileId, '%s\n', componentJson);
clear componentCleanup;
fprintf('Component validation PASS. Running the 10-network Gate-3 analysis once...\n');

complete = run_stage2b_kao_gate3_ensemble(cfg);
save(fullfile(cfg.workResultsRoot, 'stage2b_kao_gate3_assembled.mat'), ...
    'complete', '-v7.3');
figureInventory = create_stage2b_kao_gate3_figures(cfg, complete);
output = write_stage2b_kao_gate3_outputs(complete, cfg);
completeAudit = validate_stage2b_kao_gate3_complete(complete, ...
    figureInventory, cfg);
save(fullfile(cfg.workAuditRoot, 'complete_validation.mat'), 'completeAudit', '-v7.3');
completeJson = jsonencode(completeAudit, 'PrettyPrint', true);
completeFileId = fopen(fullfile(cfg.workAuditRoot, 'complete_validation.json'), 'w');
completeCleanup = onCleanup(@() fclose(completeFileId));
fprintf(completeFileId, '%s\n', completeJson);
clear completeCleanup;

fprintf('Stage 2B-Kao Gate 3 complete in isolated work folders.\n');
fprintf('Networks: %d | target checks: %d | figures: %d PNG/FIG pairs\n', ...
    completeAudit.NetworkCount, completeAudit.TargetValidationCount, ...
    completeAudit.FigureCount);
fprintf('Machine-readable output: %s\n', output.Directory);
