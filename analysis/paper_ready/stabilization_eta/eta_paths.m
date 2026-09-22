function cfg = eta_paths(root)
    addpath(fullfile(root,'analysis','stage_3'),fullfile(root,'analysis','paper_ready'), ...
        fullfile(root,'analysis','paper_ready','alignment95'),fullfile(root,'analysis','paper_ready','prediction'));
    cfg=stage3_bio_paths(root);
    cfg.dest=fullfile(root,'results','paper_ready','stabilization_eta');
    cfg.raw=fullfile(root,'results','paper_ready','cache','stabilization_eta');
    cfg.manifest=fullfile(root,'artifacts','manifests','paper_ready','stabilization_eta');
    cfg.paper=fullfile(root,'results','paper_ready');
    cfg.eta=[1 .75 .5 .25 0]; cfg.names={'Intact','Block'};
    cfg.previousPolicies=[1 4]; cfg.flags=[1 1;0 0];
    for path={cfg.dest,cfg.raw}, if ~isfolder(path{1}), mkdir(path{1}); end, end
end
