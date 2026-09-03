function inventory = create_stage2b_kao_gate3_figures(cfg, complete, figureIndices)
    plotCfg = cfg;
    plotCfg.plotsPngRoot = cfg.workPlotsPngRoot;
    plotCfg.plotsFigRoot = cfg.workPlotsFigRoot;
    names = [ ...
        "01_stage2b_controller_derivation_and_fixed_points"; ...
        "02_stage2b_cortical_preparation_go_movement_trajectories"; ...
        "03_stage2b_preparatory_error_dynamics"; ...
        "04_stage2b_reaches_by_preparation_duration"; ...
        "05_stage2b_movement_error_by_preparation_duration"; ...
        "06_stage2b_cortical_and_controller_dimensionality"; ...
        "07_stage2b_local_stability_and_finite_time_control"; ...
        "08_stage2b_prospective_potency_geometry"; ...
        "09_stage2b_prep_move_alignment_and_amplification"];
    builders = {@figure01, @figure02, @figure03, @figure04, @figure05, ...
        @figure06, @figure07, @figure08, @figure09};
    if nargin < 3
        figureIndices = 1:numel(names);
    end
    assert(all(ismember(figureIndices, 1:numel(names))));
    figureIndices = figureIndices(:);
    png = strings(numel(figureIndices), 1);
    fig = strings(numel(figureIndices), 1);
    for outputIndex = 1:numel(figureIndices)
        index = figureIndices(outputIndex);
        handle = builders{index}(cfg, complete);
        style_all_axes(handle);
        [fig(outputIndex), png(outputIndex)] = save_figure_bundle(handle, ...
            char(names(index)), plotCfg);
    end
    inventory = table(figureIndices, names(figureIndices), png, fig, ...
        'VariableNames', {'Figure','Basename','PNG','FIG'});
end

function handle = figure01(cfg, complete)
    results = complete.results;
    handle = base_figure('Controller derivation and fixed-point verification', ...
        [60, 60, 1800, 1100]);
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; axis(ax, 'off'); hold(ax, 'on');
    rectangle(ax, 'Position', [0.02, 0.68, 0.20, 0.18], ...
        'Curvature', 0.08, 'FaceColor', [0.96, 0.96, 0.96]);
    rectangle(ax, 'Position', [0.34, 0.68, 0.24, 0.18], ...
        'Curvature', 0.08, 'FaceColor', [0.96, 0.96, 0.96]);
    rectangle(ax, 'Position', [0.70, 0.68, 0.28, 0.18], ...
        'Curvature', 0.08, 'FaceColor', [0.91, 0.95, 0.99]);
    rectangle(ax, 'Position', [0.36, 0.34, 0.30, 0.17], ...
        'Curvature', 0.08, 'FaceColor', [0.91, 0.95, 0.99], ...
        'EdgeColor', [0.10, 0.42, 0.78]);
    text(ax, 0.12, 0.77, 'Target q', 'FontWeight', 'bold', 'FontSize', 12, ...
        'HorizontalAlignment', 'center');
    text(ax, 0.46, 0.77, {'Analytical tonic'; 'u_q^*'}, ...
        'FontWeight', 'bold', 'FontSize', 12, 'HorizontalAlignment', 'center');
    text(ax, 0.84, 0.77, {'Frozen cortex'; '200 rate units'}, ...
        'FontWeight', 'bold', 'FontSize', 12, 'HorizontalAlignment', 'center');
    text(ax, 0.51, 0.425, {'Full-state feedback'; 'K_j[r(t)-r_q^*]'}, ...
        'FontWeight', 'bold', 'Color', [0.10, 0.42, 0.78], ...
        'FontSize', 11, 'HorizontalAlignment', 'center');
    text(ax, 0.02, 0.16, {'PREP: tonic + feedback on'; ...
        'GO: both off; frozen movement input on'}, 'FontSize', 11);
    quiver(ax, 0.23, 0.77, 0.095, 0, 0, 'k', 'LineWidth', 1.3, ...
        'MaxHeadSize', 0.7);
    quiver(ax, 0.59, 0.77, 0.095, 0, 0, 'k', 'LineWidth', 1.3, ...
        'MaxHeadSize', 0.7);
    plot(ax, [0.84, 0.84, 0.70], [0.68, 0.57, 0.57], ...
        '-', 'Color', [0.10, 0.42, 0.78], 'LineWidth', 1.3);
    quiver(ax, 0.70, 0.57, -0.035, -0.11, 0, ...
        'Color', [0.10, 0.42, 0.78], 'LineWidth', 1.3, 'MaxHeadSize', 0.7);
    plot(ax, [0.51, 0.51, 0.70], [0.51, 0.61, 0.61], '-', ...
        'Color', [0.10, 0.42, 0.78], 'LineWidth', 1.3);
    quiver(ax, 0.70, 0.61, 0, 0.06, 0, ...
        'Color', [0.10, 0.42, 0.78], 'LineWidth', 1.3, 'MaxHeadSize', 0.7);
    xlim(ax, [0, 1]); ylim(ax, [0, 1]); title(ax, 'A  Unrestricted Kao-LQR architecture');
    ax = nexttile;
    bar(ax, [0, 200], 'FaceColor', 'flat');
    ax.Children.CData = [0.45, 0.45, 0.45; 0.10, 0.42, 0.78];
    set(ax, 'XTick', 1:2, 'XTickLabel', {'Stage 2A','Stage 2B-Kao'});
    ylabel(ax, 'Feedback input dimensions');
    title(ax, 'B  State-feedback actuator dimensionality');
    ylim(ax, [0, 220]);
    ax = nexttile;
    K = complete.representative.controllers{2}.K;
    imagesc(ax, K); axis(ax, 'tight'); colormap(ax, redblue(257));
    clim(ax, max(abs(K), [], 'all') * [-1, 1]); colorbar(ax);
    xlabel(ax, 'Cortical rate-error dimension');
    ylabel(ax, 'Feedback input dimension');
    title(ax, 'C  Representative network 1: K_1');
    ax = nexttile; hold(ax, 'on');
    semilogy(ax, results.controller.Network, ...
        results.controller.CareResidualRelative, 'o', ...
        'MarkerFaceColor', [0.10, 0.42, 0.78], 'Color', [0.10, 0.42, 0.78]);
    yline(ax, cfg.validation.careResidualTolerance, '--k', 'Tolerance');
    xlabel(ax, 'Network'); ylabel(ax, 'Relative CARE residual');
    title(ax, 'D  Network-specific CARE verification');
    ax = nexttile; hold(ax, 'on');
    for network = 1:cfg.ensemble.count
        rows = results.targetValidation.Network == network & ...
            results.targetValidation.Controller == "Stage 2B-Kao";
        scatter(ax, network * ones(nnz(rows), 1), ...
            results.targetValidation.FixedPointResidualNorm(rows), 22, ...
            [0.65, 0.75, 0.86], 'filled');
    end
    maximum = groupsummary(results.targetValidation( ...
        results.targetValidation.Controller == "Stage 2B-Kao", :), ...
        'Network', 'max', 'FixedPointResidualNorm');
    plot(ax, maximum.Network, maximum.max_FixedPointResidualNorm, 'kd-', ...
        'MarkerFaceColor', 'k');
    xlabel(ax, 'Network'); ylabel(ax, 'Fixed-point residual norm');
    title(ax, 'E  All 8 targets per network');
    ax = nexttile; hold(ax, 'on');
    values = results.controller.MaximumGainReloadDifference;
    stem(ax, results.controller.Network, values, 'filled', ...
        'Color', [0.10, 0.42, 0.78]);
    xlabel(ax, 'Network'); ylabel(ax, 'max|K_{derived}-K_{saved}|');
    title(ax, 'F  Saved-controller provenance check');
    sgtitle(handle, ['Figure 1 — independently recomputed Q_j, CARE P_j, and ' ...
        'signed K_j for all 10 frozen networks']);
