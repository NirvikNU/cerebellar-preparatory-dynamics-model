clearvars;
close all;
clc;

projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(projectRoot, 'config'));
addpath(fullfile(projectRoot, 'analysis', 'published_generator'));
addpath(fullfile(projectRoot, 'analysis', 'stage_2a'));
addpath(fullfile(projectRoot, 'figures'));
addpath(fullfile(projectRoot, 'figures', 'stage_2a'));
fprintf('Stage 2A figure-uncertainty revision from accepted saved outputs only.\n');
fprintf('No model simulation, training, retuning, QC change, or Stage 2B execution.\n');
report = revise_stage2a_figure_uncertainty(projectRoot);
disp(report);
