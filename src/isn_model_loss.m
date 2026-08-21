function [totalLoss, components] = isn_model_loss(model, task, params, noise)
    n = params.model.numCorticalUnits;
    state = model.baselineRates + params.noise.sigmaInitialHz * noise.initial;
    angles = task.initialJointAngles;
    velocity = task.initialJointVelocity;
    integrationFraction = single(params.model.dtMs / params.model.tauMs);
    dynamicScale = single(sqrt(params.model.tauMs / params.model.dtMs));
    cInf = model.WcbLatent * tanh(model.WcbHidden * task.targetInput + ...
        model.bcbHidden) + model.bcbLatent;
    zero = sum(state(1) * 0);
    names = {'preGoPosition', 'preGoVelocity', 'preGoTorque', ...
        'endpointUrgency', 'terminalPosition', 'terminalVelocity', ...
        'holdPosition', 'holdVelocity', 'effort', 'joint', ...
        'torque', 'activity'};
    for nameIndex = 1:numel(names)
        sums.(names{nameIndex}) = zero;
    end

    for timeIndex = 1:task.numTimeSteps
        rates = max(state, 0);
        rawTorque = model.Wout * rates;
        hand = arm_forward_kinematics(angles, params.plant);
        handVelocity = arm_endpoint_velocity(angles, velocity, params.plant);
        centerError = (hand - task.centerPosition) / ...
            single(params.task.targetRadiusM);
        targetError = (hand - task.trialTargetPositions) / ...
            single(params.task.targetRadiusM);
        speedSquared = sum((handVelocity / 0.25).^2, 1);
        pre = task.preGoMask(:, timeIndex)';
        urgency = task.endpointUrgency(:, timeIndex)';
        terminal = task.terminalMask(:, timeIndex)';
        hold = task.holdMask(:, timeIndex)';
        sums.preGoPosition = sums.preGoPosition + ...
            sum(sum(centerError.^2, 1) .* pre, 'all');
        sums.preGoVelocity = sums.preGoVelocity + ...
            sum(speedSquared .* pre, 'all');
        sums.preGoTorque = sums.preGoTorque + ...
            sum(sum((rawTorque / 0.25).^2, 1) .* pre, 'all');
        sums.endpointUrgency = sums.endpointUrgency + ...
            sum(sum(targetError.^2, 1) .* urgency, 'all');
        sums.terminalPosition = sums.terminalPosition + ...
            sum(sum(targetError.^2, 1) .* terminal, 'all');
        sums.terminalVelocity = sums.terminalVelocity + ...
            sum(speedSquared .* terminal, 'all');
        sums.holdPosition = sums.holdPosition + ...
            sum(sum(targetError.^2, 1) .* hold, 'all');
        sums.holdVelocity = sums.holdVelocity + ...
            sum(speedSquared .* hold, 'all');
        sums.effort = sums.effort + sum((rawTorque / 0.25).^2, 'all');
        sums.joint = sums.joint + sum(joint_penalty(angles, params), 'all');
        sums.torque = sums.torque + sum(torque_penalty(rawTorque, params), 'all');
        sums.activity = sums.activity + sum((rates / 30).^2, 'all');

        if timeIndex < task.numTimeSteps
            latent = cInf .* task.relaxationScale(timeIndex);
            dynamicNoise = params.noise.sigmaDynamicHz * dynamicScale * ...
                noise.dynamic(:, :, timeIndex);
            derivative = -state + model.Wrec * rates + ...
                model.baselineDrive + model.Wtarg * task.targetInput + ...
                model.Wgo * task.goSignal(:, timeIndex)' + ...
                model.Ucb * latent + dynamicNoise;
            state = state + integrationFraction * derivative;
            [angles, velocity] = two_link_arm_step(angles, velocity, ...
                rawTorque, task.dtSeconds, params.plant);
        end
    end

    components.preGoPosition = sums.preGoPosition / sum(task.preGoMask, 'all');
    components.preGoVelocity = sums.preGoVelocity / sum(task.preGoMask, 'all');
    components.preGoTorque = sums.preGoTorque / sum(task.preGoMask, 'all');
    components.endpointUrgency = sums.endpointUrgency / ...
        max(sum(task.endpointUrgency, 'all'), 1);
    components.terminalPosition = sums.terminalPosition / ...
        sum(task.terminalMask, 'all');
    components.terminalVelocity = sums.terminalVelocity / ...
        sum(task.terminalMask, 'all');
    components.holdPosition = sums.holdPosition / sum(task.holdMask, 'all');
    components.holdVelocity = sums.holdVelocity / sum(task.holdMask, 'all');
    denominator = single(task.numTrials * task.numTimeSteps);
    components.effort = sums.effort / denominator;
    components.joint = sums.joint / denominator;
    components.torque = sums.torque / denominator;
    components.activity = sums.activity / single(n) / denominator;
    weightSum = zero;
    trainable = {'Wtarg', 'Wgo', 'Ucb', 'WcbHidden', 'bcbHidden', ...
        'WcbLatent', 'bcbLatent', 'Wout'};
    for fieldIndex = 1:numel(trainable)
        weightSum = weightSum + sum(model.(trainable{fieldIndex}).^2, 'all');
    end
    components.weight = weightSum / single(200 * 200);
    w = params.training;
    totalLoss = w.preGoPositionLossWeight * components.preGoPosition + ...
        w.preGoVelocityLossWeight * components.preGoVelocity + ...
        w.preGoTorqueLossWeight * components.preGoTorque + ...
        w.endpointUrgencyLossWeight * components.endpointUrgency + ...
        w.terminalPositionLossWeight * components.terminalPosition + ...
        w.terminalVelocityLossWeight * components.terminalVelocity + ...
        w.holdPositionLossWeight * components.holdPosition + ...
        w.holdVelocityLossWeight * components.holdVelocity + ...
        w.controlEffortLossWeight * components.effort + ...
        w.jointLimitLossWeight * components.joint + ...
        w.torqueLimitLossWeight * components.torque + ...
        w.activityRegularization * components.activity + ...
        w.weightRegularization * components.weight;
end

function value = smooth_positive(input, softness)
    value = 0.5 * (input + sqrt(input.^2 + softness^2));
end

function penalty = joint_penalty(angles, params)
    p = params.plant;
    margin = single(p.jointPenaltyMarginRad);
    softness = single(p.jointPenaltySoftnessRad);
    low = single(p.jointLowerLimitsRad) + margin;
    high = single(p.jointUpperLimitsRad) - margin;
    penalty = (smooth_positive(low - angles, softness) / margin).^2 + ...
        (smooth_positive(angles - high, softness) / margin).^2;
end

function penalty = torque_penalty(torque, params)
    p = params.plant;
    guideline = single(p.torqueGuidelineNm);
    softness = single(p.torquePenaltySoftnessNm);
    magnitude = sqrt(torque.^2 + softness^2);
    penalty = (smooth_positive(magnitude - guideline, softness) / ...
        guideline).^2;
end
