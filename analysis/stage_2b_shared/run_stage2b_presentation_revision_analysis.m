function revision = run_stage2b_presentation_revision_analysis(model, results)
    revision.version = 'CURRENT AUTHORIZED REVISION 2026-08-30';
    revision.temporalSubsamplingS = 0.010;
    revision.inputWindowS = [0, 0.500];
    revision.preparationWindowFromTargetOnsetS = [0.150, 0.450];
    revision.modelMovementOnsetOffsetS = 0.100;
    revision.movementWindowFromMovementOnsetS = [-0.050, 0.250];
    revision.movementWindowFromControlRemovalS = [0.050, 0.350];
    revision.centering = ['For each sampled time, subtract the across-target ' ...
        'population mean; then stack time x target observations by neuron.'];
    revision.nullDraws = 10000;
    revision.nullSeed = 68001;
    revision.nullMedianBootstrapDraws = 2000;
    revision.nullMedianBootstrapSeed = 68002;
    [revision.inputSummary, revision.inputSpectrum, revision.inputTimeCourse] = ...
        input_dimensionality(model, results, revision);
    [revision.alignment, revision.alignmentNull, revision.alignmentSpectrum, ...
        revision.rotation] = alignment_analysis(model, results, revision);
    revision.flow = flow_analysis(model, results);
end

