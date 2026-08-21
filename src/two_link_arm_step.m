function [nextJointAngles, nextJointVelocity, appliedTorque] = ...
        two_link_arm_step(jointAngles, jointVelocity, rawTorque, ...
        dtSeconds, plant)
    elbow = jointAngles(2, :);
    shoulderVelocity = jointVelocity(1, :);
    elbowVelocity = jointVelocity(2, :);

    appliedTorque = apply_arm_torque_safety(rawTorque, plant);
    coupling = single(plant.m2 * plant.L1 * plant.lc2);
    cosineElbow = cos(elbow);
    sineElbow = sin(elbow);

    mass11 = single(plant.I1 + plant.I2 + ...
        plant.m1 * plant.lc1^2 + ...
        plant.m2 * (plant.L1^2 + plant.lc2^2)) + ...
        2 * coupling * cosineElbow;
    mass12 = single(plant.I2 + plant.m2 * plant.lc2^2) + ...
        coupling * cosineElbow;
    mass22 = single(plant.I2 + plant.m2 * plant.lc2^2);

    interaction1 = -coupling * sineElbow .* ...
        (2 * shoulderVelocity .* elbowVelocity + elbowVelocity.^2);
    interaction2 = coupling * sineElbow .* shoulderVelocity.^2;
    interaction = [interaction1; interaction2];
    dampingTorque = single(plant.damping) * jointVelocity;
    rightHandSide = appliedTorque - interaction - dampingTorque;

    determinant = mass11 .* mass22 - mass12.^2;
    acceleration1 = (mass22 .* rightHandSide(1, :) - ...
        mass12 .* rightHandSide(2, :)) ./ determinant;
    acceleration2 = (-mass12 .* rightHandSide(1, :) + ...
        mass11 .* rightHandSide(2, :)) ./ determinant;
    jointAcceleration = [acceleration1; acceleration2];

    nextJointVelocity = jointVelocity + dtSeconds * jointAcceleration;
    unclippedAngles = jointAngles + dtSeconds * nextJointVelocity;
    if plant.useHardSafetyClipping
        lowerLimits = single(plant.jointLowerLimitsRad);
        upperLimits = single(plant.jointUpperLimitsRad);
        nextJointAngles = min(max(unclippedAngles, lowerLimits), ...
            upperLimits);
    else
        nextJointAngles = unclippedAngles;
    end
end
