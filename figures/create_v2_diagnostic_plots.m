function files = create_v2_diagnostic_plots( ...
        deterministic, noisy, delayRobustness, trainingHistory, params)
    files = {};
    files = [files, plot_reach_trajectories(deterministic, params)];
    files = [files, plot_speed_profiles(deterministic, params)];
    files = [files, plot_pre_go_output(deterministic, params)];
    files = [files, plot_delay_performance(delayRobustness, params)];
    files = [files, plot_cerebellar_latents(deterministic, params)];
    files = [files, plot_cortical_drives(deterministic, params)];
    files = [files, plot_cortical_pca(deterministic, params)];
    files = [files, plot_preparatory_geometry(deterministic, params)];
    files = [files, plot_training(trainingHistory, params)];
    if ~isempty(noisy) && ~noisy.diagnostics.metrics.finite
        warning('V2Model:NonfinitePlotInput', ...
            'Noisy evaluation contains nonfinite values.');
    end
end

function files = plot_reach_trajectories(evaluation, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    ax = axes(figureHandle); hold(ax, 'on');
    task = evaluation.task;
    for targetIndex = 1:params.task.numTargets
        trial = find(task.targetIndex == targetIndex, 1);
        position = 100 * squeeze(evaluation.simulation.position(:, trial, :));
        color = params.plot.targetColors(targetIndex, :);
        plot(ax, position(1, :), position(2, :), 'Color', color, ...
            'LineWidth', params.plot.lineWidth);
        plot(ax, 100 * task.targetPositions(1, targetIndex), ...
            100 * task.targetPositions(2, targetIndex), 'o', ...
            'Color', color, 'MarkerFaceColor', color, 'MarkerSize', 7);
    end
    plot(ax, 0, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6);
    axis(ax, 'equal'); xlabel(ax, 'Horizontal position (cm)');
    ylabel(ax, 'Vertical position (cm)');
    title(ax, 'Intact V2 reach trajectories');
    apply_plot_style(ax, params);
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'behavior', 'reach_trajectories'), params);
end

function files = plot_speed_profiles(evaluation, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    ax = axes(figureHandle); hold(ax, 'on');
    task = evaluation.task;
    speed = evaluation.diagnostics.speed;
    for targetIndex = 1:params.task.numTargets
        trial = find(task.targetIndex == targetIndex, 1);
        aligned = double(task.timeMs - task.goTimeMs(trial));
        plot(ax, aligned, speed(trial, :), 'Color', ...
            params.plot.targetColors(targetIndex, :), ...
            'LineWidth', params.plot.lineWidth);
    end
    xline(ax, 0, 'k--', 'Go');
    xline(ax, params.task.movementDurationMs, 'k:');
    xlabel(ax, 'Time from go (ms)'); ylabel(ax, 'Speed (m/s)');
    title(ax, 'Endpoint speed and hold');
    apply_plot_style(ax, params);
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'behavior', 'speed_profiles'), params);
end

function files = plot_pre_go_output(evaluation, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    layout = tiledlayout(figureHandle, 2, 1, 'TileSpacing', 'compact');
    task = evaluation.task;
    velocity = evaluation.simulation.velocity;
    speed = evaluation.diagnostics.speed;
    ax1 = nexttile(layout); hold(ax1, 'on');
    ax2 = nexttile(layout); hold(ax2, 'on');
    for targetIndex = 1:params.task.numTargets
        trial = find(task.targetIndex == targetIndex, 1);
        aligned = double(task.timeMs - task.goTimeMs(trial));
        color = params.plot.targetColors(targetIndex, :);
        plot(ax1, aligned, squeeze(velocity(1, trial, :)), ...
            'Color', color, 'LineWidth', params.plot.referenceLineWidth);
        plot(ax1, aligned, squeeze(velocity(2, trial, :)), ...
            '--', 'Color', color, 'LineWidth', params.plot.referenceLineWidth);
        plot(ax2, aligned, speed(trial, :), 'Color', color, ...
            'LineWidth', params.plot.referenceLineWidth);
    end
    xlim(ax1, [-params.plot.preGoDisplayMs 0]);
    xlim(ax2, [-params.plot.preGoDisplayMs 0]);
    ylabel(ax1, 'v_x, v_y (m/s)'); ylabel(ax2, 'Speed (m/s)');
    xlabel(ax2, 'Time from go (ms)');
    title(ax1, 'Pre-go motor output');
    apply_plot_style(ax1, params); apply_plot_style(ax2, params);
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'behavior', 'pre_go_motor_output'), params);
end

