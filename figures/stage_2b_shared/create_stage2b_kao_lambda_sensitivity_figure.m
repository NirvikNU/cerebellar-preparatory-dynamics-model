function files = create_stage2b_kao_lambda_sensitivity_figure(cfg, complete)
    network = complete.results.network;
    ensemble = complete.results.ensemble;
    lambdas = complete.lambdas;
    colors = lines(numel(lambdas));
    canonicalIndex = find(lambdas == 0.1, 1);
    colors(canonicalIndex, :) = [0.75, 0.10, 0.10];
    figureHandle = figure('Visible', 'off', 'Color', 'w', ...
        'Position', [60, 60, 1500, 850]);
    layout = tiledlayout(2, 3, 'TileSpacing', 'compact', ...
        'Padding', 'compact');

    nexttile;
    plot_lambda_metric(network, ensemble, lambdas, ...
        'GainSpectralNorm', '||K||_2', false);
    title('A  Feedback-gain magnitude');

    nexttile;
    plot_lambda_metric(network, ensemble, lambdas, ...
        'TargetMedianT95Ms', 't_{95} (ms)', false);
    hold on;
    notReached = network.NotReachedTargetCount > 0;
    if any(notReached)
        scatter(network.Lambda(notReached), ...
            510 * ones(sum(notReached), 1), 55, 'k', '^', 'filled', ...
            'DisplayName', 'One or more targets not reached');
        ylim([0, 525]);
    end
    title('B  Prospective-error speed');

    nexttile;
    plot_lambda_metric(network, ensemble, lambdas, ...
        'TargetMedianRawEffort', 'Raw effort, \int||u_{fb}||^2dt', true);
    title('C  Unweighted feedback effort');

    nexttile;
    hold on;
    plot_metric_summary_only(ensemble, lambdas, ...
        'TargetMedianFeedbackRmsNorm', [0.10, 0.35, 0.75], 'o-', ...
        'RMS norm');
    plot_metric_summary_only(ensemble, lambdas, ...
        'TargetMedianPeakFeedbackNorm', [0.90, 0.45, 0.10], 's--', ...
        'Peak norm');
    reference = xline(0.1, ':', 'Canonical \lambda=0.1', ...
        'Color', [0.75, 0.10, 0.10], 'LabelVerticalAlignment', 'bottom');
    reference.HandleVisibility = 'off';
    set(gca, 'XScale', 'log', 'YScale', 'log');
    xticks(lambdas);
    xlabel('\lambda'); ylabel('Feedback norm');
    title('D  RMS and peak feedback');
    legend('Location', 'best'); grid on; box off;

    nexttile;
    hold on;
    for lambdaIndex = 1:numel(lambdas)
        lambda = lambdas(lambdaIndex);
        rows = network.Lambda == lambda;
        scatter(network.TargetMedianRawEffort(rows), ...
            network.TargetMedianT95Ms(rows), 24, colors(lambdaIndex, :), ...
            'filled', 'MarkerFaceAlpha', 0.35, 'HandleVisibility', 'off');
        effort = metric_summary(ensemble, lambda, ...
            'TargetMedianRawEffort');
        speed = metric_summary(ensemble, lambda, 'TargetMedianT95Ms');
        markerSize = 8;
        lineWidth = 1.5;
        if lambda == 0.1
            markerSize = 11;
            lineWidth = 2.5;
        end
        errorbar(effort.Median, speed.Median, speed.BootstrapSE, ...
            speed.BootstrapSE, effort.BootstrapSE, effort.BootstrapSE, ...
            'o', 'Color', colors(lambdaIndex, :), ...
            'MarkerFaceColor', colors(lambdaIndex, :), ...
            'MarkerSize', markerSize, 'LineWidth', lineWidth, ...
            'DisplayName', sprintf('\\lambda = %.2g', lambda));
    end
    set(gca, 'XScale', 'log');
    xlabel('Raw effort, \int||u_{fb}||^2dt'); ylabel('t_{95} (ms)');
    title('E  Gain-speed-effort tradeoff');
    legend('Location', 'best'); grid on; box off;

    nexttile;
    hold on;
    plot_metric_summary_only(ensemble, lambdas, ...
        'TargetMedianEndpoint100Mm', [0.20, 0.55, 0.25], 'o-', ...
        '100-ms preparation');
    plot_metric_summary_only(ensemble, lambdas, ...
        'TargetMedianEndpoint200Mm', [0.55, 0.20, 0.65], 's--', ...
        '200-ms preparation');
    reference = xline(0.1, ':', 'Canonical \lambda=0.1', ...
        'Color', [0.75, 0.10, 0.10], 'LabelVerticalAlignment', 'bottom');
    reference.HandleVisibility = 'off';
    set(gca, 'XScale', 'log'); xticks(lambdas);
    xlabel('\lambda'); ylabel('Endpoint error (mm)');
    title('F  Behavioral check');
    legend('Location', 'best'); grid on; box off;

    title(layout, ['Stage 2B-Kao \lambda sensitivity: stronger gain, ' ...
        'preparation speed, and feedback cost'], 'FontWeight', 'bold');
    diagnosticCfg = cfg;
    diagnosticCfg.plotsPngRoot = fullfile(cfg.plotsRoot, 'diagnostics', ...
        'lambda_sensitivity', 'png');
    diagnosticCfg.plotsFigRoot = fullfile(cfg.plotsRoot, 'diagnostics', ...
        'lambda_sensitivity', 'fig');
    [figFile, pngFile] = save_figure_bundle(figureHandle, ...
        'stage2b_kao_lambda_sensitivity_gain_speed_effort', diagnosticCfg);
    files = struct('fig', string(figFile), 'png', string(pngFile));