end

function handle = figure02(cfg, complete)
    representative = complete.representative;
    model = representative.model;
    preparation = representative.preparations{2};
    movement = representative.movements{2};
    prepIndices = 1:10:size(preparation.states, 1);
    moveIndices = 1:10:min(501, size(movement.rates, 1));
    prepRaw = permute(max(preparation.states(prepIndices, :, :), 0), [1, 3, 2]);
    moveRaw = permute(movement.rates(moveIndices, :, :), [1, 3, 2]);
    flat = reshape(cat(1, prepRaw, moveRaw), [], model.n);
    scale = max(std(flat, 0, 1), 1);
    prepProcessed = prepRaw ./ reshape(scale, 1, 1, []);
    moveProcessed = moveRaw ./ reshape(scale, 1, 1, []);
    prepProcessed = prepProcessed - mean(prepProcessed, 2);
    moveProcessed = moveProcessed - mean(moveProcessed, 2);
    observations = [reshape(prepProcessed, [], model.n); ...
        reshape(moveProcessed, [], model.n)];
    [~, ~, V] = svd(observations - mean(observations, 1), 'econ');
    prepScores = reshape(reshape(prepProcessed, [], model.n) * V(:, 1:3), ...
        numel(prepIndices), model.nMovements, 3);
    moveScores = reshape(reshape(moveProcessed, [], model.n) * V(:, 1:3), ...
        numel(moveIndices), model.nMovements, 3);
    handle = base_figure('Representative cortical trajectories', ...
        [80, 80, 1750, 780]);
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on'); view(ax, 3);
    for target = 1:model.nMovements
        color = cfg.plot.colors(target, :);
        plot3(ax, prepScores(:, target, 1), prepScores(:, target, 2), ...
            prepScores(:, target, 3), '--', 'Color', color, 'LineWidth', 1.4);
        scatter3(ax, prepScores(end, target, 1), prepScores(end, target, 2), ...
            prepScores(end, target, 3), 42, color, 'filled');
        plot3(ax, moveScores(:, target, 1), moveScores(:, target, 2), ...
            moveScores(:, target, 3), '-', 'Color', color, 'LineWidth', 1.6);
    end
    xlabel(ax, 'PC1'); ylabel(ax, 'PC2'); zlabel(ax, 'PC3');
    title(ax, 'A  Representative network 1');
    ax = nexttile; hold(ax, 'on');
    for target = 1:model.nMovements
        color = cfg.plot.colors(target, :);
        plot(ax, prepScores(:, target, 1), prepScores(:, target, 2), '--', ...
            'Color', color, 'LineWidth', 1.4);
        scatter(ax, prepScores(end, target, 1), prepScores(end, target, 2), ...
            42, color, 'filled');
        plot(ax, moveScores(:, target, 1), moveScores(:, target, 2), '-', ...
            'Color', color, 'LineWidth', 1.6);
    end
    xlabel(ax, 'PC1'); ylabel(ax, 'PC2'); axis(ax, 'equal');
    title(ax, 'B  Dashed: preparation; circle: GO; solid: movement');
    sgtitle(handle, ['Figure 2 — deterministic target trajectories; SD-floor-1 ' ...
        'normalization and time-specific target centering']);
