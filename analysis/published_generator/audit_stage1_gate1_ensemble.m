function [audit, targetAudit, primary] = audit_stage1_gate1_ensemble(cfg, models, ...
        calibrationDiagnostics, ~, target, targetTorques)
    count = numel(models);
    network = (1:count).';
    seed = strings(count, 1);
    provenance = strings(count, 1);
    maxAngleErrorDeg = zeros(count, 1);
    maxRadiusErrorM = zeros(count, 1);
    maxEndpointErrorM = zeros(count, 1);
    weightedTorqueCost = zeros(count, 1);
    spectralAbscissaW = zeros(count, 1);
    readoutNullResidual = zeros(count, 1);
    calibrationIterations = zeros(count, 1);
    pass = false(count, 1);
    targetRows = count * numel(cfg.gate1.targetAnglesDeg);
    targetNetwork = zeros(targetRows, 1);
    targetId = zeros(targetRows, 1);
    desiredAngleDeg = zeros(targetRows, 1);
    actualAngleDeg = zeros(targetRows, 1);
    angularErrorDeg = zeros(targetRows, 1);
    desiredRadiusM = cfg.gate1.radiusM * ones(targetRows, 1);
    actualRadiusM = zeros(targetRows, 1);
    radiusErrorM = zeros(targetRows, 1);
    endpointErrorM = zeros(targetRows, 1);
    targetPass = false(targetRows, 1);
    desiredAngles = mod(cfg.gate1.targetAnglesDeg(:), 360);
    desiredEndpoint = target.initialHand([1, 3]) + target.endpointDisplacement;
    for index = 1:count
        model = models{index};
        model.targetHand = target.hands;
        model.targetTorque = targetTorques;
        rollout = simulate_published_cortex(model, model.xstar, true);
        [~, hand] = simulate_published_arm(model, rollout.torque);
        endpoint = squeeze(hand(end, [1, 3], :)).';
        displacement = endpoint - target.initialHand([1, 3]);
        angles = mod(atan2d(displacement(:, 2), displacement(:, 1)), 360);
        angleDifference = mod(angles - desiredAngles + 180, 360) - 180;
        radius = vecnorm(displacement, 2, 2);
        rows = ((index - 1) * numel(desiredAngles) + 1):(index * numel(desiredAngles));
        targetNetwork(rows) = index;
        targetId(rows) = (1:numel(desiredAngles)).';
        desiredAngleDeg(rows) = desiredAngles;
        actualAngleDeg(rows) = angles;
        angularErrorDeg(rows) = angleDifference;
        actualRadiusM(rows) = radius;
        radiusErrorM(rows) = radius - cfg.gate1.radiusM;
        endpointErrorM(rows) = vecnorm(endpoint - desiredEndpoint, 2, 2);
        targetPass(rows) = abs(angleDifference) ...
            <= cfg.gate1.validation.maxAngleErrorDeg ...
            & abs(radiusErrorM(rows)) <= cfg.gate1.validation.maxRadiusErrorM ...
            & endpointErrorM(rows) <= cfg.gate1.validation.maxEndpointErrorM;
        maxAngleErrorDeg(index) = max(abs(angleDifference));
        maxRadiusErrorM(index) = max(abs(radius - cfg.gate1.radiusM));
        maxEndpointErrorM(index) = max(vecnorm(endpoint - desiredEndpoint, 2, 2));
        difference = rollout.torque - targetTorques;
        difference(:, 2, :) = 3 * difference(:, 2, :);
        weightedTorqueCost(index) = model.samplingDt / model.nMovements ...
            * sum(difference.^2, 'all');
        spectralAbscissaW(index) = max(real(eig(model.W)));
        readoutNullResidual(index) = calibrationDiagnostics{index}.readoutNullResidual;
        calibrationIterations(index) = calibrationDiagnostics{index}.iterations;
        if index == cfg.gate1.pinnedMember
            seed(index) = "official default RNG (released realization) / recalibration " ...
                + string(cfg.gate1.calibrationSeeds(index));
            provenance(index) = "pinned released W and spontaneous; x* and C recalibrated";
        else
            seed(index) = string(cfg.gate1.generatedNetworkSeeds(index - 1)) ...
                + " / " + string(cfg.gate1.calibrationSeeds(index));
            provenance(index) = "source-faithful seeded SOC W; seeded setup calibration";
        end
        architecturePass = isequal(size(model.W), [200, 200]) ...
            && nnz(model.W(:, 1:160) < 0) == 0 ...
            && nnz(model.W(:, 161:end) > 0) == 0 ...
            && nnz(diag(model.W)) == 0 ...
            && all(isfinite([model.W(:); model.xstar(:); model.C(:)]));
        calibrationPass = weightedTorqueCost(index) ...
            <= cfg.gate1.validation.maxWeightedTorqueCost;
        behaviorPass = maxAngleErrorDeg(index) ...
            <= cfg.gate1.validation.maxAngleErrorDeg ...
            && maxRadiusErrorM(index) <= cfg.gate1.validation.maxRadiusErrorM ...
            && maxEndpointErrorM(index) <= cfg.gate1.validation.maxEndpointErrorM;
        pass(index) = architecturePass && calibrationPass && behaviorPass;
        models{index}.targetHand = target.hands;
        models{index}.targetTorque = targetTorques;
    end
    audit = table(network, seed, provenance, maxAngleErrorDeg, maxRadiusErrorM, ...
        maxEndpointErrorM, weightedTorqueCost, spectralAbscissaW, ...
        readoutNullResidual, calibrationIterations, pass);
    targetAudit = table(targetNetwork, targetId, desiredAngleDeg, ...
        actualAngleDeg, angularErrorDeg, desiredRadiusM, actualRadiusM, ...
        radiusErrorM, endpointErrorM, targetPass, ...
        'VariableNames', {'Network','Target','DesiredAngleDeg', ...
        'ActualAngleDeg','AngularErrorDeg','DesiredRadiusM','ActualRadiusM', ...
        'RadiusErrorM','EndpointErrorM','Pass'});
    primary = models{cfg.gate1.pinnedMember};
    primary.targetHand = target.hands;
    primary.targetTorque = targetTorques;
end
