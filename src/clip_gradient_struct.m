function gradients = clip_gradient_struct(gradients, threshold)
    fieldNames = fieldnames(gradients);
    sumSquares = 0;

    for fieldIndex = 1:numel(fieldNames)
        gradientData = extractdata(gradients.(fieldNames{fieldIndex}));
        sumSquares = sumSquares + double(sum(gradientData.^2, 'all'));
    end

    globalNorm = sqrt(sumSquares);

    if globalNorm > threshold
        scale = threshold / globalNorm;
        for fieldIndex = 1:numel(fieldNames)
            fieldName = fieldNames{fieldIndex};
            gradients.(fieldName) = gradients.(fieldName) * scale;
        end
    end
end
