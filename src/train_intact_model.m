function [learnedModel, trainingHistory] = train_intact_model(params)
    learnables = initialize_intact_model(params);
    initialModel = extract_intact_model(learnables);
    initialWrec = initialModel.Wrec;
    initialUcb = initialModel.Ucb;

    trainableFields = {'Wtarg', 'Wgo', 'WcbHidden', 'bcbHidden', ...
        'WcbLatent', 'bcbLatent', 'Wout', 'Wrec'};
    allFields = fieldnames(learnables);
    multipliers = params.training.learningRateMultipliers;
    if multipliers.Ucb ~= 0 || any(strcmp(trainableFields, 'Ucb'))
        error('IntactModel:UcbMustRemainFixed', ...
            'Ucb must be excluded from the optimizer with multiplier zero.');
    end
    if params.training.batchSize ~= ...
            params.task.numTargets * params.training.trialsPerTarget
        error('IntactModel:BatchSize', ...
            'Batch size must equal targets times trials per target.');
    end

    useGpu = params.training.useGpuIfAvailable && canUseGPU;
    if useGpu
        for fieldIndex = 1:numel(allFields)
            fieldName = allFields{fieldIndex};
            learnables.(fieldName) = dlarray(gpuArray( ...
                extractdata(learnables.(fieldName))));
        end
    end
    trainingParams = prepare_device_params(params, useGpu);
    validationParams = trainingParams;
    trainingTaskStream = RandStream('mt19937ar', ...
        'Seed', params.seed.trainingTask);
    trainingNoiseStream = RandStream('mt19937ar', ...
        'Seed', params.seed.trainingNoise);
    validationTaskStream = RandStream('mt19937ar', ...
        'Seed', params.seed.validationTask);
    validationNoiseStream = RandStream('mt19937ar', ...
        'Seed', params.seed.validationNoise);

    validationTask = sample_balanced_task(params, ...
        params.training.validationTrialsPerTarget, validationTaskStream);
    validationGradientTask = prepare_gradient_task( ...
        validationTask, validationParams, useGpu);
    validationNoise = sample_noise(validationNoiseStream, ...
        validationTask, params.model.numCorticalUnits, useGpu);

    trailingAverage = struct();
    trailingAverageSquared = struct();
    for fieldIndex = 1:numel(trainableFields)
        fieldName = trainableFields{fieldIndex};
        trailingAverage.(fieldName) = [];
        trailingAverageSquared.(fieldName) = [];
    end

    maxIterations = params.training.stageAIterations + ...
        params.training.stageBMaxIterations;
    numTrials = params.training.batchSize;
    componentNames = {'total', 'behavioral', 'position', 'velocity', ...
        'terminalPosition', 'terminalVelocity', 'preGo', 'joint', ...
        'torque', 'activity', 'weight'};
    trainingHistory.iteration = (1:maxIterations)';
    for componentIndex = 1:numel(componentNames)
        trainingHistory.([componentNames{componentIndex}, 'Loss']) = ...
            nan(maxIterations, 1);
        trainingHistory.(['validation', ...
            upper_first(componentNames{componentIndex}), 'Loss']) = ...
            nan(maxIterations, 1);
    end
    trainingHistory.baseLearningRate = nan(maxIterations, 1);
    trainingHistory.stage = strings(maxIterations, 1);
    trainingHistory.goTimeMs = zeros(numTrials, maxIterations, 'single');
    trainingHistory.targetIndex = ...
        zeros(numTrials, maxIterations, 'uint8');
    trainingHistory.seeds = params.seed;
    trainingHistory.batchSize = numTrials;
    trainingHistory.trialsPerTarget = params.training.trialsPerTarget;
    trainingHistory.learningRateMultipliers = multipliers;
    trainingHistory.trainableParameterFields = trainableFields;
    trainingHistory.frozenParameterFields = {'Ucb'};
    trainingHistory.validationGoTimeMs = validationTask.goTimeMs;
    trainingHistory.validationTargetIndex = validationTask.targetIndex;
    trainingHistory.usedGpu = useGpu;
    trainingHistory.usedAcceleratedGradientFunction = ...
        params.training.useAcceleratedGradientFunction;
    if useGpu
        gpu = gpuDevice;
        trainingHistory.executionEnvironment = gpu.Name;
    else
        trainingHistory.executionEnvironment = 'CPU';
    end
    fprintf('Training execution environment: %s\n', ...
        trainingHistory.executionEnvironment);

    if params.training.useAcceleratedGradientFunction
        gradientFunction = dlaccelerate(@intact_model_gradients);
    else
        gradientFunction = @intact_model_gradients;
    end

    bestValidationBehavioralLoss = inf;
    bestValidationTotalLoss = inf;
    bestValidationIteration = NaN;
    bestValidationComponents = struct();
    bestModel = [];
    lastImprovementIteration = params.training.stageAIterations;
    stoppedEarly = false;
    startTime = tic;

    for iteration = 1:maxIterations
        inStageA = iteration <= params.training.stageAIterations;
        if inStageA
            stageName = "A-deterministic";
            lossParams = trainingParams;
            lossParams.noise.sigmaInitial = 0;
            lossParams.noise.sigmaDynamic = 0;
            baseLearningRate = params.training.stageABaseLearnRate;
            stageBIteration = 0;
        else
            stageName = "B-noisy";
            lossParams = trainingParams;
            baseLearningRate = params.training.stageBBaseLearnRate;
            stageBIteration = iteration - params.training.stageAIterations;
            if stageBIteration >= ...
                    params.training.stageBLearnRateDropIteration
                baseLearningRate = baseLearningRate * ...
                    params.training.learnRateDropFactor;
            end
        end

        trainingTask = sample_balanced_task(params, ...
            params.training.trialsPerTarget, trainingTaskStream);
        gradientTask = prepare_gradient_task( ...
            trainingTask, lossParams, useGpu);
        noise = sample_noise(trainingNoiseStream, trainingTask, ...
            params.model.numCorticalUnits, useGpu);

        [loss, gradients, components] = dlfeval(gradientFunction, ...
            learnables, gradientTask, lossParams, noise);
        gradients = clip_gradient_struct(gradients, ...
            params.training.gradientThreshold);

        for fieldIndex = 1:numel(trainableFields)
            fieldName = trainableFields{fieldIndex};
            parameterLearningRate = baseLearningRate * ...
                multipliers.(fieldName);
            [learnables.(fieldName), trailingAverage.(fieldName), ...
                trailingAverageSquared.(fieldName)] = adamupdate( ...
                learnables.(fieldName), gradients.(fieldName), ...
                trailingAverage.(fieldName), ...
                trailingAverageSquared.(fieldName), iteration, ...
                parameterLearningRate, ...
                params.training.gradientDecayFactor, ...
                params.training.squaredGradientDecayFactor, ...
                params.training.adamEpsilon);
        end

        trainingHistory.totalLoss(iteration) = scalar_value(loss);
        componentValues = scalar_components(components);
        for componentIndex = 2:numel(componentNames)
            componentName = componentNames{componentIndex};
            trainingHistory.([componentName, 'Loss'])(iteration) = ...
                componentValues.(componentName);
        end
        trainingHistory.baseLearningRate(iteration) = baseLearningRate;
        trainingHistory.stage(iteration) = stageName;
        trainingHistory.goTimeMs(:, iteration) = ...
            single(trainingTask.goTimeMs(:));
        trainingHistory.targetIndex(:, iteration) = ...
            uint8(trainingTask.targetIndex(:));

        validationDue = mod(iteration, ...
            params.training.validationFrequency) == 0;
        if validationDue
            [validationLoss, validationComponents] = dlfeval( ...
                @intact_model_loss, learnables, validationGradientTask, ...
                validationParams, validationNoise);
            validationValues = scalar_components(validationComponents);
            trainingHistory.validationTotalLoss(iteration) = ...
                scalar_value(validationLoss);
            for componentIndex = 2:numel(componentNames)
                componentName = componentNames{componentIndex};
                historyField = ['validation', ...
                    upper_first(componentName), 'Loss'];
                trainingHistory.(historyField)(iteration) = ...
                    validationValues.(componentName);
            end

            if ~inStageA && validationValues.behavioral < ...
                    bestValidationBehavioralLoss - ...
                    params.training.minimumValidationImprovement
                bestValidationBehavioralLoss = validationValues.behavioral;
                bestValidationTotalLoss = scalar_value(validationLoss);
                bestValidationIteration = iteration;
                bestValidationComponents = validationValues;
                bestModel = extract_intact_model(learnables);
                lastImprovementIteration = iteration;
            end
        end

        if iteration == 1 || mod(iteration, ...
                params.training.displayEvery) == 0
            validationText = '';
            if validationDue
                validationText = sprintf(' | val behavioral %.6f', ...
                    trainingHistory.validationBehavioralLoss(iteration));
            end
            fprintf(['Iteration %4d/%4d | %s | loss %.6f | ', ...
                'position %.6f | velocity %.6f | terminal p %.6f | ', ...
                'terminal v %.6f | pre-go %.6f%s\n'], ...
                iteration, maxIterations, stageName, ...
                trainingHistory.totalLoss(iteration), ...
                trainingHistory.positionLoss(iteration), ...
                trainingHistory.velocityLoss(iteration), ...
                trainingHistory.terminalPositionLoss(iteration), ...
                trainingHistory.terminalVelocityLoss(iteration), ...
                trainingHistory.preGoLoss(iteration), validationText);
        end

        plateauReached = ~inStageA && ...
            stageBIteration >= params.training.minimumStageBIterations && ...
            iteration - lastImprovementIteration >= ...
                params.training.earlyStoppingPatienceUpdates;
        if plateauReached
            stoppedEarly = true;
            fprintf(['Early stopping after %d noisy-stage updates; ', ...
                'validation did not improve for %d updates.\n'], ...
                stageBIteration, ...
                params.training.earlyStoppingPatienceUpdates);
            break;
        end
    end

    updatesCompleted = iteration;
    if isempty(bestModel)
        error('IntactModel:NoNoisyValidationCheckpoint', ...
            'No noisy-stage validation checkpoint was created.');
    end

    learnedModel = bestModel;
    trainingHistory.elapsedSeconds = toc(startTime);
    trainingHistory.updatesCompleted = updatesCompleted;
    trainingHistory.stageAUpdatesCompleted = min( ...
        updatesCompleted, params.training.stageAIterations);
    trainingHistory.stageBUpdatesCompleted = max( ...
        0, updatesCompleted - params.training.stageAIterations);
    trainingHistory.stoppedEarly = stoppedEarly;
    trainingHistory.bestValidationIteration = bestValidationIteration;
    trainingHistory.bestValidationBehavioralLoss = ...
        bestValidationBehavioralLoss;
    trainingHistory.bestValidationTotalLoss = bestValidationTotalLoss;
    trainingHistory.bestValidationComponents = bestValidationComponents;
    trainingHistory.finalTrainingComponents = struct();
    for componentIndex = 1:numel(componentNames)
        componentName = componentNames{componentIndex};
        trainingHistory.finalTrainingComponents.(componentName) = ...
            trainingHistory.([componentName, 'Loss'])(updatesCompleted);
    end
    trainingHistory.initialWrec = initialWrec;
    trainingHistory.initialUcb = initialUcb;
    trainingHistory.normalizedWrecChange = norm( ...
        double(learnedModel.Wrec - initialWrec), 'fro') / ...
        norm(double(initialWrec), 'fro');
    trainingHistory.absoluteUcbChange = norm( ...
        double(learnedModel.Ucb - initialUcb), 'fro');
    trainingHistory.ucbFixedWithinMachinePrecision = ...
        trainingHistory.absoluteUcbChange == 0;
    trainingHistory = trim_history(trainingHistory, updatesCompleted);
