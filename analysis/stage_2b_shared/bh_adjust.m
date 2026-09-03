function adjusted = bh_adjust(pValues)
    pValues = pValues(:);
    assert(all(isfinite(pValues) & pValues >= 0 & pValues <= 1));
    [sorted, order] = sort(pValues);
    count = numel(sorted);
    corrected = sorted .* count ./ (1:count).';
    corrected = flipud(cummin(flipud(corrected)));
    corrected = min(corrected, 1);
    adjusted = zeros(size(pValues));
    adjusted(order) = corrected;
end
