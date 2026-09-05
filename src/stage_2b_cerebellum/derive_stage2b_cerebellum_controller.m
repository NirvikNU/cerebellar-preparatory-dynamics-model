function controller = derive_stage2b_cerebellum_controller(model, cfg)
    n = model.n;
    assert(n == cfg.controller.stateDimension);
    k = cfg.controller.actuatorDimension; % Should be 13
    assert(k == 13, 'Actuator dimension must be exactly 13 for Stage 2B-Cerebellum.');

    A = model.A;
    Qraw = 0.5 * (model.Qnative + model.Qnative.');
    Q = (n / trace(Qraw)) * Qraw;

    [V_Q, D_Q] = eig(Q, 'vector');
    [D_Q, sortIdx] = sort(D_Q, 'descend');
    V_Q = V_Q(:, sortIdx);

    cumulativePotency = cumsum(D_Q) / sum(D_Q);
    eig13 = D_Q(13);
    eig14 = D_Q(14);
    boundaryScale = max([norm(Q, 2), abs(eig13), abs(eig14), 1]);
    boundaryTolerance = cfg.validation.eigenBoundaryScaleFactor * ...
        eps(boundaryScale) * boundaryScale;
    if abs(eig13 - eig14) <= boundaryTolerance
        error('Degenerate boundary at Q eigenvalues 13 and 14: %e vs %e', eig13, eig14);
    end

    B_CB = V_Q(:, 1:k);
    assert(size(B_CB, 1) == n && size(B_CB, 2) == k);
    orthoError = norm(B_CB' * B_CB - eye(k), 'fro');
    assert(orthoError < cfg.validation.orthonormalTolerance, ...
        'Actuator basis is not orthonormal');
    assert(rank(B_CB) == k, 'Actuator basis is not full rank');

    R_CB = cfg.controller.lambda * eye(k);

    openLoopEigenvalues = eig(A);
    unstable_idx = find(real(openLoopEigenvalues) >= ...
        -cfg.validation.pbhRelativeTolerance);
    uncontrollableUnstableCount = 0;
    minimumPbhRelativeMargin = 1;
    for i = 1:length(unstable_idx)
        lambda = openLoopEigenvalues(unstable_idx(i));
        pbhMatrix = [lambda * eye(n) - A, B_CB];
        singularValues = svd(pbhMatrix);
        relativeMargin = singularValues(end) / max(norm(pbhMatrix, 2), eps);
        minimumPbhRelativeMargin = min(minimumPbhRelativeMargin, relativeMargin);
        if relativeMargin <= cfg.validation.pbhRelativeTolerance
            uncontrollableUnstableCount = uncontrollableUnstableCount + 1;
        end
    end

    if uncontrollableUnstableCount > 0
        error('System is not stabilizable with reduced B.');
    end

    [P, closedLoopEigenvalues, positiveGain] = care(A, B_CB, Q, R_CB);
    K_CB = -positiveGain;
    effectiveFeedback = B_CB * K_CB;

    careResidual = A.' * P + P * A - P * B_CB * (R_CB \ (B_CB.' * P)) + Q;
    careResidualRelative = norm(careResidual, 'fro') / max(norm(Q, 'fro'), eps);
    assert(careResidualRelative < cfg.validation.careResidualTolerance);

    maxClosedLoopEig = max(real(closedLoopEigenvalues));
    assert(maxClosedLoopEig < -1e-10, 'CARE closed loop is not strictly stable');

    targetRates = max(model.xstar, 0);
    tonicInput = model.xstar - model.W * targetRates - model.h;
    targetInput = tonicInput - effectiveFeedback * targetRates;

    fixedPointResidual = -model.xstar + model.W * targetRates + model.h ...
        + targetInput + effectiveFeedback * targetRates;
    fixedPointResidualNorm = vecnorm(fixedPointResidual, 2, 1).';
    assert(max(fixedPointResidualNorm) < cfg.validation.fixedPointTolerance);

    % Target Jacobian local stability check
    % Jacobian = W * diag(rstar > 0) - I + effectiveFeedback * diag(rstar > 0)
    for tIdx = 1:size(model.xstar, 2)
        rstar_t = targetRates(:, tIdx);
        active_mask = rstar_t > 0;
        J = (model.W + effectiveFeedback) * diag(active_mask) - eye(n);
        maxJ_eig = max(real(eig(J))); assert(maxJ_eig < 1e-8, 'Target Jacobian is locally unstable.');
        assert(maxJ_eig < -1e-6, sprintf('Target %d is locally unstable with max eig %e', tIdx, maxJ_eig));
    end

    controller.name = 'Stage 2B-Cerebellum';
    controller.A = A;
    controller.B = B_CB;
    controller.Q = Q;
    controller.Qraw = Qraw;
    controller.qScaleFromStage1 = n / trace(Qraw);
    controller.R = R_CB;
    controller.P = P;
    controller.K = K_CB;
    controller.effectiveFeedback = effectiveFeedback;
    controller.tonicInput = tonicInput;
    controller.targetInput = targetInput;
    controller.fixedPointResidual = fixedPointResidual;
    controller.fixedPointResidualNorm = fixedPointResidualNorm;
    controller.careResidual = careResidual;
    controller.careResidualRelative = careResidualRelative;
    controller.openLoopEigenvalues = openLoopEigenvalues;
    controller.closedLoopEigenvalues = closedLoopEigenvalues;
    controller.stabilizable = true;
    controller.uncontrollableUnstableCount = uncontrollableUnstableCount;
    controller.pbhModesChecked = numel(unstable_idx);
    controller.minimumPbhRelativeMargin = minimumPbhRelativeMargin;
    controller.gainFrobeniusNorm = norm(K_CB, 'fro');
    controller.inputDimension = k;
    controller.stateDimension = n;
    controller.lambda = cfg.controller.lambda;
    controller.qTrace = trace(Q);

    % New fields for Cerebellum
    controller.qEigenvalues = D_Q;
    controller.qCumulativePotency = cumulativePotency;
    controller.qPotencyTop13 = cumulativePotency(13);
    controller.k95 = find(cumulativePotency >= 0.95, 1);
    controller.eigGap13_14 = eig13 - eig14;
    controller.eigGap13_14Relative = (eig13 - eig14) / max(abs(eig13), eps);
    controller.eigBoundaryTolerance = boundaryTolerance;
    controller.maxClosedLoopEig = maxClosedLoopEig;

    controller.sourceEquation = ['u_q(t)=tonicInput + B_{CB} K_{CB} (r(t)-r_q^*), ' ...
        'K_{CB}=-lambda^{-1}B_{CB}^T P'];
end
