function controller = derive_stage2b_kao_controller(model, cfg)
    n = model.n;
    assert(n == cfg.controller.stateDimension);
    A = model.A;
    B = eye(n);
    Qraw = 0.5 * (model.Qnative + model.Qnative.');
    Q = (n / trace(Qraw)) * Qraw;
    R = cfg.controller.lambda * eye(n);
    assert(abs(trace(Q) - cfg.controller.qTrace) <= ...
        cfg.validation.qTraceTolerance * cfg.controller.qTrace);
    [P, closedLoopEigenvalues, positiveGain] = care(A, B, Q, R);
    K = -positiveGain;
    effectiveFeedback = B * K;
    careResidual = A.' * P + P * A - ...
        P * B * (R \ (B.' * P)) + Q;
    careResidualRelative = norm(careResidual, 'fro') / ...
        max(norm(Q, 'fro'), eps);
    assert(careResidualRelative < cfg.validation.careResidualTolerance);
    targetRates = max(model.xstar, 0);
    tonicInput = model.xstar - model.W * targetRates - model.h;
    targetInput = tonicInput - effectiveFeedback * targetRates;
    fixedPointResidual = -model.xstar + model.W * targetRates + model.h ...
        + targetInput + effectiveFeedback * targetRates;
    fixedPointResidualNorm = vecnorm(fixedPointResidual, 2, 1).';
    assert(max(fixedPointResidualNorm) < cfg.validation.fixedPointTolerance);
    openLoopEigenvalues = eig(A);
    unstable = real(openLoopEigenvalues) >= 0;
    stabilizable = ~any(unstable);
    controller.name = 'Stage 2B-Kao';
    controller.A = A;
    controller.B = B;
    controller.Q = Q;
    controller.Qraw = Qraw;
    controller.qScaleFromStage1 = n / trace(Qraw);
    controller.R = R;
    controller.P = P;
    controller.K = K;
    controller.effectiveFeedback = effectiveFeedback;
    controller.tonicInput = tonicInput;
    controller.targetInput = targetInput;
    controller.fixedPointResidual = fixedPointResidual;
    controller.fixedPointResidualNorm = fixedPointResidualNorm;
    controller.careResidual = careResidual;
    controller.careResidualRelative = careResidualRelative;
    controller.openLoopEigenvalues = openLoopEigenvalues;
    controller.closedLoopEigenvalues = closedLoopEigenvalues;
    controller.stabilizable = stabilizable;
    controller.uncontrollableUnstableCount = sum(unstable);
    controller.gainFrobeniusNorm = norm(K, 'fro');
    controller.inputDimension = size(B, 2);
    controller.stateDimension = n;
    controller.lambda = cfg.controller.lambda;
    controller.qTrace = trace(Q);
    controller.targetGainMaximumDifference = 0;
    controller.sourceEquation = ['u_q(t)=u_q^+ + K(r(t)-r_q^*), ' ...
        'K=-lambda^{-1}B^T P'];
end
