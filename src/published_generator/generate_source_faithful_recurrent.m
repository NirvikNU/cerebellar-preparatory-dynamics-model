function [W, diagnostics] = generate_source_faithful_recurrent(cfg, seed)
    rng(seed, 'twister');
    n = cfg.gate1.n;
    nE = cfg.gate1.nE;
    p = cfg.gate1.connectionProbability;
    kE = round(p * nE);
    w0 = cfg.gate1.initialSpectralRadius / sqrt(n * p * (1 - p));
    W = zeros(n);
    excitatoryIds = 1:nE;
    for row = 1:n
        selected = random_excitatory_ids(excitatoryIds, kE, row);
        W(row, selected) = exp(log(w0) + 0.5 * randn(1, kE));
        inhibitoryIds = (nE + 1):n;
        inhibitoryIds(inhibitoryIds == row) = [];
        W(row, inhibitoryIds) = -rand(1, numel(inhibitoryIds));
    end
    W = normalize_inhibition(W, cfg);
    iteration = 0;
    history = zeros(100000, 1);
    while true
        spectralAbscissa = max(real(eig(W)));
        iteration = iteration + 1;
        history(iteration) = spectralAbscissa;
        shift = max(1, 1.2 * spectralAbscissa);
        shifted = W - shift * eye(n);
        controllability = lyap(shifted, eye(n));
        observability = lyap(shifted.', eye(n));
        gradient = observability * controllability;
        eta = cfg.gate1.socLearningRate / trace(gradient);
        gradient(1:(n + 1):end) = 0;
        W(:, (nE + 1):end) = min(0, ...
            W(:, (nE + 1):end) - eta * gradient(:, (nE + 1):end));
        W = normalize_inhibition(W, cfg);
        if spectralAbscissa <= cfg.gate1.socStopSpectralAbscissa
            break
        end
        assert(iteration < 100000, 'SOC construction failed to converge.');
    end
    diagnostics = struct('seed', seed, 'iterations', iteration, ...
        'preUpdateFinalSpectralAbscissa', spectralAbscissa, ...
        'savedSpectralAbscissa', max(real(eig(W))), ...
        'history', history(1:iteration), ...
        'negativeExcitatoryCount', nnz(W(:, 1:nE) < 0), ...
        'positiveInhibitoryCount', nnz(W(:, (nE + 1):end) > 0), ...
        'nonzeroDiagonalCount', nnz(diag(W)));
end

function selected = random_excitatory_ids(ids, count, row)
    while true
        selected = ids(randperm(numel(ids), count));
        if row > numel(ids) || ~ismember(row, selected)
            return
        end
    end
end

function W = normalize_inhibition(W, cfg)
    n = cfg.gate1.n;
    nE = cfg.gate1.nE;
    nI = cfg.gate1.nI;
    denominator = nI * ones(n, 1);
    denominator((nE + 1):end) = nI - 1;
    correction = (cfg.gate1.dcEigenvalue - sum(W(:, 1:nE), 2) ...
        - sum(W(:, (nE + 1):end), 2)) ./ denominator;
    W(:, (nE + 1):end) = min(0, ...
        W(:, (nE + 1):end) + correction);
    W(1:(n + 1):end) = 0;
end
