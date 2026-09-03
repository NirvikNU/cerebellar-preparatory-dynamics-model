function report = run_stage1_smoke_tests(cfg, model, nativeSegment)
    if nargin < 3
        nativeRates = readmatrix(fullfile(cfg.dataRoot, ...
            'native_cortical_r1_1.tsv'), 'FileType', 'text');
        nativeSegment = nativeRates(1:5, :);
    end
    assert(strcmp(model.metadata.upstream_commit, cfg.upstreamCommit));
    assert(model.n == 200 && model.nE == 160 && model.nI == 40);
    assert(model.dt == 2e-4 && model.samplingDt == 1e-3 && model.tau == 0.15);
    assert(all(model.W(:, 1:model.nE) >= 0, 'all'));
    assert(all(model.W(:, (model.nE + 1):end) <= 0, 'all'));
    assert(all(diag(model.W) == 0));
    assert(rank(model.C) == 2);
    assert(size(model.xstar, 2) == 8);
    shortModel = model;
    shortModel.nInternalSteps = 25;
    shortModel.nSamples = 5;
    segment = simulate_published_cortex(shortModel, model.xstar(:, 1), true);
    assert(all(isfinite(segment.rates), 'all') && all(isfinite(segment.torque), 'all'));
    assert(isequal(size(nativeSegment), [5, model.n]));
    segmentDifference = max(abs(segment.rates(:) - nativeSegment(:)));
    assert(segmentDifference < 1e-6);
    qResidual = model.A.' * model.Qnative + model.Qnative * model.A + model.C.' * model.C;
    relativeResidual = norm(qResidual, 'fro') / norm(model.C.' * model.C, 'fro');
    assert(relativeResidual <= cfg.equivalence.lyapunovRelativeTolerance);
    report = struct('passed', true, 'shortSegmentMaxAbs', ...
        segmentDifference, ...
        'qRelativeResidual', relativeResidual);
end
