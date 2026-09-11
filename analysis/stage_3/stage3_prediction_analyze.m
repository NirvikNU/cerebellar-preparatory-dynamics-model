function summary = stage3_prediction_analyze(root)
    cfg=stage3_prediction_paths(root);
    loaded=load(fullfile(cfg.predRoot,'production_complete.mat'),'report'); assert(strcmp(loaded.report.status,'PASS'));
    unit=jsondecode(fileread(fullfile(cfg.predRoot,'analysis_unit_tests.json'))); assert(strcmp(unit.status,'PASS'));
    assert(~isfile(fullfile(cfg.predRoot,'summary.mat')),'Refuse to overwrite prediction summary.');
    loaded=load(fullfile(cfg.bioRoot,'population.mat'),'result'); indices=loaded.result.bootstrapIndices;
    summary=struct('task',cfg.task,'status','running','metrics',zeros(10,3,4,11), ...
        'metricNames',{{'neuralR2','handR2','speedR2','withinHandR2','withinSpeedR2', ...
        'prepeakHandR2','prepeakSpeedR2','prepeakWithinHandR2','prepeakWithinSpeedR2', ...
        'speedCapturedVariance','prepeakSpeedCapturedVariance'}},'bootstrapIndices',indices, ...
        'chance',zeros(10,3,4,cfg.permutations),'K',zeros(10,3,4,2), ...
        'matched',zeros(10,3,3,2),'matchedK',zeros(10,3,3,2), ...
        'orientation',zeros(10,3,3,2),'orientationNull',zeros(10,3,3,2,cfg.permutations));
    stage1=stage_1_gate1_config(root);
    targetXY=.1*[cosd(stage1.gate1.targetAnglesDeg(:)),sind(stage1.gate1.targetAnglesDeg(:))];
    started=tic;
    for network=1:10
        loaded=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',network)),'ref'); scale=loaded.ref.scale;
        for level=1:3
            cases=cell(1,4);
            for policy=1:4
                output=fullfile(cfg.predCache,sprintf('analysis_n%02d_s%d_p%d.mat',network,level,policy));
                assert(~isfile(output),'Refuse to overwrite analysis evidence.');
                loaded=load(fullfile(cfg.predCache,sprintf('n%02d_s%d_p%d.mat',network,level,policy)),'out');
                assert(loaded.out.boundsPass && all(loaded.out.windowsOK));
                features=stage3_prediction_features(loaded.out,scale); clear loaded
                result=stage3_prediction_case(features,network,cfg.ridgeGrid,cfg.permutations,targetXY);
                result.network=network; result.level=level; result.policy=policy;
                save(output,'result','-v7.3');
                summary.metrics(network,level,policy,:)=reshape(result.metrics,1,1,1,11);
                summary.chance(network,level,policy,:)=reshape(result.neural.r2(2:end),1,1,1,[]);
                summary.K(network,level,policy,:)=[result.pca{1}.k,result.pca{2}.k];
                cases{policy}=result;
                fprintf('Prediction saved n%02d s=%.2f policy%d; %.1fs (all fixed settings)\n',network,cfg.noiseLevels(level),policy,toc(started));
            end
            paired=cell(3,2);
            for lesion=1:3
                policy=lesion+1;
                kk=min([cases{1}.pca{1}.k,cases{1}.pca{2}.k;cases{policy}.pca{1}.k,cases{policy}.pca{2}.k],[],1);
                summary.matchedK(network,level,lesion,:)=kk;
                for condition=1:2
                    pp=[1 policy]; c=cases{pp(condition)};
                    paired{lesion,condition}=stage3_prediction_ridge(c.pca{1}.scores(:,1:kk(1)), ...
                        c.pca{2}.scores(:,1:kk(2)),c.folds,cfg.ridgeGrid);
                    summary.matched(network,level,lesion,condition)=paired{lesion,condition}.r2;
                end
                for epoch=1:2
                    aa=cases{1}.behavior{epoch}.speedAxes; bb=cases{policy}.behavior{epoch}.speedAxes;
                    align=sum(aa.*bb,1).^2;
                    summary.orientation(network,level,lesion,epoch)=align(1);
                    summary.orientationNull(network,level,lesion,epoch,:)=reshape(align(2:end),1,1,1,1,[]);
                end
            end
            save(fullfile(cfg.predCache,sprintf('matched_n%02d_s%d.mat',network,level)),'paired');
        end
    end
    summary.bootstrap=stage2_bootstrap(summary.metrics,indices);
    summary.matchedBootstrap=stage2_bootstrap(summary.matched,indices);
    summary.chanceMedian=median(summary.chance,4);
    summary.chanceBootstrap=stage2_bootstrap(summary.chanceMedian,indices);
    summary.expectedOrientation=mean(summary.orientationNull,5);
    summary.orientationDeficit=summary.expectedOrientation-summary.orientation;
    summary.orientationBootstrap=stage2_bootstrap(summary.orientationDeficit,indices);
    p=zeros(3,3); tests=cell(3,3);
    for metric=1:3
        for lesion=1:3
            delta=summary.metrics(:,2,lesion+1,metric)-summary.metrics(:,2,1,metric);
            tests{lesion,metric}=stage2_signflip(delta,indices); p(lesion,metric)=tests{lesion,metric}.p;
        end
    end
    summary.tests=tests; summary.p=p; summary.q=stage2_bh(p);
    summary.status='PASS'; summary.elapsedSeconds=toc(started);
    save(fullfile(cfg.predRoot,'summary.mat'),'summary');
    rows=cell(120,1); r=0;
    for n=1:10
        for level=1:3
            for policy=1:4
                r=r+1; vals=reshape(summary.metrics(n,level,policy,:),1,11);
                rows{r}=array2table([n,cfg.noiseLevels(level),policy,vals], ...
                    'VariableNames',[{'network','s','policy'},summary.metricNames]);
            end
        end
    end
    writetable(vertcat(rows{:}),fullfile(cfg.predRoot,'network_metrics.csv'));
    receipt=struct('status','PASS','n',10,'trialsPerTarget',30,'noiseLevels',cfg.noiseLevels, ...
        'primaryNoise',.10,'primaryP',p,'primaryQ',summary.q,'noTuning',true);
    stage3_write_json(fullfile(cfg.predRoot,'analysis_complete.json'),receipt);
end
