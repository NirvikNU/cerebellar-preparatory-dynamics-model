function inventory = create_stage2b_revised_figures(cfgKao, cfgCerebellum, model, results, revision, figureIndices)
    if nargin < 6
        figureIndices = 1:10;
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
    configurations = {cfgKao, cfgCerebellum};
    stageIndices = [2, 3];
    rows = cell(2 * numel(figureIndices), 4);
    row = 0;
    for stage = 1:2
        cfg = configurations{stage};
        if ~isfolder(cfg.plotsPngRoot), mkdir(cfg.plotsPngRoot); end
        if ~isfolder(cfg.plotsFigRoot), mkdir(cfg.plotsFigRoot); end
        delete_extra_plots(cfg, names);
        for figureIndex = figureIndices
            handle = builders{figureIndex}(model, results, revision, stageIndices(stage));
            figPath = fullfile(cfg.plotsFigRoot, [names{figureIndex}, '.fig']);
            pngPath = fullfile(cfg.plotsPngRoot, [names{figureIndex}, '.png']);
            savefig(handle, figPath);
            exportgraphics(handle, pngPath, 'Resolution', 200, 'BackgroundColor', 'white');
            close(handle);
            row = row + 1;
            rows(row, :) = {string(results.controllers{stageIndices(stage)}.name), ...
                string(names{figureIndex}), string(figPath), string(pngPath)};
        end
    end
    inventory = cell2table(rows, 'VariableNames', ...
        {'Stage','Basename','FIG','PNG'});
end

function handle = figure01(~, results, ~, stageIndex)
    indices = [1, stageIndex];
    colors = stage_colors(stageIndex);
    handle = base_figure('Controller derivation and fixed points');
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile;
    inputDimensions = cellfun(@(value) value.inputDimension, results.controllers(indices));
    colored_bars(ax, inputDimensions, colors);
    set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices));
    ylabel(ax, 'Control dimensions'); title(ax, 'Fixed actuator size'); style(ax);
    ax = nexttile;
    if stageIndex == 3
        values = results.controllers{3}.qEigenvalues;
        plot(ax, 1:numel(values), cumsum(values) / sum(values), 'k-', 'LineWidth', 1.5);
        hold(ax, 'on'); xline(ax, 13, '--k', 'k=13'); yline(ax, 0.95, ':k');
        title(ax, sprintf('Top 13 Q potency: %.2f%%', ...
            100 * results.controllers{3}.potencyFraction));
        xlabel(ax, 'Q eigenvector rank'); ylabel(ax, 'Cumulative potency'); ylim(ax, [0, 1.02]);
    else
        imagesc(ax, results.controllers{2}.K); colorbar(ax);
        xlabel(ax, 'Cortical state'); ylabel(ax, 'Control channel');
        title(ax, 'Unrestricted K (200 x 200)');
    end
    style(ax);
    ax = nexttile;
    imagesc(ax, results.controllers{stageIndex}.K); colorbar(ax);
    xlabel(ax, 'Cortical state'); ylabel(ax, 'Control channel');
    title(ax, sprintf('Frozen K (%d x 200)', results.controllers{stageIndex}.inputDimension));
    style(ax);
    ax = nexttile;
    values = zeros(8, 2);
    for index = 1:2
        rows = results.local.targets.Controller == results.controllers{indices(index)}.name;
        values(:, index) = results.local.targets.FixedPointResidualNorm(rows);
    end
    semilogy(ax, 1:8, max(values, 1e-18), 'o-', 'LineWidth', 1.1);
    xlabel(ax, 'Target'); ylabel(ax, 'Fixed-point residual norm');
    title(ax, 'All eight fixed points preserved'); legend(ax, stage_names(results, indices));
    legend_boxoff(ax); style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        if indices(index) == 1, continue; end
        eigenvalues = results.controllers{indices(index)}.closedLoopEigenvalues;
        scatter(ax, real(eigenvalues), imag(eigenvalues), 12, colors(index, :), 'filled');
    end
    xline(ax, 0, ':k'); xlabel(ax, 'Real part'); ylabel(ax, 'Imaginary part');
    title(ax, 'Frozen CARE closed-loop spectrum'); style(ax);
    ax = nexttile; axis(ax, 'off');
    if stageIndex == 2
        text(ax, 0, 0.8, 'Kao controller', 'FontSize', 15, 'FontWeight', 'bold');
        text(ax, 0, 0.55, '200-D state feedback', 'FontSize', 13);
        text(ax, 0, 0.32, 'B = I_{200}; no actuator restriction', 'FontSize', 13);
    else
        text(ax, 0, 0.8, 'Cerebellum capacity bound', 'FontSize', 15, 'FontWeight', 'bold');
        text(ax, 0, 0.55, '13-D command; fixed B_{CB}', 'FontSize', 13);
        text(ax, 0, 0.32, 'Top-13 Q eigenvectors; no biology', 'FontSize', 13);
    end
    sgtitle(handle, 'Frozen controller derivation and fixed-point checks');
