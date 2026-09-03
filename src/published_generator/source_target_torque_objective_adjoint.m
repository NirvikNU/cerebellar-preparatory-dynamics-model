function [loss, gradient, trajectoryError, roughness] = ...
        source_target_torque_objective_adjoint(torques, targetHands, arm, dt)
    nTorqueSamples = size(torques, 1);
    nMovements = size(torques, 3);
    theta1 = arm.theta1;
    theta2 = acos(-arm.L1 * cos(theta1) / arm.L2) - theta1;
    states = zeros(4, nTorqueSamples + 1, nMovements, 'like', torques);
    states(:, 1, :) = repmat([theta1; 0; theta2; 0], 1, 1, nMovements);
    transitionState = zeros(4, 4, nTorqueSamples, nMovements, 'like', torques);
    transitionTorque = zeros(4, 2, nTorqueSamples, nMovements, 'like', torques);
    trajectoryError = 0;
    outputGradient = zeros(4, nTorqueSamples + 1, nMovements, 'like', torques);
    for movement = 1:nMovements
        for sample = 1:(nTorqueSamples + 1)
            state = states(:, sample, movement);
            [hand, handJacobian] = hand_state_and_jacobian(state, arm);
            target = targetHands(sample, :, movement).';
            difference = hand - target;
            trajectoryError = trajectoryError + sum(difference.^2);
            outputGradient(:, sample, movement) = 2 * handJacobian.' * difference;
            if sample <= nTorqueSamples
                torque = torques(sample, :, movement).';
                [next, stateJacobian, torqueJacobian] = ...
                    arm_step_and_jacobians(state, torque, arm, dt);
                states(:, sample + 1, movement) = next;
                transitionState(:, :, sample, movement) = stateJacobian;
                transitionTorque(:, :, sample, movement) = torqueJacobian;
            end
        end
    end
    increments = torques(2:end, :, :) - torques(1:(end - 1), :, :);
    roughness = sum(increments.^2, 'all');
    initialPenalty = 10 * sum(torques(1, :, :).^2, 'all');
    loss = trajectoryError + initialPenalty + 2 * roughness;
    gradient = zeros(size(torques), 'like', torques);
    gradient(1, :, :) = gradient(1, :, :) + 20 * torques(1, :, :);
    roughnessGradient = 4 * increments;
    gradient(1:(end - 1), :, :) = gradient(1:(end - 1), :, :) ...
        - roughnessGradient;
    gradient(2:end, :, :) = gradient(2:end, :, :) + roughnessGradient;
    for movement = 1:nMovements
        adjoint = outputGradient(:, end, movement);
        for sample = nTorqueSamples:-1:1
            gradient(sample, :, movement) = gradient(sample, :, movement) ...
                + (transitionTorque(:, :, sample, movement).' * adjoint).';
            adjoint = outputGradient(:, sample, movement) ...
                + transitionState(:, :, sample, movement).' * adjoint;
        end
    end
end

function [hand, jacobian] = hand_state_and_jacobian(state, arm)
    q1 = state(1); dq1 = state(2); q2 = state(3); dq2 = state(4);
    angle = q1 + q2;
    speed = dq1 + dq2;
    c1 = cos(q1); s1 = sin(q1); ca = cos(angle); sa = sin(angle);
    hand = [arm.L1 * c1 + arm.L2 * ca; ...
        -arm.L1 * dq1 * s1 - arm.L2 * speed * sa; ...
        arm.L1 * s1 + arm.L2 * sa; ...
        arm.L1 * dq1 * c1 + arm.L2 * speed * ca];
    jacobian = [
        -arm.L1 * s1 - arm.L2 * sa, 0, -arm.L2 * sa, 0
        -arm.L1 * dq1 * c1 - arm.L2 * speed * ca, ...
            -arm.L1 * s1 - arm.L2 * sa, -arm.L2 * speed * ca, -arm.L2 * sa
        arm.L1 * c1 + arm.L2 * ca, 0, arm.L2 * ca, 0
        -arm.L1 * dq1 * s1 - arm.L2 * speed * sa, ...
            arm.L1 * c1 + arm.L2 * ca, -arm.L2 * speed * sa, arm.L2 * ca];
end

function [next, stateJacobian, torqueJacobian] = ...
        arm_step_and_jacobians(state, torque, arm, dt)
    q1 = state(1); dq1 = state(2); q2 = state(3); dq2 = state(4);
    a1 = arm.I1 + arm.I2 + arm.M2 * arm.L1^2;
    a2 = arm.M2 * arm.L1 * arm.S2;
    a3 = arm.I2;
    sine = sin(q2); cosine = cos(q2);
    mass = [a1 + 2 * a2 * cosine, a3 + a2 * cosine; ...
        a3 + a2 * cosine, a3];
    coriolis = [-a2 * sine * dq2 * (2 * dq1 + dq2); ...
        a2 * sine * dq1^2];
    rhs = torque - coriolis - arm.B * [dq1; dq2];
    acceleration = mass \ rhs;
    derivativeMassQ2 = [-2 * a2 * sine, -a2 * sine; -a2 * sine, 0];
    derivativeCoriolisQ2 = [-a2 * cosine * dq2 * (2 * dq1 + dq2); ...
        a2 * cosine * dq1^2];
    derivativeCoriolisDq1 = [-2 * a2 * sine * dq2; 2 * a2 * sine * dq1];
    derivativeCoriolisDq2 = [-2 * a2 * sine * (dq1 + dq2); 0];
    derivativeAcceleration = zeros(2, 4, 'like', state);
    derivativeAcceleration(:, 2) = mass \ ...
        (-derivativeCoriolisDq1 - arm.B(:, 1));
    derivativeAcceleration(:, 3) = mass \ ...
        (-derivativeCoriolisQ2 - derivativeMassQ2 * acceleration);
    derivativeAcceleration(:, 4) = mass \ ...
        (-derivativeCoriolisDq2 - arm.B(:, 2));
    stateJacobian = eye(4, 'like', state);
    stateJacobian(1, 2) = dt;
    stateJacobian(3, 4) = dt;
    stateJacobian(2, :) = stateJacobian(2, :) + dt * derivativeAcceleration(1, :);
    stateJacobian(4, :) = stateJacobian(4, :) + dt * derivativeAcceleration(2, :);
    torqueJacobian = zeros(4, 2, 'like', state);
    torqueJacobian([2, 4], :) = dt * (mass \ eye(2, 'like', state));
    next = [q1 + dt * dq1; dq1 + dt * acceleration(1); ...
        q2 + dt * dq2; dq2 + dt * acceleration(2)];
end
