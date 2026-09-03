function results = run_stage2b_comparative_analysis(cfg, model, kao, cerebellum, kaoPreparation)
    accepted = load(fullfile(cfg.stage2a.resultsRoot, ...
        'stage2a_complete_results.mat'), 'preparation', 'tonicInput', 'ideal');
    stage2a = baseline_controller(model, accepted.tonicInput, kao.Q);
    controllers = {stage2a, kao, cerebellum};
    names = string(cellfun(@(value) value.name, controllers, 'UniformOutput', false));
    cerebellumPreparation = simulate_stage2b_preparation(model, cerebellum, ...
        cfg.preparation.maximumDurationS);
    preparations = {accepted.preparation, kaoPreparation, cerebellumPreparation};
    results.controllerNames = names;
    results.controllers = controllers;
    results.preparations = preparations;
    results.ideal = accepted.ideal;
    results.local = local_analysis(cfg, model, controllers);
    results.movement = movement_analysis(cfg, model, controllers, ...
        preparations, accepted.ideal);
    results.effort = effort_analysis(model, controllers, preparations);
    [results.clouds, results.cloudSummary] = cloud_analysis(cfg, model, controllers);
    results.perturbations = analyze_stage2b_midprep_perturbations(cfg, model, ...
        controllers, preparations);
    results.potency = potency_breakdown(cfg, model, controllers);
    [results.alignment, results.alignmentNull, results.amplification, ...
        results.rotation, results.epochData] = epoch_analysis(cfg, model, ...
        controllers, preparations);
    results.flow = flow_analysis(cfg, model, controllers);
    results.validation = validation_table(cfg, model, controllers, results.local);
    assert(all(isfinite(results.local.targets.SpectralAbscissaPerS)));
    assert(all(isfinite(results.movement.EndpointErrorM)));
    assert(all(isfinite(results.clouds.FinalProspectiveFraction)));
    assert(all(results.validation.Passed));
end

function controller = baseline_controller(model, tonicInput, Q)
    controller.name = 'Stage 2A';
    controller.A = model.A;
    controller.B = zeros(model.n, 1);
    controller.Q = Q;
    controller.R = 0.1;
    controller.P = [];
    controller.K = zeros(1, model.n);
    controller.effectiveFeedback = zeros(model.n);
    controller.targetInput = tonicInput;
    controller.fixedPointResidual = -model.xstar + model.W * max(model.xstar, 0) ...
        + model.h + tonicInput;
    controller.fixedPointResidualNorm = vecnorm(controller.fixedPointResidual, 2, 1).';
    controller.careResidualRelative = NaN;
    controller.gainFrobeniusNorm = 0;
    controller.inputDimension = 0;
    controller.lambda = 0.1;
    controller.stabilizable = true;
end

