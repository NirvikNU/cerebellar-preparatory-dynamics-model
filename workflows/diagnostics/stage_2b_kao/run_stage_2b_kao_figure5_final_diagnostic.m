clear;
close all;
clc;

rootDirectory = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(rootDirectory, 'config'));
addpath(fullfile(rootDirectory, 'src', 'published_generator'));
addpath(fullfile(rootDirectory, 'src', 'stage_2a'));
addpath(fullfile(rootDirectory, 'src', 'stage_2b_kao'));
addpath(fullfile(rootDirectory, 'analysis', 'published_generator'));
addpath(fullfile(rootDirectory, 'analysis', 'stage_2b_shared'));

issues = checkcode(fullfile(rootDirectory, 'analysis', 'stage_2b_shared', ...
    'audit_stage2b_kao_figure5_final.m'), '-id');
if ~isempty(issues)
    for issue = 1:numel(issues)
        fprintf('%s:%d %s\n', issues(issue).id, issues(issue).line, ...
            issues(issue).message);
    end
    error('Code Analyzer issues in the Figure-5 final diagnostic.');
end

audit = audit_stage2b_kao_figure5_final(rootDirectory);
fprintf('STATUS: %s\n', audit.Status);
fprintf('Maximum preparation-state difference: %.3e\n', ...
    audit.MaximumPreparationStateDifference);
fprintf('Maximum saved-metric difference: %.3e\n', ...
    audit.MaximumSavedMetricDifference);
fprintf('Maximum batched/single-target difference: %.3e\n', ...
    audit.MaximumBatchedVersusSingleTargetDifference);
fprintf('Maximum GO initial-torque difference: %.3e\n', ...
    audit.MaximumInitialTorqueDifference);

controllers = ["Stage 2A", "Stage 2B-Kao"];
metrics = ["StateErrorFraction", "ProspectiveErrorFraction", ...
    "EndpointErrorM", "HandTrajectoryNRMSE", "TorqueNRMSE"];
for controller = controllers
    rows = audit.Comparison.Controller == controller;
    fprintf('%s\n', controller);
    for metric = metrics
        at100 = audit.Comparison.(metric + "100ms")(rows);
        at200 = audit.Comparison.(metric + "200ms")(rows);
        lower = audit.Comparison.(metric + "LowerAt200")(rows);
        fprintf('  %s: %.12g -> %.12g; lower at 200 ms %d/10\n', ...
            metric, median(at100), median(at200), sum(lower));
    end
end

traceMetrics = ["TorqueErrorRms", "TorqueErrorPreOnsetRms", ...
    "TorqueErrorPostOnsetRms", "TorqueErrorLateRms", ...
    "MaximumHandErrorM", "HandErrorAtMovementOnsetM", "EndpointErrorM", ...
    "TorqueErrorImpulseNorm", "FinalJointAngleErrorNorm", ...
    "FinalJointVelocityErrorNorm"];
rows = audit.TraceComparison.Controller == "Stage 2A";
for metric = traceMetrics
    at100 = audit.TraceComparison.(metric + "100ms")(rows);
    at200 = audit.TraceComparison.(metric + "200ms")(rows);
    fprintf('Stage 2A trace %s: %.12g -> %.12g\n', ...
        metric, median(at100), median(at200));
end

validation = finalize_stage2b_kao_figure5_freeze(rootDirectory);
fprintf('Freeze status: %s\n', validation.Status);
fprintf('Only canonical Figure 5 changed: %d\n', ...
    validation.OnlyFigure5Changed);
fprintf('Stage 1 / Stage 2A / Stage 2B-Cerebellum frozen: %d / %d / %d\n', ...
    validation.Stage1FrozenManifestVerified, ...
    validation.Stage2aFrozenManifestVerified, ...
    validation.Stage2bCerebellumManifestVerified);
