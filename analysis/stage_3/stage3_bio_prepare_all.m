function receipt = stage3_bio_prepare_all
    % Resume frozen candidate; terminal convergence is descriptive, not a gate.
    cfg=stage3_bio_paths;
    assert(isfile(fullfile(cfg.manifestRoot,'BIO_RESUME_BEFORE.csv')));
    assert(~isfile(fullfile(cfg.bioRoot,'preparation_complete.json')));
    if ~isfolder(cfg.bioRoot), mkdir(cfg.bioRoot); end
    if ~isfolder(cfg.bioCache), mkdir(cfg.bioCache); end
    s=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); cs=s.controllers;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); reg=s.registry;
    rows=cell(40,1); targets=cell(320,1); row=0; tr=0; newCount=0; reused=0;
    started=tic;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        d=reg.primary{n}; c=cs{n}; inputLimit=NaN;
        for policy=1:4
            path=fullfile(cfg.bioCache,sprintf('n%02d_p%d.mat',n,policy));
            if (n==1 && ismember(policy,[1 4])) || isfile(path)
                [p,source]=stage3_bio_load(cfg,n,policy); reused=reused+1;
            else
                p=stage3_biological_prepare(m,d,c,cfg.policyFlags(policy,:));
                identity=struct('network',n,'policy',policy,'definition',d,'controller',c);
                save(path,'p','identity','-v7.3'); source=path; newCount=newCount+1;
            end
            if policy==1, inputLimit=5*max(1,p.nativeComponentMax(5)); end
            boundPass=p.nativeRateMax<=ref.rateLimit && p.nativeStateNormMax<=ref.stateLimit ...
                && max(p.nativeComponentMax)<=inputLimit;
            row=row+1;
            rows{row}=table(n,policy,boundPass,p.nativeRateMax,ref.rateLimit,p.nativeStateNormMax, ...
                ref.stateLimit,inputLimit,p.nativeComponentMax(1),p.nativeComponentMax(2), ...
                p.nativeComponentMax(3),p.nativeComponentMax(4),p.nativeComponentMax(5), ...
                mean(p.distanceStar(end,:)),mean(p.distanceBlock(end,:)),max(p.relativeSettle), ...
                'VariableNames',{'network','policy','boundsPass','rateMax','rateLimit','stateMax', ...
                'stateLimit','inputLimit','u0Max','bMax','feedbackMax','cbMax','totalMax', ...
                'goDistanceStar','goDistanceBlock','goRelativeBlockMax'});
            for q=1:8
                tr=tr+1;
                targets{tr}=table(n,policy,q,p.distanceStar(end,q),p.distanceBlock(end,q), ...
                    p.relativeSettle(q),p.normalizedProspective(end,q),p.crossingMs(q,1), ...
                    p.crossingMs(q,2),p.crossingMs(q,3),p.crossingMs(q,4), ...
                    p.readinessEQ(1,q),p.readinessEQ(2,q),p.readinessEQ(3,q), ...
                    p.readinessState(1,q),p.readinessState(2,q),p.readinessState(3,q), ...
                    string(source),'VariableNames',{'network','policy','target','goDistanceStar', ...
                    'goDistanceBlock','goRelativeBlock','goNormalizedEQ','eq50ms','eq90ms','state50ms', ...
                    'state90ms','eqAt50','eqAt100','eqAt200','stateAt50','stateAt100','stateAt200','source'});
            end
            if ~boundPass
                writetable(vertcat(rows{1:row}),fullfile(cfg.bioRoot,'preparation_bounds.csv'));
                error('BioResume:Bounds','Retained bound failed network%d policy%d',n,policy);
            end
        end
        fprintf('Network %02d four policies complete; retained bounds pass; %.1fs\n',n,toc(started));
        assert(toc(started)<3600,'BioResume:Budget','Preparation one-hour bound');
    end
    writetable(vertcat(rows{:}),fullfile(cfg.bioRoot,'preparation_bounds.csv'));
    writetable(vertcat(targets{:}),fullfile(cfg.bioRoot,'target_readiness.csv'));
    receipt=struct('status','PASS','newPreparations',newCount,'reusedPreparations',reused, ...
        'policies',{cfg.policyNames},'settlingCriterion','Retired by explicit RESUME-02 authority; distances reported', ...
        'elapsedSeconds',toc(started));
    stage3_write_json(fullfile(cfg.bioRoot,'preparation_complete.json'),receipt);
end