end

function handle = figure03(~, complete)
    handle = base_figure('Preparatory error dynamics', [80, 80, 1750, 780]);
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    metrics = ["StateErrorFraction", "ProspectiveErrorFraction"];
    labels = {'Normalized full-state error','Normalized prospective-Q error'};
    controllers = ["Stage 2A", "Stage 2B-Kao"];
    colors = [0.35, 0.35, 0.35; 0.10, 0.42, 0.78];
    for metricIndex = 1:2
        ax = nexttile; hold(ax, 'on');
        for controllerIndex = 1:2
            data = ensemble_rows(complete.ensemble.errorTimecourse, ...
                controllers(controllerIndex), metrics(metricIndex));
            shaded(ax, 1000 * data.PreparationTimeS, data.Median, ...
                data.BootstrapSE, colors(controllerIndex, :));
        end
        for time = [50, 100, 200, 300, 500]
            xline(ax, time, ':', 'Color', [0.75, 0.75, 0.75]);
        end
        set(ax, 'YScale', 'log'); xlabel(ax, 'Preparation time (ms)');
        ylabel(ax, labels{metricIndex});
        title(ax, char('A' + metricIndex - 1));
        if metricIndex == 1
            legend(ax, {'Stage 2A ± bootstrap SE','Stage 2B-Kao ± bootstrap SE'}, ...
                'Location', 'southwest'); legend boxoff;
        end
    end
    sgtitle(handle, ['Figure 3 — median across 10 network-level target medians ' ...
        '±1 bootstrap SE (10,000 network resamples)']);
end

function handle = figure04(cfg, complete)
    representative = complete.representative;
    durations = cfg.analysis.representativeDurationsS;
    handle = base_figure('Representative reaches by preparation duration', ...
        [40, 40, 2300, 1050]);
    tiledlayout(2, numel(durations), 'TileSpacing', 'compact', 'Padding', 'compact');
    for controllerIndex = 1:2
        reach = representative.reaches(controllerIndex);
        for durationIndex = 1:numel(durations)
            ax = nexttile; hold(ax, 'on');
            for target = 1:representative.model.nMovements
                plot(ax, representative.ideal.hand(:, 1, target), ...
                    representative.ideal.hand(:, 3, target), '--', ...
                    'Color', [0.72, 0.72, 0.72], 'LineWidth', 0.8);
                plot(ax, reach.hand(:, 1, target, durationIndex), ...
                    reach.hand(:, 2, target, durationIndex), '-', ...
                    'Color', cfg.plot.colors(target, :), 'LineWidth', 1.3);
            end
            axis(ax, 'equal'); xlim(ax, [-0.30, 0.30]); ylim(ax, [-0.12, 0.52]);
            if controllerIndex == 1
                title(ax, sprintf('%d ms', round(1000 * durations(durationIndex))));
            end
            if durationIndex == 1
                ylabel(ax, sprintf('%s\nHand y (m)', ...
                    char(reach.controller)));
            end
            if controllerIndex == 2
                xlabel(ax, 'Hand x (m)');
            end
        end
    end
    sgtitle(handle, ['Figure 4 — representative network 1; dashed target and ' ...
        'solid generated 10-cm reaches']);
end

