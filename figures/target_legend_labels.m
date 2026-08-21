function labels = target_legend_labels(params)
    labels = arrayfun(@(targetIndex) sprintf('Target %d', targetIndex), ...
        1:params.task.numTargets, 'UniformOutput', false);
end
