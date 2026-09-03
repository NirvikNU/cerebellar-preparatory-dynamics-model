function [xstars, readout, auxiliary] = ...
        source_calibration_unpack(parameters, observabilityBasis, spontaneous, nE, xstarStd)
    deviations = observabilityBasis * parameters.xstars;
    targetNormSquared = size(deviations, 1) * size(deviations, 2) * xstarStd^2;
    deviations = sqrt(targetNormSquared / sum(deviations.^2, 'all')) * deviations;
    xstars = spontaneous + deviations;
    motorStates = [xstars(1:nE, :), spontaneous(1:nE)];
    rightInverse = (motorStates.' * motorStates) \ motorStates.';
    readout = parameters.c - parameters.c * motorStates * rightInverse;
    if nargout > 2
        auxiliary = struct('deviations', deviations, ...
            'motorStates', motorStates, 'rightInverse', rightInverse);
    end
end
