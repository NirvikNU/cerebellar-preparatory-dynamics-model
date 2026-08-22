function noise = sample_v2_noise(task, params, noisy, stream, useGpu)
    initial = zeros(params.model.numCorticalUnits, task.numTrials, 'single');
    dynamic = zeros(1, 1, 'single');
    if noisy
        initial = randn(stream, size(initial), 'single');
        dynamic = randn(stream, params.model.numCorticalUnits, ...
            task.numTrials, task.numTimeSteps - 1, 'single');
    end
    if useGpu
        initial = gpuArray(initial);
        dynamic = gpuArray(dynamic);
    end
    noise.initial = dlarray(initial);
    noise.dynamic = dlarray(dynamic);
    noise.enabled = noisy;
end
