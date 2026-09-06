function report = analyze_stage1_active_set_diagnostics(projectRoot, outputRoot)
    %#ok<*AGROW,*UDIM>
    % Preserve the original diagnostic's bounded-table/style annotations.
    % Retained diagnostic source; explicit separate authorization is required.
    % Stage-1 functions extracted without scientific changes from the former
    % mixed-stage diagnostic. Never called by the smoke/regression runners.
    assert(nargin == 2 && ~isfolder(outputRoot), ...
        'Provide a new diagnostic output directory; never overwrite frozen results.');
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src', 'published_generator'));
    addpath(fullfile(projectRoot, 'analysis', 'published_generator'));
    addpath(fullfile(projectRoot, 'figures', 'published_generator'));
    cfg = stage_1_gate1_config(projectRoot);
    diagnostic = struct('resultsRoot', outputRoot, ...
        'stage1FigRoot', fullfile(outputRoot, 'fig'), ...
        'stage1PngRoot', fullfile(outputRoot, 'png'), ...
        'bootstrapSamples', 10000, 'bootstrapSeed', 2026090202);
    mkdir(outputRoot);
    stage1Target = table(); stage1Overlap = table();
    stage1ActiveCurve = table(); frozenMetrics = table();
    frozenCurves = table(); validation = table(); representative = struct();
    for network = 1:cfg.gate1.networkCount
        saved = load(fullfile(cfg.gate1.ensembleRoot, ...
            sprintf('network_%02d.mat', network)), 'model');
        [targetRows, overlapRows, curveRows, frozenRows, mismatchRows, ...
            movement, check] = analyze_stage1_network(saved.model, network);
        stage1Target = [stage1Target; targetRows];
        stage1Overlap = [stage1Overlap; overlapRows];
        stage1ActiveCurve = [stage1ActiveCurve; curveRows];
        frozenMetrics = [frozenMetrics; frozenRows];
        frozenCurves = [frozenCurves; mismatchRows];
        validation = [validation; check];
        if network == 1, representative.movement = movement; end
    end
    [stage1Network, activeCurveNetwork, frozenNetwork, frozenCurveNetwork] = ...
        summarize_stage1(stage1Target, stage1Overlap, stage1ActiveCurve, ...
            frozenMetrics, frozenCurves, diagnostic);
    results = struct('stage1Target', stage1Target, ...
        'stage1Overlap', stage1Overlap, 'stage1ActiveCurve', stage1ActiveCurve, ...
        'stage1Network', stage1Network, ...
        'stage1ActiveCurveNetwork', activeCurveNetwork, ...
        'frozenRegimeTarget', frozenMetrics, 'frozenRegimeCurve', frozenCurves, ...
        'frozenRegimeNetwork', frozenNetwork, ...
        'frozenRegimeCurveNetwork', frozenCurveNetwork, 'validation', validation);
    assert(all(validation.Passed));
    save(fullfile(outputRoot, 'stage1_active_set_saved.mat'), ...
        'results', 'representative', 'diagnostic', '-v7.3');
    figureFiles = create_stage1_active_set_figures(cfg, diagnostic, ...
        results, representative);
    report = struct('validation', validation, 'figureFiles', figureFiles);
end

