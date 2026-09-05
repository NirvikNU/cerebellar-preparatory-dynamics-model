function figureAudit = create_stage2b_cerebellum_gate4b_figures(cfg, audit)
    % Gate 4D: a one-argument call renders accepted outputs only.
    % No controller, simulation, bootstrap, or accepted-result write occurs.
    if nargin < 2
        saved = load(fullfile(cfg.currentResultsRoot, ...
            'stage2b_cerebellum_gate4b_complete.mat'), 'audit');
        audit = saved.audit;
    end
    names = ["01_stage2b_cerebellum_actuator_q_geometry"; ...
        "02_stage2b_cerebellum_prospective_q_preparation"; ...
        "03_stage2b_cerebellum_endpoint_by_preparation_duration"; ...
        "04_stage2b_cerebellum_structural_controller_validation"];
    figures = gobjects(4, 1);
    figures(1) = geometry_figure(cfg, audit);
    figures(2) = performance_figure(audit, "ProspectiveErrorFraction");
    figures(3) = performance_figure(audit, "EndpointErrorM");
    figures(4) = validation_figure(cfg, audit);
    pngPath = strings(4, 1);
    figPath = strings(4, 1);
    pngValid = false(4, 1);
    figReopenPass = false(4, 1);
    for index = 1:4
        pngPath(index) = fullfile(cfg.plotsPngRoot, names(index) + ".png");
        figPath(index) = fullfile(cfg.plotsFigRoot, names(index) + ".fig");
        savefig(figures(index), figPath(index));
        close(figures(index));
        reopened = openfig(figPath(index), 'invisible');
        figReopenPass(index) = isgraphics(reopened);
        exportgraphics(reopened, pngPath(index), ...
            'Resolution', cfg.plot.resolution, 'BackgroundColor', 'white');
        info = imfinfo(pngPath(index));
        pngValid(index) = info.Width > 0 && info.Height > 0;
        close(reopened);
    end
    figureAudit = table(names, pngPath, figPath, pngValid, figReopenPass, ...
        'VariableNames', {'Figure','PngPath','FigPath','PngValid', ...
        'FigReopenPass'});
end

function output = geometry_figure(cfg, audit)
    output = base_figure('Actuator and Q-potency geometry', [60, 60, 1750, 950]);
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    colors = lines(cfg.ensemble.count);
    nexttile([1, 2]); hold on;
    for network = 1:cfg.ensemble.count
        controllerPath = fullfile(cfg.currentEnsembleRoot, ...
            sprintf('network_%02d_stage2b_cerebellum_controller.mat', network));
        saved = load(controllerPath, 'controllerSaved');
        cumulative = saved.controllerSaved.qCumulativePotency;
        plot(1:30, cumulative(1:30), 'Color', [colors(network, :), 0.35], ...
            'LineWidth', 1.1);
    end
    xline(13, '--k', 'k = 13', 'LabelVerticalAlignment', 'bottom');
    yline(0.95, ':', '95%');
    xlabel('Leading Q dimensions'); ylabel('Cumulative potency fraction');
    title('A  Leading Q directions across all 10 networks');
    xlim([1, 30]); ylim([0, 1.005]); box off;
    nexttile;
    bar(audit.controllerValidation.Network, ...
        100 * audit.controllerValidation.Top13PotencyFraction, ...
        'FaceColor', [0.20, 0.65, 0.35], 'FaceAlpha', 0.52, ...
        'EdgeColor', [0.20, 0.65, 0.35], 'LineWidth', 0.8);
    yline(95, ':k'); ylim([90, 96]); xlabel('Network');
    ylabel('Top-13 potency (%)'); title('B  Captured Q potency by network'); box off;
    nexttile;
    yyaxis left;
    bar(audit.controllerValidation.Network, ...
        audit.controllerValidation.EigenGap13Minus14, ...
        'FaceColor', [0.20, 0.65, 0.35], 'FaceAlpha', 0.52, ...
        'EdgeColor', [0.20, 0.65, 0.35], 'LineWidth', 0.8);
    ylabel('\lambda_{13} - \lambda_{14}');
    yyaxis right;
    plot(audit.controllerValidation.Network, audit.controllerValidation.K95, ...
        'o', 'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.4, ...
        'MarkerSize', 6, 'MarkerFaceColor', [0.35, 0.35, 0.35]);
    ylabel('Network k_{95}'); ylim([12.5, 15.5]);
    yticks(13:15); xticks(1:10);
    xlabel('Network'); title('C  Nondegenerate boundary and k_{95}'); box off;
    style_figure(output, ['Figure 1 - Stage 2B-Cerebellum: fixed top-13 Q ' ...
        'actuator; per-network geometry, not a fitted dimension']);