function handle = figure05(~, complete)
    handle = base_figure('Dense movement-quality diagnostic', [50, 50, 1850, 1050]);
    tiledlayout(2, 3, 'TileSpacing', 'loose', 'Padding', 'compact');
    metrics = ["StateErrorFraction", "ProspectiveErrorFraction", ...
        "EndpointErrorM", "HandTrajectoryNRMSE", "TorqueNRMSE"];
    labels = {'GO full-state error','GO prospective-Q error', ...
        'Endpoint error (m)','Hand-trajectory NRMSE','Torque NRMSE'};
    controllers = ["Stage 2A", "Stage 2B-Kao"];
    colors = [0.35, 0.35, 0.35; 0.10, 0.42, 0.78];
    for metricIndex = 1:numel(metrics)
        ax = nexttile; hold(ax, 'on');
        for controllerIndex = 1:2
            data = ensemble_rows(complete.ensemble.movement, ...
                controllers(controllerIndex), metrics(metricIndex));
            shaded(ax, 1000 * data.PreparationDurationS, data.Median, ...
                data.BootstrapSE, colors(controllerIndex, :));
        end
        xline(ax, 100, '--k', '100 ms'); xline(ax, 200, ':k', '200 ms');
        set(ax, 'YScale', 'log'); xlabel(ax, 'Preparation duration (ms)');
        ylabel(ax, labels{metricIndex}); title(ax, char('A' + metricIndex - 1));
        if metricIndex == 1
            legend(ax, {'Stage 2A ± bootstrap SE','Stage 2B-Kao ± bootstrap SE'}, ...
                'Location', 'southwest'); legend boxoff;
        end
    end
    ax = nexttile; hold(ax, 'on');
    comparison = complete.ensemble.movement100vs200;
    stage2aRows = complete.results.movement.Controller == "Stage 2A" & ...
        ismember(complete.results.movement.PreparationDurationS, [0.1, 0.2]);
    stage2a = complete.results.movement(stage2aRows, :);
    stage2aEndpoint = groupsummary(stage2a, ...
        {'Network','PreparationDurationS'}, 'median', 'EndpointErrorM');
    stage2aWide = unstack(stage2aEndpoint, 'median_EndpointErrorM', ...
        'PreparationDurationS');
    stage2aChange = stage2aWide.x0_2 - stage2aWide.x0_1;
    endpointSummary = complete.ensemble.movement( ...
        complete.ensemble.movement.Metric == "EndpointErrorM" & ...
        ismember(complete.ensemble.movement.PreparationDurationS, [0.1, 0.2]), :);
    values = 1000 * [stage2aWide.x0_1, stage2aWide.x0_2, ...
        comparison.Endpoint100ms, comparison.Endpoint200ms];
    medians = zeros(1, 4); errors = zeros(1, 4);
    summaryControllers = ["Stage 2A", "Stage 2A", ...
        "Stage 2B-Kao", "Stage 2B-Kao"];
    summaryDurations = [0.1, 0.2, 0.1, 0.2];
    for index = 1:4
        row = endpointSummary.Controller == summaryControllers(index) & ...
            endpointSummary.PreparationDurationS == summaryDurations(index);
        medians(index) = 1000 * endpointSummary.Median(row);
        errors(index) = 1000 * endpointSummary.BootstrapSE(row);
    end
    positions = [1, 2, 4, 5];
    colors = [0.58, 0.58, 0.58; 0.35, 0.35, 0.35; ...
        0.38, 0.66, 0.88; 0.10, 0.42, 0.78];
    bars = bar_summary_panel(ax, positions, medians, errors, values, colors, ...
        {'2A: 100','2A: 200','Kao: 100','Kao: 200'}, [1, 2; 3, 4]);
    set(bars, 'BaseValue', 0.03);
    set(ax, 'YScale', 'log'); ylim(ax, [0.03, 300]);
    ylabel(ax, 'Endpoint error (mm)');
    title(ax, sprintf(['F  100-to-200 ms: 2A improves %d/10; ' ...
        'Kao improves %d/10'], sum(stage2aChange < 0), ...
        sum(comparison.Endpoint200Minus100 < 0)));
    sgtitle(handle, ['Figure 5 — dense 0:10:500-ms diagnostic; network is the ' ...
        'independent unit']);
end

