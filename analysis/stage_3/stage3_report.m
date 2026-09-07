function report = stage3_report(cfg)
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); r=s.result;
    map=readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv'));
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=s.registry;
    counts=zeros(30,8); row=0;
    for n=1:10
        for d=1:3
            row=row+1; a=map(map.network==n & map.direction==d,:);
            counts(row,:)=[n,d,36,sum(a.tested),sum(a.analytical),sum(a.physical),sum(a.physical & a.finitePhenotype),sum(a.feasible)];
        end
    end
    counts=array2table(counts,'VariableNames',{'network','direction','declared','nonlinearTested','analytical','physical','empirical','allCriteria'});
    writetable(counts,fullfile(cfg.resultsRoot,'generality_counts.csv'));
    additional=zeros(numel(r.additional),7);
    for k=1:numel(r.additional)
        a=r.additional{k}; additional(k,:)=[a.network,a.direction,a.alpha,a.betaNormalized,mean(a.targetErrorsMM),mean(a.endpointErrorMM),a.finiteMovement];
    end
    additional=array2table(additional,'VariableNames',{'network','direction','alpha','betaNormalized','earlyErrorMM','endpointErrorMM','finiteMovement'});
    writetable(additional,fullfile(cfg.resultsRoot,'sampled_solution_summary.csv'));
    nested=NaN(10,3);
    for n=1:10
        rows=additional(additional.network==n,:); nested(n,:)=[n,height(rows),median(rows.earlyErrorMM)];
    end
    writetable(array2table(nested,'VariableNames',{'network','sampledSolutions','withinNetworkMedianEarlyErrorMM'}),fullfile(cfg.resultsRoot,'nested_movement_summary.csv'));
    if r.hasPrimary
        metrics=array2table([(1:10).',r.metrics.pr,r.metrics.alignmentObservedExpected,r.metrics.earlyErrorMM], ...
            'VariableNames',{'network','prIntact','prBlock','observed','expected','earlyIntactMM','earlyBlockMM'});
        writetable(metrics,fullfile(cfg.resultsRoot,'primary_metrics.csv'));
    end
    report=struct('task',cfg.task,'status','COMPUTED; scientific review pending', ...
        'declaredPoints',height(map),'nonlinearTested',sum(map.tested),'analyticallySufficient',sum(map.analytical), ...
        'physical',sum(map.physical),'empiricalPhysical',sum(map.physical & map.finitePhenotype), ...
        'certifiedFeasible',sum(map.feasible),'outsideBoundEmpiricalSuccess',sum(map.physical & map.finitePhenotype & ~map.analytical), ...
        'negativeRate',sum(~map.rateRealizable),'modulationEnvelopeRejected',sum(~map.modulationOK), ...
        'endpointBoundsRejected',sum(~map.endpointBoundsOK),'primaryGridIndex',registry.primaryGridIndex, ...
        'additionalSolutionCount',numel(r.additional),'statistics',r.statistics, ...
        'preparationProtocols',r.preparationProtocols,'movementTargetRollouts',r.movementTargetRollouts, ...
        'maxAnalyticFinitePRDifference',max(abs(map.prBlock-map.analyticPRBlock),[],'omitnan'), ...
        'maxAnalyticFiniteAIDifference',max(abs(map.observed-map.analyticAI),[],'omitnan'), ...
        'maxNullSE',max(map.nullSE,[],'omitnan'),'maxNullHalfDifference',max(abs(map.nullHalfDifference),[],'omitnan'), ...
        'HoeffdingRadius',cfg.nullHoeffdingRadius,'sensitivity',{r.sensitivity});
    if r.hasPrimary
        report.primaryAlpha=registry.primary{1}.alpha; report.primaryBetaNormalized=registry.primary{1}.betaNormalized;
        report.stepCheck=r.stepCheck;
    end
    stage3_write_json(fullfile(cfg.resultsRoot,'REPORT.json'),report);
    disp(report); disp(counts); disp(additional);
end
