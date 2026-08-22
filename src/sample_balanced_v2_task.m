function task = sample_balanced_v2_task(params, trialsPerTarget, stream)
    targets = repelem(1:params.task.numTargets, trialsPerTarget);
    targets = targets(randperm(stream, numel(targets)));
    allowed = params.task.minimumGoTimeMs:params.model.dtMs: ...
        params.task.maximumGoTimeMs;
    goTimes = allowed(randi(stream, numel(allowed), 1, numel(targets)));
    task = build_v2_task(params, trialsPerTarget, goTimes, targets);
end
