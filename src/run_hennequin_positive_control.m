function result = run_hennequin_positive_control(params, fixed, projectRoot)
    task = build_isn_reach_task(params, 1, ...
        params.task.canonicalGoTimeMs, []);
    basis = temporal_basis(task.timeMs, params.positiveControl);
    design = control_design(basis, task.targetInput);
    useGpu = params.training.useGpuIfAvailable && canUseGPU;
    if useGpu
        select_required_gpu(params.model.requiredGpuName);
    end
    rng(params.seed.positiveControl, 'twister');
    n = params.model.numCorticalUnits;
    parameter.control = dlarray(single(0.01 * randn(n, ...
        size(design, 1)) / sqrt(size(design, 1))));
    parameter.Wout = dlarray(single(1e-4 * randn(2, n) / sqrt(n)));
    fixedDevice.Wrec = dlarray(move(fixed.Wrec, useGpu));
    fixedDevice.baselineRates = dlarray(move(fixed.baselineRates, useGpu));
    fixedDevice.baselineDrive = dlarray(move(fixed.baselineDrive, useGpu));
    parameter.control = dlarray(move(extractdata(parameter.control), useGpu));
    parameter.Wout = dlarray(move(extractdata(parameter.Wout), useGpu));
    taskDevice = prepare_positive_task(task, design, params, useGpu);
    deviceParams = move_plant(params, useGpu);
    average = struct('control', [], 'Wout', []);
    averageSquared = struct('control', [], 'Wout', []);
    bestLoss = inf;
    best = [];
    history.loss = nan(params.positiveControl.maxIterations, 1);
    for iteration = 1:params.positiveControl.maxIterations
        [loss, gradients] = dlfeval(@positive_gradients, parameter, ...
            fixedDevice, taskDevice, deviceParams);
        gradients = clip_gradient_struct(gradients, ...
            params.positiveControl.gradientThreshold);
        names = {'control', 'Wout'};
        for fieldIndex = 1:numel(names)
            name = names{fieldIndex};
            if strcmp(name, 'control')
                learnRate = params.positiveControl.controlLearnRate;
            else
                learnRate = params.positiveControl.readoutLearnRate;
            end
            [parameter.(name), average.(name), averageSquared.(name)] = ...
                adamupdate(parameter.(name), gradients.(name), ...
                average.(name), averageSquared.(name), iteration, ...
                learnRate, ...
                params.training.gradientDecayFactor, ...
                params.training.squaredGradientDecayFactor, ...
                params.training.adamEpsilon);
        end
        history.loss(iteration) = scalar(loss);
        if history.loss(iteration) < bestLoss
            bestLoss = history.loss(iteration);
            best.control = gather(extractdata(parameter.control));
            best.Wout = gather(extractdata(parameter.Wout));
        end
        if iteration == 1 || mod(iteration, 50) == 0
            fprintf('Positive control %d/%d loss %.6f\n', iteration, ...
                params.positiveControl.maxIterations, history.loss(iteration));
        end
    end
    simulation = simulate_control(best, fixed, task, design, params);
    metrics = control_metrics(simulation, task, params);
    result.parameters = best;
    result.history = history;
    result.metrics = metrics;
    result.passed = metrics.meanEndpointErrorM <= ...
        params.validation.maxMeanEndpointErrorM && ...
        metrics.maximumEndpointErrorM <= ...
        params.validation.maxTargetAveragedEndpointErrorM && ...
        metrics.terminalSpeedMPerSec <= ...
        params.validation.maxTerminalSpeedMPerSec && ...
        metrics.preGoRmsSpeedMPerSec <= ...
        params.validation.maxDeterministicPreGoRmsSpeedMPerSec;
    outputRoot = params.files.positiveControlRoot;
    if isempty(regexp(outputRoot, '^[A-Za-z]:[\\/]', 'once')) && ...
            ~startsWith(outputRoot, filesep)
        outputRoot = fullfile(projectRoot, outputRoot);
    end
    if ~isfolder(outputRoot)
        mkdir(outputRoot);
    end
    save(fullfile(outputRoot, 'positive_control.mat'), 'result', ...
        'params', '-v7.3');
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

function taskOut = prepare_positive_task(task, design, params, useGpu)
    taskOut = prepare_isn_gradient_task(task, params, useGpu);
    taskOut.controlDesign = dlarray(move(design, useGpu));
end

function [loss, gradients] = positive_gradients(parameter, fixed, task, params)
    loss = positive_loss(parameter, fixed, task, params);
    [gradients.control, gradients.Wout] = dlgradient(loss, ...
        parameter.control, parameter.Wout);
end

