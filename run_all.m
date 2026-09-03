clearvars;
close all;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'config'));
addpath(fullfile(projectRoot, 'src', 'published_generator'));
addpath(fullfile(projectRoot, 'analysis', 'published_generator'));
fprintf('Stage 1 smoke-only validation\n');
fprintf('Project: %s\n', projectRoot);
cfg = published_generator_config(projectRoot);
require_kao_reference(cfg);
model = load_published_generator(cfg);
report = run_stage1_smoke_tests(cfg, model);
referenceSource = 'verified project-local native-reference cache';
fprintf('PASS: upstream %s; short-segment max abs %.3e; Q residual %.3e.\n', ...
    cfg.upstreamCommit, report.shortSegmentMaxAbs, report.qRelativeResidual);
fprintf('Reference source: %s.\n', referenceSource);
fprintf(['No optimization, training, Stage 2B-Kao, Stage 2B-Cerebellum, ' ...
    'or full analysis was run.\n']);