end

function handle = figure02(model, results, ~, stageIndex)
    indices = [1, stageIndex];
    targetColors = lines(model.nMovements);
    handle = base_figure('Cortical preparation, GO, and movement trajectories');
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    for panel = 1:2
        controllerIndex = indices(panel);
        ax = nexttile; hold(ax, 'on');
        prep = results.preparations{controllerIndex};
        limit = round(0.5 / model.samplingDt) + 1;
        goStates = squeeze(prep.states(limit, :, :));
        movement = simulate_published_cortex(model, goStates, true);
        prepRates = max(prep.states(1:limit, :, :), 0);
        values = [reshape(permute(prepRates, [2, 1, 3]), model.n, []), ...
            reshape(permute(movement.rates(1:351, :, :), [2, 1, 3]), model.n, [])];
        values = values - mean(values, 2);
        [U, ~, ~] = svd(values, 'econ'); U = U(:, 1:2);
        for target = 1:model.nMovements
            p = squeeze(prepRates(:, :, target)) * U;
            m = squeeze(movement.rates(1:351, :, target)) * U;
            plot(ax, p(:, 1), p(:, 2), '--', 'Color', targetColors(target, :), 'LineWidth', 1);
            scatter(ax, p(end, 1), p(end, 2), 30, targetColors(target, :), 'filled');
            plot(ax, m(:, 1), m(:, 2), '-', 'Color', targetColors(target, :), 'LineWidth', 1.3);
        end
        xlabel(ax, 'PC 1'); ylabel(ax, 'PC 2');
        title(ax, results.controllers{controllerIndex}.name); axis(ax, 'equal'); style(ax);
    end
    sgtitle(handle, 'Dashed: preparation; filled circle: GO; solid: movement');
end

function handle = figure03(model, results, ~, stageIndex)
    indices = [1, stageIndex]; colors = stage_colors(stageIndex);
    handle = base_figure('Preparatory error dynamics');
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        fraction = prospective_fraction(results.preparations{indices(index)}, ...
            model, results.controllers{1}.Q);
        semilogy(ax, results.preparations{indices(index)}.timesS, mean(fraction, 2), ...
            'Color', colors(index, :), 'LineWidth', 1.7);
    end
    xlim(ax, [0, 0.5]); ylim(ax, [1e-8, 2]);
    xlabel(ax, 'Preparation time (s)'); ylabel(ax, 'Prospective error fraction');
    title(ax, 'Mean across eight targets'); legend(ax, stage_names(results, indices));
    legend_boxoff(ax); style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        prep = results.preparations{indices(index)};
        delta = squeeze(prep.states(:, :, 1)) - model.xstar(:, 1).';
        plot(ax, prep.timesS, vecnorm(delta, 2, 2) / norm(delta(1, :)), ...
            'Color', colors(index, :), 'LineWidth', 1.7);
    end
    xlim(ax, [0, 0.5]); xlabel(ax, 'Preparation time (s)');
    ylabel(ax, 'Euclidean state fraction'); title(ax, 'Representative target 1'); style(ax);
end

