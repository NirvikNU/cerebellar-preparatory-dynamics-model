function [p,source] = stage3_bio_load(cfg,n,policy)
    if n==1 && ismember(policy,[1 4])
        source=fullfile(cfg.cacheRoot,'biological_revision','primary_01.mat');
        s=load(source,'primary');
        if policy==1, p=s.primary.intact; else, p=s.primary.block; end
    else
        source=fullfile(cfg.bioCache,sprintf('n%02d_p%d.mat',n,policy));
        s=load(source,'p'); p=s.p;
    end
    assert(isequal(p.flags,cfg.policyFlags(policy,:)));
end
