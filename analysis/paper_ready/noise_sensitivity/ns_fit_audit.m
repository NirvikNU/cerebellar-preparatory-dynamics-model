function a=ns_fit_audit(X,fit,reps)
    % Independent normal-equation fits, unpenalized intercept and mean-SSE penalty.
    a=struct('predictionError',0,'lossError',0,'r2Error',0,'refits',numel(reps)); p=size(X,2);
    for rep=reps
        Y=fit.actual(:,:,rep); pred=zeros(size(Y));
        for o=1:3
            train=fit.folds.outer~=o; loss=zeros(25,1);
            for i=1:3
                tr=train & fit.folds.inner(:,o)~=i; va=train & fit.folds.inner(:,o)==i;
                D=[ones(sum(tr),1) X(tr,:)]; Dv=[ones(sum(va),1) X(va,:)];
                for g=1:25
                    B=(D.'*D+diag([0 repmat(sum(tr)*fit.grid(g),1,p)]))\(D.'*Y(tr,:));
                    loss(g)=loss(g)+sum((Y(va,:)-Dv*B).^2,'all');
                end
            end
            a.lossError=max(a.lossError,max(abs(loss-fit.innerSSE(o,:,rep).')));
            [~,best]=min(loss); assert(best==fit.lambdaIndex(o,rep));
            D=[ones(sum(train),1) X(train,:)]; Dt=[ones(sum(~train),1) X(~train,:)];
            B=(D.'*D+diag([0 repmat(sum(train)*fit.grid(best),1,p)]))\(D.'*Y(train,:)); pred(~train,:)=Dt*B;
        end
        a.predictionError=max(a.predictionError,max(abs(pred-fit.predicted(:,:,rep)),[],'all'));
        r2=1-norm(Y-pred,'fro')^2/norm(Y-mean(Y,1),'fro')^2; a.r2Error=max(a.r2Error,abs(r2-fit.r2(rep)));
    end
end
