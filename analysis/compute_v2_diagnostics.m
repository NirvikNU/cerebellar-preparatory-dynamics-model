function diagnostics = compute_v2_diagnostics( ...
        model, simulation, task, params, includePopulation)
    if nargin < 5
        includePopulation = true;
    end
    nTrials = task.numTrials;
    nTimes = task.numTimeSteps;
    speed = reshape(sqrt(sum(simulation.velocity.^2, 1)), ...
        nTrials, nTimes);
    positionError = simulation.position - task.trialTargetPositions;
    errorMagnitude = reshape(sqrt(sum(positionError.^2, 1)), ...
        nTrials, nTimes);
    displacement = reshape(sqrt(sum(simulation.position.^2, 1)), ...
        nTrials, nTimes);
    endpointErrors = zeros(1, nTrials);
    terminalSpeeds = zeros(1, nTrials);
    peakSpeeds = zeros(1, nTrials);
    timeToPeakMs = zeros(1, nTrials);
    for trialIndex = 1:nTrials
        endIndex = task.movementEndIndexByTrial(trialIndex);
        goIndex = task.goIndexByTrial(trialIndex);
        endpointErrors(trialIndex) = errorMagnitude(trialIndex, endIndex);
        terminalSpeeds(trialIndex) = speed(trialIndex, endIndex);
        [peakSpeeds(trialIndex), relativeIndex] = max( ...
            speed(trialIndex, goIndex:endIndex));
        timeToPeakMs(trialIndex) = ...
            (relativeIndex - 1) * params.model.dtMs;
    end
    targetMeanErrors = zeros(1, params.task.numTargets);
    targetSuccess = false(1, params.task.numTargets);
    for targetIndex = 1:params.task.numTargets
        selected = task.targetIndex == targetIndex;
        targetMeanErrors(targetIndex) = mean(endpointErrors(selected));
        targetSuccess(targetIndex) = targetMeanErrors(targetIndex) <= ...
            params.validation.maxTargetAveragedEndpointErrorM;
    end
    preMask = logical(task.preGoMask);
    late150Mask = preMask & task.timeMs >= task.goTimeMs' - 150;
    late100Mask = preMask & task.timeMs >= task.goTimeMs' - 100;
    holdMask = logical(task.holdMask);
    movementMask = logical(task.movementMask);
    metrics.meanEndpointErrorM = mean(endpointErrors);
    metrics.medianEndpointErrorM = median(endpointErrors);
    metrics.maximumTargetAveragedEndpointErrorM = max(targetMeanErrors);
    metrics.targetMeanEndpointErrorM = targetMeanErrors;
    metrics.allTargetsSuccessful = all(targetSuccess);
    metrics.meanTerminalSpeedMPerSec = mean(terminalSpeeds);
    metrics.preGoRmsSpeedMPerSec = sqrt(mean(double(speed(preMask)).^2));
    metrics.final150PreGoRmsSpeedMPerSec = sqrt(mean( ...
        double(speed(late150Mask)).^2));
    metrics.final100PreGoRmsSpeedMPerSec = sqrt(mean( ...
        double(speed(late100Mask)).^2));
    metrics.maximumPreGoSpeedMPerSec = max(speed(preMask));
    metrics.maximumPreGoDisplacementM = max(displacement(preMask));
    metrics.meanHoldErrorM = mean(errorMagnitude(holdMask));
    metrics.maximumHoldErrorM = max(errorMagnitude(holdMask));
    metrics.meanHoldSpeedMPerSec = mean(speed(holdMask));
    metrics.meanPeakSpeedMPerSec = mean(peakSpeeds);
    metrics.meanTimeToPeakSpeedMs = mean(timeToPeakMs);
    metrics.meanFiringRateHz = mean(simulation.rates, 'all');
    metrics.maximumFiringRateHz = max(simulation.rates, [], 'all');
    metrics.finite = all(isfinite(simulation.rates), 'all') && ...
        all(isfinite(simulation.position), 'all') && ...
        all(isfinite(simulation.velocity), 'all');
    metrics.endpointErrorsM = endpointErrors;
    metrics.terminalSpeedsMPerSec = terminalSpeeds;
    metrics.peakSpeedsMPerSec = peakSpeeds;
    metrics.timeToPeakSpeedMs = timeToPeakMs;
    metrics.targetPreGoRmsSpeedMPerSec = nan(1, params.task.numTargets);
    metrics.targetFinal150PreGoRmsSpeedMPerSec = ...
        nan(1, params.task.numTargets);
    metrics.targetFinal100PreGoRmsSpeedMPerSec = ...
        nan(1, params.task.numTargets);
    metrics.targetMaximumPreGoSpeedMPerSec = ...
        nan(1, params.task.numTargets);
    for targetIndex = 1:params.task.numTargets
        targetTrials = task.targetIndex == targetIndex;
        targetMask = repmat(targetTrials(:), 1, nTimes);
        metrics.targetPreGoRmsSpeedMPerSec(targetIndex) = sqrt(mean( ...
            double(speed(preMask & targetMask)).^2));
        metrics.targetFinal150PreGoRmsSpeedMPerSec(targetIndex) = ...
            sqrt(mean(double(speed(late150Mask & targetMask)).^2));
        metrics.targetFinal100PreGoRmsSpeedMPerSec(targetIndex) = ...
            sqrt(mean(double(speed(late100Mask & targetMask)).^2));
        metrics.targetMaximumPreGoSpeedMPerSec(targetIndex) = ...
            max(speed(preMask & targetMask));
    end

    driveLabels = {'target', 'go', 'cerebellar', 'recurrent'};
    for driveIndex = 1:numel(driveLabels)
        values = reshape(simulation.driveNorms(driveIndex, :, :), ...
            nTrials, nTimes);
        label = driveLabels{driveIndex};
        diagnostics.drives.(label).meanAll = mean(values, 'all');
        diagnostics.drives.(label).meanPreparation = mean(values(preMask));
        diagnostics.drives.(label).meanMovement = mean(values(movementMask));
        diagnostics.drives.(label).meanHold = mean(values(holdMask));
        diagnostics.drives.(label).timeCourse = mean(values, 1);
    end
    meanDrives = cellfun(@(name) ...
        diagnostics.drives.(name).meanAll, driveLabels);
    [~, dominantIndex] = max(meanDrives);
    diagnostics.drives.dominantPathway = driveLabels{dominantIndex};
    diagnostics.drives.meanMagnitude = meanDrives;

    latent = simulation.cerebellarLatent;
    derivative = diff(latent, 1, 3) / single(params.model.dtMs / 1000);
    late = task.timeMs(1:end - 1) >= ...
        params.evaluation.latePreparationStartMs & ...
        task.timeMs(1:end - 1) <= ...
        params.evaluation.latePreparationEndMs;
    diagnostics.cerebellar.meanLateDerivativePerSecond = mean( ...
        sqrt(sum(derivative(:, :, late).^2, 1)), 'all');
    diagnostics.cerebellar.meanLatentNorm = mean( ...
        sqrt(sum(latent.^2, 1)), 'all');

    fields = v2_trainable_fields();
    for fieldIndex = 1:numel(fields)
        name = fields{fieldIndex};
        diagnostics.parameterNorms.(name) = norm(double(model.(name)), 'fro');
    end
    diagnostics.metrics = metrics;
    diagnostics.speed = speed;
    diagnostics.errorMagnitude = errorMagnitude;
    diagnostics.displacement = displacement;
    if includePopulation
        diagnostics.population = population_diagnostics( ...
            model, simulation, task, params);
    else
        diagnostics.population = struct();
    end
