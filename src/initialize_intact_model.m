function learnables = initialize_intact_model(params)
    rng(params.seed.initialization, 'twister');

    numUnits = params.model.numCorticalUnits;
    targetInputSize = params.model.targetInputSize;
    latentRank = params.model.cerebellarRank;
    hiddenUnits = params.model.cerebellarHiddenUnits;
    generatorInputSize = params.model.cerebellarInputSize;

    learnables.Wrec = dlarray(single( ...
        params.model.recurrentInitializationGain * ...
        randn(numUnits, numUnits) / sqrt(numUnits)));
    learnables.Wtarg = dlarray(single( ...
        0.2 * randn(numUnits, targetInputSize) / sqrt(targetInputSize)));
    learnables.Wgo = dlarray(single(0.2 * randn(numUnits, 1)));
    learnables.Ucb = dlarray(single( ...
        0.2 * randn(numUnits, latentRank) / sqrt(latentRank)));
    learnables.WcbHidden = dlarray(single( ...
        randn(hiddenUnits, generatorInputSize) / sqrt(generatorInputSize)));
    learnables.bcbHidden = dlarray(zeros(hiddenUnits, 1, 'single'));
    learnables.WcbLatent = dlarray(single( ...
        randn(latentRank, hiddenUnits) / sqrt(hiddenUnits)));
    learnables.bcbLatent = dlarray(zeros(latentRank, 1, 'single'));
    learnables.Wout = dlarray(single( ...
        0.02 * randn(2, numUnits) / sqrt(numUnits)));
end
