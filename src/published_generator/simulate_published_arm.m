function [theta, hand] = simulate_published_arm(model, torque)
    if ismatrix(torque)
        torque = reshape(torque, size(torque, 1), size(torque, 2), 1);
    end
    nSamples = size(torque, 1);
    batchSize = size(torque, 3);
    theta = zeros(nSamples + 1, 4, batchSize);
    hand = zeros(nSamples + 1, 4, batchSize);
    theta2 = acos(-model.arm.L1 * cos(model.arm.theta1) / model.arm.L2) ...
        - model.arm.theta1;
    theta(1, :, :) = repmat([model.arm.theta1, 0, theta2, 0], 1, 1, batchSize);
    for batch = 1:batchSize
        hand(1, :, batch) = hand_state(squeeze(theta(1, :, batch)), model.arm);
        for time = 1:nSamples
            state = squeeze(theta(time, :, batch)).';
            q1 = state(1); dq1 = state(2); q2 = state(3); dq2 = state(4);
            a1 = model.arm.I1 + model.arm.I2 + model.arm.M2 * model.arm.L1^2;
            a2 = model.arm.M2 * model.arm.L1 * model.arm.S2;
            a3 = model.arm.I2;
            zc = a2 * cos(q2);
            mass = [a1 + 2 * zc, a3 + zc; a3 + zc, a3];
            zs = a2 * sin(q2);
            coriolis = [-zs * dq2 * (2 * dq1 + dq2); zs * dq1^2];
            acceleration = mass \ (squeeze(torque(time, :, batch)).' ...
                - coriolis - model.arm.B * [dq1; dq2]);
            next = [q1 + model.samplingDt * dq1; ...
                dq1 + model.samplingDt * acceleration(1); ...
                q2 + model.samplingDt * dq2; ...
                dq2 + model.samplingDt * acceleration(2)];
            theta(time + 1, :, batch) = next.';
            hand(time + 1, :, batch) = hand_state(next.', model.arm);
        end
    end
end

function state = hand_state(theta, arm)
    q1 = theta(1); dq1 = theta(2); q2 = theta(3); dq2 = theta(4);
    angle = q1 + q2;
    speed = dq1 + dq2;
    x = arm.L1 * cos(q1) + arm.L2 * cos(angle);
    y = arm.L1 * sin(q1) + arm.L2 * sin(angle);
    dx = -arm.L1 * dq1 * sin(q1) - arm.L2 * speed * sin(angle);
    dy = arm.L1 * dq1 * cos(q1) + arm.L2 * speed * cos(angle);
    state = [x, dx, y, dy];
end
