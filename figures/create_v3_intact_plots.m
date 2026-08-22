function files = create_v3_intact_plots( ...
        canonical, delayEvaluation, history, params, run)
    root = fullfile(params.files.figureRoot, 'intact');
    files = {};
    files = [files, plot_hand_trajectories( ...
        canonical, params, run, root)];
    files = [files, plot_velocity_profiles( ...
        canonical, params, run, root)];
    files = [files, plot_prego_output( ...
        canonical, params, run, root)];
    files = [files, plot_cortical_activity( ...
        canonical, params, run, root)];
    files = [files, plot_cerebellar_activity( ...
        canonical, params, run, root)];
    files = [files, plot_output_across_delay( ...
        delayEvaluation, params, run, root)];
    files = [files, plot_training_diagnostics( ...
        history, run, root)];
end

function files = plot_hand_trajectories(evaluation, params, run, root)
    figureHandle = figure('Visible', run.plot.visible, 'Color', 'w');
    axesHandle = axes(figureHandle);
    hold(axesHandle, 'on');
    for target = 1:params.task.numTargets
        trial = find(evaluation.task.targetIndex == target, 1);
        position = squeeze(evaluation.simulation.position(:, trial, :));
        plot(axesHandle, 100 * position(1, :), 100 * position(2, :), ...
            'Color', run.plot.targetColors(target, :), ...
            'LineWidth', run.plot.lineWidth);
    end
    targets = 100 * double(evaluation.task.targetPositions);
    scatter(axesHandle, targets(1, :), targets(2, :), 55, ...
        run.plot.targetColors, 'filled');
    scatter(axesHandle, 0, 0, 45, 'k', 'filled');
    axis(axesHandle, 'equal');
    xlabel(axesHandle, 'x (cm)');
    ylabel(axesHandle, 'y (cm)');
    title(axesHandle, 'Deterministic intact V3 hand trajectories');
    style_axes(axesHandle, run);
    files = save_bundle(figureHandle, fullfile( ...
        root, 'behavior', 'hand_trajectories'), run);
end

function files = plot_velocity_profiles(evaluation, params, run, root)
    figureHandle = figure('Visible', run.plot.visible, 'Color', 'w');
    axesHandle = axes(figureHandle);
    hold(axesHandle, 'on');
    relativeTime = double(evaluation.task.timeMs) - ...
        params.task.canonicalGoTimeMs;
    for target = 1:params.task.numTargets
        trial = find(evaluation.task.targetIndex == target, 1);
        velocity = squeeze(evaluation.simulation.velocity(:, trial, :));
        speed = sqrt(sum(double(velocity).^2, 1));
        plot(axesHandle, relativeTime, speed, ...
            'Color', run.plot.targetColors(target, :), ...
            'LineWidth', run.plot.lineWidth);
    end
    xline(axesHandle, 0, 'k--');
    xlabel(axesHandle, 'Time from go (ms)');
    ylabel(axesHandle, 'Speed (m/s)');
    title(axesHandle, 'Velocity profiles');
    style_axes(axesHandle, run);
    files = save_bundle(figureHandle, fullfile( ...
        root, 'behavior', 'velocity_profiles'), run);
end

