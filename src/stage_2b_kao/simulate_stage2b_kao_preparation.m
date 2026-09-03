function output = simulate_stage2b_kao_preparation(model, controller, durationS, options)
    arguments
        model
        controller
        durationS (1, 1) double {mustBeNonnegative}
        options.InitialStates double = []
        options.TargetIndex double = []
        options.StoreControl (1, 1) logical = true
    end
    if isempty(options.InitialStates)
        x = repmat(model.spontaneous, 1, model.nMovements);
        targetIndex = 1:model.nMovements;
    else
        x = options.InitialStates;
        if isempty(options.TargetIndex)
            assert(mod(size(x, 2), model.nMovements) == 0);
            targetIndex = repmat(1:model.nMovements, ...
                1, size(x, 2) / model.nMovements);
        else
            targetIndex = options.TargetIndex(:).';
        end
    end
    assert(numel(targetIndex) == size(x, 2));
    sampleEvery = round(model.samplingDt / model.dt);
    nSteps = round(durationS / model.dt);
    assert(mod(nSteps, sampleEvery) == 0);
    nSamples = nSteps / sampleEvery + 1;
    states = zeros(nSamples, model.n, size(x, 2));
    states(1, :, :) = permute(x, [3, 1, 2]);
    if options.StoreControl
        feedback = zeros(nSamples, model.n, size(x, 2));
    else
        feedback = [];
    end
    targetRates = max(model.xstar(:, targetIndex), 0);
    tonic = controller.tonicInput(:, targetIndex);
    if options.StoreControl
        initialFeedback = controller.effectiveFeedback * ...
            (max(x, 0) - targetRates);
        feedback(1, :, :) = permute(initialFeedback, [3, 1, 2]);
    end
    sample = 1;
    for step = 1:nSteps
        rates = max(x, 0);
        currentFeedback = controller.effectiveFeedback * ...
            (rates - targetRates);
        x = x + (model.dt / model.tau) * (-x + model.W * rates ...
            + model.h + tonic + currentFeedback);
        if mod(step, sampleEvery) == 0
            sample = sample + 1;
            states(sample, :, :) = permute(x, [3, 1, 2]);
            if options.StoreControl
                feedback(sample, :, :) = permute(currentFeedback, [3, 1, 2]);
            end
        end
    end
    output.timesS = (0:(nSamples - 1)).' * model.samplingDt;
    output.states = states;
    output.finalState = x;
    output.feedback = feedback;
    output.targetIndex = targetIndex;
end
