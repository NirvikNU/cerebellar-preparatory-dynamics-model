function files = create_gate2_active_set_figures(cfg, diagnostic, results, ...
        representative)
    files.stage1Representative = representative_figure(cfg, diagnostic, ...
        representative.movement);
    files.stage1Quantitative = stage1_quantitative_figure(cfg, diagnostic, ...
        results);
    files.preparationSufficiency = preparation_figure(cfg, diagnostic, results);
end

function files = representative_figure(cfg, diagnostic, representative)
    handle = figure('Visible', 'off', 'Color', 'w', ...
        'Position', [50, 50, 1700, 1000]);
    layout = tiledlayout(handle, 2, 2, 'TileSpacing', 'compact', ...
        'Padding', 'compact');
    inactivePercent = 100 * (1 - squeeze(mean( ...
        representative.activeRaster, 1)));
    ax = nexttile(layout);
    imagesc(ax, 1:8, 1:200, inactivePercent);
    colormap(ax, white_to_color([0.35, 0.16, 0.62]));
    colorScale = colorbar(ax, 'eastoutside');
    colorScale.Label.String = 'Movement time inactive (%)';
    xlabel(ax, 'Target'); ylabel(ax, 'Ordered neuron');
    xticks(ax, 1:8); xticklabels(ax, compose('T%d', 1:8));
    title(ax, 'A  Shared ON/OFF participation');
    text(ax, 1.15, 193, 'Zero = active throughout', ...
        'Color', [0.25, 0.25, 0.25], 'FontSize', cfg.plot.fontSize - 1);
    apply_plot_style(ax, cfg);
    ax = nexttile(layout);
    imagesc(ax, 1:8, 1:200, representative.meanRatesNormalized);
    colormap(ax, parula(256));
    colorScale = colorbar(ax, 'eastoutside');
    colorScale.Label.String = 'Normalized mean movement firing rate';
    xlabel(ax, 'Target'); ylabel(ax, 'Same ordered neurons');
    xticks(ax, 1:8); xticklabels(ax, compose('T%d', 1:8));
    title(ax, 'B  Target-specific continuous amplitudes');
    apply_plot_style(ax, cfg);
    ax = nexttile(layout, 3, [1, 2]);
    target = 2;
    targetRaster = squeeze(representative.activeRaster(:, :, target)).';
    image(ax, 1000 * representative.timesS, 1:200, 1 + targetRaster);
    colormap(ax, [1, 1, 1; 0.08, 0.08, 0.08]);
    clim(ax, [1, 2]); hold(ax, 'on');
    switchingRows = find(any(diff(targetRaster, 1, 2) ~= 0, 2));
    for row = switchingRows.'
        yline(ax, row, '-', 'Color', [0.85, 0.15, 0.12], ...
            'LineWidth', 1.2);
    end
    xlabel(ax, 'Movement time (ms)'); ylabel(ax, 'Same ordered neurons');
    title(ax, sprintf(['Inset  N1/T2 binary activity; red line marks %d ' ...
        'switching neuron'], numel(switchingRows)));
    apply_plot_style(ax, cfg);
    sgtitle(handle, ['Gate 2 — network 1: shared active population, ' ...
        'target-specific firing amplitudes']);
    files = save_bundle(handle, ...
        'stage1_representative_active_set_raster_and_rate_heatmap', ...
        diagnostic.stage1FigRoot, diagnostic.stage1PngRoot, cfg.plot.resolution);
end

