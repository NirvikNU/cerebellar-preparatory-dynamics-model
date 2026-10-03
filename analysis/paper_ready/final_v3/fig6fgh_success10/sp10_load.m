function raw=sp10_load(root,n,p)
    % Read frozen native movement evidence only. No models are instantiated.
    raw=mv09_load(root,n,p);
    raw.moMs=h5read(fullfile(root,raw.path),'/raw/move/moMs');
    raw.moMs=raw.moMs(:);
    assert(numel(raw.moMs)==240 && all(isfinite(raw.moMs)));
    assert(all(raw.moMs==round(raw.moMs) & raw.moMs>=0 & raw.moMs<600));
end
