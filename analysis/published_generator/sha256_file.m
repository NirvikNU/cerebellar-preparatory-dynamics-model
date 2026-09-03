function value = sha256_file(path)
    command = sprintf('certutil -hashfile "%s" SHA256', strrep(path, '"', '""'));
    [status, output] = system(command);
    assert(status == 0, 'Could not hash %s: %s', path, output);
    match = regexp(output, '[0-9a-fA-F]{64}', 'match', 'once');
    assert(~isempty(match), 'Could not parse SHA-256 for %s.', path);
    value = lower(string(match));
end
