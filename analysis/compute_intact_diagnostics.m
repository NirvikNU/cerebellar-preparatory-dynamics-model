function diagnostics = compute_intact_diagnostics( ...
        model, simulation, task, params, checkpointLoss)
    numTargets = params.task.numTargets;
    numUnits = params.model.numCorticalUnits;
    numTimeSteps = task.numTimeSteps;
    canonicalGoTimeMs = params.task.canonicalGoTimeMs;
    if any(task.goTimeMs ~= canonicalGoTimeMs)
        error('IntactModel:CanonicalDiagnostics', ...
            'Canonical diagnostics require the configured canonical go time.');
    end

    speed = reshape(sqrt(sum(simulation.velocity.^2, 1)), ...
        task.numTrials, numTimeSteps);
    meanPosition = zeros(2, numTargets, numTimeSteps, 'single');
    meanVelocity = zeros(2, numTargets, numTimeSteps, 'single');
    meanSpeed = zeros(numTargets, numTimeSteps, 'single');
    meanRates = zeros(numUnits, numTargets, numTimeSteps, 'single');
    meanState = zeros(numUnits, numTargets, numTimeSteps, 'single');
    meanJointAngles = zeros(2, numTargets, numTimeSteps, 'single');
    meanAppliedTorque = zeros(2, numTargets, numTimeSteps, 'single');
    meanLatent = zeros(params.model.cerebellarRank, numTargets, ...
        numTimeSteps, 'single');
    meanDesiredPosition = zeros(2, numTargets, numTimeSteps, 'single');
    meanDesiredVelocity = zeros(2, numTargets, numTimeSteps, 'single');

    for targetIndex = 1:numTargets
        trialMask = simulation.targetIndex == targetIndex;
        meanPosition(:, targetIndex, :) = ...
            mean(simulation.position(:, trialMask, :), 2);
        meanVelocity(:, targetIndex, :) = ...
            mean(simulation.velocity(:, trialMask, :), 2);
        meanSpeed(targetIndex, :) = mean(speed(trialMask, :), 1);
        meanRates(:, targetIndex, :) = ...
            mean(simulation.rates(:, trialMask, :), 2);
        meanState(:, targetIndex, :) = ...
            mean(simulation.state(:, trialMask, :), 2);
        meanJointAngles(:, targetIndex, :) = ...
            mean(simulation.jointAngles(:, trialMask, :), 2);
        meanAppliedTorque(:, targetIndex, :) = ...
            mean(simulation.appliedTorque(:, trialMask, :), 2);
        meanLatent(:, targetIndex, :) = ...
            mean(simulation.cerebellarLatent(:, trialMask, :), 2);
        meanDesiredPosition(:, targetIndex, :) = ...
            mean(task.desiredPosition(:, trialMask, :), 2);
        meanDesiredVelocity(:, targetIndex, :) = ...
            mean(task.desiredVelocity(:, trialMask, :), 2);
    end

    positionError = double(simulation.position - task.desiredPosition);
    velocityError = double(simulation.velocity - task.desiredVelocity);
    positionSquaredDistance = reshape(sum(positionError.^2, 1), ...
        task.numTrials, numTimeSteps);
    velocitySquaredDistance = reshape(sum(velocityError.^2, 1), ...
        task.numTrials, numTimeSteps);
    movementMask = double(task.movementMask);
    preGoMask = double(task.preGoMask);
    endpointRmse = sqrt(sum(positionSquaredDistance .* movementMask, 'all') / ...
        sum(movementMask, 'all'));
    velocityRmse = sqrt(sum(velocitySquaredDistance .* movementMask, 'all') / ...
        sum(movementMask, 'all'));
    preGoRmsSpeed = sqrt(sum(double(speed).^2 .* preGoMask, 'all') / ...
        sum(preGoMask, 'all'));
    centerPosition = reshape(double(task.centerPosition), 2, 1, 1);
    displacementFromCenterSquared = reshape(sum( ...
        (double(simulation.position) - centerPosition).^2, 1), ...
        task.numTrials, numTimeSteps);
    preGoRmsDisplacement = sqrt(sum( ...
        displacementFromCenterSquared .* preGoMask, 'all') / ...
        sum(preGoMask, 'all'));

    endpointErrorByTrial = zeros(1, task.numTrials);
    terminalSpeedByTrial = zeros(1, task.numTrials);
    for trialIndex = 1:task.numTrials
        endpointIndex = task.movementEndIndexByTrial(trialIndex);
        finalPosition = double(simulation.position(:, trialIndex, ...
            endpointIndex));
        endpointErrorByTrial(trialIndex) = norm(finalPosition - ...
            double(task.trialTargetPositions(:, trialIndex)));
        terminalSpeedByTrial(trialIndex) = norm(double( ...
            simulation.velocity(:, trialIndex, endpointIndex)));
    end
    targetAveragedEndpointError = zeros(1, numTargets);
    targetAveragedTerminalSpeed = zeros(1, numTargets);
    for targetIndex = 1:numTargets
        targetMask = simulation.targetIndex == targetIndex;
        targetAveragedEndpointError(targetIndex) = mean( ...
            endpointErrorByTrial(targetMask));
        targetAveragedTerminalSpeed(targetIndex) = mean( ...
            terminalSpeedByTrial(targetMask));
    end

    wholeTrialMask = task.timeMs <= ...
        canonicalGoTimeMs + params.task.movementDurationMs;
    wholeTrialPca = compute_population_pca(meanRates, wholeTrialMask, ...
        double(task.timeMs) - canonicalGoTimeMs, 3);
    movementMaskForPca = task.timeMs >= canonicalGoTimeMs & ...
        task.timeMs <= canonicalGoTimeMs + params.task.movementDurationMs;
    movementPca = compute_population_pca(meanRates, movementMaskForPca, ...
        double(task.timeMs) - canonicalGoTimeMs, ...
        params.evaluation.jpcaNumPcs);
    jpca = compute_jpca(movementPca, params.model.dtMs / 1000);

    cerebellarDriveNorm = zeros(task.numTrials, numTimeSteps);
    for timeIndex = 1:numTimeSteps
        drive = model.Ucb * simulation.cerebellarLatent(:, :, timeIndex);
        cerebellarDriveNorm(:, timeIndex) = ...
            sqrt(sum(double(drive).^2, 1));
    end
    latePreparationMask = task.timeMs >= ...
        params.evaluation.latePreparationStartMs & task.timeMs <= ...
        params.evaluation.latePreparationEndMs;
    latentDerivativeNormByTarget = zeros(1, numTargets);
    latentChangeByTarget = zeros(1, numTargets);
    for targetIndex = 1:numTargets
        latent = squeeze(double(meanLatent( ...
            :, targetIndex, latePreparationMask)));
        derivative = diff(latent, 1, 2) / (params.model.dtMs / 1000);
        latentDerivativeNormByTarget(targetIndex) = mean( ...
            sqrt(sum(derivative.^2, 1)));
        latentChangeByTarget(targetIndex) = norm(latent(:, end) - ...
            latent(:, 1));
    end

    jointAnglesDeg = rad2deg(double(simulation.jointAngles));
    appliedTorque = double(simulation.appliedTorque);
    metrics.checkpointLoss = checkpointLoss;
    metrics.endpointRmseM = endpointRmse;
    metrics.velocityRmseMPerSec = velocityRmse;
    metrics.medianEndpointErrorM = median(endpointErrorByTrial);
    metrics.meanEndpointErrorM = mean(endpointErrorByTrial);
    metrics.maximumTargetAveragedEndpointErrorM = ...
        max(targetAveragedEndpointError);
    metrics.endpointErrorByTrialM = endpointErrorByTrial;
    metrics.targetAveragedEndpointErrorM = targetAveragedEndpointError;
    metrics.meanTerminalSpeedMPerSec = mean(terminalSpeedByTrial);
    metrics.medianTerminalSpeedMPerSec = median(terminalSpeedByTrial);
    metrics.maximumTargetAveragedTerminalSpeedMPerSec = ...
        max(targetAveragedTerminalSpeed);
    metrics.terminalSpeedByTrialMPerSec = terminalSpeedByTrial;
    metrics.targetAveragedTerminalSpeedMPerSec = ...
        targetAveragedTerminalSpeed;
    metrics.preGoRmsEndpointSpeedMPerSec = preGoRmsSpeed;
    metrics.preGoRmsEndpointDisplacementM = preGoRmsDisplacement;
    metrics.minimumJointAngleDeg = squeeze(min( ...
        jointAnglesDeg, [], [2 3]))';
    metrics.maximumJointAngleDeg = squeeze(max( ...
        jointAnglesDeg, [], [2 3]))';
    metrics.minimumAppliedTorqueNm = squeeze(min( ...
        appliedTorque, [], [2 3]))';
    metrics.maximumAppliedTorqueNm = squeeze(max( ...
        appliedTorque, [], [2 3]))';
    metrics.maximumAbsoluteTorqueNm = squeeze(max( ...
        abs(appliedTorque), [], [2 3]))';
    metrics.maximumAbsoluteRawTorqueNm = squeeze(max( ...
        abs(double(simulation.rawTorque)), [], [2 3]))';
    metrics.hardJointLimitContactFraction = ...
        mean(simulation.jointLimitContact, 'all');
    metrics.hardTorqueSaturationFraction = ...
        mean(simulation.torqueSaturation, 'all');
    metrics.pcaExplainedVariancePercent = ...
        wholeTrialPca.explainedVariancePercent(1:3);
    metrics.movementPcaExplainedVariancePercent = ...
        movementPca.explainedVariancePercent(1:3);
    metrics.jpcaRotationalFitR2 = jpca.rotationalFitR2;
    metrics.jpcaUnconstrainedFitR2 = jpca.unconstrainedFitR2;
    metrics.jpcaDominantFrequencyHz = jpca.dominantFrequencyHz;
    metrics.jpcaSkewFraction = jpca.skewFraction;
    metrics.meanCerebellarDrivePreparation = sum( ...
        cerebellarDriveNorm .* preGoMask, 'all') / sum(preGoMask, 'all');
    metrics.meanCerebellarDriveMovement = sum( ...
        cerebellarDriveNorm .* movementMask, 'all') / ...
        sum(movementMask, 'all');
    metrics.latePreparationLatentDerivativeNormByTargetPerSec = ...
        latentDerivativeNormByTarget;
    metrics.latePreparationLatentChangeByTarget = latentChangeByTarget;
    metrics.meanLatePreparationLatentDerivativeNormPerSec = ...
        mean(latentDerivativeNormByTarget);
    metrics.meanLatePreparationLatentChange = mean(latentChangeByTarget);
    metrics.latePreparationWindowMs = [ ...
        params.evaluation.latePreparationStartMs, ...
        params.evaluation.latePreparationEndMs];

    diagnostics.metrics = metrics;
    diagnostics.meanPosition = meanPosition;
    diagnostics.meanVelocity = meanVelocity;
    diagnostics.meanSpeed = meanSpeed;
    diagnostics.meanRates = meanRates;
    diagnostics.meanState = meanState;
    diagnostics.meanJointAngles = meanJointAngles;
    diagnostics.meanAppliedTorque = meanAppliedTorque;
    diagnostics.meanLatent = meanLatent;
    diagnostics.meanDesiredPosition = meanDesiredPosition;
    diagnostics.meanDesiredVelocity = meanDesiredVelocity;
    diagnostics.timeRelativeToGoMs = ...
        double(task.timeMs) - canonicalGoTimeMs;
    diagnostics.pca = wholeTrialPca;
    diagnostics.movementPca = movementPca;
    diagnostics.jpca = jpca;
