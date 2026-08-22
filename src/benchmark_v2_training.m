function benchmark = benchmark_v2_training(initialModel, params)
    gpu = select_required_gpu(params.model.requiredGpuName);
    model = move_v2_model(initialModel, true);
    stream = RandStream('mt19937ar', 'Seed', params.seed.trainingTask + 900);
    task = sample_balanced_v2_task(params, ...
        params.training.trialsPerTarget, stream);
    deviceTask = prepare_v2_gradient_task(task, true);
    noise = sample_v2_noise(task, params, false, stream, true);
    accelerated = dlaccelerate(@v2_model_gradients);

    dlfeval(@v2_model_gradients, model, deviceTask, params, noise);
    dlfeval(accelerated, model, deviceTask, params, noise);
    wait(gpuDevice);
    ordinarySeconds = time_gradients(@v2_model_gradients, model, ...
        deviceTask, params, noise, params.training.benchmarkRepetitions);
    memoryBeforeAccelerated = gpu.TotalMemory - gpu.AvailableMemory;
    acceleratedSeconds = time_gradients(accelerated, model, ...
        deviceTask, params, noise, params.training.benchmarkRepetitions);
    refreshedGpu = gpuDevice;
    memoryAfterAccelerated = refreshedGpu.TotalMemory - ...
        refreshedGpu.AvailableMemory;
    memoryGrowth = memoryAfterAccelerated - memoryBeforeAccelerated;
    useAccelerated = acceleratedSeconds < ordinarySeconds && ...
        memoryGrowth < 1024^3;
    if useAccelerated
        gradientFunction = accelerated;
    else
        gradientFunction = @v2_model_gradients;
    end

    [~, optimizerLayout] = pack_v2_trainables(model);
    optimizerMultiplier = v2_optimizer_multiplier_vector( ...
        optimizerLayout, params, true);
    average = [];
    averageSquared = [];
    losses = nan(params.training.benchmarkUpdates, 1);
    startTime = tic;
    for iteration = 1:params.training.benchmarkUpdates
        task = sample_balanced_v2_task(params, ...
            params.training.trialsPerTarget, stream);
        deviceTask = prepare_v2_gradient_task(task, true);
        noise = sample_v2_noise(task, params, false, stream, true);
        [loss, gradients] = dlfeval(gradientFunction, model, ...
            deviceTask, params, noise);
        gradientVector = pack_v2_trainables(gradients);
        gradientVector = clip_gradient_vector(gradientVector, ...
            params.training.gradientThreshold);
        parameterVector = pack_v2_trainables(model);
        [candidateVector, average, averageSquared] = adamupdate( ...
            parameterVector, gradientVector, average, averageSquared, ...
            iteration, params.training.stageALearnRate, ...
            params.training.gradientDecayFactor, ...
            params.training.squaredGradientDecayFactor, ...
            params.training.adamEpsilon);
        parameterVector = parameterVector + optimizerMultiplier .* ...
            (candidateVector - parameterVector);
        model = unpack_v2_trainables(model, parameterVector, optimizerLayout);
        losses(iteration) = double(gather(extractdata(loss)));
    end
    wait(gpuDevice);
    elapsed = toc(startTime);
    refreshedGpu = gpuDevice;
    memoryAfterUpdates = refreshedGpu.TotalMemory - ...
        refreshedGpu.AvailableMemory;
    benchmark.gpuName = gpu.Name;
    benchmark.ordinaryGradientSeconds = ordinarySeconds;
    benchmark.acceleratedGradientSeconds = acceleratedSeconds;
    benchmark.acceleratedMemoryGrowthBytes = memoryGrowth;
    benchmark.useAccelerated = useAccelerated;
    benchmark.updates = params.training.benchmarkUpdates;
    benchmark.elapsedSeconds = elapsed;
    benchmark.secondsPerUpdate = elapsed / params.training.benchmarkUpdates;
    benchmark.estimatedSecondsFor1000Updates = ...
        1000 * benchmark.secondsPerUpdate;
    benchmark.estimatedSecondsFor3000Updates = ...
        3000 * benchmark.secondsPerUpdate;
    benchmark.gpuMemoryUsedAfterUpdatesBytes = memoryAfterUpdates;
    benchmark.firstLoss = losses(1);
    benchmark.finalLoss = losses(end);
end

function seconds = time_gradients(functionHandle, model, task, params, ...
        noise, repetitions)
    startTime = tic;
    for repetition = 1:repetitions
        dlfeval(functionHandle, model, task, params, noise);
    end
    wait(gpuDevice);
    seconds = toc(startTime) / repetitions;
end
