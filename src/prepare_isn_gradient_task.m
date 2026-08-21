function output = prepare_isn_gradient_task(task, params, useGpu)
    fields = {'targetInput', 'goSignal', 'relaxationScale', ...
        'trialTargetPositions', 'centerPosition', 'preGoMask', ...
        'movementMask', 'terminalMask', 'holdMask', 'endpointUrgency'};
    output.numTrials = task.numTrials;
    output.numTimeSteps = task.numTimeSteps;
    output.dtSeconds = move(single(task.dtSeconds), useGpu);
    for fieldIndex = 1:numel(fields)
        name = fields{fieldIndex};
        output.(name) = dlarray(move(single(task.(name)), useGpu));
    end
    output.initialJointAngles = dlarray(move(repmat(single( ...
        params.plant.initialJointAnglesRad), 1, task.numTrials), useGpu));
    output.initialJointVelocity = dlarray(move(repmat(single( ...
        params.plant.initialJointVelocityRadPerSec), ...
        1, task.numTrials), useGpu));
end

function value = move(value, useGpu)
    if useGpu
        value = gpuArray(value);
    end
end
