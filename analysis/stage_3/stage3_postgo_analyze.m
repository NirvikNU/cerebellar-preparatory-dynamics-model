function summary = stage3_postgo_analyze(root)
    cfg=stage3_postgo_paths(root);
    loaded=load(fullfile(cfg.postRoot,'production_complete.mat'),'report'); assert(strcmp(loaded.report.status,'PASS'));
    unit=jsondecode(fileread(fullfile(cfg.postRoot,'unit_tests.json'))); assert(strcmp(unit.status,'PASS'));
    assert(~isfile(fullfile(cfg.postRoot,'summary.mat')));
    loaded=load(fullfile(cfg.bioRoot,'population.mat'),'result'); indices=loaded.result.bootstrapIndices;
    stage1=stage_1_gate1_config(root);
    targetXY=.1*[cosd(stage1.gate1.targetAnglesDeg(:)),sind(stage1.gate1.targetAnglesDeg(:))];
    summary=struct('task',cfg.task,'metrics',zeros(10,4,2,8),'variance',zeros(10,4,4,2), ...
        'varianceByTarget',zeros(10,4,4,8,2),'pairedOutputRMS',zeros(10,4,2), ...
        'bootstrapIndices',indices,'identity',zeros(40,4));
    summary.conditionNames={'Full','Prep-only','Post-only','Deterministic'};
    summary.metricNames={'Prep pooled hand R2','Prep pooled speed R2','Prep within-target hand R2', ...
        'Prep within-target speed R2','Prepeak pooled hand R2','Prepeak pooled speed R2', ...
        'Prepeak within-target hand R2','Prepeak within-target speed R2'};
    for n=1:10
        loaded=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); scale=loaded.ref.scale;
        for p=1:4
            destination=fullfile(cfg.postCache,sprintf('analysis_n%02d_p%d.mat',n,p)); assert(~isfile(destination));
            loaded=load(fullfile(cfg.predCache,sprintf('analysis_n%02d_s2_p%d.mat',n,p)),'result'); baseline=loaded.result;
            loaded=load(fullfile(cfg.predCache,sprintf('n%02d_s2_p%d.mat',n,p)),'out'); full=loaded.out;
            loaded=load(fullfile(cfg.postCache,sprintf('n%02d_p%d.mat',n,p)),'replay'); replay=loaded.replay;
            fullResult=stage3_postgo_behavior(baseline.features,baseline.folds,cfg.ridgeGrid,targetXY);
            baselineError=max(abs(fullResult.metrics-baseline.metrics(2:9)));
            assert(baselineError<1e-9,'Frozen actual-response behavior branch mismatch.');
            for e=1:2
                a=fullResult.behavior{e}; b=baseline.behavior{e};
                assert(isequal(a.speed.lambdaIndex,b.speed.lambdaIndex(:,1)) && a.speed.fullLambdaIndex==b.speed.fullLambdaIndex(1));
                assert(max(abs(a.taskAxes-b.taskAxes),[],'all')<1e-10);
                assert(max(abs(a.speedAxes-b.speedAxes(:,1)),[],'all')<1e-9);
            end
            prep=full;
            prep.states=cat(1,full.states(1:500,:,:),replay.prep.states);
            fields={'go','torque','theta','hand','finalState','moMs','peakMs','peakSpeed','peakPosition','windowsOK'};
            for f=1:numel(fields), prep.(fields{f})=replay.prep.(fields{f}); end
            features=stage3_prediction_features(prep,scale);
            featureError=max(abs(features.X{1}-baseline.features.X{1}),[],'all');
            assert(featureError<1e-12);
            assert(max(abs(features.aligned(:,:,:,1)-baseline.features.aligned(:,:,:,1)),[],'all')<1e-12);
            assert(max(abs(features.invariant(:,:,:,1)-baseline.features.invariant(:,:,:,1)),[],'all')<1e-12);
            prepResult=stage3_postgo_behavior(features,baseline.folds,cfg.ridgeGrid,targetXY);
            assert(max(abs(prepResult.behavior{1}.taskAxes-baseline.behavior{1}.taskAxes),[],'all')<1e-10);
            summary.metrics(n,p,1,:)=fullResult.metrics; summary.metrics(n,p,2,:)=prepResult.metrics;
            outputs={full,replay.prep,replay.post,replay.deterministic};
            for c=1:3
                for q=1:8
                    ids=full.targets==q; item=outputs{c};
                    summary.varianceByTarget(n,p,c,q,:)=[var(item.peakSpeed(ids),0),trace(cov(item.peakPosition(ids,:)))];
                end
            end
            summary.variance(n,p,:,:)=mean(summary.varianceByTarget(n,p,:,:,:),4);
            summary.pairedOutputRMS(n,p,:)=[sqrt(mean((full.peakSpeed-replay.prep.peakSpeed).^2)), ...
                sqrt(mean(sum((full.peakPosition-replay.prep.peakPosition).^2,2)))];
            summary.identity((n-1)*4+p,:)=[n p baselineError featureError];
            save(destination,'fullResult','prepResult','-v7.3');
            fprintf('Causal analysis n%02d policy%d: immutable Full and Prep features verified\n',n,p);
        end
    end
    summary.metricChange=summary.metrics(:,:,2,:)-summary.metrics(:,:,1,:);
    summary.varianceRatios=summary.variance(:,:,2:3,:)./summary.variance(:,:,1,:);
    summary.varianceFullMinusPrep=summary.variance(:,:,1,:)-summary.variance(:,:,2,:);
    summary.bootstrap=stage2_bootstrap(summary.metrics,indices);
    summary.changeBootstrap=stage2_bootstrap(summary.metricChange,indices);
    summary.varianceBootstrap=stage2_bootstrap(summary.variance,indices);
    summary.ratioBootstrap=stage2_bootstrap(summary.varianceRatios,indices);
    summary.varianceChangeBootstrap=stage2_bootstrap(summary.varianceFullMinusPrep,indices);
    summary.status='PASS';
    save(fullfile(cfg.postRoot,'summary.mat'),'summary');
    stage3_write_json(fullfile(cfg.postRoot,'summary.json'),summary);
end
