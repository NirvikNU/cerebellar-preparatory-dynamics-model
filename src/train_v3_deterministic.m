function [bestModel, history] = train_v3_deterministic( ...
        initialModel, params, run, checkpointPath)
    gpu = select_required_gpu(run.requiredGpuName);
    model = move_v3_model(initialModel, true);
    initialWrec = gather(extractdata(model.Wrec));
    taskStream = RandStream('mt19937ar', ...
        'Seed', params.seed.trainingTask);
    noiseStream = RandStream('mt19937ar', ...
        'Seed', params.seed.trainingNoise);
    validationTaskStream = RandStream('mt19937ar', ...
        'Seed', run.seed.validationTask);
    validationNoiseStream = RandStream('mt19937ar', ...
        'Seed', run.seed.validationNoise);
    validationTask = sample_balanced_v3_task(params, ...
        run.validationTrialsPerTarget, validationTaskStream);
    validationDeviceTask = prepare_v3_gradient_task(validationTask, true);
    validationNoise = sample_v3_noise(validationTask, params, false, ...
        validationNoiseStream, true);
    [gradientFunction, parameterVector, optimizerLayout, staticModel] = ...
        create_v3_gradient_engine(model, params, run.useAccelerated);
    if run.useAccelerated
        warmupSeconds = warm_v3_accelerated_function( ...
            gradientFunction, parameterVector, validationDeviceTask, ...
            validationNoise, gpu, run.acceleratedWarmupCalls);
    else
        warmupSeconds = [];
    end
    optimizerMultiplier = v3_optimizer_multiplier_vector( ...
        optimizerLayout, params, true);
    history = initialize_history(run.maximumUpdates, gpu.Name, ...
        run.useAccelerated, warmupSeconds);
    [initialValidationLoss, initialValidationComponents] = dlfeval( ...
        @v3_model_loss, model, validationDeviceTask, params, ...
        validationNoise);
    history.initialValidationLoss = scalar(initialValidationLoss);
    history.initialValidationComponents = ...
        scalar_components(initialValidationComponents);
    history.bestValidationLoss = history.initialValidationLoss;
    history.bestIteration = 0;
    bestModel = extract_v3_model(model);
    average = [];
    averageSquared = [];
    currentLearnRate = run.baseLearnRate;
    lastImprovement = 0;
    lastRateDrop = 0;
    startTime = tic;
    stopReason = 'maximum updates';

    for iteration = 1:run.maximumUpdates
        task = sample_balanced_v3_task(params, ...
            params.training.trialsPerTarget, taskStream);
        deviceTask = prepare_v3_gradient_task(task, true);
        noise = sample_v3_noise(task, params, false, noiseStream, true);
        [loss, gradientVector] = dlfeval(gradientFunction, ...
            parameterVector, deviceTask, noise);
        recordNow = mod(iteration, run.validationFrequency) == 0;
        progressNow = mod(iteration, run.displayEvery) == 0;
        if recordNow || progressNow
            currentModel = unpack_v3_trainables(staticModel, ...
                parameterVector, optimizerLayout);
            [~, trainingComponents] = dlfeval(@v3_model_loss, ...
                currentModel, deviceTask, params, noise);
        end
        [gradientVector, gradientNorm] = clip_gradient_vector( ...
            gradientVector, run.gradientThreshold);
        [candidateVector, average, averageSquared] = adamupdate( ...
            parameterVector, gradientVector, average, averageSquared, ...
            iteration, currentLearnRate, run.gradientDecayFactor, ...
            run.squaredGradientDecayFactor, run.adamEpsilon);
        parameterVector = parameterVector + optimizerMultiplier .* ...
            (candidateVector - parameterVector);
        history.loss(iteration) = scalar(loss);
        history.learningRate(iteration) = currentLearnRate;
        history.gradientNorm(iteration) = gradientNorm;

        if recordNow
            history.trainingComponents = record_components( ...
                history.trainingComponents, trainingComponents, iteration);
            currentModel = unpack_v3_trainables(staticModel, ...
                parameterVector, optimizerLayout);
            [validationLoss, validationComponents] = dlfeval( ...
                @v3_model_loss, currentModel, validationDeviceTask, ...
                params, validationNoise);
            history.validationLoss(iteration) = scalar(validationLoss);
            history.validationComponents = record_components( ...
                history.validationComponents, validationComponents, ...
                iteration);
            if history.validationLoss(iteration) < ...
                    history.bestValidationLoss - ...
                    run.minimumValidationImprovement
                history.bestValidationLoss = ...
                    history.validationLoss(iteration);
                history.bestIteration = iteration;
                bestModel = extract_v3_model(currentModel);
                lastImprovement = iteration;
            end
            plateauReference = max(lastImprovement, lastRateDrop);
            minimumRate = run.baseLearnRate * ...
                run.minimumLearningRateFraction;
            if iteration - plateauReference >= ...
                    run.learningRatePlateauPatienceUpdates && ...
                    currentLearnRate > minimumRate
                currentLearnRate = max(minimumRate, ...
                    currentLearnRate * run.learningRateDropFactor);
                lastRateDrop = iteration;
                fprintf('V3 deterministic learning rate reduced to %.3g.\n', ...
                    currentLearnRate);
            end
        end

        if progressNow
            elapsedMinutes = toc(startTime) / 60;
            remainingMinutes = elapsedMinutes / iteration * ...
                (run.maximumUpdates - iteration);
            fprintf(['V3 deterministic %d/%d | total %.6f | ', ...
                'preP %.4g preV %.4g latePreV %.4g urg %.4g ', ...
                'termP %.4g termV %.4g holdP %.4g holdV %.4g ', ...
                'velEff %.4g activity %.4g weight %.4g | ', ...
                'val %.6f | lr %.3g | grad %.4f | elapsed %.2f min | ', ...
                'eta %.2f min\n'], iteration, run.maximumUpdates, ...
                history.loss(iteration), ...
                scalar(trainingComponents.preGoPosition), ...
                scalar(trainingComponents.preGoVelocity), ...
                scalar(trainingComponents.latePreGoVelocity), ...
                scalar(trainingComponents.endpointUrgency), ...
                scalar(trainingComponents.terminalPosition), ...
                scalar(trainingComponents.terminalVelocity), ...
                scalar(trainingComponents.holdPosition), ...
                scalar(trainingComponents.holdVelocity), ...
                scalar(trainingComponents.velocityEffort), ...
                scalar(trainingComponents.activity), ...
                scalar(trainingComponents.weight), ...
                history.validationLoss(iteration), ...
                history.learningRate(iteration), gradientNorm, ...
                elapsedMinutes, remainingMinutes);
        end

        shouldStop = iteration >= run.earlyStoppingPatienceUpdates && ...
            iteration - lastImprovement >= ...
            run.earlyStoppingPatienceUpdates;
        if shouldStop
            stopReason = 'early stopping';
        end
        saveNow = mod(iteration, run.checkpointFrequency) == 0 || ...
            shouldStop || iteration == run.maximumUpdates;
        if saveNow
            currentModel = unpack_v3_trainables(staticModel, ...
                parameterVector, optimizerLayout);
            assert(isequal(initialWrec, ...
                gather(extractdata(currentModel.Wrec))), ...
                'V3Training:WrecChanged', ...
                'Fixed Wrec changed during deterministic training.');
            save_checkpoint(checkpointPath, currentModel, bestModel, ...
                average, averageSquared, parameterVector, ...
                optimizerLayout, history, iteration, currentLearnRate, ...
                lastImprovement, lastRateDrop, taskStream, noiseStream, ...
                validationTaskStream, validationNoiseStream, ...
                validationTask, validationNoise, params, run, ...
                toc(startTime), stopReason);
        end
        if shouldStop
            break
        end
    end

    history.updatesCompleted = iteration;
    history.elapsedSeconds = toc(startTime);
    history.secondsPerUpdate = history.elapsedSeconds / iteration;
    history.stopReason = stopReason;
    history = trim_history(history, iteration);
    assert(isequal(initialWrec, bestModel.Wrec), ...
        'V3Training:BestWrecChanged', ...
        'Best-model Wrec differs from the fixed initialization.');
