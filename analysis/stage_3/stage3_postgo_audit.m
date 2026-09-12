function audit = stage3_postgo_audit(root)
    cfg=stage3_postgo_paths(root);
    assert(~isfile(fullfile(cfg.postRoot,'independent_audit.json')));
    loaded=load(fullfile(cfg.postRoot,'summary.mat'),'summary'); summary=loaded.summary;
    loaded=load(fullfile(cfg.bioRoot,'population.mat'),'result');
    assert(isequal(summary.bootstrapIndices,loaded.result.bootstrapIndices));
    audit=struct('status','running','cases',0,'fits',0,'maxIncrementError',0,'maxArmError',0, ...
        'maxFeatureError',0,'maxPredictionError',0,'maxR2Error',0,'maxRidgeResidual',0, ...
        'maxInnerLossRelativeError',0,'maxVarianceError',0,'maxBootstrapError',0);
    ids=[1 30 121 240]; targets=repelem(1:8,30); trials=repmat(1:30,1,8);
    try
        for n=1:10
            loaded=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=loaded.model;
            noise=stage3_prediction_noise(m,n,targets(ids),trials(ids));
            for p=1:4
                loaded=load(fullfile(cfg.postCache,sprintf('n%02d_p%d.mat',n,p)),'replay'); r=loaded.replay;
                loaded=load(fullfile(cfg.predCache,sprintf('n%02d_s2_p%d.mat',n,p)),'out'); full=loaded.out;
                loaded=load(fullfile(cfg.postCache,sprintf('analysis_n%02d_p%d.mat',n,p))); results={loaded.fullResult,loaded.prepResult};
                dp=stage3_bio_load(cfg,n,p);
                assert(isequal(r.prep.go,full.go) && isequal(r.post.go,dp.go(:,targets)) && isequal(r.deterministic.go,dp.go));
                for j=1:numel(ids)
                    increments=reshape(noise.process(:,j,2501:end),m.n,[]);
                    digest=java.security.MessageDigest.getInstance('SHA-256');
                    digest.update(typecast(increments(:),'int8'));
                    hash=reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]);
                    assert(strcmpi(hash,r.postNoiseSHA256{ids(j)}));
                end
                for c=1:3
                    names={'prep','post','deterministic'}; item=r.(names{c});
                    selected=ids; if c==3, selected=[1 4 8]; end
                    for saved=[1 11 101 501 598]
                        x=squeeze(item.states(saved,:,selected));
                        for sub=0:4
                            step=(saved-1)*5+sub;
                            x=x+(m.dt/m.tau)*(-x+m.W*max(x,0)+m.h+published_movement_input(step*m.dt,m));
                            if c==2, x=x+.1*sqrt(2*m.dt/m.tau)*noise.process(:,:,2500+step+1); end
                        end
                        err=max(abs(x-squeeze(item.states(saved+1,:,selected))),[],'all');
                        audit.maxIncrementError=max(audit.maxIncrementError,err); assert(err<1e-10);
                    end
                    x=squeeze(item.states(end,:,selected));
                    for step=(m.nSamples-1)*5:m.nInternalSteps-1
                        x=x+(m.dt/m.tau)*(-x+m.W*max(x,0)+m.h+published_movement_input(step*m.dt,m));
                        if c==2, x=x+.1*sqrt(2*m.dt/m.tau)*noise.process(:,:,2500+step+1); end
                    end
                    err=max(abs(x-item.finalState(:,selected)),[],'all');
                    audit.maxIncrementError=max(audit.maxIncrementError,err); assert(err<1e-10);
                    for j=1:size(item.hand,3)
                        speed=sqrt(item.hand(:,2,j).^2+item.hand(:,4,j).^2);
                        [peak,index]=max(speed); mo=find(speed>=peak/5,1)-1;
                        assert(mo==item.moMs(j) && index-1==item.peakMs(j) && abs(peak-item.peakSpeed(j))<1e-12);
                        assert(isequal(item.peakPosition(j,:),item.hand(index,[1 3],j)));
                    end
                    for j=selected
                        for k=[1 50 100 250 500]
                            state=item.theta(k,:,j); a=m.arm; dq1=state(2); q2=state(3); dq2=state(4);
                            A=a.I1+a.I2+a.M2*a.L1^2+2*a.M2*a.L1*a.S2*cos(q2);
                            B=a.I2+a.M2*a.L1*a.S2*cos(q2); D=a.I2; z=a.M2*a.L1*a.S2*sin(q2);
                            rhs=item.torque(k,:,j).'-[-z*dq2*(2*dq1+dq2);z*dq1^2]-a.B*[dq1;dq2];
                            accel=[D*rhs(1)-B*rhs(2);A*rhs(2)-B*rhs(1)]/(A*D-B^2);
                            next=state+.001*[dq1 accel(1) dq2 accel(2)];
                            err=max(abs(next-item.theta(k+1,:,j))); audit.maxArmError=max(audit.maxArmError,err); assert(err<1e-10);
                        end
                    end
                end
                outputs={full,r.prep,r.post,r.deterministic};
                for c=1:4
                    independent=zeros(8,2);
                    for q=1:8
                        item=outputs{c}; selected=targets==q;
                        if c==4
                            speed=repmat(item.peakSpeed(q),30,1); xy=repmat(item.peakPosition(q,:),30,1);
                        else
                            speed=item.peakSpeed(selected); xy=item.peakPosition(selected,:);
                        end
                        independent(q,:)=[sum((speed-mean(speed)).^2)/29,sum((xy-mean(xy,1)).^2,'all')/29];
                    end
                    expected=reshape(summary.varianceByTarget(n,p,c,:,:),8,2);
                    err=max(abs(expected-independent),[],'all'); audit.maxVarianceError=max(audit.maxVarianceError,err); assert(err<1e-12);
                    assert(max(abs(mean(independent,1)-reshape(summary.variance(n,p,c,:),1,2)))<1e-12);
                end
                for c=1:2
                    result=results{c}; assert(isequal(result.folds,stage3_prediction_folds(n,targets)));
                    if c==1, state=full.states; event=full; else, state=cat(1,full.states(1:500,:,:),r.prep.states); event=r.prep; end
                    for j=ids
                        centers={-100:10:0,event.peakMs(j)+(-150:10:-50)};
                        for epoch=1:2
                            epochs=[1 3]; e=epochs(epoch);
                            for k=1:11
                                t=centers{epoch}(k); ii=find(abs(full.timeGOms-t)<=150);
                                if e==1, ii=ii(full.timeGOms(ii)<=0); else, ii=ii(full.timeGOms(ii)<=event.peakMs(j)-50); end
                                w=exp(-(full.timeGOms(ii)-t).^2/1800); w=w/sum(w);
                                expected=sum(max(state(ii,:,j),0).*w,1)./result.features.scale.'-result.features.invariant(k,:,1,e);
                                err=max(abs(expected-result.features.aligned(k,:,j,e)));
                                audit.maxFeatureError=max(audit.maxFeatureError,err); assert(err<1e-9);
                            end
                        end
                    end
                    for epoch=1:2
                        epochs=[1 3]; X=result.features.X{epochs(epoch)}; b=result.behavior{epoch};
                        audit=check_ridge(b.speed,X,audit);
                        audit=check_ols(b.hand,X*b.taskAxes,audit);
                        within=zeros(8,2);
                        for q=1:8
                            ii=targets==q;
                            audit=check_ols(b.handWithin{q},X(ii,:)*b.taskAxes,audit);
                            audit=check_ols(b.speedWithin{q},X(ii,:)*b.speedAxes,audit);
                            within(q,:)=[b.handWithin{q}.r2 b.speedWithin{q}.r2];
                        end
                        assert(max(abs(mean(within,1)-b.withinMean))<1e-12);
                    end
                    assert(max(abs(result.metrics-reshape(summary.metrics(n,p,c,:),1,8)))<1e-12);
                end
                assert(isequal(results{1}.features.X{1},results{2}.features.X{1}) || ...
                    max(abs(results{1}.features.X{1}-results{2}.features.X{1}),[],'all')<1e-12);
                audit.cases=audit.cases+1; fprintf('Independent causal audit %d/40 PASS\n',audit.cases);
            end
        end
        fields={'metrics','metricChange','variance','varianceRatios','varianceFullMinusPrep'};
        receipts={'bootstrap','changeBootstrap','varianceBootstrap','ratioBootstrap','varianceChangeBootstrap'};
        for f=1:numel(fields)
            values=reshape(summary.(fields{f}),10,[]); saved=summary.(receipts{f});
            for j=1:size(values,2)
                v=values(:,j); med=median(reshape(v(summary.bootstrapIndices),10000,10),2);
                se=sqrt(sum((med-mean(med)).^2)/9999);
                err=abs(se-saved.se(j)); audit.maxBootstrapError=max(audit.maxBootstrapError,err);
                assert(err<1e-12 && median(v)==saved.median(j));
            end
        end
        assert(isequal(summary.metricChange,summary.metrics(:,:,2,:)-summary.metrics(:,:,1,:)));
        assert(isequal(summary.varianceRatios,summary.variance(:,:,2:3,:)./summary.variance(:,:,1,:)));
        assert(isequal(summary.varianceFullMinusPrep,summary.variance(:,:,1,:)-summary.variance(:,:,2,:)));
        audit.status='PASS';
    catch exception
        audit.status='STOP'; audit.error=exception.message; audit.stack=exception.stack;
        stage3_write_json(fullfile(cfg.postRoot,'independent_audit.json'),audit); rethrow(exception);
    end
    stage3_write_json(fullfile(cfg.postRoot,'independent_audit.json'),audit); disp(audit);
