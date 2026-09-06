function out = stage2_prepare(model, ctl, cfg)
    % All eight targets share one batched Euler loop; save exact endpoints.
    x = repmat(model.spontaneous,1,8);
    out.states = zeros(cfg.preparationMs+1,200,8);
    out.sourceCost = zeros(cfg.preparationMs+1,8);
    out.stateCost = out.sourceCost;
    effort = zeros(1,8);
    nSteps = round(cfg.preparationMs/1000/model.dt);
    sampleEvery = round(model.samplingDt/model.dt);
    WK = model.W + ctl.K;
    for step = 0:nSteps
        r = max(x,0);
        if mod(step,sampleEvery)==0
            row = step/sampleEvery+1;
            out.states(row,:,:) = permute(x,[3 1 2]);
            dr = r-model.xstar;
            dx = x-model.xstar;
            out.sourceCost(row,:) = sum(dr.*(ctl.Q*dr),1);
            out.stateCost(row,:) = sum(dx.*(ctl.Q*dx),1);
        end
        if step < nSteps
            feedback = ctl.K*(r-max(model.xstar,0));
            effort = effort + (model.dt/model.tau)*sum(feedback.^2,1);
            x = x + (model.dt/model.tau)*(-x+WK*r+model.h+ctl.specific);
        end
    end
    out.effort = mean(effort);
    out.rates = max(out.states,0);
    assert(all(isfinite(out.states),'all') && all(isfinite(out.sourceCost),'all'));
end