function handle = figure04(model, results, ~, stageIndex)
    indices = [1, stageIndex]; durations = [0, 0.05, 0.20, 0.50];
    targetColors = lines(model.nMovements);
    handle = base_figure('Reaches by preparation duration');
    tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
    for row = 1:2
        prep = results.preparations{indices(row)};
        for durationIndex = 1:numel(durations)
            ax = nexttile; hold(ax, 'on');
            sample = round(durations(durationIndex) / model.samplingDt) + 1;
            goStates = squeeze(prep.states(sample, :, :));
            cortex = simulate_published_cortex(model, goStates, false);
            [~, hand] = simulate_published_arm(model, cortex.torque);
            for target = 1:model.nMovements
                plot(ax, results.ideal.hand(:, 1, target), results.ideal.hand(:, 3, target), ...
                    '--', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.8);
                plot(ax, hand(:, 1, target), hand(:, 3, target), '-', ...
                    'Color', targetColors(target, :), 'LineWidth', 1.1);
            end
            axis(ax, 'equal'); style(ax);
            if row == 1, title(ax, sprintf('%d ms preparation', 1000 * durations(durationIndex))); end
            if durationIndex == 1, ylabel(ax, results.controllers{indices(row)}.name); end
            if row == 2, xlabel(ax, 'Hand x (m)'); end
        end
    end
end

function handle = figure05(~, results, ~, stageIndex)
    indices = [1, stageIndex]; colors = stage_colors(stageIndex);
    metrics = {'ProspectiveErrorFraction','EndpointErrorM','TorqueNRMSE'};
    labels = {'Prospective error fraction','Endpoint error (m)','Torque NRMSE'};
    handle = base_figure('Movement error by preparation duration');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    for metric = 1:numel(metrics)
        ax = nexttile; hold(ax, 'on');
        for index = 1:2
            rows = results.movement.Controller == results.controllers{indices(index)}.name;
            data = results.movement(rows, :);
            [groups, duration] = findgroups(data.PreparationDurationS);
            plot(ax, 1000 * duration, splitapply(@mean, data.(metrics{metric}), groups), ...
                'o-', 'Color', colors(index, :), 'MarkerFaceColor', colors(index, :), ...
                'LineWidth', 1.4);
        end
        xlabel(ax, 'Preparation duration (ms)'); ylabel(ax, labels{metric});
        if metric == 1
            set(ax, 'YScale', 'log'); legend(ax, stage_names(results, indices)); legend_boxoff(ax);
        end
        style(ax);
    end
end

