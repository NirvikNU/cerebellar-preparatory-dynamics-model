clearvars;
close all;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'analysis', 'published_generator'));
fprintf('Stage 1: bounded validation of ten frozen members and 80 movements.\n');
report = revalidate_stage1_accepted_ensemble(projectRoot);
disp(jsonencode(report, PrettyPrint=true));
fprintf('No calibration, training, canonical overwrite or figure regeneration.\n');
