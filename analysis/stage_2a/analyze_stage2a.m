function analysis = analyze_stage2a(cfg, model, tonicInput, fixedPointResidual, ...
        preparation, ideal)
    nTargets = model.nMovements;
    nPreparationSamples = numel(preparation.timesS);
    stateError = zeros(nPreparationSamples, nTargets);
    normalizedStateError = zeros(nPreparationSamples, nTargets);
    prospectiveError = zeros(nPreparationSamples, nTargets);
    normalizedProspectiveError = zeros(nPreparationSamples, nTargets);
    for target = 1:nTargets
        delta = preparation.states(:, :, target) - model.xstar(:, target).';
        stateError(:, target) = vecnorm(delta, 2, 2);
        normalizedStateError(:, target) = stateError(:, target) ...
            / max(stateError(1, target), eps);
        prospectiveError(:, target) = sum((delta * model.Qnative) .* delta, 2);
        normalizedProspectiveError(:, target) = prospectiveError(:, target) ...
            / max(prospectiveError(1, target), eps);
    end

    denseDurations = cfg.preparation.metricDurationsS;
    denseGoStates = states_at_times(preparation, denseDurations, model.samplingDt);
    denseMovement = simulate_stage2a_movements(model, denseGoStates, false);
    denseIndices = round(denseDurations / model.samplingDt) + 1;
    movementMetrics = movement_metric_table(model, ideal, denseMovement, ...
        denseDurations, normalizedStateError(denseIndices, :), ...
        normalizedProspectiveError(denseIndices, :));

    representativeDurations = cfg.preparation.representativeDurationsS;
    representativeGoStates = states_at_times(preparation, ...
        representativeDurations, model.samplingDt);
    representativeMovement = simulate_stage2a_movements( ...
        model, representativeGoStates, true);
    observedGoRates = squeeze(representativeMovement.cortex.rates(1, :, :));
    expectedGoRates = max(representativeGoStates, 0);
    goContinuityMaximum = max(abs(observedGoRates - expectedGoRates), [], 'all');

    convergence = convergence_table(cfg, model, normalizedProspectiveError, ...
        preparation.timesS);
    validation = validation_table(model, tonicInput, fixedPointResidual, ...
        normalizedStateError, normalizedProspectiveError, movementMetrics, ...
        max(denseDurations));
    positiveMask = movementMetrics.ProspectiveErrorFraction > 0 ...
        & movementMetrics.HandTrajectoryNRMSE > 0;
    logCorrelation = corrcoef( ...
        log10(movementMetrics.ProspectiveErrorFraction(positiveMask)), ...
        log10(movementMetrics.HandTrajectoryNRMSE(positiveMask)));
    if isequal(size(logCorrelation), [2, 2])
        prospectiveMovementLogCorrelation = logCorrelation(1, 2);
    else
        prospectiveMovementLogCorrelation = NaN;
    end

    analysis.fixedPoint.inputNorm = vecnorm(tonicInput, 2, 1).';
    analysis.fixedPoint.residualNorm = vecnorm(fixedPointResidual, 2, 1).';
    analysis.preparation.stateError = stateError;
    analysis.preparation.normalizedStateError = normalizedStateError;
    analysis.preparation.prospectiveError = prospectiveError;
    analysis.preparation.normalizedProspectiveError = normalizedProspectiveError;
    analysis.movement.durationsS = denseDurations;
    analysis.movement.goStates = denseGoStates;
    analysis.movement.simulation = denseMovement;
    analysis.movement.metrics = movementMetrics;
    analysis.representative.durationsS = representativeDurations;
    analysis.representative.goStates = representativeGoStates;
    analysis.representative.simulation = representativeMovement;
    analysis.convergence = convergence;
    analysis.validation = validation;
    analysis.goContinuityMaximum = goContinuityMaximum;
    analysis.prospectiveMovementLogCorrelation = prospectiveMovementLogCorrelation;
    analysis.nonfiniteCount = count_nonfinite(preparation.states) ...
        + count_nonfinite(denseMovement.cortex.torque) ...
        + count_nonfinite(denseMovement.hand) ...
        + count_nonfinite(representativeMovement.cortex.rates);
