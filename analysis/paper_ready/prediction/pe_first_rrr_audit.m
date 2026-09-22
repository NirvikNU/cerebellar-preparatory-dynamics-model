function audit=pe_first_rrr_audit(root)
    % Bounded independent check of the first saved case; no production writes.
    cfg=pe_paths(root);
    a=load(fullfile(cfg.raw,'primary_n01_p1.mat'),'result');
    b=load(fullfile(cfg.raw,'rrr_n01_p1.mat'),'fit','curves');
    X=a.result.features.X{1}; Y=a.result.features.X{2}; f=a.result.folds; fit=b.fit{1};
    predicted=zeros(240,200,200); audit=struct('status','RUNNING','network',1,'policy',1,'repeat',1, ...
        'lossError',0,'predictionError',0,'r2Error',0,'penaltyMismatches',0);
    for outer=1:3
        train=f.outer~=outer; loss=zeros(25,200);
        for inner=1:3
            tr=train & f.inner(:,outer)~=inner; va=train & f.inner(:,outer)==inner;
            for g=1:25
                [B,V,xm,ym]=augmented(X(tr,:),Y(tr,:),cfg.ridgeGrid(g));
                P=(X(va,:)-xm)*B*V; yy=Y(va,:)-ym;
                loss(g,:)=loss(g,:)+norm(yy,'fro')^2+cumsum(sum(P.^2,1)-2*sum((yy*V).*P,1));
            end
        end
        audit.lossError=max(audit.lossError,max(abs(loss-reshape(fit.innerSSE(outer,:,:),25,200)),[],'all'));
        [~,best]=min(loss,[],1); audit.penaltyMismatches=audit.penaltyMismatches+nnz(best~=fit.lambdaIndex(outer,:));
        for g=unique(best)
            [B,V,xm,ym]=augmented(X(train,:),Y(train,:),cfg.ridgeGrid(g)); factor=fit.factors{outer}{g};
            for rank=find(best==g)
                actual=(X(~train,:)-xm)*B*V(:,1:rank)*V(:,1:rank).'+ym;
                k=min(rank,size(factor.right,2));
                saved=(X(~train,:)-factor.xmean)*factor.Bscore(:,1:k)*factor.right(:,1:k).'+factor.ymean;
                audit.predictionError=max(audit.predictionError,max(abs(actual-saved),[],'all'));
                predicted(~train,:,rank)=actual;
            end
        end
    end
    for rank=1:200
        value=1-norm(Y-predicted(:,:,rank),'fro')^2/norm(Y-mean(Y,1),'fro')^2;
        audit.r2Error=max(audit.r2Error,abs(value-b.curves(1,1,rank)));
    end
    assert(audit.penaltyMismatches==0 && audit.lossError<1e-5 && audit.predictionError<1e-7 && audit.r2Error<1e-8);
    audit.status='PASS'; paper_json(fullfile(cfg.manifest,'FIRST_RRR_CASE_AUDIT.json'),audit);
end

function [B,V,xm,ym]=augmented(X,Y,lambda)
    xm=mean(X,1); ym=mean(Y,1); p=size(X,2);
    Z=[X-xm;sqrt(lambda)*eye(p)]; T=[Y-ym;zeros(p,size(Y,2))];
    [Q,R]=qr(Z,0); projected=Q.'*T; [~,~,V]=svd(projected,'econ'); B=R\projected;
end
