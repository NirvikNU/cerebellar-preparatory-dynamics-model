function result=v2_case(n,prep,move,scale,prior)
    result.folds=stage3_prediction_folds(n,repelem((1:8).',30));
    result.convergence=v2_convergence(prep.states,prep.initial,scale,result.folds);
    result.geometry=paper95_geometry(prep.meanRates(401:10:501,:,:),scale);
    result.predictionEvaluable=~any(move.missingWindow|move.nearZero);
    result.reusedPrediction=~isempty(prior);
    if ~isempty(prior)
        assert(isequal(result.folds,prior.folds)); result.prediction=prior.prediction;
        assert(result.predictionEvaluable==prior.predictionEvaluable);
    elseif result.predictionEvaluable
        % Exact released PCA75/feature/ridge procedure; no parameter alteration.
        f=pe_features(prep.states,move.states,move.moMs,scale);
        r.features=f; r.folds=result.folds; r.pca=cell(1,2);
        for epoch=1:2
            X=f.X{epoch}; mu=mean(X,1); [~,S,V]=svd(X-mu,'econ'); ev=diag(S).^2/239;
            k=find(cumsum(ev)>=.75*sum(ev),1);
            r.pca{epoch}=struct('mean',mu,'basis',V,'eigenvalues',ev,'k',k,'scores',(X-mu)*V);
        end
        r.fit=stage3_prediction_ridge(r.pca{1}.scores(:,1:r.pca{1}.k), ...
            r.pca{2}.scores(:,1:r.pca{2}.k),r.folds,logspace(-8,4,25));
        result.prediction=ns_controls(r,n,logspace(-8,4,25));
    else
        result.prediction=[];
    end
    result.scale=scale;
    result.movement=rmfield(move,intersect(fieldnames(move),{'states','audit','go','finalState','torque','theta','hand','speed'}));
    result.peakPosition=zeros(240,2);
    for j=1:240, result.peakPosition(j,:)=reshape(move.hand(move.peakMs(j)+1,[1 3],j),1,2); end
    result.peakMeanByTarget=mean(reshape(move.peak,30,8),1);
    result.peakMean=mean(result.peakMeanByTarget);
    result.qc=struct('finite',all(isfinite(prep.states),'all')&&all(isfinite(move.states),'all')&&all(isfinite(move.hand),'all'), ...
        'prepRateMax',prep.rateMax,'prepStateMax',prep.stateMax,'prepTotalInputMax',prep.componentMax(5), ...
        'movementRateMax',move.rateMax,'movementStateMax',move.stateMax,'nearZero',sum(move.nearZero), ...
        'missingWindow',sum(move.missingWindow),'boundaryPeak',sum(move.boundaryPeak),'multiPeak',sum(move.multiPeakCount>=2), ...
        'allTrialsRetained',true);
    assert(result.qc.finite);
end
