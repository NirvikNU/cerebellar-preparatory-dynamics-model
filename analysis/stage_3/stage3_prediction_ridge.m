function fit = stage3_prediction_ridge(X,Y,folds,grid)
    % Reuse only X factorizations across response permutations, not fitted Y.
    n=size(X,1); responseCount=size(Y,2); repeats=size(Y,3);
    flat=reshape(Y,n,[]); predicted=zeros(size(flat));
    fit.innerSSE=zeros(3,numel(grid),repeats);
    fit.lambdaIndex=zeros(3,repeats); fit.weights=cell(3,1); fit.intercepts=cell(3,1);
    for outer=1:3
        train=folds.outer~=outer; test=~train;
        loss=zeros(numel(grid),repeats);
        for inner=1:3
            tr=train & folds.inner(:,outer)~=inner; va=train & folds.inner(:,outer)==inner;
            [U,S,V]=svd(X(tr,:)-mean(X(tr,:),1),'econ'); singular=diag(S);
            ymean=mean(flat(tr,:),1); uty=U.'*(flat(tr,:)-ymean);
            projected=(X(va,:)-mean(X(tr,:),1))*V;
            for g=1:numel(grid)
                prediction=projected*((singular./(singular.^2+sum(tr)*grid(g))).*uty)+ymean;
                err=reshape(flat(va,:)-prediction,sum(va),responseCount,repeats);
                loss(g,:)=loss(g,:)+reshape(sum(err.^2,[1 2]),1,repeats);
            end
        end
        fit.innerSSE(outer,:,:)=reshape(loss,1,numel(grid),repeats);
        [~,best]=min(loss,[],1); fit.lambdaIndex(outer,:)=best;
        [U,S,V]=svd(X(train,:)-mean(X(train,:),1),'econ'); singular=diag(S);
        ymean=mean(flat(train,:),1); uty=U.'*(flat(train,:)-ymean);
        B=zeros(size(X,2),responseCount*repeats);
        for rep=1:repeats
            cols=(rep-1)*responseCount+(1:responseCount);
            B(:,cols)=V*((singular./(singular.^2+sum(train)*grid(best(rep)))).*uty(:,cols));
        end
        intercept=ymean-mean(X(train,:),1)*B;
        predicted(test,:)=X(test,:)*B+intercept;
        fit.weights{outer}=reshape(B,size(X,2),responseCount,repeats);
        fit.intercepts{outer}=reshape(intercept,1,responseCount,repeats);
    end
    fit.predicted=reshape(predicted,size(Y)); fit.actual=Y; fit.folds=folds; fit.grid=grid;
    error=reshape(flat-predicted,n,responseCount,repeats);
    total=reshape(flat-mean(flat,1),n,responseCount,repeats);
    fit.r2=reshape(1-sum(error.^2,[1 2])./sum(total.^2,[1 2]),1,repeats);
    % Full-condition axis: same nested selection evidence, pooled over outers.
    totalLoss=reshape(sum(fit.innerSSE,1),numel(grid),repeats);
    [~,fit.fullLambdaIndex]=min(totalLoss,[],1);
    [U,S,V]=svd(X-mean(X,1),'econ'); singular=diag(S);
    ymean=mean(flat,1); uty=U.'*(flat-ymean); B=zeros(size(X,2),responseCount*repeats);
    for rep=1:repeats
        cols=(rep-1)*responseCount+(1:responseCount);
        B(:,cols)=V*((singular./(singular.^2+n*grid(fit.fullLambdaIndex(rep)))).*uty(:,cols));
    end
    fit.fullWeights=reshape(B,size(X,2),responseCount,repeats);
    fit.fullIntercepts=reshape(ymean-mean(X,1)*B,1,responseCount,repeats);
end
