function report = run_v3_smoke_tests(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(mfilename('fullpath'));
    end
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src'));
    addpath(fullfile(projectRoot, 'analysis'));

    params = v3_model_params();
    fixed = construct_v3_hybrid_recurrence(params, projectRoot);
    model = initialize_v3_model(params, fixed);
    numericModel = extract_v3_model(model);
    n = params.model.numCorticalUnits;

    targetIndex = repelem(1:params.task.numTargets, ...
        numel(params.smoke.delaysMs));
    goTimes = repmat(params.smoke.delaysMs, ...
        1, params.task.numTargets);
    task = build_v3_task(params, numel(params.smoke.delaysMs), ...
        goTimes, targetIndex);
    simulation = simulate_v3_model(numericModel, task, params, ...
        params.seed.smokeSimulation, false);
    expectedTimeSteps = params.task.maximumTrialDurationMs / ...
        params.model.dtMs + 1;
    assert(isequal(size(simulation.state), ...
        [n task.numTrials expectedTimeSteps]));
    assert(isequal(size(simulation.rates), ...
        [n task.numTrials expectedTimeSteps]));
    assert(isequal(size(simulation.cerebellarLatent), ...
        [params.model.cerebellarRank task.numTrials expectedTimeSteps]));
    assert(isequal(size(simulation.cerebellarDrive), ...
        [n task.numTrials expectedTimeSteps]));
    assert(isequal(size(simulation.velocity), ...
        [2 task.numTrials expectedTimeSteps]));
    assert(isequal(size(simulation.position), ...
        [2 task.numTrials expectedTimeSteps]));
    forwardFields = {'state', 'rates', 'cerebellarLatent', ...
        'cerebellarDrive', 'velocity', 'position'};
    for fieldIndex = 1:numel(forwardFields)
        assert(all(isfinite(simulation.(forwardFields{fieldIndex})), 'all'));
    end
    report.forwardSimulation = 'PASS';

    forbiddenInputs = {'go', 'corticalState', 'handState', 'velocity', ...
        'targetCoordinates', 'targetAngle', 'desiredTrajectory', ...
        'futureKinematics', 'elapsedTime'};
    assert(isequal(params.model.cerebellarInputNames, {'targetIdentity'}));
    assert(isempty(intersect(params.model.cerebellarInputNames, ...
        forbiddenInputs)));
    assert(size(model.WcbHidden, 2) == params.task.numTargets);
    assert(nargin('compute_v3_cerebellar_target') == 2);
    assert(size(model.Wgo, 2) == 1);
    assert(~any(task.goSignal(logical(task.preGoMask))));
    for delay = params.smoke.delaysMs
        trials = find(double(task.goTimeMs) == delay);
        referenceGo = task.goSignal(trials(1), :);
        assert(all(task.goSignal(trials, :) == referenceGo, 'all'));
    end
    assert(all(sum(task.goSignal, 2) == ...
        params.task.goPulseDurationMs / params.model.dtMs));
    report.inputLeakage = 'PASS';

    trainableFields = v3_trainable_fields();
    assert(~ismember('Wrec', trainableFields));
    [parameterVector, layout] = pack_v3_trainables(model);
    assert(~ismember('Wrec', layout.names));
    useGpu = params.smoke.useGpuForGradients && canUseGPU;
    deviceModel = move_v3_model(model, useGpu);
    deviceTask = prepare_v3_gradient_task(task, useGpu);
    noiseStream = RandStream('mt19937ar', ...
        'Seed', params.seed.trainingNoise);
    noise = sample_v3_noise(task, params, false, noiseStream, useGpu);
    [loss, gradients, components] = dlfeval(@v3_model_gradients, ...
        deviceModel, deviceTask, params, noise);
    assert(isfinite(to_scalar(loss)));
    componentNames = fieldnames(components);
    for componentIndex = 1:numel(componentNames)
        assert(isfinite(to_scalar(components.( ...
            componentNames{componentIndex}))));
    end
    gradientNorms = struct();
    for fieldIndex = 1:numel(trainableFields)
        name = trainableFields{fieldIndex};
        gradient = extractdata(gradients.(name));
        gradientNorms.(name) = double(gather(sqrt(sum(gradient.^2, 'all'))));
        assert(isfinite(gradientNorms.(name)) && gradientNorms.(name) > 0);
    end
    [deviceParameterVector, deviceLayout] = ...
        pack_v3_trainables(deviceModel);
    gradientVector = pack_v3_trainables(gradients);
    [updatedVector, ~, ~] = adamupdate(deviceParameterVector, ...
        gradientVector, [], [], 1, params.smoke.optimizerLearnRate, ...
        0.9, 0.999, 1e-8);
    staticModel = rmfield(deviceModel, trainableFields);
    updatedModel = unpack_v3_trainables( ...
        staticModel, updatedVector, deviceLayout);
    originalWrec = gather(extractdata(deviceModel.Wrec));
    updatedWrec = gather(extractdata(updatedModel.Wrec));
    recurrentUpdateDifference = max(abs( ...
        originalWrec(:) - updatedWrec(:)));
    assert(recurrentUpdateDifference == 0);
    assert(layout.totalCount == numel(parameterVector));
    report.gradientPlumbing = 'PASS';
    report.fixedRecurrence = 'PASS';
    report.gradientNorms = gradientNorms;
    report.trainableParameterCount = layout.totalCount;

    canonicalTask = build_v3_task(params, 1, ...
        params.task.canonicalGoTimeMs, []);
    canonicalSimulation = simulate_v3_model(numericModel, canonicalTask, ...
        params, params.seed.smokeSimulation, false);
    maximumMaskDifference = 0;
    selectedPrepRates = [];
    selectedMoveRates = [];
    for trial = 1:canonicalTask.numTrials
        prepIndex = canonicalTask.goIndexByTrial(trial) - 1;
        movementIndices = canonicalTask.goIndexByTrial(trial): ...
            min(canonicalTask.goIndexByTrial(trial) + ...
            round(200 / params.model.dtMs), canonicalTask.numTimeSteps);
        prepRates = canonicalSimulation.rates(:, trial, prepIndex);
        for movementIndex = movementIndices
            moveRates = canonicalSimulation.rates(:, trial, movementIndex);
            difference = nnz((prepRates > 0) ~= (moveRates > 0));
            if difference > maximumMaskDifference
                maximumMaskDifference = difference;
                selectedPrepRates = prepRates;
                selectedMoveRates = moveRates;
            end
        end
    end
    assert(maximumMaskDifference > 0);
    effective = analyze_v3_effective_dynamics( ...
        numericModel.Wrec, selectedPrepRates, selectedMoveRates);
    assert(effective.activeSetDifferenceCount == maximumMaskDifference);
    assert(effective.effectiveDifferenceFrobenius > 0);
    assert(nnz(strcmp(fieldnames(numericModel), 'Wrec')) == 1);
    assert(isequal(numericModel.Wrec, fixed.Wrec));
    report.effectiveDynamics = 'PASS';
    report.activeSetDifferenceCount = maximumMaskDifference;
    report.effectiveDifferenceFrobenius = ...
        effective.effectiveDifferenceFrobenius;

    checkpointPath = fullfile(projectRoot, params.files.smokeCheckpoint);
    checkpointDirectory = fileparts(checkpointPath);
    if ~exist(checkpointDirectory, 'dir')
        mkdir(checkpointDirectory);
    end
    checkpoint.model = numericModel;
    checkpoint.fixed = fixed;
    checkpoint.params = params;
    save(checkpointPath, 'checkpoint');
    cleanup = onCleanup(@() delete_if_present(checkpointPath));
    loaded = load(checkpointPath, 'checkpoint');
    roundTripSimulation = simulate_v3_model(loaded.checkpoint.model, ...
        canonicalTask, loaded.checkpoint.params, ...
        params.seed.smokeSimulation, false);
    roundTripFields = {'state', 'rates', 'cerebellarLatent', ...
        'cerebellarDrive', 'velocity', 'position'};
    roundTripMaximumDifference = 0;
    for fieldIndex = 1:numel(roundTripFields)
        name = roundTripFields{fieldIndex};
        difference = max(abs(canonicalSimulation.(name) - ...
            roundTripSimulation.(name)), [], 'all');
        roundTripMaximumDifference = max( ...
            roundTripMaximumDifference, double(difference));
    end
    assert(roundTripMaximumDifference <= params.smoke.numericTolerance);
    delete_if_present(checkpointPath);
    clear cleanup;
    report.checkpointRoundTrip = 'PASS';
    report.checkpointMaximumDifference = roundTripMaximumDifference;

    geometry = compute_v3_neural_geometry( ...
        canonicalSimulation, canonicalTask, params);
    null = compute_v3_alignment_null( ...
        geometry.preparatoryCovariance, geometry.movementCovariance, ...
        geometry.commonDimension, params.analysis.smokeNullSamples, ...
        params.seed.geometryNull);
    geometryValues = [geometry.k95Preparatory, geometry.k95Movement, ...
        geometry.commonDimension, ...
        geometry.alignment.preparatoryToMovement, ...
        geometry.alignment.movementToPreparatory, ...
        geometry.curves.preparatoryByPreparatoryPercent, ...
        geometry.curves.preparatoryByMovementPercent, ...
        geometry.curves.movementByMovementPercent, ...
        geometry.curves.movementByPreparatoryPercent, ...
        null.preparatoryToRandom, null.movementToRandom];
    assert(all(isfinite(geometryValues)));
    report.neuralGeometryPipeline = 'PASS';
    report.geometry.k95Preparatory = geometry.k95Preparatory;
    report.geometry.k95Movement = geometry.k95Movement;
    report.geometry.commonDimension = geometry.commonDimension;
    report.geometry.preparatoryToMovement = ...
        geometry.alignment.preparatoryToMovement;
    report.geometry.movementToPreparatory = ...
        geometry.alignment.movementToPreparatory;
    report.geometry.nullSamples = params.analysis.smokeNullSamples;

    verify_prego_masks(task, params);
    report.behavioralLoss = 'PASS';
    report.loss = to_scalar(loss);
    report.lossComponents = struct();
    for componentIndex = 1:numel(componentNames)
        name = componentNames{componentIndex};
        report.lossComponents.(name) = to_scalar(components.(name));
    end

    report.hybrid = fixed.hybrid;
    report.reference = fixed.reference;
    report.useGpuForGradients = useGpu;
    if useGpu
        device = gpuDevice;
        report.gradientDevice = device.Name;
    else
        report.gradientDevice = 'CPU';
    end
    report.deterministicTrainingRun = false;
    fprintf(['V3_SMOKE_PASS loss=%.9g parameters=%d activeSetChanges=%d ', ...
        'checkpointMaxDiff=%.3g gradientDevice=%s\n'], report.loss, ...
        report.trainableParameterCount, report.activeSetDifferenceCount, ...
        report.checkpointMaximumDifference, report.gradientDevice);
    fprintf(['V3_HYBRID scale=%.9g spectralAbscissa=%.9g ', ...
        'frobenius=%.9g nonnormality=%.9g prepMoveOverlap=%.3g\n'], ...
        fixed.hybrid.globalNormalization, ...
        fixed.hybrid.spectralAbscissa, fixed.hybrid.frobeniusNorm, ...
        fixed.hybrid.nonnormalCommutator, ...
        fixed.hybrid.prepMoveBasisOverlap);
    fprintf(['V3_GEOMETRY_PIPELINE_ONLY k95Prep=%d k95Move=%d k=%d ', ...
        'prepToMove=%.6g moveToPrep=%.6g nullSamples=%d\n'], ...
        report.geometry.k95Preparatory, report.geometry.k95Movement, ...
        report.geometry.commonDimension, ...
        report.geometry.preparatoryToMovement, ...
        report.geometry.movementToPreparatory, ...
        report.geometry.nullSamples);
    fprintf('No deterministic V3 training has been run.\n');
end

function verify_prego_masks(task, params)
    expectedLateSamples = params.training.latePreGoWindowMs / ...
        params.model.dtMs;
    for delay = params.smoke.delaysMs
        trial = find(double(task.goTimeMs) == delay, 1, 'first');
        preIndices = find(task.preGoMask(trial, :));
        lateIndices = find(task.latePreGoMask(trial, :));
        goIndex = task.goIndexByTrial(trial);
        assert(numel(preIndices) == delay / params.model.dtMs);
        assert(task.timeMs(preIndices(end)) == delay - params.model.dtMs);
        assert(numel(lateIndices) == expectedLateSamples);
        assert(task.timeMs(lateIndices(1)) == ...
            delay - params.training.latePreGoWindowMs);
        assert(task.timeMs(lateIndices(end)) == ...
            delay - params.model.dtMs);
        assert(~task.preGoMask(trial, goIndex));
        assert(~task.latePreGoMask(trial, goIndex));
    end
end

function value = to_scalar(value)
    if isa(value, 'dlarray')
        value = extractdata(value);
    end
    value = double(gather(value));
end

function delete_if_present(path)
    if exist(path, 'file')
        delete(path);
    end
end