end

function task = sample_balanced_task(params, trialsPerTarget, stream)
    numTargets = params.task.numTargets;
    numTrials = numTargets * trialsPerTarget;
    targetIndex = repelem(1:numTargets, trialsPerTarget);
    targetIndex = targetIndex(randperm(stream, numTrials));
    allowedGoTimes = params.task.minimumGoTimeMs:params.model.dtMs: ...
        params.task.maximumGoTimeMs;
    sampledIndices = randi(stream, numel(allowedGoTimes), 1, numTrials);
    goTimeMs = allowedGoTimes(sampledIndices);
    task = build_reach_task(params, trialsPerTarget, ...
        goTimeMs, targetIndex);
end

function noise = sample_noise(stream, task, numUnits, useGpu)
    initialNoise = randn(stream, numUnits, task.numTrials, 'single');
    dynamicNoise = randn(stream, numUnits, task.numTrials, ...
        task.numTimeSteps - 1, 'single');
    if useGpu
        initialNoise = gpuArray(initialNoise);
        dynamicNoise = gpuArray(dynamicNoise);
    end
    noise.initial = dlarray(initialNoise);
    noise.dynamic = dlarray(dynamicNoise);
end

function params = prepare_device_params(params, useGpu)
    if ~useGpu
        return;
    end
    plantFields = {'L1', 'L2', 'm1', 'm2', 'lc1', 'lc2', 'I1', 'I2', ...
        'damping', 'initialJointAnglesRad', ...
        'initialJointVelocityRadPerSec', 'jointLowerLimitsRad', ...
        'jointUpperLimitsRad', 'jointPenaltyMarginRad', ...
        'jointPenaltySoftnessRad', 'torqueGuidelineNm', ...
        'torquePenaltySoftnessNm', 'hardTorqueSafetyLimitNm'};
    for fieldIndex = 1:numel(plantFields)
        fieldName = plantFields{fieldIndex};
        params.plant.(fieldName) = gpuArray(single( ...
            params.plant.(fieldName)));
    end
