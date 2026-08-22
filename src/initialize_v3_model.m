function model = initialize_v3_model(params, fixed)
    rng(params.seed.initialization, 'twister');
    n = params.model.numCorticalUnits;
    nTargets = params.model.targetInputSize;
    hidden = params.model.cerebellarHiddenUnits;
    rankValue = params.model.cerebellarRank;
    init = params.initialization;
    model.Wtarg = dlarray(single(init.targetScale * ...
        randn(n, nTargets) / sqrt(nTargets)));
    model.Wgo = dlarray(single(init.goScale * randn(n, 1)));
    model.WcbHidden = dlarray(single(init.cerebellarHiddenScale * ...
        randn(hidden, nTargets) / sqrt(nTargets)));
    model.bcbHidden = dlarray(zeros(hidden, 1, 'single'));
    model.WcbLatent = dlarray(single(init.cerebellarLatentScale * ...
        randn(rankValue, hidden) / sqrt(hidden)));
    model.bcbLatent = dlarray(zeros(rankValue, 1, 'single'));
    model.Ucb = dlarray(single(init.cerebellarProjectionScale * ...
        randn(n, rankValue) / sqrt(rankValue)));
    model.Wout = dlarray(single(init.readoutScale * ...
        randn(2, n) / sqrt(n)));
    model.Wrec = dlarray(fixed.Wrec);
    model.baselineRates = dlarray(fixed.baselineRates);
    model.baselineDrive = dlarray(fixed.baselineDrive);
end
