function [comparison, diagnosis] = finalize_target_torque_diagnostic(projectRoot)
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src', 'published_generator'));
    addpath(fullfile(projectRoot, 'analysis', 'published_generator'));
    cfg = stage_1_gate1_config(projectRoot);
    diagnosticRoot = fullfile(cfg.gate1.resultsRoot, 'target_torque_diagnostic');
    completePath = fullfile(diagnosticRoot, 'target_torque_diagnostic_complete.mat');
    saved = load(completePath);
    model = load_published_generator(cfg);
    [nativeAngles, nativeTargetHands, nativeTorques, nativeDiagnostics] = ...
        load_native_target_torque_benchmark(cfg);
    nativeTable = summarize_target_torque_benchmark("Pinned native Kao", ...
        nativeAngles, nativeTargetHands, nativeTorques, nativeDiagnostics, ...
        model, cfg.gate1.validation.maxEndpointErrorM);
    comparison = saved.comparison;
    comparison(1:8, :) = nativeTable;
    diagnosis = classify_target_torque_diagnostic(comparison, ...
        cfg.gate1.validation.maxEndpointErrorM);
    newRows = comparison(comparison.Benchmark == "MATLAB new geometry", :);
    originalRows = comparison(comparison.Benchmark == "MATLAB original geometry", :);
    nativeRows = comparison(comparison.Benchmark == "Pinned native Kao", :);
    desiredT1 = saved.newTarget.hands(end, [1, 3], 1);
    minimumArmReachM = abs(model.arm.L2 - model.arm.L1);
    desiredT1ShoulderDistanceM = norm(desiredT1);
    kinematicEndpointLowerBoundM = max(0, ...
        minimumArmReachM - desiredT1ShoulderDistanceM);
    t1 = newRows(newRows.Target == 1, :);
    diagnosis.classification = ...
        'new T1 target is kinematically unreachable for the frozen two-link arm';
    diagnosis.failedTarget = 1;
    diagnosis.failedTargetAngleDeg = 270;
    diagnosis.minimumArmReachM = minimumArmReachM;
    diagnosis.desiredT1ShoulderDistanceM = desiredT1ShoulderDistanceM;
    diagnosis.kinematicEndpointLowerBoundM = kinematicEndpointLowerBoundM;
    diagnosis.observedT1EndpointErrorM = t1.EndpointErrorM;
    diagnosis.observedMinusKinematicLowerBoundM = ...
        t1.EndpointErrorM - kinematicEndpointLowerBoundM;
    diagnosis.t1ThresholdExcessM = t1.EndpointErrorM ...
        - cfg.gate1.validation.maxEndpointErrorM;
    diagnosis.maximumEndpointErrorOtherNewTargetsM = ...
        max(newRows.EndpointErrorM(newRows.Target ~= 1));
    diagnosis.maximumOriginalVsNativeEndpointDifferenceM = ...
        max(abs(originalRows.EndpointErrorM - nativeRows.EndpointErrorM));
    diagnosis.maximumOriginalVsNativeObjectiveDifference = ...
        max(abs(originalRows.SourceTotalObjective - nativeRows.SourceTotalObjective));
    diagnosis.recommendedNextDecision = ['Revise the authorized target geometry or ' ...
        'explicitly define how an unreachable target is to be handled; do not retune ' ...
        'the optimizer or loosen the gate as a substitute.'];
    diagnosis.stage2ArtifactsUnchanged = saved.diagnosis.stage2ArtifactsUnchanged;
    diagnosis.pinnedManifestEntries = saved.diagnosis.pinnedManifestEntries;
    diagnosis.pinnedManifestAllMatched = saved.diagnosis.pinnedManifestAllMatched;
    diagnosis.previousFailedAuditPreserved = ...
        saved.diagnosis.previousFailedAuditPreserved;
    diagnosis.tenNetworkEnsembleGenerated = false;
    diagnosis.stage2AOr2BExecuted = false;
    writetable(comparison, fullfile(diagnosticRoot, ...
        'target_torque_comparison_by_target.csv'));
    summary = groupsummary(comparison, 'Benchmark', {'min','median','max'}, ...
        {'EndpointErrorM','AngularErrorDeg','RadialErrorM', ...
        'PositionTrajectoryRmseM','SourceTotalObjective','MaximumAbsoluteTorque'});
    writetable(summary, fullfile(diagnosticRoot, ...
        'target_torque_comparison_summary.csv'));
    fid = fopen(fullfile(diagnosticRoot, 'target_torque_diagnosis.json'), 'w');
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '%s', jsonencode(diagnosis, PrettyPrint=true));
    clear cleanup;
    cfgSaved = saved.cfg;
    targetSummary = saved.summary;
    nativeDiagnosticsSaved = nativeDiagnostics;
    save(completePath, 'cfgSaved', 'comparison', 'targetSummary', 'diagnosis', ...
        'nativeAngles', 'nativeTargetHands', 'nativeTorques', ...
        'nativeDiagnosticsSaved', '-append');
    manifest = hash_tree(projectRoot, ...
        "results/stage_1/gate1_recalibrated/target_torque_diagnostic");
    manifest(endsWith(manifest.relative_path, ...
        'target_torque_diagnostic_manifest.csv'), :) = [];
    writetable(manifest, fullfile(diagnosticRoot, ...
        'target_torque_diagnostic_manifest.csv'));
end
