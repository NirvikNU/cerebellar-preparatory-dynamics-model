function [comparison, pass] = compare_native_matlab(cfg, model, simulation, theta, hand)
    rows = cell(model.nMovements, 1);
    for movement = 1:model.nMovements
        nativeRates = readmatrix(fullfile(cfg.dataRoot, ...
            sprintf('native_cortical_r1_%d.tsv', movement)), 'FileType', 'text');
        nativeTorque = readmatrix(fullfile(cfg.dataRoot, ...
            sprintf('native_torque_r1_%d.tsv', movement)), 'FileType', 'text');
        nativeTheta = readmatrix(fullfile(cfg.dataRoot, ...
            sprintf('native_theta_r1_%d.tsv', movement)), 'FileType', 'text');
        nativeHand = readmatrix(fullfile(cfg.dataRoot, ...
            sprintf('native_hand_r1_%d.tsv', movement)), 'FileType', 'text');
        matlabRates = simulation.rates(:, :, movement);
        matlabTorque = simulation.torque(:, :, movement);
        matlabTheta = theta(:, :, movement);
        matlabHand = hand(:, :, movement);
        values = [normalized_rmse(matlabRates, nativeRates), ...
            normalized_rmse(matlabTorque, nativeTorque), ...
            normalized_rmse(matlabTheta, nativeTheta), ...
            normalized_rmse(matlabHand, nativeHand), ...
            norm(matlabHand(end, [1, 3]) - nativeHand(end, [1, 3]))];
        rows{movement} = values;
    end
    matrix = vertcat(rows{:});
    comparison = array2table(matrix, 'VariableNames', ...
        {'CorticalNRMSE','TorqueNRMSE','ThetaNRMSE','HandNRMSE','EndpointErrorM'});
    comparison.Movement = (1:model.nMovements).';
    comparison = movevars(comparison, 'Movement', 'Before', 1);
    pass = all(matrix(:, 1:4) <= cfg.equivalence.primaryNrmseTolerance, 'all') ...
        && all(matrix(:, 5) <= cfg.equivalence.endpointToleranceM);
end

function value = normalized_rmse(actual, expected)
    difference = actual - expected;
    referenceRms = sqrt(mean(expected(:).^2));
    value = sqrt(mean(difference(:).^2)) / max(referenceRms, eps);
end
