function task = build_reach_task(params, trialsPerTarget, goTimeMs, ...
        targetIndex)
    if nargin < 2 || isempty(trialsPerTarget)
        trialsPerTarget = 1;
    end

    numTargets = params.task.numTargets;
    targetAnglesDeg = params.task.targetAnglesDeg;
    if numel(targetAnglesDeg) ~= numTargets
        error('IntactModel:TargetCountMismatch', ...
            'targetAnglesDeg must contain one angle per target.');
    end

    if nargin < 4 || isempty(targetIndex)
        targetIndex = repelem(1:numTargets, trialsPerTarget);
    else
        targetIndex = reshape(double(targetIndex), 1, []);
        expectedTrials = numTargets * trialsPerTarget;
        if numel(targetIndex) ~= expectedTrials || ...
                any(targetIndex < 1) || any(targetIndex > numTargets) || ...
                any(mod(targetIndex, 1) ~= 0)
            error('IntactModel:TargetIndex', ...
                'targetIndex must specify every balanced minibatch trial.');
        end
        counts = accumarray(targetIndex(:), 1, [numTargets 1]);
        if any(counts ~= trialsPerTarget)
            error('IntactModel:UnbalancedTargets', ...
                'Every target must occur trialsPerTarget times.');
        end
    end
    numTrials = numel(targetIndex);

    if nargin < 3 || isempty(goTimeMs)
        goTimeMs = params.task.canonicalGoTimeMs;
    end
    if isscalar(goTimeMs)
        goTimeMs = repmat(goTimeMs, 1, numTrials);
    end
    goTimeMs = reshape(single(goTimeMs), 1, []);
    if numel(goTimeMs) ~= numTrials
        error('IntactModel:GoTimeCountMismatch', ...
            'goTimeMs must be scalar or contain one value per trial.');
    end
    if any(goTimeMs < params.task.minimumGoTimeMs) || ...
            any(goTimeMs > params.task.maximumGoTimeMs)
        error('IntactModel:GoTimeRange', ...
            'Every go time must lie within the configured training range.');
    end

    dtMs = params.model.dtMs;
    timeMs = single(0:dtMs:params.task.maximumTrialDurationMs);
    numTimeSteps = numel(timeMs);
    targetAnglesRad = single(deg2rad(targetAnglesDeg));
    targetDirections = [cos(targetAnglesRad); sin(targetAnglesRad)];
    centerPosition = arm_forward_kinematics(single( ...
        params.plant.initialJointAnglesRad), params.plant);
    targetPositions = centerPosition + ...
        single(params.task.targetRadiusM) * targetDirections;
    trialTargetPositions = targetPositions(:, targetIndex);

    targetInputBasis = eye(numTargets, 'single');
    targetInput = targetInputBasis(:, targetIndex);
    goSignal = single(timeMs >= goTimeMs');
    preGoMask = single(timeMs < goTimeMs');
    movementEndTimeMs = goTimeMs + params.task.movementDurationMs;
    movementMask = single(timeMs >= goTimeMs' & ...
        timeMs <= movementEndTimeMs');
    movementEndIndexByTrial = ...
        round(double(movementEndTimeMs) / dtMs) + 1;
    terminalMask = zeros(numTrials, numTimeSteps, 'single');
    linearTerminalIndex = sub2ind([numTrials numTimeSteps], ...
        1:numTrials, movementEndIndexByTrial);
    terminalMask(linearTerminalIndex) = 1;

    normalizedElapsedCueTime = single(2 * double(timeMs) / ...
        params.task.maximumTrialDurationMs - 1);
    cerebellarInput = zeros(params.model.cerebellarInputSize, ...
        numTrials, numTimeSteps, 'single');
    desiredPosition = zeros(2, numTrials, numTimeSteps, 'single');
    desiredVelocity = zeros(2, numTrials, numTimeSteps, 'single');
    displacement = trialTargetPositions - centerPosition;
    movementDurationSeconds = params.task.movementDurationMs / 1000;

    for timeIndex = 1:numTimeSteps
        cerebellarInput(:, :, timeIndex) = [targetInput; ...
            repmat(normalizedElapsedCueTime(timeIndex), 1, numTrials)];

        fraction = (double(timeMs(timeIndex)) - double(goTimeMs)) / ...
            params.task.movementDurationMs;
        boundedFraction = min(max(fraction, 0), 1);
        positionScale = 10 * boundedFraction.^3 - ...
            15 * boundedFraction.^4 + 6 * boundedFraction.^5;
        velocityScale = (30 * boundedFraction.^2 - ...
            60 * boundedFraction.^3 + 30 * boundedFraction.^4) / ...
            movementDurationSeconds;
        withinMovement = fraction >= 0 & fraction <= 1;
        velocityScale(~withinMovement) = 0;

        desiredPosition(:, :, timeIndex) = centerPosition + ...
            displacement .* single(positionScale);
        desiredVelocity(:, :, timeIndex) = ...
            displacement .* single(velocityScale);
    end

    task.timeMs = timeMs;
    task.dtSeconds = single(dtMs / 1000);
    task.targetAnglesDeg = targetAnglesDeg;
    task.targetAnglesRad = targetAnglesRad;
    task.targetDirections = targetDirections;
    task.centerPosition = centerPosition;
    task.targetPositions = targetPositions;
    task.trialTargetPositions = trialTargetPositions;
    task.targetIndex = targetIndex;
    task.targetInput = targetInput;
    task.goTimeMs = goTimeMs;
    task.goSignal = goSignal;
    task.cerebellarGeneratorInput = cerebellarInput;
    task.desiredPosition = desiredPosition;
    task.desiredVelocity = desiredVelocity;
    task.preGoMask = preGoMask;
    task.movementMask = movementMask;
    task.terminalMask = terminalMask;
    task.goIndexByTrial = round(double(goTimeMs) / dtMs) + 1;
    task.movementEndIndexByTrial = movementEndIndexByTrial;
    task.desiredPeakSpeedMPerSec = single(1.875 * ...
        params.task.targetRadiusM / movementDurationSeconds);
    task.numTrials = numTrials;
    task.numTimeSteps = numTimeSteps;
end
