function [learnedModel, history] = train_v2_stage( ...
        initialModel, params, stageName, useAccelerated, checkpointPath, ...
        resumeCheckpoint)
    if nargin < 5
        checkpointPath = '';
    end
    if nargin < 6
        resumeCheckpoint = [];
    end
    [stageIndex, maxIterations, baseLearnRate, noisy] = ...
        stage_settings(params, stageName);
    gpu = select_required_gpu(params.model.requiredGpuName);
    resuming = ~isempty(resumeCheckpoint);
    if resuming
        validate_resume_checkpoint(resumeCheckpoint, stageName, ...
            maxIterations);
        model = move_v2_model(resumeCheckpoint.currentModel, true);
    else
        model = move_v2_model(initialModel, true);
    end
    taskStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.trainingTask + 100 * stageIndex);
    noiseStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.trainingNoise + 100 * stageIndex);
    validationTaskStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.validationTask + 100 * stageIndex);
    validationNoiseStream = RandStream('mt19937ar', 'Seed', ...
        params.seed.validationNoise + 100 * stageIndex);
    if resuming
        taskStream.State = resumeCheckpoint.rng.trainingTaskState;
        noiseStream.State = resumeCheckpoint.rng.trainingNoiseState;
        validationTaskStream.State = ...
            resumeCheckpoint.rng.validationTaskState;
        validationNoiseStream.State = ...
            resumeCheckpoint.rng.validationNoiseState;
        validationTask = build_v2_task(params, ...
            params.training.validationTrialsPerTarget, ...
            resumeCheckpoint.validationTask.goTimeMs, ...
            resumeCheckpoint.validationTask.targetIndex);
    else
        validationTask = sample_balanced_v2_task(params, ...
            params.training.validationTrialsPerTarget, validationTaskStream);
    end
    validationDeviceTask = prepare_v2_gradient_task(validationTask, true);
    if resuming
        validationNoise = move_noise(resumeCheckpoint.validationNoise, true);
    else
        validationNoise = sample_v2_noise(validationTask, params, noisy, ...
            validationNoiseStream, true);
    end
    [gradientFunction, parameterVector, optimizerLayout, staticModel] = ...
        create_v2_gradient_engine(model, params, useAccelerated);
    if resuming
        if ~isequaln(optimizerLayout, resumeCheckpoint.optimizerLayout)
            error('V2Model:ResumeLayout', ...
                'Checkpoint optimizer layout differs from the current layout.');
        end
        parameterVector = move_dlarray(resumeCheckpoint.parameterVector, true);
    end
    acceleratedWarmupSeconds = [];
    if useAccelerated
        acceleratedWarmupSeconds = warm_v2_accelerated_function( ...
            gradientFunction, parameterVector, validationDeviceTask, ...
            validationNoise, gpu, params.training.acceleratedWarmupCalls);
    end
    optimizerMultiplier = v2_optimizer_multiplier_vector( ...
        optimizerLayout, params, true);
    if resuming
        average = move_dlarray(resumeCheckpoint.average, true);
        averageSquared = move_dlarray(resumeCheckpoint.averageSquared, true);
        history = extend_history(resumeCheckpoint.history, maxIterations, ...
            stageName, noisy, useAccelerated, gpu.Name);
    else
        average = [];
        averageSquared = [];
        history = initialize_history(maxIterations, stageName, noisy, ...
            useAccelerated, gpu.Name);
    end
    history.acceleratedWarmupSeconds = acceleratedWarmupSeconds;
    conditionLabel = 'deterministic';
    if noisy
        conditionLabel = 'noisy';
    end
    bestModel = [];
    lastImprovement = 0;
    lastRateDrop = 0;
    currentLearnRate = baseLearnRate;
    startIteration = 1;
    if resuming
        startIteration = resumeCheckpoint.iteration + 1;
        currentLearnRate = resumeCheckpoint.currentLearnRate;
        lastRateDrop = resumeCheckpoint.scheduler.lastRateDrop;
        currentModel = unpack_v2_trainables(staticModel, parameterVector, ...
            optimizerLayout);
        [validationLoss, validationComponents] = dlfeval( ...
            @v2_model_loss, currentModel, validationDeviceTask, params, ...
            validationNoise);
        history.validationLoss(resumeCheckpoint.iteration) = ...
            scalar(validationLoss);
        history.validationComponents = record_components( ...
            history.validationComponents, validationComponents, ...
            resumeCheckpoint.iteration);
        history.bestValidationLoss = scalar(validationLoss);
        history.bestIteration = resumeCheckpoint.iteration;
        history.refinementBoundaryIteration = resumeCheckpoint.iteration;
        bestModel = extract_v2_model(currentModel);
        lastImprovement = resumeCheckpoint.iteration;
        fprintf(['Resuming V2 stage %s from update %d with Adam and RNG ', ...
            'state preserved; validation baseline reset for the revised ', ...
            'behavioral objective (%.6f).\n'], stageName, ...
            resumeCheckpoint.iteration, history.bestValidationLoss);
    end
    startTime = tic;
    for iteration = startIteration:maxIterations
        task = sample_balanced_v2_task(params, ...
            params.training.trialsPerTarget, taskStream);
        deviceTask = prepare_v2_gradient_task(task, true);
        noise = sample_v2_noise(task, params, noisy, noiseStream, true);
        [loss, gradientVector] = dlfeval(gradientFunction, ...
            parameterVector, deviceTask, noise);
        recordNow = mod(iteration, ...
            params.training.validationFrequency) == 0;
        progressNow = mod(iteration, params.training.displayEvery) == 0;
        if recordNow || progressNow
            model = unpack_v2_trainables(staticModel, parameterVector, ...
                optimizerLayout);
            [~, components] = dlfeval(@v2_model_loss, model, ...
                deviceTask, params, noise);
        end
        [gradientVector, gradientNorm] = clip_gradient_vector( ...
            gradientVector, ...
            params.training.gradientThreshold);
        [candidateVector, average, averageSquared] = adamupdate( ...
            parameterVector, gradientVector, average, averageSquared, ...
            iteration, currentLearnRate, ...
            params.training.gradientDecayFactor, ...
            params.training.squaredGradientDecayFactor, ...
            params.training.adamEpsilon);
        parameterVector = parameterVector + optimizerMultiplier .* ...
            (candidateVector - parameterVector);
        history.loss(iteration) = scalar(loss);
        history.learningRate(iteration) = currentLearnRate;
        history.gradientNorm(iteration) = gradientNorm;
        if recordNow
            history.trainingComponents = record_components( ...
                history.trainingComponents, components, iteration);
            model = unpack_v2_trainables(staticModel, parameterVector, ...
                optimizerLayout);
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
        if progressNow
            elapsedMinutes = toc(startTime) / 60;
            completedThisRun = iteration - startIteration + 1;
            remainingMinutes = elapsedMinutes / completedThisRun * ...
                (maxIterations - iteration);
            fprintf(['V2 stage %s %s update %d/%d | ', ...
                'train %.6f | preV %.4g latePreV %.4g urg %.4g termP %.4g ', ...
                'termV %.4g holdP %.4g holdV %.4g | val %.6f | ', ...
                'lr %.3g | grad %.4f | elapsed %.2f min | ', ...
                'eta %.2f min\n'], stageName, conditionLabel, iteration, ...
                maxIterations, history.loss(iteration), ...
                scalar(components.preGoVelocity), ...
                scalar(components.latePreGoVelocity), ...
                scalar(components.endpointUrgency), ...
                scalar(components.terminalPosition), ...
                scalar(components.terminalVelocity), ...
                scalar(components.holdPosition), ...
                scalar(components.holdVelocity), ...
                history.validationLoss(iteration), ...
                history.learningRate(iteration), ...
                gradientNorm, elapsedMinutes, remainingMinutes);
        end
        shouldStop = iteration >= ...
            params.training.earlyStoppingPatienceUpdates && ...
            lastImprovement > 0 && iteration - lastImprovement >= ...
            params.training.earlyStoppingPatienceUpdates;
        if ~isempty(checkpointPath) && (mod(iteration, ...
                params.training.checkpointFrequency) == 0 || ...
                shouldStop || iteration == maxIterations)
            model = unpack_v2_trainables(staticModel, parameterVector, ...
                optimizerLayout);
            save_training_checkpoint(checkpointPath, model, bestModel, ...
                average, averageSquared, history, iteration, ...
                currentLearnRate, stageName, lastImprovement, ...
                lastRateDrop, taskStream, noiseStream, ...
                validationTaskStream, validationNoiseStream, ...
                validationTask, validationNoise, optimizerLayout, ...
                parameterVector, params, toc(startTime));
        end
        if shouldStop
            break;
        end
    end
    if isempty(bestModel)
        model = unpack_v2_trainables(staticModel, parameterVector, ...
            optimizerLayout);
        bestModel = extract_v2_model(model);
        history.bestIteration = iteration;
        history.bestValidationLoss = history.loss(iteration);
    end
    learnedModel = bestModel;
    history.updatesCompleted = iteration;
    history.elapsedSeconds = toc(startTime);
    history.additionalUpdatesCompleted = iteration - startIteration + 1;
    history.secondsPerUpdate = history.elapsedSeconds / ...
        history.additionalUpdatesCompleted;
    history = trim_history(history, iteration);