function handle = figure06(cfg, complete)
    results = complete.results;
    handle = base_figure('Cortical and controller dimensionality', ...
        [50, 50, 1850, 1050]);
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    summaryK = bootstrap_network_median(results.inputDimension.K95, ...
        cfg.ensemble.bootstrapSamples, cfg.ensemble.bootstrapSeed + 12001);
    bar_summary_panel(ax, 1, summaryK.median, summaryK.standardError, ...
        results.inputDimension.K95, [0.10, 0.42, 0.78], {'Median'}, []);
    ylabel(ax, 'Dimensions');
    title(ax, 'A  Feedback-input k_{95} (200 native units)');
    ax = nexttile; hold(ax, 'on');
    summaryPr = bootstrap_network_median( ...
        results.inputDimension.ParticipationRatio, ...
        cfg.ensemble.bootstrapSamples, cfg.ensemble.bootstrapSeed + 12002);
    bar_summary_panel(ax, 1, summaryPr.median, summaryPr.standardError, ...
        results.inputDimension.ParticipationRatio, [0.10, 0.42, 0.78], ...
        {'Median'}, []);
    ylabel(ax, 'Participation ratio'); title(ax, 'B  State-feedback input only');
    ax = nexttile; hold(ax, 'on');
    data = complete.ensemble.inputTimecourse;
    rows = data.Metric == "TargetMedianFeedbackNorm";
    shaded(ax, 1000 * data.PreparationTimeS(rows), data.Median(rows), ...
        data.BootstrapSE(rows), [0.10, 0.42, 0.78]);
    xlabel(ax, 'Preparation time (ms)'); ylabel(ax, 'Feedback-input norm');
    title(ax, 'C  Median across networks ± bootstrap SE');
    ax = nexttile; paired_pr_panel(ax, cfg, results, "Preparation", ...
        complete.results.prStatistics, 'D  Cortical preparation PR');
    ax = nexttile; paired_pr_panel(ax, cfg, results, "Movement", ...
        complete.results.prStatistics, 'E  Cortical movement PR');
    ax = nexttile; hold(ax, 'on');
    networkEffort = groupsummary(results.effort, 'Network', 'median', ...
        'LambdaWeightedFeedbackEffort');
    summaryEffort = bootstrap_network_median( ...
        networkEffort.median_LambdaWeightedFeedbackEffort, ...
        cfg.ensemble.bootstrapSamples, cfg.ensemble.bootstrapSeed + 12003);
    bar_summary_panel(ax, 1, summaryEffort.median, ...
        summaryEffort.standardError, ...
        networkEffort.median_LambdaWeightedFeedbackEffort, ...
        [0.10, 0.42, 0.78], {'Median'}, []);
    ylabel(ax, '\lambda-weighted feedback effort');
    title(ax, 'F  0–500 ms integrated effort');
    sgtitle(handle, ['Figure 6 — 10-ms temporal subsampling; no total-' ...
        'preparatory-input PR']);
end

function handle = figure07(cfg, complete)
    handle = base_figure('Local stability and finite-time control', ...
        [50, 50, 1850, 1050]);
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    controllers = ["Stage 2A", "Stage 2B-Kao"];
    colors = [0.35, 0.35, 0.35; 0.10, 0.42, 0.78];
    scalarMetrics = ["SpectralAbscissaPerS", ...
        "WorstInstantaneousProspectiveRatePerS", ...
        "WorstInstantaneousEuclideanRatePerS"];
    scalarLabels = {'Spectral abscissa (s^{-1})', ...
        'Worst instantaneous Q rate (s^{-1})', ...
        'Worst instantaneous Euclidean rate (s^{-1})'};
    for metricIndex = 1:3
        ax = nexttile; hold(ax, 'on');
        medians = zeros(1, 2);
        errors = zeros(1, 2);
        for controllerIndex = 1:2
            data = complete.ensemble.local( ...
                complete.ensemble.local.Controller == controllers(controllerIndex) & ...
                complete.ensemble.local.Metric == scalarMetrics(metricIndex), :);
            medians(controllerIndex) = data.Median;
            errors(controllerIndex) = data.BootstrapSE;
        end
        networkValues = target_medians_by_network(complete.results.local, ...
            scalarMetrics(metricIndex), controllers);
        bar_summary_panel(ax, 1:2, medians, errors, networkValues, colors, ...
            {'Stage 2A','Stage 2B-Kao'}, [1, 2]);
        yline(ax, 0, ':k'); set(ax, 'XTick', 1:2, ...
            'XTickLabel', {'Stage 2A','Stage 2B-Kao'});
        ylabel(ax, scalarLabels{metricIndex}); title(ax, char('A' + metricIndex - 1));
    end
    finiteMetrics = ["WorstQ95Gain", "WorstEuclideanGain"];
    finiteLabels = {'Worst finite-time Q_{95} gain', ...
        'Worst finite-time Euclidean gain'};
    for metricIndex = 1:2
        ax = nexttile; hold(ax, 'on');
        for controllerIndex = 1:2
            data = complete.ensemble.finiteTime( ...
                complete.ensemble.finiteTime.Controller == controllers(controllerIndex) & ...
                complete.ensemble.finiteTime.Metric == finiteMetrics(metricIndex), :);
            errorbar(ax, 1000 * data.TimeS, data.Median, data.BootstrapSE, 'o-', ...
                'Color', colors(controllerIndex, :), ...
                'MarkerFaceColor', colors(controllerIndex, :), 'LineWidth', 1.4);
        end
        yline(ax, 1, ':k'); xlabel(ax, 'Time (ms)');
        ylabel(ax, finiteLabels{metricIndex}); title(ax, char('D' + metricIndex - 1));
        if metricIndex == 1
            legend(ax, {'Stage 2A','Stage 2B-Kao'}, 'Location', 'best'); legend boxoff;
        end
    end
    ax = nexttile; hold(ax, 'on');
    qDimensions = complete.results.local.Q95Dimensions( ...
        complete.results.local.Controller == "Stage 2B-Kao");
    qDimensions = qDimensions(1:8:end);
    summaryQ = bootstrap_network_median(qDimensions, ...
        cfg.ensemble.bootstrapSamples, cfg.ensemble.bootstrapSeed + 12004);
    bar_summary_panel(ax, 1, summaryQ.median, summaryQ.standardError, ...
        qDimensions, [0.10, 0.42, 0.78], {'Median'}, []);
    ylabel(ax, 'Leading Q directions');
    title(ax, 'F  Network-specific Q_{95} dimension');
    sgtitle(handle, ['Figure 7 — all targets contribute within each network; ' ...
        'median across 10 networks ± bootstrap SE']);