function [targetRows, overlapRows, curveRows, frozenRows, mismatchRows, ...
        representative, validation] = analyze_stage1_network(model, network)
    trueMovement = simulate_true_movement(model);
    representative = struct();
    accepted = simulate_published_cortex(model, model.xstar, true);
    maxRateDifference = max(abs(trueMovement.rates - accepted.rates), [], 'all');
    maxTorqueDifference = max(abs(trueMovement.torque - accepted.torque), [], 'all');
    assert(maxRateDifference <= 1e-12 && maxTorqueDifference <= 1e-12);
    [~, trueHand] = simulate_published_arm(model, trueMovement.torque);
    nTargets = model.nMovements;
    active = trueMovement.states > 0;
    targetRows = table();
    curveRows = table();
    frozenRows = table();
    mismatchRows = table();
    unionSets = false(model.n, nTargets);
    meanRates = squeeze(mean(trueMovement.rates, 1));
    for target = 1:nTargets
        targetActive = squeeze(active(:, :, target));
        transitions = sum(diff(targetActive, 1, 1) ~= 0, 1);
        switchingFraction = mean(transitions > 0);
        transitionsPerNeuron = mean(transitions);
        transitionsPerNeuronPerS = transitionsPerNeuron / ...
            ((model.nSamples - 1) * model.samplingDt);
        unionSets(:, target) = any(targetActive, 1).';
        occupancy = mean(targetActive, 1).';
        targetRows = [targetRows; table(network, target, ... %#ok<AGROW>
            switchingFraction, sum(transitions), transitionsPerNeuron, ...
            transitionsPerNeuronPerS, mean(occupancy), ... %#ok<UDIM>
            'VariableNames', {'Network','Target','SwitchingFraction', ...
            'TotalTransitions','TransitionsPerNeuron', ...
            'TransitionsPerNeuronPerS','MeanActiveFraction'})];
        fractionActive = mean(targetActive, 2);
        timeS = trueMovement.timesS;
        curveRows = [curveRows; table(repmat(network, numel(timeS), 1), ... %#ok<AGROW>
            repmat(target, numel(timeS), 1), timeS, fractionActive, ...
            'VariableNames', {'Network','Target','MovementTimeS', ...
            'ActiveFraction'})];
        frozen = simulate_frozen_regime(model, model.xstar(:, target), ...
            targetActive(1, :).');
        [~, frozenHand] = simulate_published_arm(model, frozen.torque);
        trueRates = trueMovement.rates(:, :, target);
        trueTorque = trueMovement.torque(:, :, target);
        targetHand = trueHand(:, [1, 3], target);
        fixedHand = frozenHand(:, [1, 3]);
        corticalNrmse = normalized_rmse(frozen.rates, trueRates);
        torqueNrmse = normalized_rmse(frozen.torque, trueTorque);
        handNrmse = normalized_rmse(fixedHand - fixedHand(1, :), ...
            targetHand - targetHand(1, :));
        endpointErrorM = norm(fixedHand(end, :) - targetHand(end, :));
        frozenRows = [frozenRows; table(network, target, corticalNrmse, ... %#ok<AGROW>
            torqueNrmse, handNrmse, endpointErrorM, ...
            'VariableNames', {'Network','Target','CorticalRateNRMSE', ...
            'TorqueNRMSE','HandTrajectoryNRMSE','EndpointErrorM'})];
        rateDifference = squeeze(vecnorm(frozen.rates - trueRates, 2, 2));
        torqueDifference = squeeze(vecnorm(frozen.torque - trueTorque, 2, 2));
        handDifference = vecnorm(fixedHand - targetHand, 2, 2);
        mismatchRows = [mismatchRows; table( ... %#ok<AGROW>
            repmat(network, model.nSamples, 1), ...
            repmat(target, model.nSamples, 1), trueMovement.timesS, ...
            rateDifference, torqueDifference, handDifference(1:end-1), ...
            'VariableNames', {'Network','Target','MovementTimeS', ...
            'CorticalDifferenceNorm','TorqueDifferenceNorm', ...
            'HandPositionDifferenceM'})];
        if network == 1 && target == 1
            representative.trueHand = targetHand;
            representative.frozenHand = fixedHand;
        end
    end
    overlapRows = table();
    for first = 1:(nTargets - 1)
        for second = (first + 1):nTargets
            intersection = sum(unionSets(:, first) & unionSets(:, second));
            unionCount = sum(unionSets(:, first) | unionSets(:, second));
            jaccard = intersection / max(unionCount, 1);
            overlapRows = [overlapRows; table(network, first, second, ... %#ok<AGROW>
                jaccard, intersection, unionCount, 'VariableNames', ...
                {'Network','Target1','Target2','UnionSetJaccard', ...
                'IntersectionCount','UnionCount'})];
        end
    end
    if network == 1
        [~, preferredTarget] = max(meanRates, [], 2);
        modulation = max(meanRates, [], 2) - min(meanRates, [], 2);
        orderingTable = table((1:model.n).', preferredTarget, modulation, ...
            'VariableNames', {'Neuron','PreferredTarget','Modulation'});
        orderingTable = sortrows(orderingTable, ...
            {'PreferredTarget','Modulation','Neuron'}, {'ascend','descend','ascend'});
        ordering = orderingTable.Neuron;
        normalizedMean = meanRates ./ max(max(meanRates, [], 2), eps);
        normalizedMean(~isfinite(normalizedMean)) = 0;
        representative.activeRaster = active(:, ordering, :);
        representative.meanRatesRaw = meanRates(ordering, :);
        representative.meanRatesNormalized = normalizedMean(ordering, :);
        representative.neuronOrdering = orderingTable;
        representative.timesS = trueMovement.timesS;
    end
    validation = table(network, "Stage 1 nonlinear reproduction", ...
        max(maxRateDifference, maxTorqueDifference), 1e-12, true, ...
        'VariableNames', {'Network','Check','MaximumDifference', ...
        'Tolerance','Passed'});
end

function output = simulate_true_movement(model)
    x = model.xstar;
    sampleEvery = round(model.samplingDt / model.dt);
    states = zeros(model.nSamples, model.n, model.nMovements);
    rates = zeros(model.nSamples, model.n, model.nMovements);
    torque = zeros(model.nSamples, 2, model.nMovements);
    sample = 0;
    for step = 0:(model.nInternalSteps - 1)
        r = max(x, 0);
        if mod(step, sampleEvery) == 0
            sample = sample + 1;
            states(sample, :, :) = permute(x, [3, 1, 2]);
            rates(sample, :, :) = permute(r, [3, 1, 2]);
            torque(sample, :, :) = permute(model.C * r, [3, 1, 2]);
        end
        drive = published_movement_input(model.dt * step, model);
        x = x + (model.dt / model.tau) * ...
            (-x + model.W * r + model.h + drive);
    end
    output = struct('states', states, 'rates', rates, 'torque', torque, ...
        'timesS', (0:(model.nSamples - 1)).' * model.samplingDt);
end

function output = simulate_frozen_regime(model, initialState, activeAtGo)
    x = initialState;
    activeAtGo = double(activeAtGo(:));
    sampleEvery = round(model.samplingDt / model.dt);
    rates = zeros(model.nSamples, model.n);
    torque = zeros(model.nSamples, 2);
    sample = 0;
    for step = 0:(model.nInternalSteps - 1)
        r = activeAtGo .* x;
        if mod(step, sampleEvery) == 0
            sample = sample + 1;
            rates(sample, :) = r.';
            torque(sample, :) = (model.C * r).';
        end
        drive = published_movement_input(model.dt * step, model);
        x = x + (model.dt / model.tau) * ...
            (-x + model.W * r + model.h + drive);
    end
    output = struct('rates', rates, 'torque', torque);
end

function [networkSummary, activeCurve, frozenSummary, frozenCurve] = ...
        summarize_stage1(target, overlap, curve, frozen, mismatch, diagnostic)
    networks = unique(target.Network);
    networkSummary = table();
    frozenSummary = table();
    for network = networks.'
        rows = target.Network == network;
        pairRows = overlap.Network == network;
        networkSummary = [networkSummary; table(network, ... %#ok<AGROW>
            median(target.SwitchingFraction(rows)), ...
            median(target.TransitionsPerNeuronPerS(rows)), ...
            median(target.MeanActiveFraction(rows)), ...
            median(overlap.UnionSetJaccard(pairRows)), ...
            'VariableNames', {'Network','MedianSwitchingFraction', ...
            'MedianTransitionsPerNeuronPerS','MedianActiveFraction', ...
            'MedianUnionSetJaccard'})];
        rows = frozen.Network == network;
        frozenSummary = [frozenSummary; table(network, ... %#ok<AGROW>
            median(frozen.CorticalRateNRMSE(rows)), ...
            median(frozen.TorqueNRMSE(rows)), ...
            median(frozen.HandTrajectoryNRMSE(rows)), ...
            median(frozen.EndpointErrorM(rows)), ...
            'VariableNames', {'Network','MedianCorticalRateNRMSE', ...
            'MedianTorqueNRMSE','MedianHandTrajectoryNRMSE', ...
            'MedianEndpointErrorM'})];
    end
    activeCurve = aggregate_target_curves(curve, 'MovementTimeS', ...
        'ActiveFraction');
    frozenCurve = aggregate_target_curves(mismatch, 'MovementTimeS', ...
        'HandPositionDifferenceM');
    networkSummary = add_scalar_bootstrap(networkSummary, diagnostic, 1);
    frozenSummary = add_scalar_bootstrap(frozenSummary, diagnostic, 2);
end

function output = aggregate_target_curves(input, timeName, valueName)
    networks = unique(input.Network);
    times = unique(input.(timeName));
    output = table();
    for network = networks.'
        values = zeros(numel(times), 1);
        for timeIndex = 1:numel(times)
            rows = input.Network == network & ...
                input.(timeName) == times(timeIndex);
            values(timeIndex) = median(input.(valueName)(rows));
        end
        output = [output; table(repmat(network, numel(times), 1), times, ... %#ok<AGROW>
            values, 'VariableNames', {'Network', timeName, valueName})];
    end
end

function output = add_scalar_bootstrap(input, diagnostic, seedOffset)
    output = input;
    variables = input.Properties.VariableNames(2:end);
    for index = 1:numel(variables)
        summary = bootstrap_network_median(input.(variables{index}), ...
            diagnostic.bootstrapSamples, diagnostic.bootstrapSeed + ...
            100 * seedOffset + index);
        output.([variables{index}, 'AcrossNetworkMedian']) = ...
            repmat(summary.median, height(output), 1);
        output.([variables{index}, 'BootstrapSE']) = ...
            repmat(summary.standardError, height(output), 1);
    end
end

function value = normalized_rmse(actual, reference)
    numerator = sqrt(mean((actual - reference) .^ 2, 'all'));
    denominator = max(max(reference, [], 'all') - ...
        min(reference, [], 'all'), eps);
    value = numerator / denominator;
end