end

function values = scalar_components(components)
    componentFields = fieldnames(components);
    values = struct();
    for fieldIndex = 1:numel(componentFields)
        fieldName = componentFields{fieldIndex};
        values.(fieldName) = scalar_value(components.(fieldName));
    end
end

function value = scalar_value(inputValue)
    value = double(gather(extractdata(inputValue)));
end

function output = upper_first(input)
    output = [upper(input(1)), input(2:end)];
end

function history = trim_history(history, updatesCompleted)
    fields = fieldnames(history);
    for fieldIndex = 1:numel(fields)
        fieldName = fields{fieldIndex};
        value = history.(fieldName);
        if isnumeric(value) || islogical(value) || isstring(value)
            if isvector(value) && numel(value) >= updatesCompleted && ...
                    numel(value) > 1
                if size(value, 1) >= updatesCompleted && size(value, 2) == 1
                    history.(fieldName) = value(1:updatesCompleted, :);
                elseif size(value, 2) >= updatesCompleted && ...
                        size(value, 1) == history.batchSize
                    history.(fieldName) = value(:, 1:updatesCompleted);
                end
            elseif ismatrix(value) && size(value, 2) >= updatesCompleted && ...
                    size(value, 1) == history.batchSize
                history.(fieldName) = value(:, 1:updatesCompleted);
            end
        end
    end
end
