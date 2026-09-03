function [anglesDeg, targetHands, torques, optimizerDiagnostics] = ...
        load_native_target_torque_benchmark(cfg)
    anglesDeg = linspace(-36, 216, 8);
    targetHands = zeros(600, 4, 8);
    torques = zeros(599, 2, 8);
    for movement = 1:8
        targetHands(:, :, movement) = readmatrix(fullfile(cfg.dataRoot, ...
            sprintf('target_hand_r1_%d.tsv', movement)), 'FileType', 'text');
        torques(:, :, movement) = readmatrix(fullfile(cfg.dataRoot, ...
            sprintf('target_torque_r1_%d.tsv', movement)), 'FileType', 'text');
    end
    logPath = fullfile(cfg.referenceRoot, 'official_results', ...
        'stage1_native_reaches.log');
    logText = fileread(logPath);
    tokens = regexp(logText, ...
        'step:\s*(\d+)\s*\|\s*loss:\s*([0-9.eE+-]+)', 'tokens');
    perMovement = cell(8, 1);
    movement = 0;
    for index = 1:numel(tokens)
        step = str2double(tokens{index}{1});
        loss = str2double(tokens{index}{2});
        if step == 0
            movement = movement + 1;
        end
        perMovement{movement} = struct('iterations', step, ...
            'stopReason', 'official optimizer completed; last logged step', ...
            'finalLoss', loss, 'finalGradientNorm', NaN);
    end
    assert(movement == 8, 'Could not parse all native target optimizations.');
    optimizerDiagnostics = struct('perMovement', {perMovement}, ...
        'source', 'official_results/stage1_native_reaches.log');
end