function files = plot_delay_performance(delay, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    layout = tiledlayout(figureHandle, 3, 1, 'TileSpacing', 'compact');
    names = {'meanEndpointErrorM', 'meanTerminalSpeedMPerSec', ...
        'preGoRmsSpeedMPerSec'};
    labels = {'Endpoint error (mm)', 'Terminal speed (m/s)', ...
        'Pre-go RMS speed (m/s)'};
    scales = [1000 1 1];
    for index = 1:3
        ax = nexttile(layout); hold(ax, 'on');
        plot(ax, delay.deterministic.delayMs, scales(index) * ...
            delay.deterministic.(names{index}), 'ko-', ...
            'LineWidth', params.plot.lineWidth, 'DisplayName', 'Deterministic');
        if isfield(delay, 'noisy') && ~isempty(delay.noisy)
            plot(ax, delay.noisy.delayMs, scales(index) * ...
                delay.noisy.(names{index}), 'o-', ...
                'Color', [0.4 0.4 0.4], ...
                'LineWidth', params.plot.lineWidth, ...
                'DisplayName', 'Noisy');
        end
        ylabel(ax, labels{index}); apply_plot_style(ax, params);
        if index == 1
            title(ax, 'Performance across instructed delay');
            legend(ax, 'Location', 'best', 'Box', 'off');
        end
    end
    xlabel(ax, 'Cue-to-go delay (ms)');
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'behavior', 'performance_across_delay'), params);
end

function files = plot_cerebellar_latents(evaluation, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    layout = tiledlayout(figureHandle, 5, 1, 'TileSpacing', 'compact');
    task = evaluation.task;
    latent = evaluation.simulation.cerebellarLatent;
    for dimension = 1:params.model.cerebellarRank
        ax = nexttile(layout); hold(ax, 'on');
        for targetIndex = 1:params.task.numTargets
            trial = find(task.targetIndex == targetIndex, 1);
            plot(ax, task.timeMs, squeeze(latent(dimension, trial, :)), ...
                'Color', params.plot.targetColors(targetIndex, :), ...
                'LineWidth', params.plot.referenceLineWidth);
        end
        xline(ax, task.goTimeMs(1), 'k--');
        ylabel(ax, sprintf('c_%d', dimension)); apply_plot_style(ax, params);
        if dimension == 1
            title(ax, 'Target-only cerebellar relaxation');
        end
    end
    xlabel(ax, 'Time from cue (ms)');
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'cerebellar', 'latent_dynamics'), params);
end

function files = plot_cortical_drives(evaluation, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    ax = axes(figureHandle); hold(ax, 'on');
    labels = {'Target', 'Go', 'Cerebellar', 'Recurrent'};
    colors = [0.85 0.2 0.2; 0.1 0.1 0.1; 0.1 0.45 0.85; 0.3 0.7 0.3];
    for index = 1:4
        values = squeeze(mean(evaluation.simulation.driveNorms(index, :, :), 2));
        plot(ax, evaluation.task.timeMs, values, 'Color', colors(index, :), ...
            'LineWidth', params.plot.lineWidth, 'DisplayName', labels{index});
    end
    xline(ax, evaluation.task.goTimeMs(1), 'k--', 'Go');
    xlabel(ax, 'Time from cue (ms)'); ylabel(ax, 'Cortical drive norm');
    title(ax, 'Cortical input-drive magnitudes');
    legend(ax, 'Location', 'best', 'Box', 'off'); apply_plot_style(ax, params);
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'cerebellar', 'cortical_drive_magnitudes'), params);
end

function files = plot_cortical_pca(evaluation, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    ax = axes(figureHandle); hold(ax, 'on'); view(ax, 3);
    scores = evaluation.diagnostics.population.pca.scores;
    task = evaluation.task;
    for targetIndex = 1:params.task.numTargets
        trial = find(task.targetIndex == targetIndex, 1);
        goIndex = task.goIndexByTrial(trial);
        endIndex = min(task.numTimeSteps, ...
            task.movementEndIndexByTrial(trial) + ...
            round(params.task.holdDurationMs / params.model.dtMs));
        color = params.plot.targetColors(targetIndex, :);
        plot3(ax, squeeze(scores(1, trial, 1:goIndex)), ...
            squeeze(scores(2, trial, 1:goIndex)), ...
            squeeze(scores(3, trial, 1:goIndex)), '--', 'Color', color, ...
            'LineWidth', params.plot.referenceLineWidth);
        plot3(ax, squeeze(scores(1, trial, goIndex:endIndex)), ...
            squeeze(scores(2, trial, goIndex:endIndex)), ...
            squeeze(scores(3, trial, goIndex:endIndex)), '-', 'Color', color, ...
            'LineWidth', params.plot.lineWidth);
        plot3(ax, scores(1, trial, goIndex), scores(2, trial, goIndex), ...
            scores(3, trial, goIndex), 'o', 'Color', color, ...
            'MarkerFaceColor', color);
    end
    xlabel(ax, 'PC1'); ylabel(ax, 'PC2'); zlabel(ax, 'PC3');
    title(ax, 'Cortical population PCA: dashed preparation, solid movement');
    apply_plot_style(ax, params);
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'cortical', 'population_pca'), params);
end

