clearvars;
close all;
clc;

projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(projectRoot, 'analysis', 'published_generator'));
report = revalidate_stage1_accepted_ensemble(projectRoot);
disp(jsonencode(report, PrettyPrint=true));
fprintf('Bounded Stage-1 validation only; canonical results remain unchanged.\n');
