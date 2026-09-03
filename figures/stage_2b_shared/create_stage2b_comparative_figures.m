function inventory = create_stage2b_comparative_figures(cfgKao, cfgCerebellum, model, results, indices)
    if nargin < 5
        indices = 1:10;
    end
    names = {
        '01_stage2b_controller_derivation_and_fixed_points'; ...
        '02_stage2b_cortical_preparation_go_movement_trajectories'; ...
        '03_stage2b_preparatory_error_dynamics'; ...
        '04_stage2b_reaches_by_preparation_duration'; ...
        '05_stage2b_movement_error_by_preparation_duration'; ...
        '06_stage2b_control_input_dynamics_and_effort'; ...
        '07_stage2b_local_stability_and_finite_time_control'; ...
        '08_stage2b_nonlinear_perturbation_recovery_and_flow'; ...
        '09_stage2b_prep_move_alignment_and_null_distribution'; ...
        '10_stage2b_movement_amplification_and_prep_move_rotation'};
    builders = {@figure01, @figure02, @figure03, @figure04, @figure05, ...
        @figure06, @figure07, @figure08, @figure09, @figure10};
    inventory = strings(numel(indices), 5);
    for outputIndex = 1:numel(indices)
        index = indices(outputIndex);
        figureHandle = builders{index}(cfgCerebellum, model, results);
        [kaoFig, kaoPng, cerebellumFig, cerebellumPng] = ...
            save_mirrored(figureHandle, names{index}, cfgKao, cfgCerebellum);
        inventory(outputIndex, :) = [string(names{index}), string(kaoFig), ...
            string(kaoPng), string(cerebellumFig), string(cerebellumPng)];
    end
end

function figureHandle = figure01(~, ~, results)
    colors = controller_colors();
    figureHandle = base_figure('Controller derivation and fixed points');
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    nexttile;
    bar([0, results.controllers{2}.inputDimension, ...
        results.controllers{3}.inputDimension], 'FaceColor', 'flat', ...
        'CData', colors);
    set(gca, 'XTick', 1:3, 'XTickLabel', short_names());
    ylabel('Control dimensions'); title('Fixed actuator size'); style(gca);
    nexttile;
    values = results.controllers{3}.qEigenvalues;
    plot(1:numel(values), cumsum(values) / sum(values), 'k-', 'LineWidth', 1.5);
    hold on; xline(13, '--', 'k=13'); yline(results.controllers{3}.potencyFraction, ':');
    xlabel('Q eigenvector rank'); ylabel('Cumulative potency'); ylim([0, 1.02]);
    title(sprintf('Top 13 capture %.2f%%', 100 * results.controllers{3}.potencyFraction)); style(gca);
    nexttile;
    imagesc(results.controllers{2}.K); axis tight; colorbar;
    xlabel('Cortical state'); ylabel('Control channel'); title('Kao K (200 x 200)'); style(gca);
    nexttile;
    imagesc(results.controllers{3}.K); axis tight; colorbar;
    xlabel('Cortical state'); ylabel('Control channel'); title('Cerebellum K (13 x 200)'); style(gca);
    nexttile;
    values = results.validation.MaximumFixedPointResidual;
    semilogy(1:3, max(values, 1e-16), 'ko-', 'LineWidth', 1.2, ...
        'MarkerFaceColor', 'k');
    set(gca, 'XTick', 1:3, 'XTickLabel', short_names()); ylabel('Residual norm');
    ylim([5e-17, 5e-14]);
    title('Eight targets remain fixed points'); style(gca);
    nexttile;
    hold on;
    for index = 2:3
        eigenvalues = results.controllers{index}.closedLoopEigenvalues;
        scatter(real(eigenvalues), imag(eigenvalues), 10, colors(index, :), 'filled');
    end
    xline(0, ':k'); xlabel('Real eigenvalue'); ylabel('Imaginary eigenvalue');
    title('CARE closed-loop spectra'); legend({'Kao','Cerebellum'}, 'Location', 'best');
    legend boxoff; style(gca);
end

