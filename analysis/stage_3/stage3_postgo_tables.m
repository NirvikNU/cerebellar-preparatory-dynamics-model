function stage3_postgo_tables(root)
    cfg=stage3_postgo_paths(root); loaded=load(fullfile(cfg.postRoot,'summary.mat'),'summary'); s=loaded.summary;
    rows=cell(64,1); k=0;
    for metric=1:8
        for p=1:4
            for c=1:2
                k=k+1; v=s.metrics(:,p,c,metric); b=stage2_bootstrap(v,s.bootstrapIndices);
                rows{k}=table(string(s.metricNames{metric}),string(cfg.policyNames{p}),string(s.conditionNames{c}),b.median,b.se, ...
                    'VariableNames',{'metric','policy','condition','median','bootstrapSE'});
            end
        end
    end
    writetable(vertcat(rows{:}),fullfile(cfg.postRoot,'prediction_summary.csv'));
    rows=cell(32,1); k=0;
    for metric=1:2
        names={'Peak-speed variance (m/s)^2','Hand covariance trace m^2'};
        for p=1:4
            for c=1:4
                k=k+1; v=s.variance(:,p,c,metric); b=stage2_bootstrap(v,s.bootstrapIndices);
                rows{k}=table(string(names{metric}),string(cfg.policyNames{p}),string(s.conditionNames{c}),b.median,b.se, ...
                    'VariableNames',{'metric','policy','condition','median','bootstrapSE'});
            end
        end
    end
    writetable(vertcat(rows{:}),fullfile(cfg.postRoot,'variance_summary.csv'));
    rows=cell(56,1); k=0;
    for p=1:4
        for metric=1:8
            k=k+1; b=stage2_bootstrap(s.metricChange(:,p,1,metric),s.bootstrapIndices);
            rows{k}=table(string(s.metricNames{metric}),string(cfg.policyNames{p}),"Prep-only minus Full",b.median,b.se, ...
                'VariableNames',{'metric','policy','contrast','median','bootstrapSE'});
        end
        for metric=1:2
            names={'Peak-speed variance','Hand-position variance'};
            for c=1:2
                k=k+1; b=stage2_bootstrap(s.varianceRatios(:,p,c,metric),s.bootstrapIndices);
                rows{k}=table(string(names{metric}),string(cfg.policyNames{p}),string(s.conditionNames{c+1})+" / Full",b.median,b.se, ...
                    'VariableNames',{'metric','policy','contrast','median','bootstrapSE'});
            end
            k=k+1; b=stage2_bootstrap(s.varianceFullMinusPrep(:,p,1,metric),s.bootstrapIndices);
            rows{k}=table(string(names{metric}),string(cfg.policyNames{p}),"Full minus Prep-only (SI variance units)",b.median,b.se, ...
                'VariableNames',{'metric','policy','contrast','median','bootstrapSE'});
        end
    end
    writetable(vertcat(rows{:}),fullfile(cfg.postRoot,'paired_changes_and_ratios.csv'));
    rows=cell(80,1); k=0;
    for n=1:10
        for p=1:4
            for c=1:2
                k=k+1; v=reshape(s.metrics(n,p,c,:),1,8);
                rows{k}=array2table([n p c v],'VariableNames',{'network','policy','condition','prepHand','prepSpeed', ...
                    'prepWithinHand','prepWithinSpeed','prepeakHand','prepeakSpeed','prepeakWithinHand','prepeakWithinSpeed'});
            end
        end
    end
    writetable(vertcat(rows{:}),fullfile(cfg.postRoot,'network_predictions.csv'));
end
