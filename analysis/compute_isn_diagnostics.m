function diagnostics = compute_isn_diagnostics(model, simulation, task, params)
    nTargets = params.task.numTargets;
    nTimes = task.numTimeSteps;
    speed = reshape(sqrt(sum(simulation.velocity.^2, 1)), ...
        task.numTrials, nTimes);
    meanFields = {'position', 'velocity', 'rates', 'jointAngles', ...
        'appliedTorque', 'cerebellarLatent', 'driveNorms'};
    for fieldIndex = 1:numel(meanFields)
        name = meanFields{fieldIndex};
        source = simulation.(name);
        diagnostics.(['mean', upper_first(name)]) = zeros( ...
            size(source, 1), nTargets, nTimes, 'single');
    end
    diagnostics.meanSpeed = zeros(nTargets, nTimes, 'single');
    for targetIndex = 1:nTargets
        mask = task.targetIndex == targetIndex;
        for fieldIndex = 1:numel(meanFields)
            name = meanFields{fieldIndex};
            destination = ['mean', upper_first(name)];
            diagnostics.(destination)(:, targetIndex, :) = ...
                mean(simulation.(name)(:, mask, :), 2);
        end
        diagnostics.meanSpeed(targetIndex, :) = mean(speed(mask, :), 1);
    end
    endpointError = zeros(1, task.numTrials);
    terminalSpeed = endpointError;
    peakSpeed = endpointError;
    timeToPeak = endpointError;
    pathEfficiency = endpointError;
    for trialIndex = 1:task.numTrials
        endpointIndex = task.movementEndIndexByTrial(trialIndex);
        endpointError(trialIndex) = norm(double(simulation.position( ...
            :, trialIndex, endpointIndex) - task.trialTargetPositions(:, trialIndex)));
        terminalSpeed(trialIndex) = double(speed(trialIndex, endpointIndex));
        movement = logical(task.movementMask(trialIndex, :));
        [peakSpeed(trialIndex), localIndex] = max(double(speed(trialIndex, movement)));
        movementTimes = double(task.timeMs(movement));
        timeToPeak(trialIndex) = movementTimes(localIndex) - ...
            double(task.goTimeMs(trialIndex));
        path = squeeze(double(simulation.position(:, trialIndex, movement)));
        pathLength = sum(vecnorm(diff(path, 1, 2), 2, 1));
        pathEfficiency(trialIndex) = params.task.targetRadiusM / ...
            max(pathLength, eps);
    end
    pre = logical(task.preGoMask);
    hold = logical(task.holdMask);
    center = reshape(double(task.centerPosition), 2, 1, 1);
    preDisplacement = reshape(sqrt(sum((double(simulation.position) - ...
        center).^2, 1)), task.numTrials, nTimes);
    targetByTrial = reshape(double(task.trialTargetPositions), 2, task.numTrials, 1);
    holdError = reshape(sqrt(sum((double(simulation.position) - ...
        targetByTrial).^2, 1)), task.numTrials, nTimes);
    metrics.meanEndpointErrorM = mean(endpointError);
    metrics.maximumTargetAveragedEndpointErrorM = max(accumarray( ...
        task.targetIndex(:), endpointError(:), [nTargets 1], @mean));
    metrics.meanTerminalSpeedMPerSec = mean(terminalSpeed);
    metrics.preGoRmsEndpointSpeedMPerSec = sqrt(mean(double(speed(pre)).^2));
    metrics.preGoRmsEndpointDisplacementM = ...
        sqrt(mean(preDisplacement(pre).^2));
    metrics.holdRmsErrorM = sqrt(mean(holdError(hold).^2));
    metrics.holdRmsSpeedMPerSec = sqrt(mean(double(speed(hold)).^2));
    metrics.meanPeakSpeedMPerSec = mean(peakSpeed);
    metrics.meanTimeToPeakSpeedMs = mean(timeToPeak);
    metrics.meanPathEfficiency = mean(pathEfficiency);
    metrics.minimumJointAngleDeg = squeeze(min(rad2deg( ...
        double(simulation.jointAngles)), [], [2 3]))';
    metrics.maximumJointAngleDeg = squeeze(max(rad2deg( ...
        double(simulation.jointAngles)), [], [2 3]))';
    metrics.maximumAbsoluteTorqueNm = squeeze(max(abs(double( ...
        simulation.appliedTorque)), [], [2 3]))';
    metrics.hardJointLimitContactFraction = mean(simulation.jointLimitContact, 'all');
    metrics.hardTorqueSaturationFraction = mean(simulation.torqueSaturation, 'all');
    canonicalGo = params.task.canonicalGoTimeMs;
    wholeMask = true(size(task.timeMs));
    moveMask = task.timeMs >= canonicalGo & ...
        task.timeMs <= canonicalGo + params.task.movementDurationMs;
    diagnostics.pca = population_pca(diagnostics.meanRates, wholeMask, ...
        double(task.timeMs) - canonicalGo, 3);
    diagnostics.movementPca = population_pca(diagnostics.meanRates, ...
        moveMask, double(task.timeMs) - canonicalGo, ...
        params.evaluation.jpcaNumPcs);
    diagnostics.jpca = jpca_fit(diagnostics.movementPca, params.model.dtMs / 1000);
    metrics.pcaExplainedVariancePercent = diagnostics.pca.explained(1:3);
    metrics.movementPcaExplainedVariancePercent = ...
        diagnostics.movementPca.explained(1:3);
    metrics.jpcaRotationalFitR2 = diagnostics.jpca.rotationalFitR2;
    metrics.jpcaUnconstrainedFitR2 = diagnostics.jpca.unconstrainedFitR2;
    metrics.jpcaDominantFrequencyHz = diagnostics.jpca.frequencyHz;
    late = task.timeMs >= params.evaluation.latePreparationStartMs & ...
        task.timeMs <= params.evaluation.latePreparationEndMs;
    derivativeNorm = zeros(1, nTargets);
    change = derivativeNorm;
    for targetIndex = 1:nTargets
        latent = squeeze(double(diagnostics.meanCerebellarLatent( ...
            :, targetIndex, late)));
        derivativeNorm(targetIndex) = mean(vecnorm(diff(latent, 1, 2) / ...
            (params.model.dtMs / 1000), 2, 1));
        change(targetIndex) = norm(latent(:, end) - latent(:, 1));
    end
    metrics.meanLatePreparationLatentDerivativeNormPerSec = mean(derivativeNorm);
    metrics.meanLatePreparationLatentChange = mean(change);
    preMask = logical(task.preGoMask);
    movementMask = logical(task.movementMask);
    cbDrive = reshape(double(simulation.driveNorms(3, :, :)), ...
        task.numTrials, nTimes);
    metrics.meanCerebellarDrivePreparation = mean(cbDrive(preMask));
    metrics.meanCerebellarDriveMovement = mean(cbDrive(movementMask));
    metrics.cerebellarToTargetDriveRatio = ...
        mean(cbDrive(preMask)) / max(mean(reshape(double( ...
        simulation.driveNorms(1, :, :)), task.numTrials, nTimes), 'all'), eps);
    diagnostics.metrics = metrics;
    diagnostics.timeRelativeToGoMs = double(task.timeMs) - canonicalGo;
    diagnostics.model = model;
