function inventory = create_stage2b_alignment_replication_figures( ...
        cfgKao, cfgCerebellum, replication)
%CREATE_STAGE2B_ALIGNMENT_REPLICATION_FIGURES Replace canonical Figure 9.

    configurations = {cfgKao, cfgCerebellum};
    controllerNames = ["Stage 2B-Kao", "Stage 2B-Cerebellum"];
    inventoryRows = cell(2, 4);
    figureName = '09_stage2b_prep_move_alignment_and_null_distribution';
    for stageIndex = 1:2
        controllerName = controllerNames(stageIndex);
        rows = replication.audit.Controller == controllerName;
        audit = replication.audit(rows, :);
        handle = build_figure(controllerName, audit, replication);
        [figFile, pngFile] = save_figure_bundle(handle, figureName, ...
            configurations{stageIndex});
        inventoryRows(stageIndex, :) = {controllerName, 9, ...
            string(pngFile), string(figFile)};
    end
    inventory = cell2table(inventoryRows, 'VariableNames', ...
        {'Stage','FigureIndex','PngFile','FigFile'});
end

function handle = build_figure(controllerName, audit, replication)
    handle = figure('Color', 'w', 'Visible', 'off', ...
        'Units', 'pixels', 'Position', [80, 80, 2048, 1220]);
    layout = tiledlayout(handle, 2, 2, 'TileSpacing', 'compact', ...
        'Padding', 'compact');
    colors = [0.20, 0.47, 0.72; 0.84, 0.37, 0.16];
    if height(audit) == 1
        colors = colors(2, :);
    end

    ax = nexttile(layout, 1); hold(ax, 'on');
    for row = 1:height(audit)
        spectrumRows = replication.spectrum.Controller == controllerName & ...
            replication.spectrum.Analysis == audit.Analysis(row);
        spectrum = replication.spectrum(spectrumRows, :);
        plot(ax, spectrum.Component, spectrum.PrepCumulativeVariance, ...
            'LineWidth', 1.8, 'Color', colors(row, :));
        xline(ax, audit.K(row), ':', sprintf('K=%d', audit.K(row)), ...
            'Color', colors(row, :), 'LineWidth', 1.1, ...
            'LabelVerticalAlignment', 'middle');
    end
    yline(ax, 0.80, ':', '80%', 'Color', [0.45, 0.45, 0.45]);
    yline(ax, 0.95, '--', '95%', 'Color', [0.20, 0.20, 0.20]);
    xlim(ax, [0, 25]); ylim(ax, [0, 1.02]);
    xlabel(ax, 'Preparatory PC'); ylabel(ax, 'Cumulative variance');
    title(ax, 'A  Controller-specific dimensionality');
    legend(ax, threshold_labels(audit), 'Location', 'southeast');
    style_axes(ax);

    ax = nexttile(layout, 2); hold(ax, 'on');
    x = (1:height(audit)).';
    nullHandle = errorbar(ax, x, audit.NullMedian, ...
        audit.BootstrapSDOfNullMedians, 'o', 'Color', [0.35, 0.35, 0.35], ...
        'MarkerFaceColor', [0.72, 0.72, 0.72], 'LineWidth', 1.3, ...
        'CapSize', 12);
    observedHandle = scatter(ax, x, audit.ObservedAlignment, 80, colors, ...
        'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
    for row = 1:height(audit)
        text(ax, x(row), max(audit.ObservedAlignment(row) - 0.055, 0.015), ...
            sprintf('p=%.4g', audit.EmpiricalLowerTailP(row)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
    end
    set(ax, 'XTick', x, 'XTickLabel', threshold_labels(audit));
    ylabel(ax, 'Alignment index'); ylim(ax, [0, 1]);
    title(ax, 'B  Observed versus covariance-constrained null');
    legend(ax, [observedHandle, nullHandle], ...
        {'Observed', 'Null median \pm bootstrap SD of medians'}, ...
        'Location', 'northwest');
    style_axes(ax);

    ax = nexttile(layout, 3); hold(ax, 'on');
    for row = 1:height(audit)
        nullRows = replication.null.Controller == controllerName & ...
            replication.null.Analysis == audit.Analysis(row);
        values = replication.null.AlignmentIndex(nullRows);
        histogram(ax, values, 45, 'Normalization', 'pdf', ...
            'DisplayStyle', 'stairs', 'LineWidth', 1.5, ...
            'EdgeColor', colors(row, :));
        xline(ax, audit.ObservedAlignment(row), '-', 'LineWidth', 1.5, ...
            'Color', colors(row, :));
    end
    xlabel(ax, 'Alignment index'); ylabel(ax, 'Probability density');
    title(ax, 'C  Raw 10,000-draw null distribution');
    legend(ax, threshold_labels(audit), 'Location', 'best');
    style_axes(ax);

    ax = nexttile(layout, 4); axis(ax, 'off');
    row = find(audit.VarianceThreshold == max(audit.VarianceThreshold), 1, 'last');
    lines = {
        'D  Published Kao/Elsayed pipeline';
        '300-ms half-open windows; 30 samples/epoch at 10 ms';
        'Prep: 150-440 ms after target onset';
        'Move: -50 to +240 ms around model movement onset';
        'Model onset: 100 ms after preparatory-control removal';
        'Per-neuron normalization: full-task rate range + 5';
        'At each time: subtract across-condition mean';
        'Null: Gaussian directions biased by sqrt(C_{full}), then orth()';
        sprintf('Canonical 95%%: K=%d, AI=%.3f, null median=%.3f', ...
            audit.K(row), audit.ObservedAlignment(row), audit.NullMedian(row));
        sprintf('Null SD=%.3f; bootstrap-median SD=%.4f', ...
            audit.NullSD(row), audit.BootstrapSDOfNullMedians(row))};
    if controllerName == "Stage 2B-Kao"
        lines{end + 1} = ['Pinned release contains one ISN instance; the ' ...
            'published ten-network mean/SD cannot be regenerated exactly.'];
    end
    text(ax, 0.02, 0.96, lines, 'VerticalAlignment', 'top', ...
        'FontSize', 12, 'Interpreter', 'tex');
    title(layout, sprintf('%s: source-faithful preparatory-movement alignment', ...
        char(controllerName)), 'FontSize', 18, 'FontWeight', 'bold');
end

function labels = threshold_labels(audit)
    labels = strings(height(audit), 1);
    for row = 1:height(audit)
        labels(row) = sprintf('%d%% (K=%d)', ...
            round(100 * audit.VarianceThreshold(row)), audit.K(row));
    end
end

function style_axes(ax)
    set(ax, 'FontSize', 12, 'TickDir', 'out', 'LineWidth', 0.3, ...
        'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);
    grid(ax, 'off'); box(ax, 'off');
    legend(ax, 'boxoff');
end