end

function pcaResult = compute_population_pca( ...
        meanRates, timeMask, relativeTimeMs, requestedComponents)
    numUnits = size(meanRates, 1);
    numTargets = size(meanRates, 2);
    numSteps = nnz(timeMask);
    data = zeros(numTargets * numSteps, numUnits);
    for targetIndex = 1:numTargets
        rowIndex = (targetIndex - 1) * numSteps + (1:numSteps);
        data(rowIndex, :) = squeeze(double( ...
            meanRates(:, targetIndex, timeMask)))';
    end
    dataMean = mean(data, 1);
    centeredData = data - dataMean;
    [leftVectors, singularValues, rightVectors] = ...
        svd(centeredData, 'econ');
    numComponents = min([requestedComponents, size(rightVectors, 2), ...
        size(leftVectors, 2)]);
    scores = leftVectors(:, 1:numComponents) * ...
        singularValues(1:numComponents, 1:numComponents);
    singularVariance = diag(singularValues).^2;
    explainedVariance = 100 * singularVariance / sum(singularVariance);
    trajectories = zeros(numSteps, numComponents, numTargets);
    for targetIndex = 1:numTargets
        rowIndex = (targetIndex - 1) * numSteps + (1:numSteps);
        trajectories(:, :, targetIndex) = scores(rowIndex, :);
    end
    pcaResult.mean = dataMean;
    pcaResult.coefficients = rightVectors(:, 1:numComponents);
    pcaResult.trajectories = trajectories;
    pcaResult.explainedVariancePercent = ...
        explainedVariance(1:numComponents)';
    pcaResult.timeRelativeToGoMs = relativeTimeMs(timeMask);
