function output = simulate_naive_preparation(model, tonicInput, maximumDurationS)
    assert(size(tonicInput, 1) == model.n);
    batchSize = size(tonicInput, 2);
    sampleEvery = round(model.samplingDt / model.dt);
    nInternalSteps = round(maximumDurationS / model.dt);
    nSamples = round(maximumDurationS / model.samplingDt) + 1;
    assert(abs(nInternalSteps * model.dt - maximumDurationS) < eps(maximumDurationS));
    assert(mod(nInternalSteps, sampleEvery) == 0);
    x = repmat(model.spontaneous, 1, batchSize);
    states = zeros(nSamples, model.n, batchSize);
    states(1, :, :) = permute(x, [3, 1, 2]);
    sample = 1;
    for step = 1:nInternalSteps
        rates = max(x, 0);
        x = x + (model.dt / model.tau) * ...
            (-x + model.W * rates + model.h + tonicInput);
        if mod(step, sampleEvery) == 0
            sample = sample + 1;
            states(sample, :, :) = permute(x, [3, 1, 2]);
        end
    end
    assert(sample == nSamples);
    output.timesS = (0:(nSamples - 1)).' * model.samplingDt;
    output.states = states;
    output.finalState = x;
    output.initialState = repmat(model.spontaneous, 1, batchSize);
end
