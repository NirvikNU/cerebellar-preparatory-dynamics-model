function [model, diagnostics] = calibrate_source_faithful_generator( ...
        cfg, W, spontaneous, targetTorques, seed, baseModel)
    rng(seed, 'twister');
    n = cfg.gate1.n;
    nE = cfg.gate1.nE;
    A = W - eye(n);
    observability = lyap(A.', eye(n));
    [observabilityBasis, ~, ~] = svd(observability);
    if isempty(spontaneous)
        deviation = randn(n, 1);
        deviation = cfg.gate1.spontaneousStd / std(deviation, 0) * deviation;
        spontaneous = cfg.gate1.spontaneousMean + deviation;
    end
    h = spontaneous - W * max(spontaneous, 0);
    parameters = struct('xstars', ...
        0.1 / sqrt(n) * randn(n, size(targetTorques, 3)), ...
        'c', 0.1 / sqrt(n) * randn(2, nE));
    constants = struct('W', W, 'h', h, 'targetTorques', targetTorques, ...
        'nInternalSteps', size(targetTorques, 1) * round(baseModel.samplingDt / baseModel.dt), ...
        'sampleEvery', round(baseModel.samplingDt / baseModel.dt), ...
        'dt', baseModel.dt, 'samplingDt', baseModel.samplingDt, ...
        'tau', baseModel.tau, 'trajectoryWeight', cfg.gate1.trajectoryWeight, ...
        'torqueWeightSquared', cfg.gate1.weightedTorqueScale.^2, ...
        'readoutRegularization', cfg.gate1.readoutRegularization, ...
        'movementInput', @(time) published_movement_input(time, baseModel), ...
        'observabilityBasis', observabilityBasis, 'spontaneous', spontaneous, ...
        'nE', nE, 'xstarStd', cfg.gate1.xstarStd);
    lossFcn = @(value) source_calibration_parameter_objective(value, constants);
    solver = lbfgsState(HistorySize=cfg.gate1.lbfgsHistorySize);
    history = nan(cfg.gate1.maxCalibrationIterations, 4);
    previousMoveCost = 1e9;
    stopReason = "maximum iterations";
    for iteration = 1:cfg.gate1.maxCalibrationIterations
        [parameters, solver] = lbfgsupdate(parameters, lossFcn, solver, ...
            MaxNumLineSearchIterations=cfg.gate1.maxLineSearchIterations, ...
            NumLossFunctionOutputs=4);
        lossValue = double(solver.Loss);
        gradientNorm = double(solver.GradientsNorm);
        moveCost = double(solver.AdditionalLossFunctionOutputs{1});
        regularization = double(solver.AdditionalLossFunctionOutputs{2});
        relativeChange = abs(previousMoveCost - moveCost) / previousMoveCost;
        history(iteration, :) = [lossValue, moveCost, regularization, relativeChange];
        if ~isfinite(lossValue) || solver.LineSearchStatus == "failed"
            stopReason = "nonfinite loss or failed line search";
            break
        end
        if moveCost < cfg.gate1.calibrationMoveCostStop
            stopReason = "source movement-cost threshold";
            break
        end
        if iteration > 1 && relativeChange < cfg.gate1.calibrationRelativeChangeStop
            stopReason = "source relative-change threshold";
            break
        end
        previousMoveCost = moveCost;
    end
    [xstars, readout] = source_calibration_unpack(parameters, ...
        observabilityBasis, spontaneous, nE, cfg.gate1.xstarStd);
    model = baseModel;
    model.W = W;
    model.A = A;
    model.spontaneous = spontaneous;
    model.h = h;
    model.xstar = xstars;
    model.Ce = readout;
    model.C = [readout, zeros(2, n - nE)];
    model.Qnative = lyap(A.', model.C.' * model.C);
    diagnostics = struct('seed', seed, 'iterations', iteration, ...
        'stopReason', char(stopReason), 'finalLoss', history(iteration, 1), ...
        'finalMoveCost', history(iteration, 2), ...
        'finalRegularization', history(iteration, 3), ...
        'finalRelativeChange', history(iteration, 4), ...
        'finalGradientNorm', gradientNorm, 'history', history(1:iteration, :), ...
        'readoutNullResidual', norm(model.C * max([xstars, spontaneous], 0), 'fro'));
end