end

function jpca = compute_jpca(movementPca, dtSeconds)
    trajectories = movementPca.trajectories;
    [numSteps, numDimensions, numTargets] = size(trajectories);
    stateRows = zeros((numSteps - 2) * numTargets, numDimensions);
    derivativeRows = zeros(size(stateRows));
    for targetIndex = 1:numTargets
        rows = (targetIndex - 1) * (numSteps - 2) + ...
            (1:(numSteps - 2));
        targetTrajectory = trajectories(:, :, targetIndex);
        stateRows(rows, :) = targetTrajectory(2:(end - 1), :);
        derivativeRows(rows, :) = (targetTrajectory(3:end, :) - ...
            targetTrajectory(1:(end - 2), :)) / (2 * dtSeconds);
    end
    unconstrainedMatrix = stateRows \ derivativeRows;
    skewMatrix = 0.5 * (unconstrainedMatrix - unconstrainedMatrix');
    unconstrainedPrediction = stateRows * unconstrainedMatrix;
    rotationalPrediction = stateRows * skewMatrix;
    centeredDerivative = derivativeRows - mean(derivativeRows, 1);
    totalDerivativeVariance = sum(centeredDerivative.^2, 'all');
    unconstrainedFitR2 = 1 - sum( ...
        (derivativeRows - unconstrainedPrediction).^2, 'all') / ...
        totalDerivativeVariance;
    rotationalFitR2 = 1 - sum( ...
        (derivativeRows - rotationalPrediction).^2, 'all') / ...
        totalDerivativeVariance;

    [eigenvectors, eigenvalues] = eig(skewMatrix);
    frequencies = abs(imag(diag(eigenvalues)));
    [dominantAngularFrequency, dominantIndex] = max(frequencies);
    dominantVector = eigenvectors(:, dominantIndex);
    plane = [real(dominantVector), imag(dominantVector)];
    if rank(plane) < 2
        plane = eye(numDimensions, 2);
    else
        [plane, ~] = qr(plane, 0);
    end
    planeTrajectories = zeros(numSteps, 2, numTargets);
    for targetIndex = 1:numTargets
        planeTrajectories(:, :, targetIndex) = ...
            trajectories(:, :, targetIndex) * plane;
    end

    jpca.trajectories = planeTrajectories;
    jpca.timeRelativeToGoMs = movementPca.timeRelativeToGoMs;
    jpca.rotationalMatrix = skewMatrix;
    jpca.unconstrainedMatrix = unconstrainedMatrix;
    jpca.plane = plane;
    jpca.rotationalFitR2 = rotationalFitR2;
    jpca.unconstrainedFitR2 = unconstrainedFitR2;
    jpca.dominantFrequencyHz = dominantAngularFrequency / (2 * pi);
    jpca.skewFraction = norm(skewMatrix, 'fro') / ...
        max(norm(unconstrainedMatrix, 'fro'), eps);
end
