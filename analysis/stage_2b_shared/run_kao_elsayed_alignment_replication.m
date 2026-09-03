function replication = run_kao_elsayed_alignment_replication(model, results, options)
%RUN_KAO_ELSAYED_ALIGNMENT_REPLICATION Source-faithful alignment audit.

    if nargin < 3
        options = struct();
    end
    validate_inputs(model, results);
    settings = analysis_settings(model, options);
    controllerIndices = [2, 2, 3];
    varianceThresholds = [0.80, 0.95, 0.95];
    analysisLabels = ["Published pipeline diagnostic (80%)", ...
        "Canonical project analysis (95%)", ...
        "Canonical project analysis (95%)"];
    controllerData = cell(1, numel(results.controllers));
    for controllerIndex = unique(controllerIndices)
        controllerData{controllerIndex} = prepare_controller_data( ...
            model, results, controllerIndex, settings);
    end

    nAnalysis = numel(controllerIndices);
    auditRows = cell(nAnalysis, 30);
    nullRows = cell(settings.nullDraws * nAnalysis, 5);
    bootstrapRows = cell(settings.bootstrapDraws * nAnalysis, 5);
    spectrumRows = cell(model.n * nAnalysis, 7);
    nullRow = 0;
    bootstrapRow = 0;
    spectrumRow = 0;
    for analysisIndex = 1:nAnalysis
        controllerIndex = controllerIndices(analysisIndex);
        data = controllerData{controllerIndex};
        threshold = varianceThresholds(analysisIndex);
        cumulativePrep = cumsum(data.prepEigenvalues) / ...
            sum(data.prepEigenvalues);
        cumulativeMove = cumsum(data.moveEigenvalues) / ...
            sum(data.moveEigenvalues);
        dimension = find(cumulativePrep >= threshold, 1, 'first');
        denominator = sum(data.prepEigenvalues(1:dimension));
        movementBasis = data.moveEigenvectors(:, 1:dimension);
        observed = trace(movementBasis.' * data.Cprep * movementBasis) / ...
            denominator;
        nullSeed = settings.nullSeed + analysisIndex - 1;
        bootstrapSeed = settings.bootstrapSeed + analysisIndex - 1;
        nullValues = covariance_biased_null(data.Cfull, data.prepMatrix, ...
            dimension, settings.nullDraws, nullSeed);
        rng(bootstrapSeed, 'twister');
        bootstrapMedians = zeros(settings.bootstrapDraws, 1);
        for draw = 1:settings.bootstrapDraws
            sample = randi(settings.nullDraws, settings.nullDraws, 1);
            bootstrapMedians(draw) = median(nullValues(sample));
        end
        nullInterval = prctile(nullValues, [2.5, 97.5]);
        pLower = (1 + sum(nullValues <= observed)) / ...
            (settings.nullDraws + 1);
        prepParticipation = participation_ratio(data.prepEigenvalues);
        moveParticipation = participation_ratio(data.moveEigenvalues);
        controllerName = string(results.controllers{controllerIndex}.name);
        analysisLabel = analysisLabels(analysisIndex);
        auditRows(analysisIndex, :) = {controllerName, analysisLabel, threshold, ...
            settings.prepStartS, settings.prepEndExclusiveS, ...
            settings.moveStartFromMovementOnsetS, ...
            settings.moveEndExclusiveFromMovementOnsetS, ...
            settings.moveStartFromControlRemovalS, ...
            settings.moveEndExclusiveFromControlRemovalS, ...
            numel(settings.prepTimesS), numel(settings.moveTimesS), ...
            size(data.prepMatrix, 2), size(data.moveMatrix, 2), ...
            settings.sampleIntervalS, dimension, prepParticipation, ...
            moveParticipation, observed, mean(nullValues), ...
            median(nullValues), std(nullValues, 0), nullInterval(1), ...
            nullInterval(2), std(bootstrapMedians, 0), pLower, ...
            settings.nullDraws, settings.bootstrapDraws, nullSeed, ...
            bootstrapSeed, settings.preprocessing};
        for draw = 1:settings.nullDraws
            nullRow = nullRow + 1;
            nullRows(nullRow, :) = {controllerName, analysisLabel, ...
                threshold, draw, nullValues(draw)};
        end
        for draw = 1:settings.bootstrapDraws
            bootstrapRow = bootstrapRow + 1;
            bootstrapRows(bootstrapRow, :) = {controllerName, analysisLabel, ...
                threshold, draw, bootstrapMedians(draw)};
        end
        for component = 1:model.n
            spectrumRow = spectrumRow + 1;
            spectrumRows(spectrumRow, :) = {controllerName, analysisLabel, ...
                threshold, component, cumulativePrep(component), ...
                cumulativeMove(component), data.prepEigenvalues(component)};
        end
    end

    replication.audit = cell2table(auditRows, 'VariableNames', ...
        {'Controller','Analysis','VarianceThreshold','PrepStartS', ...
        'PrepEndExclusiveS','MoveStartFromMovementOnsetS', ...
        'MoveEndExclusiveFromMovementOnsetS','MoveStartFromControlRemovalS', ...
        'MoveEndExclusiveFromControlRemovalS','PreparationTimeSamples', ...
        'MovementTimeSamples','PreparationObservations','MovementObservations', ...
        'SampleIntervalS','K','PreparationParticipationRatio', ...
        'MovementParticipationRatio','ObservedAlignment','NullMean', ...
        'NullMedian','NullSD','NullLower95','NullUpper95', ...
        'BootstrapSDOfNullMedians','EmpiricalLowerTailP','NullDraws', ...
        'BootstrapDraws','NullSeed','BootstrapSeed','Preprocessing'});
    replication.null = cell2table(nullRows, 'VariableNames', ...
        {'Controller','Analysis','VarianceThreshold','Draw','AlignmentIndex'});
    replication.bootstrapMedians = cell2table(bootstrapRows, 'VariableNames', ...
        {'Controller','Analysis','VarianceThreshold','BootstrapDraw', ...
        'MedianAlignmentIndex'});
    replication.spectrum = cell2table(spectrumRows, 'VariableNames', ...
        {'Controller','Analysis','VarianceThreshold','Component', ...
        'PrepCumulativeVariance','MoveCumulativeVariance','PrepEigenvalue'});
    replication.settings = settings;
    replication.sourceBenchmark = source_benchmark(replication.audit);
    replication.discrepancy = discrepancy_statement();
    assert(all(replication.audit.PreparationTimeSamples == 30));
    assert(all(replication.audit.MovementTimeSamples == 30));
    assert(all(isfinite(replication.null.AlignmentIndex)));
    assert(all(replication.null.AlignmentIndex >= -1e-12));
    assert(all(replication.null.AlignmentIndex <= 1 + 1e-10));
end

function settings = analysis_settings(model, options)
    settings.version = 'CURRENT AUTHORIZED REVISION 2026-08-31';
    settings.sampleIntervalS = 0.010;
    settings.prepStartS = 0.150;
    settings.prepEndExclusiveS = 0.450;
    settings.modelMovementOnsetAfterControlRemovalS = 0.100;
    settings.moveStartFromMovementOnsetS = -0.050;
    settings.moveEndExclusiveFromMovementOnsetS = 0.250;
    settings.moveStartFromControlRemovalS = 0.050;
    settings.moveEndExclusiveFromControlRemovalS = 0.350;
    settings.prepTimesS = settings.prepStartS + ...
        (0:29) * settings.sampleIntervalS;
    settings.moveTimesS = settings.moveStartFromControlRemovalS + ...
        (0:29) * settings.sampleIntervalS;
    settings.nullDraws = 10000;
    settings.bootstrapDraws = 2000;
    settings.nullSeed = 83101;
    settings.bootstrapSeed = 83111;
    settings.preprocessing = "Elsayed/Kao: divide every neuron's rates by " + ...
        "its across-full-task range plus 5; at each time subtract the " + ...
        "across-condition mean; stack 30 times x 8 conditions by neuron. " + ...
        "The full-task covariance concatenates the processed preparation " + ...
        "and movement matrices. Windows are half-open 300-ms intervals.";
    if isfield(options, 'nullDraws')
        settings.nullDraws = options.nullDraws;
    end
    if isfield(options, 'bootstrapDraws')
        settings.bootstrapDraws = options.bootstrapDraws;
    end
    assert(abs(model.samplingDt - 0.001) < eps);
end

function data = prepare_controller_data(model, results, controllerIndex, settings)
    preparation = results.preparations{controllerIndex};
    prepIndices = round(settings.prepTimesS / model.samplingDt) + 1;
    goIndex = round(0.500 / model.samplingDt) + 1;
    goStates = squeeze(preparation.states(goIndex, :, :));
    movement = simulate_published_cortex(model, goStates, true);
    moveIndices = round(settings.moveTimesS / model.samplingDt) + 1;
    prepRaw = permute(max(preparation.states(prepIndices, :, :), 0), [1, 3, 2]);
    moveRaw = permute(movement.rates(moveIndices, :, :), [1, 3, 2]);
    combinedRaw = cat(1, prepRaw, moveRaw);
    flatRaw = reshape(combinedRaw, [], model.n);
    normalizationFactor = max(flatRaw, [], 1) - min(flatRaw, [], 1) + 5;
    assert(all(normalizationFactor > 0));
    prepNormalized = prepRaw ./ reshape(normalizationFactor, 1, 1, []);
    moveNormalized = moveRaw ./ reshape(normalizationFactor, 1, 1, []);
    prepCentered = prepNormalized - mean(prepNormalized, 2);
    moveCentered = moveNormalized - mean(moveNormalized, 2);
    data.prepMatrix = reshape(permute(prepCentered, [3, 1, 2]), model.n, []);
    data.moveMatrix = reshape(permute(moveCentered, [3, 1, 2]), model.n, []);
    data.fullMatrix = [data.prepMatrix, data.moveMatrix];
    data.Cprep = data.prepMatrix * data.prepMatrix.';
    data.Cmove = data.moveMatrix * data.moveMatrix.';
    data.Cfull = data.fullMatrix * data.fullMatrix.';
    [data.prepEigenvectors, prepValues] = svd_sorted(data.Cprep);
    [data.moveEigenvectors, moveValues] = svd_sorted(data.Cmove);
    data.prepEigenvalues = prepValues;
    data.moveEigenvalues = moveValues;
    data.normalizationFactor = normalizationFactor;
    prepMean = mean(prepCentered, 2);
    moveMean = mean(moveCentered, 2);
    assert(norm(prepMean(:)) < 1e-12);
    assert(norm(moveMean(:)) < 1e-12);
end

function nullValues = covariance_biased_null(Cfull, prepMatrix, dimension, ...
        nDraws, seed)
    [fullBasis, singularValues] = svd_sorted(Cfull);
    biasMatrix = fullBasis * diag(sqrt(max(singularValues, 0)));
    Cprep = prepMatrix * prepMatrix.';
    prepValues = svd(Cprep);
    denominator = sum(prepValues(1:dimension));
    nullValues = zeros(nDraws, 1);
    rng(seed, 'twister');
    for draw = 1:nDraws
        randomVectors = randn(size(Cfull, 1), dimension);
        randomVectors = randomVectors ./ vecnorm(randomVectors, 2, 1);
        randomBasis = orth(biasMatrix * randomVectors);
        assert(size(randomBasis, 2) == dimension);
        nullValues(draw) = trace(randomBasis.' * Cprep * randomBasis) / ...
            denominator;
    end
end

function [vectors, values] = svd_sorted(matrix)
    matrix = (matrix + matrix.') / 2;
    [vectors, singularMatrix] = svd(matrix, 'econ');
    values = max(real(diag(singularMatrix)), 0);
end

function value = participation_ratio(eigenvalues)
    eigenvalues = max(real(eigenvalues), 0);
    value = sum(eigenvalues) ^ 2 / sum(eigenvalues .^ 2);
end

function benchmark = source_benchmark(audit)
    row = audit.Controller == "Stage 2B-Kao" & ...
        abs(audit.VarianceThreshold - 0.80) < eps;
    assert(nnz(row) == 1);
    benchmark.pinnedRepositoryCommit = ...
        '40077d2da16e68ab2ab2cff59ec692b97315980b';
    benchmark.pinnedNetworkInstancesAvailable = 1;
    benchmark.originalFigure6CNetworkInstances = 10;
    benchmark.originalFigure6CAnalysisCodeAvailable = false;
    benchmark.originalFigure6CNumericalDataAvailable = false;
    benchmark.methodReplicationStatus = 'PASS';
    benchmark.elsayedReferenceCode = ...
        'https://github.com/gamaleldin/rand_subspaces';
    benchmark.figure6CDigitizedISNLQRObservedMeanApprox = 0.16;
    benchmark.figure6CDigitizedISNLQRNullMeanApprox = 0.52;
    benchmark.singlePinnedInstanceObserved = audit.ObservedAlignment(row);
    benchmark.singlePinnedInstanceNullMedian = audit.NullMedian(row);
    benchmark.status = ['PASS WITH RELEASE LIMITATION: source-faithful ' ...
        'single-instance benchmark. The pinned ' ...
        'release contains one ISN realization and no Figure-6C numerical table ' ...
        'or ten-network ensemble, so the published across-network mean and SD ' ...
        'cannot be reproduced exactly from the released material.'];
end

function statement = discrepancy_statement()
    statement = "The superseded 0.376/0.789 result used 31-point inclusive " + ...
        "windows (310 ms), omitted Elsayed's per-neuron range-plus-5 " + ...
        "normalization, and replaced the published continuous covariance-" + ...
        "biased Gaussian/orth sampler with weighted selection of discrete " + ...
        "full-task eigenvectors. The first two choices change the observed " + ...
        "PC geometry; the third changes the expected/null distribution.";
end

function validate_inputs(model, results)
    assert(model.n == 200 && model.nMovements == 8);
    assert(numel(results.controllers) >= 3);
    assert(strcmp(results.controllers{2}.name, 'Stage 2B-Kao'));
    assert(strcmp(results.controllers{3}.name, 'Stage 2B-Cerebellum'));
    assert(size(results.preparations{2}.states, 1) >= 501);
    assert(size(results.preparations{3}.states, 1) >= 501);
end
