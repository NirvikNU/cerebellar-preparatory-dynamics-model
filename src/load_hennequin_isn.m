function fixed = load_hennequin_isn(params, projectRoot)
    matrixPath = fullfile(projectRoot, params.files.isnMatrix);
    actualSha256 = file_sha256(matrixPath);
    if ~strcmpi(actualSha256, params.model.isnSourceSha256)
        error('V2Model:MatrixHash', ...
            'Official W_rec SHA-256 mismatch: expected %s, found %s.', ...
            params.model.isnSourceSha256, actualSha256);
    end
    recurrentMatrix = single(readmatrix(matrixPath, 'FileType', 'text'));
    expectedSize = repmat(params.model.numCorticalUnits, 1, 2);
    if ~isequal(size(recurrentMatrix), expectedSize)
        error('V2Model:MatrixSize', 'Official W_rec must be 200-by-200.');
    end
    eigenvalues = eig(double(recurrentMatrix));
    spectralAbscissa = max(real(eigenvalues));
    if spectralAbscissa >= params.model.isnSpectralAbscissaLimit
        error('V2Model:UnstableBackbone', ...
            'Official W_rec spectral abscissa %.6f is not below %.3f.', ...
            spectralAbscissa, params.model.isnSpectralAbscissaLimit);
    end

    rng(params.seed.baselineRates, 'twister');
    probabilities = ((1:expectedSize(1)) - 0.5) / expectedSize(1);
    logSigma = sqrt(log(1 + (params.model.baselineStdHz / ...
        params.model.baselineMeanHz)^2));
    logMean = log(params.model.baselineMeanHz) - 0.5 * logSigma^2;
    normalQuantiles = sqrt(2) * erfinv(2 * probabilities - 1);
    baselineRates = exp(logMean + logSigma * normalQuantiles);
    baselineRates = single(baselineRates(randperm(expectedSize(1)))');
    baselineDrive = baselineRates - recurrentMatrix * baselineRates;

    fixed.Wrec = recurrentMatrix;
    fixed.baselineRates = baselineRates;
    fixed.baselineDrive = baselineDrive;
    fixed.spectralAbscissa = spectralAbscissa;
    fixed.spectralRadius = max(abs(eigenvalues));
    fixed.nonnormalCommutator = norm(double(recurrentMatrix' * ...
        recurrentMatrix - recurrentMatrix * recurrentMatrix'), 'fro') / ...
        norm(double(recurrentMatrix), 'fro')^2;
    fixed.sourceSha256 = actualSha256;
    fixed.sourceCommit = params.model.isnSourceCommit;
end

function hash = file_sha256(path)
    file = fopen(path, 'rb');
    if file < 0
        error('V2Model:MatrixFile', 'Cannot open official W_rec: %s', path);
    end
    cleanup = onCleanup(@() fclose(file));
    bytes = fread(file, Inf, '*uint8');
    engine = java.security.MessageDigest.getInstance('SHA-256');
    engine.update(typecast(bytes, 'int8'));
    digest = typecast(engine.digest(), 'uint8');
    hash = upper(reshape(dec2hex(digest, 2).', 1, []));
    clear cleanup;
end
