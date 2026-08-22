function diagnostics = compute_v3_neural_geometry(simulation, task, params)
    rates = double(simulation.rates);
    n = size(rates, 1);
    nTargets = params.task.numTargets;
    nTimes = task.numTimeSteps;
    targetAverage = zeros(n, nTargets, nTimes);
    for targetIndex = 1:nTargets
        trials = find(task.targetIndex == targetIndex);
        if isempty(trials)
            error('V3Analysis:MissingTarget', ...
                'Every target must be represented in the activity tensor.');
        end
        targetAverage(:, targetIndex, :) = ...
            mean(rates(:, trials, :), 2);
    end

    flattened = reshape(targetAverage, n, []);
    neuronScale = std(flattened, 0, 2);
    neuronScale = max(neuronScale, 1e-6);
    normalized = targetAverage ./ reshape(neuronScale, n, 1, 1);
    centered = normalized - mean(normalized, 2);

    uniqueGoTimes = unique(double(task.goTimeMs));
    if numel(uniqueGoTimes) ~= 1
        error('V3Analysis:CanonicalTiming', ...
            'Geometry diagnostics require a common diagnostic go time.');
    end
    goTime = uniqueGoTimes;
    time = double(task.timeMs);
    prepTime = time >= goTime - params.analysis.preparatoryWindowMs & ...
        time < goTime;
    moveTime = time >= goTime & ...
        time < goTime + params.analysis.movementWindowMs;
    prepMatrix = reshape(centered(:, :, prepTime), n, []);
    moveMatrix = reshape(centered(:, :, moveTime), n, []);
    prepCovariance = covariance_matrix(prepMatrix);
    moveCovariance = covariance_matrix(moveMatrix);
    [prepVectors, prepValues] = sorted_eigensystem(prepCovariance);
    [moveVectors, moveValues] = sorted_eigensystem(moveCovariance);
    k95Prep = variance_dimension(prepValues, ...
        params.analysis.varianceThreshold);
    k95Move = variance_dimension(moveValues, ...
        params.analysis.varianceThreshold);
    commonDimension = max(k95Prep, k95Move);
    commonDimension = min([commonDimension, size(prepVectors, 2), ...
        size(moveVectors, 2)]);
    prepBasis = prepVectors(:, 1:commonDimension);
    moveBasis = moveVectors(:, 1:commonDimension);
    optimalPrep = sum(prepValues(1:commonDimension));
    optimalMove = sum(moveValues(1:commonDimension));
    prepByMove = captured_variance(prepCovariance, moveBasis);
    moveByPrep = captured_variance(moveCovariance, prepBasis);

    maximumCurveDimension = min([n, size(prepMatrix, 2), ...
        size(moveMatrix, 2)]);
    curveDimensions = 1:maximumCurveDimension;
    prepByPrepCurve = zeros(size(curveDimensions));
    prepByMoveCurve = zeros(size(curveDimensions));
    moveByMoveCurve = zeros(size(curveDimensions));
    moveByPrepCurve = zeros(size(curveDimensions));
    totalPrep = max(trace(prepCovariance), eps);
    totalMove = max(trace(moveCovariance), eps);
    for dimension = curveDimensions
        prepByPrepCurve(dimension) = 100 * sum( ...
            prepValues(1:dimension)) / totalPrep;
        moveByMoveCurve(dimension) = 100 * sum( ...
            moveValues(1:dimension)) / totalMove;
        prepByMoveCurve(dimension) = 100 * captured_variance( ...
            prepCovariance, moveVectors(:, 1:dimension)) / totalPrep;
        moveByPrepCurve(dimension) = 100 * captured_variance( ...
            moveCovariance, prepVectors(:, 1:dimension)) / totalMove;
    end
    singularValues = svd(prepBasis' * moveBasis);

    diagnostics.preprocessing.perNeuronScale = single(neuronScale);
    diagnostics.preprocessing.timewiseTargetMeanSubtracted = true;
    diagnostics.preprocessing.targetAverageRates = single(targetAverage);
    diagnostics.preparatoryMatrix = single(prepMatrix);
    diagnostics.movementMatrix = single(moveMatrix);
    diagnostics.preparatoryCovariance = prepCovariance;
    diagnostics.movementCovariance = moveCovariance;
    diagnostics.k95Preparatory = k95Prep;
    diagnostics.k95Movement = k95Move;
    diagnostics.commonDimension = commonDimension;
    diagnostics.alignment.preparatoryToMovement = ...
        prepByMove / max(optimalPrep, eps);
    diagnostics.alignment.movementToPreparatory = ...
        moveByPrep / max(optimalMove, eps);
    diagnostics.alignment.principalAnglesDeg = ...
        acosd(min(max(singularValues, 0), 1));
    diagnostics.curves.dimension = curveDimensions;
    diagnostics.curves.preparatoryByPreparatoryPercent = ...
        prepByPrepCurve;
    diagnostics.curves.preparatoryByMovementPercent = prepByMoveCurve;
    diagnostics.curves.movementByMovementPercent = moveByMoveCurve;
    diagnostics.curves.movementByPreparatoryPercent = moveByPrepCurve;
end

function covariance = covariance_matrix(matrix)
    covariance = matrix * matrix' / max(size(matrix, 2) - 1, 1);
    covariance = (covariance + covariance') / 2;
end

function [vectors, values] = sorted_eigensystem(covariance)
    [vectors, values] = eig(covariance, 'vector');
    [values, order] = sort(max(real(values), 0), 'descend');
    vectors = real(vectors(:, order));
end

function dimension = variance_dimension(values, threshold)
    total = sum(values);
    if total <= eps
        dimension = 1;
        return
    end
    dimension = find(cumsum(values) / total >= threshold, 1, 'first');
end

function value = captured_variance(covariance, vectors)
    value = trace(vectors' * covariance * vectors);
end
