function [loss, gradients, trajectoryError, roughness] = ...
        source_target_torque_objective(torques, targetHands, arm, dt)
    nMovements = size(targetHands, 3);
    theta1 = arm.theta1;
    theta2 = acos(-arm.L1 * cos(theta1) / arm.L2) - theta1;
    state = repmat([theta1; 0; theta2; 0], 1, nMovements);
    trajectoryError = dlarray(0);
    for sample = 1:size(targetHands, 1)
        hand = source_hand_state_dl(state, arm);
        target = permute(targetHands(sample, :, :), [2, 3, 1]);
        difference = hand - target;
        trajectoryError = trajectoryError + sum(difference.^2, 'all');
        if sample <= size(torques, 1)
            torque = permute(torques(sample, :, :), [2, 3, 1]);
            state = source_arm_step_dl(state, torque, arm, dt);
        end
    end
    increments = torques(2:end, :, :) - torques(1:(end - 1), :, :);
    roughness = sum(increments.^2, 'all');
    initialPenalty = 10 * sum(torques(1, :, :).^2, 'all');
    loss = trajectoryError + initialPenalty + 2 * roughness;
    gradients = dlgradient(loss, torques);
end

function hand = source_hand_state_dl(state, arm)
    q1 = state(1, :); dq1 = state(2, :);
    q2 = state(3, :); dq2 = state(4, :);
    angle = q1 + q2;
    speed = dq1 + dq2;
    hand = [arm.L1 * cos(q1) + arm.L2 * cos(angle); ...
        -arm.L1 * dq1 .* sin(q1) - arm.L2 * speed .* sin(angle); ...
        arm.L1 * sin(q1) + arm.L2 * sin(angle); ...
        arm.L1 * dq1 .* cos(q1) + arm.L2 * speed .* cos(angle)];
end

function next = source_arm_step_dl(state, torque, arm, dt)
    q1 = state(1, :); dq1 = state(2, :);
    q2 = state(3, :); dq2 = state(4, :);
    a1 = arm.I1 + arm.I2 + arm.M2 * arm.L1^2;
    a2 = arm.M2 * arm.L1 * arm.S2;
    a3 = arm.I2;
    zc = a2 * cos(q2);
    m11 = a1 + 2 * zc;
    m12 = a3 + zc;
    m22 = a3;
    zs = a2 * sin(q2);
    c1 = -zs .* dq2 .* (2 * dq1 + dq2);
    c2 = zs .* dq1.^2;
    rhs1 = torque(1, :) - c1 - arm.B(1, 1) * dq1 - arm.B(1, 2) * dq2;
    rhs2 = torque(2, :) - c2 - arm.B(2, 1) * dq1 - arm.B(2, 2) * dq2;
    determinant = m11 .* m22 - m12.^2;
    ddq1 = (rhs1 .* m22 - m12 .* rhs2) ./ determinant;
    ddq2 = (m11 .* rhs2 - m12 .* rhs1) ./ determinant;
    next = [q1 + dt * dq1; dq1 + dt * ddq1; ...
        q2 + dt * dq2; dq2 + dt * ddq2];
end
