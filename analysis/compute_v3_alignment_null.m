function null = compute_v3_alignment_null( ...
        preparatoryCovariance, movementCovariance, dimension, ...
        numSamples, seed)
    n = size(preparatoryCovariance, 1);
    if ~isequal(size(preparatoryCovariance), [n n]) || ...
            ~isequal(size(movementCovariance), [n n])
        error('V3Analysis:NullDimensions', ...
            'Both covariance matrices must be N-by-N.');
    end
    if dimension < 1 || dimension > n || numSamples < 1
        error('V3Analysis:NullArguments', ...
            'Invalid subspace dimension or number of null samples.');
    end
    preparatoryOptimal = leading_variance( ...
        preparatoryCovariance, dimension);
    movementOptimal = leading_variance(movementCovariance, dimension);
    previousState = rng;
    cleanup = onCleanup(@() rng(previousState));
    rng(seed, 'twister');
    null.preparatoryToRandom = zeros(1, numSamples);
    null.movementToRandom = zeros(1, numSamples);
    for sampleIndex = 1:numSamples
        [randomPrep, ~] = qr(randn(n, dimension), 0);
        [randomMove, ~] = qr(randn(n, dimension), 0);
        null.preparatoryToRandom(sampleIndex) = trace(randomMove' * ...
            preparatoryCovariance * randomMove) / ...
            max(preparatoryOptimal, eps);
        null.movementToRandom(sampleIndex) = trace(randomPrep' * ...
            movementCovariance * randomPrep) / ...
            max(movementOptimal, eps);
    end
    clear cleanup;
end

function value = leading_variance(covariance, dimension)
    values = sort(max(real(eig(covariance)), 0), 'descend');
    value = sum(values(1:dimension));
end
