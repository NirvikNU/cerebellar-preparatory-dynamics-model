function report = validate_stage2a_conditional_components(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    end
    addpath(fullfile(projectRoot, 'config'));
    addpath(fullfile(projectRoot, 'src', 'stage_2a'));
    addpath(fullfile(projectRoot, 'analysis', 'published_generator'));
    cfg = stage_2a_config(projectRoot);
    saved = load(fullfile(cfg.ensemble.stage1Root, 'network_01.mat'), 'model');
    model = saved.model;
    target = 2;
    [tonicInput, residual] = compute_tonic_input(model);
    xstar = model.xstar(:, target);
    active = double(xstar > 0);
    jacobian = (-eye(model.n) + model.W .* active.') / model.tau;
    nonzero = abs(xstar(abs(xstar) > 0));
    epsilon = min(1e-6, 0.1 * min(nonzero));
    previous = rng;
    cleanup = onCleanup(@() rng(previous));
    rng(2026083121, 'twister');
    errors = zeros(5, 1);
    for directionIndex = 1:numel(errors)
        direction = randn(model.n, 1);
        direction = direction / norm(direction);
        plus = preparation_derivative(model, tonicInput(:, target), ...
            xstar + epsilon * direction);
        minus = preparation_derivative(model, tonicInput(:, target), ...
            xstar - epsilon * direction);
        finiteDifference = (plus - minus) / (2 * epsilon);
        analytic = jacobian * direction;
        errors(directionIndex) = norm(finiteDifference - analytic) ...
            / max(norm(finiteDifference), eps);
    end
    q = (model.Qnative + model.Qnative.') / 2;
    [vectors, values] = eig(q, 'vector');
    [values, order] = sort(real(values), 'descend');
    vectors = real(vectors(:, order));
    qTolerance = 1e-10 * max(max(abs(values)), 1);
    assert(min(values) >= -qTolerance);
    values = max(values, 0);
    k95 = find(cumsum(values) / sum(values) ...
        >= cfg.conditional.potencyFraction, 1, 'first');
    qReconstructionError = norm(q - vectors * diag(values) * vectors.', ...
        'fro') / norm(q, 'fro');
    assert(max(errors) <= 1e-7);
    assert(qReconstructionError <= 1e-10);
    assert(max(vecnorm(residual, 2, 1)) ...
        <= cfg.acceptance.fixedPointResidualTolerance);
    report = struct('network', 1, 'target', target, ...
        'activeUnits', sum(active), 'finiteDifferenceStep', epsilon, ...
        'maximumJacobianDirectionalError', max(errors), ...
        'minimumQEigenvalue', min(values), 'k95', k95, ...
        'qReconstructionRelativeError', qReconstructionError, ...
        'maximumFixedPointResidual', max(vecnorm(residual, 2, 1)), ...
        'passed', true);
    if ~isfolder(cfg.workAuditRoot)
        mkdir(cfg.workAuditRoot);
    end
    write_json(fullfile(cfg.workAuditRoot, ...
        'stage2a_conditional_component_validation.json'), report);
end

function derivative = preparation_derivative(model, input, state)
    derivative = (-state + model.W * max(state, 0) + model.h + input) ...
        / model.tau;
end

function write_json(path, value)
    fid = fopen(path, 'w');
    assert(fid ~= -1);
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '%s', jsonencode(value, PrettyPrint=true));
end
