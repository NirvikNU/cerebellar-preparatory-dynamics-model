function result = stage3_prediction_case(features,network,grid,permutations,targetXY)
    targets=features.targets; n=numel(targets); folds=stage3_prediction_folds(network,targets);
    result.features=features; result.folds=folds;
    result.pca=cell(1,2);
    for epoch=1:2
        X=features.X{epoch}; [~,S,V]=svd(X-mean(X,1),'econ');
        eigenvalues=diag(S).^2/(n-1); k=find(cumsum(eigenvalues)>=.75*sum(eigenvalues),1);
        result.pca{epoch}=struct('mean',mean(X,1),'basis',V,'eigenvalues',eigenvalues, ...
            'k',k,'scores',(X-mean(X,1))*V);
    end
    result.globalPermutations=zeros(n,permutations); result.withinPermutations=zeros(n,permutations);
    for rep=1:permutations
        stream=RandStream('mt19937ar','Seed',322000000+10000*network+100*rep);
        result.globalPermutations(:,rep)=randperm(stream,n).';
        for q=1:8
            ids=find(targets==q); result.withinPermutations(ids,rep)=ids(randperm(stream,numel(ids)));
        end
    end
    X=result.pca{1}.scores(:,1:result.pca{1}.k);
    Y=result.pca{2}.scores(:,1:result.pca{2}.k);
    responses=repmat(Y,1,1,permutations+1);
    for rep=1:permutations, responses(:,:,rep+1)=Y(result.globalPermutations(:,rep),:); end
    result.neural=stage3_prediction_ridge(X,responses,folds,grid);
    result.behavior=cell(1,2);
    for e=1:2
        epoch=[1 3]; X=features.X{epoch(e)};
        means=zeros(8,size(X,2));
        for q=1:8, means(q,:)=mean(X(targets==q,:),1); end
        [~,S,V]=svd(means-mean(means,1),'econ'); ev=diag(S).^2/7;
        k=find(cumsum(ev)>=.95*sum(ev),1); basis=V(:,1:k);
        taskScores=(means-mean(means,1))*basis;
        betax=pinv([ones(8,1),taskScores])*targetXY(:,1); ax=betax(2:end); ax=ax/norm(ax);
        nullScores=taskScores*(eye(k)-ax*ax.');
        betay=pinv([ones(8,1),nullScores])*targetXY(:,2); ay=betay(2:end);
        ay=ay-ax*(ax.'*ay); ay=ay/norm(ay);
        axes=basis*[ax ay]; assert(norm(axes.'*axes-eye(2),'fro')<1e-10);
        behavior=struct('taskMean',means,'taskK',k,'taskEigenvalues',ev,'taskBasis',basis,'taskAxes',axes);
        behavior.hand=stage3_prediction_ols(X*axes,features.peakPosition,folds.outer);
        speed=repmat(features.peakSpeed,1,1,permutations+1);
        for rep=1:permutations, speed(:,:,rep+1)=features.peakSpeed(result.withinPermutations(:,rep)); end
        behavior.speed=stage3_prediction_ridge(X,speed,folds,grid);
        weights=reshape(behavior.speed.fullWeights,size(X,2),permutations+1);
        behavior.speedAxes=weights./vecnorm(weights);
        heldoutProjection=zeros(n,1);
        for outer=1:3
            w=behavior.speed.weights{outer}(:,1,1); test=folds.outer==outer;
            heldoutProjection(test)=X(test,:)*(w/norm(w));
        end
        behavior.heldoutProjection=heldoutProjection;
        behavior.capturedVariance=var(heldoutProjection)/sum(var(X,0,1));
        behavior.handWithin=cell(8,1); behavior.speedWithin=cell(8,1);
        within=zeros(8,2);
        for q=1:8
            ids=find(targets==q);
            behavior.handWithin{q}=stage3_prediction_ols(X(ids,:)*axes,features.peakPosition(ids,:), (1:numel(ids)).');
            behavior.speedWithin{q}=stage3_prediction_ols(X(ids,:)*behavior.speedAxes(:,1),features.peakSpeed(ids), (1:numel(ids)).');
            within(q,:)=[behavior.handWithin{q}.r2,behavior.speedWithin{q}.r2];
        end
        behavior.withinR2=within; behavior.withinMean=mean(within,1);
        result.behavior{e}=behavior;
    end
    result.metrics=[result.neural.r2(1),result.behavior{1}.hand.r2,result.behavior{1}.speed.r2(1), ...
        result.behavior{1}.withinMean,result.behavior{2}.hand.r2,result.behavior{2}.speed.r2(1), ...
        result.behavior{2}.withinMean,result.behavior{1}.capturedVariance,result.behavior{2}.capturedVariance];
end
