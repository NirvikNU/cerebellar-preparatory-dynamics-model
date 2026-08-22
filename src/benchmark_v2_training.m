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

    fields = v2_trainable_fields();
    average = initialize_state(fields);
    averageSquared = initialize_state(fields);
    maximumMemory = memoryAfterAccelerated;
    losses = nan(params.training.benchmarkUpdates, 1);
    startTime = tic;
    for iteration = 1:params.training.benchmarkUpdates
        task = sample_balanced_v2_task(params, ...
            params.training.trialsPerTarget, stream);
        deviceTask = prepare_v2_gradient_task(task, true);
        noise = sample_v2_noise(task, params, false, stream, true);
        [loss, gradients] = dlfeval(gradientFunction, model, ...
            deviceTask, params, noise);
        gradients = clip_gradient_struct(gradients, ...
            params.training.gradientThreshold);
        for fieldIndex = 1:numel(fields)
            name = fields{fieldIndex};
            learnRate = params.training.stageALearnRate * ...
                params.training.learningRateMultipliers.(name);
            [model.(name), average.(name), averageSquared.(name)] = ...
                adamupdate(model.(name), gradients.(name), ...
                average.(name), averageSquared.(name), iteration, ...
                learnRate, params.training.gradientDecayFactor, ...
                params.training.squaredGradientDecayFactor, ...
                params.training.adamEpsilon);
        end
        losses(iteration) = double(gather(extractdata(loss)));
        refreshedGpu = gpuDevice;
        maximumMemory = max(maximumMemory, refreshedGpu.TotalMemory - ...
            refreshedGpu.AvailableMemory);
    end
    wait(gpuDevice);
    elapsed = toc(startTime);
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
    benchmark.maximumObservedGpuMemoryBytes = maximumMemory;
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

function state = initialize_state(fields)
    state = struct();
    for fieldIndex = 1:numel(fields)
        state.(fields{fieldIndex}) = [];
    end
end
