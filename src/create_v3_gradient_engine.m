function [gradientFunction, parameterVector, layout, staticModel] = ...
        create_v3_gradient_engine(model, params, useAccelerated)
    [parameterVector, layout] = pack_v3_trainables(model);
    staticModel = rmfield(model, v3_trainable_fields());
    gradientCore = @(parameters, task, noise) ...
        v3_packed_model_gradients(parameters, staticModel, layout, ...
        task, params, noise);
    gradientFunction = gradientCore;
    if useAccelerated
        gradientFunction = dlaccelerate(gradientCore);
    end
end
