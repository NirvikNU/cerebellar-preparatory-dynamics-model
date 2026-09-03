function analysis = analyze_published_generator(cfg, model, baseline, ~, hand)
    qMatlab = lyap(model.A.', model.C.' * model.C);
    qMatlab = (qMatlab + qMatlab.') / 2;
    residual = model.A.' * qMatlab + qMatlab * model.A + model.C.' * model.C;
    analysis.potency.q = qMatlab;
    analysis.potency.relativeLyapunovResidual = ...
        norm(residual, 'fro') / norm(model.C.' * model.C, 'fro');
    analysis.potency.nativeQRelativeDifference = ...
        norm(qMatlab - model.Qnative, 'fro') / norm(model.Qnative, 'fro');
    analysis.potency.symmetryRelativeError = ...
        norm(qMatlab - qMatlab.', 'fro') / norm(qMatlab, 'fro');
    [vectors, diagonal] = eig(qMatlab, 'vector');
    [eigenvalues, order] = sort(real(diagonal), 'descend');
    vectors = real(vectors(:, order));
    eigenvalues(abs(eigenvalues) < 1e-12 * eigenvalues(1)) = 0;
    analysis.potency.eigenvectors = vectors;
    analysis.potency.eigenvalues = eigenvalues;
    positive = max(eigenvalues, 0);
    analysis.potency.normalizedSpectrum = positive / sum(positive);
    analysis.potency.cumulativeSpectrum = cumsum(analysis.potency.normalizedSpectrum);
    analysis.potency.participationRatio = sum(positive)^2 / sum(positive.^2);
    thresholds = [0.50, 0.80, 0.90, 0.95];
    dimensions = arrayfun(@(value) find(analysis.potency.cumulativeSpectrum ...
        >= value, 1, 'first'), thresholds);
    analysis.potency.dimensionThresholds = table(thresholds.', dimensions.', ...
        'VariableNames', {'CumulativeFraction','Dimensions'});
    assert(analysis.potency.relativeLyapunovResidual ...
        <= cfg.equivalence.lyapunovRelativeTolerance);
    analysis.perturbations = nonlinear_potency_validation(cfg, model, ...
        baseline, vectors, eigenvalues);
    analysis.mapping = initial_state_mapping(cfg, model, baseline, vectors);
    analysis.movement = movement_metrics(cfg, model, baseline, hand);
    allRates = baseline.rates(:);
    perNeuronMean = squeeze(mean(baseline.rates, [1, 3])).';
    perNeuronMaximum = squeeze(max(baseline.rates, [], [1, 3])).';
    analysis.firing = struct('meanSourceUnits', mean(allRates), ...
        'medianSourceUnits', median(allRates), ...
        'maximumSourceUnits', max(allRates), ...
        'nonfiniteCount', sum(~isfinite(allRates)), ...
        'perNeuronMean', perNeuronMean, ...
        'perNeuronMaximum', perNeuronMaximum);
    eigA = eig(model.A / model.tau);
    eigW = eig(model.W);
    times = (0:0.05:0.60).';
    gains = zeros(size(times));
    for index = 1:numel(times)
        gains(index) = norm(expm((model.A / model.tau) * times(index)), 2);
    end
    excitatorySums = sum(model.W(:, 1:model.nE), 1).';
    inhibitoryMagnitudes = -sum(model.W(:, (model.nE + 1):end), 1).';
    analysis.stability = struct('maxRealEigenvaluePerS', max(real(eigA)), ...
        'wSpectralAbscissa', max(real(eigW)), 'eigenvaluesPerS', eigA, ...
        'transientTimesS', times, 'transientGains', gains, ...
        'maximumTransientGain', max(gains), ...
        'maximumTransientGainTimeS', times(find(gains == max(gains), 1)));
    analysis.ei = struct('excitatoryOutgoingSums', excitatorySums, ...
        'inhibitoryOutgoingMagnitudes', inhibitoryMagnitudes, ...
        'negativeExcitatoryCount', nnz(model.W(:, 1:model.nE) < 0), ...
        'positiveInhibitoryCount', nnz(model.W(:, (model.nE + 1):end) > 0), ...
        'nonzeroDiagonalCount', nnz(diag(model.W)));
    distances = squareform_local(model.xstar);
    analysis.initialStates = struct('pairwiseDistances', distances, ...
        'minimumPairwiseDistance', min(distances(triu(true(8), 1))), ...
        'readoutAtInitialStates', model.C * max(model.xstar, 0));
end

function result = nonlinear_potency_validation(cfg, model, baseline, vectors, eigenvalues)
    k = cfg.potency.directionsPerBand;
    middleStart = floor((model.n - k) / 2) + 1;
    indices = [1:k, middleStart:(middleStart + k - 1), (model.n - k + 1):model.n];
    labels = [repmat("high", 1, k), repmat("intermediate", 1, k), ...
        repmat("low", 1, k)];
    nDirections = numel(indices);
    nTrials = model.nMovements * nDirections * 2;
    q = result_q(vectors, eigenvalues);
    initial = zeros(model.n, nTrials);
    target = zeros(nTrials, 1); direction = zeros(nTrials, 1);
    signValue = zeros(nTrials, 1); band = strings(nTrials, 1);
    predicted = zeros(nTrials, 1);
    trial = 0;
    for movement = 1:model.nMovements
        for localDirection = 1:nDirections
            for signIndex = [-1, 1]
                trial = trial + 1;
                rankIndex = indices(localDirection);
                delta = signIndex * cfg.potency.perturbationNorm * vectors(:, rankIndex);
                initial(:, trial) = model.xstar(:, movement) + delta;
                target(trial) = movement;
                direction(trial) = rankIndex;
                signValue(trial) = signIndex;
                band(trial) = labels(localDirection);
                predicted(trial) = delta.' * q * delta;
            end
        end
    end
    rollout = simulate_published_cortex(model, initial, false);
    actual = zeros(nTrials, 1);
    for trial = 1:nTrials
        difference = rollout.torque(:, :, trial) - baseline.torque(:, :, target(trial));
        actual(trial) = model.samplingDt * sum(difference.^2, 'all');
    end
    tableData = table(target, direction, signValue, band, predicted, actual, ...
        'VariableNames', {'Movement','EigenRank','Sign','Band', ...
        'PredictedCost','NonlinearMotorError'});
    predictedRank = tied_rank(predicted);
    actualRank = tied_rank(actual);
    rankCorrelation = corr(predictedRank, actualRank);
    highMedian = median(actual(band == "high"));
    highValues = actual(band == "high");
    intermediateValues = actual(band == "intermediate");
    lowValues = actual(band == "low");
    lowMedian = median(actual(band == "low"));
    highGreaterThanIntermediate = pairwise_order_fraction( ...
        highValues, intermediateValues);
    highGreaterThanLow = pairwise_order_fraction(highValues, lowValues);
    intermediateGreaterThanLow = pairwise_order_fraction( ...
        intermediateValues, lowValues);
    result = struct('trials', tableData, 'rankCorrelation', rankCorrelation, ...
        'highMedianError', highMedian, 'intermediateMedianError', ...
        median(actual(band == "intermediate")), 'lowMedianError', lowMedian, ...
        'highToLowMedianRatio', highMedian / max(lowMedian, realmin), ...
        'highGreaterThanIntermediateFraction', highGreaterThanIntermediate, ...
        'highGreaterThanLowFraction', highGreaterThanLow, ...
        'intermediateGreaterThanLowFraction', intermediateGreaterThanLow, ...
        'allBandsCompletelyOrdered', highGreaterThanIntermediate == 1 ...
            && highGreaterThanLow == 1 && intermediateGreaterThanLow == 1, ...
        'perturbationNorm', cfg.potency.perturbationNorm);
    exampleColumns = find(target == 1 & signValue == 1 & ...
        (direction == indices(1) | direction == indices(k + 1) ...
        | direction == indices(2 * k + 1)));
    result.exampleTorque = rollout.torque(:, :, exampleColumns);
    result.exampleBands = band(exampleColumns);
end

function q = result_q(vectors, eigenvalues)
    q = vectors * diag(eigenvalues) * vectors.';
end

function result = initial_state_mapping(cfg, model, baseline, vectors)
    rng(cfg.mapping.seed, 'twister');
    nPerMovement = cfg.mapping.samplesPerMovement;
    nTrials = model.nMovements * nPerMovement;
    nCoordinates = cfg.mapping.coordinateCount;
    coordinates = randn(nCoordinates, nTrials);
    coordinates = cfg.mapping.perturbationNorm * coordinates ...
        ./ vecnorm(coordinates, 2, 1);
    initial = zeros(model.n, nTrials);
    movement = repelem((1:model.nMovements).', nPerMovement);
    for trial = 1:nTrials
        initial(:, trial) = model.xstar(:, movement(trial)) ...
            + vectors(:, 1:nCoordinates) * coordinates(:, trial);
    end
    rollout = simulate_published_cortex(model, initial, true);
    [~, perturbedHand] = simulate_published_arm(model, rollout.torque);
    earlySamples = max(1, round(cfg.potency.earlyWindowS / model.samplingDt));
    cortical = zeros(nTrials, model.n);
    earlyMotor = zeros(nTrials, 2);
    endpoint = zeros(nTrials, 2);
    for trial = 1:nTrials
        base = movement(trial);
        rateDifference = rollout.rates(1:earlySamples, :, trial) ...
            - baseline.rates(1:earlySamples, :, base);
        torqueDifference = rollout.torque(1:earlySamples, :, trial) ...
            - baseline.torque(1:earlySamples, :, base);
        cortical(trial, :) = mean(rateDifference, 1);
        earlyMotor(trial, :) = model.samplingDt * sum(torqueDifference, 1);
        endpoint(trial, :) = perturbedHand(end, [1, 3], trial) ...
            - simulate_baseline_endpoint(model, baseline, base);
    end
    test = mod((1:nTrials).', 4) == 0;
    train = ~test;
    [~, ~, corticalBasis] = svd(cortical(train, :) - mean(cortical(train, :), 1), 'econ');
    corticalScores = cortical * corticalBasis(:, 1:min(10, size(corticalBasis, 2)));
    input = coordinates.';
    [predictedCortical, corticalR2] = heldout_ridge(input, corticalScores, train, test, cfg.mapping.ridge);
    [predictedMotor, earlyMotorR2] = heldout_ridge(input, earlyMotor, train, test, cfg.mapping.ridge);
    [predictedEndpoint, endpointR2] = heldout_ridge(input, endpoint, train, test, cfg.mapping.ridge);
    result = struct('seed', cfg.mapping.seed, 'trainMask', train, 'testMask', test, ...
        'coordinates', input, 'movement', movement, ...
        'earlyCorticalScores', corticalScores, ...
        'predictedEarlyCorticalScores', predictedCortical, ...
        'earlyMotorOutput', earlyMotor, 'predictedEarlyMotorOutput', predictedMotor, ...
        'endpointDisplacement', endpoint, 'predictedEndpointDisplacement', predictedEndpoint, ...
        'earlyCorticalR2', corticalR2, 'earlyMotorR2', earlyMotorR2, ...
        'endpointR2', endpointR2);
end

function endpoint = simulate_baseline_endpoint(model, baseline, movement)
    persistent cachedEndpoints cachedKey
    key = sum(model.W(:));
    if isempty(cachedEndpoints) || isempty(cachedKey) || cachedKey ~= key
        [~, hand] = simulate_published_arm(model, baseline.torque);
        cachedEndpoints = squeeze(hand(end, [1, 3], :)).';
        cachedKey = key;
    end
    endpoint = cachedEndpoints(movement, :);
end

function [prediction, r2] = heldout_ridge(input, output, train, test, ridge)
    centerInput = mean(input(train, :), 1);
    centerOutput = mean(output(train, :), 1);
    xTrain = input(train, :) - centerInput;
    yTrain = output(train, :) - centerOutput;
    coefficients = (xTrain.' * xTrain + ridge * eye(size(input, 2))) ...
        \ (xTrain.' * yTrain);
    prediction = nan(size(output));
    prediction(test, :) = (input(test, :) - centerInput) * coefficients + centerOutput;
    residual = sum((output(test, :) - prediction(test, :)).^2, 'all');
    total = sum((output(test, :) - mean(output(test, :), 1)).^2, 'all');
    r2 = 1 - residual / max(total, eps);
end

function metrics = movement_metrics(cfg, model, baseline, hand)
    endpointError = zeros(model.nMovements, 1);
    torqueError = zeros(model.nMovements, 1);
    for movement = 1:model.nMovements
        if isfield(model, 'targetHand') && isfield(model, 'targetTorque')
            targetHand = model.targetHand(:, :, movement);
            targetTorque = model.targetTorque(:, :, movement);
        else
            targetHand = readmatrix(fullfile(cfg.dataRoot, ...
                sprintf('target_hand_r1_%d.tsv', movement)), 'FileType', 'text');
            targetTorque = readmatrix(fullfile(cfg.dataRoot, ...
                sprintf('target_torque_r1_%d.tsv', movement)), 'FileType', 'text');
        end
        endpointError(movement) = norm(hand(end, [1, 3], movement) ...
            - targetHand(end, [1, 3]));
        difference = baseline.torque(:, :, movement) - targetTorque;
        difference(:, 2) = 3 * difference(:, 2);
        torqueError(movement) = model.samplingDt * sum(difference.^2, 'all');
    end
    metrics = table((1:model.nMovements).', endpointError, torqueError, ...
        'VariableNames', {'Movement','EndpointErrorM','WeightedTorqueError'});
end

function ranks = tied_rank(values)
    [sorted, order] = sort(values);
    ranks = zeros(size(values));
    startIndex = 1;
    while startIndex <= numel(values)
        endIndex = startIndex;
        while endIndex < numel(values) && sorted(endIndex + 1) == sorted(startIndex)
            endIndex = endIndex + 1;
        end
        ranks(order(startIndex:endIndex)) = mean(startIndex:endIndex);
        startIndex = endIndex + 1;
    end
end

function fraction = pairwise_order_fraction(first, second)
    fraction = mean(first(:) > second(:).', 'all');
end

function distances = squareform_local(states)
    count = size(states, 2);
    distances = zeros(count);
    for first = 1:count
        for second = (first + 1):count
            distances(first, second) = norm(states(:, first) - states(:, second));
            distances(second, first) = distances(first, second);
        end
    end
end
