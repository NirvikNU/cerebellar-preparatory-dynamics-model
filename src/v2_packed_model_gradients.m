function [loss, gradientVector, components] = v2_packed_model_gradients( ...
        parameterVector, staticModel, layout, task, params, noise)
    model = unpack_v2_trainables(staticModel, parameterVector, layout);
    [loss, components] = v2_model_loss(model, task, params, noise);
    gradientVector = dlgradient(loss, parameterVector);
end
