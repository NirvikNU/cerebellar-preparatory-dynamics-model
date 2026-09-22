function out = eta_convergence(states,scale,folds)
    % Reference-only, target-matched PCA95. No held-out observations in PCA.
    rates=max(states(1:10:501,:,:),0)./reshape(scale,1,200,1);
    out.k=zeros(8,3); out.c=nan(240,1); out.cue=out.c; out.prego=out.c;
    out.foldMean=nan(8,3); out.references=cell(8,3); out.heldout=cell(8,3);
    out.basis=cell(8,3); out.eigenvalues=cell(8,3); out.mean=cell(8,3);
    for q=1:8
        ids=(q-1)*30+(1:30);
        for fold=1:3
            ref=ids(folds.outer(ids)~=fold); test=ids(folds.outer(ids)==fold);
            assert(numel(ref)==20 && numel(test)==10);
            X=reshape(permute(rates(:,:,ref),[1 3 2]),[],200);
            mu=mean(X,1); [~,S,V]=svd(X-mu,'econ'); ev=diag(S).^2/(size(X,1)-1);
            k=find(cumsum(ev)>=.95*sum(ev),1); B=V(:,1:k);
            out.k(q,fold)=k; out.basis{q,fold}=B; out.eigenvalues{q,fold}=ev;
            out.mean{q,fold}=mu; out.references{q,fold}=ref; out.heldout{q,fold}=test;
            windows={1:11,41:51}; distance=zeros(10,2);
            for w=1:2
                reference=mean(mean(rates(windows{w},:,ref),1),3);
                held=reshape(permute(mean(rates(windows{w},:,test),1),[3 2 1]),10,200);
                distance(:,w)=vecnorm((held-reference)*B,2,2);
            end
            out.cue(test)=distance(:,1); out.prego(test)=distance(:,2);
            valid=isfinite(distance(:,1)) & distance(:,1)>eps(max(1,norm(X,'fro')));
            values=nan(10,1); values(valid)=1-distance(valid,2)./distance(valid,1);
            out.c(test)=values; out.foldMean(q,fold)=mean(values);
        end
    end
    out.targetMean=mean(out.foldMean,2); out.value=mean(out.targetMean);
    out.undefined=sum(~isfinite(out.c)); out.folds=folds;
end
