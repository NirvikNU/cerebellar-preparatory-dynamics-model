function result = stage2_signflip(difference, indices)
    difference = difference(:);
    assert(numel(difference)==10 && all(isfinite(difference)));
    signs = zeros(1024,10);
    for j=1:10, signs(:,j)=2*double(bitget(uint16((0:1023).'),j))-1; end
    statistic = abs(mean(difference));
    permuted = abs(signs*difference/10);
    result.p = mean(permuted>=statistic-1e-12*max(1,statistic));
    result.meanDifference = mean(difference);
    uncertainty = stage2_bootstrap(difference,indices);
    result.medianDifference = uncertainty.median;
    result.medianDifferenceSE = uncertainty.se;
end
