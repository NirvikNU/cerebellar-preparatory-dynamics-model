function error=ns_convergence_audit(states,scale,r)
    error=0; scores=nan(240,1);
    for q=1:8
        ids=(q-1)*30+(1:30);
        for fold=1:3
            ref=ids(r.folds.outer(ids)~=fold); test=ids(r.folds.outer(ids)==fold);
            assert(isequal(ref,r.references{q,fold}) && isequal(test,r.heldout{q,fold}));
            X=zeros(1020,200); cue=zeros(30,200); prego=cue;
            for neuron=1:200
                z=squeeze(max(states(1:10:501,neuron,ref),0))/scale(neuron); X(:,neuron)=z(:);
                cue(:,neuron)=squeeze(sum(max(states(1:10:101,neuron,ids),0),1))/11/scale(neuron);
                prego(:,neuron)=squeeze(sum(max(states(401:10:501,neuron,ids),0),1))/11/scale(neuron);
            end
            [V,D]=eig(cov(X)); [ev,order]=sort(max(diag(D),0),'descend'); V=V(:,order);
            k=1; while sum(ev(1:k))/sum(ev)<.95, k=k+1; end
            assert(k==r.k(q,fold)); B=V(:,1:k);
            ri=ref-(q-1)*30; ti=test-(q-1)*30; pc=cue*B; pp=prego*B;
            rc=sum(pc(ri,:),1)/20; rp=sum(pp(ri,:),1)/20;
            error=max(error,max(abs(mean(X)-r.mean{q,fold})));
            error=max(error,abs(sum(ev(1:k))/sum(ev)-sum(r.eigenvalues{q,fold}(1:k))/sum(r.eigenvalues{q,fold})));
            for j=1:10
                dc=norm(pc(ti(j),:)-rc); dp=norm(pp(ti(j),:)-rp);
                error=max([error abs(dc-r.cue(test(j))) abs(dp-r.prego(test(j)))]);
                if isfinite(dc) && dc>eps(max(1,norm(X,'fro'))), scores(test(j))=1-dp/dc; end
            end
        end
    end
    assert(isequal(isnan(scores),isnan(r.c))); good=isfinite(scores);
    error=max([error;abs(scores(good)-r.c(good))]);
    assert(isequal(isnan(mean(scores)),isnan(r.value)));
    if all(good), error=max(error,abs(mean(scores)-r.value)); end
end
