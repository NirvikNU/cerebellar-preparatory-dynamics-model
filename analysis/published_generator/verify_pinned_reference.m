function verification = verify_pinned_reference(cfg)
    manifestPath = fullfile(cfg.referenceRoot, 'artifact_manifest.tsv');
    expected = readtable(manifestPath, 'FileType', 'text', ...
        'Delimiter', '\t', 'VariableNamingRule', 'preserve', ...
        'TextType', 'string');
    actualHash = strings(height(expected), 1);
    actualBytes = zeros(height(expected), 1);
    for row = 1:height(expected)
        relative = replace(expected.relative_path(row), '/', filesep);
        path = fullfile(cfg.referenceRoot, relative);
        assert(isfile(path), 'Pinned artifact missing: %s', path);
        info = dir(path);
        actualBytes(row) = info.bytes;
        actualHash(row) = sha256_file(path);
    end
    byteMatch = actualBytes == expected.bytes;
    hashMatch = strcmpi(actualHash, expected.sha256);
    sourceRoot = fileparts(cfg.referenceRoot);
    [status, head] = system(sprintf('git -C "%s" rev-parse HEAD', sourceRoot));
    assert(status == 0, 'Could not read pinned source commit.');
    head = strtrim(head);
    verification = struct('manifestEntries', height(expected), ...
        'byteMatches', nnz(byteMatch), 'hashMatches', nnz(hashMatch), ...
        'allMatched', all(byteMatch & hashMatch), 'sourceHead', head, ...
        'sourceHeadMatched', strcmp(head, cfg.gate1.sourceCommit));
    assert(verification.allMatched, 'Pinned native-reference manifest mismatch.');
    assert(verification.sourceHeadMatched, 'Pinned source HEAD mismatch.');
end