function files = plot_prego_output(evaluation, params, run, root)
    figureHandle = figure('Visible', run.plot.visible, 'Color', 'w');
    tiledlayout(figureHandle, 3, 1, 'TileSpacing', 'compact');
    relativeTime = double(evaluation.task.timeMs) - ...
        params.task.canonicalGoTimeMs;
    labels = {'v_x (m/s)', 'v_y (m/s)', 'Speed (m/s)'};
    for panel = 1:3
        axesHandle = nexttile;
        hold(axesHandle, 'on');
        for target = 1:params.task.numTargets
            trial = find(evaluation.task.targetIndex == target, 1);
            velocity = squeeze( ...
                evaluation.simulation.velocity(:, trial, :));
            if panel < 3
                values = double(velocity(panel, :));
            else
                values = sqrt(sum(double(velocity).^2, 1));
            end
            plot(axesHandle, relativeTime, values, ...
                'Color', run.plot.targetColors(target, :), ...
                'LineWidth', run.plot.lineWidth);
        end
        xline(axesHandle, 0, 'k--');
        xlim(axesHandle, [-params.task.canonicalGoTimeMs 100]);
        ylabel(axesHandle, labels{panel});
        style_axes(axesHandle, run);
    end
    xlabel(axesHandle, 'Time from go (ms)');
    sgtitle(figureHandle, 'Pre-go motor output and stationarity');
    files = save_bundle(figureHandle, fullfile( ...
        root, 'behavior', 'pre_go_stationarity'), run);
end

function files = plot_cortical_activity(evaluation, params, run, root)
    rates = double(evaluation.simulation.rates);
    relativeTime = double(evaluation.task.timeMs) - ...
        params.task.canonicalGoTimeMs;
    summaries = {squeeze(mean(rates, 1)), ...
        squeeze(max(rates, [], 1)), squeeze(mean(rates > 0, 1))};
    labels = {'Mean rate (Hz)', 'Maximum rate (Hz)', 'Active fraction'};
    figureHandle = figure('Visible', run.plot.visible, 'Color', 'w');
    tiledlayout(figureHandle, 3, 1, 'TileSpacing', 'compact');
    for panel = 1:3
        axesHandle = nexttile;
        hold(axesHandle, 'on');
        for target = 1:params.task.numTargets
            plot(axesHandle, relativeTime, summaries{panel}(target, :), ...
                'Color', run.plot.targetColors(target, :), ...
                'LineWidth', run.plot.lineWidth);
        end
        xline(axesHandle, 0, 'k--');
        ylabel(axesHandle, labels{panel});
        style_axes(axesHandle, run);
    end
    xlabel(axesHandle, 'Time from go (ms)');
    sgtitle(figureHandle, 'Cortical activity diagnostics');
    files = save_bundle(figureHandle, fullfile( ...
        root, 'cortical', 'cortical_activity'), run);
end

function files = plot_cerebellar_activity(evaluation, params, run, root)
    latent = double(evaluation.simulation.cerebellarLatent);
    relativeTime = double(evaluation.task.timeMs) - ...
        params.task.canonicalGoTimeMs;
    figureHandle = figure('Visible', run.plot.visible, 'Color', 'w');
    tiledlayout(figureHandle, params.model.cerebellarRank, 1, ...
        'TileSpacing', 'compact');
    for dimension = 1:params.model.cerebellarRank
        axesHandle = nexttile;
        hold(axesHandle, 'on');
        for target = 1:params.task.numTargets
            plot(axesHandle, relativeTime, ...
                squeeze(latent(dimension, target, :)), ...
                'Color', run.plot.targetColors(target, :), ...
                'LineWidth', run.plot.lineWidth);
        end
        xline(axesHandle, 0, 'k--');
        ylabel(axesHandle, sprintf('c_%d', dimension));
        style_axes(axesHandle, run);
    end
    xlabel(axesHandle, 'Time from go (ms)');
    sgtitle(figureHandle, 'Target-conditioned cerebellar latent');
    files = save_bundle(figureHandle, fullfile( ...
        root, 'cerebellar', 'cerebellar_activity'), run);
end

