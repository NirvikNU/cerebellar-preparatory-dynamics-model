function inventory = create_stage1_figures(cfg, model, baseline, hand, analysis)
    if ~isfolder(cfg.plotsPngRoot)
        mkdir(cfg.plotsPngRoot);
    end
    if ~isfolder(cfg.plotsFigRoot)
        mkdir(cfg.plotsFigRoot);
    end
    inventory = strings(8, 2);
    time = (0:(model.nSamples - 1)) * model.samplingDt;
    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1050, 760]);
    axesHandle = axes(figureHandle); hold(axesHandle, 'on');
    for movement = 1:model.nMovements
        if isfield(model, 'targetHand')
            target = model.targetHand(:, :, movement);
        else
            target = readmatrix(fullfile(cfg.dataRoot, ...
                sprintf('target_hand_r1_%d.tsv', movement)), 'FileType', 'text');
        end
        plot(axesHandle, target(:, 1), target(:, 3), '--', ...
            'Color', cfg.plot.colors(movement, :), 'LineWidth', 1.2);
        plot(axesHandle, hand(:, 1, movement), hand(:, 3, movement), '-', ...
            'Color', cfg.plot.colors(movement, :), 'LineWidth', 2.0);
    end
    axis(axesHandle, 'equal'); xlabel(axesHandle, 'Hand x (m)'); ylabel(axesHandle, 'Hand y (m)');
    title(axesHandle, 'Recalibrated targets (dashed) and generator (solid)');
    apply_plot_style(axesHandle, cfg);
    inventory(1, :) = save_bundle(figureHandle, '01_target_vs_generated_reaches', cfg);

    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1150, 760]);
    layout = tiledlayout(figureHandle, 2, 1, 'TileSpacing', 'compact');
    labels = {'Shoulder torque','Elbow torque'};
    for channel = 1:2
        axesHandle = nexttile(layout); hold(axesHandle, 'on');
        for movement = 1:model.nMovements
            if isfield(model, 'targetTorque')
                target = model.targetTorque(:, :, movement);
            else
                target = readmatrix(fullfile(cfg.dataRoot, ...
                    sprintf('target_torque_r1_%d.tsv', movement)), 'FileType', 'text');
            end
            plot(axesHandle, time, target(:, channel), '--', ...
                'Color', cfg.plot.colors(movement, :), 'LineWidth', 1.0);
            plot(axesHandle, time, baseline.torque(:, channel, movement), '-', ...
                'Color', cfg.plot.colors(movement, :), 'LineWidth', 1.6);
        end
        ylabel(axesHandle, labels{channel}); apply_plot_style(axesHandle, cfg);
    end
    xlabel(axesHandle, 'Time after movement release (s)');
    title(layout, 'Recalibrated target torques (dashed) and outputs (solid)');
    inventory(2, :) = save_bundle(figureHandle, '02_motor_output_profiles', cfg);

    rates = reshape(permute(baseline.rates, [1, 3, 2]), [], model.n);
    rates = rates - mean(rates, 1);
    [~, ~, basis] = svd(rates, 'econ');
    scores = reshape(rates * basis(:, 1:3), model.nSamples, model.nMovements, 3);
    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1050, 780]);
    axesHandle = axes(figureHandle); hold(axesHandle, 'on');
    for movement = 1:model.nMovements
        plot3(axesHandle, scores(:, movement, 1), scores(:, movement, 2), ...
            scores(:, movement, 3), 'Color', cfg.plot.colors(movement, :), 'LineWidth', 1.7);
        scatter3(axesHandle, scores(1, movement, 1), scores(1, movement, 2), ...
            scores(1, movement, 3), 55, cfg.plot.colors(movement, :), 'filled');
    end
    xlabel(axesHandle, 'PC1'); ylabel(axesHandle, 'PC2'); zlabel(axesHandle, 'PC3');
    title(axesHandle, 'Movement-generating cortical trajectories; circles mark x*');
    view(axesHandle, 35, 24); apply_plot_style(axesHandle, cfg);
    inventory(3, :) = save_bundle(figureHandle, '03_cortical_population_trajectories', cfg);

    centeredStates = model.xstar.' - mean(model.xstar, 2).';
    [stateScores, ~, ~] = svd(centeredStates, 'econ');
    coordinates = stateScores(:, 1:2);
    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1350, 500]);
    layout = tiledlayout(figureHandle, 1, 2, 'TileSpacing', 'compact');
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    for movement = 1:model.nMovements
        scatter(axesHandle, coordinates(movement, 1), coordinates(movement, 2), ...
            75, cfg.plot.colors(movement, :), 'filled');
        text(axesHandle, coordinates(movement, 1), coordinates(movement, 2), ...
            sprintf('  %d', movement), 'FontSize', 12);
    end
    xlabel(axesHandle, 'State PC1'); ylabel(axesHandle, 'State PC2');
    title(axesHandle, 'Eight reference initial conditions'); apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout);
    imagesc(axesHandle, analysis.initialStates.pairwiseDistances); colorbar(axesHandle);
    axis(axesHandle, 'image'); xlabel(axesHandle, 'Movement'); ylabel(axesHandle, 'Movement');
    title(axesHandle, 'Pairwise x* distance'); apply_plot_style(axesHandle, cfg);
    inventory(4, :) = save_bundle(figureHandle, '04_optimal_initial_state_geometry', cfg);

    test = analysis.mapping.testMask;
    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1450, 520]);
    layout = tiledlayout(figureHandle, 1, 2, 'TileSpacing', 'compact');
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    scatter(axesHandle, 1e3 * analysis.mapping.endpointDisplacement(test, 1), ...
        1e3 * analysis.mapping.predictedEndpointDisplacement(test, 1), 45, 'filled');
    scatter(axesHandle, 1e3 * analysis.mapping.endpointDisplacement(test, 2), ...
        1e3 * analysis.mapping.predictedEndpointDisplacement(test, 2), 45, 'filled');
    limits = [min(xlim(axesHandle)), max(xlim(axesHandle))]; plot(axesHandle, limits, limits, 'k--');
    xlabel(axesHandle, 'Observed endpoint change (mm)');
    ylabel(axesHandle, 'Held-out prediction (mm)');
    title(axesHandle, sprintf('Initial-state endpoint mapping, R^2 = %.3f', ...
        analysis.mapping.endpointR2));
    apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    values = [analysis.mapping.earlyCorticalR2, analysis.mapping.earlyMotorR2, ...
        analysis.mapping.endpointR2];
    bar(axesHandle, values, 'FaceColor', [0.25, 0.45, 0.70]);
    set(axesHandle, 'XTick', 1:3, 'XTickLabel', {'Early cortex','Early motor','Endpoint'});
    xtickangle(axesHandle, 15);
    ylabel(axesHandle, 'Held-out R^2'); title(axesHandle, 'Local perturbation mapping');
    apply_plot_style(axesHandle, cfg);
    inventory(5, :) = save_bundle(figureHandle, '05_initial_state_to_movement_mapping', cfg);

    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1450, 520]);
    layout = tiledlayout(figureHandle, 1, 2, 'TileSpacing', 'compact');
    axesHandle = nexttile(layout);
    normalizedEigenvalues = max(analysis.potency.eigenvalues ...
        / analysis.potency.eigenvalues(1), 1e-16);
    semilogy(axesHandle, normalizedEigenvalues, 'k-', 'LineWidth', 1.8);
    xlabel(axesHandle, 'Rank'); ylabel(axesHandle, 'Normalized potency eigenvalue');
    title(axesHandle, sprintf('Q spectrum; PR = %.2f', analysis.potency.participationRatio));
    apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout);
    plot(axesHandle, analysis.potency.cumulativeSpectrum, 'k-', 'LineWidth', 1.8); hold(axesHandle, 'on');
    yline(axesHandle, [0.5, 0.8, 0.9, 0.95], ':'); ylim(axesHandle, [0, 1.02]);
    xlabel(axesHandle, 'Number of dimensions'); ylabel(axesHandle, 'Cumulative potency');
    title(axesHandle, 'Normalized cumulative spectrum'); apply_plot_style(axesHandle, cfg);
    inventory(6, :) = save_bundle(figureHandle, '06_prospective_potency_spectrum', cfg);

    trials = analysis.perturbations.trials;
    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1150, 500]);
    layout = tiledlayout(figureHandle, 1, 2, 'TileSpacing', 'compact');
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    bandOrder = ["high", "intermediate", "low"];
    bandColors = [0.12, 0.47, 0.71; 0.85, 0.33, 0.10; 0.47, 0.67, 0.19];
    for index = 1:3
        values = trials.NonlinearMotorError(trials.Band == bandOrder(index));
        jitter = linspace(-0.12, 0.12, numel(values)).';
        scatter(axesHandle, index + jitter, values, 25, bandColors(index, :), 'filled');
        plot(axesHandle, index + [-0.25, 0.25], median(values) * [1, 1], ...
            'k-', 'LineWidth', 2, 'HandleVisibility', 'off');
    end
    set(axesHandle, 'YScale', 'log', 'XTick', 1:3, 'XTickLabel', bandOrder);
    ylabel(axesHandle, 'Integrated nonlinear motor error');
    title(axesHandle, sprintf('Potency predicts error; Spearman \rho = %.3f', ...
        analysis.perturbations.rankCorrelation)); apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout); hold(axesHandle, 'on');
    for index = 1:3
        delta = analysis.perturbations.exampleTorque(:, :, index) - baseline.torque(:, :, 1);
        plot(axesHandle, time, vecnorm(delta, 2, 2), 'LineWidth', 1.8);
    end
    xlabel(axesHandle, 'Time (s)'); ylabel(axesHandle, 'Motor-output deviation norm');
    legend(axesHandle, cellstr(analysis.perturbations.exampleBands), 'Location', 'best');
    title(axesHandle, 'Matched examples: movement 1'); apply_plot_style(axesHandle, cfg);
    inventory(7, :) = save_bundle(figureHandle, '07_potent_vs_null_perturbations', cfg);

    figureHandle = figure('Color', 'w', 'Position', [80, 80, 1200, 720]);
    layout = tiledlayout(figureHandle, 2, 2, 'TileSpacing', 'compact');
    axesHandle = nexttile(layout); histogram(axesHandle, analysis.firing.perNeuronMean, 25);
    xlabel(axesHandle, 'Mean rate (source units)'); ylabel(axesHandle, 'Neurons');
    title(axesHandle, 'Per-neuron mean rates'); apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout); histogram(axesHandle, analysis.firing.perNeuronMaximum, 25);
    xlabel(axesHandle, 'Maximum rate (source units)'); ylabel(axesHandle, 'Neurons');
    title(axesHandle, 'Per-neuron maxima'); apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout);
    eigenvalues = analysis.stability.eigenvaluesPerS;
    scatter(axesHandle, real(eigenvalues), imag(eigenvalues), 18, 'filled'); xline(axesHandle, 0, 'k--');
    xlabel(axesHandle, 'Real (s^{-1})'); ylabel(axesHandle, 'Imaginary (s^{-1})');
    title(axesHandle, 'Movement linearization spectrum'); apply_plot_style(axesHandle, cfg);
    axesHandle = nexttile(layout);
    plot(axesHandle, analysis.stability.transientTimesS, ...
        analysis.stability.transientGains, 'k-', 'LineWidth', 1.8);
    xlabel(axesHandle, 'Time (s)'); ylabel(axesHandle, 'Largest transient gain');
    title(axesHandle, 'Nonnormal amplification'); apply_plot_style(axesHandle, cfg);
    inventory(8, :) = save_bundle(figureHandle, '08_firing_and_stability', cfg);
end

function files = save_bundle(figureHandle, name, cfg)
    [figFile, pngFile] = save_figure_bundle(figureHandle, name, cfg);
    files = string({figFile, pngFile});
end
