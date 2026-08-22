function summary = build_v2_numerical_summary(model, fixed, ...
        trainingHistory, deterministic, noisy, delayRobustness, ...
        validation, benchmark, params)
    summary.projectVersion = params.project.version;
    summary.createdAt = char(datetime('now', 'TimeZone', 'local', ...
        'Format', 'yyyy-MM-dd HH:mm:ss Z'));
    summary.fixedBackbone.sourceSha256 = fixed.sourceSha256;
    summary.fixedBackbone.sourceCommit = fixed.sourceCommit;
    summary.fixedBackbone.spectralAbscissa = fixed.spectralAbscissa;
    summary.fixedBackbone.spectralRadius = fixed.spectralRadius;
    summary.fixedBackbone.nonnormalCommutator = fixed.nonnormalCommutator;
    summary.training.stageAUpdates = trainingHistory.stageA.updatesCompleted;
    summary.training.stageBUpdates = trainingHistory.stageB.updatesCompleted;
    summary.training.stageASeconds = trainingHistory.stageA.elapsedSeconds;
    summary.training.stageBSeconds = trainingHistory.stageB.elapsedSeconds;
    summary.training.runtimeBenchmark = benchmark;
    summary.deterministic = deterministic.diagnostics.metrics;
    summary.noisy = noisy.diagnostics.metrics;
    summary.delayRobustness = delayRobustness;
    summary.validation = validation;
    summary.population = noisy.diagnostics.population;
    summary.cerebellar = noisy.diagnostics.cerebellar;
    summary.drives = noisy.diagnostics.drives;
    summary.parameterNorms = noisy.diagnostics.parameterNorms;
    summary.modelMetadata = model.metadata;
end
