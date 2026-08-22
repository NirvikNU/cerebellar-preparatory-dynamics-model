function robustness = evaluate_v2_delay_robustness( ...
        model, params, noisy, trialsPerTarget, seed)
    delays = params.evaluation.delayValuesMs;
    fields = {'meanEndpointErrorM', ...
        'maximumTargetAveragedEndpointErrorM', ...
        'meanTerminalSpeedMPerSec', 'preGoRmsSpeedMPerSec', ...
        'meanHoldErrorM', 'meanHoldSpeedMPerSec', ...
        'maximumPreGoDisplacementM'};
    robustness.delayMs = delays;
    for fieldIndex = 1:numel(fields)
        robustness.(fields{fieldIndex}) = nan(size(delays));
    end
    for delayIndex = 1:numel(delays)
        task = build_v2_task(params, trialsPerTarget, delays(delayIndex), []);
        simulation = simulate_v2_model(model, task, params, ...
            seed + delayIndex, noisy);
        diagnostics = compute_v2_diagnostics(model, simulation, ...
            task, params, false);
        for fieldIndex = 1:numel(fields)
            name = fields{fieldIndex};
            robustness.(name)(delayIndex) = diagnostics.metrics.(name);
        end
    end
    robustness.noisy = noisy;
    robustness.trialsPerTarget = trialsPerTarget;
end