end

function handle = figure08(cfg, complete)
    representative = complete.representative;
    flow = representative.flow;
    results = complete.results;
    handle = base_figure('Prospective-potency geometry', [40, 40, 1900, 1100]);
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    allGamma = [flow.grid.NonlinearGammaQPerS; flow.grid.LinearizedGammaQPerS];
    limit = prctile(abs(allGamma(isfinite(allGamma))), 98);
    for controllerIndex = 1:2
        ax = nexttile; rows = flow.grid.Controller == ...
            string(representative.controllers{controllerIndex}.name);
        plot_flow(ax, flow.grid(rows, :), cfg.analysis.flowGridPoints, ...
            limit, false);
        title(ax, sprintf('%c  %s nonlinear field', ...
            'A' + controllerIndex - 1, ...
            representative.controllers{controllerIndex}.name));
        trajectories = flow.trajectories{controllerIndex};
        [vectors, values] = eig(representative.controllers{1}.Q, 'vector');
        [~, order] = sort(real(values), 'descend');
        U = real(vectors(:, order(1:2)));
        for trial = 1:size(trajectories, 3)
            delta = squeeze(trajectories(:, :, trial)) - ...
                representative.model.xstar(:, flow.target).';
            projected = delta * U;
            plot(ax, projected(:, 1), projected(:, 2), '-', ...
                'Color', [0.05, 0.05, 0.05], 'LineWidth', 0.9);
            scatter(ax, projected(1, 1), projected(1, 2), 18, 'k', 'filled');
        end
    end
    ax = nexttile;
    rows = flow.grid.Controller == "Stage 2B-Kao";
    plot_flow(ax, flow.grid(rows, :), cfg.analysis.flowGridPoints, limit, true);
    title(ax, 'C  Exact-Jacobian linearized field');
    ax = nexttile; hold(ax, 'on');
    valid = rows & ~flow.grid.MaskedNearOrigin;
    scatter(ax, flow.grid.LinearizedGammaQPerS(valid), ...
        flow.grid.NonlinearGammaQPerS(valid), 18, ...
        flow.grid.OutOfPlaneVelocityFraction(valid), 'filled');
    identity_limits(ax); colorbar(ax); xlabel(ax, 'Linearized \gamma_Q (s^{-1})');
    ylabel(ax, 'Nonlinear \gamma_Q (s^{-1})');
    title(ax, 'D  Representative target: color = out-of-plane fraction');
    ax = nexttile; hold(ax, 'on');
    for controllerIndex = 1:2
        name = string(representative.controllers{controllerIndex}.name);
        cloud = results.cloud(results.cloud.Controller == name, :);
        scatter(ax, max(cloud.LinearizedProspectiveFraction, realmin), ...
            max(cloud.NonlinearProspectiveFraction, realmin), 8, ...
            'MarkerEdgeColor', controller_color(controllerIndex), ...
            'MarkerEdgeAlpha', 0.25);
    end
    set(ax, 'XScale', 'log', 'YScale', 'log'); identity_limits(ax);
    xlabel(ax, 'Linearized 300-ms Q fraction');
    ylabel(ax, 'Nonlinear 300-ms Q fraction');
    title(ax, 'E  Full-200-D clouds: all networks and targets');
    ax = nexttile; hold(ax, 'on');
    selection = flow.selection;
    bar(ax, selection.Target, selection.StandardizedMedianDistance, ...
        'FaceColor', [0.72, 0.78, 0.85]);
    scatter(ax, selection.Target(selection.Selected), ...
        selection.StandardizedMedianDistance(selection.Selected), 80, ...
        [0.10, 0.42, 0.78], 'filled');
    xlabel(ax, 'Network-1 target'); ylabel(ax, 'Distance from median profile');
    title(ax, {sprintf('F  Predetermined representative: target %d', ...
        flow.target); 'Q_1,Q_2 are potency directions, not PCs'});
    colormap(handle, redblue(257));
    sgtitle(handle, ['Figure 8 — nonlinear/Jacobian prospective-potency ' ...
        'diagnostic; quantitative cloud pooling remains 200-D']);
end