end

function goStates = states_at_times(preparation, durationsS, samplingDt)
    indices = round(durationsS / samplingDt) + 1;
    assert(all(indices >= 1 & indices <= size(preparation.states, 1)));
    selected = preparation.states(indices, :, :);
    goStates = reshape(permute(selected, [2, 3, 1]), ...
        size(preparation.states, 2), []);
end

function tableData = movement_metric_table(model, ideal, movement, durationsS, ...
        normalizedStateError, normalizedProspectiveError)
    nTargets = model.nMovements;
    nDurations = numel(durationsS);
    values = zeros(nTargets * nDurations, 7);
    row = 0;
    for durationIndex = 1:nDurations
        for target = 1:nTargets
            row = row + 1;
            batch = (durationIndex - 1) * nTargets + target;
            referenceTorque = ideal.cortex.torque(:, :, target);
            actualTorque = movement.cortex.torque(:, :, batch);
            referencePosition = ideal.hand(:, [1, 3], target);
            actualPosition = movement.hand(:, [1, 3], batch);
            referenceDisplacement = referencePosition - referencePosition(1, :);
            actualDisplacement = actualPosition - actualPosition(1, :);
            endpointError = norm(actualPosition(end, :) - referencePosition(end, :));
            values(row, :) = [target, durationsS(durationIndex), ...
                normalizedStateError(durationIndex, target), ...
                normalizedProspectiveError(durationIndex, target), endpointError, ...
                normalized_rmse(actualDisplacement, referenceDisplacement), ...
                normalized_rmse(actualTorque, referenceTorque)];
        end
    end
    tableData = array2table(values, 'VariableNames', ...
        {'Target','PreparationDurationS','StateErrorFraction', ...
        'ProspectiveErrorFraction','EndpointErrorM', ...
        'HandTrajectoryNRMSE','TorqueNRMSE'});
end

function tableData = convergence_table(cfg, model, normalizedProspectiveError, timesS)
    reductions = cfg.preparation.errorReductionFractions;
    values = nan(model.nMovements, 1 + numel(reductions));
    values(:, 1) = (1:model.nMovements).';
    for target = 1:model.nMovements
        for index = 1:numel(reductions)
            threshold = 1 - reductions(index);
            first = find(normalizedProspectiveError(:, target) <= threshold, 1, 'first');
            if ~isempty(first)
                values(target, index + 1) = timesS(first);
            end
        end
    end
    names = [{'Target'}, arrayfun(@(value) sprintf('T%dReductionS', ...
        round(100 * value)), reductions, 'UniformOutput', false)];
    tableData = array2table(values, 'VariableNames', names);
end

function tableData = validation_table(model, tonicInput, fixedPointResidual, ...
        normalizedStateError, normalizedProspectiveError, movementMetrics, longDurationS)
    longRows = movementMetrics.PreparationDurationS == longDurationS;
    longMetrics = movementMetrics(longRows, :);
    tableData = table((1:model.nMovements).', vecnorm(tonicInput, 2, 1).', ...
        vecnorm(fixedPointResidual, 2, 1).', normalizedStateError(end, :).', ...
        normalizedProspectiveError(end, :).', ...
        1 - normalizedProspectiveError(end, :).', longMetrics.EndpointErrorM, ...
        longMetrics.HandTrajectoryNRMSE, longMetrics.TorqueNRMSE, ...
        'VariableNames', {'Target','TonicInputNorm','FixedPointResidualNorm', ...
        'LongStateErrorFraction','LongProspectiveErrorFraction', ...
        'ProspectiveErrorReduction','LongEndpointErrorM', ...
        'LongHandTrajectoryNRMSE','LongTorqueNRMSE'});
end

function value = normalized_rmse(actual, reference)
    difference = actual - reference;
    referenceRms = sqrt(mean(reference(:).^2));
    value = sqrt(mean(difference(:).^2)) / max(referenceRms, eps);
end

function count = count_nonfinite(values)
    count = sum(~isfinite(values), 'all');
end
