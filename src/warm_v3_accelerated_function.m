function seconds = warm_v3_accelerated_function(functionHandle, ...
        parameterVector, task, noise, gpu, callCount)
    seconds = nan(callCount, 1);
    for callIndex = 1:callCount
        startTime = tic;
        [~, ~] = dlfeval(functionHandle, parameterVector, task, noise);
        wait(gpu);
        seconds(callIndex) = toc(startTime);
        fprintf('V3 accelerated warm-up %d/%d: %.3f s\n', ...
            callIndex, callCount, seconds(callIndex));
    end
end
