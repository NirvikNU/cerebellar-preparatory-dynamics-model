function fit=submission_null_fit(X,Y,folds,grid)
    % Same nested ridge estimator; inner SSE from exact quadratic sufficient statistics.
    n=size(X,1);responses=size(Y,2);repeats=size(Y,3);flat=reshape(Y,n,[]);
    predicted=zeros(size(flat));fit.innerSSE=zeros(3,numel(grid),repeats);fit.lambdaIndex=zeros(3,repeats);
    for outer=1:3
        train=folds.outer~=outer;test=~train;loss=zeros(numel(grid),repeats);
        for inner=1:3
            tr=train&folds.inner(:,outer)~=inner;va=train&folds.inner(:,outer)==inner;
            mu=mean(X(tr,:),1);[U,S,V]=svd(X(tr,:)-mu,'econ');singular=diag(S);
            ym=mean(flat(tr,:),1);D=U.'*(flat(tr,:)-ym);E=flat(va,:)-ym;A=(X(va,:)-mu)*V;
            k=numel(singular);B=reshape(D,k,responses,repeats);C=reshape(A.'*E,k,responses,repeats);
            cross=reshape(sum(B.*C,2),k,repeats);
            products=reshape(pagemtimes(B,'none',B,'transpose'),k*k,repeats).*(reshape(A.'*A,k*k,1));
            weights=singular./(singular.^2+sum(tr)*grid);
            weightProducts=reshape(pagemtimes(reshape(weights,k,1,[]),'none',reshape(weights,k,1,[]),'transpose'),k*k,numel(grid));
            constant=reshape(sum(reshape(E.^2,sum(va),responses,repeats),[1 2]),1,repeats);
            loss=loss+constant-2*(weights.'*cross)+weightProducts.'*products;
        end
        fit.innerSSE(outer,:,:)=reshape(loss,1,numel(grid),repeats);[~,best]=min(loss,[],1);fit.lambdaIndex(outer,:)=best;
        mu=mean(X(train,:),1);[U,S,V]=svd(X(train,:)-mu,'econ');singular=diag(S);
        ym=mean(flat(train,:),1);D=U.'*(flat(train,:)-ym);
        weights=singular./(singular.^2+sum(train)*grid(best));
        coefficients=V*(repelem(weights,1,responses).*D);intercept=ym-mu*coefficients;
        predicted(test,:)=X(test,:)*coefficients+intercept;
    end
    fit.predicted=reshape(predicted,size(Y));
    error=reshape(flat-predicted,n,responses,repeats);total=reshape(flat-mean(flat,1),n,responses,repeats);
    fit.SSE=reshape(sum(error.^2,[1 2]),1,repeats);fit.SST=reshape(sum(total.^2,[1 2]),1,repeats);
    fit.r2=1-fit.SSE./fit.SST;
    assert(all(isfinite(fit.r2))&&all(fit.SSE>=0)&&all(fit.SST>0));
end
