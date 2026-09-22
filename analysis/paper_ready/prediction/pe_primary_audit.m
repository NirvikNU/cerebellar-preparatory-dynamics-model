function audit = pe_primary_audit(root)
    cfg=pe_paths(root); s=load(fullfile(cfg.dest,'primary.mat'),'summary'); summary=s.summary;
    audit=struct('status','RUNNING','pcaError',0,'predictionError',0,'lossError',0,'r2Error',0,'featureError',0,'checks',0);
    for n=1:10
        cases=cell(1,4);
        for p=1:4
            s=load(fullfile(cfg.raw,sprintf('primary_n%02d_p%d.mat',n,p)),'result'); r=s.result;
            cases{p}=r;
            % Independent direct covariance eigenspectrum and PC capture threshold.
            for e=1:2
                X=r.features.X{e}; ev=sort(eig(cov(X)),'descend'); ev=max(ev,0);
                k=1; while sum(ev(1:k))/sum(ev)<.75, k=k+1; end
                assert(k==r.pca{e}.k); audit.pcaError=max(audit.pcaError,max(abs(ev-r.pca{e}.eigenvalues)));
                assert(norm(r.pca{e}.basis.'*r.pca{e}.basis-eye(200),'fro')<1e-10);
            end
            validateFolds(r.folds,n,r.features.targets);
            for j=1:100
                rs=RandStream('mt19937ar','Seed',322000000+10000*n+100*j);
                assert(isequal(r.permutations(:,j),randperm(rs,240).'));
            end
            X=r.pca{1}.scores(:,1:r.pca{1}.k); Y=r.pca{2}.scores(:,1:r.pca{2}.k);
            assert(max(abs(Y-r.fit.actual(:,:,1)),[],'all')==0);
            for j=1:100, assert(isequal(Y(r.permutations(:,j),:),r.fit.actual(:,:,j+1))); end
            audit=fitAudit(X,r.fit,audit);
            s=load(fullfile(cfg.raw,sprintf('series_n%02d_p%d.mat',n,p)),'prepStates','movement','moMs','scale');
            % Independent scalar-neuron summation at all centers for three fixed trials.
            for j=[1 120 240]
                for e=1:2
                    if e==1, t=(-500:0).'; raw=s.prepStates(:,:,j); centers=-100:10:0;
                    else, t=(0:size(s.movement,1)-1).'; raw=s.movement(:,:,j); centers=s.moMs(j)+(0:10:100); end
                    for z=1:11
                        ids=find(abs(t-centers(z))<=150);
                        if e==2, ids=ids(t(ids)>=s.moMs(j)); end
                        w=exp(-((t(ids)-centers(z))/30).^2/2); w=w/sum(w);
                        for neuron=1:200
                            value=sum(w.*max(raw(ids,neuron),0))/s.scale(neuron)-r.features.invariant(z,neuron,1,e);
                            audit.featureError=max(audit.featureError,abs(value-r.features.aligned(z,neuron,j,e)));
                        end
                    end
                end
            end
            clear s
            audit.checks=audit.checks+1;
        end
        s=load(fullfile(cfg.raw,sprintf('matched_n%02d.mat',n)),'paired');
        for lesion=1:3
            kk=min([cases{1}.pca{1}.k cases{1}.pca{2}.k;cases{lesion+1}.pca{1}.k cases{lesion+1}.pca{2}.k]);
            assert(isequal(kk,reshape(summary.matchedK(n,lesion,:),1,2)));
            for c=1:2
                policies=[1 lesion+1]; r=cases{policies(c)}; fit=s.paired{lesion,c};
                assert(isequal(fit.actual,r.pca{2}.scores(:,1:kk(2))));
                audit=fitAudit(r.pca{1}.scores(:,1:kk(1)),fit,audit);
            end
        end
        fprintf('Independent PCA/ridge/shuffle/matched audit network%d\n',n);
    end
    assert(audit.pcaError<1e-9 && audit.predictionError<1e-8 && audit.lossError<1e-6 && audit.r2Error<1e-10 && audit.featureError<1e-10);
    audit.status='PASS'; paper_json(fullfile(cfg.dest,'primary_audit.json'),audit);
end

function validateFolds(folds,n,targets)
    outer=zeros(240,1); inner=zeros(240,3);
    for q=1:8
        ids=find(targets==q); rs=RandStream('mt19937ar','Seed',320000000+10000*n+q); ids=ids(randperm(rs,30));
        for j=1:30, outer(ids(j))=ceil(j/10); end
    end
    for o=1:3
        assert(sum(outer==o)==80);
        for q=1:8
            ids=find(targets==q & outer~=o); rs=RandStream('mt19937ar','Seed',321000000+10000*n+100*o+q); ids=ids(randperm(rs,20));
            for j=1:20, inner(ids(j),o)=1+mod(j-1,3); end
        end
    end
    assert(isequal(folds.outer,outer) && isequal(folds.inner,inner));
end

function audit=fitAudit(X,fit,audit)
    n=size(X,1); p=size(X,2); q=size(fit.actual,2); reps=size(fit.actual,3);
    Y=reshape(fit.actual,n,[]); pred=zeros(size(Y));
    for o=1:3
        train=fit.folds.outer~=o; loss=zeros(25,reps);
        for i=1:3
            tr=train & fit.folds.inner(:,o)~=i; va=train & fit.folds.inner(:,o)==i;
            D=[ones(sum(tr),1) X(tr,:)]; Dv=[ones(sum(va),1) X(va,:)];
            for g=1:25
                B=(D.'*D+diag([0 repmat(sum(tr)*fit.grid(g),1,p)]))\(D.'*Y(tr,:));
                E=reshape(Y(va,:)-Dv*B,sum(va),q,reps); loss(g,:)=reshape(sum(E.^2,[1 2]),1,reps)+loss(g,:);
            end
        end
        audit.lossError=max(audit.lossError,max(abs(loss-reshape(fit.innerSSE(o,:,:),25,reps)),[],'all'));
        [~,best]=min(loss,[],1); assert(isequal(best,fit.lambdaIndex(o,:)));
        D=[ones(sum(train),1) X(train,:)]; Dt=[ones(sum(~train),1) X(~train,:)];
        for rep=1:reps
            cols=(rep-1)*q+(1:q); B=(D.'*D+diag([0 repmat(sum(train)*fit.grid(best(rep)),1,p)]))\(D.'*Y(train,cols));
            pred(~train,cols)=Dt*B;
        end
    end
    audit.predictionError=max(audit.predictionError,max(abs(pred-reshape(fit.predicted,n,[])),[],'all'));
    for rep=1:reps
        cols=(rep-1)*q+(1:q); value=1-norm(Y(:,cols)-pred(:,cols),'fro')^2/norm(Y(:,cols)-mean(Y(:,cols),1),'fro')^2;
        audit.r2Error=max(audit.r2Error,abs(value-fit.r2(rep)));
    end
end
