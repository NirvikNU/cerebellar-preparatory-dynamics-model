function controller = derive_stage2b_cerebellum_controller(model, cfg)
    n = model.n;
    Qraw = 0.5 * (model.Qnative + model.Qnative.');
    [vectors, values] = eig(Qraw, 'vector');
    [values, order] = sort(real(values), 'descend');
    vectors = real(vectors(:, order));
    k = cfg.controller.fixedActuatorDimension;
    B = vectors(:, 1:k);
    for column = 1:k
        [~, pivot] = max(abs(B(:, column)));
        if B(pivot, column) < 0
            B(:, column) = -B(:, column);
        end
    end
    orthonormalResidual = norm(B.' * B - eye(k), 'fro');
    assert(orthonormalResidual < cfg.validation.orthonormalTolerance);
    potencyFraction = sum(values(1:k)) / sum(values);
    assert(potencyFraction > cfg.validation.potencyFractionMinimum);
    Q = (n / trace(Qraw)) * Qraw;
    A = model.A;
    R = cfg.controller.lambda * eye(k);
    [P, closedLoopEigenvalues, positiveGain] = care(A, B, Q, R);
    K = -positiveGain;
    effectiveFeedback = B * K;
    careResidual = A.' * P + P * A - ...
        P * B * (R \ (B.' * P)) + Q;
    careResidualRelative = norm(careResidual, 'fro') / max(norm(Q, 'fro'), eps);
    assert(careResidualRelative < cfg.validation.careResidualTolerance);
    targetRates = max(model.xstar, 0);
    targetInput = model.xstar - model.W * targetRates - model.h ...
        - effectiveFeedback * targetRates;
    fixedPointResidual = -model.xstar + model.W * targetRates + model.h ...
        + targetInput + effectiveFeedback * targetRates;
    fixedPointResidualNorm = vecnorm(fixedPointResidual, 2, 1).';
    assert(max(fixedPointResidualNorm) < cfg.validation.fixedPointTolerance);
    openLoopEigenvalues = eig(A);
    unstable = real(openLoopEigenvalues) >= 0;
    controller.name = 'Stage 2B-Cerebellum';
    controller.A = A;
    controller.B = B;
    controller.Q = Q;
    controller.Qraw = Qraw;
    controller.qScaleFromStage1 = n / trace(Qraw);
    controller.R = R;
    controller.P = P;
    controller.K = K;
    controller.effectiveFeedback = effectiveFeedback;
    controller.targetInput = targetInput;
    controller.fixedPointResidual = fixedPointResidual;
    controller.fixedPointResidualNorm = fixedPointResidualNorm;
    controller.careResidual = careResidual;
    controller.careResidualRelative = careResidualRelative;
    controller.openLoopEigenvalues = openLoopEigenvalues;
    controller.closedLoopEigenvalues = closedLoopEigenvalues;
    controller.stabilizable = ~any(unstable);
    controller.uncontrollableUnstableCount = sum(unstable);
    controller.gainFrobeniusNorm = norm(K, 'fro');
    controller.inputDimension = k;
    controller.stateDimension = n;
    controller.lambda = cfg.controller.lambda;
    controller.qTrace = trace(Q);
    controller.BOrthonormalResidual = orthonormalResidual;
    controller.potencyFraction = potencyFraction;
    controller.qEigenvalues = values;
    controller.targetGainMaximumDifference = 0;
    controller.sourceEquation = ['u_q(t)=u_q^+ + B_CB K_CB(r(t)-r_q^*), ' ...
        'B_CB=fixed top-13 eigenvectors of Stage-1 Q'];
end
