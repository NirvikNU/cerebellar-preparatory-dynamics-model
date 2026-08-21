function files = create_hennequin_positive_control_plot( ...
        result, fixed, params)
    task = build_isn_reach_task(params, 1, ...
        params.task.canonicalGoTimeMs, []);
    simulation = simulate_hennequin_positive_control( ...
        result.parameters, fixed, task, params);
    outputRoot = params.files.positiveControlFigureRoot;

    trajectoryFigure = figure('Color', 'w', 'Visible', params.plot.visible);
    ax = axes(trajectoryFigure); hold(ax, 'on');
    for targetIndex = 1:params.task.numTargets
        position = 100 * squeeze(simulation.position(:, targetIndex, :));
        color = params.plot.targetColors(targetIndex, :);
        plot(ax, position(1, :), position(2, :), 'Color', color, ...
            'LineWidth', params.plot.lineWidth);
        plot(ax, 100 * task.targetPositions(1, targetIndex), ...
            100 * task.targetPositions(2, targetIndex), 'o', ...
            'Color', color, 'MarkerFaceColor', color);
    end
    axis(ax, 'equal'); xlabel(ax, 'Horizontal position (cm)');
    ylabel(ax, 'Vertical position (cm)');
    title(ax, 'Hennequin-backbone positive control');
    apply_plot_style(ax, params);
    files = save_figure_bundle(trajectoryFigure, ...
        fullfile(outputRoot, 'reach_trajectories'), params);

    historyFigure = figure('Color', 'w', 'Visible', params.plot.visible);
    ax = axes(historyFigure);
    semilogy(ax, result.history.loss, 'k-', ...
        'LineWidth', params.plot.lineWidth);
    xlabel(ax, 'Update'); ylabel(ax, 'Training loss');
    title(ax, 'Positive-control optimization');
    apply_plot_style(ax, params);
    files = [files, save_figure_bundle(historyFigure, ...
        fullfile(outputRoot, 'training_history'), params)];
end
