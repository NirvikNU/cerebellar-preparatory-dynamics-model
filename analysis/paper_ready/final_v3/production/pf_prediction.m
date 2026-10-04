function result=pf_prediction(n,prep,move,scale)
    % Only the immutable v2_case PCA75/ridge block; no convergence or controls.
    result.folds=pf_folds(n,repelem((1:8).',30));
    result.predictionEvaluable=~any(move.missingWindow|move.nearZero);
    result.prediction=[]; result.scale=scale;
    if result.predictionEvaluable
        f=pf_features(prep.states,move.states,move.moMs,scale);
        r.features=f; r.folds=result.folds; r.pca=cell(1,2);
        for epoch=1:2
            X=f.X{epoch}; mu=mean(X,1); [~,S,V]=svd(X-mu,'econ'); ev=diag(S).^2/239;
            k=find(cumsum(ev)>=.75*sum(ev),1);
            r.pca{epoch}=struct('mean',mu,'basis',V,'eigenvalues',ev,'k',k,'scores',(X-mu)*V);
        end
        r.fit=pf_ridge(r.pca{1}.scores(:,1:r.pca{1}.k), ...
            r.pca{2}.scores(:,1:r.pca{2}.k),r.folds,logspace(-8,4,25));
        result.prediction=r;
        result.predictionEvaluable=all(isfinite(r.fit.r2));
    end
    result.qc=struct('finite',all(isfinite(prep.states),'all')&&all(isfinite(move.states),'all')&&all(isfinite(move.hand),'all'), ...
        'prepRateMax',prep.rateMax,'prepStateMax',prep.stateMax,'prepTotalInputMax',prep.componentMax(5), ...
        'movementRateMax',move.rateMax,'movementStateMax',move.stateMax,'nearZero',sum(move.nearZero), ...
        'missingWindow',sum(move.missingWindow),'boundaryPeak',sum(move.boundaryPeak),'multiPeak',sum(move.multiPeakCount>=2), ...
        'allTrialsRetained',true);
    assert(result.qc.finite,'V3:Nonfinite','Nonfinite result: stop without retuning.');
end
