function files = create_isn_diagnostic_plots( ...
        diagnostics, deterministicDelay, noisyDelay, task, params)
    files = {};
    files = [files, reach_plot(diagnostics, task, params)];
    files = [files, speed_plot(diagnostics, params)];
    files = [files, delay_plot(deterministicDelay, noisyDelay, ...
        'meanEndpointErrorM', 'Endpoint error (m)', ...
        'endpoint_error_vs_delay', params)];
    files = [files, prego_delay_plot(deterministicDelay, noisyDelay, params)];
    files = [files, delay_plot(deterministicDelay, noisyDelay, ...
        'meanTerminalSpeedMPerSec', 'Terminal speed (m/s)', ...
        'terminal_speed_vs_delay', params)];
    files = [files, joint_plot(diagnostics, params)];
    files = [files, torque_plot(diagnostics, params)];
    files = [files, contact_plot(diagnostics, params)];
    files = [files, state_plot(diagnostics.pca.trajectories, ...
        'Whole-trial M1 PCA', 'whole_trial_m1_pca', params)];
    files = [files, state_plot(diagnostics.movementPca.trajectories, ...
        'Movement-only M1 PCA', 'movement_only_m1_pca', params)];
    files = [files, jpca_plot(diagnostics, params)];
    files = [files, latent_plot(diagnostics, task, params)];
    files = [files, settling_plot(diagnostics, task, params)];
    files = [files, cb_drive_plot(diagnostics, task, params)];
    files = [files, all_drive_plot(diagnostics, task, params)];
end

function files = reach_plot(d, task, p)
    f = new_figure(p); ax = axes(f); hold(ax, 'on');
    for target = 1:p.task.numTargets
        xy = 100 * squeeze(d.meanPosition(:, target, :));
        plot(ax, xy(1, :), xy(2, :), 'Color', p.plot.targetColors(target, :), ...
            'LineWidth', p.plot.lineWidth);
        plot(ax, 100 * task.targetPositions(1, target), ...
            100 * task.targetPositions(2, target), 'o', ...
            'Color', p.plot.targetColors(target, :), 'MarkerFaceColor', ...
            p.plot.targetColors(target, :));
    end
    axis(ax, 'equal'); xlabel(ax, 'Horizontal position (cm)');
    ylabel(ax, 'Vertical position (cm)'); title(ax, 'Eight intact reaches');
    style(ax, p); files = save_at(f, 'behavior', 'reach_trajectories', p);
end

function files = speed_plot(d, p)
    f = new_figure(p); ax = axes(f); hold(ax, 'on');
    mask = d.timeRelativeToGoMs >= -p.plot.preGoDisplayMs;
    for target = 1:p.task.numTargets
        plot(ax, d.timeRelativeToGoMs(mask), d.meanSpeed(target, mask), ...
            'Color', p.plot.targetColors(target, :), 'LineWidth', p.plot.lineWidth);
    end
    xline(ax, 0, 'k:'); xlabel(ax, 'Time relative to go (ms)');
    ylabel(ax, 'Endpoint speed (m/s)'); title(ax, 'Endpoint speed');
    style(ax, p); files = save_at(f, 'behavior', 'endpoint_speed', p);
end

function files = delay_plot(a, b, field, yLabel, name, p)
    f = new_figure(p); ax = axes(f); hold(ax, 'on');
    plot(ax, a.delayValuesMs, a.(field), 'ks--', 'LineWidth', p.plot.lineWidth, ...
        'DisplayName', 'Deterministic');
    plot(ax, b.delayValuesMs, b.(field), 'bo-', 'LineWidth', p.plot.lineWidth, ...
        'DisplayName', 'Noisy');
    xlabel(ax, 'Cue-to-go delay (ms)'); ylabel(ax, yLabel);
    legend(ax, 'Location', 'best', 'Box', 'off'); style(ax, p);
    files = save_at(f, 'behavior', name, p);
end

function files = prego_delay_plot(a, b, p)
    f = new_figure(p); layout = tiledlayout(f, 2, 1, ...
        'TileSpacing', 'compact', 'Padding', 'compact');
    fields = {'preGoRmsEndpointSpeedMPerSec', ...
        'preGoRmsEndpointDisplacementM'};
    labels = {'Pre-go RMS speed (m/s)', 'Pre-go RMS displacement (m)'};
    for index = 1:2
        ax = nexttile(layout); hold(ax, 'on');
        plot(ax, a.delayValuesMs, a.(fields{index}), 'ks--', ...
            'LineWidth', p.plot.lineWidth);
        plot(ax, b.delayValuesMs, b.(fields{index}), 'bo-', ...
            'LineWidth', p.plot.lineWidth);
        ylabel(ax, labels{index}); style(ax, p);
    end
    xlabel(nexttile(layout, 2), 'Cue-to-go delay (ms)');
    files = save_at(f, 'behavior', 'prego_vs_delay', p);
end

function files = joint_plot(d, p)
    f = new_figure(p); layout = tiledlayout(f, 2, 1, ...
        'TileSpacing', 'compact', 'Padding', 'compact');
    for joint = 1:2
        ax = nexttile(layout); hold(ax, 'on');
        for target = 1:p.task.numTargets
            plot(ax, d.timeRelativeToGoMs, rad2deg(squeeze( ...
                d.meanJointAngles(joint, target, :))), ...
                'Color', p.plot.targetColors(target, :), ...
                'LineWidth', p.plot.lineWidth);
        end
        ylabel(ax, sprintf('Joint %d angle (deg)', joint)); style(ax, p);
    end
    xlabel(nexttile(layout, 2), 'Time relative to go (ms)');
    files = save_at(f, 'plant', 'joint_angles', p);
end

