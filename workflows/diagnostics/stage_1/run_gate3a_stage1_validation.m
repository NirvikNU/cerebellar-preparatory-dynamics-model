clear;
close all;
clc;

projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(projectRoot, 'config'));
addpath(fullfile(projectRoot, 'src', 'published_generator'));
addpath(fullfile(projectRoot, 'analysis', 'published_generator'));

cfg = stage_1_gate1_config(projectRoot);
require_kao_reference(cfg);
pinned = verify_pinned_reference(cfg);
model = load_published_generator(cfg);
smoke = run_stage1_smoke_tests(cfg, model);
ensemble = revalidate_stage1_accepted_ensemble(projectRoot);

accepted = readtable(fullfile(cfg.gate1.auditRoot, ...
    'accepted_ensemble_audit.csv'));
targets = readtable(fullfile(cfg.gate1.auditRoot, ...
    'accepted_ensemble_target_audit.csv'));
assert(height(accepted) == 10 && all(accepted.Pass));
assert(height(targets) == 80 && all(targets.Pass));
assert(pinned.allMatched && pinned.sourceHeadMatched);

report = struct('status', 'PASS', 'acceptedNetworks', height(accepted), ...
    'acceptedTargets', height(targets), ...
    'maximumAuditDifference', ensemble.maximumAuditDifference, ...
    'nativeManifestEntries', pinned.manifestEntries, ...
    'nativeManifestMatched', pinned.allMatched, ...
    'shortSegmentMaximumAbsoluteError', smoke.shortSegmentMaxAbs, ...
    'qRelativeResidual', smoke.qRelativeResidual, ...
    'figurePairsReopened', ensemble.figurePairCount);
disp(jsonencode(report, PrettyPrint=true));
