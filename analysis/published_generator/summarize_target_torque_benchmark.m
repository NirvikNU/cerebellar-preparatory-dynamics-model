function tableData = summarize_target_torque_benchmark(benchmark, anglesDeg, ...
        targetHands, torques, optimizerDiagnostics, model, gateThresholdM)
    [~, actualHands] = simulate_published_arm(model, torques);
    count = size(torques, 3);
    target = (1:count).';
    benchmarkColumn = repmat(string(benchmark), count, 1);
    desiredAngleDeg = mod(anglesDeg(:), 360);
    desiredRadiusM = zeros(count, 1);
    terminalX_M = zeros(count, 1);
    terminalY_M = zeros(count, 1);
    endpointErrorM = zeros(count, 1);
    angularErrorDeg = zeros(count, 1);
    radialErrorM = zeros(count, 1);
    positionTrajectoryRmseM = zeros(count, 1);
    sourceTrajectoryError = zeros(count, 1);
    sourceTotalObjective = zeros(count, 1);
    initialTorquePenalty = zeros(count, 1);
    torqueSmoothness = zeros(count, 1);
    penalizedTorqueRegularization = zeros(count, 1);
    maximumAbsoluteTorque = zeros(count, 1);
    torqueRms = zeros(count, 1);
    optimizerStatus = strings(count, 1);
    optimizerIterations = nan(count, 1);
    optimizerEvaluations = nan(count, 1);
    finalGradientNorm = nan(count, 1);
    gatePass = false(count, 1);
    for movement = 1:count
        desiredInitial = targetHands(1, [1, 3], movement);
        desiredTerminal = targetHands(end, [1, 3], movement);
        desiredDisplacement = desiredTerminal - desiredInitial;
        desiredRadiusM(movement) = norm(desiredDisplacement);
        actualTerminal = actualHands(end, [1, 3], movement);
        terminalX_M(movement) = actualTerminal(1);
        terminalY_M(movement) = actualTerminal(2);
        endpointErrorM(movement) = norm(actualTerminal - desiredTerminal);
        actualDisplacement = actualTerminal - desiredInitial;
        actualAngle = mod(atan2d(actualDisplacement(2), actualDisplacement(1)), 360);
        angularErrorDeg(movement) = mod(actualAngle ...
            - desiredAngleDeg(movement) + 180, 360) - 180;
        radialErrorM(movement) = norm(actualDisplacement) - desiredRadiusM(movement);
        positionDifference = actualHands(:, [1, 3], movement) ...
            - targetHands(:, [1, 3], movement);
        positionTrajectoryRmseM(movement) = sqrt(mean(positionDifference.^2, 'all'));
        [objective, ~, trajectoryError, smoothness] = ...
            source_target_torque_objective_adjoint(torques(:, :, movement), ...
            targetHands(:, :, movement), model.arm, model.samplingDt);
        sourceTrajectoryError(movement) = trajectoryError;
        sourceTotalObjective(movement) = objective;
        initialTorquePenalty(movement) = 10 * sum(torques(1, :, movement).^2, 'all');
        torqueSmoothness(movement) = smoothness;
        penalizedTorqueRegularization(movement) = ...
            initialTorquePenalty(movement) + 2 * smoothness;
        maximumAbsoluteTorque(movement) = max(abs(torques(:, :, movement)), [], 'all');
        torqueRms(movement) = sqrt(mean(torques(:, :, movement).^2, 'all'));
        if isempty(optimizerDiagnostics)
            optimizerStatus(movement) = ...
                "official native output; exit information not exported";
        else
            detail = optimizerDiagnostics.perMovement{movement};
            optimizerStatus(movement) = string(detail.stopReason);
            optimizerIterations(movement) = detail.iterations;
            finalGradientNorm(movement) = detail.finalGradientNorm;
        end
        gatePass(movement) = endpointErrorM(movement) <= gateThresholdM;
    end
    tableData = table(benchmarkColumn, target, desiredAngleDeg, desiredRadiusM, ...
        terminalX_M, terminalY_M, endpointErrorM, angularErrorDeg, radialErrorM, ...
        positionTrajectoryRmseM, sourceTrajectoryError, sourceTotalObjective, ...
        initialTorquePenalty, torqueSmoothness, penalizedTorqueRegularization, ...
        maximumAbsoluteTorque, torqueRms, optimizerStatus, optimizerIterations, ...
        optimizerEvaluations, finalGradientNorm, gatePass, ...
        'VariableNames', {'Benchmark','Target','DesiredAngleDeg','DesiredRadiusM', ...
        'TerminalX_M','TerminalY_M','EndpointErrorM','AngularErrorDeg', ...
        'RadialErrorM','PositionTrajectoryRmseM','SourceTrajectoryError', ...
        'SourceTotalObjective','InitialTorquePenalty','TorqueSmoothness', ...
        'PenalizedTorqueRegularization','MaximumAbsoluteTorque','TorqueRms', ...
        'OptimizerStatus','OptimizerIterations','OptimizerEvaluations', ...
        'FinalGradientNorm','ProjectEndpointGatePass'});
end