function files = torque_plot(d, p)
    f = new_figure(p); layout = tiledlayout(f, 2, 1, ...
        'TileSpacing', 'compact', 'Padding', 'compact');
    for joint = 1:2
        ax = nexttile(layout); hold(ax, 'on');
        for target = 1:p.task.numTargets
            plot(ax, d.timeRelativeToGoMs, squeeze( ...
                d.meanAppliedTorque(joint, target, :)), ...
                'Color', p.plot.targetColors(target, :), ...
                'LineWidth', p.plot.lineWidth);
        end
        ylabel(ax, sprintf('Joint %d torque (N m)', joint)); style(ax, p);
    end
    xlabel(nexttile(layout, 2), 'Time relative to go (ms)');
    files = save_at(f, 'plant', 'joint_torques', p);
end

function files = contact_plot(d, p)
    f = new_figure(p); ax = axes(f);
    bar(ax, [d.metrics.hardJointLimitContactFraction, ...
        d.metrics.hardTorqueSaturationFraction]);
    set(ax, 'XTickLabel', {'Joint limit', 'Torque saturation'});
    ylabel(ax, 'Contact fraction'); title(ax, 'Safety-contact statistics');
    style(ax, p); files = save_at(f, 'plant', 'contact_statistics', p);
end

function files = state_plot(trajectories, titleText, name, p)
    f = new_figure(p); ax = axes(f); hold(ax, 'on');
    for target = 1:p.task.numTargets
        x = trajectories(:, 1:3, target);
        plot3(ax, x(:, 1), x(:, 2), x(:, 3), ...
            'Color', p.plot.targetColors(target, :), ...
            'LineWidth', p.plot.lineWidth);
    end
    xlabel(ax, 'PC1'); ylabel(ax, 'PC2'); zlabel(ax, 'PC3');
    title(ax, titleText); view(ax, 35, 25); style(ax, p);
    files = save_at(f, 'cortex', name, p);
end

function files = jpca_plot(d, p)
    f = new_figure(p); ax = axes(f); hold(ax, 'on');
    for target = 1:p.task.numTargets
        x = d.jpca.trajectories(:, :, target);
        plot(ax, x(:, 1), x(:, 2), 'Color', p.plot.targetColors(target, :), ...
            'LineWidth', p.plot.lineWidth);
    end
    axis(ax, 'equal'); xlabel(ax, 'jPC1'); ylabel(ax, 'jPC2');
    title(ax, sprintf('jPCA diagnostic, R^2 %.3f', d.jpca.rotationalFitR2));
    style(ax, p); files = save_at(f, 'cortex', 'jpca_diagnostic', p);
end

function files = latent_plot(d, task, p)
    f = new_figure(p); layout = tiledlayout(f, 5, 1, ...
        'TileSpacing', 'compact', 'Padding', 'compact');
    for latent = 1:5
        ax = nexttile(layout); hold(ax, 'on');
        for target = 1:p.task.numTargets
            plot(ax, task.timeMs, squeeze(d.meanCerebellarLatent( ...
                latent, target, :)), 'Color', p.plot.targetColors(target, :), ...
                'LineWidth', p.plot.lineWidth);
        end
        ylabel(ax, sprintf('c_%d', latent)); style(ax, p);
    end
    files = save_at(f, 'cerebellum', 'latent_traces', p);
end

function files = settling_plot(d, task, p)
    f = new_figure(p); ax = axes(f); hold(ax, 'on');
    for target = 1:p.task.numTargets
        latent = squeeze(double(d.meanCerebellarLatent(:, target, :)));
        derivative = [nan, vecnorm(diff(latent, 1, 2) / ...
            (p.model.dtMs / 1000), 2, 1)];
        plot(ax, task.timeMs, derivative, 'Color', ...
            p.plot.targetColors(target, :), 'LineWidth', p.plot.lineWidth);
    end
    xlabel(ax, 'Elapsed cue time (ms)'); ylabel(ax, '||dc/dt|| (s^{-1})');
    title(ax, 'Cerebellar settling'); style(ax, p);
    files = save_at(f, 'cerebellum', 'settling_diagnostic', p);
end

function files = cb_drive_plot(d, task, p)
    f = new_figure(p); ax = axes(f); hold(ax, 'on');
    for target = 1:p.task.numTargets
        plot(ax, task.timeMs, squeeze(d.meanDriveNorms(3, target, :)), ...
            'Color', p.plot.targetColors(target, :), ...
            'LineWidth', p.plot.lineWidth);
    end
    xlabel(ax, 'Elapsed cue time (ms)'); ylabel(ax, '||U_{cb}c(t)||');
    title(ax, 'Cerebellar cortical drive'); style(ax, p);
    files = save_at(f, 'cerebellum', 'cortical_drive_norm', p);
end

function files = all_drive_plot(d, task, p)
    f = new_figure(p); ax = axes(f); hold(ax, 'on');
    labels = {'Target', 'Go', 'Cerebellar', 'Recurrent'};
    for drive = 1:4
        plot(ax, task.timeMs, squeeze(mean(d.meanDriveNorms(drive, :, :), 2)), ...
            'LineWidth', p.plot.lineWidth, 'DisplayName', labels{drive});
    end
    xlabel(ax, 'Elapsed cue time (ms)'); ylabel(ax, 'Mean drive norm');
    legend(ax, 'Location', 'best', 'Box', 'off'); style(ax, p);
    files = save_at(f, 'cerebellum', 'cortical_drive_magnitudes', p);
end

function f = new_figure(p)
    f = figure('Color', 'w', 'Visible', p.plot.visible);
end

function style(ax, p)
    apply_plot_style(ax, p);
end

function files = save_at(f, group, name, p)
    files = save_figure_bundle(f, fullfile(p.files.figureRoot, group, name), p);
end
