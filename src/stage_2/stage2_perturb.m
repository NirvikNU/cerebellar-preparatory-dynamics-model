function out = stage2_perturb(model, ctl, cfg, stream)
    % Fixed stream order: neuron, then trial, then target, then network.
    epsilon = cfg.perturbationSD*randn(stream,model.n,cfg.perturbationTrials,8);
    epsilon = reshape(epsilon,model.n,[]);
    target = repelem(model.xstar,1,cfg.perturbationTrials);
    specific = repelem(ctl.specific,1,cfg.perturbationTrials);
    x = target+epsilon;
    out.initialNorm = sqrt(sum(epsilon.^2,1));
    out.initialActiveChangeFraction = mean((x>0)~=(target>0),1);
    [vectors,eigenvalues] = eig((ctl.Q+ctl.Q.')/2,'vector');
    [~,order] = sort(eigenvalues,'descend');
    top = vectors(:,order(1:10));
    bottom = vectors(:,order(end-9:end));
    out.squaredError = zeros(cfg.perturbationMs+1,2);
    out.finalNorm = [];
    steps = round(cfg.perturbationMs/1000/model.dt);
    every = round(model.samplingDt/model.dt);
    WK = model.W+ctl.K;
    for step = 0:steps
        if mod(step,every)==0
            dx = x-target;
            out.squaredError(step/every+1,:) = ...
                [mean(sum((top.'*dx).^2,1)) mean(sum((bottom.'*dx).^2,1))];
        end
        if step < steps
            x = x+(model.dt/model.tau)*(-x+WK*max(x,0)+model.h+specific);
        end
    end
    out.finalNorm = sqrt(sum((x-target).^2,1));
    assert(all(isfinite(x),'all') && all(isfinite(out.squaredError),'all'));
end