function output = local_analysis(cfg, model, controllers)
    rows = numel(controllers) * model.nMovements;
    controllerName = strings(rows, 1);
    target = zeros(rows, 1);
    spectral = zeros(rows, 1);
    fixed = zeros(rows, 1);
    jacobianFd = zeros(rows, 1);
    instantaneousWorst = zeros(rows, 1);
    instantaneousMedian = zeros(rows, 1);
    finiteRows = rows * numel(cfg.analysis.finiteTimesS);
    finiteController = strings(finiteRows, 1);
    finiteTarget = zeros(finiteRows, 1);
    finiteTime = zeros(finiteRows, 1);
    finiteGain = zeros(finiteRows, 1);
    [qVectors, qValues] = eig(model.Qnative, 'vector');
    [~, order] = sort(real(qValues), 'descend');
    U = real(qVectors(:, order(1:13)));
    Q = controllers{1}.Q;
    G = U.' * Q * U;
    rng(64001, 'twister');
    directions = randn(model.n, 5);
    directions = directions ./ vecnorm(directions, 2, 1);
    epsilon = 1e-6;
    row = 0;
    finiteRow = 0;
    for controllerIndex = 1:numel(controllers)
        controller = controllers{controllerIndex};
        for movement = 1:model.nMovements
            row = row + 1;
            xstar = model.xstar(:, movement);
            D = diag(double(xstar > 0));
            J = (-eye(model.n) + ...
                (model.W + controller.effectiveFeedback) * D) / model.tau;
            controllerName(row) = controller.name;
            target(row) = movement;
            spectral(row) = max(real(eig(J)));
            fixed(row) = controller.fixedPointResidualNorm(movement);
            observed = zeros(model.n, size(directions, 2));
            for index = 1:size(directions, 2)
                d = directions(:, index);
                observed(:, index) = (vector_field(xstar + epsilon * d, ...
                    movement, model, controller) - vector_field(xstar - epsilon * d, ...
                    movement, model, controller)) / (2 * epsilon);
            end
            expected = J * directions;
            jacobianFd(row) = norm(observed - expected, 'fro') / ...
                max(norm(expected, 'fro'), eps);
            rates = generalized_rates(J, Q, U, G);
            instantaneousWorst(row) = min(rates);
            instantaneousMedian(row) = median(rates);
            for timeIndex = 1:numel(cfg.analysis.finiteTimesS)
                finiteRow = finiteRow + 1;
                time = cfg.analysis.finiteTimesS(timeIndex);
                propagated = expm(J * time) * U;
                H = propagated.' * Q * propagated;
                finiteController(finiteRow) = controller.name;
                finiteTarget(finiteRow) = movement;
                finiteTime(finiteRow) = time;
                finiteGain(finiteRow) = sqrt(max(real(eig(H, G))));
            end
        end
    end
    output.targets = table(controllerName, target, spectral, fixed, jacobianFd, ...
        instantaneousWorst, instantaneousMedian, ...
        'VariableNames', {'Controller','Target','SpectralAbscissaPerS', ...
        'FixedPointResidualNorm','JacobianFdRelativeError', ...
        'WorstInstantaneousQContractionPerS','MedianInstantaneousQContractionPerS'});
    output.finiteTime = table(finiteController, finiteTarget, finiteTime, finiteGain, ...
        'VariableNames', {'Controller','Target','TimeS','WorstTop13QGain'});
end

function rates = generalized_rates(J, Q, U, G)
    derivative = U.' * (J.' * Q + Q * J) * U;
    rates = -real(eig(derivative, G));
end

