function seconds = warm_v2_accelerated_function(functionHandle, ...
        parameterVector, task, noise, gpu, callCount)
    seconds = nan(callCount, 1);
    for callIndex = 1:callCount
        startTime = tic;
        [~, ~] = dlfeval(functionHandle, parameterVector, task, noise);
        wait(gpu);
        seconds(callIndex) = toc(startTime);
    end
end
