function targetState = compute_v3_cerebellar_target(model, targetIdentity)
    if size(targetIdentity, 1) ~= 8
        error('V3Model:CerebellarInput', ...
            'The cerebellar generator accepts only 8-D target identity.');
    end
    hiddenState = tanh(model.WcbHidden * targetIdentity + ...
        model.bcbHidden);
    targetState = model.WcbLatent * hiddenState + model.bcbLatent;
end
