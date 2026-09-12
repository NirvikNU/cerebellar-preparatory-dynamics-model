function result = stage3_postgo_behavior(features,folds,grid,targetXY)
    % Actual-response branch of the frozen prediction analysis, without null reruns.
    targets=features.targets; result.features=features; result.folds=folds;
    result.behavior=cell(1,2);
    for e=1:2
        epochs=[1 3]; X=features.X{epochs(e)};
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
        behavior.speed=stage3_prediction_ridge(X,features.peakSpeed,folds,grid);
        weights=reshape(behavior.speed.fullWeights,size(X,2),1);
        behavior.speedAxes=weights./vecnorm(weights);
        behavior.handWithin=cell(8,1); behavior.speedWithin=cell(8,1); within=zeros(8,2);
        for q=1:8
            ids=find(targets==q);
            behavior.handWithin{q}=stage3_prediction_ols(X(ids,:)*axes,features.peakPosition(ids,:), (1:numel(ids)).');
            behavior.speedWithin{q}=stage3_prediction_ols(X(ids,:)*behavior.speedAxes,features.peakSpeed(ids), (1:numel(ids)).');
            within(q,:)=[behavior.handWithin{q}.r2,behavior.speedWithin{q}.r2];
        end
        behavior.withinR2=within; behavior.withinMean=mean(within,1);
        result.behavior{e}=behavior;
    end
    result.metrics=[result.behavior{1}.hand.r2,result.behavior{1}.speed.r2, ...
        result.behavior{1}.withinMean,result.behavior{2}.hand.r2,result.behavior{2}.speed.r2, ...
        result.behavior{2}.withinMean];
end
