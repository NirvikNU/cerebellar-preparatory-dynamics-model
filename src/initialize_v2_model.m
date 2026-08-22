function model = initialize_v2_model(params, fixed)
    rng(params.seed.initialization, 'twister');
    n = params.model.numCorticalUnits;
    h = params.model.cerebellarHiddenUnits;
    k = params.model.cerebellarRank;
    model.Wtarg = dlarray(single(0.05 * randn(n, 8) / sqrt(8)));
    model.Wgo = dlarray(single(0.05 * randn(n, 1)));
    model.Ucb = dlarray(single(0.05 * randn(n, k) / sqrt(k)));
    model.WcbHidden = dlarray(single(randn(h, 8) / sqrt(8)));
    model.bcbHidden = dlarray(zeros(h, 1, 'single'));
    model.WcbLatent = dlarray(single(0.1 * randn(k, h) / sqrt(h)));
    model.bcbLatent = dlarray(zeros(k, 1, 'single'));
    model.Wout = dlarray(single(1e-4 * randn(2, n) / sqrt(n)));
    model.Wrec = dlarray(fixed.Wrec);
    model.baselineRates = dlarray(fixed.baselineRates);
    model.baselineDrive = dlarray(fixed.baselineDrive);
end
