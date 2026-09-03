clearvars;
close all;
clc;

projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(projectRoot, 'analysis', 'stage_2a'));
report = run_stage2a_conditional_diagnostic(projectRoot);
disp(report);
assert(report.conditionalAccepted, ...
    ['Gate-2 conditional acceptance failed. Canonical Stage-2A cleanup ' ...
    'and figure generation are not authorized.']);
