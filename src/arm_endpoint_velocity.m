function handVelocity = arm_endpoint_velocity( ...
        jointAngles, jointVelocity, plant)
    shoulder = jointAngles(1, :);
    elbow = jointAngles(2, :);
    shoulderVelocity = jointVelocity(1, :);
    elbowVelocity = jointVelocity(2, :);
    combinedAngle = shoulder + elbow;

    jacobian11 = -single(plant.L1) * sin(shoulder) - ...
        single(plant.L2) * sin(combinedAngle);
    jacobian12 = -single(plant.L2) * sin(combinedAngle);
    jacobian21 = single(plant.L1) * cos(shoulder) + ...
        single(plant.L2) * cos(combinedAngle);
    jacobian22 = single(plant.L2) * cos(combinedAngle);

    handVelocity = [ ...
        jacobian11 .* shoulderVelocity + jacobian12 .* elbowVelocity; ...
        jacobian21 .* shoulderVelocity + jacobian22 .* elbowVelocity];
end
