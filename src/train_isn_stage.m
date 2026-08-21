function [learnedModel, history] = train_isn_stage( ...
        initialModel, params, stageNumber, useAccelerated, checkpointPath)
    if nargin < 5
        checkpointPath = '';
    end
    fields = {'Wtarg', 'Wgo', 'WcbHidden', 'bcbHidden', ...
        'WcbLatent', 'bcbLatent', 'Ucb', 'Wout'};
    [maxIterations, learnRate, variableDelay, noisy] = ...
        stage_settings(params, stageNumber);
    useGpu = params.training.useGpuIfAvailable && canUseGPU;
    if useGpu
        select_required_gpu(params.model.requiredGpuName);
    end
    model = move_model(initialModel, useGpu);
    deviceParams = move_plant(params, useGpu);
    taskStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.trainingTask + 100 * stageNumber);
    noiseStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.trainingNoise + 100 * stageNumber);
    validationStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.validationTask + 100 * stageNumber);
    validationTask = sample_task(params, ...
        params.training.validationTrialsPerTarget, variableDelay, ...
        validationStream);
    validationTaskGpu = prepare_isn_gradient_task( ...
        validationTask, deviceParams, useGpu);
    validationNoise = sample_noise(validationTask, params, ...
        noisy, validationStream, useGpu);
    validationParams = deviceParams;
    if ~noisy
        validationParams.noise.sigmaInitialHz = 0;
        validationParams.noise.sigmaDynamicHz = 0;
    end
    gradientFunction = @isn_model_gradients;
    if useAccelerated
        gradientFunction = dlaccelerate(gradientFunction);
    end

    average = struct();
    averageSquared = struct();
    for fieldIndex = 1:numel(fields)
        average.(fields{fieldIndex}) = [];
        averageSquared.(fields{fieldIndex}) = [];
    end
    history.loss = nan(maxIterations, 1);
    history.validationLoss = nan(maxIterations, 1);
    history.learningRate = nan(maxIterations, 1);
    history.stageNumber = stageNumber;
    history.variableDelay = variableDelay;
    history.noisy = noisy;
    history.usedGpu = useGpu;
    history.usedAccelerated = useAccelerated;
    history.bestValidationLoss = inf;
    history.bestIteration = NaN;
    bestModel = [];
    lastImprovement = 0;
    lastRateDrop = 0;
    currentLearnRate = learnRate;
    startTime = tic;
    for iteration = 1:maxIterations
        task = sample_task(params, params.training.trialsPerTarget, ...
            variableDelay, taskStream);
        gradientTask = prepare_isn_gradient_task(task, deviceParams, useGpu);
        noise = sample_noise(task, params, noisy, noiseStream, useGpu);
        lossParams = deviceParams;
        if ~noisy
            lossParams.noise.sigmaInitialHz = 0;
            lossParams.noise.sigmaDynamicHz = 0;
        end
        [loss, gradients] = dlfeval(gradientFunction, model, ...
            gradientTask, lossParams, noise);
        gradients = clip_gradient_struct(gradients, ...
            params.training.gradientThreshold);
        for fieldIndex = 1:numel(fields)
            name = fields{fieldIndex};
            parameterRate = currentLearnRate * ...
                params.training.learningRateMultipliers.(name);
            [model.(name), average.(name), averageSquared.(name)] = ...
                adamupdate(model.(name), gradients.(name), ...
                average.(name), averageSquared.(name), iteration, ...
                parameterRate, params.training.gradientDecayFactor, ...
                params.training.squaredGradientDecayFactor, ...
                params.training.adamEpsilon);
        end
        history.loss(iteration) = scalar(loss);
        history.learningRate(iteration) = currentLearnRate;
        if mod(iteration, params.training.validationFrequency) == 0
            validationLoss = dlfeval(@isn_model_loss, model, ...
                validationTaskGpu, validationParams, validationNoise);
            history.validationLoss(iteration) = scalar(validationLoss);
            if history.validationLoss(iteration) < ...
                    history.bestValidationLoss - ...
                    params.training.minimumValidationImprovement
                history.bestValidationLoss = history.validationLoss(iteration);
                history.bestIteration = iteration;
                bestModel = extract_intact_model(model);
                lastImprovement = iteration;
            end
            plateauReference = max(lastImprovement, lastRateDrop);
            minimumRate = learnRate * ...
                params.training.minimumLearningRateFraction;
            if iteration - plateauReference >= ...
                    params.training.learningRatePlateauPatienceUpdates && ...
                    currentLearnRate > minimumRate
                currentLearnRate = max(minimumRate, currentLearnRate * ...
                    params.training.learningRateDropFactor);
                lastRateDrop = iteration;
                fprintf('ISN stage %d reduced learning rate to %.3g.\n', ...
                    stageNumber, currentLearnRate);
            end
        end
        if iteration == 1 || mod(iteration, params.training.displayEvery) == 0
            fprintf('ISN stage %d iteration %d/%d loss %.6f val %.6f\n', ...
                stageNumber, iteration, maxIterations, history.loss(iteration), ...
                history.validationLoss(iteration));
        end
        shouldStop = iteration >= ...
            params.training.earlyStoppingPatienceUpdates && ...
                iteration - lastImprovement >= ...
                params.training.earlyStoppingPatienceUpdates;
        if ~isempty(checkpointPath) && (mod(iteration, ...
                params.training.checkpointFrequency) == 0 || ...
                shouldStop || iteration == maxIterations)
            save_training_checkpoint(checkpointPath, model, bestModel, ...
                average, averageSquared, history, iteration, ...
                currentLearnRate, stageNumber);
        end
        if shouldStop
            break;
        end
    end
    if isempty(bestModel)
        bestModel = extract_intact_model(model);
        history.bestIteration = iteration;
        history.bestValidationLoss = history.loss(iteration);
    end
    learnedModel = bestModel;
    history.updatesCompleted = iteration;
    history.loss = history.loss(1:iteration);
    history.validationLoss = history.validationLoss(1:iteration);
    history.learningRate = history.learningRate(1:iteration);
    history.elapsedSeconds = toc(startTime);
