function error=ns_shuffle_audit(r,n)
    error=0; X=r.pca{1}.scores(:,1:r.pca{1}.k); Y=r.pca{2}.scores(:,1:r.pca{2}.k);
    if r.reusedShuffles, fit=r.fit; offset=1; else, fit=r.shuffleFit; offset=0; end
    assert(isequal(fit.grid,logspace(-8,4,25)) && isequal(fit.folds,r.folds));
    for rep=1:100
        rs=RandStream('mt19937ar','Seed',322000000+10000*n+100*rep); perm=randperm(rs,240).';
        assert(isequal(perm,r.permutations(:,rep)) && isequal(fit.actual(:,:,rep+offset),Y(perm,:)));
        actual=Y(perm,:); pred=zeros(size(actual));
        for o=1:3
            [~,best]=min(fit.innerSSE(o,:,rep+offset)); assert(best==fit.lambdaIndex(o,rep+offset));
            test=fit.folds.outer==o;
            pred(test,:)=X(test,:)*fit.weights{o}(:,:,rep+offset)+fit.intercepts{o}(:,:,rep+offset);
        end
        [~,best]=min(sum(fit.innerSSE(:,:,rep+offset),1)); assert(best==fit.fullLambdaIndex(rep+offset));
        error=max(error,max(abs(pred-fit.predicted(:,:,rep+offset)),[],'all'));
        value=1-sum((actual-pred).^2,'all')/sum((actual-mean(actual)).^2,'all'); error=max(error,abs(value-fit.r2(rep+offset)));
    end
end
