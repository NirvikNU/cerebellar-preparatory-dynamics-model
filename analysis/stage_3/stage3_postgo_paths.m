function cfg = stage3_postgo_paths(root)
    cfg=stage3_prediction_paths(root);
    cfg.task='STAGE3-PREGO-NOISE-CAUSAL-DIAGNOSTIC-01';
    cfg.checkpoint='326832944924378f52efe5e2d66f90d9e6d448c2';
    cfg.postRoot=fullfile(cfg.resultsRoot,'postgo_noise_diagnostic');
    cfg.postCache=fullfile(cfg.cacheRoot,'postgo_noise_diagnostic');
    if ~isfolder(cfg.postRoot), mkdir(cfg.postRoot); end
    if ~isfolder(cfg.postCache), mkdir(cfg.postCache); end
end