function loss = positive_loss(parameter, fixed, task, params)
    state = repmat(fixed.baselineRates, 1, task.numTrials);
    angles = task.initialJointAngles;
    velocity = task.initialJointVelocity;
    fraction = single(params.model.dtMs / params.model.tauMs);
    prePosition = sum(state(1) * 0);
    preVelocity = prePosition;
    endpoint = prePosition;
    terminalPosition = prePosition;
    terminalVelocity = prePosition;
    holdPosition = prePosition;
    holdVelocity = prePosition;
    effort = prePosition;
    for timeIndex = 1:task.numTimeSteps
        rates = max(state, 0);
        torque = parameter.Wout * rates;
        hand = arm_forward_kinematics(angles, params.plant);
        handVelocity = arm_endpoint_velocity(angles, velocity, params.plant);
        centerError = (hand - task.centerPosition) / ...
            single(params.task.targetRadiusM);
        targetError = (hand - task.trialTargetPositions) / ...
            single(params.task.targetRadiusM);
        speed = sum((handVelocity / 0.25).^2, 1);
        pre = task.preGoMask(:, timeIndex)';
        terminal = task.terminalMask(:, timeIndex)';
        hold = task.holdMask(:, timeIndex)';
        prePosition = prePosition + sum(sum(centerError.^2, 1) .* pre, 'all');
        preVelocity = preVelocity + sum(speed .* pre, 'all');
        endpoint = endpoint + sum(sum(targetError.^2, 1) .* ...
            task.endpointUrgency(:, timeIndex)', 'all');
        terminalPosition = terminalPosition + ...
            sum(sum(targetError.^2, 1) .* terminal, 'all');
        terminalVelocity = terminalVelocity + sum(speed .* terminal, 'all');
        holdPosition = holdPosition + sum(sum(targetError.^2, 1) .* hold, 'all');
        holdVelocity = holdVelocity + sum(speed .* hold, 'all');
        input = parameter.control * task.controlDesign(:, :, timeIndex);
        effort = effort + sum(input.^2, 'all');
        if timeIndex < task.numTimeSteps
            state = state + fraction * (-state + fixed.Wrec * rates + ...
                fixed.baselineDrive + input);
            [angles, velocity] = two_link_arm_step(angles, velocity, ...
                torque, task.dtSeconds, params.plant);
        end
    end
    w = params.training;
    loss = w.preGoPositionLossWeight * prePosition / sum(task.preGoMask, 'all') + ...
        w.preGoVelocityLossWeight * preVelocity / sum(task.preGoMask, 'all') + ...
        w.endpointUrgencyLossWeight * endpoint / sum(task.endpointUrgency, 'all') + ...
        w.terminalPositionLossWeight * terminalPosition / sum(task.terminalMask, 'all') + ...
        w.terminalVelocityLossWeight * terminalVelocity / sum(task.terminalMask, 'all') + ...
        w.holdPositionLossWeight * holdPosition / sum(task.holdMask, 'all') + ...
        w.holdVelocityLossWeight * holdVelocity / sum(task.holdMask, 'all') + ...
        params.positiveControl.controlEffortWeight * effort / ...
        single(task.numTrials * task.numTimeSteps * ...
        params.model.numCorticalUnits);
end

function simulation = simulate_control(parameter, fixed, task, design, params)
    state = repmat(fixed.baselineRates, 1, task.numTrials);
    angles = repmat(single(params.plant.initialJointAnglesRad), 1, task.numTrials);
    velocity = zeros(2, task.numTrials, 'single');
    fraction = single(params.model.dtMs / params.model.tauMs);
    simulation.position = zeros(2, task.numTrials, task.numTimeSteps, 'single');
    simulation.velocity = simulation.position;
    for timeIndex = 1:task.numTimeSteps
        rates = max(state, 0);
        torque = parameter.Wout * rates;
        simulation.position(:, :, timeIndex) = ...
            arm_forward_kinematics(angles, params.plant);
        simulation.velocity(:, :, timeIndex) = ...
            arm_endpoint_velocity(angles, velocity, params.plant);
        input = parameter.control * design(:, :, timeIndex);
        if timeIndex < task.numTimeSteps
            state = state + fraction * (-state + fixed.Wrec * rates + ...
                fixed.baselineDrive + input);
            [angles, velocity] = two_link_arm_step(angles, velocity, ...
                torque, task.dtSeconds, params.plant);
        end
    end
end

function metrics = control_metrics(simulation, task, ~)
    speed = reshape(sqrt(sum(simulation.velocity.^2, 1)), ...
        task.numTrials, task.numTimeSteps);
    errors = zeros(1, task.numTrials);
    terminalSpeed = errors;
    for trialIndex = 1:task.numTrials
        index = task.movementEndIndexByTrial(trialIndex);
        errors(trialIndex) = norm(double(simulation.position( ...
            :, trialIndex, index) - task.trialTargetPositions(:, trialIndex)));
        terminalSpeed(trialIndex) = speed(trialIndex, index);
    end
    metrics.meanEndpointErrorM = mean(errors);
    metrics.maximumEndpointErrorM = max(errors);
    metrics.terminalSpeedMPerSec = mean(terminalSpeed);
    metrics.preGoRmsSpeedMPerSec = sqrt(mean(double( ...
        speed(logical(task.preGoMask))).^2));
end

function value = move(value, useGpu)
    value = single(value);
    if useGpu
        value = gpuArray(value);
    end
end

function params = move_plant(params, useGpu)
    if ~useGpu
        return;
    end
    names = fieldnames(params.plant);
    for fieldIndex = 1:numel(names)
        name = names{fieldIndex};
        if isnumeric(params.plant.(name))
            params.plant.(name) = gpuArray(single(params.plant.(name)));
        end
    end
end

function value = scalar(input)
    value = double(gather(extractdata(input)));
end
