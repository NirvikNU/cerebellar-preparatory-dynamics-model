function gradients = source_calibration_unpack_vjp(parameters, auxiliary, ...
        physicalGradient, observabilityBasis, nE)
    motorStates = auxiliary.motorStates;
    rightInverse = auxiliary.rightInverse;
    projector = eye(nE) - motorStates * rightInverse;
    gradientC0 = physicalGradient.c * projector;
    gradientProjector = parameters.c.' * physicalGradient.c;
    gradientProjection = -gradientProjector;
    gradientMotorStates = projector * ...
        (gradientProjection + gradientProjection.') * rightInverse.';
    gradientXstars = physicalGradient.xstars;
    gradientXstars(1:nE, :) = gradientXstars(1:nE, :) ...
        + gradientMotorStates(:, 1:size(gradientXstars, 2));
    rawDeviations = observabilityBasis * parameters.xstars;
    squaredNorm = sum(rawDeviations.^2, 'all');
    scale = sqrt(sum(auxiliary.deviations.^2, 'all') / squaredNorm);
    gradientRaw = scale * (gradientXstars ...
        - rawDeviations * (sum(gradientXstars .* rawDeviations, 'all') / squaredNorm));
    gradients = struct('xstars', observabilityBasis.' * gradientRaw, ...
        'c', gradientC0);
end