end

function plot_lambda_metric(network, ensemble, lambdas, metric, yLabel, yLog)
    hold on;
    networks = unique(network.Network).';
    for networkIndex = networks
        rows = network.Network == networkIndex;
        current = sortrows(network(rows, {'Lambda', metric}), 'Lambda');
        plot(current.Lambda, current.(metric), '-', ...
            'Color', [0.75, 0.75, 0.75], 'LineWidth', 0.7, ...
            'HandleVisibility', 'off');
    end
    medianValues = zeros(numel(lambdas), 1);
    seValues = zeros(numel(lambdas), 1);
    for index = 1:numel(lambdas)
        summary = metric_summary(ensemble, lambdas(index), metric);
        medianValues(index) = summary.Median;
        seValues(index) = summary.BootstrapSE;
    end
    errorbar(lambdas, medianValues, seValues, 'ko-', ...
        'MarkerFaceColor', 'k', 'LineWidth', 1.8, 'MarkerSize', 6, ...
        'DisplayName', 'Median \pm 1 bootstrap SE');
    canonical = lambdas == 0.1;
    scatter(lambdas(canonical), medianValues(canonical), 85, ...
        [0.75, 0.10, 0.10], 'filled', 'DisplayName', 'Canonical \lambda=0.1');
    set(gca, 'XScale', 'log');
    if yLog
        set(gca, 'YScale', 'log');
    end
    xticks(lambdas); xlabel('\lambda'); ylabel(yLabel);
    grid on; box off;
end

function plot_metric_summary_only(ensemble, lambdas, metric, color, style, label)
    medianValues = zeros(numel(lambdas), 1);
    seValues = zeros(numel(lambdas), 1);
    for index = 1:numel(lambdas)
        summary = metric_summary(ensemble, lambdas(index), metric);
        medianValues(index) = summary.Median;
        seValues(index) = summary.BootstrapSE;
    end
    errorbar(lambdas, medianValues, seValues, style, 'Color', color, ...
        'MarkerFaceColor', color, 'LineWidth', 1.7, 'MarkerSize', 6, ...
        'DisplayName', label);
end

function output = metric_summary(ensemble, lambda, metric)
    output = ensemble(ensemble.Lambda == lambda & ...
        ensemble.Metric == string(metric), :);
    assert(height(output) == 1);
end
