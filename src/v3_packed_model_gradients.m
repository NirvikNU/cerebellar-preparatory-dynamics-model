function [loss, gradientVector] = v3_packed_model_gradients( ...
        parameterVector, staticModel, layout, task, params, noise)
    model = unpack_v3_trainables(staticModel, parameterVector, layout);
    loss = v3_model_loss(model, task, params, noise);
    gradientVector = dlgradient(loss, parameterVector);
end