function [summary, spectrum, timeCourse] = input_dimensionality(model, results, revision)
    sampleIndices = round((revision.inputWindowS(1):revision.temporalSubsamplingS: ...
        revision.inputWindowS(2)) / model.samplingDt) + 1;
    sampledTimes = (sampleIndices - 1).' * model.samplingDt;
    nController = numel(results.controllers);
    summaryRows = cell(nController * 3, 8);
    spectrumRows = cell(nController * 3 * model.n, 6);
    timeRows = cell(nController * numel(sampleIndices), 4);
    summaryRow = 0;
    spectrumRow = 0;
    timeRow = 0;
    for controllerIndex = 1:nController
        controller = results.controllers{controllerIndex};
        preparation = results.preparations{controllerIndex};
        nTime = numel(sampleIndices);
        feedback = zeros(nTime, model.nMovements, model.n);
        total = zeros(nTime, model.nMovements, model.n);
        command = zeros(nTime, model.nMovements, max(controller.inputDimension, 1));
        for target = 1:model.nMovements
            rates = max(squeeze(preparation.states(sampleIndices, :, target)), 0);
            targetRates = max(model.xstar(:, target), 0).';
            error = rates - targetRates;
            feedback(:, target, :) = error * controller.effectiveFeedback.';
            tonic = (controller.targetInput(:, target) + ...
                controller.effectiveFeedback * max(model.xstar(:, target), 0)).';
            total(:, target, :) = feedback(:, target, :) + ...
                repmat(reshape(tonic, 1, 1, []), nTime, 1, 1);
            if controller.inputDimension > 0
                command(:, target, 1:controller.inputDimension) = ...
                    reshape(error * controller.K.', nTime, 1, controller.inputDimension);
            end
        end
        labels = strings(1, 3);
        labels(1:2) = ["State-dependent cortical feedback", ...
            "Total preparatory cortical input"];
        matrices = cell(1, 3);
        matrices(1:2) = {feedback, total};
        if controllerIndex == 3
            labels(3) = "13-D controller command";
            matrices{3} = command(:, :, 1:controller.inputDimension);
        else
            labels(3) = "Controller command";
            matrices{3} = command(:, :, 1:max(controller.inputDimension, 1));
        end
        for matrixIndex = 1:numel(matrices)
            [matrix, nFeature] = centered_observation_matrix(matrices{matrixIndex});
            [cumulative, k95, participation, totalVariance] = dimensionality(matrix);
            summaryRow = summaryRow + 1;
            summaryRows(summaryRow, :) = {string(controller.name), labels(matrixIndex), ...
                nTime, model.nMovements, nTime * model.nMovements, nFeature, ...
                k95, participation};
            for component = 1:nFeature
                spectrumRow = spectrumRow + 1;
                spectrumRows(spectrumRow, :) = {string(controller.name), ...
                    labels(matrixIndex), component, cumulative(component), ...
                    totalVariance, revision.temporalSubsamplingS};
            end
        end
        norms = squeeze(vecnorm(feedback, 2, 3));
        for timeIndex = 1:nTime
            timeRow = timeRow + 1;
            timeRows(timeRow, :) = {string(controller.name), sampledTimes(timeIndex), ...
                mean(norms(timeIndex, :)), max(norms(timeIndex, :))};
        end
    end
    summaryRows = summaryRows(1:summaryRow, :);
    spectrumRows = spectrumRows(1:spectrumRow, :);
    timeRows = timeRows(1:timeRow, :);
    summary = cell2table(summaryRows, 'VariableNames', {'Controller','InputType', ...
        'TimeSamples','Targets','Observations','FeatureDimension','K95', ...
        'ParticipationRatio'});
    spectrum = cell2table(spectrumRows, 'VariableNames', {'Controller','InputType', ...
        'Component','CumulativeVarianceFraction','TotalCenteredVariance', ...
        'TemporalSubsamplingS'});
    timeCourse = cell2table(timeRows, 'VariableNames', {'Controller','TimeS', ...
        'MeanFeedbackNorm','MaximumFeedbackNorm'});
    assert(all(summary.TimeSamples == 51));
    stage2aFeedback = summary.Controller == "Stage 2A" & ...
        summary.InputType == "State-dependent cortical feedback";
    assert(summary.K95(stage2aFeedback) == 0);
end

function [summary, nullTable, spectrum, rotation] = alignment_analysis(model, results, revision)
    prepTimes = revision.preparationWindowFromTargetOnsetS(1): ...
        revision.temporalSubsamplingS:revision.preparationWindowFromTargetOnsetS(2);
    moveTimes = revision.movementWindowFromControlRemovalS(1): ...
        revision.temporalSubsamplingS:revision.movementWindowFromControlRemovalS(2);
    prepIndices = round(prepTimes / model.samplingDt) + 1;
    moveIndices = round(moveTimes / model.samplingDt) + 1;
    nController = numel(results.controllers);
    summaryRows = cell(nController, 16);
    spectrumRows = cell(nController * model.n * 2, 5);
    nullValues = zeros(revision.nullDraws, nController);
    rotationRows = cell(nController, 5);
    spectrumRow = 0;
    rng(revision.nullSeed, 'twister');
    for controllerIndex = 1:nController
        preparation = results.preparations{controllerIndex};
        goIndex = round(0.500 / model.samplingDt) + 1;
        goStates = squeeze(preparation.states(goIndex, :, :));
        movement = simulate_published_cortex(model, goStates, true);
        prepValues = max(preparation.states(prepIndices, :, :), 0);
        moveValues = movement.rates(moveIndices, :, :);
        prepMatrix = centered_observation_matrix(permute(prepValues, [1, 3, 2]));
        moveMatrix = centered_observation_matrix(permute(moveValues, [1, 3, 2]));
        Cprep = covariance_rows(prepMatrix);
        Cmove = covariance_rows(moveMatrix);
        Cfull = covariance_rows([prepMatrix; moveMatrix]);
        [Vprep, evalPrep] = sorted_eigenvectors(Cprep);
        [Vmove, evalMove] = sorted_eigenvectors(Cmove);
        [Vfull, evalFull] = sorted_eigenvectors(Cfull);
        cumulativePrep = cumsum(max(evalPrep, 0)) / max(sum(max(evalPrep, 0)), eps);
        cumulativeMove = cumsum(max(evalMove, 0)) / max(sum(max(evalMove, 0)), eps);
        k95 = find(cumulativePrep >= 0.95, 1, 'first');
        prepPR = participation_ratio(evalPrep);
        movePR = participation_ratio(evalMove);
        denominator = sum(max(evalPrep(1:k95), 0));
        observed = trace(Vmove(:, 1:k95).' * Cprep * Vmove(:, 1:k95)) / ...
            max(denominator, eps);
        projectedPrepDiagonal = diag(Vfull.' * Cprep * Vfull);
        weights = max(evalFull, 0);
        weights = weights / max(sum(weights), eps);
        for draw = 1:revision.nullDraws
            selected = weighted_sample_without_replacement(weights, k95);
            nullValues(draw, controllerIndex) = sum(projectedPrepDiagonal(selected)) / ...
                max(denominator, eps);
        end
        nullMedian = median(nullValues(:, controllerIndex));
        rng(revision.nullMedianBootstrapSeed + controllerIndex - 1, 'twister');
        bootstrapMedian = zeros(revision.nullMedianBootstrapDraws, 1);
        for draw = 1:revision.nullMedianBootstrapDraws
            sample = randi(revision.nullDraws, revision.nullDraws, 1);
            bootstrapMedian(draw) = median(nullValues(sample, controllerIndex));
        end
        nullMedianSe = std(bootstrapMedian, 0);
        lowerTailP = (1 + sum(nullValues(:, controllerIndex) <= observed)) / ...
            (revision.nullDraws + 1);
        angles = acosd(min(1, svd(Vprep(:, 1:k95).' * Vmove(:, 1:k95))));
        controller = string(results.controllers{controllerIndex}.name);
        summaryRows(controllerIndex, :) = {controller, numel(prepTimes), ...
            numel(moveTimes), size(prepMatrix, 1), size(moveMatrix, 1), k95, ...
            prepPR, movePR, observed, nullMedian, nullMedianSe, lowerTailP, ...
            revision.nullDraws, revision.temporalSubsamplingS, ...
            revision.modelMovementOnsetOffsetS, revision.centering};
        rotationRows(controllerIndex, :) = {controller, k95, mean(angles), ...
            median(angles), max(angles)};
        for component = 1:model.n
            spectrumRow = spectrumRow + 1;
            spectrumRows(spectrumRow, :) = {controller, "Preparation", component, ...
                cumulativePrep(component), evalPrep(component)};
            spectrumRow = spectrumRow + 1;
            spectrumRows(spectrumRow, :) = {controller, "Movement", component, ...
                cumulativeMove(component), evalMove(component)};
        end
    end
    summary = cell2table(summaryRows, 'VariableNames', {'Controller', ...
        'PreparationTimeSamples','MovementTimeSamples','PreparationObservations', ...
        'MovementObservations','K95Preparation','PreparationParticipationRatio', ...
        'MovementParticipationRatio','ObservedAlignment','NullMedian', ...
        'NullMedianSE','EmpiricalLowerTailP','NullDraws','TemporalSubsamplingS', ...
        'ModelMovementOnsetOffsetS','Centering'});
    [drawGrid, controllerGrid] = ndgrid((1:revision.nullDraws).', (1:nController).');
    names = string(cellfun(@(value) value.name, results.controllers, ...
        'UniformOutput', false));
    controllerColumn = reshape(names(controllerGrid(:)), [], 1);
    nullTable = table(controllerColumn, drawGrid(:), ...
        nullValues(:), 'VariableNames', {'Controller','Draw','AlignmentIndex'});
    spectrum = cell2table(spectrumRows(1:spectrumRow, :), 'VariableNames', ...
        {'Controller','Epoch','Component','CumulativeVarianceFraction','Eigenvalue'});
    rotation = cell2table(rotationRows, 'VariableNames', {'Controller', ...
        'K95Preparation','MeanPrincipalAngleDeg','MedianPrincipalAngleDeg', ...
        'MaximumPrincipalAngleDeg'});
    assert(all(summary.PreparationTimeSamples == 31));
    assert(all(summary.MovementTimeSamples == 31));
end

function output = flow_analysis(model, results)
    target = representative_target(results);
    [vectors, values] = eig(model.Qnative, 'vector');
    [~, order] = sort(real(values), 'descend');
    U = real(vectors(:, order(1:2)));
    extent = 0.120;
    gridPoints = 25;
    maskRadius = 0.006;
    gridValues = linspace(-extent, extent, gridPoints);
    [grid1, grid2] = meshgrid(gridValues, gridValues);
    nGrid = numel(grid1);
    nController = numel(results.controllers);
    rows = cell(nController * nGrid, 15);
    row = 0;
    Q = results.controllers{1}.Q;
    xstar = model.xstar(:, target);
    activeAtFixedPoint = xstar > 0;
    for controllerIndex = 1:nController
        controller = results.controllers{controllerIndex};
        D = diag(double(activeAtFixedPoint));
        J = (-eye(model.n) + (model.W + controller.effectiveFeedback) * D) / model.tau;
        for point = 1:nGrid
            row = row + 1;
            delta = U * [grid1(point); grid2(point)];
            state = xstar + delta;
            nonlinear = vector_field(state, target, model, controller);
            linearized = J * delta;
            nonlinearProjected = U.' * nonlinear;
            linearizedProjected = U.' * linearized;
            V = delta.' * Q * delta;
            masked = norm([grid1(point), grid2(point)]) < maskRadius;
            gammaNonlinear = 2 * delta.' * Q * nonlinear / max(V, eps);
            gammaLinearized = 2 * delta.' * Q * linearized / max(V, eps);
            if masked
                gammaNonlinear = NaN;
                gammaLinearized = NaN;
            end
            rows(row, :) = {string(controller.name), target, grid1(point), ...
                grid2(point), nonlinearProjected(1), nonlinearProjected(2), ...
                linearizedProjected(1), linearizedProjected(2), gammaNonlinear, ...
                gammaLinearized, norm(nonlinear - U * nonlinearProjected) / ...
                max(norm(nonlinear), eps), mean((state > 0) ~= activeAtFixedPoint), ...
                norm(nonlinearProjected - linearizedProjected), masked, extent};
        end
    end
    grid = cell2table(rows, 'VariableNames', {'Controller','Target','Q1','Q2', ...
        'NonlinearVelocityQ1','NonlinearVelocityQ2','LinearizedVelocityQ1', ...
        'LinearizedVelocityQ2','NonlinearGammaQPerS','LinearizedGammaQPerS', ...
        'NonlinearOutOfPlaneFraction','ActiveSetChangeFraction', ...
        'ProjectedVelocityDifferenceNorm','MaskedNearOrigin','GridExtent'});
    diagnostics = cell(nController, 9);
    for controllerIndex = 1:nController
        name = string(results.controllers{controllerIndex}.name);
        selected = grid.Controller == name & ~grid.MaskedNearOrigin;
        nonlinearVelocity = [grid.NonlinearVelocityQ1(selected), ...
            grid.NonlinearVelocityQ2(selected)];
        linearVelocity = [grid.LinearizedVelocityQ1(selected), ...
            grid.LinearizedVelocityQ2(selected)];
        velocityNrmse = norm(nonlinearVelocity - linearVelocity, 'fro') / ...
            max(norm(nonlinearVelocity, 'fro'), eps);
        gammaCorrelation = corr(grid.NonlinearGammaQPerS(selected), ...
            grid.LinearizedGammaQPerS(selected), 'Rows', 'complete');
        gammaRmse = sqrt(mean((grid.NonlinearGammaQPerS(selected) - ...
            grid.LinearizedGammaQPerS(selected)).^2, 'omitnan'));
        signMismatch = mean(sign(grid.NonlinearGammaQPerS(selected)) ~= ...
            sign(grid.LinearizedGammaQPerS(selected)), 'omitnan');
        diagnostics(controllerIndex, :) = {name, target, velocityNrmse, ...
            gammaCorrelation, gammaRmse, signMismatch, ...
            median(grid.NonlinearOutOfPlaneFraction(selected), 'omitnan'), ...
            max(grid.ActiveSetChangeFraction(selected)), ...
            mean(grid.ActiveSetChangeFraction(selected))};
    end
    diagnostics = cell2table(diagnostics, 'VariableNames', {'Controller','Target', ...
        'ProjectedVelocityNRMSE','GammaCorrelation','GammaRMSEPerS', ...
        'GammaSignMismatchFraction','MedianOutOfPlaneFraction', ...
        'MaximumActiveSetChangeFraction','MeanActiveSetChangeFraction'});
    angles = linspace(0, 2 * pi, 9); angles(end) = [];
    starts = xstar + 0.100 * U * [cos(angles); sin(angles)];
    trajectories = cell(nController, 1);
    for controllerIndex = 1:nController
        simulation = simulate_stage2b_preparation(model, results.controllers{controllerIndex}, ...
            0.300, InitialStates=starts, TargetIndex=target * ones(1, numel(angles)), ...
            StoreControl=false);
        projected = zeros(size(simulation.states, 1), 2, numel(angles));
        for trial = 1:numel(angles)
            delta = simulation.states(:, :, trial) - xstar.';
            projected(:, :, trial) = delta * U;
        end
        trajectories{controllerIndex} = projected;
    end
    output.grid = grid;
    output.diagnostics = diagnostics;
    output.trajectories = trajectories;
    output.U = U;
    output.target = target;
    output.selection = representative_target_table(results, target);
    output.gridExtent = extent;
    output.gridPoints = gridPoints;
    output.maskRadius = maskRadius;
end

function target = representative_target(results)
    tableData = representative_target_table(results, NaN);
    [~, target] = min(tableData.DistanceToMedian);
end

function output = representative_target_table(results, selectedTarget)
    names = string(cellfun(@(value) value.name, results.controllers, ...
        'UniformOutput', false));
    features = zeros(8, numel(names) * 3);
    column = 0;
    for controllerIndex = 1:numel(names)
        rows = results.local.targets.Controller == names(controllerIndex);
        column = column + 1;
        features(:, column) = results.local.targets.SpectralAbscissaPerS(rows);
        finiteRows = results.local.finiteTime.Controller == names(controllerIndex) & ...
            abs(results.local.finiteTime.TimeS - 0.300) < 1e-12;
        column = column + 1;
        features(:, column) = results.local.finiteTime.WorstTop13QGain(finiteRows);
        cloudRows = results.clouds.Controller == names(controllerIndex) & ...
            results.clouds.SeedSet == "Matched" & ...
            abs(results.clouds.PerturbationNorm - 0.050) < 1e-12;
        [groups, targetIndex] = findgroups(results.clouds.Target(cloudRows));
        cloudMean = splitapply(@mean, results.clouds.FinalProspectiveFraction(cloudRows), groups);
        column = column + 1;
        features(targetIndex, column) = cloudMean;
    end
    standardized = (features - mean(features, 1)) ./ max(std(features, 0, 1), eps);
    medianVector = median(standardized, 1);
    distance = vecnorm(standardized - medianVector, 2, 2);
    selected = false(8, 1);
    if isfinite(selectedTarget)
        selected(selectedTarget) = true;
    end
    output = table((1:8).', distance, selected, 'VariableNames', ...
        {'Target','DistanceToMedian','Selected'});
end

function derivative = vector_field(x, target, model, controller)
    rates = max(x, 0);
    derivative = (-x + model.W * rates + model.h + ...
        controller.targetInput(:, target) + controller.effectiveFeedback * rates) / model.tau;
end

function [matrix, nFeature] = centered_observation_matrix(values)
    nTime = size(values, 1);
    nTarget = size(values, 2);
    nFeature = size(values, 3);
    values = values - mean(values, 2);
    matrix = reshape(values, nTime * nTarget, nFeature);
end

function covariance = covariance_rows(matrix)
    covariance = (matrix.' * matrix) / max(size(matrix, 1) - 1, 1);
    covariance = 0.5 * (covariance + covariance.');
end

function [cumulative, k95, participation, totalVariance] = dimensionality(matrix)
    if ~any(abs(matrix) > 0, 'all')
        cumulative = zeros(size(matrix, 2), 1);
        k95 = 0;
        participation = 0;
        totalVariance = 0;
        return;
    end
    singularValues = svd(matrix, 'econ');
    eigenvalues = singularValues.^2 / max(size(matrix, 1) - 1, 1);
    eigenvalues = [eigenvalues; zeros(max(size(matrix, 2) - numel(eigenvalues), 0), 1)];
    totalVariance = sum(eigenvalues);
    cumulative = cumsum(eigenvalues) / max(totalVariance, eps);
    k95 = find(cumulative >= 0.95, 1, 'first');
    participation = participation_ratio(eigenvalues);
end

function value = participation_ratio(eigenvalues)
    eigenvalues = max(real(eigenvalues), 0);
    value = sum(eigenvalues)^2 / max(sum(eigenvalues.^2), eps);
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
