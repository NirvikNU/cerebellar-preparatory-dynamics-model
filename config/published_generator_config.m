function cfg = published_generator_config(projectRoot)
    if nargin < 1 || isempty(projectRoot)
        projectRoot = fileparts(fileparts(mfilename('fullpath')));
    end
    referenceRoot = fullfile(projectRoot, 'third_party', ...
        'kao_optimal_preparation', 'local_cache', ...
        'kao_optimal_preparation', 'native_reference_40077d2');
    cfg.projectRoot = projectRoot;
    cfg.referenceRoot = referenceRoot;
    cfg.dataRoot = fullfile(referenceRoot, 'full_precision');
    cfg.resultsRoot = fullfile(projectRoot, 'results', 'stage_1');
    cfg.plotsRoot = fullfile(projectRoot, 'plots', 'stage_1');
    cfg.plotsPngRoot = fullfile(cfg.plotsRoot, 'png');
    cfg.plotsFigRoot = fullfile(cfg.plotsRoot, 'fig');
    cfg.upstreamCommit = '40077d2da16e68ab2ab2cff59ec692b97315980b';
    cfg.equivalence.primaryNrmseTolerance = 1e-3;
    cfg.equivalence.endpointToleranceM = 1e-4;
    cfg.equivalence.lyapunovRelativeTolerance = 1e-10;
    cfg.acceptance.rankCorrelationIsDescriptive = true;
    cfg.acceptance.requireCompleteBandOrdering = true;
    cfg.acceptance.status = ...
        'ACCEPTED — FIRST 10 QC-PASSING 10-CM SOURCE-FAITHFUL ISNS';
    cfg.potency.perturbationNorm = 0.10;
    cfg.potency.directionsPerBand = 5;
    cfg.potency.earlyWindowS = 0.100;
    cfg.mapping.seed = 20210825;
    cfg.mapping.samplesPerMovement = 12;
    cfg.mapping.perturbationNorm = 0.05;
    cfg.mapping.coordinateCount = 20;
    cfg.mapping.trainFraction = 0.75;
    cfg.mapping.ridge = 1e-8;
    cfg.plot.fontSize = 16;
    cfg.plot.tickDirection = 'out';
    cfg.plot.axisColor = 'k';
    cfg.plot.axisLineWidth = 0.3;
    cfg.plot.resolution = 200;
    cfg.plot.colors = [
        1, 0, 0.160000000000000
        1, 0.600954000000000, 0
        0.254901960784314, 0.411764705882353, 0.882352941176471
        0, 1, 0.147586000000000
        0.250980392156863, 0.878431372549020, 0.815686274509804
        0.313725490196078, 0.784313725490196, 0.470588235294118
        0.482737000000000, 0, 1
        1, 0, 0.750000000000000];
end