function files = stage1_quantitative_figure(cfg, diagnostic, results)
    handle = figure('Visible', 'off', 'Color', 'w', ...
        'Position', [50, 50, 1650, 760]);
    layout = tiledlayout(handle, 1, 2, 'TileSpacing', 'compact', ...
        'Padding', 'compact');
    layout.OuterPosition = [0, 0.08, 1, 0.86];
    switching = network_target_matrix(results.stage1Target, ...
        'SwitchingFraction') * 100;
    endpointMm = network_target_matrix(results.frozenRegimeTarget, ...
        'EndpointErrorM') * 1000;
    ax = nexttile(layout);
    imagesc(ax, 1:8, 1:10, switching);
    colormap(ax, white_to_color([0.10, 0.42, 0.72]));
    clim(ax, [0, 1.5]);
    colorScale = colorbar(ax, 'eastoutside');
    colorScale.Label.String = 'Neurons switching at least once (%)';
    colorScale.Ticks = [0, 0.5, 1, 1.5];
    annotate_nonzero_cells(ax, switching, @(value) sprintf('%.1f', value), 0.5);
    configure_heatmap_axes(ax, 'A  Threshold crossings', cfg);
    ax = nexttile(layout);
    endpointColor = log10(1 + endpointMm);
    imagesc(ax, 1:8, 1:10, endpointColor);
    colormap(ax, white_to_color([0.78, 0.12, 0.12]));
    maximumMm = max(endpointMm, [], 'all');
    clim(ax, [0, log10(1 + maximumMm)]);
    colorScale = colorbar(ax, 'eastoutside');
    rawTicks = [0, 1, 10, 100, 400];
    rawTicks = rawTicks(rawTicks <= max(400, maximumMm));
    colorScale.Ticks = log10(1 + rawTicks);
    colorScale.TickLabels = compose('%g', rawTicks);
    colorScale.Label.String = 'Endpoint mismatch (mm; log color mapping)';
    annotate_nonzero_cells(ax, endpointMm, @endpoint_label, 1.5);
    configure_heatmap_axes(ax, 'B  GO-active-set-frozen mismatch', cfg);
    annotation(handle, 'textbox', [0.12, 0.012, 0.76, 0.05], ...
        'String', ['72/80 movements exact under frozen active set   |   ' ...
        '8/80 show threshold crossings   |   target-union Jaccard ' ...
        '= 1 for 280/280 target pairs'], 'HorizontalAlignment', ...
        'center', 'EdgeColor', 'none', 'FontWeight', 'bold', ...
        'FontSize', cfg.plot.fontSize);
    sgtitle(handle, ['Gate 2 — all networks and targets: sparse switching ' ...
        'can produce material nonlinear movement errors']);
    files = save_bundle(handle, ...
        'stage1_switching_overlap_and_frozen_regime_test', ...
        diagnostic.stage1FigRoot, diagnostic.stage1PngRoot, cfg.plot.resolution);
end

function files = preparation_figure(cfg, diagnostic, results)
    handle = figure('Visible', 'off', 'Color', 'w', ...
        'Position', [50, 50, 1800, 760]);
    layout = tiledlayout(handle, 1, 3, 'TileSpacing', 'compact', ...
        'Padding', 'compact');
    layout.OuterPosition = [0, 0.10, 1, 0.82];
    controllers = ["Stage 2A", "Stage 2B-Kao"];
    colors = [0.25, 0.55, 0.85; 0.85, 0.25, 0.20];
    metrics = ["ActiveSetMismatchPercent", "ProspectiveErrorFraction", ...
        "EndpointErrorM"];
    labels = {'Incorrect ON/OFF identity (%)', ...
        'Normalized prospective-Q error', 'Endpoint error (mm)'};
    titles = {'A  Active-set mismatch','B  Continuous-state error', ...
        'C  Behavioral consequence'};
    for metricIndex = 1:3
        ax = nexttile(layout);
        hold(ax, 'on');
        for controllerIndex = 1:2
            plot_preparation_metric(ax, results, controllers(controllerIndex), ...
                metrics(metricIndex), diagnostic, colors(controllerIndex, :), ...
                metricIndex == 3);
        end
        xlabel(ax, 'Preparation duration (ms)'); ylabel(ax, labels{metricIndex});
        title(ax, titles{metricIndex});
        if metricIndex == 1
            ylim(ax, [0, 5]);
            text(ax, 15, 4.55, ['Target-level maxima: Stage 2A 4.5%; ' ...
                'Kao 1.0%'], 'FontSize', cfg.plot.fontSize - 1);
        elseif metricIndex == 2
            yline(ax, diagnostic.prospectiveThreshold, ':k', '0.05', ...
                'HandleVisibility', 'off');
            set(ax, 'YScale', 'log');
            ylim(ax, [1e-6, 1.2]);
            text(ax, 65, 0.12, 'Kao median t_{95}: 20 ms', ...
                'Color', colors(2, :), 'FontSize', cfg.plot.fontSize - 1);
            text(ax, 255, 0.09, 'Stage 2A: 440 ms (9/10)', ...
                'Color', colors(1, :), 'FontSize', cfg.plot.fontSize - 1);
        else
            yline(ax, 1000 * diagnostic.endpointThresholdM, ':k', '2 mm', ...
                'HandleVisibility', 'off');
            ylim(ax, [0, 175]);
        end
        if metricIndex == 1
            legend(ax, 'Location', 'northeast'); legend(ax, 'boxoff');
        else
            legend(ax, 'off');
        end
        apply_plot_style(ax, cfg);
    end
    annotation(handle, 'textbox', [0.12, 0.012, 0.76, 0.065], ...
        'String', ['At 0 ms, median active-set mismatch is 0%, yet ' ...
        'prospective-Q error is 1 and endpoint error is about 102 mm. ' ...
        'Correct ON/OFF identity does not imply a prepared movement state.'], ...
        'HorizontalAlignment', 'center', 'EdgeColor', [0.55, 0.55, 0.55], ...
        'BackgroundColor', [0.97, 0.97, 0.97], 'FontWeight', 'bold', ...
        'FontSize', cfg.plot.fontSize);
    sgtitle(handle, ['Gate 2 — preparation depends on continuous cortical ' ...
        'state, not binary active-set identity']);
    files = save_bundle(handle, ...
        'stage2a_vs_stage2b_kao_active_set_sufficiency', ...
        diagnostic.comparisonFigRoot, diagnostic.comparisonPngRoot, ...
        cfg.plot.resolution);
