function benchmark = benchmark_isn_gradient_execution(model, params)
    useGpu = params.training.useGpuIfAvailable && canUseGPU;
    if useGpu
        gpu = select_required_gpu(params.model.requiredGpuName);
        benchmark.gpuName = gpu.Name;
    else
        benchmark.gpuName = 'CPU';
    end
    task = build_isn_reach_task(params, params.training.trialsPerTarget, ...
        params.task.canonicalGoTimeMs, []);
    task = prepare_isn_gradient_task(task, params, useGpu);
    model = move_model(model, useGpu);
    deviceParams = move_plant(params, useGpu);
    noise.initial = dlarray(move(zeros(params.model.numCorticalUnits, ...
        task.numTrials, 'single'), useGpu));
    noise.dynamic = dlarray(move(zeros(params.model.numCorticalUnits, ...
        task.numTrials, task.numTimeSteps - 1, 'single'), useGpu));
    accelerated = dlaccelerate(@isn_model_gradients);

    dlfeval(@isn_model_gradients, model, task, deviceParams, noise);
    dlfeval(accelerated, model, task, deviceParams, noise);
    synchronize(useGpu);
    ordinaryStart = tic;
    for repetition = 1:params.training.benchmarkRepetitions
        dlfeval(@isn_model_gradients, model, task, deviceParams, noise);
    end
    synchronize(useGpu);
    benchmark.ordinarySecondsPerIteration = ...
        toc(ordinaryStart) / params.training.benchmarkRepetitions;
    acceleratedStart = tic;
    for repetition = 1:params.training.benchmarkRepetitions
        dlfeval(accelerated, model, task, deviceParams, noise);
    end
    synchronize(useGpu);
    benchmark.acceleratedSecondsPerIteration = ...
        toc(acceleratedStart) / params.training.benchmarkRepetitions;
    benchmark.speedup = benchmark.ordinarySecondsPerIteration / ...
        benchmark.acceleratedSecondsPerIteration;
    benchmark.useAccelerated = ...
        benchmark.acceleratedSecondsPerIteration < ...
        benchmark.ordinarySecondsPerIteration;
    benchmark.repetitions = params.training.benchmarkRepetitions;
end

function model = move_model(model, useGpu)
    names = fieldnames(model);
    for fieldIndex = 1:numel(names)
        value = model.(names{fieldIndex});
        if isa(value, 'dlarray')
            value = extractdata(value);
        end
        model.(names{fieldIndex}) = dlarray(move(single(value), useGpu));
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

function value = move(value, useGpu)
    if useGpu
        value = gpuArray(value);
    end
end

function synchronize(useGpu)
    if useGpu
        wait(gpuDevice);
    end
end
