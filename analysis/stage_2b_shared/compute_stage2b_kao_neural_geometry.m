function geometry = compute_stage2b_kao_neural_geometry(model, preparation, ...
        movement, preparationTimesS, movementTimesAfterControlRemovalS, method)
    arguments
        model
        preparation
        movement
        preparationTimesS double
        movementTimesAfterControlRemovalS double
        method (1, 1) string {mustBeMember(method, ...
            ["sd-floor-1", "range-plus-5"])} = "sd-floor-1"
    end
    prepIndices = round(preparationTimesS / model.samplingDt) + 1;
    moveIndices = round(movementTimesAfterControlRemovalS / ...
        model.samplingDt) + 1;
    prepRaw = permute(max(preparation.states(prepIndices, :, :), 0), ...
        [1, 3, 2]);
    moveRaw = permute(movement.rates(moveIndices, :, :), [1, 3, 2]);
    combined = reshape(cat(1, prepRaw, moveRaw), [], model.n);
    if method == "sd-floor-1"
        scale = max(std(combined, 0, 1), 1);
        description = ['Neuron-wise SD over the selected preparation-plus-' ...
            'movement target-by-time samples, floored at 1; divide by this ' ...
            'SD; subtract the across-target mean independently at each time.'];
    else
        scale = max(combined, [], 1) - min(combined, [], 1) + 5;
        description = ['Kao/Elsayed provenance preprocessing: divide by the ' ...
            'selected full-task range plus 5; subtract the across-target ' ...
            'mean independently at each time.'];
    end
    prepNormalized = prepRaw ./ reshape(scale, 1, 1, []);
    moveNormalized = moveRaw ./ reshape(scale, 1, 1, []);
    prepCentered = prepNormalized - mean(prepNormalized, 2);
    moveCentered = moveNormalized - mean(moveNormalized, 2);
    prepMatrix = reshape(permute(prepCentered, [3, 1, 2]), model.n, []);
    moveMatrix = reshape(permute(moveCentered, [3, 1, 2]), model.n, []);
    fullMatrix = [prepMatrix, moveMatrix];
    Cprep = prepMatrix * prepMatrix.';
    Cmove = moveMatrix * moveMatrix.';
    Cfull = fullMatrix * fullMatrix.';
    [prepVectors, prepValues] = sorted_spectrum(Cprep);
    [moveVectors, moveValues] = sorted_spectrum(Cmove);
    geometry.prepMatrix = prepMatrix;
    geometry.moveMatrix = moveMatrix;
    geometry.Cprep = Cprep;
    geometry.Cmove = Cmove;
    geometry.Cfull = Cfull;
    geometry.prepVectors = prepVectors;
    geometry.moveVectors = moveVectors;
    geometry.prepValues = prepValues;
    geometry.moveValues = moveValues;
    geometry.preparationParticipationRatio = participation_ratio(prepValues);
    geometry.movementParticipationRatio = participation_ratio(moveValues);
    geometry.scale = scale;
    geometry.method = method;
    geometry.description = description;
    assert(size(prepMatrix, 2) == 30 * model.nMovements);
    assert(size(moveMatrix, 2) == 30 * model.nMovements);
    assert(all(isfinite(fullMatrix), 'all'));
    prepMean = mean(prepCentered, 2);
    moveMean = mean(moveCentered, 2);
    assert(norm(prepMean(:)) < 1e-12);
    assert(norm(moveMean(:)) < 1e-12);
end

function [vectors, values] = sorted_spectrum(matrix)
    matrix = 0.5 * (matrix + matrix.');
    [vectors, singular] = svd(matrix, 'econ');
    values = max(real(diag(singular)), 0);
end

function value = participation_ratio(eigenvalues)
    eigenvalues = max(real(eigenvalues), 0);
    value = sum(eigenvalues) ^ 2 / max(sum(eigenvalues .^ 2), eps);
end
