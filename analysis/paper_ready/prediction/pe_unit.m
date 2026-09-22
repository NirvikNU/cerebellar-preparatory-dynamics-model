function audit = pe_unit(root)
    cfg=pe_paths(root); rs=RandStream('mt19937ar','Seed',323000001);
    X=randn(rs,240,9); Y=X*randn(rs,9,7)+.2*randn(rs,240,7);
    folds=stage3_prediction_folds(1,repelem((1:8).',30)); grid=logspace(-8,4,25);
    fit=pe_rrr_fit(X,Y,folds,grid,1:7); err=0; selection=true;
    for o=1:3
        train=folds.outer~=o; loss=zeros(25,7);
        for i=1:3
            tr=train & folds.inner(:,o)~=i; va=train & folds.inner(:,o)==i;
            for g=1:25
                [base,V,xm,ym]=augmented(X(tr,:),Y(tr,:),grid(g));
                for rank=1:7
                    b=base*V(:,1:rank)*V(:,1:rank).';
                    loss(g,rank)=loss(g,rank)+norm(Y(va,:)-((X(va,:)-xm)*b+ym),'fro')^2;
                end
            end
        end
        err=max(err,max(abs(loss-reshape(fit.innerSSE(o,:,:),25,7)),[],'all'));
        [~,best]=min(loss); selection=selection && isequal(best,fit.lambdaIndex(o,:));
        for rank=1:7
            [base,V,xm,ym]=augmented(X(train,:),Y(train,:),grid(best(rank)));
            b=base*V(:,1:rank)*V(:,1:rank).';
            actual=norm(Y(~train,:)-((X(~train,:)-xm)*b+ym),'fro')^2;
            err=max(err,abs(actual-fit.outerSSE(o,rank)));
        end
    end
    assert(err<1e-8 && selection);
    d=pe_rrr_dimension(repmat([.1 .4 .7 .7],10,1)); assert(d.rank==3 && d.peakRank==3);
    % Separate synthetic two-epoch indexing and protected-boundary test.
    prep=zeros(501,7,240); movement=zeros(599,7,240);
    for j=1:240
        for neuron=1:7
            prep(:,neuron,j)=2+sin((-500:0)'/67+neuron)+neuron*cos(j/13)/4;
            movement(:,neuron,j)=2+sin((0:598)'/67+neuron)+neuron*cos(j/13)/4;
        end
    end
    mo=40+mod(1:240,17); scale=(1:7)'/7; f=pe_features(prep,movement,mo,scale);
    out=struct('states',cat(1,prep(1:500,:,:),movement),'timeGOms',(-500:598)', ...
        'moMs',mo,'peakMs',210+zeros(1,240),'targets',repelem(1:8,30),'trials',repmat(1:30,1,8), ...
        'peakPosition',zeros(240,2),'peakSpeed',ones(240,1));
    % GO is shared; synthetic traces agree there.
    old=stage3_prediction_features(out,scale);
    featureError=max(abs(f.aligned-old.aligned(:,:,:,1:2)),[],'all'); assert(featureError<1e-12);
    audit=struct('status','PASS','rrrAugmentedQRError',err,'selectedPenaltiesMatch',selection,'featureError',featureError, ...
        'seed',323000001,'realPredictionRun',false);
    paper_json(fullfile(cfg.dest,'unit.json'),audit); disp(audit);
end

function [B,V,xm,ym]=augmented(X,Y,lambda)
    xm=mean(X,1); ym=mean(Y,1); p=size(X,2);
    Z=[X-xm;sqrt(lambda)*eye(p)]; T=[Y-ym;zeros(p,size(Y,2))];
    [Q,R]=qr(Z,0); projected=Q.'*T; [~,~,V]=svd(projected,'econ'); B=R\projected;
end
