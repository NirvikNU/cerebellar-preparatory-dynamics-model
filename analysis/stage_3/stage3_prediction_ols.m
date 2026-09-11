function fit = stage3_prediction_ols(X,Y,foldIDs)
    design=[ones(size(X,1),1),X]; predicted=zeros(size(Y));
    labels=unique(foldIDs); fit.weights=cell(numel(labels),1);
    for j=1:numel(labels)
        test=foldIDs==labels(j); train=~test;
        beta=pinv(design(train,:))*Y(train,:);
        predicted(test,:)=design(test,:)*beta; fit.weights{j}=beta;
    end
    fit.predicted=predicted; fit.actual=Y; fit.folds=foldIDs;
    fit.r2=1-sum((Y-predicted).^2,'all')/sum((Y-mean(Y,1)).^2,'all');
end
