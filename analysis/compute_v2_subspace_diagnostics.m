function diagnostics = compute_v2_subspace_diagnostics( ...
        model, simulation, task, params)
    rates = double(simulation.rates);
    n = size(rates, 1);
    time = double(task.timeMs);
    go = double(task.goTimeMs(:));
    prepMask = time >= go - params.analysis.preparatoryWindowMs & ...
        time < go;
    moveMask = time >= go & ...
        time < go + params.analysis.movementWindowMs;
    prep = epoch_matrix(rates, prepMask);
    movement = epoch_matrix(rates, moveMask);
    [prepCentered, prepMean] = center_rows(prep);
    [moveCentered, moveMean] = center_rows(movement);
    prepCovariance = covariance_matrix(prepCentered);
    moveCovariance = covariance_matrix(moveCentered);
    dimension = min([params.analysis.subspaceDimension, n, ...
        size(prepCentered, 2) - 1, size(moveCentered, 2) - 1]);
    [prepVectors, prepValues] = leading_eigenvectors( ...
        prepCovariance, dimension);
    [moveVectors, moveValues] = leading_eigenvectors( ...
        moveCovariance, dimension);

    prepByPrep = captured_variance(prepCovariance, prepVectors);
    prepByMove = captured_variance(prepCovariance, moveVectors);
    moveByMove = captured_variance(moveCovariance, moveVectors);
    moveByPrep = captured_variance(moveCovariance, prepVectors);
    totalPrep = trace(prepCovariance);
    totalMove = trace(moveCovariance);
    diagnostics.dimension = dimension;
    diagnostics.epoch.preparatoryWindowMs = ...
        params.analysis.preparatoryWindowMs;
    diagnostics.epoch.movementWindowMs = params.analysis.movementWindowMs;
    diagnostics.preparatory.coefficients = single(prepVectors);
    diagnostics.preparatory.eigenvalues = prepValues;
    diagnostics.movement.coefficients = single(moveVectors);
    diagnostics.movement.eigenvalues = moveValues;
    diagnostics.crossProjection.preparatoryByPreparatoryPercent = ...
        100 * prepByPrep / max(totalPrep, eps);
    diagnostics.crossProjection.preparatoryByMovementPercent = ...
        100 * prepByMove / max(totalPrep, eps);
    diagnostics.crossProjection.movementByMovementPercent = ...
        100 * moveByMove / max(totalMove, eps);
    diagnostics.crossProjection.movementByPreparatoryPercent = ...
        100 * moveByPrep / max(totalMove, eps);
    diagnostics.alignment.preparatoryByMovement = ...
        prepByMove / max(sum(prepValues), eps);
    diagnostics.alignment.movementByPreparatory = ...
        moveByPrep / max(sum(moveValues), eps);
    singularValues = svd(prepVectors' * moveVectors);
    diagnostics.alignment.principalAnglesDeg = ...
        acosd(min(max(singularValues, 0), 1));
    diagnostics.alignment.meanSquaredCosine = mean(singularValues.^2);

    [potentVectors, potentRank] = output_potent_basis(model.Wout);
    prepPotentVariance = captured_variance( ...
        prepCovariance, potentVectors);
    optimalPotentVariance = sum(prepValues(1:min(potentRank, ...
        numel(prepValues))));
    diagnostics.outputPotent.rank = potentRank;
    diagnostics.outputPotent.coefficients = single(potentVectors);
    diagnostics.outputPotent.preparatoryVariancePercent = ...
        100 * prepPotentVariance / max(totalPrep, eps);
    diagnostics.outputPotent.preparatoryAlignmentIndex = ...
        prepPotentVariance / max(optimalPotentVariance, eps);
    prepPotentCoordinates = potentVectors' * prepCentered;
    diagnostics.outputPotent.preparatoryProjectionRmsHz = sqrt(mean( ...
        sum(prepPotentCoordinates.^2, 1)));
    diagnostics.outputPotent.preparatoryVelocityRmsMPerSec = sqrt(mean( ...
        sum((double(model.Wout) * prep).^2, 1)));
    diagnostics.outputPotent.preparatoryMeanRateHz = prepMean;
    diagnostics.outputPotent.movementMeanRateHz = moveMean;

    nTrials = task.numTrials;
    nTimes = task.numTimeSteps;
    commonMean = mean(reshape(rates, n, []), 2);
    centeredAll = reshape(rates, n, []) - commonMean;
    potentTime = reshape(potentVectors' * centeredAll, ...
        potentRank, nTrials, nTimes);
    diagnostics.outputPotent.timeCourseRmsHz = squeeze(sqrt(mean( ...
        sum(potentTime.^2, 1), 2)))';
end

function matrix = epoch_matrix(rates, mask)
    n = size(rates, 1);
    reshaped = reshape(rates, n, []);
    matrix = reshaped(:, mask(:));
end

function [centered, rowMean] = center_rows(matrix)
    rowMean = mean(matrix, 2);
    centered = matrix - rowMean;
end

function covariance = covariance_matrix(centered)
    covariance = centered * centered' / max(size(centered, 2) - 1, 1);
    covariance = (covariance + covariance') / 2;
end

function [vectors, values] = leading_eigenvectors(covariance, dimension)
    [allVectors, allValues] = eig(covariance, 'vector');
    [allValues, order] = sort(real(allValues), 'descend');
    vectors = real(allVectors(:, order(1:dimension)));
    values = max(allValues(1:dimension), 0);
end

function value = captured_variance(covariance, vectors)
    value = trace(vectors' * covariance * vectors);
end

function [vectors, rankValue] = output_potent_basis(readout)
    [vectors, singularValues, ~] = svd(double(readout)', 'econ');
    singularValues = diag(singularValues);
    tolerance = max(size(readout)) * eps(max(singularValues));
    rankValue = sum(singularValues > tolerance);
    vectors = vectors(:, 1:rankValue);
end
