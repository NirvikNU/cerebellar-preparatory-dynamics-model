function manifest = hash_tree(root, relativeRoots)
    pathGroups = cell(numel(relativeRoots), 1);
    for index = 1:numel(relativeRoots)
        current = fullfile(root, relativeRoots(index));
        if isfile(current)
            pathGroups{index} = string(current);
        elseif isfolder(current)
            listing = dir(fullfile(current, '**', '*'));
            listing = listing(~[listing.isdir]);
            pathGroups{index} = string(fullfile({listing.folder}, {listing.name})).';
        else
            pathGroups{index} = strings(0, 1);
        end
    end
    paths = vertcat(pathGroups{:});
    paths = unique(paths, 'stable');
    relativePath = erase(paths, string(root) + filesep);
    bytes = zeros(numel(paths), 1);
    sha256 = strings(numel(paths), 1);
    for index = 1:numel(paths)
        info = dir(paths(index));
        bytes(index) = info.bytes;
        sha256(index) = sha256_file(paths(index));
    end
    manifest = table(relativePath, bytes, sha256, ...
        'VariableNames', {'relative_path', 'bytes', 'sha256'});
end
