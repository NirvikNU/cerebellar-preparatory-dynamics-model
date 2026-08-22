function report = validate_v2_stationarity_refinement_support(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end
    params = v2_model_params();
    params.training.latePreGoVelocityLossWeight = 0;
    resultRoot = fullfile(projectRoot, params.files.resultRoot);
    savedModel = load(fullfile(resultRoot, ...
        'stage_a_best_model.mat'), 'model');
    savedCheckpoint = load(fullfile(resultRoot, ...
        'stage_a_checkpoint_latest.mat'), 'checkpoint');
    task = build_v2_task(params, 1, params.task.canonicalGoTimeMs, []);
    stream = RandStream('mt19937ar', 'Seed', params.seed.trainingNoise);
    noise = sample_v2_noise(task, params, false, stream, false);
    [newLoss, components] = v2_model_loss( ...
        savedModel.model, task, params, noise);
    legacyLoss = legacy_total(components, params);
    report.zeroWeightLossDifference = abs(scalar_value(newLoss) - ...
        scalar_value(legacyLoss));
    if report.zeroWeightLossDifference > 1e-7
        error('V2Model:LegacyLossEquivalence', ...
            'Zero-weight late term changed the legacy loss by %.9g.', ...
            report.zeroWeightLossDifference);
    end
    leakage = diagnose_v2_pre_go_leakage(savedModel.model, params);
    report.mask = leakage.maskVerification;

    smokeParams = params;
    smokeParams.training.stageAMaxIterations = ...
        savedCheckpoint.checkpoint.iteration + 2;
    smokeParams.training.validationFrequency = 50;
    smokeParams.training.displayEvery = 50;
    smokeParams.training.checkpointFrequency = 250;
    [~, history] = train_v2_stage( ...
        savedCheckpoint.checkpoint.currentModel, smokeParams, 'A', true, ...
        '', savedCheckpoint.checkpoint);
    report.resumeSmokeAdditionalUpdates = history.additionalUpdatesCompleted;
    report.resumeSmokeFinite = all(isfinite(history.loss(end - 1:end)));
    if report.resumeSmokeAdditionalUpdates ~= 2 || ~report.resumeSmokeFinite
        error('V2Model:ResumeSmoke', ...
            'Two-update exact-state resume smoke test failed.');
    end
end

function value = scalar_value(input)
    if isa(input, 'dlarray')
        input = extractdata(input);
    end
    value = double(gather(input));
end

function loss = legacy_total(c, params)
    w = params.training;
    loss = w.preGoPositionLossWeight * c.preGoPosition + ...
        w.preGoVelocityLossWeight * c.preGoVelocity + ...
        w.endpointUrgencyLossWeight * c.endpointUrgency + ...
        w.terminalPositionLossWeight * c.terminalPosition + ...
        w.terminalVelocityLossWeight * c.terminalVelocity + ...
        w.holdPositionLossWeight * c.holdPosition + ...
        w.holdVelocityLossWeight * c.holdVelocity + ...
        w.velocityEffortLossWeight * c.velocityEffort + ...
        w.activityRegularization * c.activity + ...
        w.weightRegularization * c.weight;
end