function handle = figure06(~, results, revision, stageIndex)
    indices = [1, stageIndex]; colors = stage_colors(stageIndex);
    handle = base_figure('Control input dynamics, dimensionality, and effort');
    tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        rows = revision.inputTimeCourse.Controller == results.controllers{indices(index)}.name;
        plot(ax, revision.inputTimeCourse.TimeS(rows), ...
            revision.inputTimeCourse.MeanFeedbackNorm(rows), 'Color', colors(index, :), ...
            'LineWidth', 1.6);
    end
    xlabel(ax, 'Preparation time (s)'); ylabel(ax, 'Mean feedback input norm');
    legend(ax, stage_names(results, indices)); legend_boxoff(ax); style(ax);
    inputTypes = ["State-dependent cortical feedback", ...
        "Total preparatory cortical input"];
    for panel = 1:2
        ax = nexttile; hold(ax, 'on');
        for index = 1:2
            rows = revision.inputSpectrum.Controller == results.controllers{indices(index)}.name ...
                & revision.inputSpectrum.InputType == inputTypes(panel);
            plot(ax, revision.inputSpectrum.Component(rows), ...
                revision.inputSpectrum.CumulativeVarianceFraction(rows), ...
                'Color', colors(index, :), 'LineWidth', 1.6);
            summaryRow = revision.inputSummary.Controller == results.controllers{indices(index)}.name ...
                & revision.inputSummary.InputType == inputTypes(panel);
            k = revision.inputSummary.K95(summaryRow);
            if k > 0, xline(ax, k, ':', sprintf('k_{95}=%d', k), 'Color', colors(index, :)); end
        end
        xlim(ax, [0, 40]); ylim(ax, [0, 1.02]); yline(ax, 0.95, ':k');
        xlabel(ax, 'Component'); ylabel(ax, 'Cumulative variance'); title(ax, inputTypes(panel)); style(ax);
    end
    ax = nexttile;
    effort = zeros(8, 2);
    for index = 1:2
        rows = results.effort.Controller == results.controllers{indices(index)}.name;
        effort(:, index) = results.effort.LambdaWeightedDeviationEffort(rows);
    end
    bar(ax, 1:8, effort, 'grouped'); xlabel(ax, 'Target');
    ylabel(ax, '\lambda-weighted deviation effort'); title(ax, 'Frozen-controller effort'); style(ax);
    ax = nexttile;
    values = zeros(2, 2);
    for index = 1:2
        controller = results.controllers{indices(index)}.name;
        for inputIndex = 1:2
            row = revision.inputSummary.Controller == controller & ...
                revision.inputSummary.InputType == inputTypes(inputIndex);
            values(index, inputIndex) = revision.inputSummary.ParticipationRatio(row);
        end
    end
    bar(ax, values); set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices));
    ylabel(ax, 'Participation ratio'); legend(ax, {'Feedback','Total input'}); legend_boxoff(ax);
    title(ax, '10-ms temporal subsampling'); style(ax);
    ax = nexttile;
    if stageIndex == 3
        rows = revision.inputSpectrum.Controller == results.controllers{3}.name ...
            & revision.inputSpectrum.InputType == "13-D controller command";
        plot(ax, revision.inputSpectrum.Component(rows), ...
            revision.inputSpectrum.CumulativeVarianceFraction(rows), 'Color', colors(2, :), ...
            'LineWidth', 1.7); yline(ax, 0.95, ':k'); xlim(ax, [1, 13]); ylim(ax, [0, 1.02]);
        title(ax, 'Secondary: 13-D command z(t)'); xlabel(ax, 'Component');
        ylabel(ax, 'Cumulative variance');
    else
        axis(ax, 'off');
        text(ax, 0, 0.65, 'Stage 2A has no', 'FontSize', 15);
        text(ax, 0, 0.42, 'state-dependent feedback input.', 'FontSize', 15, 'FontWeight', 'bold');
    end
    style(ax);
    sgtitle(handle, 'Figure 6: actual cortical inputs; all matrices sampled every 10 ms');
end

function handle = figure07(~, results, ~, stageIndex)
    indices = [1, stageIndex]; colors = stage_colors(stageIndex);
    handle = base_figure('Local stability and finite-time control');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        rows = results.local.targets.Controller == results.controllers{indices(index)}.name;
        plot(ax, results.local.targets.Target(rows), ...
            results.local.targets.SpectralAbscissaPerS(rows), 'o-', ...
            'Color', colors(index, :), 'MarkerFaceColor', colors(index, :));
    end
    yline(ax, 0, ':k'); xlabel(ax, 'Target'); ylabel(ax, 'Spectral abscissa (s^{-1})');
    legend(ax, stage_names(results, indices)); legend_boxoff(ax); style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        rows = results.local.finiteTime.Controller == results.controllers{indices(index)}.name;
        data = results.local.finiteTime(rows, :); [groups, time] = findgroups(data.TimeS);
        plot(ax, 1000 * time, splitapply(@max, data.WorstTop13QGain, groups), ...
            'o-', 'Color', colors(index, :), 'LineWidth', 1.4);
    end
    yline(ax, 1, ':k'); xlabel(ax, 'Time (ms)'); ylabel(ax, 'Worst top-13 Q gain'); style(ax);
    ax = nexttile;
    contraction = zeros(8, 2);
    for index = 1:2
        rows = results.local.targets.Controller == results.controllers{indices(index)}.name;
        contraction(:, index) = results.local.targets.WorstInstantaneousQContractionPerS(rows);
    end
    bar(ax, 1:8, contraction, 'grouped'); yline(ax, 0, ':k'); xlabel(ax, 'Target');
    ylabel(ax, 'Worst instantaneous Q contraction (s^{-1})'); style(ax);
end

