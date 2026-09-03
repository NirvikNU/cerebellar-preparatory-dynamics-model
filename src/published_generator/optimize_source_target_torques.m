function [torques, diagnostics] = optimize_source_target_torques(cfg, target, arm)
    rng(cfg.gate1.targetTorqueSeed, 'twister');
    nTorqueSamples = size(target.hands, 1) - 1;
    initial = 1e-4 * randn(nTorqueSamples, 2, numel(target.anglesDeg));
    targetHands = target.hands;
    nMovements = size(initial, 3);
    torqueCells = cell(nMovements, 1);
    diagnosticCells = cell(nMovements, 1);
    if isempty(gcp('nocreate'))
        parpool('Processes', min(nMovements, feature('numcores')));
    end
    parfor movement = 1:nMovements
        [torqueCells{movement}, diagnosticCells{movement}] = optimize_one( ...
            initial(:, :, movement), targetHands(:, :, movement), arm, cfg);
    end
    torques = cat(3, torqueCells{:});
    diagnostics = struct('seed', cfg.gate1.targetTorqueSeed, ...
        'usedGpu', false, 'perMovement', {diagnosticCells});
end

function [parameters, diagnostics] = optimize_one(parameters, targetHands, arm, cfg)
    lossFcn = @(value) source_target_torque_objective_adjoint( ...
        value, targetHands, arm, cfg.gate1.targetDtS);
    solver = lbfgsState(HistorySize=cfg.gate1.lbfgsHistorySize);
    history = nan(cfg.gate1.targetTorqueMaxIterations, 4);
    stopReason = "maximum iterations";
    previousLoss = inf;
    for iteration = 1:cfg.gate1.targetTorqueMaxIterations
        [parameters, solver] = lbfgsupdate(parameters, lossFcn, solver, ...
            MaxNumLineSearchIterations=cfg.gate1.maxLineSearchIterations, ...
            NumLossFunctionOutputs=4);
        lossValue = double(solver.Loss);
        gradientNorm = double(solver.GradientsNorm);
        trajectoryError = double(solver.AdditionalLossFunctionOutputs{1});
        roughness = double(solver.AdditionalLossFunctionOutputs{2});
        history(iteration, :) = [lossValue, gradientNorm, trajectoryError, roughness];
        if ~isfinite(lossValue) || solver.LineSearchStatus == "failed"
            stopReason = "nonfinite loss or failed line search";
            break
        end
        if gradientNorm <= cfg.gate1.targetTorqueGradientTolerance
            stopReason = "gradient tolerance";
            break
        end
        relativeChange = abs(previousLoss - lossValue) / max(abs(previousLoss), 1);
        if iteration > 1 && relativeChange <= cfg.gate1.targetTorqueRelativeChangeTolerance
            stopReason = "relative-loss tolerance";
            break
        end
        previousLoss = lossValue;
    end
    diagnostics = struct('iterations', iteration, ...
        'stopReason', char(stopReason), 'finalLoss', history(iteration, 1), ...
        'finalGradientNorm', history(iteration, 2), ...
        'finalTrajectoryError', history(iteration, 3), ...
        'finalRoughness', history(iteration, 4), ...
        'history', history(1:iteration, :));
end