end

function audit = check_ols(fit,X,audit)
    design=[ones(size(X,1),1),X]; prediction=zeros(size(fit.actual)); labels=unique(fit.folds);
    for j=1:numel(labels)
        test=fit.folds==labels(j); b=design(~test,:)\fit.actual(~test,:); prediction(test,:)=design(test,:)*b;
    end
    err=max(abs(prediction-fit.predicted),[],'all'); audit.maxPredictionError=max(audit.maxPredictionError,err); assert(err<1e-8);
    score=1-sum((fit.actual-prediction).^2,'all')/sum((fit.actual-mean(fit.actual,1)).^2,'all');
    err=abs(score-fit.r2); audit.maxR2Error=max(audit.maxR2Error,err); assert(err<1e-7); audit.fits=audit.fits+1;
end

function audit = check_ridge(fit,X,audit)
    Y=fit.actual;
    score=1-sum((Y-fit.predicted).^2,'all')/sum((Y-mean(Y,1)).^2,'all');
    err=abs(score-fit.r2); audit.maxR2Error=max(audit.maxR2Error,err); assert(err<1e-12);
    for outer=1:3
        train=fit.folds.outer~=outer; test=~train; B=fit.weights{outer}; a=fit.intercepts{outer};
        residual=X(train,:)*B+a-Y(train,:);
        equation=X(train,:).'*residual/sum(train)+fit.grid(fit.lambdaIndex(outer))*B;
        err=norm(equation,'fro')/max(1,norm(X(train,:).'*Y(train,:)/sum(train),'fro'));
        audit.maxRidgeResidual=max(audit.maxRidgeResidual,err); assert(err<1e-8);
        assert(max(abs(X(test,:)*B+a-fit.predicted(test,:)),[],'all')<1e-9);
        losses=zeros(1,numel(fit.grid));
        for inner=1:3
            tr=train & fit.folds.inner(:,outer)~=inner; va=train & fit.folds.inner(:,outer)==inner;
            xx=X(tr,:)-mean(X(tr,:),1); yy=Y(tr,:)-mean(Y(tr,:),1); gram=xx.'*xx; rhs=xx.'*yy;
            for g=1:numel(fit.grid)
                beta=(gram+sum(tr)*fit.grid(g)*eye(size(X,2)))\rhs;
                prediction=(X(va,:)-mean(X(tr,:),1))*beta+mean(Y(tr,:),1);
                losses(g)=losses(g)+sum((prediction-Y(va,:)).^2,'all');
            end
        end
        saved=fit.innerSSE(outer,:); relative=max(abs(losses-saved)./max(1,abs(saved)));
        audit.maxInnerLossRelativeError=max(audit.maxInnerLossRelativeError,relative); assert(relative<1e-6);
        [~,best]=min(saved); assert(best==fit.lambdaIndex(outer));
        assert(losses(best)<=min(losses)+1e-6*max(1,min(losses)));
    end
    [~,best]=min(sum(fit.innerSSE,1)); assert(best==fit.fullLambdaIndex);
    residual=X*fit.fullWeights+fit.fullIntercepts-Y;
    equation=X.'*residual/size(X,1)+fit.grid(best)*fit.fullWeights;
    err=norm(equation,'fro')/max(1,norm(X.'*Y/size(X,1),'fro'));
    audit.maxRidgeResidual=max(audit.maxRidgeResidual,err); assert(err<1e-8);
    audit.fits=audit.fits+1;
end
