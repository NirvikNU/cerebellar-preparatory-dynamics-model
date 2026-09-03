function cfg = stage_2b_cerebellum_config(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end
    cfg = stage_2b_kao_config(projectRoot);
    cfg.resultsRoot = fullfile(projectRoot, 'results', 'stage_2b_cerebellum');
    cfg.plotsRoot = fullfile(projectRoot, 'plots', 'stage_2b_cerebellum');
    cfg.plotsPngRoot = fullfile(cfg.plotsRoot, 'png');
    cfg.plotsFigRoot = fullfile(cfg.plotsRoot, 'fig');
    cfg.controller.inputDimension = 13;
    cfg.controller.fixedActuatorDimension = 13;
    cfg.analysis.primarySeed = 62001;
    cfg.analysis.confirmatorySeed = 63001;
    cfg.analysis.cloudDirectionsPerTargetNorm = 64;
    cfg.analysis.cloudNorms = [0.025; 0.050; 0.100];
    cfg.analysis.cloudDurationS = 0.300;
    cfg.analysis.perturbationTimesS = [0.050; 0.200; 0.400];
    cfg.analysis.perturbationNorm = 0.050;
    cfg.analysis.finiteTimesS = [0.050; 0.100; 0.200; 0.300; 0.500];
    cfg.analysis.alignmentDimensions = [10; 15];
    cfg.analysis.randomSubspaceDraws = 10000;
    cfg.analysis.publishedPrepWindowS = [0.150, 0.450];
    cfg.analysis.publishedMoveWindowS = [-0.050, 0.250];
    cfg.analysis.sensitivityPrepWindowS = [0.200, 0.500];
    cfg.analysis.sensitivityMoveWindowS = [0.000, 0.300];
    cfg.analysis.canonicalPreparationDurationsS = [0; 0.050; 0.100; ...
        0.200; 0.300; 0.500];
    cfg.analysis.flowTarget = 1;
    cfg.analysis.flowGridExtent = 0.25;
    cfg.analysis.flowGridPoints = 21;
    cfg.validation.orthonormalTolerance = 1e-10;
    cfg.validation.potencyFractionMinimum = 0.94;
    cfg.status = 'STAGE 2B-CEREBELLUM — FIXED TOP-13-Q NORMATIVE CAPACITY BOUND';
end
