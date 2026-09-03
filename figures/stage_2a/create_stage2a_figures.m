function inventory = create_stage2a_figures(cfg, representative, ensemble, ...
        figureIndices)
    if nargin < 4 || isempty(figureIndices)
        figureIndices = 1:5;
    end
    assert(all(ismember(figureIndices, 1:5)) && numel(unique(figureIndices)) ...
        == numel(figureIndices));
    inventory = strings(numel(figureIndices), 2);
    for outputIndex = 1:numel(figureIndices)
        figureIndex = figureIndices(outputIndex);
        switch figureIndex
            case 1
                files = fixed_point_figure(cfg, representative, ensemble);
            case 2
                files = cortical_trajectory_figure(cfg, representative);
            case 3
                files = prospective_error_figure(cfg, representative, ensemble);
            case 4
                files = reach_duration_figure(cfg, representative);
            case 5
                files = movement_error_figure(cfg, representative, ensemble);
        end
        inventory(outputIndex, :) = files;
    end
end

function files = fixed_point_figure(cfg, representative, ensemble)
    model = representative.model;
    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1200, 600]);
    layout = tiledlayout(figureHandle, 1, 2, 'TileSpacing', 'compact');
    axesHandle = nexttile(layout);
    bar(axesHandle, 1:model.nMovements, ...
        vecnorm(representative.tonicInput, 2, 1), ...
        'FaceColor', [0.25, 0.45, 0.70]);
    xlabel(axesHandle, 'Target'); ylabel(axesHandle, '||u_{q,1}^*||_2');
    panelTitle = title(axesHandle, ...
        'Network 1: analytical tonic inputs');
    set(panelTitle, 'FontSize', 15);
    apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    residual = ensemble.networkAudit.MaximumFixedPointResidual;
    normalizedResidual = residual / cfg.acceptance.fixedPointResidualTolerance;
    scatter(axesHandle, 1:cfg.ensemble.count, normalizedResidual, 38, ...
        [0.65, 0.72, 0.80], 'filled', 'MarkerEdgeColor', [0.35, 0.35, 0.35]);
    residualSummary = bootstrap_network_median(normalizedResidual, ...
        cfg.ensemble.bootstrapSamples, cfg.ensemble.bootstrapSeed + 100);
    summaryX = cfg.ensemble.count + 1.5;
    errorbar(axesHandle, summaryX, residualSummary.median, ...
        residualSummary.standardError, 'kd', 'MarkerFaceColor', 'k', ...
        'MarkerSize', 7, 'LineWidth', 1.5, 'CapSize', 10);
    text(axesHandle, summaryX, 0.08, '0 \pm 0', ...
        'HorizontalAlignment', 'center', 'FontSize', cfg.plot.fontSize - 1);
    yline(axesHandle, 1, 'r--', ...
        'Tolerance');
    ylim(axesHandle, [-0.05, 1.1]);
    xlim(axesHandle, [0.5, summaryX + 0.5]);
    xticks(axesHandle, [1:cfg.ensemble.count, summaryX]);
    xticklabels(axesHandle, [compose('N%d', 1:cfg.ensemble.count), ...
        "Median"]);
    xtickangle(axesHandle, 45);
    xlabel(axesHandle, 'Accepted Stage-1 network / ensemble summary');
    ylabel(axesHandle, 'Maximum residual / 10^{-12} tolerance');
    panelTitle = title(axesHandle, ...
        'All networks: residuals and median \pm bootstrap SE');
    set(panelTitle, 'FontSize', 15);
    apply_plot_style(axesHandle, cfg);
    mainTitle = title(layout, ...
        'Stage 2A analytical-input validation across the frozen ensemble');
    set(mainTitle, 'FontSize', 16);
    files = save_bundle(figureHandle, '01_tonic_input_and_fixed_point', cfg);
end

