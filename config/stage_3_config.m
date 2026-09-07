function cfg = stage_3_config(root)
    % Predeclared bounded inverse-design family; never tune from movement.
    if nargin<1, root=fileparts(fileparts(mfilename('fullpath'))); end
    cfg.projectRoot=root; cfg.task='STAGE3-CORTICAL-STATE-FEASIBILITY-01';
    cfg.checkpoint='302138aacac1c81132f57c2da3578e5b29494ffb';
    cfg.networkCount=10; cfg.targetCount=8; cfg.directionCount=3;
    cfg.alpha=[.1 .2 .35 .5 .75 1]; cfg.betaNormalized=[.1 .25 .5 .75 1 1.25];
    cfg.betaConvention='beta=betaNormalized*sqrt(T/d); normalized total variance ratio=alpha^2+betaNormalized^2';
    cfg.directionSeedBase=2026090800; cfg.directionSeedStride=100;
    cfg.syntheticSeed=2026090810; cfg.nullSeedBase=2026090900;
    cfg.bootstrapSeed=2026091000; cfg.bootstrapDraws=10000; cfg.nullDraws=10000;
    cfg.nullConfidenceFamilySize=10000; cfg.nullFamilyError=.01;
    cfg.nullHoeffdingRadius=sqrt(log(2*cfg.nullConfidenceFamilySize/cfg.nullFamilyError)/(2*cfg.nullDraws));
    cfg.alignmentMargin=.005; cfg.prMargin=1e-6;
    cfg.kappaMargin=3; cfg.nu=3; cfg.preparationMs=500;
    cfg.dt=.0002; cfg.savedDt=.001; cfg.tau=.15;
    cfg.prepGO=-100:10:0; cfg.fullGO=-500:10:0; cfg.fullMO=-50:10:450;
    cfg.varianceThreshold=.95; cfg.rankMultiplier=100;
    cfg.modulationEnvelope=[.25 2]; cfg.rateMultiplier=3; cfg.stateMultiplier=3;
    cfg.inputMultiplier=5; cfg.settleRelativeTolerance=1e-4;
    cfg.equilibriumRelativeTolerance=1e-10; cfg.algebraTolerance=1e-10;
    cfg.intactHandToleranceM=1e-5; cfg.intactReleaseRelativeTolerance=1e-7;
    cfg.earlyMovementReferenceMs=0:200;
    cfg.additionalSolutionsPerNetwork=3;
    cfg.primaryRule='Among points feasible in all 10 networks at direction 1, minimize abs(log(alpha^2+b^2)); ties: descending alpha, ascending b. If none, no primary.';
    cfg.sampleRule='One per direction 1..3 if feasible: direction 1 nearest unit variance; later directions maximize minimum normalized alpha/b distance to earlier samples; ties use primary ordering.';
    cfg.nonorthogonality=[.05 .1]; cfg.gainMarginFactors=[.9 1.1];
    cfg.sensitivityScope='Member 1, first direction, primary point only; report unavailable if primary absent; preserve state definitions and primary normalization, recompute actual reference covariance/null.';
    cfg.stepCheckDt=.0001; cfg.stepCurveRelativeTolerance=.01;
    cfg.stepReleaseRelativeTolerance=1e-4;
    cfg.maxGridProtocols=1080; cfg.maxPreparationProtocols=1220;
    cfg.maxMovementTargetRollouts=600; cfg.maxWallSeconds=3600;
    cfg.statistics='Two primary constructed-geometry exact tests in one BH family; primary early-movement paired test separately; diagnostics/samples descriptive, networks independent.';
    cfg.ensembleRoot=fullfile(root,'results','stage_1','current','ensemble');
    cfg.resultsRoot=fullfile(root,'results','stage_3','current');
    cfg.cacheRoot=fullfile(cfg.resultsRoot,'cache');
    cfg.manifestRoot=fullfile(root,'artifacts','manifests','stage3_cortical_state_feasibility');
    cfg.plotsPngRoot=fullfile(root,'plots','stage_3','png');
    cfg.plotsFigRoot=fullfile(root,'plots','stage_3','fig');
    cfg.plot=struct('fontSize',16,'tickDirection','out','axisColor',[.15 .15 .15], ...
        'axisLineWidth',1,'resolution',160);
end
