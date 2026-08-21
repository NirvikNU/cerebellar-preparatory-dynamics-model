function simulation = simulate_intact_model(model, task, params, ...
        randomSeed, includeNoise)
    rng(randomSeed, 'twister');

    numUnits = params.model.numCorticalUnits;
    numTrials = task.numTrials;
    numTimeSteps = task.numTimeSteps;
    integrationFraction = single(params.model.dtMs / params.model.tauMs);
    dynamicNoiseScale = single(sqrt(params.model.tauMs / ...
        params.model.dtMs));

    state = single(params.model.initialStateBaseline) * ...
        ones(numUnits, numTrials, 'single');
    if includeNoise
        state = state + params.noise.sigmaInitial * ...
            randn(numUnits, numTrials, 'single');
    end
    jointAngles = repmat(single(params.plant.initialJointAnglesRad), ...
        1, numTrials);
    jointVelocity = repmat(single( ...
        params.plant.initialJointVelocityRadPerSec), 1, numTrials);

    stateHistory = zeros(numUnits, numTrials, numTimeSteps, 'single');
    rateHistory = zeros(numUnits, numTrials, numTimeSteps, 'single');
    rawTorqueHistory = zeros(2, numTrials, numTimeSteps, 'single');
    appliedTorqueHistory = zeros(2, numTrials, numTimeSteps, 'single');
    jointAngleHistory = zeros(2, numTrials, numTimeSteps, 'single');
    jointVelocityHistory = zeros(2, numTrials, numTimeSteps, 'single');
    positionHistory = zeros(2, numTrials, numTimeSteps, 'single');
    velocityHistory = zeros(2, numTrials, numTimeSteps, 'single');
    latentHistory = zeros(params.model.cerebellarRank, numTrials, ...
        numTimeSteps, 'single');
    jointContactHistory = false(2, numTrials, numTimeSteps);
    torqueSaturationHistory = false(2, numTrials, numTimeSteps);

    lowerLimits = single(params.plant.jointLowerLimitsRad);
    upperLimits = single(params.plant.jointUpperLimitsRad);
    contactTolerance = single(1e-6);

    for timeIndex = 1:numTimeSteps
        rates = tanh(state);
        rawTorque = model.Wout * rates;
        appliedTorque = apply_arm_torque_safety(rawTorque, params.plant);
        handPosition = arm_forward_kinematics(jointAngles, params.plant);
        handVelocity = arm_endpoint_velocity( ...
            jointAngles, jointVelocity, params.plant);
        cerebellarLatent = generate_cerebellar_latent(model, ...
            task.cerebellarGeneratorInput(:, :, timeIndex));

        stateHistory(:, :, timeIndex) = state;
        rateHistory(:, :, timeIndex) = rates;
        rawTorqueHistory(:, :, timeIndex) = rawTorque;
        appliedTorqueHistory(:, :, timeIndex) = appliedTorque;
        jointAngleHistory(:, :, timeIndex) = jointAngles;
        jointVelocityHistory(:, :, timeIndex) = jointVelocity;
        positionHistory(:, :, timeIndex) = handPosition;
        velocityHistory(:, :, timeIndex) = handVelocity;
        latentHistory(:, :, timeIndex) = cerebellarLatent;
        jointContactHistory(:, :, timeIndex) = ...
            abs(jointAngles - lowerLimits) <= contactTolerance | ...
            abs(jointAngles - upperLimits) <= contactTolerance;
        if params.plant.useHardSafetyClipping
            torqueSaturationHistory(:, :, timeIndex) = ...
                abs(rawTorque) >= params.plant.hardTorqueSafetyLimitNm;
        end

        if timeIndex < numTimeSteps
            if includeNoise
                dynamicNoise = params.noise.sigmaDynamic * ...
                    dynamicNoiseScale * ...
                    randn(numUnits, numTrials, 'single');
            else
                dynamicNoise = zeros(numUnits, numTrials, 'single');
            end
            stateDerivative = -state + model.Wrec * rates + ...
                model.Wtarg * task.targetInput + ...
                model.Wgo * task.goSignal(:, timeIndex)' + ...
                model.Ucb * cerebellarLatent + dynamicNoise;
            state = state + integrationFraction * stateDerivative;
            [jointAngles, jointVelocity] = two_link_arm_step( ...
                jointAngles, jointVelocity, rawTorque, task.dtSeconds, ...
                params.plant);
        end
    end

    simulation.state = stateHistory;
    simulation.rates = rateHistory;
    simulation.rawTorque = rawTorqueHistory;
    simulation.appliedTorque = appliedTorqueHistory;
    simulation.jointAngles = jointAngleHistory;
    simulation.jointVelocity = jointVelocityHistory;
    simulation.position = positionHistory;
    simulation.velocity = velocityHistory;
    simulation.cerebellarLatent = latentHistory;
    simulation.jointLimitContact = jointContactHistory;
    simulation.torqueSaturation = torqueSaturationHistory;
    simulation.targetIndex = task.targetIndex;
    simulation.randomSeed = randomSeed;
    simulation.includeNoise = includeNoise;
end
