function summary = pe_primary(root)
    cfg=pe_paths(root); a=load(fullfile(cfg.dest,'recovery.mat'),'audit'); assert(strcmp(a.audit.status,'PASS'));
    assert(~isfile(fullfile(cfg.dest,'primary.mat')));
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); summary.indices=s.result.bootstrapIndices;
    summary.r2=zeros(10,4); summary.chance=zeros(10,4,100); summary.K=zeros(10,4,2);
    summary.capture=zeros(10,4,2); summary.matched=zeros(10,3,2); summary.matchedK=zeros(10,3,2);
    started=tic;
    for n=1:10
        cases=cell(1,4);
        for p=1:4
            output=fullfile(cfg.raw,sprintf('primary_n%02d_p%d.mat',n,p)); assert(~isfile(output));
            s=load(fullfile(cfg.raw,sprintf('series_n%02d_p%d.mat',n,p)),'f'); f=s.f;
            result.features=f; result.folds=stage3_prediction_folds(n,f.targets); result.pca=cell(1,2);
            for e=1:2
                X=f.X{e}; mu=mean(X,1); [~,S,V]=svd(X-mu,'econ'); ev=diag(S).^2/239;
                k=find(cumsum(ev)>=.75*sum(ev),1);
                result.pca{e}=struct('mean',mu,'basis',V,'eigenvalues',ev,'k',k,'scores',(X-mu)*V);
                summary.K(n,p,e)=k; summary.capture(n,p,e)=sum(ev(1:k))/sum(ev);
            end
            result.permutations=zeros(240,100);
            for rep=1:100
                stream=RandStream('mt19937ar','Seed',322000000+10000*n+100*rep);
                result.permutations(:,rep)=randperm(stream,240).';
            end
            X=result.pca{1}.scores(:,1:result.pca{1}.k); Y=result.pca{2}.scores(:,1:result.pca{2}.k);
            responses=repmat(Y,1,1,101);
            for rep=1:100, responses(:,:,rep+1)=Y(result.permutations(:,rep),:); end
            result.fit=stage3_prediction_ridge(X,responses,result.folds,cfg.ridgeGrid);
            summary.r2(n,p)=result.fit.r2(1); summary.chance(n,p,:)=result.fit.r2(2:end);
            save(output,'result','-v7.3'); cases{p}=result;
        end
        paired=cell(3,2);
        for lesion=1:3
            counts=squeeze(summary.K(n,[1 lesion+1],:)); kk=min(counts,[],1); summary.matchedK(n,lesion,:)=kk;
            for condition=1:2
                policies=[1 lesion+1]; c=cases{policies(condition)};
                paired{lesion,condition}=stage3_prediction_ridge(c.pca{1}.scores(:,1:kk(1)),c.pca{2}.scores(:,1:kk(2)),c.folds,cfg.ridgeGrid);
                summary.matched(n,lesion,condition)=paired{lesion,condition}.r2;
            end
        end
        save(fullfile(cfg.raw,sprintf('matched_n%02d.mat',n)),'paired');
        fprintf('Primary nested fits and100 shuffles network%d %.1fs\n',n,toc(started));
    end
    summary.bootstrap=stage2_bootstrap(summary.r2,summary.indices);
    summary.matchedBootstrap=stage2_bootstrap(summary.matched,summary.indices);
    summary.chanceMedian=median(summary.chance,3); summary.chanceBootstrap=stage2_bootstrap(summary.chanceMedian,summary.indices);
    summary.relativeChange=100*(summary.r2(:,4)-summary.r2(:,1))./summary.r2(:,1);
    summary.relativeBootstrap=stage2_bootstrap(summary.relativeChange,summary.indices);
    summary.tests=cell(1,3); summary.p=zeros(1,3);
    for j=1:3, summary.tests{j}=stage2_signflip(summary.r2(:,j+1)-summary.r2(:,1),summary.indices); summary.p(j)=summary.tests{j}.p; end
    summary.q=stage2_bh(summary.p); summary.status='PASS'; summary.elapsedSeconds=toc(started);
    save(fullfile(cfg.dest,'primary.mat'),'summary'); paper_json(fullfile(cfg.dest,'primary.json'),rmfield(summary,{'indices'}));
end
