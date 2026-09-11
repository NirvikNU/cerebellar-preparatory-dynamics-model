function cfg = stage3_prediction_paths(root)
    if nargin<1, root=fileparts(fileparts(fileparts(mfilename('fullpath')))); end
    cfg=stage3_bio_paths(root);
    cfg.task='STAGE3-PREDICTION-VALIDATION-01';
    cfg.checkpoint='c40e0eb74679a0122cb1e54c784c2e56946a5e14';
    cfg.predRoot=fullfile(cfg.resultsRoot,'prediction_validation');
    cfg.predCache=fullfile(cfg.cacheRoot,'prediction_validation');
    cfg.noiseLevels=[.05 .10 .20]; cfg.primaryNoiseIndex=2;
    cfg.trials=30; cfg.ridgeGrid=logspace(-8,4,25); cfg.permutations=100;
    cfg.noiseSeedBase=310000000; cfg.leakSeed=319000001;
    cfg.stateRmsTolerance=.01; cfg.handRmsToleranceM=.001;
    cfg.deterministicTolerance=1e-10;
    if ~isfolder(cfg.predRoot), mkdir(cfg.predRoot); end
    if ~isfolder(cfg.predCache), mkdir(cfg.predCache); end
end
