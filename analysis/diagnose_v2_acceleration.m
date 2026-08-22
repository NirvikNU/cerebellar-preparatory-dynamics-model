function report = diagnose_v2_acceleration(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src'));
    params = v2_model_params();
    params.files.isnMatrix = fullfile(projectRoot, params.files.isnMatrix);
    gpu = select_required_gpu(params.model.requiredGpuName);
    fixed = load_hennequin_isn(params, '');
    model = move_v2_model(initialize_v2_model(params, fixed), true);
    stream = RandStream('mt19937ar', 'Seed', ...
        params.seed.trainingTask + 1900);
    taskA = sample_balanced_v2_task(params, ...
        params.training.trialsPerTarget, stream);
    taskB = sample_balanced_v2_task(params, ...
        params.training.trialsPerTarget, stream);
    deviceTaskA = prepare_v2_gradient_task(taskA, true);
    deviceTaskB = prepare_v2_gradient_task(taskB, true);
    noiseA = sample_v2_noise(taskA, params, false, stream, true);
    noiseB = sample_v2_noise(taskB, params, false, stream, true);

    report.taskShapesInvariant = task_shapes_are_equal(deviceTaskA, ...
        deviceTaskB);
    report.goTimesDiffer = ~isequal(taskA.goTimeMs, taskB.goTimeMs);
    report.signatureBefore = describe_arguments(model, deviceTaskA, ...
        params, noiseA);

    legacy = dlaccelerate(@v2_model_gradients);
    timed_no_output(legacy, model, deviceTaskA, params, noiseA, gpu, ...
        'legacy zero-output initial trace');
    report.legacy(1) = cache_record(legacy, []);
    timed_no_output(legacy, model, deviceTaskA, params, noiseA, gpu, ...
        'legacy zero-output repeat');
    report.legacy(2) = cache_record(legacy, []);
    [loss, ~] = timed_call(legacy, model, deviceTaskA, ...
        params, noiseA, gpu, 'legacy two-output same inputs');
    report.legacy(3) = cache_record(legacy, loss);
    [loss, ~] = timed_call(legacy, model, deviceTaskA, ...
        params, noiseA, gpu, 'legacy two-output repeat');
    report.legacy(4) = cache_record(legacy, loss);
    [loss, gradients] = timed_call(legacy, model, deviceTaskB, ...
        params, noiseB, gpu, 'legacy new task values');
    report.legacy(5) = cache_record(legacy, loss);

    [parameterVector, layout] = pack_v2_trainables(model);
    gradientVector = pack_v2_trainables(gradients);
    [candidateVector, average, averageSquared] = adamupdate( ...
        parameterVector, gradientVector, [], [], 1, ...
        params.training.stageALearnRate, ...
        params.training.gradientDecayFactor, ...
        params.training.squaredGradientDecayFactor, ...
        params.training.adamEpsilon);
    multiplier = v2_optimizer_multiplier_vector(layout, params, true);
    updatedVector = parameterVector + multiplier .* ...
        (candidateVector - parameterVector);
    updatedModel = unpack_v2_trainables(model, updatedVector, layout);
    report.signatureAfter = describe_arguments(updatedModel, ...
        deviceTaskB, params, noiseB);
    report.publicSignaturesEqual = isequal(report.signatureBefore, ...
        report.signatureAfter);
    [loss, ~] = timed_call(legacy, updatedModel, deviceTaskB, params, ...
        noiseB, gpu, 'legacy after packed Adam update');
    report.legacy(6) = cache_record(legacy, loss);
    report.outputArityAddsTrace = ...
        report.legacy(3).occupancy > report.legacy(2).occupancy;
    report.taskValuesReuseTrace = ...
        report.legacy(5).occupancy == report.legacy(4).occupancy;
    report.updatedStructReusesTrace = ...
        report.legacy(6).occupancy == report.legacy(5).occupancy;

    staticModel = rmfield(model, v2_trainable_fields());
    packedCore = @(parameters, task, noise) v2_packed_model_gradients( ...
        parameters, staticModel, layout, task, params, noise);
    packed = dlaccelerate(packedCore);
    [loss, ~, ~] = timed_packed_call(packed, parameterVector, ...
        deviceTaskA, noiseA, gpu, 'packed initial trace');
    report.packed(1) = cache_record(packed, loss);
    [loss, packedGradient, ~] = timed_packed_call(packed, parameterVector, ...
        deviceTaskA, noiseA, gpu, 'packed identical repeat');
    report.packed(2) = cache_record(packed, loss);
    [candidateVector, ~, ~] = adamupdate( ...
        parameterVector, packedGradient, average, averageSquared, 2, ...
        params.training.stageALearnRate, ...
        params.training.gradientDecayFactor, ...
        params.training.squaredGradientDecayFactor, ...
        params.training.adamEpsilon);
    updatedVector = parameterVector + multiplier .* ...
        (candidateVector - parameterVector);
    [loss, ~, ~] = timed_packed_call(packed, updatedVector, deviceTaskB, ...
        noiseB, gpu, 'packed after Adam update and new task');
    report.packed(3) = cache_record(packed, loss);
    report.packedCacheReusedAfterUpdate = ...
        report.packed(3).occupancy == report.packed(2).occupancy;
    fprintf('Fixed task shapes: %d; public signatures equal: %d.\n', ...
        report.taskShapesInvariant, report.publicSignaturesEqual);
    fprintf(['Output arity adds trace: %d; task values reuse trace: %d; ', ...
        'updated struct reuses trace: %d.\n'], ...
        report.outputArityAddsTrace, report.taskValuesReuseTrace, ...
        report.updatedStructReusesTrace);
    fprintf('Packed cache reused after update: %d.\n', ...
        report.packedCacheReusedAfterUpdate);
end

function timed_no_output(functionHandle, model, task, params, noise, ...
        gpu, label)
    startTime = tic;
    dlfeval(functionHandle, model, task, params, noise);
    wait(gpu);
    elapsed = toc(startTime);
    fprintf('%-40s %8.4f s; occupancy %g; hit rate %.2f%%\n', ...
        label, elapsed, functionHandle.Occupancy, functionHandle.HitRate);
end

function [loss, gradients] = timed_call(functionHandle, model, task, ...
        params, noise, gpu, label)
    startTime = tic;
    [loss, gradients] = dlfeval(functionHandle, model, task, params, noise);
    wait(gpu);
    elapsed = toc(startTime);
    fprintf('%-40s %8.4f s; occupancy %g; hit rate %.2f%%\n', ...
        label, elapsed, functionHandle.Occupancy, functionHandle.HitRate);
end

function [loss, gradient, components] = timed_packed_call( ...
        functionHandle, parameters, ...
        task, noise, gpu, label)
    startTime = tic;
    [loss, gradient, components] = dlfeval(functionHandle, parameters, ...
        task, noise);
    wait(gpu);
    elapsed = toc(startTime);
    fprintf('%-40s %8.4f s; occupancy %g; hit rate %.2f%%\n', ...
        label, elapsed, functionHandle.Occupancy, functionHandle.HitRate);
end

function record = cache_record(functionHandle, loss)
    record.occupancy = functionHandle.Occupancy;
    record.hitRate = functionHandle.HitRate;
    if isempty(loss)
        record.loss = NaN;
    else
        record.loss = double(gather(extractdata(loss)));
    end
end

function tf = task_shapes_are_equal(first, second)
    firstFields = fieldnames(first);
    secondFields = fieldnames(second);
    tf = isequal(firstFields, secondFields);
    for fieldIndex = 1:numel(firstFields)
        name = firstFields{fieldIndex};
        tf = tf && isequal(size(first.(name)), size(second.(name))) && ...
            strcmp(class(first.(name)), class(second.(name)));
        if isa(first.(name), 'dlarray')
            tf = tf && isequal(dims(first.(name)), dims(second.(name))) && ...
                strcmp(underlying_class(first.(name)), ...
                underlying_class(second.(name))) && ...
                strcmp(device_name(first.(name)), device_name(second.(name)));
        end
    end
end

function signatures = describe_arguments(model, task, params, noise)
    signatures.model = describe_struct(model);
    signatures.task = describe_struct(task);
    signatures.params = describe_struct(params);
    signatures.noise = describe_struct(noise);
end

function description = describe_struct(value)
    names = fieldnames(value);
    description.fieldOrder = names;
    for fieldIndex = 1:numel(names)
        name = names{fieldIndex};
        field = value.(name);
        if isstruct(field)
            description.fields.(name) = describe_struct(field);
        else
            entry.class = class(field);
            entry.size = size(field);
            if isa(field, 'dlarray')
                entry.labels = dims(field);
                entry.underlyingClass = underlying_class(field);
                entry.device = device_name(field);
            else
                entry.labels = '';
                entry.underlyingClass = class(field);
                entry.device = 'cpu';
            end
            description.fields.(name) = entry;
        end
    end
end

function name = underlying_class(value)
    data = extractdata(value);
    if isa(data, 'gpuArray')
        name = classUnderlying(data);
    else
        name = class(data);
    end
end

function name = device_name(value)
    if isa(extractdata(value), 'gpuArray')
        name = 'gpu';
    else
        name = 'cpu';
    end
end
