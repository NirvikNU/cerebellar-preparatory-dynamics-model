function output = analyze_stage2b_midprep_perturbations(cfg, model, controllers, preparations)
    rng(65001, 'twister');
    nDirections = 8;
    nRows = numel(controllers) * numel(cfg.analysis.perturbationTimesS) ...
        * model.nMovements * nDirections;
    controllerName = strings(nRows, 1);
    perturbationTime = zeros(nRows, 1);
    target = zeros(nRows, 1);
    directionIndex = zeros(nRows, 1);
    finalFraction = zeros(nRows, 1);
    recovery = zeros(nRows, 1);
    Q = controllers{1}.Q;
    finalSample = round(0.500 / model.samplingDt) + 1;
    row = 0;
    for timeIndex = 1:numel(cfg.analysis.perturbationTimesS)
        time = cfg.analysis.perturbationTimesS(timeIndex);
        for movement = 1:model.nMovements
            directions = randn(model.n, nDirections);
            directions = directions ./ vecnorm(directions, 2, 1);
            perturbations = cfg.analysis.perturbationNorm * directions;
            initial = repmat(model.spontaneous, 1, nDirections);
            indices = movement * ones(1, nDirections);
            initialQ = sum(perturbations.' * Q .* perturbations.', 2);
            for controllerIndex = 1:numel(controllers)
                simulation = simulate_stage2b_preparation(model, ...
                    controllers{controllerIndex}, 0.500, InitialStates=initial, ...
                    TargetIndex=indices, PerturbationTimeS=time, ...
                    Perturbations=reshape(perturbations, model.n, nDirections, 1), ...
                    StoreControl=false);
                matchedFinal = squeeze(preparations{controllerIndex}.states(...
                    finalSample, :, movement)).';
                inducedFinal = simulation.finalState - matchedFinal;
                finalQ = sum(inducedFinal.' * Q .* inducedFinal.', 2);
                for direction = 1:nDirections
                    row = row + 1;
                    controllerName(row) = controllers{controllerIndex}.name;
                    perturbationTime(row) = time;
                    target(row) = movement;
                    directionIndex(row) = direction;
                    finalFraction(row) = finalQ(direction) / max(initialQ(direction), eps);
                    recovery(row) = 1 - finalFraction(row);
                end
            end
        end
    end
    output = table(controllerName, perturbationTime, target, directionIndex, ...
        finalFraction, recovery, 'VariableNames', {'Controller', ...
        'PerturbationTimeS','Target','Direction','FinalProspectiveFraction', ...
        'RecoveryFraction'});
end
