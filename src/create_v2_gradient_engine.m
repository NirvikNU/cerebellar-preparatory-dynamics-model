function [gradientFunction, parameterVector, layout, staticModel] = ...
        create_v2_gradient_engine(model, params, useAccelerated)
    [parameterVector, layout] = pack_v2_trainables(model);
    staticModel = rmfield(model, v2_trainable_fields());
    gradientCore = @(parameters, task, noise) ...
        v2_packed_model_gradients(parameters, staticModel, layout, ...
        task, params, noise);
    gradientFunction = gradientCore;
    if useAccelerated
        gradientFunction = dlaccelerate(gradientCore);
    end
end
