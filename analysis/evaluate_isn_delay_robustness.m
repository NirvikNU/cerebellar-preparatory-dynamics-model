function robustness = evaluate_isn_delay_robustness( ...
        model, params, noisy, trialsPerTarget, seedBase)
    delays = params.evaluation.delayValuesMs;
    count = numel(delays);
    fields = {'meanEndpointErrorM', 'maximumTargetAveragedEndpointErrorM', ...
        'meanTerminalSpeedMPerSec', 'preGoRmsEndpointSpeedMPerSec', ...
        'preGoRmsEndpointDisplacementM', 'holdRmsErrorM', ...
        'holdRmsSpeedMPerSec'};
    for fieldIndex = 1:numel(fields)
        robustness.(fields{fieldIndex}) = zeros(count, 1);
    end
    for delayIndex = 1:count
        task = build_isn_reach_task(params, trialsPerTarget, ...
            delays(delayIndex), []);
        simulation = simulate_isn_model(model, task, params, ...
            seedBase + delayIndex - 1, noisy);
        diagnostics = compute_isn_diagnostics(model, simulation, ...
            task, params);
        for fieldIndex = 1:numel(fields)
            name = fields{fieldIndex};
            robustness.(name)(delayIndex) = diagnostics.metrics.(name);
        end
    end
    robustness.delayValuesMs = delays;
    robustness.noisy = noisy;
    robustness.trialsPerTarget = trialsPerTarget;
end
