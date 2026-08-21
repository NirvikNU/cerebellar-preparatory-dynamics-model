function gpu = select_required_gpu(requiredName)
    for deviceIndex = 1:gpuDeviceCount("available")
        candidate = gpuDevice(deviceIndex);
        if strcmpi(candidate.Name, requiredName)
            gpu = candidate;
            return;
        end
    end
    error('IsnModel:RequiredGpuNotFound', ...
        'Required GPU "%s" was not found.', requiredName);
end