function handle = figure08(~, results, revision, stageIndex)
    indices = [1, stageIndex]; colors = stage_colors(stageIndex);
    handle = base_figure('Nonlinear and local-linearized flow-field diagnostic');
    tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
    tableData = revision.flow.grid;
    relevant = ismember(tableData.Controller, full_stage_names(results, indices)) ...
        & ~tableData.MaskedNearOrigin;
    gammaLimit = max(abs([tableData.NonlinearGammaQPerS(relevant); ...
        tableData.LinearizedGammaQPerS(relevant)]), [], 'omitnan');
    for fieldType = 1:2
        for index = 1:2
            controllerIndex = indices(index);
            ax = nexttile; rows = tableData.Controller == results.controllers{controllerIndex}.name;
            data = tableData(rows, :); n = revision.flow.gridPoints;
            X = reshape(data.Q1, n, n); Y = reshape(data.Q2, n, n);
            if fieldType == 1
                Z = reshape(data.NonlinearGammaQPerS, n, n);
                U = reshape(data.NonlinearVelocityQ1, n, n);
                V = reshape(data.NonlinearVelocityQ2, n, n);
                trajectories = revision.flow.trajectories{controllerIndex};
                descriptor = 'Nonlinear';
            else
                Z = reshape(data.LinearizedGammaQPerS, n, n);
                U = reshape(data.LinearizedVelocityQ1, n, n);
                V = reshape(data.LinearizedVelocityQ2, n, n);
                trajectories = [];
                descriptor = 'Exact Jacobian';
            end
            surf(ax, X, Y, zeros(size(Z)), Z, 'EdgeColor', 'none'); view(ax, 2); hold(ax, 'on');
            quiver(ax, X, Y, U, V, 'k', 'AutoScale', 'on', 'AutoScaleFactor', 0.7);
            if fieldType == 1
                for trial = 1:size(trajectories, 3)
                    plot(ax, trajectories(:, 1, trial), trajectories(:, 2, trial), ...
                        'Color', colors(index, :), 'LineWidth', 1.0);
                end
            end
            plot(ax, 0, 0, 'kp', 'MarkerFaceColor', 'w', 'MarkerSize', 10);
            clim(ax, [-gammaLimit, gammaLimit]); axis(ax, 'equal');
            xlim(ax, [-revision.flow.gridExtent, revision.flow.gridExtent]);
            ylim(ax, [-revision.flow.gridExtent, revision.flow.gridExtent]);
            xlabel(ax, 'Q_1 displacement'); ylabel(ax, 'Q_2 displacement');
            title(ax, sprintf('%s: %s (target %d)', descriptor, ...
                short_name(results.controllers{controllerIndex}.name), revision.flow.target));
            style(ax);
            if fieldType == 2 && index == 2
                cb = colorbar(ax); cb.Label.String = '\gamma_Q=(1/V)dV/dt (s^{-1})';
            end
        end
    end
    colormap(handle, diverging_map(257));
    ax = nexttile;
    diagnostics = revision.flow.diagnostics(ismember(revision.flow.diagnostics.Controller, ...
        full_stage_names(results, indices)), :);
    colored_bars(ax, diagnostics.ProjectedVelocityNRMSE, colors);
    set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices));
    ax.XTickLabelRotation = 15;
    ylabel(ax, 'Projected velocity NRMSE'); title(ax, 'Nonlinear vs linearized'); style(ax);
    ax = nexttile;
    colored_bars(ax, diagnostics.GammaCorrelation, colors);
    set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices)); ylim(ax, [-1, 1]);
    ax.XTickLabelRotation = 15;
    ylabel(ax, '\gamma_Q correlation'); title(ax, 'Matched-grid agreement'); style(ax);
    ax = nexttile;
    yyaxis(ax, 'left'); bar(ax, diagnostics.MedianOutOfPlaneFraction, 0.55, ...
        'FaceColor', [0.55, 0.55, 0.55]); ylabel(ax, 'Median out-of-plane fraction');
    yyaxis(ax, 'right'); plot(ax, 1:2, diagnostics.MaximumActiveSetChangeFraction, ...
        'ko-', 'MarkerFaceColor', 'k'); ylabel(ax, 'Max active-set change');
    set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices));
    ax.XTickLabelRotation = 15;
    title(ax, 'Projection and ReLU diagnostics'); style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        rows = results.cloudSummary.Controller == results.controllers{indices(index)}.name ...
            & results.cloudSummary.SeedSet == "Matched";
        plot(ax, results.cloudSummary.PerturbationNorm(rows), ...
            results.cloudSummary.MeanProspectiveFraction(rows), 'o-', ...
            'Color', colors(index, :), 'MarkerFaceColor', colors(index, :));
    end
    xlabel(ax, 'Perturbation norm'); ylabel(ax, '300-ms Q fraction');
    title(ax, 'All-target 200-D nonlinear clouds'); legend(ax, stage_names(results, indices));
    legend_boxoff(ax); style(ax);
