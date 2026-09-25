function cfg=ns_paths(root)
    addpath(fullfile(root,'analysis','paper_ready','stabilization_eta'));
    cfg=eta_paths(root); cfg.old=cfg; cfg.root=root;
    cfg.dest=fullfile(root,'results','paper_ready','noise_sensitivity');
    cfg.raw=fullfile(root,'results','paper_ready','cache','noise_sensitivity');
    cfg.manifest=fullfile(root,'artifacts','manifests','paper_ready','noise_sensitivity');
    cfg.eta=[0 1]; cfg.oldEta=[5 1];
    cfg.pairs=[.05 .1;.1 .1;.2 .1;.1 .05;.1 .2]; cfg.grid=logspace(-8,4,25);
    for path={cfg.dest,cfg.raw,cfg.manifest}, if ~isfolder(path{1}), mkdir(path{1}); end, end
end
