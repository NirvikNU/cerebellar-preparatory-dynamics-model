function [learnedModel, history] = train_v2_stage( ...
        initialModel, params, stageName, useAccelerated, checkpointPath)
    if nargin < 5
        checkpointPath = '';
    end
    [stageIndex, maxIterations, baseLearnRate, noisy] = ...
        stage_settings(params, stageName);
    gpu = select_required_gpu(params.model.requiredGpuName);
    model = move_v2_model(initialModel, true);
    taskStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.trainingTask + 100 * stageIndex);
    noiseStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.trainingNoise + 100 * stageIndex);
    validationTaskStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.validationTask + 100 * stageIndex);
    validationNoiseStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.validationNoise + 100 * stageIndex);
    validationTask = sample_balanced_v2_task(params, ...
        params.training.validationTrialsPerTarget, validationTaskStream);
    validationDeviceTask = prepare_v2_gradient_task(validationTask, true);
    validationNoise = sample_v2_noise(validationTask, params, noisy, ...
        validationNoiseStream, true);
    gradientFunction = @v2_model_gradients;
    if useAccelerated
        gradientFunction = dlaccelerate(gradientFunction);
    end

    fields = v2_trainable_fields();
    average = initialize_optimizer_state(fields);
    averageSquared = initialize_optimizer_state(fields);
    history = initialize_history(maxIterations, stageName, noisy, ...
        useAccelerated, gpu.Name);
    bestModel = [];
    lastImprovement = 0;
    lastRateDrop = 0;
    currentLearnRate = baseLearnRate;
    startTime = tic;
    for iteration = 1:maxIterations
        task = sample_balanced_v2_task(params, ...
            params.training.trialsPerTarget, taskStream);
        deviceTask = prepare_v2_gradient_task(task, true);
        noise = sample_v2_noise(task, params, noisy, noiseStream, true);
        [loss, gradients, components] = dlfeval(gradientFunction, ...
            model, deviceTask, params, noise);
        [gradients, gradientNorm] = clip_gradient_struct(gradients, ...
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
        history.gradientNorm(iteration) = gradientNorm;
        if iteration == 1 || mod(iteration, ...
                params.training.validationFrequency) == 0
            history.trainingComponents = record_components( ...
                history.trainingComponents, components, iteration);
            [validationLoss, validationComponents] = dlfeval( ...
                @v2_model_loss, model, validationDeviceTask, params, ...
                validationNoise);
            history.validationLoss(iteration) = scalar(validationLoss);
            history.validationComponents = record_components( ...
                history.validationComponents, validationComponents, iteration);
            if history.validationLoss(iteration) < ...
                    history.bestValidationLoss - ...
                    params.training.minimumValidationImprovement
                history.bestValidationLoss = history.validationLoss(iteration);
                history.bestIteration = iteration;
                bestModel = extract_v2_model(model);
                lastImprovement = iteration;
            end
            plateauReference = max(lastImprovement, lastRateDrop);
            minimumRate = baseLearnRate * ...
                params.training.minimumLearningRateFraction;
            if iteration - plateauReference >= ...
                    params.training.learningRatePlateauPatienceUpdates && ...
                    currentLearnRate > minimumRate
                currentLearnRate = max(minimumRate, currentLearnRate * ...
                    params.training.learningRateDropFactor);
                lastRateDrop = iteration;
                fprintf('V2 stage %s reduced learning rate to %.3g.\n', ...
                    stageName, currentLearnRate);
            end
        end
        if iteration == 1 || mod(iteration, params.training.displayEvery) == 0
            fprintf(['V2 stage %s iteration %d/%d loss %.6f ', ...
                'val %.6f grad %.4f\n'], stageName, iteration, ...
                maxIterations, history.loss(iteration), ...
                history.validationLoss(iteration), gradientNorm);
        end
        shouldStop = iteration >= ...
            params.training.earlyStoppingPatienceUpdates && ...
            lastImprovement > 0 && iteration - lastImprovement >= ...
            params.training.earlyStoppingPatienceUpdates;
        if ~isempty(checkpointPath) && (mod(iteration, ...
                params.training.checkpointFrequency) == 0 || ...
                shouldStop || iteration == maxIterations)
            save_training_checkpoint(checkpointPath, model, bestModel, ...
                average, averageSquared, history, iteration, ...
                currentLearnRate, stageName);
        end
        if shouldStop
            break;
        end
    end
    if isempty(bestModel)
        bestModel = extract_v2_model(model);
        history.bestIteration = iteration;
        history.bestValidationLoss = history.loss(iteration);
    end
    learnedModel = bestModel;
    history.updatesCompleted = iteration;
    history.elapsedSeconds = toc(startTime);
    history.secondsPerUpdate = history.elapsedSeconds / iteration;
    history = trim_history(history, iteration);
end

function [index, count, rate, noisy] = stage_settings(params, stageName)
    switch upper(char(stageName))
        case 'A'
            index = 1;
            count = params.training.stageAMaxIterations;
            rate = params.training.stageALearnRate;
            noisy = false;
        case 'B'
            index = 2;
            count = params.training.stageBMaxIterations;
            rate = params.training.stageBLearnRate;
            noisy = true;
        otherwise
            error('V2Model:Stage', 'Stage must be A or B.');
    end
end

function state = initialize_optimizer_state(fields)
    state = struct();
    for fieldIndex = 1:numel(fields)
        state.(fields{fieldIndex}) = [];
    end
end

function history = initialize_history(count, stageName, noisy, ...
        accelerated, gpuName)
    history.loss = nan(count, 1);
    history.validationLoss = nan(count, 1);
    history.learningRate = nan(count, 1);
    history.gradientNorm = nan(count, 1);
    componentNames = loss_component_names();
    for index = 1:numel(componentNames)
        history.trainingComponents.(componentNames{index}) = nan(count, 1);
        history.validationComponents.(componentNames{index}) = nan(count, 1);
    end
    history.stageName = char(stageName);
    history.variableDelay = true;
    history.noisy = noisy;
    history.usedGpu = true;
    history.gpuName = gpuName;
    history.usedAccelerated = accelerated;
    history.bestValidationLoss = inf;
    history.bestIteration = NaN;
end

function output = record_components(output, components, iteration)
    names = loss_component_names();
    for index = 1:numel(names)
        output.(names{index})(iteration) = scalar(components.(names{index}));
    end
end

function names = loss_component_names()
    names = {'preGoPosition', 'preGoVelocity', 'endpointUrgency', ...
        'terminalPosition', 'terminalVelocity', 'holdPosition', ...
        'holdVelocity', 'velocityEffort', 'activity', 'weight'};
end

function value = scalar(input)
    value = double(gather(extractdata(input)));
end

function history = trim_history(history, iteration)
    names = {'loss', 'validationLoss', 'learningRate', 'gradientNorm'};
    for index = 1:numel(names)
        history.(names{index}) = history.(names{index})(1:iteration);
    end
    groups = {'trainingComponents', 'validationComponents'};
    for groupIndex = 1:numel(groups)
        group = groups{groupIndex};
        names = fieldnames(history.(group));
        for index = 1:numel(names)
            history.(group).(names{index}) = ...
                history.(group).(names{index})(1:iteration);
        end
    end
end

function save_training_checkpoint(path, model, bestModel, average, ...
        averageSquared, history, iteration, learnRate, stageName)
    checkpoint.currentModel = gather_struct(model);
    checkpoint.bestModel = bestModel;
    checkpoint.average = gather_struct(average);
    checkpoint.averageSquared = gather_struct(averageSquared);
    checkpoint.history = trim_history(history, iteration);
    checkpoint.iteration = iteration;
    checkpoint.currentLearnRate = learnRate;
    checkpoint.stageName = char(stageName);
    checkpoint.savedAt = char(datetime('now', 'TimeZone', 'local', ...
        'Format', 'yyyy-MM-dd HH:mm:ss Z'));
    outputDirectory = fileparts(path);
    if ~isfolder(outputDirectory)
        mkdir(outputDirectory);
    end
    save(path, 'checkpoint', '-v7.3');
end

function output = gather_struct(input)
    output = struct();
    names = fieldnames(input);
    for index = 1:numel(names)
        value = input.(names{index});
        if isempty(value)
            output.(names{index}) = value;
        else
            if isa(value, 'dlarray')
                value = extractdata(value);
            end
            output.(names{index}) = gather(value);
        end
    end
end
