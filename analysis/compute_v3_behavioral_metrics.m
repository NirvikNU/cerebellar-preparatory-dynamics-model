function metrics = compute_v3_behavioral_metrics(simulation, task, params)
    speed = squeeze(sqrt(sum(double(simulation.velocity).^2, 1)));
    if task.numTrials == 1
        speed = reshape(speed, 1, []);
    end
    position = double(simulation.position);
    nTrials = task.numTrials;
    endpointError = zeros(nTrials, 1);
    terminalSpeed = zeros(nTrials, 1);
    preGoRmsSpeed = zeros(nTrials, 1);
    latePreGoRmsSpeed = zeros(nTrials, 1);
    maximumPreGoSpeed = zeros(nTrials, 1);
    holdError = zeros(nTrials, 1);
    holdSpeed = zeros(nTrials, 1);
    for trial = 1:nTrials
        target = double(task.trialTargetPositions(:, trial));
        endpointIndex = task.movementEndIndexByTrial(trial);
        endpointError(trial) = norm( ...
            position(:, trial, endpointIndex) - target);
        terminal = logical(task.terminalMask(trial, :));
        pre = logical(task.preGoMask(trial, :));
        latePre = logical(task.latePreGoMask(trial, :));
        hold = logical(task.holdMask(trial, :));
        terminalSpeed(trial) = mean(speed(trial, terminal));
        preGoRmsSpeed(trial) = sqrt(mean(speed(trial, pre).^2));
        latePreGoRmsSpeed(trial) = sqrt(mean( ...
            speed(trial, latePre).^2));
        maximumPreGoSpeed(trial) = max(speed(trial, pre));
        holdPositions = reshape(position(:, trial, hold), 2, []);
        holdError(trial) = mean(vecnorm(holdPositions - target, 2, 1));
        holdSpeed(trial) = mean(speed(trial, hold));
    end
    targetAverages = zeros(params.task.numTargets, 6);
    for target = 1:params.task.numTargets
        selected = task.targetIndex == target;
        targetAverages(target, :) = [mean(endpointError(selected)), ...
            mean(terminalSpeed(selected)), ...
            mean(preGoRmsSpeed(selected)), ...
            mean(latePreGoRmsSpeed(selected)), ...
            mean(holdError(selected)), mean(holdSpeed(selected))];
    end
    metrics.perTrial.endpointErrorM = endpointError;
    metrics.perTrial.terminalSpeedMPerSec = terminalSpeed;
    metrics.perTrial.preGoRmsSpeedMPerSec = preGoRmsSpeed;
    metrics.perTrial.latePreGoRmsSpeedMPerSec = latePreGoRmsSpeed;
    metrics.perTrial.maximumPreGoSpeedMPerSec = maximumPreGoSpeed;
    metrics.perTrial.holdErrorM = holdError;
    metrics.perTrial.holdSpeedMPerSec = holdSpeed;
    metrics.targetAverages = targetAverages;
    metrics.meanEndpointErrorM = mean(endpointError);
    metrics.worstTargetEndpointErrorM = max(targetAverages(:, 1));
    metrics.meanTerminalSpeedMPerSec = mean(terminalSpeed);
    metrics.preGoRmsSpeedMPerSec = sqrt(mean(preGoRmsSpeed.^2));
    metrics.latePreGoRmsSpeedMPerSec = sqrt(mean( ...
        latePreGoRmsSpeed.^2));
    metrics.maximumPreGoSpeedMPerSec = max(maximumPreGoSpeed);
    metrics.meanHoldErrorM = mean(holdError);
    metrics.meanHoldSpeedMPerSec = mean(holdSpeed);
    metrics.allFinite = all(isfinite([endpointError; terminalSpeed; ...
        preGoRmsSpeed; latePreGoRmsSpeed; maximumPreGoSpeed; ...
        holdError; holdSpeed]));
end
