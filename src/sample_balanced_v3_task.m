function task = sample_balanced_v3_task(params, trialsPerTarget, stream)
    targets = repelem(1:params.task.numTargets, trialsPerTarget);
    targets = targets(randperm(stream, numel(targets)));
    allowed = params.task.delayGridMs;
    goTimes = allowed(randi(stream, numel(allowed), 1, numel(targets)));
    task = build_v3_task(params, trialsPerTarget, goTimes, targets);
end
