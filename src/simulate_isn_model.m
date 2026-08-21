function simulation = simulate_isn_model(model, task, params, seed, noisy)
    rng(seed, 'twister');
    n = params.model.numCorticalUnits;
    state = repmat(single(model.baselineRates), 1, task.numTrials);
    if noisy
        state = state + params.noise.sigmaInitialHz * ...
            randn(n, task.numTrials, 'single');
    end
    angles = repmat(single(params.plant.initialJointAnglesRad), ...
        1, task.numTrials);
    velocity = repmat(single(params.plant.initialJointVelocityRadPerSec), ...
        1, task.numTrials);
    integrationFraction = single(params.model.dtMs / params.model.tauMs);
    dynamicScale = single(sqrt(params.model.tauMs / params.model.dtMs));
    cInf = model.WcbLatent * tanh(model.WcbHidden * task.targetInput + ...
        model.bcbHidden) + model.bcbLatent;
    simulation.rates = zeros(n, task.numTrials, task.numTimeSteps, 'single');
    simulation.position = zeros(2, task.numTrials, task.numTimeSteps, 'single');
    simulation.velocity = zeros(2, task.numTrials, task.numTimeSteps, 'single');
    simulation.jointAngles = zeros(2, task.numTrials, task.numTimeSteps, 'single');
    simulation.jointVelocity = zeros(2, task.numTrials, task.numTimeSteps, 'single');
    simulation.rawTorque = zeros(2, task.numTrials, task.numTimeSteps, 'single');
    simulation.appliedTorque = simulation.rawTorque;
    simulation.jointLimitContact = false(2, task.numTrials, task.numTimeSteps);
    simulation.torqueSaturation = false(2, task.numTrials, task.numTimeSteps);
    simulation.cerebellarLatent = zeros(5, task.numTrials, task.numTimeSteps, 'single');
    simulation.driveNorms = zeros(4, task.numTrials, task.numTimeSteps, 'single');
    for timeIndex = 1:task.numTimeSteps
        rates = max(state, 0);
        torque = model.Wout * rates;
        latent = cInf .* task.relaxationScale(timeIndex);
        simulation.rates(:, :, timeIndex) = rates;
        simulation.position(:, :, timeIndex) = ...
            arm_forward_kinematics(angles, params.plant);
        simulation.velocity(:, :, timeIndex) = ...
            arm_endpoint_velocity(angles, velocity, params.plant);
        simulation.jointAngles(:, :, timeIndex) = angles;
        simulation.jointVelocity(:, :, timeIndex) = velocity;
        simulation.rawTorque(:, :, timeIndex) = torque;
        simulation.appliedTorque(:, :, timeIndex) = ...
            apply_arm_torque_safety(torque, params.plant);
        simulation.jointLimitContact(:, :, timeIndex) = ...
            abs(angles - single(params.plant.jointLowerLimitsRad)) <= 1e-6 | ...
            abs(angles - single(params.plant.jointUpperLimitsRad)) <= 1e-6;
        simulation.torqueSaturation(:, :, timeIndex) = ...
            abs(torque) >= single(params.plant.hardTorqueSafetyLimitNm);
        simulation.cerebellarLatent(:, :, timeIndex) = latent;
        drives = {model.Wtarg * task.targetInput, ...
            model.Wgo * task.goSignal(:, timeIndex)', model.Ucb * latent, ...
            model.Wrec * rates};
        for driveIndex = 1:4
            simulation.driveNorms(driveIndex, :, timeIndex) = ...
                sqrt(sum(drives{driveIndex}.^2, 1));
        end
        if timeIndex < task.numTimeSteps
            noise = zeros(n, task.numTrials, 'single');
            if noisy
                noise = params.noise.sigmaDynamicHz * dynamicScale * ...
                    randn(n, task.numTrials, 'single');
            end
            state = state + integrationFraction * (-state + ...
                model.Wrec * rates + model.baselineDrive + ...
                model.Wtarg * task.targetInput + ...
                model.Wgo * task.goSignal(:, timeIndex)' + ...
                model.Ucb * latent + noise);
            [angles, velocity] = two_link_arm_step(angles, velocity, ...
                torque, task.dtSeconds, params.plant);
        end
    end
    simulation.targetIndex = task.targetIndex;
end