end

function validate_resume_checkpoint(checkpoint, stageName, maxIterations)
    required = {'currentModel', 'average', 'averageSquared', ...
        'parameterVector', 'optimizerLayout', 'history', 'iteration', ...
        'currentLearnRate', 'stageName', 'scheduler', 'rng', ...
        'validationTask', 'validationNoise'};
    for index = 1:numel(required)
        if ~isfield(checkpoint, required{index})
            error('V2Model:ResumeCheckpoint', ...
                'Resume checkpoint lacks %s.', required{index});
        end
    end
    if ~strcmpi(char(checkpoint.stageName), char(stageName))
        error('V2Model:ResumeStage', ...
            'Checkpoint stage does not match requested stage.');
    end
    if checkpoint.iteration >= maxIterations
        error('V2Model:ResumeIteration', ...
            'Maximum iteration must exceed checkpoint iteration.');
    end
end

function noise = move_noise(input, useGpu)
    noise.enabled = input.enabled;
    noise.initial = move_dlarray(input.initial, useGpu);
    noise.dynamic = move_dlarray(input.dynamic, useGpu);
end

function value = move_dlarray(value, useGpu)
    if isa(value, 'dlarray')
        value = extractdata(value);
    end
    value = single(value);
    if useGpu
        value = gpuArray(value);
    end
    value = dlarray(value);
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