end

function output = performance_figure(audit, metric)
    output = base_figure(char(metric), [80, 80, 1750, 780]);
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    controllers = ["Stage 2A"; "Stage 2B-Kao"; "Stage 2B-Cerebellum"];
    colors = [0.35, 0.35, 0.35; 0.10, 0.42, 0.78; 0.20, 0.65, 0.35];
    nexttile; hold on;
    curveHandles = gobjects(3, 1);
    for index = 1:numel(controllers)
        selected = audit.performanceEnsemble.Controller == controllers(index) & ...
            audit.performanceEnsemble.Metric == metric;
        data = sortrows(audit.performanceEnsemble(selected, :), ...
            'PreparationDurationS');
        x = 1000 * data.PreparationDurationS;
        y = data.Median;
        se = data.BootstrapSE;
        fill([x; flipud(x)], [y-se; flipud(y+se)], colors(index, :), ...
            'FaceAlpha', 0.24, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        curveHandles(index) = plot(x, y, 'Color', colors(index, :), ...
            'LineWidth', 1.8);
    end
    xlabel('Preparation duration (ms)'); xlim([0, 500]); box off;
    xline(100, '--k', '100 ms', 'HandleVisibility', 'off');
    xline(200, ':k', '200 ms', 'HandleVisibility', 'off');
    set(gca, 'YScale', 'log');
    legend(curveHandles, controllers + " +/- bootstrap SE", ...
        'Location', 'southwest', 'Box', 'off');
    if metric == "EndpointErrorM"
        ylabel('Endpoint error (m)'); ylim([1e-5, 1]); xticks(0:100:500);
        title('A  Movement endpoint error after preparation');
    else
        xlabel('Preparation time (ms)'); xticks(0:50:500);
        for time = [50, 300, 500]
            xline(time, ':', 'Color', [0.75, 0.75, 0.75], ...
                'HandleVisibility', 'off');
        end
        ylabel('Normalized prospective-Q error'); ylim([1e-6, 1.05]);
        title('A  Prospective-state preparation');
    end
    nexttile; hold on;
    durations = [0.1, 0.2];
    positions = [1, 2; 4, 5; 7, 8];
    lightColors = [0.58, 0.58, 0.58; 0.38, 0.66, 0.88; 0.52, 0.77, 0.62];
    networkValues = zeros(10, 2, 3);
    if metric == "EndpointErrorM"
        baseValue = 0.03;
    else
        baseValue = 1e-5;
    end
    for durationIndex = 1:2
        for controllerIndex = 1:3
            controller = controllers(controllerIndex);
            if metric == "EndpointErrorM"
                data = audit.frozenComparison( ...
                    audit.frozenComparison.Controller == controller & ...
                    abs(audit.frozenComparison.PreparationDurationS - ...
                    durations(durationIndex)) < 1e-12, :);
                value = 1000 * data.EndpointErrorM;
                uncertainty = 1000 * data.BootstrapSE;
            else
                data = audit.performanceEnsemble( ...
                    audit.performanceEnsemble.Controller == controller & ...
                    abs(audit.performanceEnsemble.PreparationDurationS - ...
                    durations(durationIndex)) < 1e-12 & ...
                    audit.performanceEnsemble.Metric == metric, :);
                value = data.Median;
                uncertainty = data.BootstrapSE;
            end
            x = positions(controllerIndex, durationIndex);
            color = colors(controllerIndex, :);
            if durationIndex == 1
                color = lightColors(controllerIndex, :);
            end
            bar(x, value, 0.62, 'FaceColor', color, 'FaceAlpha', 0.52, ...
                'EdgeColor', color, 'LineWidth', 0.8, 'BaseValue', baseValue);
            if metric == "EndpointErrorM"
                rows = audit.performanceNetwork.Controller == controller & ...
                    abs(audit.performanceNetwork.PreparationDurationS - ...
                    durations(durationIndex)) < 1e-12;
                dataNetwork = sortrows(audit.performanceNetwork(rows, :), 'Network');
                networkValues(:, durationIndex, controllerIndex) = ...
                    1000 * dataNetwork.EndpointErrorM;
                offsets = linspace(-0.12, 0.12, height(dataNetwork)).';
                scatter(x + offsets, 1000 * dataNetwork.EndpointErrorM, ...
                    24, color, 'filled');
            end
            errorbar(x, value, uncertainty, 'k', 'LineStyle', 'none', ...
                'LineWidth', 1.4, 'CapSize', 10);
        end
    end
    if metric == "EndpointErrorM"
        for controllerIndex = 1:3
            for network = 1:10
                plot(positions(controllerIndex, :) + offsets(network), ...
                    networkValues(network, :, controllerIndex), '-', ...
                    'Color', [0.74, 0.74, 0.74], 'LineWidth', 0.65);
            end
        end
        uistack(findall(gca, 'Type', 'errorbar'), 'top');
        uistack(findall(gca, 'Type', 'scatter'), 'top');
    end
    xlim([0.45, 8.55]); xticks([1, 2, 4, 5, 7, 8]);
    xticklabels({'2A: 100','2A: 200','Kao: 100','Kao: 200','CB: 100','CB: 200'});
    xlabel('Preparation duration (ms; CB = Stage 2B-Cerebellum)');
    box off; title('B  Network median \pm 1 bootstrap SE');
    if metric == "EndpointErrorM"
        ylabel('Endpoint error (mm)'); ylim([0.03, 300]);
        figureNumber = 3;
    else
        ylabel('Normalized prospective-Q error'); ylim([1e-5, 1]);
        figureNumber = 2;
    end
    set(gca, 'YScale', 'log');
    style_figure(output, sprintf(['Figure %d - Stage 2B-Cerebellum: median ' ...
        'across 10 network-level target medians +/-1 bootstrap SE'], figureNumber));
end

function output = validation_figure(cfg, audit)
    output = base_figure('Structural and controller validation', ...
        [50, 50, 1850, 950]);
    tiledlayout(2, 3, 'TileSpacing', 'loose', 'Padding', 'compact');
    network = audit.controllerValidation.Network;
    green = [0.20, 0.65, 0.35];
    nexttile; semilogy(network, audit.controllerValidation.CareResidualRelative, ...
        'o', 'Color', green, 'MarkerFaceColor', green, 'MarkerSize', 6);
    yline(cfg.validation.careResidualTolerance, '--k', 'Tolerance');
    xlabel('Network'); ylabel('Relative CARE residual');
    title('A  Network-specific CARE verification');
    ylim([1e-14, 2e-10]); xticks(1:10); xlim([0.5, 10.5]);
    nexttile; hold on;
    plot(network, audit.controllerValidation.MaximumCareClosedLoopRealEigenvalue, ...
        'o', 'Color', green, 'MarkerFaceColor', green, 'MarkerSize', 6);
    yline(0, ':k'); xlabel('Network');
    ylabel('Maximum real part (normalized time)');
    title('B  Stabilizing CARE closed loop'); xticks(1:10); xlim([0.5, 10.5]);
    nexttile; hold on;
    plot(network, audit.controllerValidation.MaximumTargetJacobianRealEigenvalue, ...
        'd', 'Color', green, 'MarkerFaceColor', green, 'MarkerSize', 6);
    yline(0, ':k'); xlabel('Network'); ylabel('Spectral abscissa (s^{-1})');
    title('C  Worst target Jacobian in each network');
    xticks(1:10); xlim([0.5, 10.5]);
    nexttile; plot(network, ...
        audit.controllerValidation.MaximumFixedPointResidualPerS, ...
        'kd-', 'MarkerFaceColor', 'k', 'MarkerSize', 6);
    yline(cfg.validation.fixedPointTolerance, '--k', 'Tolerance');
    xlabel('Network'); ylabel('Fixed-point residual norm (s^{-1})');
    title('D  Exact target equilibria: all residuals = 0');
    ylim([-0.1, 1.2] * cfg.validation.fixedPointTolerance);
    xticks(1:10); xlim([0.5, 10.5]);
    nexttile; stem(network, ...
        audit.controllerValidation.MaximumFeedbackErrorAtTarget, ...
        'filled', 'Color', green, 'MarkerSize', 6);
    xlabel('Network'); ylabel('Feedback-error norm at r^*');
    title('E  All feedback-error terms = 0');
    ylim([-1, 1]); xticks(1:10); xlim([0.5, 10.5]);
    nexttile; axis off;
    text(0.02, 0.92, sprintf('Top-13 boundary: %d/10', ...
        sum(audit.controllerValidation.EigenBoundaryPass)), 'FontWeight', 'bold');
    text(0.02, 0.77, sprintf('Reduced-B stabilizable: %d/10', ...
        sum(audit.controllerValidation.Stabilizable)));
    text(0.02, 0.62, sprintf('CARE structural pass: %d/10', ...
        sum(audit.controllerValidation.AllStructuralChecksPass)));
    text(0.02, 0.47, sprintf('Target checks: %d/80', ...
        sum(audit.targetValidation.AllTargetChecksPass)));
    text(0.02, 0.32, sprintf('Finite saved/recovered data: %d/10', ...
        sum(audit.upstreamVerification.PreparationFinite & ...
        audit.upstreamVerification.CachedPerformanceFinite)));
    text(0.02, 0.17, sprintf('Final decision: %s', audit.acceptance.Status), ...
        'FontWeight', 'bold', 'Color', [0.10, 0.50, 0.25]);
    title('F  Accepted Gate 4B-C validation');
    style_figure(output, ['Figure 4 - Stage 2B-Cerebellum: saved controller ' ...
        'and target validation; no scientific recomputation']);
end

function output = base_figure(name, position)
    output = figure('Visible', 'off', 'Color', 'white', 'Name', name, ...
        'Position', position);
end

function style_figure(output, titleText)
    axesHandles = findall(output, 'Type', 'axes');
    set(axesHandles, 'FontName', 'Helvetica', 'FontSize', 12, ...
        'LineWidth', 0.3, 'TickDir', 'out', 'XColor', [0, 0, 0], ...
        'YColor', [0, 0, 0]);
    for index = 1:numel(axesHandles)
        grid(axesHandles(index), 'off'); box(axesHandles(index), 'off');
        for ruler = 1:numel(axesHandles(index).YAxis)
            axesHandles(index).YAxis(ruler).Color = [0, 0, 0];
        end
    end
    set(findall(output, 'Type', 'legend'), 'FontName', 'Arial', ...
        'FontSize', 8, 'Box', 'off');
    sgtitle(output, titleText, 'FontName', 'Helvetica', ...
        'FontSize', 14, 'FontWeight', 'normal');
end
