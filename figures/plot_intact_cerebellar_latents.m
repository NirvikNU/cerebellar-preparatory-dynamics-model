function figureFiles = plot_intact_cerebellar_latents( ...
        diagnostics, task, params)
    figureHandle = figure('Color', 'w', 'Visible', params.plot.visible, ...
        'Position', [100 100 900 1050]);
    layoutHandle = tiledlayout(figureHandle, 5, 1, ...
        'TileSpacing', 'compact', 'Padding', 'compact');
    displayMask = task.timeMs <= params.task.canonicalGoTimeMs + ...
        params.task.movementDurationMs;
    timeMs = double(task.timeMs(displayMask));
    targetHandles = gobjects(params.task.numTargets, 1);

    for latentIndex = 1:params.model.cerebellarRank
        axesHandle = nexttile(layoutHandle);
        hold(axesHandle, 'on');
        for targetIndex = 1:params.task.numTargets
            values = squeeze(diagnostics.meanLatent( ...
                latentIndex, targetIndex, displayMask));
            lineHandle = plot(axesHandle, timeMs, values, ...
                'Color', params.plot.targetColors(targetIndex, :), ...
                'LineWidth', params.plot.lineWidth);
            if latentIndex == 1
                targetHandles(targetIndex) = lineHandle;
            else
                set(lineHandle, 'HandleVisibility', 'off');
            end
        end
        xline(axesHandle, params.task.canonicalGoTimeMs, ':', ...
            'External go', 'Color', 'k', ...
            'LineWidth', params.plot.referenceLineWidth, ...
            'HandleVisibility', 'off');
        ylabel(axesHandle, sprintf('c_%d(t)', latentIndex));
        apply_plot_style(axesHandle, params);
        if latentIndex < params.model.cerebellarRank
            set(axesHandle, 'XTickLabel', []);
        else
            xlabel(axesHandle, 'Elapsed time from cue (ms)');
        end
    end
    title(layoutHandle, ['Intact feedforward cerebellar latents ', ...
        '(go marker is external reference only)']);
    legendHandle = legend(targetHandles, target_legend_labels(params), ...
        'Location', 'eastoutside');
    set(legendHandle, 'Box', 'off');
    figureFiles = save_figure_bundle(figureHandle, fullfile( ...
        params.files.figureRoot, 'cerebellar', ...
        'intact_cerebellar_latents'), params);
end
