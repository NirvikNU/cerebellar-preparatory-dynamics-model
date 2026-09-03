function target = source_target_hand_trajectories(cfg, arm)
    angles = cfg.gate1.targetAnglesDeg;
    dt = cfg.gate1.targetDtS;
    nSamples = round(cfg.gate1.targetDurationS / dt);
    theta1 = arm.theta1;
    theta2 = acos(-arm.L1 * cos(theta1) / arm.L2) - theta1;
    initial = hand_state([theta1, 0, theta2, 0], arm);
    peakSpeed = source_peak_speed(cfg.gate1.radiusM, dt, nSamples);
    hands = zeros(nSamples, 4, numel(angles));
    for movement = 1:numel(angles)
        angle = deg2rad(angles(movement));
        state = initial;
        for sample = 1:nSamples
            hands(sample, :, movement) = state;
            time = dt * (sample - 1);
            radialSpeed = peakSpeed * speed_profile(time);
            previous = state;
            state = [previous(1) + dt * previous(2), ...
                cos(angle) * radialSpeed, ...
                previous(3) + dt * previous(4), ...
                sin(angle) * radialSpeed];
        end
    end
    endpoints = squeeze(hands(end, [1, 3], :)).';
    displacement = endpoints - initial([1, 3]);
    target = struct('hands', hands, 'anglesDeg', angles, ...
        'labels', cfg.gate1.targetLabels, 'peakSpeed', peakSpeed, ...
        'initialHand', initial, 'endpointDisplacement', displacement, ...
        'endpointRadiusM', vecnorm(displacement, 2, 2), ...
        'endpointAngleDeg', mod(atan2d(displacement(:, 2), displacement(:, 1)), 360));
end

function peak = source_peak_speed(radius, dt, nSamples)
    lower = 0;
    upper = 3;
    while abs(lower - upper) >= 1e-4
        middle = (lower + upper) / 2;
        position = [0, 0];
        velocity = [0, 0];
        for sample = 1:nSamples
            time = dt * (sample - 1);
            radialSpeed = middle * speed_profile(time);
            if sample < nSamples
                position = position + dt * velocity;
                velocity = [radialSpeed, 0];
            end
        end
        achieved = norm(position);
        if achieved < radius
            lower = middle;
        else
            upper = middle;
        end
    end
    peak = (lower + upper) / 2;
end

function value = speed_profile(time)
    tauReach = 0.140;
    bell = @(t) (t / tauReach).^2 .* exp(-(t / tauReach).^2 / 2);
    value = bell(time) / bell(tauReach * sqrt(2));
end

function state = hand_state(theta, arm)
    q1 = theta(1); dq1 = theta(2); q2 = theta(3); dq2 = theta(4);
    angle = q1 + q2;
    speed = dq1 + dq2;
    state = [arm.L1 * cos(q1) + arm.L2 * cos(angle), ...
        -arm.L1 * dq1 * sin(q1) - arm.L2 * speed * sin(angle), ...
        arm.L1 * sin(q1) + arm.L2 * sin(angle), ...
        arm.L1 * dq1 * cos(q1) + arm.L2 * speed * cos(angle)];
end
