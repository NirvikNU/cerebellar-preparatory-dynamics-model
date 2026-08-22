function summary = build_v2_stage_a_summary(model, fixed, history, ...
        evaluation, delay, validation, figureFiles, paths, params)
    summary.createdAt = char(datetime('now', 'TimeZone', 'local', ...
        'Format', 'yyyy-MM-dd HH:mm:ss Z'));
    summary.projectVersion = params.project.version;
    summary.scope = 'Stage A deterministic acquisition only';
    summary.fixedBackbone.sourceSha256 = fixed.sourceSha256;
    summary.fixedBackbone.sourceCommit = fixed.sourceCommit;
    summary.training.updatesCompleted = history.updatesCompleted;
    summary.training.elapsedSeconds = history.elapsedSeconds;
    summary.training.acceleratedWarmupSeconds = ...
        history.acceleratedWarmupSeconds;
    summary.training.bestIteration = history.bestIteration;
    summary.training.bestValidationLoss = history.bestValidationLoss;
    summary.training.finalTrainingLoss = history.loss(end);
    summary.training.trainingLossAtBest = history.loss( ...
        history.bestIteration);
    validationUpdates = find(isfinite(history.validationLoss));
    summary.training.lastValidationUpdate = validationUpdates(end);
    summary.training.lastValidationLoss = history.validationLoss( ...
        validationUpdates(end));
    summary.training.bestAtLastValidation = ...
        history.bestIteration == validationUpdates(end);
    if numel(validationUpdates) > 1
        summary.training.lastValidationImproved = ...
            history.validationLoss(validationUpdates(end)) < ...
            history.validationLoss(validationUpdates(end - 1));
    else
        summary.training.lastValidationImproved = false;
    end
    summary.training.lossStillImprovingAtEnd = ...
        summary.training.bestAtLastValidation && ...
        summary.training.lastValidationImproved;
    [summary.lossComponents, summary.dominantLossComponents] = ...
        loss_components_at_best(history, params);
    summary.metrics = evaluation.diagnostics.metrics;
    summary.delayRobustness = delay;
    summary.validation = validation;
    summary.population = evaluation.diagnostics.population;
    summary.cerebellar = evaluation.diagnostics.cerebellar;
    summary.drives = evaluation.diagnostics.drives;
    summary.parameterNorms = evaluation.diagnostics.parameterNorms;
    summary.figureFiles = figureFiles;
    summary.paths = paths;
    summary.stageBPlanning.primaryNoiseHz = 0.2;
    summary.stageBPlanning.activeConfiguredNoiseHz = ...
        params.noise.sigmaDynamicHz;
    summary.stageBPlanning.stageBWasRun = false;
    summary.noLesionRun = true;
    if validation.allPassed
        summary.recommendation = ...
            'ready for explicit review before Stage B';
    elseif summary.training.lossStillImprovingAtEnd
        summary.recommendation = 'continue Stage A';
    else
        summary.recommendation = 'stop and review Stage A failure';
    end
    summary.bestModelParameterNorm = parameter_vector_norm(model);
end

function [components, dominant] = loss_components_at_best(history, params)
    names = fieldnames(history.validationComponents);
    values = nan(numel(names), 1);
    weighted = nan(numel(names), 1);
    for nameIndex = 1:numel(names)
        name = names{nameIndex};
        values(nameIndex) = history.validationComponents.(name)( ...
            history.bestIteration);
        weighted(nameIndex) = values(nameIndex) * loss_weight(name, params);
        components.(name).unweighted = values(nameIndex);
        components.(name).weighted = weighted(nameIndex);
    end
    [~, order] = sort(weighted, 'descend');
    count = min(5, numel(order));
    dominant.names = names(order(1:count));
    dominant.weightedValues = weighted(order(1:count));
    dominant.unweightedValues = values(order(1:count));
end

function weight = loss_weight(name, params)
    training = params.training;
    switch name
        case 'preGoPosition'
            weight = training.preGoPositionLossWeight;
        case 'preGoVelocity'
            weight = training.preGoVelocityLossWeight;
        case 'endpointUrgency'
            weight = training.endpointUrgencyLossWeight;
        case 'terminalPosition'
            weight = training.terminalPositionLossWeight;
        case 'terminalVelocity'
            weight = training.terminalVelocityLossWeight;
        case 'holdPosition'
            weight = training.holdPositionLossWeight;
        case 'holdVelocity'
            weight = training.holdVelocityLossWeight;
        case 'velocityEffort'
            weight = training.velocityEffortLossWeight;
        case 'activity'
            weight = training.activityRegularization;
        case 'weight'
            weight = training.weightRegularization;
        otherwise
            error('V2Model:LossComponent', ...
                'Unknown loss component: %s.', name);
    end
end

function value = parameter_vector_norm(model)
    vector = pack_v2_trainables(model);
    value = norm(double(vector));
end