end

function [count, rate, variable, noisy] = stage_settings(params, stage)
    switch stage
        case 1
            count = params.training.stage1MaxIterations;
            rate = params.training.stage1LearnRate;
            variable = false;
            noisy = false;
        case 2
            count = params.training.stage2MaxIterations;
            rate = params.training.stage2LearnRate;
            variable = true;
            noisy = false;
        case 3
            count = params.training.stage3MaxIterations;
            rate = params.training.stage3LearnRate;
            variable = true;
            noisy = true;
        otherwise
            error('IsnModel:Stage', 'Stage must be 1, 2, or 3.');
    end
end

function task = sample_task(params, trialsPerTarget, variable, stream)
    targets = repelem(1:params.task.numTargets, trialsPerTarget);
    targets = targets(randperm(stream, numel(targets)));
    if variable
        allowed = params.task.minimumGoTimeMs:params.model.dtMs: ...
            params.task.maximumGoTimeMs;
        goTimes = allowed(randi(stream, numel(allowed), 1, numel(targets)));
    else
        goTimes = params.task.canonicalGoTimeMs;
    end
    task = build_isn_reach_task(params, trialsPerTarget, goTimes, targets);
end

function noise = sample_noise(task, params, noisy, stream, useGpu)
    initial = zeros(params.model.numCorticalUnits, task.numTrials, 'single');
    dynamic = zeros(params.model.numCorticalUnits, task.numTrials, ...
        task.numTimeSteps - 1, 'single');
    if noisy
        initial = randn(stream, size(initial), 'single');
        dynamic = randn(stream, size(dynamic), 'single');
    end
    if useGpu
        initial = gpuArray(initial);
        dynamic = gpuArray(dynamic);
    end
    noise.initial = dlarray(initial);
    noise.dynamic = dlarray(dynamic);
end

function model = move_model(model, useGpu)
    names = fieldnames(model);
    for fieldIndex = 1:numel(names)
        value = model.(names{fieldIndex});
        if isa(value, 'dlarray')
            value = extractdata(value);
        end
        value = single(value);
        if useGpu
            value = gpuArray(value);
        end
        model.(names{fieldIndex}) = dlarray(value);
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

function value = scalar(input)
    value = double(gather(extractdata(input)));
end

function save_training_checkpoint(path, model, bestModel, average, ...
        averageSquared, history, iteration, currentLearnRate, stageNumber)
    checkpoint.currentModel = gather_struct(model);
    checkpoint.bestModel = bestModel;
    checkpoint.average = gather_struct(average);
    checkpoint.averageSquared = gather_struct(averageSquared);
    checkpoint.history.loss = history.loss(1:iteration);
    checkpoint.history.validationLoss = history.validationLoss(1:iteration);
    checkpoint.history.learningRate = history.learningRate(1:iteration);
    checkpoint.bestValidationLoss = history.bestValidationLoss;
    checkpoint.bestIteration = history.bestIteration;
    checkpoint.iteration = iteration;
    checkpoint.currentLearnRate = currentLearnRate;
    checkpoint.stageNumber = stageNumber;
    checkpoint.savedAt = char(datetime('now', 'TimeZone', 'local', ...
        'Format', 'yyyy-MM-dd HH:mm:ss Z'));
    save(path, 'checkpoint', '-v7.3');
end

function output = gather_struct(input)
    output = struct();
    names = fieldnames(input);
    for fieldIndex = 1:numel(names)
        value = input.(names{fieldIndex});
        if isempty(value)
            output.(names{fieldIndex}) = value;
            continue;
        end
        if isa(value, 'dlarray')
            value = extractdata(value);
        end
        output.(names{fieldIndex}) = gather(value);
    end
end
