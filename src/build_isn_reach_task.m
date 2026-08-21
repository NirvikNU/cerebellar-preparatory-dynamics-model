function task = build_isn_reach_task(params, trialsPerTarget, goTimeMs, ...
        targetIndex)
    nTargets = params.task.numTargets;
    if nargin < 4 || isempty(targetIndex)
        targetIndex = repelem(1:nTargets, trialsPerTarget);
    end
    targetIndex = reshape(double(targetIndex), 1, []);
    nTrials = numel(targetIndex);
    if nargin < 3 || isempty(goTimeMs)
        goTimeMs = params.task.canonicalGoTimeMs;
    end
    if isscalar(goTimeMs)
        goTimeMs = repmat(goTimeMs, 1, nTrials);
    end
    goTimeMs = reshape(single(goTimeMs), 1, []);
    if numel(goTimeMs) ~= nTrials
        error('IsnModel:GoTimes', 'A go time is required for every trial.');
    end
    counts = accumarray(targetIndex(:), 1, [nTargets 1]);
    if any(counts ~= trialsPerTarget)
        error('IsnModel:UnbalancedBatch', 'Targets must be balanced.');
    end

    timeMs = single(0:params.model.dtMs: ...
        params.task.maximumTrialDurationMs);
    targetBasis = eye(nTargets, 'single');
    targetInput = targetBasis(:, targetIndex);
    angles = single(deg2rad(params.task.targetAnglesDeg));
    center = arm_forward_kinematics(single( ...
        params.plant.initialJointAnglesRad), params.plant);
    targets = center + single(params.task.targetRadiusM) * ...
        [cos(angles); sin(angles)];
    trialTargets = targets(:, targetIndex);
    elapsed = timeMs - goTimeMs';
    movementEnd = goTimeMs' + params.task.movementDurationMs;
    holdEnd = movementEnd + params.task.holdDurationMs;
    preGoMask = single(timeMs < goTimeMs');
    movementMask = single(elapsed >= 0 & timeMs <= movementEnd);
    holdMask = single(timeMs > movementEnd & timeMs <= holdEnd);
    terminalMask = single(timeMs >= movementEnd - 50 & ...
        timeMs <= movementEnd + 50);
    urgency = movementMask .* single(min(max(double(elapsed) / ...
        params.task.movementDurationMs, 0), 1).^2);
    goSignal = single(timeMs >= goTimeMs' & timeMs < ...
        goTimeMs' + params.task.goPulseDurationMs);
    relaxationScale = single(1 - exp(-double(timeMs) / ...
        params.model.cerebellarTauMs));

    task.timeMs = timeMs;
    task.dtSeconds = single(params.model.dtMs / 1000);
    task.targetInput = targetInput;
    task.targetIndex = targetIndex;
    task.targetPositions = targets;
    task.trialTargetPositions = trialTargets;
    task.centerPosition = center;
    task.goTimeMs = goTimeMs;
    task.goSignal = goSignal;
    task.relaxationScale = relaxationScale;
    task.preGoMask = preGoMask;
    task.movementMask = movementMask;
    task.terminalMask = terminalMask;
    task.holdMask = holdMask;
    task.endpointUrgency = urgency;
    task.movementEndIndexByTrial = ...
        round(double(goTimeMs + params.task.movementDurationMs) / ...
        params.model.dtMs) + 1;
    task.numTrials = nTrials;
    task.numTimeSteps = numel(timeMs);
end
