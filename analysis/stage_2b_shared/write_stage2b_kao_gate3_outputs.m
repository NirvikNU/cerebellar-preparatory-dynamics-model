function output = write_stage2b_kao_gate3_outputs(complete, cfg)
%WRITE_STAGE2B_KAO_GATE3_OUTPUTS Save machine-readable Gate-3 outputs.

results = complete.results;
outputDirectory = cfg.workResultsRoot;
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end
tableDirectory = fullfile(outputDirectory, 'tables');
if ~exist(tableDirectory, 'dir')
    mkdir(tableDirectory);
end

tables = results;
ensembleNames = fieldnames(complete.ensemble);
for index = 1:numel(ensembleNames)
    tables.(['ensemble_' ensembleNames{index}]) = ...
        complete.ensemble.(ensembleNames{index});
end
tableNames = fieldnames(tables);
for tableIndex = 1:numel(tableNames)
    name = tableNames{tableIndex};
    value = tables.(name);
    if istable(value)
        writetable(value, fullfile(tableDirectory, name + ".csv"));
    end
end

nullDirectory = fullfile(outputDirectory, 'alignment_nulls');
if ~exist(nullDirectory, 'dir')
    mkdir(nullDirectory);
end
for networkIndex = 1:cfg.ensemble.count
    projectNull = results.alignmentNull( ...
        results.alignmentNull.Network == networkIndex, :);
    sourceNull = results.sourceAlignmentNull( ...
        results.sourceAlignmentNull.Network == networkIndex, :);
    writetable(projectNull, fullfile(nullDirectory, ...
        sprintf('network_%02d_project_k95_null_10000.csv', networkIndex)));
    writetable(sourceNull, fullfile(nullDirectory, ...
        sprintf('network_%02d_source_k80_null_10000.csv', networkIndex)));
end

save(fullfile(outputDirectory, 'stage2b_kao_gate3_complete.mat'), ...
    'complete', '-v7.3');

summary = struct();
summary.stage = 'Stage 2B-Kao';
summary.gate = 'Gate 3';
summary.status = cfg.status;
summary.networkCount = complete.networkCount;
summary.nullDrawsPerNetwork = complete.nullDraws;
summary.figureCount = 9;
summary.figure10Deleted = true;
summary.controllerStableCount = sum( ...
    results.controller.MaximumCareClosedLoopRealEigenvalue < 0);
summary.allFixedPointChecksPass = all( ...
    results.targetValidation.FixedPointResidualNorm < ...
    cfg.validation.fixedPointTolerance);
summary.allJacobianChecksPass = all( ...
    results.targetValidation.JacobianDirectionalRelativeError < ...
    cfg.validation.jacobianDirectionalTolerance);
summary.allSpectralChecksPass = all( ...
    results.targetValidation.SpectralAbscissaPerS < 0);
summary.medianObservedAlignment = median(results.alignment.ObservedAlignment);
summary.medianExpectedAlignment = median(results.alignment.NullMedian);
summary.bhSignificantAlignmentCount = sum( ...
    results.alignment.BhAdjustedLowerTailP < 0.05);
summary.preparationPRWilcoxonP = results.prStatistics.RawP(1);
summary.preparationPRBHAdjustedP = results.prStatistics.BhAdjustedP(1);
summary.movementPRWilcoxonP = results.prStatistics.RawP(2);
summary.movementPRBHAdjustedP = results.prStatistics.BhAdjustedP(2);
summary.maximumControllerReloadDifference = max( ...
    results.controller.MaximumGainReloadDifference);
summary.runtimeSeconds = complete.runtimeSeconds;
summaryJson = jsonencode(summary, 'PrettyPrint', true);
summaryPath = fullfile(outputDirectory, 'stage2b_kao_gate3_summary.json');
fileId = fopen(summaryPath, 'w');
cleanup = onCleanup(@() fclose(fileId));
fprintf(fileId, '%s\n', summaryJson);

output = struct('Directory', outputDirectory, 'Summary', summary, ...
    'SummaryPath', summaryPath, 'TableDirectory', tableDirectory, ...
    'NullDirectory', nullDirectory);
end