function history = extend_history(previous, count, stageName, noisy, ...
        accelerated, gpuName)
    history = initialize_history(count, stageName, noisy, accelerated, gpuName);
    sampleFields = {'loss', 'validationLoss', 'learningRate', 'gradientNorm'};
    for fieldIndex = 1:numel(sampleFields)
        name = sampleFields{fieldIndex};
        if isfield(previous, name)
            copied = min(numel(previous.(name)), count);
            history.(name)(1:copied) = previous.(name)(1:copied);
        end
    end
    groups = {'trainingComponents', 'validationComponents'};
    for groupIndex = 1:numel(groups)
        group = groups{groupIndex};
        currentNames = fieldnames(history.(group));
        for fieldIndex = 1:numel(currentNames)
            name = currentNames{fieldIndex};
            if isfield(previous, group) && ...
                    isfield(previous.(group), name)
                copied = min(numel(previous.(group).(name)), count);
                history.(group).(name)(1:copied) = ...
                    previous.(group).(name)(1:copied);
            end
        end
    end
    preserved = {'variableDelay', 'usedGpu', 'gpuName', ...
        'usedAccelerated'};
    for fieldIndex = 1:numel(preserved)
        name = preserved{fieldIndex};
        if isfield(previous, name)
            history.(name) = previous.(name);
        end
    end
end

function output = record_components(output, components, iteration)
    names = loss_component_names();
    for index = 1:numel(names)
        output.(names{index})(iteration) = scalar(components.(names{index}));
    end
end

function names = loss_component_names()
    names = {'preGoPosition', 'preGoVelocity', 'latePreGoVelocity', ...
        'endpointUrgency', ...
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
        averageSquared, history, iteration, learnRate, stageName, ...
        lastImprovement, lastRateDrop, taskStream, noiseStream, ...
        validationTaskStream, validationNoiseStream, validationTask, ...
        validationNoise, optimizerLayout, parameterVector, params, ...
        elapsedTrainingSeconds)
    checkpoint.currentModel = gather_struct(model);
    checkpoint.bestModel = bestModel;
    checkpoint.average = gather_value(average);
    checkpoint.averageSquared = gather_value(averageSquared);
    checkpoint.parameterVector = gather_value(parameterVector);
    checkpoint.optimizerLayout = optimizerLayout;
    checkpoint.history = trim_history(history, iteration);
    checkpoint.iteration = iteration;
    checkpoint.currentLearnRate = learnRate;
    checkpoint.stageName = char(stageName);
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
    checkpoint.elapsedTrainingSeconds = elapsedTrainingSeconds;
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
