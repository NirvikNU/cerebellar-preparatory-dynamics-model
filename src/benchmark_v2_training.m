function benchmark = benchmark_v2_training(initialModel, params)
    gpu = select_required_gpu(params.model.requiredGpuName);
    model = move_v2_model(initialModel, true);
    stream = RandStream('mt19937ar', 'Seed', params.seed.trainingTask + 900);
    task = sample_balanced_v2_task(params, ...
        params.training.trialsPerTarget, stream);
    deviceTask = prepare_v2_gradient_task(task, true);
    noise = sample_v2_noise(task, params, false, stream, true);
    [ordinary, parameterVector, optimizerLayout, ~] = ...
        create_v2_gradient_engine(model, params, false);
    [accelerated, ~, ~, ~] = create_v2_gradient_engine(model, params, true);
    [~, ~] = dlfeval(ordinary, parameterVector, deviceTask, noise);
    wait(gpu);
    ordinarySeconds = time_gradients(ordinary, parameterVector, ...
        deviceTask, noise, params.training.benchmarkRepetitions, gpu);
    memoryBeforeAccelerated = gpu.TotalMemory - gpu.AvailableMemory;
    acceleratedWarmupSeconds = warm_v2_accelerated_function( ...
        accelerated, parameterVector, deviceTask, noise, gpu, ...
        params.training.acceleratedWarmupCalls);
    acceleratedTraceSeconds = acceleratedWarmupSeconds(1);
    acceleratedSeconds = time_gradients(accelerated, parameterVector, ...
        deviceTask, noise, params.training.benchmarkRepetitions, gpu);
    refreshedGpu = gpuDevice;
    memoryAfterAccelerated = refreshedGpu.TotalMemory - ...
        refreshedGpu.AvailableMemory;
    memoryGrowth = memoryAfterAccelerated - memoryBeforeAccelerated;
    useAccelerated = acceleratedSeconds < ordinarySeconds && ...
        memoryGrowth < 1024^3;
    if useAccelerated
        gradientFunction = accelerated;
    else
        gradientFunction = ordinary;
    end

    optimizerMultiplier = v2_optimizer_multiplier_vector( ...
        optimizerLayout, params, true);
    average = [];
    averageSquared = [];
    losses = nan(params.training.benchmarkUpdates, 1);
    updateSeconds = nan(params.training.benchmarkUpdates, 1);
    cacheOccupancyBeforeUpdates = cache_occupancy(gradientFunction);
    for iteration = 1:params.training.benchmarkUpdates
        updateStart = tic;
        task = sample_balanced_v2_task(params, ...
            params.training.trialsPerTarget, stream);
        deviceTask = prepare_v2_gradient_task(task, true);
        noise = sample_v2_noise(task, params, false, stream, true);
        [loss, gradientVector] = dlfeval(gradientFunction, ...
            parameterVector, deviceTask, noise);
        gradientVector = clip_gradient_vector(gradientVector, ...
            params.training.gradientThreshold);
        [candidateVector, average, averageSquared] = adamupdate( ...
            parameterVector, gradientVector, average, averageSquared, ...
            iteration, params.training.stageALearnRate, ...
            params.training.gradientDecayFactor, ...
            params.training.squaredGradientDecayFactor, ...
            params.training.adamEpsilon);
        parameterVector = parameterVector + optimizerMultiplier .* ...
            (candidateVector - parameterVector);
        losses(iteration) = double(gather(extractdata(loss)));
        wait(gpu);
        updateSeconds(iteration) = toc(updateStart);
    end
    cacheOccupancyAfterUpdates = cache_occupancy(gradientFunction);
    refreshedGpu = gpuDevice;
    memoryAfterUpdates = refreshedGpu.TotalMemory - ...
        refreshedGpu.AvailableMemory;
    benchmark.gpuName = gpu.Name;
    benchmark.ordinaryGradientSeconds = ordinarySeconds;
    benchmark.acceleratedTraceSeconds = acceleratedTraceSeconds;
    benchmark.acceleratedWarmupSeconds = acceleratedWarmupSeconds;
    benchmark.acceleratedWarmupTotalSeconds = ...
        sum(acceleratedWarmupSeconds);
    benchmark.acceleratedGradientSeconds = acceleratedSeconds;
    benchmark.acceleratedMemoryGrowthBytes = memoryGrowth;
    benchmark.useAccelerated = useAccelerated;
    benchmark.updates = params.training.benchmarkUpdates;
    benchmark.updateSeconds = updateSeconds;
    benchmark.elapsedSeconds = sum(updateSeconds);
    benchmark.secondsPerUpdate = mean(updateSeconds);
    benchmark.medianSecondsPerUpdate = median(updateSeconds);
    benchmark.firstUpdateSeconds = updateSeconds(1);
    if numel(updateSeconds) > 1
        benchmark.updatesAfterFirstMeanSeconds = mean(updateSeconds(2:end));
    else
        benchmark.updatesAfterFirstMeanSeconds = updateSeconds(1);
    end
    benchmark.estimatedSecondsFor1000Updates = ...
        1000 * benchmark.updatesAfterFirstMeanSeconds;
    benchmark.estimatedSecondsFor3000Updates = ...
        3000 * benchmark.updatesAfterFirstMeanSeconds;
    benchmark.gpuMemoryUsedAfterUpdatesBytes = memoryAfterUpdates;
    benchmark.firstLoss = losses(1);
    benchmark.finalLoss = losses(end);
    benchmark.losses = losses;
    benchmark.cacheOccupancyBeforeUpdates = cacheOccupancyBeforeUpdates;
    benchmark.cacheOccupancyAfterUpdates = cacheOccupancyAfterUpdates;
    benchmark.cacheReusedAcrossUpdates = ...
        cacheOccupancyAfterUpdates == cacheOccupancyBeforeUpdates;
    benchmark.runtimeTargetSecondsPerUpdate = ...
        params.training.maximumSecondsPerUpdateAfterWarmup;
    benchmark.runtimeTargetPassed = ...
        benchmark.updatesAfterFirstMeanSeconds <= ...
        benchmark.runtimeTargetSecondsPerUpdate;
end

function seconds = time_gradients(functionHandle, parameters, task, ...
        noise, repetitions, gpu)
    startTime = tic;
    for repetition = 1:repetitions
        [~, ~] = dlfeval(functionHandle, parameters, task, noise);
    end
    wait(gpu);
    seconds = toc(startTime) / repetitions;
end

function occupancy = cache_occupancy(functionHandle)
    if isa(functionHandle, 'deep.AcceleratedFunction')
        occupancy = functionHandle.Occupancy;
    else
        occupancy = NaN;
    end
end
