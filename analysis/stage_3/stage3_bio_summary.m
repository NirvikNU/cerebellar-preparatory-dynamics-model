function report = stage3_bio_summary
    % Compact current numerical summaries, never model execution.
    cfg=stage3_bio_paths; destination=fullfile(cfg.bioRoot,'summary.json'); assert(~isfile(destination));
    s=load(fullfile(cfg.bioRoot,'population.mat'),'result'); pop=s.result;
    s=load(fullfile(cfg.bioRoot,'movement.mat'),'result'); move=s.result;
    report=struct('task','STAGE3-BIOLOGICAL-CONTROLLER-RESUME-02','statistics',move.statistics, ...
        'policies',{cfg.policyNames},'primaryK',unique(pop.primaryTable.K).', ...
        'diagnosticKRange',[min(pop.K,[],'all','omitnan'),max(pop.K,[],'all','omitnan')]);
    report.map=jsondecode(fileread(fullfile(cfg.bioRoot,'map_complete.json')));
    report.audit=jsondecode(fileread(fullfile(cfg.bioRoot,'independent_audit.json')));
    fields={'distanceStar','distanceBlock','normalizedEQ','pr','observed','expected','deficit'};
    for j=1:numel(fields)
        field=fields{j}; report.go.(field)=stage2_bootstrap(pop.(field)(:,:,end),pop.bootstrapIndices);
    end
    report.afterCueMs=[50 100 200];
    timeIndices=101+[50 100 200];
    report.readiness=struct('timeMs',report.afterCueMs,'policies',{{}});
    t=readtable(fullfile(cfg.bioRoot,'target_readiness.csv'));
    for policy=1:4
        values=squeeze(pop.fullNormalizedEQ(:,policy,timeIndices));
        state=squeeze(pop.fullDistanceStar(:,policy,timeIndices))./pop.fullDistanceStar(:,policy,101);
        report.readiness.policies{policy}=struct('eq',stage2_bootstrap(values,pop.bootstrapIndices), ...
            'state',stage2_bootstrap(state,pop.bootstrapIndices));
        rows=t(t.policy==policy,:); measures={'eq50ms','eq90ms','state50ms','state90ms'};
        for j=1:numel(measures)
            v=rows.(measures{j}); finite=v(isfinite(v));
            report.crossings(policy).(measures{j})=struct('achievedTargets',numel(finite),'totalTargets',80, ...
                'rangeMs',[min(finite) max(finite)],'pooledTargetMedianMs',median(finite));
        end
    end
    block=t(t.policy==4,:);
    report.blockRelativeGoRange=[min(block.goRelativeBlock),max(block.goRelativeBlock)];
    report.blockRelativeGoNetworkMaxMedian=median(max(reshape(block.goRelativeBlock,8,10),[],1));
    map=readtable(fullfile(cfg.bioRoot,'feasibility_map.csv'));
    counts=zeros(10,3);
    for n=1:10
        for d=1:3, counts(n,d)=sum(map.feasible & map.network==n & map.direction==d); end
    end
    report.feasibleCountsByNetworkDirection=counts;
    report.readinessInterpretation='Per-target crossing ranges are descriptive, not independent n=80 inference. EQ curves average target-specific cue-normalized error within network; state curves normalize the target-mean distance by its target-mean cue distance.';
    stage3_write_json(destination,report);
end
