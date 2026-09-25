function a=ns_prediction_audit(r,prep,move,scale,refitShuffle)
    a=struct('featureError',0,'pcaError',0,'predictionError',0,'lossError',0,'r2Error',0,'refits',0);
    for e=1:2
        features=reshape(permute(sum(r.features.aligned(:,:,:,e),1)/11,[3 2 1]),240,200);
        a.featureError=max(a.featureError,max(abs(features-r.features.X{e}),[],'all'));
        ev=sort(max(eig(cov(r.features.X{e})),0),'descend'); k=1; while sum(ev(1:k))/sum(ev)<.75, k=k+1; end
        assert(k==r.pca{e}.k); a.pcaError=max(a.pcaError,max(abs(ev-r.pca{e}.eigenvalues)));
        assert(norm(r.pca{e}.basis.'*r.pca{e}.basis-eye(200),'fro')<1e-9);
        pc=r.pca{e}; X=r.features.X{e};
        a.pcaError=max([a.pcaError max(abs(mean(X)-pc.mean)) max(abs((X-pc.mean)*pc.basis-pc.scores),[],'all') ...
            max(abs(cov(X)*pc.basis-pc.basis.*pc.eigenvalues.'),[],'all')]);
    end
    assert(isequal(r.fit.folds,r.folds) && isequal(r.fit.grid,logspace(-8,4,25)));
    for j=[1 120 240]
        for e=1:2
            if e==1, t=(-500:0).'; raw=prep(:,:,j); centers=-100:10:0;
            else, t=(0:size(move.states,1)-1).'; raw=move.states(:,:,j); centers=move.moMs(j)+(0:10:100); end
            for z=1:11
                ids=find(abs(t-centers(z))<=150); if e==2, ids=ids(t(ids)>=move.moMs(j)); end
                w=exp(-((t(ids)-centers(z))/30).^2/2); w=w/sum(w);
                value=sum(w.*max(raw(ids,:),0),1)./scale(:).'-r.features.invariant(z,:,1,e);
                a.featureError=max(a.featureError,max(abs(value-r.features.aligned(z,:,j,e))));
            end
        end
    end
    X=r.pca{1}.scores(:,1:r.pca{1}.k); direct=ns_fit_audit(X,r.fit,1);
    for name={'predictionError','lossError','r2Error'}, a.(name{1})=max(a.(name{1}),direct.(name{1})); end
    a.refits=1;
    if refitShuffle
        if r.reusedShuffles, fit=r.fit; rep=2; else, fit=r.shuffleFit; rep=1; end
        direct=ns_fit_audit(X,fit,rep);
        for name={'predictionError','lossError','r2Error'}, a.(name{1})=max(a.(name{1}),direct.(name{1})); end
        a.refits=a.refits+1;
    end
end
