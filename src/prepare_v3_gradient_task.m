function output = prepare_v3_gradient_task(task, useGpu)
    fields = {'targetInput', 'goSignal', 'relaxationScale', ...
        'trialTargetPositions', 'preGoMask', 'latePreGoMask', ...
        'movementMask', 'terminalMask', 'holdMask', 'endpointUrgency'};
    output.numTrials = task.numTrials;
    output.numTimeSteps = task.numTimeSteps;
    output.dtSeconds = move_value(single(task.dtSeconds), useGpu);
    for fieldIndex = 1:numel(fields)
        name = fields{fieldIndex};
        output.(name) = dlarray(move_value(single(task.(name)), useGpu));
    end
end

function value = move_value(value, useGpu)
    if useGpu
        value = gpuArray(value);
    end
end
