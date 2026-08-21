function robustness = evaluate_delay_robustness( ...
        model, params, includeNoise, trialsPerTarget, seedBase)
    delayValuesMs = params.evaluation.delayValuesMs;
    numDelays = numel(delayValuesMs);
    numTrials = params.task.numTargets * trialsPerTarget;
    endpointErrorM = zeros(numDelays, numTrials);
    trajectoryRmseM = zeros(numDelays, numTrials);
    terminalSpeedMPerSec = zeros(numDelays, numTrials);
    preGoRmsSpeedMPerSec = zeros(numDelays, 1);
    seeds = seedBase + (0:(numDelays - 1));

    for delayIndex = 1:numDelays
        delayMs = delayValuesMs(delayIndex);
        task = build_reach_task(params, trialsPerTarget, delayMs);
        simulation = simulate_intact_model(model, task, params, ...
            seeds(delayIndex), includeNoise);
        speed = reshape(sqrt(sum(simulation.velocity.^2, 1)), ...
            numTrials, task.numTimeSteps);
        preGoMask = logical(task.preGoMask);
        preGoRmsSpeedMPerSec(delayIndex) = sqrt(mean( ...
            double(speed(preGoMask)).^2));

        for trialIndex = 1:numTrials
            endpointIndex = task.movementEndIndexByTrial(trialIndex);
            endpointErrorM(delayIndex, trialIndex) = norm( ...
                double(simulation.position(:, trialIndex, endpointIndex)) - ...
                double(task.trialTargetPositions(:, trialIndex)));
            terminalSpeedMPerSec(delayIndex, trialIndex) = norm(double( ...
                simulation.velocity(:, trialIndex, endpointIndex)));
            movementMask = logical(task.movementMask(trialIndex, :));
            positionError = double(simulation.position(:, trialIndex, ...
                movementMask) - task.desiredPosition(:, trialIndex, ...
                movementMask));
            squaredDistance = reshape(sum(positionError.^2, 1), 1, []);
            trajectoryRmseM(delayIndex, trialIndex) = ...
                sqrt(mean(squaredDistance));
        end
    end

    endpointTrend = polyfit(double(delayValuesMs), ...
        mean(endpointErrorM, 2)', 1);
    trajectoryTrend = polyfit(double(delayValuesMs), ...
        mean(trajectoryRmseM, 2)', 1);
    robustness.delayValuesMs = delayValuesMs;
    robustness.endpointErrorM = endpointErrorM;
    robustness.trajectoryRmseM = trajectoryRmseM;
    robustness.terminalSpeedMPerSec = terminalSpeedMPerSec;
    robustness.preGoRmsSpeedMPerSec = preGoRmsSpeedMPerSec;
    robustness.meanEndpointErrorM = mean(endpointErrorM, 2);
    robustness.stdEndpointErrorM = std(endpointErrorM, 0, 2);
    robustness.meanTrajectoryRmseM = mean(trajectoryRmseM, 2);
    robustness.stdTrajectoryRmseM = std(trajectoryRmseM, 0, 2);
    robustness.meanTerminalSpeedMPerSec = ...
        mean(terminalSpeedMPerSec, 2);
    robustness.stdTerminalSpeedMPerSec = ...
        std(terminalSpeedMPerSec, 0, 2);
    robustness.endpointErrorSlopeMPerMs = endpointTrend(1);
    robustness.trajectoryRmseSlopeMPerMs = trajectoryTrend(1);
    robustness.endpointErrorLateMinusEarlyM = ...
        robustness.meanEndpointErrorM(end) - ...
        robustness.meanEndpointErrorM(1);
    robustness.trajectoryRmseLateMinusEarlyM = ...
        robustness.meanTrajectoryRmseM(end) - ...
        robustness.meanTrajectoryRmseM(1);
    robustness.seeds = seeds;
    robustness.trialsPerTarget = trialsPerTarget;
    robustness.includeNoise = includeNoise;
end