function handle = figure09(cfg, complete)
    results = complete.results;
    handle = base_figure('Alignment and movement amplification', ...
        [60, 60, 1750, 1050]);
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for network = 1:cfg.ensemble.count
        row = results.alignment.Network == network;
        errorbar(ax, results.alignment.ObservedAlignment(row), ...
            results.alignment.NullMedian(row), results.alignment.NullSD(row), ...
            'o', 'Color', [0.10, 0.42, 0.78], ...
            'MarkerFaceColor', [0.10, 0.42, 0.78], 'LineWidth', 1.1);
        text(ax, results.alignment.ObservedAlignment(row), ...
            results.alignment.NullMedian(row), sprintf('  N%d', network), ...
            'FontSize', 9);
    end
    identity_limits(ax); xlabel(ax, 'Observed alignment');
    ylabel(ax, 'Expected alignment (null median ± raw SD)');
    title(ax, 'A  Independent 10,000-draw null per network');
    ax = nexttile; hold(ax, 'on');
    semilogy(ax, results.alignment.Network, ...
        results.alignment.FiniteCorrectedLowerTailP, 'o-', ...
        'Color', [0.55, 0.55, 0.55], 'MarkerFaceColor', [0.75, 0.75, 0.75]);
    semilogy(ax, results.alignment.Network, ...
        results.alignment.BhAdjustedLowerTailP, 'd-', ...
        'Color', [0.10, 0.42, 0.78], 'MarkerFaceColor', [0.10, 0.42, 0.78]);
    yline(ax, 0.05, '--k'); xlabel(ax, 'Network'); ylabel(ax, 'Lower-tail p');
    set(ax, 'YScale', 'log');
    ylim(ax, [1 / (cfg.analysis.randomSubspaceDraws + 1), 0.06]);
    legend(ax, {'Finite-corrected raw p','BH-adjusted p'}, 'Location', 'best');
    legend boxoff; title(ax, 'B  BH correction across 10 network null tests');
    ax = nexttile; hold(ax, 'on');
    data = complete.ensemble.amplification;
    rows = data.Metric == "NormalizedAmplification";
    shaded(ax, 1000 * data.TimeFromModelMovementOnsetS(rows), ...
        data.Median(rows), data.BootstrapSE(rows), [0.10, 0.42, 0.78]);
    yline(ax, 1, ':k'); xline(ax, 0, ':k');
    xlabel(ax, 'Time from model movement onset (ms)');
    ylabel(ax, 'Amplification factor');
    title(ax, 'C  Kao Figure-6D definition; h(t)=0; reference = 1');
    ax = nexttile; hold(ax, 'on');
    summary = complete.ensemble.alignment;
    bar_summary_panel(ax, 1:2, summary.Median.', summary.BootstrapSE.', ...
        [results.alignment.ObservedAlignment, results.alignment.NullMedian], ...
        [0.10, 0.42, 0.78; 0.65, 0.75, 0.86], ...
        {'Observed','Network null median'}, [1, 2]);
    ylabel(ax, 'Alignment index');
    title(ax, 'D  Descriptive ensemble median ± bootstrap SE');
    sgtitle(handle, ['Figure 9 — project K_{95}; 30 prep and 30 movement ' ...
        'samples per network; no pooled null distributions']);
end

function paired_pr_panel(ax, ~, results, epoch, statistics, titleText)
    hold(ax, 'on');
    stage2a = results.corticalDimensionality.ParticipationRatio( ...
        results.corticalDimensionality.Epoch == epoch & ...
        results.corticalDimensionality.Controller == "Stage 2A");
    kao = results.corticalDimensionality.ParticipationRatio( ...
        results.corticalDimensionality.Epoch == epoch & ...
        results.corticalDimensionality.Controller == "Stage 2B-Kao");
    row = statistics.Epoch == epoch;
    bar_summary_panel(ax, 1:2, ...
        [statistics.Stage2aMedian(row), statistics.Stage2bKaoMedian(row)], ...
        [statistics.Stage2aBootstrapSE(row), ...
        statistics.Stage2bKaoBootstrapSE(row)], [stage2a, kao], ...
        [0.35, 0.35, 0.35; 0.10, 0.42, 0.78], ...
        {'Stage 2A','Stage 2B-Kao'}, [1, 2]);
    ylabel(ax, 'Participation ratio');
    title(ax, sprintf('%s; Wilcoxon BH-p=%.3g', titleText, ...
        statistics.BhAdjustedP(row)));
end

function values = target_medians_by_network(data, metric, controllers)
    networks = unique(data.Network);
    values = nan(numel(networks), numel(controllers));
    for controllerIndex = 1:numel(controllers)
        rows = data.Controller == controllers(controllerIndex);
        grouped = groupsummary(data(rows, :), 'Network', 'median', char(metric));
        assert(isequal(grouped.Network, networks));
        values(:, controllerIndex) = grouped.(['median_' char(metric)]);
    end
end

