function [latent, asymptote] = ...
        generate_relaxational_cerebellar_latent(model, targetInput, scale)
    hidden = tanh(model.WcbHidden * targetInput + model.bcbHidden);
    asymptote = model.WcbLatent * hidden + model.bcbLatent;
    latent = asymptote .* scale;
end