end

function history = initialize_history(count, gpuName, accelerated, warmup)
    history.loss = nan(count, 1);
    history.validationLoss = nan(count, 1);
    history.learningRate = nan(count, 1);
    history.gradientNorm = nan(count, 1);
    names = component_names();
    for index = 1:numel(names)
        history.trainingComponents.(names{index}) = nan(count, 1);
        history.validationComponents.(names{index}) = nan(count, 1);
    end
    history.deterministic = true;
    history.gpuName = gpuName;
    history.usedAccelerated = accelerated;
    history.acceleratedWarmupSeconds = warmup;
    history.bestValidationLoss = inf;
    history.bestIteration = NaN;
end

function output = record_components(output, components, iteration)
    names = component_names();
    for index = 1:numel(names)
        output.(names{index})(iteration) = scalar(components.(names{index}));
    end
end

function output = scalar_components(components)
    names = component_names();
    for index = 1:numel(names)
        output.(names{index}) = scalar(components.(names{index}));
    end
end

function names = component_names()
    names = {'preGoPosition', 'preGoVelocity', 'latePreGoVelocity', ...
        'endpointUrgency', 'terminalPosition', 'terminalVelocity', ...
        'holdPosition', 'holdVelocity', 'velocityEffort', 'activity', ...
        'weight'};
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

