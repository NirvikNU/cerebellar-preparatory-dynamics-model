function audit = pe_series_audit(root)
    cfg=pe_paths(root); errors=zeros(10,4); scaleErrors=zeros(10,4);
    for n=1:10
        r=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref');
        for p=1:4
            path=fullfile(cfg.raw,sprintf('series_n%02d_p%d.mat',n,p)); raw=matfile(path);
            goPrep=squeeze(raw.prepStates(501,:,:)); goMovement=squeeze(raw.movement(1,:,:));
            errors(n,p)=max(abs(goPrep-goMovement),[],'all');
            s=load(path,'provenance','scale','moMs','f');
            scaleErrors(n,p)=max(abs(s.scale(:)-r.ref.scale(:)));
            assert(all(s.scale>0) && all(isfinite(s.scale)));
            expectedSeeds=310000000+10000*n+100*repelem(1:8,30)+repmat(1:30,1,8);
            assert(isequal(s.provenance.seeds,expectedSeeds));
            assert(isequal(s.provenance.flags,cfg.policyFlags(p,:)));
            assert(s.provenance.lambda==10 && s.provenance.alpha==.5 && s.provenance.beta==1 && ~s.provenance.noiseAfterGO);
            assert(isequal(s.f.targets,repelem((1:8)',30)) && isequal(s.f.trials,repmat((1:30)',8,1)));
            assert(isequal(s.moMs(:),s.f.moMs(:)) && all(s.moMs(:)>=0 & s.moMs(:)+100<=598));
        end
    end
    assert(max(errors,[],'all')<1e-10 && max(scaleErrors,[],'all')==0);
    audit=struct('status','PASS','GOContinuityErrors',errors,'frozenScaleErrors',scaleErrors, ...
        'allFortyPolicyCases',true,'allTrialSeedsVerified',true,'allParametersFrozen',true);
    paper_json(fullfile(cfg.dest,'series_audit.json'),audit);
end
