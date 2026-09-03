function report = validate_stage2b_source_gate(cfg, model, controller)
    [status, commit] = system(sprintf('git -C "%s" rev-parse HEAD', cfg.sourceRoot));
    commit = strtrim(commit);
    assert(status == 0 && strcmp(commit, cfg.upstreamCommit), ...
        'Pinned source commit mismatch.');
    sourceFiles = {
        fullfile(cfg.sourceRoot, 'lib', 'defaults_base.ml'), ...
        fullfile(cfg.sourceRoot, 'lib', 'defaults.ml'), ...
        fullfile(cfg.sourceRoot, 'lib', 'controller.ml'), ...
        fullfile(cfg.sourceRoot, 'lib', 'lqr.ml'), ...
        fullfile(cfg.sourceRoot, 'lib', 'simple.ml'), ...
        fullfile(cfg.sourceRoot, 'lib', 'dynamics.ml')};
    texts = cellfun(@fileread, sourceFiles, 'UniformOutput', false);
    claims = {
        'Pinned commit', strcmp(commit, cfg.upstreamCommit), commit; ...
        'A = W - I', contains(texts{2}, 'let a = Mat.(w_rec - eye n)'), 'lib/defaults.ml'; ...
        'lambda = 0.1', contains(texts{1}, 'let r2_vanilla = 0.1'), 'lib/defaults_base.ml'; ...
        'full 200-D actuator', contains(texts{3}, 'Mat.eye n, Mat.(b *@ Lqr.classical_lqr'), 'lib/controller.ml'; ...
        'CARE-based classical LQR', contains(texts{4}, 'Linalg.D.care a b q r'), 'lib/lqr.ml'; ...
        'negative feedback sign', contains(texts{4}, 'neg (transpose b *@ x /$ r2)'), 'lib/lqr.ml'; ...
        'Q normalized to trace N', contains(texts{5}, 'unit_trace G.OSub.m_norm'), 'lib/simple.ml'; ...
        'target-specific nonlinear fixed-point correction', ...
            contains(texts{6}, 'specific_input = Mat.(xstar - h - ((w_rec + feedback) *@ nl xstar))'), ...
            'lib/dynamics.ml'};
    sourceClaims = cell2table(claims, 'VariableNames', ...
        {'Claim','Passed','Evidence'});
    assert(all(sourceClaims.Passed), 'Pinned-source translation gate failed.');
    jacobianRelativeError = zeros(model.nMovements, 1);
    spectralAbscissa = zeros(model.nMovements, 1);
    rng(41001, 'twister');
    directions = randn(model.n, 6);
    directions = directions ./ vecnorm(directions, 2, 1);
    epsilon = 1e-6;
    for target = 1:model.nMovements
        xstar = model.xstar(:, target);
        active = double(xstar > 0);
        analytic = (-eye(model.n) + ...
            (model.W + controller.effectiveFeedback) * diag(active)) / model.tau;
        finiteDifference = zeros(model.n, size(directions, 2));
        for index = 1:size(directions, 2)
            direction = directions(:, index);
            plus = vector_field(xstar + epsilon * direction, target, model, controller);
            minus = vector_field(xstar - epsilon * direction, target, model, controller);
            finiteDifference(:, index) = (plus - minus) / (2 * epsilon);
        end
        reference = analytic * directions;
        jacobianRelativeError(target) = norm(finiteDifference - reference, 'fro') ...
            / max(norm(reference, 'fro'), eps);
        spectralAbscissa(target) = max(real(eig(analytic)));
    end
    assert(max(jacobianRelativeError) < cfg.validation.jacobianRelativeTolerance);
    assert(max(controller.fixedPointResidualNorm) < cfg.validation.fixedPointTolerance);
    report.sourceClaims = sourceClaims;
    report.commit = commit;
    report.jacobianRelativeError = jacobianRelativeError;
    report.spectralAbscissaPerS = spectralAbscissa;
    report.maximumJacobianRelativeError = max(jacobianRelativeError);
    report.maximumFixedPointResidual = max(controller.fixedPointResidualNorm);
    report.careResidualRelative = controller.careResidualRelative;
    report.passed = true;
end

function derivative = vector_field(x, target, model, controller)
    rates = max(x, 0);
    targetRates = max(model.xstar(:, target), 0);
    derivative = (-x + model.W * rates + model.h ...
        + controller.targetInput(:, target) ...
        + controller.effectiveFeedback * rates) / model.tau;
    correction = controller.effectiveFeedback * targetRates;
    derivative = derivative - correction / model.tau + correction / model.tau;
end
