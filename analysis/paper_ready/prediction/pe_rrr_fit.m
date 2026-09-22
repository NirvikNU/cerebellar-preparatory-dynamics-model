function fit = pe_rrr_fit(X,Y,folds,grid,ranks)
    % Exact sum-SSE ridge-RRR objective, full neural inputs, no PCA truncation.
    nr=numel(ranks); fit.innerSSE=zeros(3,numel(grid),nr);
    fit.lambdaIndex=zeros(3,nr); fit.outerSSE=zeros(3,nr);
    fit.factors=cell(3,1);
    for o=1:3
        train=folds.outer~=o; loss=zeros(numel(grid),nr);
        for i=1:3
            tr=train & folds.inner(:,o)~=i; va=train & folds.inner(:,o)==i;
            [U,S,V]=svd(X(tr,:)-mean(X(tr,:),1),'econ'); sx=diag(S);
            uy=U.'*(Y(tr,:)-mean(Y(tr,:),1)); xv=(X(va,:)-mean(X(tr,:),1))*V;
            yv=Y(va,:)-mean(Y(tr,:),1);
            for g=1:numel(grid)
                [~,~,vr]=svd((sx./sqrt(sx.^2+grid(g))).*uy,'econ');
                predicted=(xv.*(sx./(sx.^2+grid(g))).')*(uy*vr);
                loss(g,:)=loss(g,:)+rankLoss(predicted,yv,vr,ranks);
            end
        end
        fit.innerSSE(o,:,:)=reshape(loss,1,numel(grid),nr);
        [~,best]=min(loss,[],1); fit.lambdaIndex(o,:)=best;
        xmu=mean(X(train,:),1); ymu=mean(Y(train,:),1);
        [U,S,V]=svd(X(train,:)-xmu,'econ'); sx=diag(S); uy=U.'*(Y(train,:)-ymu);
        xv=(X(~train,:)-xmu)*V; yv=Y(~train,:)-ymu;
        factors=cell(1,numel(grid));
        for g=unique(best)
            [~,~,vr]=svd((sx./sqrt(sx.^2+grid(g))).*uy,'econ');
            Bscore=(V.*(sx./(sx.^2+grid(g))).')*(uy*vr);
            predicted=xv*((sx./(sx.^2+grid(g))).*(uy*vr));
            losses=rankLoss(predicted,yv,vr,ranks); ids=best==g;
            fit.outerSSE(o,ids)=losses(ids);
            factors{g}=struct('Bscore',Bscore,'right',vr,'xmean',xmu,'ymean',ymu);
        end
        fit.factors{o}=factors;
    end
    fit.SST=sum((Y-mean(Y,1)).^2,'all'); fit.r2=1-sum(fit.outerSSE,1)/fit.SST;
    fit.folds=folds; fit.ranks=ranks; fit.grid=grid;
end

function loss = rankLoss(predicted,Y,vr,ranks)
    pieces=sum(predicted.^2,1)-2*sum((Y*vr).*predicted,1);
    cumulative=cumsum(pieces); ids=min(ranks,numel(pieces));
    loss=sum(Y.^2,'all')+cumulative(ids);
end
