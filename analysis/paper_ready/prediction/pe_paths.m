function cfg = pe_paths(root)
    addpath(fullfile(root,'analysis','stage_3'),fullfile(root,'analysis','paper_ready'));
    cfg=stage3_bio_paths(root); cfg.root=root;
    cfg.dest=fullfile(root,'results','paper_ready','prediction');
    cfg.raw=fullfile(root,'results','paper_ready','cache','prediction');
    cfg.manifest=fullfile(root,'artifacts','manifests','paper_ready','prediction');
    cfg.ridgeGrid=logspace(-8,4,25); cfg.shuffles=100;
    for path={cfg.dest,cfg.raw}, if ~isfolder(path{1}), mkdir(path{1}); end, end
end
