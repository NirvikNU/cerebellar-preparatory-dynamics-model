function multiplier = v3_optimizer_multiplier_vector( ...
        layout, params, useGpu)
    values = ones(layout.totalCount, 1, 'single');
    for fieldIndex = 1:numel(layout.names)
        name = layout.names{fieldIndex};
        values(layout.indices{fieldIndex}) = single( ...
            params.training.learningRateMultipliers.(name));
    end
    if useGpu
        values = gpuArray(values);
    end
    multiplier = dlarray(values);
end
