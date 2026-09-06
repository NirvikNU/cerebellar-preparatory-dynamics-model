function summary = bootstrap_network_median(values, nSamples, seed)
    assert(isnumeric(values) && ismatrix(values));
    assert(size(values, 1) >= 2, ...
        'Network bootstrap requires at least two network rows.');
    assert(all(isfinite(values), 'all'));
    assert(nSamples >= 1 && nSamples == round(nSamples));
    previous = rng;
    cleanup = onCleanup(@() rng(previous));
    rng(seed, 'twister');
    nNetworks = size(values, 1);
    nColumns = size(values, 2);
    bootstrapValues = zeros(nSamples, nColumns);
    for sample = 1:nSamples
        indices = randi(nNetworks, nNetworks, 1);
        bootstrapValues(sample, :) = median(values(indices, :), 1);
    end
    summary.median = median(values, 1);
    summary.standardError = std(bootstrapValues, 0, 1);
    summary.lower95 = prctile(bootstrapValues, 2.5, 1);
    summary.upper95 = prctile(bootstrapValues, 97.5, 1);
    summary.minimum = min(values, [], 1);
    summary.maximum = max(values, [], 1);
    summary.nNetworks = nNetworks;
    summary.nSamples = nSamples;
    summary.seed = seed;
end
