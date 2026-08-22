function diagnosis = diagnose_v2_pre_go_leakage(model, params)
    delays = params.evaluation.delayValuesMs;
    targetCount = params.task.numTargets;
    diagnosis.delayMs = delays;
    diagnosis.targetAnglesDeg = params.task.targetAnglesDeg;
    diagnosis.fullRmsSpeedMPerSec = nan(numel(delays), targetCount);
    diagnosis.final150RmsSpeedMPerSec = nan(numel(delays), targetCount);
    diagnosis.final100RmsSpeedMPerSec = nan(numel(delays), targetCount);
    diagnosis.maximumPreGoSpeedMPerSec = nan(numel(delays), targetCount);

    verifyDelays = [500 550 600];
    for delayIndex = 1:numel(verifyDelays)
        task = build_v2_task(params, 1, verifyDelays(delayIndex), []);
        goIndex = task.goIndexByTrial(1);
        expected = task.timeMs < verifyDelays(delayIndex);
        actual = logical(task.preGoMask(1, :));
        if ~isequal(actual, expected) || ~all(actual(1:goIndex - 1)) || ...
                actual(goIndex) || any(actual(goIndex:end))
            error('V2Model:PreGoMaskBoundary', ...
                'Pre-go mask failed at %d ms.', verifyDelays(delayIndex));
        end
        diagnosis.maskVerification(delayIndex).goTimeMs = ...
            verifyDelays(delayIndex);
        diagnosis.maskVerification(delayIndex).goIndex = goIndex;
        diagnosis.maskVerification(delayIndex).lastPreGoTimeMs = ...
            double(task.timeMs(goIndex - 1));
        diagnosis.maskVerification(delayIndex).goSampleMasked = actual(goIndex);
        diagnosis.maskVerification(delayIndex).passed = true;
    end

    for delayIndex = 1:numel(delays)
        delay = delays(delayIndex);
        task = build_v2_task(params, 1, delay, []);
        simulation = simulate_v2_model(model, task, params, ...
            params.seed.delayEvaluation + delayIndex, false);
        speed = reshape(sqrt(sum(simulation.velocity.^2, 1)), ...
            task.numTrials, task.numTimeSteps);
        for trialIndex = 1:task.numTrials
            fullMask = logical(task.preGoMask(trialIndex, :));
            final150Mask = fullMask & task.timeMs >= delay - 150;
            final100Mask = fullMask & task.timeMs >= delay - 100;
            targetIndex = task.targetIndex(trialIndex);
            diagnosis.fullRmsSpeedMPerSec(delayIndex, targetIndex) = ...
                rms_values(speed(trialIndex, fullMask));
            diagnosis.final150RmsSpeedMPerSec(delayIndex, targetIndex) = ...
                rms_values(speed(trialIndex, final150Mask));
            diagnosis.final100RmsSpeedMPerSec(delayIndex, targetIndex) = ...
                rms_values(speed(trialIndex, final100Mask));
            diagnosis.maximumPreGoSpeedMPerSec(delayIndex, targetIndex) = ...
                max(double(speed(trialIndex, fullMask)));
        end
    end
    diagnosis.aggregate.fullRmsSpeedMPerSec = ...
        rms_values(diagnosis.fullRmsSpeedMPerSec);
    diagnosis.aggregate.final150RmsSpeedMPerSec = ...
        rms_values(diagnosis.final150RmsSpeedMPerSec);
    diagnosis.aggregate.final100RmsSpeedMPerSec = ...
        rms_values(diagnosis.final100RmsSpeedMPerSec);
    diagnosis.aggregate.maximumPreGoSpeedMPerSec = ...
        max(diagnosis.maximumPreGoSpeedMPerSec, [], 'all');
end

function value = rms_values(values)
    values = double(values(:));
    value = sqrt(mean(values.^2));
end