function figureHandle = figure02(~, model, results)
    colors = lines(model.nMovements);
    figureHandle = base_figure('Cortical preparation, GO, and movement trajectories');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    for controllerIndex = 1:3
        ax = nexttile; hold(ax, 'on');
        prep = results.preparations{controllerIndex};
        limit = round(0.5 / model.samplingDt) + 1;
        goStates = squeeze(prep.states(limit, :, :));
        movement = simulate_published_cortex(model, goStates, true);
        prepRates = max(prep.states(1:limit, :, :), 0);
        allRates = [reshape(permute(prepRates, [2, 1, 3]), model.n, []), ...
            reshape(permute(movement.rates(1:301, :, :), [2, 1, 3]), model.n, [])];
        allRates = allRates - mean(allRates, 2);
        [U, ~, ~] = svd(allRates, 'econ'); U = U(:, 1:2);
        for target = 1:model.nMovements
            p = squeeze(prepRates(:, :, target)) * U;
            m = squeeze(movement.rates(1:301, :, target)) * U;
            plot(ax, p(:, 1), p(:, 2), '--', 'Color', colors(target, :), 'LineWidth', 1);
            scatter(ax, p(end, 1), p(end, 2), 28, colors(target, :), 'filled');
            plot(ax, m(:, 1), m(:, 2), '-', 'Color', colors(target, :), 'LineWidth', 1.3);
        end
        xlabel(ax, 'PC 1'); ylabel(ax, 'PC 2'); title(ax, results.controllers{controllerIndex}.name);
        axis(ax, 'equal'); style(ax);
    end
    sgtitle('Dashed: preparation; filled circle: GO; solid: movement');
end

function figureHandle = figure03(~, model, results)
    colors = controller_colors();
    figureHandle = base_figure('Preparatory error dynamics');
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for index = 1:3
        fraction = prospective_fraction(results.preparations{index}, model, results.controllers{1}.Q);
        semilogy(ax, results.preparations{index}.timesS, mean(fraction, 2), ...
            'Color', colors(index, :), 'LineWidth', 1.7);
    end
    xlim(ax, [0, 0.5]); ylim(ax, [1e-8, 2]); xlabel(ax, 'Preparation time (s)');
    ylabel(ax, 'Prospective error fraction'); title(ax, 'Mean across targets');
    legend(ax, short_names(), 'Location', 'southwest'); legend boxoff; style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:3
        prep = results.preparations{index};
        delta = squeeze(prep.states(:, :, 1)) - model.xstar(:, 1).';
        plot(ax, prep.timesS, vecnorm(delta, 2, 2) / norm(delta(1, :)), ...
            'Color', colors(index, :), 'LineWidth', 1.7);
    end
    xlim(ax, [0, 0.5]); xlabel(ax, 'Preparation time (s)'); ylabel(ax, 'Euclidean state fraction');
    title(ax, 'Target 1 state distance'); style(ax);
end

