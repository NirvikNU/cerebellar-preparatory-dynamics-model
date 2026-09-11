function audit = stage3_prediction_analysis_test(root)
    cfg=stage3_prediction_paths(root);
    assert(~isfile(fullfile(cfg.predRoot,'analysis_unit_tests.json')));
    n=240; p=7; time=(-500:598).';
    out=struct('timeGOms',time,'targets',repelem(1:8,30),'trials',repmat(1:30,1,8), ...
        'moMs',40+mod((1:n).',17),'peakMs',210+mod((1:n).',23), ...
        'peakPosition',zeros(n,2),'peakSpeed',ones(n,1));
    out.states=zeros(numel(time),p,n);
    for j=1:n
        for neuron=1:p
            out.states(:,neuron,j)=sin(time/67+neuron)+cos(j/13)*neuron/4;
        end
    end
    scale=(1:p).'/7; f=stage3_prediction_features(out,scale);
    independent=zeros(11,p,n,3);
    for j=1:n
        centers={-100:10:0,out.moMs(j)+(0:10:100),out.peakMs(j)+(-150:10:-50)};
        for epoch=1:3
            for k=1:11
                t=centers{epoch}(k); ids=find(abs(time-t)<=150);
                if epoch==1, ids=ids(time(ids)<=0); end
                if epoch==2, ids=ids(time(ids)>=out.moMs(j)); end
                if epoch==3, ids=ids(time(ids)<=out.peakMs(j)-50); end
                w=exp(-(time(ids)-t).^2/(2*30^2)); w=w/sum(w);
                for neuron=1:p
                    independent(k,neuron,j,epoch)=sum(w.*max(out.states(ids,neuron,j),0))/scale(neuron);
                end
            end
        end
    end
    independent=independent-mean(independent,3);
    audit.neuronSmoothingError=max(abs(independent-f.aligned),[],'all');
    assert(audit.neuronSmoothingError<1e-12);
    for epoch=1:3
        for j=1:n
            for neuron=1:p
                assert(abs(mean(independent(:,neuron,j,epoch))-f.X{epoch}(j,neuron))<1e-12);
            end
        end
    end
    changed=out; changed.states(time>0,:,:)=1e8;
    g=stage3_prediction_features(changed,scale);
    audit.prepBoundaryError=max(abs(f.X{1}-g.X{1}),[],'all'); assert(audit.prepBoundaryError==0);
    targets=out.targets(:); folds=stage3_prediction_folds(1,targets);
    X=[sin((1:n).'/7),cos((1:n).'/17),(1:n).'/n];
    Y=[2+X*[1;2;-1],-1+X*[.3;-.7;1]]+sin((1:n).'/19)*[.1 -.2];
    responses=cat(3,Y,flipud(Y)); fit=stage3_prediction_ridge(X,responses,folds,cfg.ridgeGrid);
    audit.ridgePredictionError=0; audit.innerLossError=0;
    for outer=1:3
        train=folds.outer~=outer; test=~train;
        for rep=1:2
            yy=responses(:,:,rep); loss=zeros(1,25);
            for inner=1:3
                tr=train & folds.inner(:,outer)~=inner; va=train & folds.inner(:,outer)==inner;
                for k=1:25
                    D=[ones(sum(tr),1),X(tr,:)]; penalty=diag([0 repmat(sum(tr)*cfg.ridgeGrid(k),1,3)]);
                    b=(D.'*D+penalty)\(D.'*yy(tr,:));
                    err=yy(va,:)-[ones(sum(va),1),X(va,:)]*b; loss(k)=loss(k)+sum(err.^2,'all');
                end
            end
            audit.innerLossError=max(audit.innerLossError,max(abs(loss-reshape(fit.innerSSE(outer,:,rep),1,[]))));
            [~,best]=min(loss); assert(best==fit.lambdaIndex(outer,rep));
            D=[ones(sum(train),1),X(train,:)]; penalty=diag([0 repmat(sum(train)*cfg.ridgeGrid(best),1,3)]);
            b=(D.'*D+penalty)\(D.'*yy(train,:)); prediction=[ones(sum(test),1),X(test,:)]*b;
            audit.ridgePredictionError=max(audit.ridgePredictionError,max(abs(prediction-fit.predicted(test,:,rep)),[],'all'));
        end
    end
    assert(audit.ridgePredictionError<1e-10 && audit.innerLossError<1e-8);
    assert(all(sum(folds.outer==1)==80) && all(folds.inner(folds.outer==1,1)==0));
    audit.status='PASS'; audit.ratesNotStates=true; audit.neuronIdentity=true;
    audit.boundaryProtected=true; audit.nestedTrainingOnly=true;
    stage3_write_json(fullfile(cfg.predRoot,'analysis_unit_tests.json'),audit); disp(audit);
end
