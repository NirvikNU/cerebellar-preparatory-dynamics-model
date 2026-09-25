function cfg=v2_paths(root)
    addpath(fullfile(root,'analysis','paper_ready','noise_sensitivity'));
    cfg=ns_paths(root); cfg.previous=cfg;
    cfg.dest=fullfile(root,'results','paper_ready','final_v2');
    cfg.raw=fullfile(root,'results','paper_ready','cache','final_v2');
    cfg.manifest=fullfile(root,'artifacts','manifests','paper_ready','final_v2');
    cfg.docs=fullfile(root,'docs','paper_ready','final_v2');
    cfg.alpha=[.10 .20 .35 .50 .75 1]; cfg.beta=[.10 .25 .50 .75 1 1.25];
    cfg.targets=[2.6453333944 16.802184]; cfg.lambda=10; cfg.eta=0;
    cfg.componentFlags=[1 1;1 0;0 1;0 0];
    for path={cfg.dest,cfg.raw,cfg.manifest,cfg.docs}
        if ~isfolder(path{1}), mkdir(path{1}); end
    end
end
