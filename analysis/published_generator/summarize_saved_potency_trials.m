function diagnostics = summarize_saved_potency_trials(csvPath)
    trials = readtable(csvPath);
    trials.Band = string(trials.Band);
    bands = ["high", "intermediate", "low"];
    summary = table('Size', [3, 5], ...
        'VariableTypes', {'string','double','double','double','double'}, ...
        'VariableNames', {'Band','N','Minimum','Median','Maximum'});
    for index = 1:numel(bands)
        values = trials.NonlinearMotorError(trials.Band == bands(index));
        summary(index, :) = {bands(index), numel(values), min(values), ...
            median(values), max(values)};
    end
    high = trials.NonlinearMotorError(trials.Band == "high");
    intermediate = trials.NonlinearMotorError(trials.Band == "intermediate");
    low = trials.NonlinearMotorError(trials.Band == "low");
    targetSpearman = zeros(8, 1);
    for movement = 1:8
        subset = trials.Movement == movement;
        targetSpearman(movement) = corr(trials.PredictedCost(subset), ...
            trials.NonlinearMotorError(subset), 'Type', 'Spearman');
    end
    [groups, ranks] = findgroups(trials.EigenRank);
    predictedMedian = splitapply(@median, trials.PredictedCost, groups);
    actualMedian = splitapply(@median, trials.NonlinearMotorError, groups);
    diagnostics = struct('bandSummary', summary, ...
        'highGreaterThanLowFraction', pairwise_fraction(high, low), ...
        'highGreaterThanIntermediateFraction', pairwise_fraction(high, intermediate), ...
        'intermediateGreaterThanLowFraction', pairwise_fraction(intermediate, low), ...
        'targetSpearman', targetSpearman, 'directionRanks', ranks, ...
        'directionMedianSpearman', corr(predictedMedian, actualMedian, 'Type', 'Spearman'));
end

function fraction = pairwise_fraction(first, second)
    fraction = mean(first(:) > second(:).', 'all');
end