function files = cortical_trajectory_figure(cfg, representative)
    model = representative.model;
    preparation = representative.preparation;
    ideal = representative.ideal;
    analysis = representative.analysis;
    rates = reshape(permute(ideal.cortex.rates, [1, 3, 2]), [], model.n);
    center = mean(rates, 1);
    centered = rates - center;
    [~, ~, basis] = svd(centered, 'econ');
    basis = basis(:, 1:2);
    durations = analysis.representative.durationsS;
    movementRates = analysis.representative.simulation.cortex.rates;
    spontaneousCoordinate = (max(model.spontaneous, 0).' - center) * basis;
    targetCoordinates = (max(model.xstar, 0).' - center) * basis;
    figureHandle = figure('Color', 'w', 'Position', [40, 40, 1450, 850]);
    layout = tiledlayout(figureHandle, 2, 3, 'TileSpacing', 'compact');
    axesHandles = gobjects(numel(durations), 1);
    for durationIndex = 1:numel(durations)
        axesHandle = nexttile(layout); hold(axesHandle, 'on');
        axesHandles(durationIndex) = axesHandle;
        endIndex = round(durations(durationIndex) / model.samplingDt) + 1;
        prepIndices = unique([1:10:endIndex, endIndex]);
        for target = 1:model.nMovements
            prepRates = max(preparation.states(prepIndices, :, target), 0);
            prepCoordinates = (prepRates - center) * basis;
            batch = (durationIndex - 1) * model.nMovements + target;
            moveRates = squeeze(movementRates(:, :, batch));
            moveCoordinates = (moveRates - center) * basis;
            color = cfg.plot.colors(target, :);
            plot(axesHandle, prepCoordinates(:, 1), prepCoordinates(:, 2), '--', ...
                'Color', color, 'LineWidth', 1.2);
            plot(axesHandle, moveCoordinates(:, 1), moveCoordinates(:, 2), '-', ...
                'Color', color, 'LineWidth', 1.5);
            scatter(axesHandle, prepCoordinates(end, 1), prepCoordinates(end, 2), ...
                38, color, 'filled', 'MarkerEdgeColor', 'k');
            scatter(axesHandle, targetCoordinates(target, 1), ...
                targetCoordinates(target, 2), 65, color, 'p', ...
                'MarkerFaceColor', 'none', 'LineWidth', 1.3);
        end
        scatter(axesHandle, spontaneousCoordinate(1), spontaneousCoordinate(2), ...
            70, 'k', 'd', 'MarkerFaceColor', 'none', 'LineWidth', 1.5);
        xlabel(axesHandle, 'Movement PC1'); ylabel(axesHandle, 'Movement PC2');
        title(axesHandle, sprintf('Preparation %.2g s', durations(durationIndex)));
        apply_plot_style(axesHandle, cfg);
    end
    synchronize_limits(axesHandles);
    title(layout, ['Representative network 1 — dashed: preparation; filled ' ...
        'circle: GO; solid: movement; diamond: spontaneous; star: ideal x^*']);
    files = save_bundle(figureHandle, ...
        '02_cortical_preparation_and_movement', cfg);
end

function files = prospective_error_figure(cfg, representative, ensemble)
    model = representative.model;
    preparation = representative.preparation;
    analysis = representative.analysis;
    summary = ensemble.timecourse;
    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1250, 620]);
    layout = tiledlayout(figureHandle, 1, 2, 'TileSpacing', 'compact');
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    networkHandle = plot_network_curves(axesHandle, summary.PreparationDurationS, ...
        ensemble.stateByNetwork, [0.72, 0.72, 0.72], false);
    for target = 1:model.nMovements
        plot(axesHandle, preparation.timesS, ...
            analysis.preparation.normalizedStateError(:, target), ':', ...
            'Color', cfg.plot.colors(target, :), 'LineWidth', 0.8);
    end
    [bandHandle, medianHandle] = shaded_summary(axesHandle, ...
        summary.PreparationDurationS, ...
        summary.StateErrorFractionMedian, ...
        summary.StateErrorFractionBootstrapSE, false);
    representativeHandle = plot(axesHandle, nan, nan, ':', ...
        'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.2);
    xlabel(axesHandle, 'Preparation time (s)');
    ylabel(axesHandle, 'Normalized ||x(t)-x_q^*||_2');
    panelTitle = title(axesHandle, 'State error');
    set(panelTitle, 'FontSize', 16);
    legend(axesHandle, [networkHandle, bandHandle, medianHandle, ...
        representativeHandle], {'Individual network target-medians', ...
        '\pm1 bootstrap SE', 'Median across 10 networks', ...
        'Representative network-1 targets'}, ...
        'Location', 'southwest', 'FontSize', 8);
    legend(axesHandle, 'boxoff');
    apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    networkHandle = plot_network_curves(axesHandle, summary.PreparationDurationS, ...
        ensemble.prospectiveByNetwork, [0.72, 0.72, 0.72], true);
    for target = 1:model.nMovements
        semilogy(axesHandle, preparation.timesS, max( ...
            analysis.preparation.normalizedProspectiveError(:, target), realmin), ...
            ':', 'Color', cfg.plot.colors(target, :), 'LineWidth', 0.8);
    end
    [bandHandle, medianHandle] = shaded_summary(axesHandle, ...
        summary.PreparationDurationS, ...
        summary.ProspectiveErrorFractionMedian, ...
        summary.ProspectiveErrorFractionBootstrapSE, true);
    representativeHandle = semilogy(axesHandle, nan, nan, ':', ...
        'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.2);
    yline(axesHandle, [0.5, 0.2, 0.1, 0.05], ':');
    xlabel(axesHandle, 'Preparation time (s)');
    ylabel(axesHandle, 'Normalized prospective motor error');
    panelTitle = title(axesHandle, 'Prospective error using each network''s own Q_j');
    set(panelTitle, 'FontSize', 16);
    legend(axesHandle, [networkHandle, bandHandle, medianHandle, ...
        representativeHandle], {'Individual network target-medians', ...
        '\pm1 bootstrap SE', 'Median across 10 networks', ...
        'Representative network-1 targets'}, ...
        'Location', 'southwest', 'FontSize', 8);
    legend(axesHandle, 'boxoff');
    apply_plot_style(axesHandle, cfg);
    mainTitle = title(layout, sprintf(['Median across 10 networks ± 1 bootstrap SE of the median; ' ...
        '%d network-level bootstrap resamples'], ...
        cfg.ensemble.bootstrapSamples));
    set(mainTitle, 'FontSize', 15);
    files = save_bundle(figureHandle, ...
        '03_prospective_error_during_preparation', cfg);
end

function files = reach_duration_figure(cfg, representative)
    model = representative.model;
    ideal = representative.ideal;
    analysis = representative.analysis;
    durations = analysis.representative.durationsS;
    figureHandle = figure('Color', 'w', 'Position', [30, 30, 1500, 800]);
    layout = tiledlayout(figureHandle, 2, 4, 'TileSpacing', 'compact');
    reachAxes = gobjects(numel(durations) + 1, 1);
    for durationIndex = 1:numel(durations)
        axesHandle = nexttile(layout); hold(axesHandle, 'on');
        reachAxes(durationIndex) = axesHandle;
        for target = 1:model.nMovements
            targetHand = model.targetHand(:, :, target);
            batch = (durationIndex - 1) * model.nMovements + target;
            generated = analysis.representative.simulation.hand(:, :, batch);
            plot(axesHandle, targetHand(:, 1), targetHand(:, 3), '--', ...
                'Color', cfg.plot.colors(target, :), 'LineWidth', 0.9);
            plot(axesHandle, generated(:, 1), generated(:, 3), '-', ...
                'Color', cfg.plot.colors(target, :), 'LineWidth', 1.5);
        end
        axis(axesHandle, 'equal'); xlabel(axesHandle, 'Hand x (m)');
        ylabel(axesHandle, 'Hand y (m)');
        title(axesHandle, sprintf('Preparation %.2g s', durations(durationIndex)));
        apply_plot_style(axesHandle, cfg);
    end
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    reachAxes(end) = axesHandle;
    for target = 1:model.nMovements
        targetHand = model.targetHand(:, :, target);
        generated = ideal.hand(:, :, target);
        plot(axesHandle, targetHand(:, 1), targetHand(:, 3), '--', ...
            'Color', cfg.plot.colors(target, :), 'LineWidth', 0.9);
        plot(axesHandle, generated(:, 1), generated(:, 3), '-', ...
            'Color', cfg.plot.colors(target, :), 'LineWidth', 1.5);
    end
    axis(axesHandle, 'equal'); xlabel(axesHandle, 'Hand x (m)');
    ylabel(axesHandle, 'Hand y (m)'); title(axesHandle, 'Ideal Stage 1: x(0)=x_q^*');
    apply_plot_style(axesHandle, cfg);
    synchronize_limits(reachAxes);
    axesHandle = nexttile(layout); axis(axesHandle, 'off');
    text(axesHandle, 0, 0.75, 'Representative network 1', ...
        'FontSize', cfg.plot.fontSize, 'FontWeight', 'bold');
    text(axesHandle, 0, 0.55, 'Dashed: 10-cm target reach', ...
        'FontSize', cfg.plot.fontSize);
    text(axesHandle, 0, 0.38, 'Solid: generated reach', ...
        'FontSize', cfg.plot.fontSize);
    text(axesHandle, 0, 0.15, {'Longer preparation moves the GO state', ...
        'toward the ideal frozen Stage-1 state.'}, ...
        'FontSize', cfg.plot.fontSize - 1, 'Units', 'normalized');
    title(layout, 'Representative reaches after different preparation durations');
    files = save_bundle(figureHandle, ...
        '04_reaches_vs_preparation_duration', cfg);
end

function files = movement_error_figure(cfg, representative, ensemble)
    summary = ensemble.movementSummary;
    durations = summary.PreparationDurationS;
    figureHandle = figure('Color', 'w', 'Position', [60, 60, 1350, 850]);
    layout = tiledlayout(figureHandle, 2, 2, 'TileSpacing', 'compact');
    ensemble_metric_panel(nexttile(layout), durations, ...
        ensemble.endpointByNetwork, summary.EndpointErrorMMedian, ...
        summary.EndpointErrorMBootstrapSE, cfg, ...
        'Endpoint discrepancy (m)', 'Endpoint error versus ideal Stage 1');
    ensemble_metric_panel(nexttile(layout), durations, ...
        ensemble.handByNetwork, summary.HandTrajectoryNRMSEMedian, ...
        summary.HandTrajectoryNRMSEBootstrapSE, cfg, ...
        'Hand-displacement NRMSE', 'Whole-reach error');
    ensemble_metric_panel(nexttile(layout), durations, ...
        ensemble.torqueByNetwork, summary.TorqueNRMSEMedian, ...
        summary.TorqueNRMSEBootstrapSE, cfg, ...
        'Torque NRMSE', 'Motor-output error');
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    correlations = ensemble.networkAudit.ProspectiveMovementLogCorrelation;
    scatter(axesHandle, 1:cfg.ensemble.count, correlations, 48, ...
        [0.65, 0.72, 0.80], 'filled', 'MarkerEdgeColor', [0.35, 0.35, 0.35]);
    statistics = bootstrap_network_median(correlations, ...
        cfg.ensemble.bootstrapSamples, cfg.ensemble.bootstrapSeed + 106);
    summaryX = cfg.ensemble.count + 1.5;
    errorbar(axesHandle, summaryX, statistics.median, ...
        statistics.standardError, 'kd', 'MarkerFaceColor', 'k', ...
        'MarkerSize', 7, 'LineWidth', 1.5, 'CapSize', 10);
    xlim(axesHandle, [0.5, summaryX + 0.5]);
    xticks(axesHandle, [1:cfg.ensemble.count, summaryX]);
    xticklabels(axesHandle, [compose('N%d', 1:cfg.ensemble.count), ...
        "Median"]);
    xtickangle(axesHandle, 45);
    xlabel(axesHandle, 'Accepted Stage-1 network / ensemble summary');
    ylabel(axesHandle, 'Within-network log correlation');
    title(axesHandle, 'Correlation: network values and median \pm bootstrap SE');
    apply_plot_style(axesHandle, cfg);
    title(layout, sprintf(['All-network summaries: median across networks ' ...
        '± 1 bootstrap SE of the median (%d network-level resamples)'], ...
        cfg.ensemble.bootstrapSamples));
    assert(representative.index == cfg.ensemble.representativeIndex);
    files = save_bundle(figureHandle, ...
        '05_movement_error_vs_preparation_duration', cfg);
end

function ensemble_metric_panel(axesHandle, durations, byNetwork, ...
        medianValues, seValues, cfg, yLabel, panelTitle)
    hold(axesHandle, 'on');
    networkHandle = plot_network_curves(axesHandle, durations, byNetwork, ...
        [0.72, 0.72, 0.72], true);
    lowerError = min(seValues, max(medianValues - realmin, 0));
    summaryHandle = errorbar(axesHandle, durations, medianValues, ...
        lowerError, seValues, '-o', 'Color', [0.05, 0.05, 0.05], ...
        'MarkerFaceColor', [0.10, 0.35, 0.65], 'MarkerEdgeColor', 'k', ...
        'MarkerSize', 4, 'LineWidth', 1.8, 'CapSize', 5);
    set(axesHandle, 'YScale', 'log');
    xlabel(axesHandle, 'Preparation duration (s)'); ylabel(axesHandle, yLabel);
    title(axesHandle, panelTitle);
    legend(axesHandle, [networkHandle, summaryHandle], ...
        {'Individual network target-medians', ...
        'Median ± 1 bootstrap SE'}, 'Location', 'southwest', 'FontSize', 8);
    legend(axesHandle, 'boxoff');
    apply_plot_style(axesHandle, cfg);
end

function firstHandle = plot_network_curves(axesHandle, durations, values, ...
        color, logScale)
    firstHandle = gobjects(1);
    for network = 1:size(values, 2)
        if logScale
            handle = semilogy(axesHandle, durations, ...
                max(values(:, network), realmin), ...
                '-', 'Color', color, 'LineWidth', 0.8);
        else
            handle = plot(axesHandle, durations, values(:, network), '-', ...
                'Color', color, 'LineWidth', 0.8);
        end
        if network == 1
            firstHandle = handle;
        else
            handle.HandleVisibility = 'off';
        end
    end
end

function [bandHandle, medianHandle] = shaded_summary(axesHandle, durations, ...
        medianValues, seValues, logScale)
    lower = max(medianValues - seValues, realmin);
    upper = medianValues + seValues;
    bandHandle = patch(axesHandle, [durations; flipud(durations)], ...
        [lower; flipud(upper)], [0.23, 0.47, 0.72], ...
        'FaceAlpha', 0.30, 'EdgeColor', 'none');
    if logScale
        medianHandle = semilogy(axesHandle, durations, ...
            max(medianValues, realmin), ...
            'k-', 'LineWidth', 2.5);
        set(axesHandle, 'YScale', 'log');
    else
        medianHandle = plot(axesHandle, durations, medianValues, ...
            'k-', 'LineWidth', 2.5);
    end
end

function synchronize_limits(axesHandles)
    xLimits = vertcat(axesHandles.XLim);
    yLimits = vertcat(axesHandles.YLim);
    commonX = [min(xLimits(:, 1)), max(xLimits(:, 2))];
    commonY = [min(yLimits(:, 1)), max(yLimits(:, 2))];
    for index = 1:numel(axesHandles)
        xlim(axesHandles(index), commonX);
        ylim(axesHandles(index), commonY);
    end
end

function files = save_bundle(figureHandle, name, cfg)
    [figFile, pngFile] = save_figure_bundle(figureHandle, name, cfg);
    files = string({figFile, pngFile});
end