function output = movement_analysis(cfg, model, controllers, preparations, ideal)
    durations = cfg.analysis.canonicalPreparationDurationsS;
    nRows = numel(controllers) * numel(durations) * model.nMovements;
    controllerName = strings(nRows, 1);
    durationS = zeros(nRows, 1);
    target = zeros(nRows, 1);
    stateFraction = zeros(nRows, 1);
    prospectiveFraction = zeros(nRows, 1);
    endpoint = zeros(nRows, 1);
    handNrmse = zeros(nRows, 1);
    torqueNrmse = zeros(nRows, 1);
    row = 0;
    for controllerIndex = 1:numel(controllers)
        preparation = preparations{controllerIndex};
        indices = round(durations / model.samplingDt) + 1;
        selected = preparation.states(indices, :, :);
        goStates = reshape(permute(selected, [2, 3, 1]), model.n, []);
        movement = simulate_published_cortex(model, goStates, false);
        [~, hand] = simulate_published_arm(model, movement.torque);
        for durationIndex = 1:numel(durations)
            for movementIndex = 1:model.nMovements
                row = row + 1;
                batch = (durationIndex - 1) * model.nMovements + movementIndex;
                delta = goStates(:, batch) - model.xstar(:, movementIndex);
                delta0 = model.spontaneous - model.xstar(:, movementIndex);
                controllerName(row) = controllers{controllerIndex}.name;
                durationS(row) = durations(durationIndex);
                target(row) = movementIndex;
                stateFraction(row) = norm(delta) / max(norm(delta0), eps);
                prospectiveFraction(row) = (delta.' * controllers{1}.Q * delta) ...
                    / max(delta0.' * controllers{1}.Q * delta0, eps);
                referencePosition = ideal.hand(:, [1, 3], movementIndex);
                actualPosition = hand(:, [1, 3], batch);
                endpoint(row) = norm(actualPosition(end, :) - referencePosition(end, :));
                handNrmse(row) = normalized_rmse(actualPosition - actualPosition(1, :), ...
                    referencePosition - referencePosition(1, :));
                torqueNrmse(row) = normalized_rmse(movement.torque(:, :, batch), ...
                    ideal.cortex.torque(:, :, movementIndex));
            end
        end
    end
    output = table(controllerName, target, durationS, stateFraction, ...
        prospectiveFraction, endpoint, handNrmse, torqueNrmse, ...
        'VariableNames', {'Controller','Target','PreparationDurationS', ...
        'StateErrorFraction','ProspectiveErrorFraction','EndpointErrorM', ...
        'HandTrajectoryNRMSE','TorqueNRMSE'});
end

function output = effort_analysis(model, controllers, preparations)
    nRows = numel(controllers) * model.nMovements;
    controllerName = strings(nRows, 1);
    target = zeros(nRows, 1);
    deviationEffort = zeros(nRows, 1);
    totalEffort = zeros(nRows, 1);
    maximumDeviation = zeros(nRows, 1);
    row = 0;
    limit = round(0.5 / model.samplingDt) + 1;
    for controllerIndex = 1:numel(controllers)
        controller = controllers{controllerIndex};
        preparation = preparations{controllerIndex};
        for movement = 1:model.nMovements
            row = row + 1;
            states = preparation.states(1:limit, :, movement);
            rates = max(states, 0);
            targetRates = max(model.xstar(:, movement), 0).';
            deviation = (rates - targetRates) * controller.effectiveFeedback.';
            total = deviation + (controller.targetInput(:, movement) ...
                + controller.effectiveFeedback * max(model.xstar(:, movement), 0)).';
            controllerName(row) = controller.name;
            target(row) = movement;
            deviationEffort(row) = controller.lambda * model.samplingDt / model.tau ...
                * sum(deviation.^2, 'all');
            totalEffort(row) = model.samplingDt / model.tau * sum(total.^2, 'all');
            maximumDeviation(row) = max(vecnorm(deviation, 2, 2));
        end
    end
    output = table(controllerName, target, deviationEffort, totalEffort, ...
        maximumDeviation, 'VariableNames', {'Controller','Target', ...
        'LambdaWeightedDeviationEffort','TotalInputEffort','MaximumDeviationInputNorm'});
end

function [trials, summary] = cloud_analysis(cfg, model, controllers)
    seeds = [cfg.analysis.primarySeed, cfg.analysis.confirmatorySeed];
    seedSetNames = ["Matched", "Untouched"];
    nRows = numel(controllers) * numel(seeds) * numel(cfg.analysis.cloudNorms) ...
        * model.nMovements * cfg.analysis.cloudDirectionsPerTargetNorm;
    controllerName = strings(nRows, 1);
    seedSet = strings(nRows, 1);
    seedValue = zeros(nRows, 1);
    target = zeros(nRows, 1);
    perturbationNorm = zeros(nRows, 1);
    directionIndex = zeros(nRows, 1);
    prospective = zeros(nRows, 1);
    euclidean = zeros(nRows, 1);
    row = 0;
    Q = controllers{1}.Q;
    for seedIndex = 1:numel(seeds)
        rng(seeds(seedIndex), 'twister');
        directionBank = randn(model.n, cfg.analysis.cloudDirectionsPerTargetNorm, ...
            model.nMovements, numel(cfg.analysis.cloudNorms));
        for normIndex = 1:numel(cfg.analysis.cloudNorms)
            magnitude = cfg.analysis.cloudNorms(normIndex);
            for movement = 1:model.nMovements
                directions = directionBank(:, :, movement, normIndex);
                directions = directions ./ vecnorm(directions, 2, 1);
                initial = model.xstar(:, movement) + magnitude * directions;
                indices = movement * ones(1, size(initial, 2));
                for controllerIndex = 1:numel(controllers)
                    simulation = simulate_stage2b_preparation(model, ...
                        controllers{controllerIndex}, cfg.analysis.cloudDurationS, ...
                        InitialStates=initial, TargetIndex=indices, StoreControl=false);
                    finalDelta = simulation.finalState - model.xstar(:, movement);
                    initialQ = sum((magnitude * directions).' * Q .* ...
                        (magnitude * directions).', 2);
                    finalQ = sum(finalDelta.' * Q .* finalDelta.', 2);
                    for direction = 1:size(directions, 2)
                        row = row + 1;
                        controllerName(row) = controllers{controllerIndex}.name;
                        seedSet(row) = seedSetNames(seedIndex);
                        seedValue(row) = seeds(seedIndex);
                        target(row) = movement;
                        perturbationNorm(row) = magnitude;
                        directionIndex(row) = direction;
                        prospective(row) = finalQ(direction) / max(initialQ(direction), eps);
                        euclidean(row) = norm(finalDelta(:, direction)) / magnitude;
                    end
                end
            end
        end
    end
    trials = table(controllerName, seedSet, seedValue, target, perturbationNorm, ...
        directionIndex, prospective, euclidean, 'VariableNames', ...
        {'Controller','SeedSet','Seed','Target','PerturbationNorm', ...
        'Direction','FinalProspectiveFraction','FinalEuclideanFraction'});
    [groups, groupController, groupSeedSet, groupSeed, groupNorm] = findgroups(...
        trials.Controller, trials.SeedSet, trials.Seed, trials.PerturbationNorm);
    summary = table(groupController, groupSeedSet, groupSeed, groupNorm, ...
        splitapply(@mean, trials.FinalProspectiveFraction, groups), ...
        splitapply(@median, trials.FinalProspectiveFraction, groups), ...
        splitapply(@mean, trials.FinalEuclideanFraction, groups), ...
        'VariableNames', {'Controller','SeedSet','Seed','PerturbationNorm', ...
        'MeanProspectiveFraction','MedianProspectiveFraction','MeanEuclideanFraction'});
end

function output = potency_breakdown(cfg, model, controllers)
    [vectors, values] = eig(model.Qnative, 'vector');
    [~, order] = sort(real(values), 'descend');
    directions = [vectors(:, order(1:10)), vectors(:, order(end-9:end))];
    labels = [repmat("Top-10 potent", 10, 1); repmat("Bottom-10 null", 10, 1)];
    nRows = numel(controllers) * model.nMovements * 20;
    controllerName = strings(nRows, 1);
    target = zeros(nRows, 1);
    band = strings(nRows, 1);
    directionIndex = zeros(nRows, 1);
    finalFraction = zeros(nRows, 1);
    row = 0;
    Q = controllers{1}.Q;
    magnitude = 0.05;
    for movement = 1:model.nMovements
        initial = model.xstar(:, movement) + magnitude * directions;
        initialDelta = magnitude * directions;
        initialQ = sum(initialDelta.' * Q .* initialDelta.', 2);
        indices = movement * ones(1, 20);
        for controllerIndex = 1:numel(controllers)
            simulation = simulate_stage2b_preparation(model, ...
                controllers{controllerIndex}, cfg.analysis.cloudDurationS, ...
                InitialStates=initial, TargetIndex=indices, StoreControl=false);
            finalDelta = simulation.finalState - model.xstar(:, movement);
            finalQ = sum(finalDelta.' * Q .* finalDelta.', 2);
            for direction = 1:20
                row = row + 1;
                controllerName(row) = controllers{controllerIndex}.name;
                target(row) = movement;
                band(row) = labels(direction);
                directionIndex(row) = direction;
                finalFraction(row) = finalQ(direction) / max(initialQ(direction), eps);
            end
        end
    end
    output = table(controllerName, target, band, directionIndex, finalFraction, ...
        'VariableNames', {'Controller','Target','Band','Direction', ...
        'FinalProspectiveFraction'});
end

function [alignment, nullTable, amplification, rotation, epochData] = ...
        epoch_analysis(cfg, model, controllers, preparations)
    nController = numel(controllers);
    nDimension = numel(cfg.analysis.alignmentDimensions);
    nEpoch = 2;
    nRows = nController * nDimension * nEpoch;
    controllerName = strings(nRows, 1);
    dimension = zeros(nRows, 1);
    epochDefinition = strings(nRows, 1);
    observed = zeros(nRows, 1);
    nullMean = zeros(nRows, 1);
    nullLow = zeros(nRows, 1);
    nullHigh = zeros(nRows, 1);
    pLower = zeros(nRows, 1);
    nullValues = zeros(cfg.analysis.randomSubspaceDraws, nRows);
    amplificationValues = zeros(nController, model.nMovements);
    rotationValues = zeros(nRows, 3);
    epochData = cell(nController, nEpoch);
    row = 0;
    rng(66001, 'twister');
    for controllerIndex = 1:nController
        preparation = preparations{controllerIndex};
        goIndex = round(0.500 / model.samplingDt) + 1;
        goStates = squeeze(preparation.states(goIndex, :, :));
        movement = simulate_published_cortex(model, goStates, true);
        prepRates = max(preparation.states, 0);
        for epoch = 1:nEpoch
            if epoch == 1
                prepWindow = cfg.analysis.publishedPrepWindowS;
                moveWindow = cfg.analysis.publishedMoveWindowS;
                epochLabel = "Published Kao epochs";
            else
                prepWindow = cfg.analysis.sensitivityPrepWindowS;
                moveWindow = cfg.analysis.sensitivityMoveWindowS;
                epochLabel = "Late-prep/early-move sensitivity";
            end
            prepMatrix = epoch_matrix(prepRates, prepWindow, 0, model.samplingDt);
            moveMatrix = movement_epoch_matrix(prepRates, movement.rates, ...
                moveWindow, 0.500, model.samplingDt);
            Cprep = covariance_matrix(prepMatrix);
            Cmove = covariance_matrix(moveMatrix);
            Cfull = covariance_matrix([prepMatrix, moveMatrix]);
            epochData{controllerIndex, epoch} = struct('prepMatrix', prepMatrix, ...
                'moveMatrix', moveMatrix, 'Cprep', Cprep, 'Cmove', Cmove, ...
                'Cfull', Cfull);
            [Vprep, evalPrep] = sorted_eigenvectors(Cprep);
            [Vmove, ~] = sorted_eigenvectors(Cmove);
            [Vfull, evalFull] = sorted_eigenvectors(Cfull);
            projectedPrepDiagonal = diag(Vfull.' * Cprep * Vfull);
            weights = max(evalFull, 0);
            weights = weights / max(sum(weights), eps);
            for dimensionIndex = 1:nDimension
                row = row + 1;
                k = cfg.analysis.alignmentDimensions(dimensionIndex);
                denominator = sum(max(evalPrep(1:k), 0));
                observed(row) = trace(Vmove(:, 1:k).' * Cprep * Vmove(:, 1:k)) ...
                    / max(denominator, eps);
                for draw = 1:cfg.analysis.randomSubspaceDraws
                    selected = weighted_sample_without_replacement(weights, k);
                    nullValues(draw, row) = sum(projectedPrepDiagonal(selected)) ...
                        / max(denominator, eps);
                end
                controllerName(row) = controllers{controllerIndex}.name;
                dimension(row) = k;
                epochDefinition(row) = epochLabel;
                nullMean(row) = mean(nullValues(:, row));
                limits = prctile(nullValues(:, row), [2.5, 97.5]);
                nullLow(row) = limits(1);
                nullHigh(row) = limits(2);
                pLower(row) = (1 + sum(nullValues(:, row) <= observed(row))) ...
                    / (cfg.analysis.randomSubspaceDraws + 1);
                angles = acosd(min(1, svd(Vprep(:, 1:k).' * Vmove(:, 1:k))));
                rotationValues(row, :) = [mean(angles), median(angles), max(angles)];
            end
        end
        autonomous = simulate_autonomous(model, model.xstar, 0.600);
        denominator = vecnorm(max(model.xstar, 0) - max(model.spontaneous, 0), 2, 1);
        for movementIndex = 1:model.nMovements
            centered = autonomous(:, :, movementIndex) - max(model.spontaneous, 0).';
            amplificationValues(controllerIndex, movementIndex) = ...
                max(vecnorm(centered, 2, 2)) / max(denominator(movementIndex), eps);
        end
    end
    alignment = table(controllerName, dimension, epochDefinition, observed, ...
        nullMean, nullLow, nullHigh, pLower, 'VariableNames', ...
        {'Controller','Dimension','EpochDefinition','AlignmentIndex', ...
        'NullMean','NullLower95','NullUpper95','EmpiricalLowerTailP'});
    [drawIndex, rowIndex] = ndgrid((1:cfg.analysis.randomSubspaceDraws).', (1:nRows).');
    nullTable = table(rowIndex(:), drawIndex(:), nullValues(:), ...
        'VariableNames', {'AlignmentRow','Draw','AlignmentIndex'});
    [controllerGrid, targetGrid] = ndgrid((1:nController).', (1:model.nMovements).');
    amplification = table(controllers_to_strings(controllers, controllerGrid(:)), ...
        targetGrid(:), amplificationValues(:), 'VariableNames', ...
        {'Controller','Target','MaximumAmplificationFactor'});
    rotation = table(controllerName, dimension, epochDefinition, ...
        rotationValues(:, 1), rotationValues(:, 2), rotationValues(:, 3), ...
        'VariableNames', {'Controller','Dimension','EpochDefinition', ...
        'MeanPrincipalAngleDeg','MedianPrincipalAngleDeg','MaximumPrincipalAngleDeg'});
end

function output = flow_analysis(cfg, model, controllers)
    [vectors, values] = eig(model.Qnative, 'vector');
    [~, order] = sort(real(values), 'descend');
    U = real(vectors(:, order(1:2)));
    gridValues = linspace(-cfg.analysis.flowGridExtent, ...
        cfg.analysis.flowGridExtent, cfg.analysis.flowGridPoints);
    [grid1, grid2] = meshgrid(gridValues, gridValues);
    nGrid = numel(grid1);
    nRows = numel(controllers) * nGrid;
    controllerName = strings(nRows, 1);
    q1 = zeros(nRows, 1);
    q2 = zeros(nRows, 1);
    velocity1 = zeros(nRows, 1);
    velocity2 = zeros(nRows, 1);
    gammaQ = zeros(nRows, 1);
    outOfPlane = zeros(nRows, 1);
    row = 0;
    target = cfg.analysis.flowTarget;
    Q = controllers{1}.Q;
    for controllerIndex = 1:numel(controllers)
        controller = controllers{controllerIndex};
        for point = 1:nGrid
            row = row + 1;
            delta = U * [grid1(point); grid2(point)];
            state = model.xstar(:, target) + delta;
            derivative = vector_field(state, target, model, controller);
            projected = U.' * derivative;
            controllerName(row) = controller.name;
            q1(row) = grid1(point);
            q2(row) = grid2(point);
            velocity1(row) = projected(1);
            velocity2(row) = projected(2);
            value = delta.' * Q * delta;
            gammaQ(row) = 2 * delta.' * Q * derivative / max(value, eps);
            outOfPlane(row) = norm(derivative - U * projected) / max(norm(derivative), eps);
        end
    end
    output.grid = table(controllerName, q1, q2, velocity1, velocity2, gammaQ, ...
        outOfPlane, 'VariableNames', {'Controller','Q1','Q2','VelocityQ1', ...
        'VelocityQ2','GammaQPerS','OutOfPlaneFraction'});
    angles = linspace(0, 2 * pi, 9); angles(end) = [];
    starts = model.xstar(:, target) + 0.15 * U * [cos(angles); sin(angles)];
    trajectory = cell(numel(controllers), 1);
    for controllerIndex = 1:numel(controllers)
        simulation = simulate_stage2b_preparation(model, controllers{controllerIndex}, ...
            cfg.analysis.cloudDurationS, InitialStates=starts, ...
            TargetIndex=target * ones(1, numel(angles)), StoreControl=false);
        projected = zeros(size(simulation.states, 1), 2, numel(angles));
        for trial = 1:numel(angles)
            delta = simulation.states(:, :, trial) - model.xstar(:, target).';
            projected(:, :, trial) = delta * U;
        end
        trajectory{controllerIndex} = projected;
    end
    output.trajectory = trajectory;
    output.U = U;
    output.target = target;
end

function output = validation_table(cfg, ~, controllers, local)
    n = numel(controllers);
    controllerName = strings(n, 1);
    careResidual = nan(n, 1);
    fixedPoint = zeros(n, 1);
    jacobianFd = zeros(n, 1);
    gainRows = zeros(n, 1);
    gainColumns = zeros(n, 1);
    stabilizable = false(n, 1);
    passed = false(n, 1);
    for index = 1:n
        controller = controllers{index};
        rows = local.targets.Controller == controller.name;
        controllerName(index) = controller.name;
        careResidual(index) = controller.careResidualRelative;
        fixedPoint(index) = max(controller.fixedPointResidualNorm);
        jacobianFd(index) = max(local.targets.JacobianFdRelativeError(rows));
        gainRows(index) = size(controller.K, 1);
        gainColumns(index) = size(controller.K, 2);
        stabilizable(index) = controller.stabilizable;
        carePass = isnan(careResidual(index)) || ...
            careResidual(index) < cfg.validation.careResidualTolerance;
        passed(index) = carePass ...
            && fixedPoint(index) < cfg.validation.fixedPointTolerance ...
            && jacobianFd(index) < cfg.validation.jacobianRelativeTolerance ...
            && stabilizable(index);
    end
    output = table(controllerName, careResidual, fixedPoint, jacobianFd, ...
        gainRows, gainColumns, stabilizable, passed, 'VariableNames', ...
        {'Controller','CareResidualRelative','MaximumFixedPointResidual', ...
        'MaximumJacobianFdRelativeError','GainRows','GainColumns', ...
        'Stabilizable','Passed'});
end

function derivative = vector_field(x, target, model, controller)
    rates = max(x, 0);
    derivative = (-x + model.W * rates + model.h ...
        + controller.targetInput(:, target) ...
        + controller.effectiveFeedback * rates) / model.tau;
end

function matrix = epoch_matrix(rates, window, offset, samplingDt)
    indices = round((window - offset) / samplingDt) + 1;
    selected = rates(indices(1):indices(2), :, :);
    matrix = condition_center(selected);
end

function matrix = movement_epoch_matrix(prepRates, movementRates, window, goTime, samplingDt)
    times = (window(1):samplingDt:window(2)).';
    values = zeros(numel(times), size(prepRates, 2), size(prepRates, 3));
    for index = 1:numel(times)
        if times(index) < 0
            prepIndex = round((goTime + times(index)) / samplingDt) + 1;
            values(index, :, :) = prepRates(prepIndex, :, :);
        else
            moveIndex = round(times(index) / samplingDt) + 1;
            values(index, :, :) = movementRates(moveIndex, :, :);
        end
    end
    matrix = condition_center(values);
end

function matrix = condition_center(values)
    values = values - mean(values, 3);
    matrix = reshape(permute(values, [2, 1, 3]), size(values, 2), []);
end

function covariance = covariance_matrix(matrix)
    covariance = (matrix * matrix.') / max(size(matrix, 2) - 1, 1);
    covariance = 0.5 * (covariance + covariance.');
end

function [vectors, values] = sorted_eigenvectors(matrix)
    [vectors, values] = eig(matrix, 'vector');
    [values, order] = sort(real(values), 'descend');
    vectors = real(vectors(:, order));
end

function selected = weighted_sample_without_replacement(weights, k)
    available = true(numel(weights), 1);
    selected = zeros(k, 1);
    for index = 1:k
        probabilities = weights .* available;
        if sum(probabilities) <= 0
            probabilities = double(available);
        end
        probabilities = probabilities / sum(probabilities);
        selected(index) = find(rand <= cumsum(probabilities), 1, 'first');
        available(selected(index)) = false;
    end
end

function rates = simulate_autonomous(model, initialStates, durationS)
    nSteps = round(durationS / model.dt);
    sampleEvery = round(model.samplingDt / model.dt);
    nSamples = nSteps / sampleEvery + 1;
    x = initialStates;
    rates = zeros(nSamples, model.n, size(x, 2));
    rates(1, :, :) = permute(max(x, 0), [3, 1, 2]);
    sample = 1;
    for step = 1:nSteps
        r = max(x, 0);
        x = x + (model.dt / model.tau) * (-x + model.W * r + model.h);
        if mod(step, sampleEvery) == 0
            sample = sample + 1;
            rates(sample, :, :) = permute(max(x, 0), [3, 1, 2]);
        end
    end
end

function values = controllers_to_strings(controllers, indices)
    names = string(cellfun(@(value) value.name, controllers, 'UniformOutput', false));
    values = names(indices).';
    values = values(:);
end

function value = normalized_rmse(actual, reference)
    value = sqrt(mean((actual(:) - reference(:)).^2)) / ...
        max(sqrt(mean(reference(:).^2)), eps);
end