end

function result = population_pca(rates, mask, time, requested)
    [nUnits, nTargets, ~] = size(rates);
    nTimes = nnz(mask);
    data = zeros(nTargets * nTimes, nUnits);
    for targetIndex = 1:nTargets
        rows = (targetIndex - 1) * nTimes + (1:nTimes);
        data(rows, :) = squeeze(double(rates(:, targetIndex, mask)))';
    end
    data = data - mean(data, 1);
    [u, s, v] = svd(data, 'econ');
    count = min(requested, size(v, 2));
    scores = u(:, 1:count) * s(1:count, 1:count);
    variance = diag(s).^2;
    result.explained = 100 * variance(1:count)' / sum(variance);
    result.trajectories = zeros(nTimes, count, nTargets);
    for targetIndex = 1:nTargets
        rows = (targetIndex - 1) * nTimes + (1:nTimes);
        result.trajectories(:, :, targetIndex) = scores(rows, :);
    end
    result.timeMs = time(mask);
end

function result = jpca_fit(pca, dt)
    [nTimes, nDimensions, nTargets] = size(pca.trajectories);
    x = zeros((nTimes - 2) * nTargets, nDimensions);
    dx = x;
    for targetIndex = 1:nTargets
        rows = (targetIndex - 1) * (nTimes - 2) + (1:(nTimes - 2));
        trajectory = pca.trajectories(:, :, targetIndex);
        x(rows, :) = trajectory(2:end-1, :);
        dx(rows, :) = (trajectory(3:end, :) - trajectory(1:end-2, :)) / (2 * dt);
    end
    unconstrained = x \ dx;
    skew = 0.5 * (unconstrained - unconstrained');
    denominator = sum((dx - mean(dx, 1)).^2, 'all');
    result.unconstrainedFitR2 = 1 - sum((dx - x * unconstrained).^2, 'all') / denominator;
    result.rotationalFitR2 = 1 - sum((dx - x * skew).^2, 'all') / denominator;
    [vectors, values] = eig(skew);
    [angular, index] = max(abs(imag(diag(values))));
    plane = [real(vectors(:, index)), imag(vectors(:, index))];
    [plane, ~] = qr(plane, 0);
    result.trajectories = zeros(nTimes, 2, nTargets);
    for targetIndex = 1:nTargets
        result.trajectories(:, :, targetIndex) = ...
            pca.trajectories(:, :, targetIndex) * plane;
    end
    result.frequencyHz = angular / (2 * pi);
end

function output = upper_first(input)
    output = [upper(input(1)), input(2:end)];
end
