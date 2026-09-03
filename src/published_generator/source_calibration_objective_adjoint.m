function [loss, physicalGradient, moveCost, regularization] = ...
        source_calibration_objective_adjoint(xstars, readout, constants)
    W = constants.W;
    h = constants.h;
    targetTorques = constants.targetTorques;
    n = size(W, 1);
    nE = size(readout, 2);
    nMovements = size(xstars, 2);
    nSteps = constants.nInternalSteps;
    sampleEvery = constants.sampleEvery;
    alpha = constants.dt / constants.tau;
    states = zeros(n, nMovements, nSteps + 1, 'like', xstars);
    states(:, :, 1) = xstars;
    sampleGradients = zeros(n, nMovements, nSteps, 'like', xstars);
    readoutGradient = zeros(size(readout), 'like', readout);
    moveCost = 0;
    sample = 0;
    for step = 1:nSteps
        state = states(:, :, step);
        rates = max(state, 0);
        if mod(step - 1, sampleEvery) == 0
            sample = sample + 1;
            output = readout * rates(1:nE, :);
            target = permute(targetTorques(sample, :, :), [2, 3, 1]);
            difference = output - target;
            weightedDifference = constants.torqueWeightSquared .* difference;
            moveCost = moveCost + constants.trajectoryWeight * constants.samplingDt ...
                * sum(difference .* weightedDifference, 'all');
            outputGradient = 2 * constants.trajectoryWeight * constants.samplingDt ...
                * weightedDifference;
            readoutGradient = readoutGradient + outputGradient * rates(1:nE, :).';
            stateOutputGradient = zeros(n, nMovements, 'like', xstars);
            stateOutputGradient(1:nE, :) = (readout.' * outputGradient) ...
                .* (state(1:nE, :) > 0);
            sampleGradients(:, :, step) = stateOutputGradient;
        end
        time = constants.dt * (step - 1);
        drive = constants.movementInput(time);
        states(:, :, step + 1) = state + alpha * ...
            (-state + W * rates + h + drive);
    end
    assert(sample == size(targetTorques, 1), 'Calibration sample-count mismatch.');
    regularization = constants.readoutRegularization * sum(readout.^2, 'all');
    loss = moveCost + regularization;
    readoutGradient = readoutGradient + ...
        2 * constants.readoutRegularization * readout;
    adjoint = zeros(n, nMovements, 'like', xstars);
    for step = nSteps:-1:1
        state = states(:, :, step);
        adjoint = (1 - alpha) * adjoint ...
            + alpha * (state > 0) .* (W.' * adjoint) ...
            + sampleGradients(:, :, step);
    end
    physicalGradient = struct('xstars', adjoint, 'c', readoutGradient);
end
