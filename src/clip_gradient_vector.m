function [gradient, globalNorm] = clip_gradient_vector(gradient, threshold)
    data = extractdata(gradient);
    globalNorm = sqrt(double(gather(sum(data.^2, 'all'))));
    if globalNorm > threshold
        gradient = gradient * (threshold / globalNorm);
    end
end
