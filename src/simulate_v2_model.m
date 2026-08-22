function simulation = simulate_v2_model(model, task, params, seed, noisy)
    rng(seed, 'twister');
    n = params.model.numCorticalUnits;
    state = repmat(single(model.baselineRates), 1, task.numTrials);
    if noisy
        state = state + params.noise.sigmaInitialHz * ...
            randn(n, task.numTrials, 'single');
    end
    position = zeros(2, task.numTrials, 'single');
    integrationFraction = single(params.model.dtMs / params.model.tauMs);
    dynamicScale = single(sqrt(params.model.tauMs / params.model.dtMs));
    cTarget = model.WcbLatent * tanh(model.WcbHidden * task.targetInput + ...
        model.bcbHidden) + model.bcbLatent;
    nTimes = task.numTimeSteps;
    simulation.rates = zeros(n, task.numTrials, nTimes, 'single');
    simulation.position = zeros(2, task.numTrials, nTimes, 'single');
    simulation.velocity = zeros(2, task.numTrials, nTimes, 'single');
    simulation.cerebellarLatent = zeros(params.model.cerebellarRank, ...
        task.numTrials, nTimes, 'single');
    simulation.driveNorms = zeros(4, task.numTrials, nTimes, 'single');
    for timeIndex = 1:nTimes
        rates = max(state, 0);
        velocity = model.Wout * rates;
        latent = cTarget .* task.relaxationScale(timeIndex);
        simulation.rates(:, :, timeIndex) = rates;
        simulation.position(:, :, timeIndex) = position;
        simulation.velocity(:, :, timeIndex) = velocity;
        simulation.cerebellarLatent(:, :, timeIndex) = latent;
        drives = {model.Wtarg * task.targetInput, ...
            model.Wgo * task.goSignal(:, timeIndex)', model.Ucb * latent, ...
            model.Wrec * rates};
        for driveIndex = 1:4
            simulation.driveNorms(driveIndex, :, timeIndex) = ...
                sqrt(sum(drives{driveIndex}.^2, 1));
        end
        if timeIndex < nTimes
            dynamicNoise = zeros(n, task.numTrials, 'single');
            if noisy
                dynamicNoise = params.noise.sigmaDynamicHz * ...
                    dynamicScale * randn(n, task.numTrials, 'single');
            end
            state = state + integrationFraction * (-state + ...
                model.Wrec * rates + model.baselineDrive + ...
                model.Wtarg * task.targetInput + ...
                model.Wgo * task.goSignal(:, timeIndex)' + ...
                model.Ucb * latent + dynamicNoise);
            position = position + task.dtSeconds * velocity;
        end
    end
    simulation.targetIndex = task.targetIndex;
    simulation.noisy = noisy;
end
