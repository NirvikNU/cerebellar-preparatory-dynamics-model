function latent = generate_cerebellar_latent(model, generatorInput)
    hiddenActivity = tanh(model.WcbHidden * generatorInput + ...
        model.bcbHidden);
    latent = model.WcbLatent * hiddenActivity + model.bcbLatent;
end
