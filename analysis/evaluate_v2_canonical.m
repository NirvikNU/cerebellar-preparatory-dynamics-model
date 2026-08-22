function evaluation = evaluate_v2_canonical( ...
        model, params, noisy, trialsPerTarget, seed)
    task = build_v2_task(params, trialsPerTarget, ...
        params.task.canonicalGoTimeMs, []);
    simulation = simulate_v2_model(model, task, params, seed, noisy);
    diagnostics = compute_v2_diagnostics(model, simulation, ...
        task, params, true);
    evaluation.task = task;
    evaluation.simulation = simulation;
    evaluation.diagnostics = diagnostics;
end