end

function handle = figure09(~, results, revision, stageIndex)
    indices = [1, stageIndex]; colors = stage_colors(stageIndex);
    handle = base_figure('Preparatory dimensionality and alignment');
    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        rows = revision.alignmentSpectrum.Controller == results.controllers{indices(index)}.name ...
            & revision.alignmentSpectrum.Epoch == "Preparation";
        plot(ax, revision.alignmentSpectrum.Component(rows), ...
            revision.alignmentSpectrum.CumulativeVarianceFraction(rows), ...
            'Color', colors(index, :), 'LineWidth', 1.7);
        summaryRow = revision.alignment.Controller == results.controllers{indices(index)}.name;
        xline(ax, revision.alignment.K95Preparation(summaryRow), ':', ...
            sprintf('k_{95}=%d', revision.alignment.K95Preparation(summaryRow)), ...
            'Color', colors(index, :));
    end
    yline(ax, 0.95, ':k'); xlim(ax, [0, 40]); ylim(ax, [0, 1.02]);
    xlabel(ax, 'Preparatory PC'); ylabel(ax, 'Cumulative variance');
    title(ax, 'Controller-specific k_{95}'); legend(ax, stage_names(results, indices));
    legend_boxoff(ax); style(ax);
    ax = nexttile; hold(ax, 'on');
    rows = ismember(revision.alignment.Controller, full_stage_names(results, indices));
    data = revision.alignment(rows, :);
    x = (1:2).';
    nullHandle = errorbar(ax, x, data.NullMedian, data.NullMedianSE, 'o', ...
        'Color', [0.45, 0.45, 0.45], 'MarkerFaceColor', [0.65, 0.65, 0.65], ...
        'LineWidth', 1.2);
    observedHandle = scatter(ax, x, data.ObservedAlignment, 55, colors, 'filled');
    set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices));
    ylabel(ax, 'Elsayed alignment index'); title(ax, '10,000 random subspaces');
    legend(ax, [observedHandle, nullHandle], {'Observed', ...
        'Covariance-matched null median \pm SE'}, 'Location', 'best');
    legend_boxoff(ax); style(ax);
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        rows = revision.alignmentNull.Controller == results.controllers{indices(index)}.name;
        histogram(ax, revision.alignmentNull.AlignmentIndex(rows), 45, ...
            'Normalization', 'pdf', 'DisplayStyle', 'stairs', ...
            'EdgeColor', colors(index, :), 'LineWidth', 1.3);
        summaryRow = revision.alignment.Controller == results.controllers{indices(index)}.name;
        xline(ax, revision.alignment.ObservedAlignment(summaryRow), '-', ...
            'Color', colors(index, :), 'LineWidth', 1.5);
    end
    xlabel(ax, 'Alignment index'); ylabel(ax, 'Null density');
    title(ax, 'Colored lines: observed'); legend(ax, stage_names(results, indices));
    legend_boxoff(ax); style(ax);
    ax = nexttile;
    metric = [data.PreparationParticipationRatio, data.MovementParticipationRatio];
    bar(ax, metric); set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices));
    ylabel(ax, 'Participation ratio'); legend(ax, {'Preparation','Movement'}); legend_boxoff(ax);
    title(ax, '300-ms epochs, sampled every 10 ms'); style(ax);
    sgtitle(handle, ['Kao timing: prep 150-450 ms after target; movement -50 to +250 ms ' ...
        'around model onset (100 ms after control removal)']);
end

