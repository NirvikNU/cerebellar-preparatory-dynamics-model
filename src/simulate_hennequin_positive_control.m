function simulation = simulate_hennequin_positive_control( ...
        parameter, fixed, task, params)
    basis = temporal_basis(task.timeMs, params.positiveControl);
    design = control_design(basis, task.targetInput);
    state = repmat(fixed.baselineRates, 1, task.numTrials);
    angles = repmat(single(params.plant.initialJointAnglesRad), 1, task.numTrials);
    velocity = repmat(single(params.plant.initialJointVelocityRadPerSec), ...
        1, task.numTrials);
    fraction = single(params.model.dtMs / params.model.tauMs);
    nTimes = task.numTimeSteps;
    simulation.position = zeros(2, task.numTrials, nTimes, 'single');
    simulation.velocity = simulation.position;
    simulation.rates = zeros(params.model.numCorticalUnits, ...
        task.numTrials, nTimes, 'single');
    simulation.controlNorm = zeros(task.numTrials, nTimes, 'single');
    for timeIndex = 1:nTimes
        rates = max(state, 0);
        torque = parameter.Wout * rates;
        input = parameter.control * design(:, :, timeIndex);
        simulation.rates(:, :, timeIndex) = rates;
        simulation.position(:, :, timeIndex) = ...
            arm_forward_kinematics(angles, params.plant);
        simulation.velocity(:, :, timeIndex) = ...
            arm_endpoint_velocity(angles, velocity, params.plant);
        simulation.controlNorm(:, timeIndex) = sqrt(sum(input.^2, 1));
        if timeIndex < nTimes
            state = state + fraction * (-state + fixed.Wrec * rates + ...
                fixed.baselineDrive + input);
            [angles, velocity] = two_link_arm_step(angles, velocity, ...
                torque, task.dtSeconds, params.plant);
        end
    end
end

function basis = temporal_basis(timeMs, settings)
    centers = linspace(double(timeMs(1)), double(timeMs(end)), ...
        settings.numTemporalBasis);
    basis = exp(-0.5 * ((double(timeMs) - centers') / ...
        settings.basisWidthMs).^2);
    basis = single(basis ./ max(sum(basis, 1), eps));
end

function design = control_design(basis, targetInput)
    [numBasis, numTime] = size(basis);
    numTrials = size(targetInput, 2);
    design = zeros(numBasis * size(targetInput, 1), ...
        numTrials, numTime, 'single');
    for timeIndex = 1:numTime
        design(:, :, timeIndex) = kron(targetInput, basis(:, timeIndex));
    end
end
