function output = simulate_stage2b_preparation(model, controller, maximumDurationS, options)
    arguments
        model
        controller
        maximumDurationS (1, 1) double {mustBeNonnegative}
        options.InitialStates double = []
        options.TargetIndex double = []
        options.PerturbationTimeS double = []
        options.Perturbations double = []
        options.StoreControl (1, 1) logical = true
    end
    nTargets = model.nMovements;
    if isempty(options.InitialStates)
        x = repmat(model.spontaneous, 1, nTargets);
        targetIndex = 1:nTargets;
    else
        x = options.InitialStates;
        nTrials = size(x, 2);
        if isempty(options.TargetIndex)
            assert(mod(nTrials, nTargets) == 0);
            targetIndex = repmat(1:nTargets, 1, nTrials / nTargets);
        else
            targetIndex = options.TargetIndex(:).';
            assert(numel(targetIndex) == nTrials);
            assert(all(targetIndex >= 1 & targetIndex <= nTargets));
        end
    end
    nTrials = size(x, 2);
    sampleEvery = round(model.samplingDt / model.dt);
    nSteps = round(maximumDurationS / model.dt);
    nSamples = nSteps / sampleEvery + 1;
    assert(mod(nSteps, sampleEvery) == 0);
    states = zeros(nSamples, model.n, nTrials);
    states(1, :, :) = permute(x, [3, 1, 2]);
    if options.StoreControl
        controlDeviation = zeros(nSamples, model.n, nTrials);
        totalPreparatoryInput = zeros(nSamples, model.n, nTrials);
    else
        controlDeviation = [];
        totalPreparatoryInput = [];
    end
    targetRates = max(model.xstar(:, targetIndex), 0);
    targetInput = controller.targetInput(:, targetIndex);
    perturbStep = round(options.PerturbationTimeS / model.dt);
    sample = 1;
    for step = 1:nSteps
        if ~isempty(perturbStep) && any(step == perturbStep)
            which = find(step == perturbStep, 1, 'first');
            x = x + options.Perturbations(:, :, which);
        end
        rates = max(x, 0);
        feedback = controller.effectiveFeedback * (rates - targetRates);
        x = x + (model.dt / model.tau) * (-x + model.W * rates ...
            + model.h + targetInput + controller.effectiveFeedback * targetRates);
        x = x + (model.dt / model.tau) * feedback;
        if mod(step, sampleEvery) == 0
            sample = sample + 1;
            states(sample, :, :) = permute(x, [3, 1, 2]);
            if options.StoreControl
                controlDeviation(sample, :, :) = permute(feedback, [3, 1, 2]);
                totalPreparatoryInput(sample, :, :) = permute(...
                    targetInput + controller.effectiveFeedback * targetRates ...
                    + feedback, [3, 1, 2]);
            end
        end
    end
    output.timesS = (0:(nSamples - 1)).' * model.samplingDt;
    output.states = states;
    output.finalState = x;
    output.initialState = squeeze(states(1, :, :)).';
    output.controlDeviation = controlDeviation;
    output.totalPreparatoryInput = totalPreparatoryInput;
    output.targetIndex = targetIndex;
end