function save_checkpoint(path, currentModel, bestModel, average, ...
        averageSquared, parameterVector, optimizerLayout, history, ...
        iteration, learnRate, lastImprovement, lastRateDrop, ...
        taskStream, noiseStream, validationTaskStream, ...
        validationNoiseStream, validationTask, validationNoise, ...
        params, run, elapsedSeconds, stopReason)
    checkpoint.currentModel = gather_struct(currentModel);
    checkpoint.bestModel = bestModel;
    checkpoint.average = gather_value(average);
    checkpoint.averageSquared = gather_value(averageSquared);
    checkpoint.parameterVector = gather_value(parameterVector);
    checkpoint.optimizerLayout = optimizerLayout;
    checkpoint.history = trim_history(history, iteration);
    checkpoint.iteration = iteration;
    checkpoint.currentLearnRate = learnRate;
    checkpoint.scheduler.lastImprovement = lastImprovement;
    checkpoint.scheduler.lastRateDrop = lastRateDrop;
    checkpoint.scheduler.bestValidationLoss = ...
        history.bestValidationLoss;
    checkpoint.scheduler.bestIteration = history.bestIteration;
    checkpoint.rng.trainingTaskState = taskStream.State;
    checkpoint.rng.trainingNoiseState = noiseStream.State;
    checkpoint.rng.validationTaskState = validationTaskStream.State;
    checkpoint.rng.validationNoiseState = validationNoiseStream.State;
    checkpoint.validationTask = validationTask;
    checkpoint.validationNoise = gather_struct(validationNoise);
    checkpoint.params = params;
    checkpoint.run = run;
    checkpoint.elapsedTrainingSeconds = elapsedSeconds;
    checkpoint.stopReason = stopReason;
    checkpoint.resume.nextIteration = iteration + 1;
    checkpoint.resume.exactStateAvailable = true;
    checkpoint.savedAt = char(datetime('now', 'TimeZone', 'local', ...
        'Format', 'yyyy-MM-dd HH:mm:ss Z'));
    outputDirectory = fileparts(path);
    if ~isfolder(outputDirectory)
        mkdir(outputDirectory);
    end
    save(path, 'checkpoint', '-v7.3');
end

function output = gather_value(value)
    if isempty(value)
        output = value;
    else
        if isa(value, 'dlarray')
            value = extractdata(value);
        end
        output = gather(value);
    end
end

function output = gather_struct(input)
    output = struct();
    names = fieldnames(input);
    for index = 1:numel(names)
        value = input.(names{index});
        if isa(value, 'dlarray')
            value = extractdata(value);
        end
        output.(names{index}) = gather(value);
    end
end