end

function population = population_diagnostics(model, simulation, task, params)
    rates = simulation.rates;
    [n, nTrials, nTimes] = size(rates);
    data = reshape(rates, n, []);
    meanRate = mean(data, 2);
    centered = double(data - meanRate);
    covariance = centered * centered' / max(size(centered, 2) - 1, 1);
    [vectors, values] = eig(covariance, 'vector');
    [values, order] = sort(real(values), 'descend');
    vectors = real(vectors(:, order));
    explained = 100 * values / max(sum(values), eps);
    scores = vectors(:, 1:3)' * centered;
    population.pca.coefficients = single(vectors(:, 1:3));
    population.pca.scores = reshape(single(scores), 3, nTrials, nTimes);
    population.pca.varianceExplainedPercent = explained(1:10)';
    population.pca.meanRate = meanRate;

    centroids = zeros(n, params.task.numTargets, nTimes, 'single');
    for targetIndex = 1:params.task.numTargets
        centroids(:, targetIndex, :) = mean( ...
            rates(:, task.targetIndex == targetIndex, :), 2);
    end
    separation = zeros(1, nTimes);
    baselineDistance = zeros(1, nTimes);
    baseline = single(model.baselineRates);
    for timeIndex = 1:nTimes
        targetStates = centroids(:, :, timeIndex);
        distances = zeros(1, nchoosek(params.task.numTargets, 2));
        pairIndex = 0;
        for first = 1:params.task.numTargets - 1
            for second = first + 1:params.task.numTargets
                pairIndex = pairIndex + 1;
                distances(pairIndex) = norm(double( ...
                    targetStates(:, first) - targetStates(:, second))) / ...
                    sqrt(n);
            end
        end
        separation(timeIndex) = mean(distances);
        baselineDistance(timeIndex) = mean(vecnorm(double( ...
            targetStates - baseline), 2, 1)) / sqrt(n);
    end
    goStates = zeros(n, params.task.numTargets, 'single');
    for targetIndex = 1:params.task.numTargets
        trials = find(task.targetIndex == targetIndex);
        samples = zeros(n, numel(trials), 'single');
        for trialOffset = 1:numel(trials)
            trial = trials(trialOffset);
            samples(:, trialOffset) = rates(:, trial, ...
                task.goIndexByTrial(trial));
        end
        goStates(:, targetIndex) = mean(samples, 2);
    end
    goDistances = [];
    for first = 1:params.task.numTargets - 1
        for second = first + 1:params.task.numTargets
            goDistances(end + 1) = norm(double( ...
                goStates(:, first) - goStates(:, second))) / sqrt(n); %#ok<AGROW>
        end
    end
    population.preparatory.centroids = centroids;
    population.preparatory.meanPairwiseSeparationHz = separation;
    population.preparatory.meanBaselineDistanceHz = baselineDistance;
    population.preparatory.meanGoSeparationHz = mean(goDistances);
end
