function ctl = stage2_controller(model, lambda)
    % Independent MATLAB implementation of pinned Kao full-dimensional LQR.
    A = model.W - eye(model.n);
    raw = (model.Qnative + model.Qnative.') / 2;
    ctl.Q = model.n * raw / trace(raw);
    [P, poles, positiveGain] = care(A, eye(model.n), ctl.Q, lambda * eye(model.n));
    ctl.K = -positiveGain;
    ctl.P = P;
    ctl.lambda = lambda;
    ctl.tonic = model.xstar - model.h - model.W * max(model.xstar, 0);
    ctl.specific = model.xstar - model.h - (model.W + ctl.K) * max(model.xstar, 0);
    residual = A.'*P + P*A - P*P/lambda + ctl.Q;
    ctl.careRelativeResidual = norm(residual,'fro') / max(1,norm(ctl.Q,'fro'));
    ctl.gramianRelativeResidual = norm(A.'*raw + raw*A + model.C.'*model.C,'fro') ...
        / max(1,norm(model.C.'*model.C,'fro'));
    ctl.maxPole = max(real(poles));
    ctl.gainIdentityError = norm(ctl.K + P/lambda,'fro');
    ctl.fixedPointError = max(abs(-model.xstar + model.W*max(model.xstar,0) ...
        + model.h + ctl.specific + ctl.K*max(model.xstar,0)),[],'all');
    assert(isequal(size(ctl.K),[200 200]) && all(isfinite(ctl.K),'all'));
    assert(ctl.careRelativeResidual < 1e-7 && ctl.gramianRelativeResidual < 1e-7);
    assert(ctl.maxPole < 0 && ctl.gainIdentityError < 1e-9 && ctl.fixedPointError < 1e-10);
end
