function receipt=pe_batch_test(root)
    cfg=pe_paths(root); loaded=load(fullfile(cfg.raw,'primary_n01_p1.mat'),'result'); prior=loaded.result;
    X=prior.features.X{1}; Y=prior.features.X{2}; perm=prior.permutations;
    correspondence=[(1:size(Y,1)).' perm];
    assert(isequal(Y(correspondence(:,1),:),Y) && isequal(correspondence(:,2:end),perm));
    folds=cell(1,10);
    for repeat=1:10, folds{repeat}=stage3_prediction_folds(1+100*(repeat-1),prior.features.targets); end
    pool=parpool('Threads',20); cleanup=onCleanup(@()delete(pool));
    curves=zeros(2,10,200); selected=zeros(2,10,3,200,'uint8');
    losses=cell(2,1); realFits=cell(2,1); grid=cfg.ridgeGrid;
    parfor shuffle=1:2
        maxNumCompThreads(1); yy=Y(correspondence(:,shuffle),:); %#ok<PFBNS> Immutable response shared across correspondence permutations.
        rr=zeros(10,200); ss=zeros(10,3,200,'uint8'); ll=zeros(10,3,25,200); ff=cell(10,1);
        for repeat=1:10
            fit=pe_rrr_fit(X,yy,folds{repeat},grid,1:200); %#ok<PFBNS> Fixed small shared fold table.
            rr(repeat,:)=fit.r2; ss(repeat,:,:)=uint8(fit.lambdaIndex); ll(repeat,:,:,:)=fit.innerSSE;
            if shuffle==1, ff{repeat}=fit; end
        end
        curves(shuffle,:,:)=rr; selected(shuffle,:,:,:)=ss; losses{shuffle}=ll; realFits{shuffle}=ff;
    end
    assert(all(isfinite(curves),'all') && all(selected>=1 & selected<=25,'all'));
    assert(all(cellfun(@(v)all(isfinite(v),'all'),losses)) && numel(realFits{1})==10);
    observed=pe_rrr_fit(X,Y,folds{1},grid,1:200);
    shuffled=pe_rrr_fit(X,Y(perm(:,1),:),folds{10},grid,1:200);
    errors=[max(abs(observed.r2-reshape(curves(1,1,:),1,200))),max(abs(shuffled.r2-reshape(curves(2,10,:),1,200)))];
    assert(max(errors)<1e-12);
    receipt=struct('status','PASS','cases','Network1 Intact, identity and first frozen shuffle, all10 repeats/all200 ranks', ...
        'serialR2Errors',errors,'unchangedCorrespondence',true,'productionResultsWritten',false);
    paper_json(fullfile(cfg.manifest,'BATCH_PREFLIGHT.json'),receipt);
    clear cleanup
end