end

function plot_preparation_metric(ax, results, controller, metric, ...
        diagnostic, color, convertToMm)
    network = results.preparationNetwork;
    selected = network.Controller == controller;
    current = network(selected, :);
    networks = unique(current.Network);
    durations = unique(current.PreparationDurationS);
    matrix = zeros(numel(networks), numel(durations));
    for networkIndex = 1:numel(networks)
        rows = current.Network == networks(networkIndex);
        values = sortrows(current(rows, :), 'PreparationDurationS').(metric);
        if convertToMm, values = 1000 * values; end
        matrix(networkIndex, :) = values.';
        faintColor = 0.88 * [1, 1, 1] + 0.12 * color;
        plot(ax, 1000 * durations, values, '-', 'Color', faintColor, ...
            'LineWidth', 0.5, 'HandleVisibility', 'off');
    end
    summary = bootstrap_network_median(matrix, diagnostic.bootstrapSamples, ...
        diagnostic.bootstrapSeed + 800 + find(["Stage 2A", ...
        "Stage 2B-Kao"] == controller));
    lower = max(summary.median - summary.standardError, realmin);
    patch(ax, 1000 * [durations; flipud(durations)], ...
        [lower, ...
        fliplr(summary.median + summary.standardError)], color, ...
        'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(ax, 1000 * durations, summary.median, 'Color', color, ...
        'LineWidth', 2, 'DisplayName', controller);
    legend(ax, 'Location', 'best'); legend(ax, 'boxoff');
end

function output = save_bundle(handle, name, figRoot, pngRoot, resolution)
    if ~isfolder(figRoot), mkdir(figRoot); end
    if ~isfolder(pngRoot), mkdir(pngRoot); end
    output.fig = fullfile(figRoot, [name, '.fig']);
    output.png = fullfile(pngRoot, [name, '.png']);
    savefig(handle, output.fig);
    exportgraphics(handle, output.png, 'Resolution', resolution, ...
        'BackgroundColor', 'white');
    close(handle);
end

function matrix = network_target_matrix(input, variable)
    matrix = nan(10, 8);
    for row = 1:height(input)
        matrix(input.Network(row), input.Target(row)) = input.(variable)(row);
    end
    assert(all(isfinite(matrix), 'all'));
end

function configure_heatmap_axes(ax, titleText, cfg)
    xlabel(ax, 'Target'); ylabel(ax, 'Network');
    xticks(ax, 1:8); xticklabels(ax, compose('T%d', 1:8));
    yticks(ax, 1:10); yticklabels(ax, compose('N%d', 1:10));
    title(ax, titleText); axis(ax, 'tight'); apply_plot_style(ax, cfg);
end

function annotate_nonzero_cells(ax, matrix, formatter, threshold)
    for network = 1:size(matrix, 1)
        for target = 1:size(matrix, 2)
            value = matrix(network, target);
            if value > 0
                if value >= threshold
                    color = [1, 1, 1];
                else
                    color = [0.12, 0.12, 0.12];
                end
                text(ax, target, network, formatter(value), ...
                    'HorizontalAlignment', 'center', 'Color', color, ...
                    'FontWeight', 'bold', 'FontSize', 9);
            end
        end
    end
end

function label = endpoint_label(value)
    if value >= 100
        label = sprintf('%.0f', value);
    elseif value >= 10
        label = sprintf('%.1f', value);
    elseif value >= 1
        label = sprintf('%.2f', value);
    elseif value >= 0.1
        label = sprintf('%.2f', value);
    else
        label = sprintf('%.3f', value);
    end
end

function map = white_to_color(color)
    weights = linspace(0, 1, 256).';
    map = (1 - weights) .* ones(256, 3) + weights .* color;
end

function apply_plot_style(ax, cfg)
    set(ax, 'FontSize', cfg.plot.fontSize, 'TickDir', 'out', ...
        'LineWidth', cfg.plot.axisLineWidth, 'XColor', [0, 0, 0], ...
        'YColor', [0, 0, 0]);
    grid(ax, 'off'); box(ax, 'off');
end
