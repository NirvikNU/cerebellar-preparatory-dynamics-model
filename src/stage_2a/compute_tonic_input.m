function [tonicInput, residual] = compute_tonic_input(model)
    targetRates = max(model.xstar, 0);
    tonicInput = model.xstar - model.W * targetRates - model.h;
    residual = -model.xstar + model.W * targetRates + model.h + tonicInput;
end