function bars = bar_summary_panel(ax, positions, medians, errors, values, ...
        colors, labels, pairs)
    hold(ax, 'on');
    positions = positions(:).'; medians = medians(:).'; errors = errors(:).';
    if isvector(values)
        values = values(:);
    end
    bars = gobjects(numel(positions), 1);
    for group = 1:numel(positions)
        bars(group) = bar(ax, positions(group), medians(group), 0.62, ...
            'FaceColor', colors(group, :), 'FaceAlpha', 0.52, ...
            'EdgeColor', colors(group, :), 'LineWidth', 0.8);
    end
    offsets = linspace(-0.12, 0.12, size(values, 1)).';
    for pairIndex = 1:size(pairs, 1)
        pair = pairs(pairIndex, :);
        for network = 1:size(values, 1)
            plot(ax, positions(pair) + offsets(network), ...
                values(network, pair), '-', 'Color', [0.74, 0.74, 0.74], ...
                'LineWidth', 0.65);
        end
    end
    for group = 1:numel(positions)
        scatter(ax, positions(group) + offsets, values(:, group), 24, ...
            colors(group, :), 'filled');
        errorbar(ax, positions(group), medians(group), errors(group), 'k', ...
            'LineStyle', 'none', 'LineWidth', 1.4, 'CapSize', 10);
    end
    set(ax, 'XTick', positions, 'XTickLabel', labels);
    xlim(ax, [min(positions) - 0.55, max(positions) + 0.55]);
end

function data = ensemble_rows(tableData, controller, metric)
    data = tableData(tableData.Controller == controller & ...
        tableData.Metric == metric, :);
end

function shaded(ax, x, center, error, color)
    fill(ax, [x; flipud(x)], [center - error; flipud(center + error)], ...
        color, 'FaceAlpha', 0.24, 'EdgeColor', 'none');
    plot(ax, x, center, '-', 'Color', color, 'LineWidth', 1.8);
end

function plot_flow(ax, data, gridPoints, limit, linearized)
    X = reshape(data.Q1, gridPoints, gridPoints);
    Y = reshape(data.Q2, gridPoints, gridPoints);
    if linearized
        Z = reshape(data.LinearizedGammaQPerS, gridPoints, gridPoints);
        U = reshape(data.LinearizedVelocityQ1, gridPoints, gridPoints);
        V = reshape(data.LinearizedVelocityQ2, gridPoints, gridPoints);
    else
        Z = reshape(data.NonlinearGammaQPerS, gridPoints, gridPoints);
        U = reshape(data.NonlinearVelocityQ1, gridPoints, gridPoints);
        V = reshape(data.NonlinearVelocityQ2, gridPoints, gridPoints);
    end
    surf(ax, X, Y, zeros(size(Z)), Z, 'EdgeColor', 'none');
    view(ax, 2); hold(ax, 'on');
    speed = hypot(U, V);
    gridStep = median(diff(unique(X(:))));
    U = 0.72 * gridStep * U ./ max(speed, eps);
    V = 0.72 * gridStep * V ./ max(speed, eps);
    U(speed <= eps) = 0;
    V(speed <= eps) = 0;
    quiver(ax, X, Y, U, V, 0, 'k', 'LineWidth', 0.55, ...
        'MaxHeadSize', 0.65);
    scatter(ax, 0, 0, 100, 'kp', 'filled'); axis(ax, 'equal');
    padding = 0.08 * max(X(:) - min(X(:)));
    xlim(ax, [min(X(:)) - padding, max(X(:)) + padding]);
    ylim(ax, [min(Y(:)) - padding, max(Y(:)) + padding]);
    clim(ax, [-limit, limit]); xlabel(ax, 'Q_1 displacement');
    ylabel(ax, 'Q_2 displacement');
end

function identity_limits(ax)
    limits = [min([xlim(ax), ylim(ax)]), max([xlim(ax), ylim(ax)])];
    xlim(ax, limits); ylim(ax, limits); plot(ax, limits, limits, '--k');
end

function color = controller_color(index)
    palette = [0.35, 0.35, 0.35; 0.10, 0.42, 0.78];
    color = palette(index, :);
end

function handle = base_figure(name, position)
    handle = figure('Visible', 'off', 'Color', 'white', 'Name', name, ...
        'Position', position);
end

function style_all_axes(handle)
    axesHandles = findall(handle, 'Type', 'axes');
    for index = 1:numel(axesHandles)
        ax = axesHandles(index);
        if strcmp(ax.Visible, 'off')
            continue;
        end
        set(ax, 'FontSize', 12, 'TickDir', 'out', 'LineWidth', 0.3, ...
            'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);
        grid(ax, 'off'); box(ax, 'off');
    end
    legendHandles = findall(handle, 'Type', 'legend');
    for index = 1:numel(legendHandles)
        set(legendHandles(index), 'FontName', 'Arial', 'FontSize', 8, ...
            'Box', 'off');
    end
end

function map = redblue(count)
    half = floor(count / 2);
    blue = [linspace(0.10, 1, half).', linspace(0.25, 1, half).', ...
        ones(half, 1)];
    red = [ones(count - half, 1), linspace(1, 0.20, count - half).', ...
        linspace(1, 0.15, count - half).'];
    map = [blue; red];
end
