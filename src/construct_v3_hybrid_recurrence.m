function fixed = construct_v3_hybrid_recurrence(params, projectRoot)
    referencePath = fullfile(projectRoot, params.files.referenceMatrix);
    actualSha256 = file_sha256(referencePath);
    if ~strcmpi(actualSha256, params.reference.sha256)
        error('V3Model:ReferenceHash', ...
            'Reference Wrec SHA-256 mismatch: expected %s, found %s.', ...
            params.reference.sha256, actualSha256);
    end
    reference = double(readmatrix(referencePath, 'FileType', 'text'));
    n = params.model.numCorticalUnits;
    if ~isequal(size(reference), [n n])
        error('V3Model:ReferenceSize', ...
            'The Hennequin scale-reference matrix must be %d-by-%d.', n, n);
    end
    referenceEigenvalues = eig(reference);
    referenceSpectralAbscissa = max(real(referenceEigenvalues));
    referenceFrobeniusNorm = norm(reference, 'fro');

    kPrep = params.hybrid.kPrep;
    kMove = params.hybrid.kMove;
    kBackground = n - kPrep - kMove;
    if kPrep <= 0 || kMove <= 0 || kBackground <= 0
        error('V3Model:HybridDimensions', ...
            'kPrep and kMove must be positive and leave a background.');
    end

    previousState = rng;
    cleanup = onCleanup(@() rng(previousState));
    rng(params.hybrid.randomSeed, 'twister');
    [populationBasis, triangular] = qr(randn(n), 0);
    columnSigns = sign(diag(triangular));
    columnSigns(columnSigns == 0) = 1;
    populationBasis = populationBasis .* columnSigns';

    prepIndex = 1:kPrep;
    moveIndex = kPrep + (1:kMove);
    backgroundIndex = kPrep + kMove + (1:kBackground);
    operator = zeros(n);
    prepSpectrum = linspace(0.70, 1.00, kPrep);
    operator(prepIndex, prepIndex) = ...
        params.hybrid.preparationBlockScale * diag(prepSpectrum);

    upstream = [zeros(floor(kMove / 2), 1); ...
        ones(ceil(kMove / 2), 1)];
    downstream = [ones(floor(kMove / 2), 1); ...
        zeros(ceil(kMove / 2), 1)];
    upstream = upstream / norm(upstream);
    downstream = downstream / norm(downstream);
    feedforwardMovement = downstream * upstream';
    movementBlock = params.hybrid.movementDiagonalScale * eye(kMove) + ...
        params.hybrid.movementNonNormalScale * feedforwardMovement;
    operator(moveIndex, moveIndex) = movementBlock;
    operator(moveIndex, prepIndex) = ...
        params.hybrid.prepToMovementCouplingScale * eye(kMove, kPrep);
    backgroundSpectrum = linspace(-1, 1, kBackground);
    operator(backgroundIndex, backgroundIndex) = ...
        params.hybrid.backgroundScale * diag(backgroundSpectrum);

    rawSpectralAbscissa = max(real(eig(operator)));
    targetSpectralAbscissa = ...
        params.hybrid.referenceSpectralAbscissaFraction * ...
        referenceSpectralAbscissa;
    spectralScale = targetSpectralAbscissa / rawSpectralAbscissa;
    maximumFrobeniusNorm = ...
        params.hybrid.maximumReferenceFrobeniusFraction * ...
        referenceFrobeniusNorm;
    frobeniusScale = maximumFrobeniusNorm / norm(operator, 'fro');
    globalNormalization = min(spectralScale, frobeniusScale);
    operator = globalNormalization * operator;
    recurrentMatrix = populationBasis * operator * populationBasis';
    recurrentMatrix = (recurrentMatrix + recurrentMatrix') / 2 + ...
        (recurrentMatrix - recurrentMatrix') / 2;
    recurrentEigenvalues = eig(recurrentMatrix);
    spectralAbscissa = max(real(recurrentEigenvalues));
    if spectralAbscissa >= 1
        error('V3Model:HybridInstability', ...
            'Hybrid Wrec spectral abscissa %.6f must be below 1.', ...
            spectralAbscissa);
    end

    rng(params.seed.baselineRates, 'twister');
    probabilities = ((1:n) - 0.5) / n;
    logSigma = sqrt(log(1 + (params.model.baselineStdHz / ...
        params.model.baselineMeanHz)^2));
    logMean = log(params.model.baselineMeanHz) - 0.5 * logSigma^2;
    normalQuantiles = sqrt(2) * erfinv(2 * probabilities - 1);
    baselineRates = exp(logMean + logSigma * normalQuantiles);
    baselineRates = single(baselineRates(randperm(n))');
    recurrentMatrix = single(recurrentMatrix);
    baselineDrive = baselineRates - recurrentMatrix * baselineRates;

    fixed.Wrec = recurrentMatrix;
    fixed.baselineRates = baselineRates;
    fixed.baselineDrive = baselineDrive;
    fixed.Qprep = single(populationBasis(:, prepIndex));
    fixed.Qmove = single(populationBasis(:, moveIndex));
    fixed.Qbackground = single(populationBasis(:, backgroundIndex));
    fixed.hybrid.operator = single(operator);
    fixed.hybrid.globalNormalization = globalNormalization;
    fixed.hybrid.rawSpectralAbscissa = rawSpectralAbscissa;
    fixed.hybrid.spectralAbscissa = spectralAbscissa;
    fixed.hybrid.spectralRadius = max(abs(recurrentEigenvalues));
    fixed.hybrid.frobeniusNorm = norm(double(recurrentMatrix), 'fro');
    fixed.hybrid.operatorNorm = norm(double(recurrentMatrix), 2);
    fixed.hybrid.nonnormalCommutator = nonnormality(recurrentMatrix);
    fixed.hybrid.prepMoveBasisOverlap = ...
        norm(double(fixed.Qprep' * fixed.Qmove), 'fro');
    fixed.reference.sha256 = actualSha256;
    fixed.reference.spectralAbscissa = referenceSpectralAbscissa;
    fixed.reference.spectralRadius = max(abs(referenceEigenvalues));
    fixed.reference.frobeniusNorm = referenceFrobeniusNorm;
    fixed.reference.operatorNorm = norm(reference, 2);
    fixed.reference.nonnormalCommutator = nonnormality(reference);
    clear cleanup;
end

function value = nonnormality(matrix)
    matrix = double(matrix);
    value = norm(matrix' * matrix - matrix * matrix', 'fro') / ...
        max(norm(matrix, 'fro')^2, eps);
end

function hash = file_sha256(path)
    file = fopen(path, 'rb');
    if file < 0
        error('V3Model:ReferenceFile', ...
            'Cannot open Hennequin scale-reference matrix: %s', path);
    end
    cleanup = onCleanup(@() fclose(file));
    bytes = fread(file, Inf, '*uint8');
    engine = java.security.MessageDigest.getInstance('SHA-256');
    engine.update(typecast(bytes, 'int8'));
    digest = typecast(engine.digest(), 'uint8');
    hash = upper(reshape(dec2hex(digest, 2).', 1, []));
    clear cleanup;
end