function handle = figure10(~, results, revision, stageIndex)
    indices = [1, stageIndex]; colors = stage_colors(stageIndex);
    handle = base_figure('Movement amplification and prep-move rotation');
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax = nexttile; hold(ax, 'on');
    for index = 1:2
        rows = results.amplification.Controller == results.controllers{indices(index)}.name;
        plot(ax, results.amplification.Target(rows), ...
            results.amplification.MaximumAmplificationFactor(rows), 'o-', ...
            'Color', colors(index, :), 'MarkerFaceColor', colors(index, :));
    end
    xlabel(ax, 'Target'); ylabel(ax, 'Maximum amplification factor');
    title(ax, 'Kao definition; no movement bump'); legend(ax, stage_names(results, indices));
    legend_boxoff(ax); style(ax);
    ax = nexttile;
    rows = ismember(revision.rotation.Controller, full_stage_names(results, indices));
    data = revision.rotation(rows, :);
    colored_bars(ax, data.MedianPrincipalAngleDeg, colors);
    set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices));
    ylabel(ax, 'Median principal angle (deg)'); title(ax, 'Controller-specific k_{95}'); style(ax);
    ax = nexttile;
    colored_bars(ax, data.MaximumPrincipalAngleDeg, colors);
    set(ax, 'XTick', 1:2, 'XTickLabel', stage_names(results, indices));
    ylabel(ax, 'Maximum principal angle (deg)');
    title(ax, 'Exact published 300-ms epochs'); style(ax);
end

function fraction = prospective_fraction(preparation, model, Q)
    fraction = zeros(size(preparation.states, 1), model.nMovements);
    for target = 1:model.nMovements
        delta = preparation.states(:, :, target) - model.xstar(:, target).';
        values = sum((delta * Q) .* delta, 2);
        fraction(:, target) = values / max(values(1), eps);
    end
end

function delete_extra_plots(cfg, names)
    expected = string(names);
    roots = {cfg.plotsPngRoot, cfg.plotsFigRoot};
    extensions = {'.png', '.fig'};
    for index = 1:2
        files = dir(fullfile(roots{index}, ['*', extensions{index}]));
        for fileIndex = 1:numel(files)
            basename = erase(string(files(fileIndex).name), extensions{index});
            if ~ismember(basename, expected)
                delete(fullfile(files(fileIndex).folder, files(fileIndex).name));
            end
        end
    end
end

function handle = base_figure(name)
    handle = figure('Visible', 'off', 'Color', 'white', 'Name', name, ...
        'Position', [50, 50, 1600, 920]);
end

function style(ax)
    if strcmp(ax.Visible, 'off'), return; end
    set(ax, 'FontSize', 12, 'TickDir', 'out', 'LineWidth', 0.3, ...
        'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);
    grid(ax, 'off'); box(ax, 'off');
end

function colors = stage_colors(stageIndex)
    palette = [0.25, 0.25, 0.25; 0.10, 0.42, 0.78; 0.90, 0.42, 0.08];
    colors = palette([1, stageIndex], :);
end

function names = stage_names(results, indices)
    names = cellfun(@(value) short_name(value.name), results.controllers(indices), ...
        'UniformOutput', false);
end

function names = full_stage_names(results, indices)
    names = string(cellfun(@(value) value.name, results.controllers(indices), ...
        'UniformOutput', false));
end

function name = short_name(name)
    name = char(string(name));
    name = strrep(name, 'Stage 2B-', '');
end

function map = diverging_map(n)
    half = floor(n / 2);
    blue = [linspace(0.10, 1, half).', linspace(0.25, 1, half).', ones(half, 1)];
    red = [ones(n - half, 1), linspace(1, 0.20, n - half).', ...
        linspace(1, 0.15, n - half).'];
    map = [blue; red];
end

function colored_bars(ax, values, colors)
    hold(ax, 'on');
    for index = 1:numel(values)
        bar(ax, index, values(index), 0.72, 'FaceColor', colors(index, :), ...
            'EdgeColor', [0.25, 0.25, 0.25]);
    end
end

function legend_boxoff(ax)
    handle = legend(ax);
    handle.Box = 'off';
end