function files = plot_output_across_delay(evaluation, params, run, root)
    summary = evaluation.summary;
    figureHandle = figure('Visible', run.plot.visible, 'Color', 'w');
    tiledlayout(figureHandle, 2, 2, 'TileSpacing', 'compact');
    values = {1000 * summary.MeanEndpointErrorM, ...
        summary.MeanTerminalSpeedMPerSec, ...
        summary.PreGoRmsSpeedMPerSec, ...
        1000 * summary.MeanHoldErrorM};
    labels = {'Endpoint error (mm)', 'Terminal speed (m/s)', ...
        'Pre-go RMS speed (m/s)', 'Hold error (mm)'};
    for panel = 1:4
        axesHandle = nexttile;
        plot(axesHandle, summary.DelayMs, values{panel}, 'k-o', ...
            'LineWidth', run.plot.lineWidth, 'MarkerFaceColor', 'k');
        xlabel(axesHandle, 'Delay (ms)');
        ylabel(axesHandle, labels{panel});
        xlim(axesHandle, [params.task.minimumGoTimeMs, ...
            params.task.maximumGoTimeMs]);
        style_axes(axesHandle, run);
    end
    sgtitle(figureHandle, 'Intact output behavior across delay');
    files = save_bundle(figureHandle, fullfile( ...
        root, 'behavior', 'output_across_delay'), run);
end

function files = plot_training_diagnostics(history, run, root)
    iterations = 1:history.updatesCompleted;
    validationIterations = find(isfinite(history.validationLoss));
    figureHandle = figure('Visible', run.plot.visible, 'Color', 'w');
    tiledlayout(figureHandle, 2, 2, 'TileSpacing', 'compact');
    axesHandle = nexttile;
    plot(axesHandle, iterations, history.loss, 'k-', ...
        'LineWidth', run.plot.lineWidth);
    hold(axesHandle, 'on');
    plot(axesHandle, validationIterations, ...
        history.validationLoss(validationIterations), 'ro-', ...
        'LineWidth', 1);
    ylabel(axesHandle, 'Total loss');
    style_axes(axesHandle, run);
    axesHandle = nexttile;
    names = {'preGoVelocity', 'latePreGoVelocity', 'endpointUrgency', ...
        'terminalPosition', 'terminalVelocity', 'holdPosition', ...
        'holdVelocity'};
    hold(axesHandle, 'on');
    for index = 1:numel(names)
        plot(axesHandle, validationIterations, ...
            history.validationComponents.(names{index})( ...
            validationIterations), 'LineWidth', 1);
    end
    ylabel(axesHandle, 'Validation component');
    legend(axesHandle, names, 'Interpreter', 'none', ...
        'Location', 'best', 'Box', 'off');
    style_axes(axesHandle, run);
    axesHandle = nexttile;
    plot(axesHandle, iterations, history.learningRate, 'k-', ...
        'LineWidth', run.plot.lineWidth);
    ylabel(axesHandle, 'Learning rate');
    xlabel(axesHandle, 'Update');
    style_axes(axesHandle, run);
    axesHandle = nexttile;
    plot(axesHandle, iterations, history.gradientNorm, 'k-', ...
        'LineWidth', run.plot.lineWidth);
    ylabel(axesHandle, 'Gradient norm');
    xlabel(axesHandle, 'Update');
    style_axes(axesHandle, run);
    sgtitle(figureHandle, 'Deterministic V3 training diagnostics');
    files = save_bundle(figureHandle, fullfile( ...
        root, 'training', 'training_diagnostics'), run);
end

function style_axes(axesHandle, run)
    set(axesHandle, 'FontSize', run.plot.fontSize, 'TickDir', 'out', ...
        'XColor', 'k', 'YColor', 'k', 'LineWidth', 0.5);
    grid(axesHandle, 'off');
    box(axesHandle, 'off');
end

function files = save_bundle(figureHandle, basePath, run)
    outputDirectory = fileparts(basePath);
    if ~isfolder(outputDirectory)
        mkdir(outputDirectory);
    end
    figPath = [basePath '.fig'];
    pngPath = [basePath '.png'];
    savefig(figureHandle, figPath);
    exportgraphics(figureHandle, pngPath, ...
        'Resolution', run.plot.resolution, 'BackgroundColor', 'white');
    close(figureHandle);
    files = {figPath, pngPath};
end
