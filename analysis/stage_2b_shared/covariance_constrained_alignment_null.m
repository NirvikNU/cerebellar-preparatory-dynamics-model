function result = covariance_constrained_alignment_null(geometry, ...
        varianceThreshold, nDraws, seed)
    cumulative = cumsum(geometry.prepValues) / ...
        max(sum(geometry.prepValues), eps);
    k = find(cumulative >= varianceThreshold, 1, 'first');
    denominator = sum(geometry.prepValues(1:k));
    moveBasis = geometry.moveVectors(:, 1:k);
    observed = trace(moveBasis.' * geometry.Cprep * moveBasis) / ...
        max(denominator, eps);
    [fullBasis, fullValues] = sorted_spectrum(geometry.Cfull);
    squareRootCovariance = fullBasis * diag(sqrt(max(fullValues, 0)));
    previous = rng;
    cleanup = onCleanup(@() rng(previous));
    rng(seed, 'twister');
    nullValues = zeros(nDraws, 1);
    for draw = 1:nDraws
        gaussian = randn(size(geometry.Cfull, 1), k);
        gaussian = gaussian ./ max(vecnorm(gaussian, 2, 1), eps);
        randomBasis = orth(squareRootCovariance * gaussian);
        assert(size(randomBasis, 2) == k);
        nullValues(draw) = trace(randomBasis.' * geometry.Cprep * ...
            randomBasis) / max(denominator, eps);
    end
    interval = prctile(nullValues, [2.5, 97.5]);
    result.k = k;
    result.observed = observed;
    result.nullValues = nullValues;
    result.nullMedian = median(nullValues);
    result.nullMean = mean(nullValues);
    result.nullSD = std(nullValues, 0);
    result.nullLower95 = interval(1);
    result.nullUpper95 = interval(2);
    result.lowerTailP = (1 + sum(nullValues <= observed)) / (nDraws + 1);
    result.draws = nDraws;
    result.seed = seed;
    assert(all(isfinite(nullValues)));
    assert(all(nullValues >= -1e-10 & nullValues <= 1 + 1e-8));
end

function [vectors, values] = sorted_spectrum(matrix)
    matrix = 0.5 * (matrix + matrix.');
    [vectors, singular] = svd(matrix, 'econ');
    values = max(real(diag(singular)), 0);
end
