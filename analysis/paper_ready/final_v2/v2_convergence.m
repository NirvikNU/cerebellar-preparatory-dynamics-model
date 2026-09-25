function out=v2_convergence(states,initial,scale,folds)
    % Pre-cue distance uses ONLY the separately supplied pre-controller state.
    assert(isequal(reshape(states(1,:,:),200,240),initial));
    rates=max(states(1:10:501,:,:),0)./reshape(scale,1,200,1);
    precue=(max(initial,0)./scale(:)).';
    out.k=zeros(8,3); out.c=nan(240,1); out.precue=out.c; out.prego=out.c;
    out.ratio=out.c; out.capture=zeros(8,3); out.before=zeros(8,3);
    out.foldMean=nan(8,3); out.references=cell(8,3); out.heldout=cell(8,3);
    out.basis=cell(8,3); out.eigenvalues=cell(8,3); out.mean=cell(8,3);
    out.referencePrecue=cell(8,3); out.guard=zeros(8,3);
    for q=1:8
        ids=(q-1)*30+(1:30);
        for fold=1:3
            ref=ids(folds.outer(ids)~=fold); test=ids(folds.outer(ids)==fold);
            assert(numel(ref)==20 && numel(test)==10);
            X=reshape(permute(rates(:,:,ref),[1 3 2]),[],200);
            mu=mean(X,1); [~,S,V]=svd(X-mu,'econ'); ev=diag(S).^2/(size(X,1)-1);
            k=find(cumsum(ev)>=.95*sum(ev),1); B=V(:,1:k);
            out.k(q,fold)=k; out.basis{q,fold}=B; out.eigenvalues{q,fold}=ev;
            out.capture(q,fold)=sum(ev(1:k))/sum(ev); out.before(q,fold)=sum(ev(1:k-1))/sum(ev);
            out.mean{q,fold}=mu; out.references{q,fold}=ref; out.heldout{q,fold}=test;
            referencePrecue=mean(precue(ref,:),1);
            dc=vecnorm((precue(test,:)-referencePrecue)*B,2,2);
            referencePrego=mean(mean(rates(41:51,:,ref),1),3);
            heldPrego=reshape(permute(mean(rates(41:51,:,test),1),[3 2 1]),10,200);
            dp=vecnorm((heldPrego-referencePrego)*B,2,2);
            out.referencePrecue{q,fold}=referencePrecue;
            out.precue(test)=dc; out.prego(test)=dp;
            threshold=eps(max(1,norm(X,'fro'))); out.guard(q,fold)=threshold;
            valid=isfinite(dc)&dc>threshold; values=nan(10,1); ratios=values;
            ratios(valid)=dp(valid)./dc(valid); values(valid)=1-ratios(valid);
            out.ratio(test)=ratios; out.c(test)=values; out.foldMean(q,fold)=mean(values);
        end
    end
    out.targetMean=mean(out.foldMean,2); out.value=mean(out.targetMean);
    out.undefined=sum(~isfinite(out.c)); out.folds=folds;
    out.baseline='single pre-cue xsp+s_init*z; no post-cue baseline samples';
end
