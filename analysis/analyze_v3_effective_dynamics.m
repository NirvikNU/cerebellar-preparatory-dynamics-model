function diagnostics = analyze_v3_effective_dynamics( ...
        recurrentMatrix, preparatoryRates, movementRates)
    recurrentMatrix = double(recurrentMatrix);
    preparatoryRates = double(preparatoryRates(:));
    movementRates = double(movementRates(:));
    n = size(recurrentMatrix, 1);
    if ~isequal(size(recurrentMatrix), [n n]) || ...
            numel(preparatoryRates) ~= n || numel(movementRates) ~= n
        error('V3Analysis:EffectiveDimensions', ...
            'Wrec must be square and each rate vector must have N entries.');
    end
    preparatoryMask = preparatoryRates > 0;
    movementMask = movementRates > 0;
    identity = eye(n);
    preparatoryEffective = -identity + ...
        recurrentMatrix .* preparatoryMask';
    movementEffective = -identity + recurrentMatrix .* movementMask';
    diagnostics.preparatoryMask = preparatoryMask;
    diagnostics.movementMask = movementMask;
    diagnostics.activeSetDifferenceCount = ...
        nnz(preparatoryMask ~= movementMask);
    diagnostics.preparatoryEffective = preparatoryEffective;
    diagnostics.movementEffective = movementEffective;
    diagnostics.effectiveDifferenceFrobenius = norm( ...
        movementEffective - preparatoryEffective, 'fro');
end