function figureHandle = figure04(~, model, results)
    durations = [0, 0.05, 0.20, 0.50];
    targetColors = lines(model.nMovements);
    figureHandle = base_figure('Reaches by preparation duration');
    tiledlayout(3, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
    for controllerIndex = 1:3
        prep = results.preparations{controllerIndex};
        for durationIndex = 1:numel(durations)
            ax = nexttile; hold(ax, 'on');
            sample = round(durations(durationIndex) / model.samplingDt) + 1;
            goStates = squeeze(prep.states(sample, :, :));
            cortex = simulate_published_cortex(model, goStates, false);
            [~, hand] = simulate_published_arm(model, cortex.torque);
            for target = 1:model.nMovements
                plot(ax, results.ideal.hand(:, 1, target), results.ideal.hand(:, 3, target), ...
                    '--', 'Color', [0.65, 0.65, 0.65], 'LineWidth', 0.8);
                plot(ax, hand(:, 1, target), hand(:, 3, target), '-', ...
                    'Color', targetColors(target, :), 'LineWidth', 1.1);
            end
            axis(ax, 'equal'); style(ax);
            if controllerIndex == 1, title(ax, sprintf('%d ms', round(1000 * durations(durationIndex)))); end
            if durationIndex == 1, ylabel(ax, results.controllers{controllerIndex}.name); end
            if controllerIndex == 3, xlabel(ax, 'x (m)'); end
        end
    end
end

function figureHandle = figure05(~, ~, results)
    colors = controller_colors();
    metrics = {'ProspectiveErrorFraction','EndpointErrorM','TorqueNRMSE'};
    labels = {'Prospective error fraction','Endpoint error (m)','Torque NRMSE'};
    figureHandle = base_figure('Movement error by preparation duration');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    for metric = 1:numel(metrics)
        ax = nexttile; hold(ax, 'on');
        for controllerIndex = 1:3
            rows = results.movement.Controller == results.controllers{controllerIndex}.name;
            tableData = results.movement(rows, :);
            [groups, duration] = findgroups(tableData.PreparationDurationS);
            meanValue = splitapply(@mean, tableData.(metrics{metric}), groups);
            plot(ax, 1000 * duration, meanValue, 'o-', 'Color', colors(controllerIndex, :), ...
                'MarkerFaceColor', colors(controllerIndex, :), 'LineWidth', 1.4);
        end
        xlabel(ax, 'Preparation duration (ms)'); ylabel(ax, labels{metric});
        if metric == 1, set(ax, 'YScale', 'log'); legend(ax, short_names(), 'Location', 'best'); legend boxoff; end
        style(ax);
    end
end

function figureHandle = figure06(~, model, results)
    colors = controller_colors();
    figureHandle = base_figure('Control input dynamics and effort');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    limit = round(0.5 / model.samplingDt) + 1;
    for index = 1:3
        prep = results.preparations{index};
        targetRates = max(model.xstar, 0).';
        values = zeros(limit, model.nMovements);
        for target = 1:model.nMovements
            rates = max(prep.states(1:limit, :, target), 0);
            deviation = (rates - targetRates(target, :)) ...
                * results.controllers{index}.effectiveFeedback.';
            values(:, target) = vecnorm(deviation, 2, 2);
        end
        plot(ax, prep.timesS(1:limit), mean(values, 2), 'Color', colors(index, :), 'LineWidth', 1.6);
    end
    xlabel(ax, 'Preparation time (s)'); ylabel(ax, 'Feedback input norm');
    legend(ax, short_names(), 'Location', 'best'); legend boxoff; style(ax);
    ax = nexttile;
    effortByTarget = zeros(8, 3);
    for index = 1:3
        rows = results.effort.Controller == results.controllers{index}.name;
        effortByTarget(:, index) = results.effort.LambdaWeightedDeviationEffort(rows);
    end
    bar(ax, 1:8, effortByTarget, 'grouped'); xlabel(ax, 'Target');
    ylabel(ax, 'lambda-weighted effort'); title(ax, 'Per target'); style(ax);
    ax = nexttile;
    means = zeros(3, 1); maximum = zeros(3, 1);
    for index = 1:3
        rows = results.effort.Controller == results.controllers{index}.name;
        means(index) = mean(results.effort.TotalInputEffort(rows));
        maximum(index) = max(results.effort.MaximumDeviationInputNorm(rows));
    end
    yyaxis(ax, 'left'); bar(ax, 1:3, means, 'FaceColor', [0.6, 0.6, 0.6]); ylabel(ax, 'Total input effort');
    yyaxis(ax, 'right'); plot(ax, 1:3, maximum, 'ko-', 'MarkerFaceColor', 'k'); ylabel(ax, 'Maximum feedback norm');
    set(ax, 'XTick', 1:3, 'XTickLabel', short_names()); style(ax);
end

function figureHandle = figure07(~, ~, results)
    colors = controller_colors();
    figureHandle = base_figure('Local stability and finite-time control');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for index = 1:3
        rows = results.local.targets.Controller == results.controllers{index}.name;
        plot(ax, results.local.targets.Target(rows), ...
            results.local.targets.SpectralAbscissaPerS(rows), 'o-', ...
            'Color', colors(index, :), 'MarkerFaceColor', colors(index, :));
    end
    yline(ax, 0, ':k'); xlabel(ax, 'Target'); ylabel(ax, 'Spectral abscissa (s^{-1})');
    legend(ax, short_names(), 'Location', 'best'); legend boxoff; style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:3
        rows = results.local.finiteTime.Controller == results.controllers{index}.name;
        tableData = results.local.finiteTime(rows, :);
        [groups, time] = findgroups(tableData.TimeS);
        maximum = splitapply(@max, tableData.WorstTop13QGain, groups);
        plot(ax, 1000 * time, maximum, 'o-', 'Color', colors(index, :), 'LineWidth', 1.4);
    end
    yline(ax, 1, ':k'); xlabel(ax, 'Time (ms)'); ylabel(ax, 'Worst top-13 Q gain'); style(ax);
    ax = nexttile;
    contractionByTarget = zeros(8, 3);
    for index = 1:3
        rows = results.local.targets.Controller == results.controllers{index}.name;
        contractionByTarget(:, index) = ...
            results.local.targets.WorstInstantaneousQContractionPerS(rows);
    end
    bar(ax, 1:8, contractionByTarget, 'grouped'); xlabel(ax, 'Target');
    yline(ax, 0, ':k'); ylabel(ax, 'Worst instantaneous Q contraction (s^{-1})'); style(ax);
end

function figureHandle = figure08(cfg, ~, results)
    colors = controller_colors();
    figureHandle = base_figure('Nonlinear perturbation recovery and flow');
    tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
    gridTable = results.flow.grid;
    limit = max(abs(gridTable.GammaQPerS(isfinite(gridTable.GammaQPerS))));
    for index = 1:3
        ax = nexttile; rows = gridTable.Controller == results.controllers{index}.name;
        tableData = gridTable(rows, :);
        n = cfg.analysis.flowGridPoints;
        X = reshape(tableData.Q1, n, n); Y = reshape(tableData.Q2, n, n);
        Z = reshape(tableData.GammaQPerS, n, n);
        surf(ax, X, Y, zeros(size(Z)), Z, 'EdgeColor', 'none'); view(ax, 2); hold(ax, 'on');
        quiver(ax, X, Y, reshape(tableData.VelocityQ1, n, n), ...
            reshape(tableData.VelocityQ2, n, n), 'k', 'AutoScaleFactor', 0.65);
        trajectories = results.flow.trajectory{index};
        for trial = 1:size(trajectories, 3)
            plot(ax, trajectories(:, 1, trial), trajectories(:, 2, trial), ...
                'Color', colors(index, :), 'LineWidth', 1.1);
        end
        plot(ax, 0, 0, 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 10);
        clim(ax, [-limit, limit]); axis(ax, 'equal'); xlim(ax, [-0.25, 0.25]); ylim(ax, [-0.25, 0.25]);
        title(ax, results.controllers{index}.name); xlabel(ax, 'Q1'); ylabel(ax, 'Q2'); style(ax);
        if index == 3
            cb = colorbar(ax); cb.Label.String = '\gamma_Q=(1/V)dV/dt (s^{-1})';
        end
    end
    colormap(figureHandle, diverging_map(257));
    ax = nexttile;
    means = zeros(3, 1);
    for index = 1:3
        rows = gridTable.Controller == results.controllers{index}.name;
        means(index) = median(gridTable.OutOfPlaneFraction(rows));
    end
    bar(ax, 1:3, means, 'FaceColor', 'flat', 'CData', colors);
    set(ax, 'XTick', 1:3, 'XTickLabel', short_names()); ylabel(ax, 'Median out-of-plane fraction');
    title(ax, '2-D flow is illustrative'); style(ax);
    ax = nexttile;
    maximum = zeros(3, 1);
    for index = 1:3
        rows = results.local.targets.Controller == results.controllers{index}.name;
        maximum(index) = max(results.local.targets.SpectralAbscissaPerS(rows));
    end
    bar(ax, 1:3, maximum, 'FaceColor', 'flat', 'CData', colors); yline(ax, 0, ':k');
    set(ax, 'XTick', 1:3, 'XTickLabel', short_names()); ylabel(ax, 'Max spectral abscissa'); title(ax, 'Local stability'); style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:3
        rows = results.local.finiteTime.Controller == results.controllers{index}.name;
        tableData = results.local.finiteTime(rows, :);
        [groups, time] = findgroups(tableData.TimeS);
        plot(ax, 1000 * time, splitapply(@max, tableData.WorstTop13QGain, groups), ...
            'o-', 'Color', colors(index, :), 'LineWidth', 1.2);
    end
    yline(ax, 1, ':k'); xlabel(ax, 'Time (ms)'); ylabel(ax, 'Worst Q gain'); title(ax, 'Finite-time control'); style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:3
        rows = results.cloudSummary.Controller == results.controllers{index}.name ...
            & results.cloudSummary.SeedSet == "Matched";
        plot(ax, results.cloudSummary.PerturbationNorm(rows), ...
            results.cloudSummary.MeanProspectiveFraction(rows), 'o-', ...
            'Color', colors(index, :), 'MarkerFaceColor', colors(index, :));
    end
    xlabel(ax, 'Perturbation norm'); ylabel(ax, '300-ms Q fraction'); title(ax, 'Matched nonlinear cloud'); style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:3
        rows = results.cloudSummary.Controller == results.controllers{index}.name ...
            & results.cloudSummary.SeedSet == "Untouched";
        plot(ax, results.cloudSummary.PerturbationNorm(rows), ...
            results.cloudSummary.MeanProspectiveFraction(rows), 'o-', ...
            'Color', colors(index, :), 'MarkerFaceColor', colors(index, :));
    end
    xlabel(ax, 'Perturbation norm'); ylabel(ax, '300-ms Q fraction'); title(ax, 'Untouched confirmation');
    legend(ax, short_names(), 'Location', 'best'); legend boxoff; style(ax);
end

function figureHandle = figure09(~, ~, results)
    colors = controller_colors();
    figureHandle = base_figure('Preparatory-movement alignment and null distribution');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    for panel = 1:2
        ax = nexttile; hold(ax, 'on');
        if panel == 1, epoch = "Published Kao epochs"; else, epoch = "Late-prep/early-move sensitivity"; end
        rows = results.alignment.EpochDefinition == epoch;
        tableData = results.alignment(rows, :);
        x = (1:height(tableData)).';
        errorbar(ax, x, tableData.NullMean, tableData.NullMean - tableData.NullLower95, ...
            tableData.NullUpper95 - tableData.NullMean, 'k.', 'LineWidth', 1);
        scatter(ax, x, tableData.AlignmentIndex, 40, repmat(colors, 2, 1), 'filled');
        set(ax, 'XTick', x, 'XTickLabel', strcat(tableData.Controller, " k", string(tableData.Dimension)), ...
            'XTickLabelRotation', 35);
        ylabel(ax, 'Alignment index'); title(ax, epoch); style(ax);
    end
    ax = nexttile; hold(ax, 'on');
    rows = results.alignment.EpochDefinition == "Published Kao epochs" ...
        & results.alignment.Dimension == 10;
    selectedRows = find(rows);
    for index = 1:numel(selectedRows)
        values = results.alignmentNull.AlignmentIndex(...
            results.alignmentNull.AlignmentRow == selectedRows(index));
        histogram(ax, values, 40, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', ...
            'EdgeColor', colors(index, :), 'LineWidth', 1.2);
        xline(ax, results.alignment.AlignmentIndex(selectedRows(index)), '-', ...
            'Color', colors(index, :), 'LineWidth', 1.3);
    end
    xlabel(ax, 'Alignment index'); ylabel(ax, 'Null density'); title(ax, '10,000 covariance-matched draws');
    legend(ax, short_names(), 'Location', 'best'); legend boxoff; style(ax);
end

function figureHandle = figure10(~, ~, results)
    colors = controller_colors();
    figureHandle = base_figure('Movement amplification and prep-move rotation');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for index = 1:3
        rows = results.amplification.Controller == results.controllers{index}.name;
        plot(ax, results.amplification.Target(rows), ...
            results.amplification.MaximumAmplificationFactor(rows), 'o-', ...
            'Color', colors(index, :), 'MarkerFaceColor', colors(index, :));
    end
    xlabel(ax, 'Target'); ylabel(ax, 'Maximum amplification factor');
    title(ax, 'Exact Kao definition, no movement bump'); legend(ax, short_names()); legend boxoff; style(ax);
    ax = nexttile;
    rows = results.rotation.EpochDefinition == "Published Kao epochs" & results.rotation.Dimension == 10;
    bar(ax, 1:3, results.rotation.MedianPrincipalAngleDeg(rows), ...
        'FaceColor', 'flat', 'CData', colors);
    set(ax, 'XTick', 1:3, 'XTickLabel', short_names());
    ylabel(ax, 'Median principal angle (deg)'); title(ax, 'Published epochs, k=10'); style(ax);
    ax = nexttile;
    rows = results.rotation.EpochDefinition == "Late-prep/early-move sensitivity" ...
        & results.rotation.Dimension == 15;
    bar(ax, 1:3, results.rotation.MedianPrincipalAngleDeg(rows), ...
        'FaceColor', 'flat', 'CData', colors);
    set(ax, 'XTick', 1:3, 'XTickLabel', short_names());
    ylabel(ax, 'Median principal angle (deg)'); title(ax, 'Sensitivity epochs, k=15'); style(ax);
end

function fraction = prospective_fraction(preparation, model, Q)
    fraction = zeros(size(preparation.states, 1), model.nMovements);
    for target = 1:model.nMovements
        delta = preparation.states(:, :, target) - model.xstar(:, target).';
        values = sum((delta * Q) .* delta, 2);
        fraction(:, target) = values / max(values(1), eps);
    end
end

function figureHandle = base_figure(name)
    figureHandle = figure('Visible', 'off', 'Color', 'white', ...
        'Name', name, 'Position', [50, 50, 1500, 850]);
end

function style(ax)
    set(ax, 'FontSize', 12, 'TickDir', 'out', 'LineWidth', 0.3, ...
        'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);
    grid(ax, 'off'); box(ax, 'off');
end

function colors = controller_colors()
    colors = [0.25, 0.25, 0.25; 0.10, 0.42, 0.78; 0.90, 0.42, 0.08];
end

function names = short_names()
    names = {'Stage 2A','Kao','Cerebellum'};
end

function map = diverging_map(n)
    half = floor(n / 2);
    blue = [linspace(0.10, 1, half).', linspace(0.25, 1, half).', ones(half, 1)];
    red = [ones(n - half, 1), linspace(1, 0.20, n - half).', linspace(1, 0.15, n - half).'];
    map = [blue; red];
end

function [kaoFig, kaoPng, cerebellumFig, cerebellumPng] = ...
        save_mirrored(figureHandle, name, cfgKao, cfgCerebellum)
    roots = {cfgKao, cfgCerebellum};
    files = strings(2, 2);
    for index = 1:2
        if ~isfolder(roots{index}.plotsFigRoot), mkdir(roots{index}.plotsFigRoot); end
        if ~isfolder(roots{index}.plotsPngRoot), mkdir(roots{index}.plotsPngRoot); end
        files(index, 1) = fullfile(roots{index}.plotsFigRoot, [name, '.fig']);
        files(index, 2) = fullfile(roots{index}.plotsPngRoot, [name, '.png']);
        savefig(figureHandle, files(index, 1));
        exportgraphics(figureHandle, files(index, 2), 'Resolution', 200, ...
            'BackgroundColor', 'white');
    end
    close(figureHandle);
    kaoFig = files(1, 1); kaoPng = files(1, 2);
    cerebellumFig = files(2, 1); cerebellumPng = files(2, 2);
end
