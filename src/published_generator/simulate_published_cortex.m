function output = simulate_published_cortex(model, initialState, storeRates)
    if nargin < 3
        storeRates = true;
    end
    x = initialState;
    batchSize = size(x, 2);
    sampleEvery = round(model.samplingDt / model.dt);
    if storeRates
        rates = zeros(model.nSamples, model.n, batchSize);
    else
        rates = [];
    end
    torque = zeros(model.nSamples, 2, batchSize);
    sample = 0;
    for step = 0:(model.nInternalSteps - 1)
        r = max(x, 0);
        if mod(step, sampleEvery) == 0
            sample = sample + 1;
            if storeRates
                rates(sample, :, :) = permute(r, [3, 1, 2]);
            end
            torque(sample, :, :) = permute(model.C * r, [3, 1, 2]);
        end
        time = model.dt * step;
        drive = published_movement_input(time, model);
        x = x + (model.dt / model.tau) * ...
            (-x + model.W * r + model.h + drive);
    end
    assert(sample == model.nSamples, 'Unexpected number of saved samples.');
    output.rates = rates;
    output.torque = torque;
    output.finalState = x;
end
