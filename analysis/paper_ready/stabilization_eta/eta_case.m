function result = eta_case(n,prep,move,scale,equilibrium,existingFit)
    result.folds=stage3_prediction_folds(n,repelem((1:8).',30));
    result.bias=zeros(8,1); result.cueDistance=zeros(8,1); result.dispersion=zeros(8,1);
    for q=1:8
        ids=(q-1)*30+(1:30); go=prep.go(:,ids); cue=prep.initial(:,ids);
        result.bias(q)=norm(mean(go,2)-equilibrium(:,q));
        result.cueDistance(q)=norm(mean(cue,2)-equilibrium(:,q));
        result.dispersion(q)=sqrt(mean(sum((go-mean(go,2)).^2,1)));
    end
    result.relativeBias=result.bias./result.cueDistance;
    result.convergence=eta_convergence(prep.states,scale,result.folds);
    result.geometry=paper95_geometry(prep.meanRates(401:10:501,:,:),scale);
    result.predictionEvaluable=~any(move.missingWindow|move.nearZero);
    if ~isempty(existingFit)
        result.prediction=existingFit; result.reusedPrediction=true;
    elseif result.predictionEvaluable
        f=pe_features(prep.states,move.states,move.moMs,scale);
        r.features=f; r.folds=result.folds; r.pca=cell(1,2);
        for epoch=1:2
            X=f.X{epoch}; mu=mean(X,1); [~,S,V]=svd(X-mu,'econ'); ev=diag(S).^2/239;
            k=find(cumsum(ev)>=.75*sum(ev),1);
            r.pca{epoch}=struct('mean',mu,'basis',V,'eigenvalues',ev,'k',k,'scores',(X-mu)*V);
        end
        r.fit=stage3_prediction_ridge(r.pca{1}.scores(:,1:r.pca{1}.k), ...
            r.pca{2}.scores(:,1:r.pca{2}.k),r.folds,logspace(-8,4,25));
        result.prediction=r; result.reusedPrediction=false;
    else
        result.prediction=[]; result.reusedPrediction=false;
    end
end
