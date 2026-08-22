function output = move_v2_model(input, useGpu)
    output = struct();
    names = fieldnames(input);
    for fieldIndex = 1:numel(names)
        value = input.(names{fieldIndex});
        if isa(value, 'dlarray')
            value = extractdata(value);
        end
        value = single(value);
        if useGpu
            value = gpuArray(value);
        end
        output.(names{fieldIndex}) = dlarray(value);
    end
end