function files = plot_preparatory_geometry(evaluation, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    ax = axes(figureHandle); hold(ax, 'on');
    prep = evaluation.diagnostics.population.preparatory;
    plot(ax, evaluation.task.timeMs, prep.meanPairwiseSeparationHz, ...
        'k-', 'LineWidth', params.plot.lineWidth, ...
        'DisplayName', 'Target-centroid separation');
    plot(ax, evaluation.task.timeMs, prep.meanBaselineDistanceHz, ...
        '--', 'Color', [0.4 0.4 0.4], ...
        'LineWidth', params.plot.lineWidth, ...
        'DisplayName', 'Distance from common baseline');
    xline(ax, evaluation.task.goTimeMs(1), 'k:', 'Go');
    xlabel(ax, 'Time from cue (ms)'); ylabel(ax, 'RMS population distance (Hz)');
    title(ax, sprintf('Preparatory geometry; go separation %.3f Hz', ...
        prep.meanGoSeparationHz));
    legend(ax, 'Location', 'best', 'Box', 'off'); apply_plot_style(ax, params);
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'cortical', 'preparatory_state_geometry'), params);
end

function files = plot_training(history, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible);
    layout = tiledlayout(figureHandle, 2, 2, 'TileSpacing', 'compact');
    [loss, validation, rate, gradient, components, boundary] = ...
        combine_history(history);
    ax1 = nexttile(layout); hold(ax1, 'on');
    semilogy(ax1, loss, 'k-', 'LineWidth', params.plot.lineWidth);
    semilogy(ax1, validation, 'o', 'Color', [0.5 0.5 0.5], ...
        'MarkerSize', 3);
    if isfinite(boundary)
        xline(ax1, boundary, 'k:');
    end
    xlabel(ax1, 'Update'); ylabel(ax1, 'Loss'); title(ax1, 'Training and validation');
    apply_plot_style(ax1, params);
    ax2 = nexttile(layout); hold(ax2, 'on');
    componentNames = {'preGoVelocity', 'latePreGoVelocity', 'terminalPosition', ...
        'terminalVelocity', 'holdPosition', 'holdVelocity'};
    for index = 1:numel(componentNames)
        values = components.(componentNames{index});
        updates = find(isfinite(values));
        plot(ax2, updates, values(updates), 'o-', ...
            'LineWidth', params.plot.referenceLineWidth, ...
            'MarkerSize', 3, ...
            'DisplayName', componentNames{index});
    end
    xlabel(ax2, 'Update'); ylabel(ax2, 'Unweighted component');
    legend(ax2, 'Location', 'best', 'Box', 'off'); apply_plot_style(ax2, params);
    ax3 = nexttile(layout); semilogy(ax3, rate, 'k-', ...
        'LineWidth', params.plot.lineWidth); xlabel(ax3, 'Update');
    ylabel(ax3, 'Base learning rate'); apply_plot_style(ax3, params);
    ax4 = nexttile(layout); plot(ax4, gradient, 'k-', ...
        'LineWidth', params.plot.referenceLineWidth); xlabel(ax4, 'Update');
    ylabel(ax4, 'Pre-clip gradient norm'); apply_plot_style(ax4, params);
    files = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'training', 'training_diagnostics'), params);
end

function [loss, validation, rate, gradient, components, boundary] = ...
        combine_history(history)
    boundary = NaN;
    loss = history.stageA.loss;
    validation = history.stageA.validationLoss;
    rate = history.stageA.learningRate;
    gradient = history.stageA.gradientNorm;
    if isfield(history.stageA, 'refinementBoundaryIteration')
        boundary = history.stageA.refinementBoundaryIteration;
    end
    hasStageB = isfield(history, 'stageB') && ~isempty(history.stageB);
    if hasStageB
        boundary = numel(history.stageA.loss);
        loss = [loss; history.stageB.loss];
        validation = [validation; history.stageB.validationLoss];
        rate = [rate; history.stageB.learningRate];
        gradient = [gradient; history.stageB.gradientNorm];
    end
    names = fieldnames(history.stageA.trainingComponents);
    for index = 1:numel(names)
        name = names{index};
        components.(name) = history.stageA.trainingComponents.(name);
        if hasStageB
            components.(name) = [components.(name); ...
                history.stageB.trainingComponents.(name)];
        end
    end
end
