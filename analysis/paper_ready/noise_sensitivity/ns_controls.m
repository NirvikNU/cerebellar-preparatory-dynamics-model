function r=ns_controls(r,n,grid)
    % Original observed fit is never replaced. Fit only missing shuffle responses.
    if isfield(r,'permutations') && size(r.fit.r2,2)==101
        r.shuffleFit=[]; r.reusedShuffles=true; return
    end
    r.permutations=zeros(240,100);
    X=r.pca{1}.scores(:,1:r.pca{1}.k); Y=r.pca{2}.scores(:,1:r.pca{2}.k);
    responses=zeros(240,size(Y,2),100);
    for rep=1:100
        stream=RandStream('mt19937ar','Seed',322000000+10000*n+100*rep);
        r.permutations(:,rep)=randperm(stream,240).'; responses(:,:,rep)=Y(r.permutations(:,rep),:);
    end
    r.shuffleFit=stage3_prediction_ridge(X,responses,r.folds,grid); r.reusedShuffles=false;
end
