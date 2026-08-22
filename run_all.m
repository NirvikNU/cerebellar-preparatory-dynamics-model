clearvars;
close all;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'config'));
addpath(fullfile(projectRoot, 'src'));
addpath(fullfile(projectRoot, 'analysis'));
addpath(fullfile(projectRoot, 'figures'));
run_v2_workflow(projectRoot);
