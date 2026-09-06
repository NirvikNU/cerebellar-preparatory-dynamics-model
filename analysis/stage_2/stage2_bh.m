function q = stage2_bh(p)
    [sorted,order] = sort(p(:));
    adjusted = sorted*numel(p)./(1:numel(p)).';
    adjusted = min(1,flipud(cummin(flipud(adjusted))));
    q = zeros(size(p));
    q(order) = adjusted;
end
