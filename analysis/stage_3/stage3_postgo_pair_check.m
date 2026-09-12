function receipt = stage3_postgo_pair_check(root)
    % Independent descriptive check of the predeclared matched output RMS.
    cfg=stage3_postgo_paths(root);
    audit=jsondecode(fileread(fullfile(cfg.postRoot,'independent_audit.json'))); assert(strcmp(audit.status,'PASS'));
    assert(~isfile(fullfile(cfg.postRoot,'paired_output_audit.json')));
    loaded=load(fullfile(cfg.postRoot,'summary.mat'),'summary'); s=loaded.summary;
    receipt=struct('status','running','comparisons',0,'maxRMSError',0,'maxBootstrapError',0);
    for n=1:10
        for p=1:4
            loaded=load(fullfile(cfg.postCache,sprintf('analysis_n%02d_p%d.mat',n,p)),'fullResult','prepResult');
            full=loaded.fullResult.features; prep=loaded.prepResult.features;
            ds=full.peakSpeed-prep.peakSpeed; dh=full.peakPosition-prep.peakPosition;
            independent=[norm(ds)/sqrt(numel(ds)),norm(dh,'fro')/sqrt(size(dh,1))];
            err=max(abs(independent-reshape(s.pairedOutputRMS(n,p,:),1,2)));
            receipt.maxRMSError=max(receipt.maxRMSError,err); assert(err<1e-12);
            receipt.comparisons=receipt.comparisons+2;
        end
    end
    b=stage2_bootstrap(s.pairedOutputRMS,s.bootstrapIndices); rows=cell(8,1);
    labels={'Full minus Prep-only peak-speed RMS (m/s)','Full minus Prep-only hand-position RMS (m)'};
    for metric=1:2
        for p=1:4
            index=p+4*(metric-1); v=s.pairedOutputRMS(:,p,metric);
            med=median(reshape(v(s.bootstrapIndices),10000,10),2);
            se=sqrt(sum((med-mean(med)).^2)/9999);
            err=abs(se-b.se(index)); receipt.maxBootstrapError=max(receipt.maxBootstrapError,err);
            assert(err<1e-12 && median(v)==b.median(index));
            rows{index}=table(string(labels{metric}),string(cfg.policyNames{p}),b.median(index),b.se(index), ...
                'VariableNames',{'metric','policy','median','bootstrapSE'});
        end
    end
    writetable(vertcat(rows{:}),fullfile(cfg.postRoot,'paired_output_rms.csv'));
    receipt.status='PASS'; stage3_write_json(fullfile(cfg.postRoot,'paired_output_audit.json'),receipt); disp(receipt);
end
