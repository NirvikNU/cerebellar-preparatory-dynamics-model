function cfg = stage_2_geometry_config(root)
    % R2 analysis-only contract; original simulation configuration stays fixed.
    if nargin<1, root=fileparts(fileparts(mfilename('fullpath'))); end
    cfg=stage_2_config(root);
    cfg=rmfield(cfg,{'floor','floorUnits','pcCount','moveEpochMs', ...
        'fullReferenceMs','fullReferenceDefinition'});
    cfg.task='STAGE2-LAMBDA-SWEEP-01-R2';
    cfg.startCheckpoint='4938fe927b59a04322f018d5e8742d9047213c02';
    cfg.originalResultsRoot=cfg.resultsRoot;
    cfg.resultsRoot=fullfile(cfg.resultsRoot,'neural_geometry_r2');
    cfg.fullGoMs=-500:10:0;
    cfg.fullMoMs=-50:10:450;
    cfg.prepMoveCueMs=150:10:450;
    cfg.prepMoveMoMs=-50:10:350;
    cfg.speedFraction=0.2;
    cfg.varianceThreshold=0.95;
    cfg.pcRule='Minimum strictly >95% separately; common K=max(K1,K2)';
    cfg.normalization='Reference sample SD; no floor; stop if nonfinite/degenerate';
    cfg.degeneracyEpsMultiplier=100;
    cfg.onsetRule='First saved 1-ms speed sample >=20% peak; previous sample below';
    cfg.centering='Align each target window, normalize, then center across targets per relative time';
    cfg.nullReference='GO -500:10:0 concatenated with target-specific MO -50:10:450; overlap retained';
    cfg.bhFamilies='Seven PR-vs-reference; seven observed-vs-expected AI; motor-error tests unchanged';
end
