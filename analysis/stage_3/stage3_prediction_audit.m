function audit = stage3_prediction_audit(root)
    cfg=stage3_prediction_paths(root);
    assert(~isfile(fullfile(cfg.predRoot,'independent_audit.json')));
    loaded=load(fullfile(cfg.predRoot,'summary.mat'),'summary'); summary=loaded.summary;
    audit=struct('status','running','cases',0,'checks',0,'maxIncrementError',0, ...
        'maxArmError',0,'maxFeatureError',0,'maxRidgeResidual',0,'maxR2Error',0, ...
        'maxBootstrapError',0,'maxInnerLossRelativeError',0);
    loaded=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); controllers=loaded.controllers;
    loaded=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=loaded.registry;
    try
        for network=1:10
            loaded=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',network)),'model'); m=loaded.model;
            ids=[1 30 121 240]; targets=repelem(1:8,30); trials=repmat(1:30,1,8);
            noise=stage3_prediction_noise(m,network,targets(ids),trials(ids));
            for level=1:3
                caseScores=cell(4,2); caseAxes=cell(4,2); caseK=zeros(4,2);
                for policy=1:4
                    loaded=load(fullfile(cfg.predCache,sprintf('n%02d_s%d_p%d.mat',network,level,policy)),'out'); out=loaded.out;
                    loaded=load(fullfile(cfg.predCache,sprintf('analysis_n%02d_s%d_p%d.mat',network,level,policy)),'result'); result=loaded.result;
                    assert(isequal(out.targets,targets) && isequal(out.trials,trials));
                    assert(isequal(result.folds,stage3_prediction_folds(network,targets)));
                    assert(isequal(out.seeds(ids),noise.seeds) && out.s==cfg.noiseLevels(level));
                    initial=repmat(m.spontaneous,1,4)+out.s*noise.initial;
                    assert(max(abs(squeeze(out.states(1,:,ids))-initial),[],'all')<1e-12);
                    c=controllers{network}; d=registry.primary{network}; flags=cfg.policyFlags(policy,:);
                    for index=[1 401 500 501 551 1001]
                        x=squeeze(out.states(index,:,ids));
                        for substep=0:4
                            step=(index-1)*5+substep;
                            if step<2500
                                input=-c.fB(:,targets(ids))-c.kappa0*(x-d.xB(:,targets(ids))) ...
                                    +flags(1)*c.b(:,targets(ids))-flags(2)*c.L*(x-m.xstar(:,targets(ids)));
                            else
                                input=published_movement_input((step-2500)*m.dt,m);
                            end
                            x=x+(m.dt/m.tau)*(-x+m.W*max(x,0)+m.h+input) ...
                                +out.s*sqrt(2*m.dt/m.tau)*noise.process(:,:,step+1);
                        end
                        err=max(abs(x-squeeze(out.states(index+1,:,ids))),[],'all');
                        audit.maxIncrementError=max(audit.maxIncrementError,err); assert(err<1e-10);
                    end
                    for j=1:240
                        speed=sqrt(out.hand(:,2,j).^2+out.hand(:,4,j).^2);
                        [peak,index]=max(speed); mo=find(speed>=peak/5,1)-1;
                        assert(mo==out.moMs(j) && index-1==out.peakMs(j) && abs(peak-out.peakSpeed(j))<1e-12);
                        assert(isequal(out.peakPosition(j,:),out.hand(index,[1 3],j)));
                    end
                    for j=ids
                        for k=[1 50 100 250 500]
                            state=out.theta(k,:,j); a=m.arm; dq1=state(2); q2=state(3); dq2=state(4);
                            A=a.I1+a.I2+a.M2*a.L1^2+2*a.M2*a.L1*a.S2*cos(q2);
                            B=a.I2+a.M2*a.L1*a.S2*cos(q2); D=a.I2;
                            z=a.M2*a.L1*a.S2*sin(q2);
                            rhs=out.torque(k,:,j).'-[-z*dq2*(2*dq1+dq2);z*dq1^2]-a.B*[dq1;dq2];
                            accel=[D*rhs(1)-B*rhs(2);A*rhs(2)-B*rhs(1)]/(A*D-B^2);
                            next=state+.001*[dq1 accel(1) dq2 accel(2)];
                            err=max(abs(next-out.theta(k+1,:,j))); audit.maxArmError=max(audit.maxArmError,err); assert(err<1e-10);
                        end
                    end
                    % Independent neuron-column, one-trial/epoch weighted sums.
                    for j=ids
                        centers={-100:10:0,out.moMs(j)+(0:10:100),out.peakMs(j)+(-150:10:-50)};
                        for epoch=1:3
                            for k=1:11
                                t=centers{epoch}(k); ii=find(abs(out.timeGOms-t)<=150);
                                if epoch==1, ii=ii(out.timeGOms(ii)<=0); end
                                if epoch==2, ii=ii(out.timeGOms(ii)>=out.moMs(j)); end
                                if epoch==3, ii=ii(out.timeGOms(ii)<=out.peakMs(j)-50); end
                                w=exp(-(out.timeGOms(ii)-t).^2/1800); w=w/sum(w);
                                expected=sum(max(out.states(ii,:,j),0).*w,1)./result.features.scale.';
                                expected=expected-result.features.invariant(k,:,1,epoch);
                                err=max(abs(expected-result.features.aligned(k,:,j,epoch)));
                                audit.maxFeatureError=max(audit.maxFeatureError,err); assert(err<1e-9);
                            end
                        end
                    end
                    for epoch=1:2
                        X=result.features.X{epoch}; pc=result.pca{epoch}; centered=X-mean(X,1);
                        caseScores{policy,epoch}=pc.scores; caseK(policy,epoch)=pc.k;
                        C=centered.'*centered/239;
                        assert(norm(C*pc.basis-pc.basis.*pc.eigenvalues.','fro')<1e-7*max(1,norm(C,'fro')));
                        fractions=cumsum(pc.eigenvalues)/sum(pc.eigenvalues);
                        assert(fractions(pc.k)>=.75 && (pc.k==1 || fractions(pc.k-1)<.75));
                    end
                    audit=check_ridge(result.neural,result.pca{1}.scores(:,1:result.pca{1}.k),audit);
                    for epoch=1:2
                        e=[1 3]; X=result.features.X{e(epoch)}; b=result.behavior{epoch};
                        audit=check_ridge(b.speed,X,audit);
                        audit=check_ols(b.hand,X*b.taskAxes,audit);
                        for q=1:8
                            ii=find(targets==q);
                            audit=check_ols(b.handWithin{q},X(ii,:)*b.taskAxes,audit);
                            audit=check_ols(b.speedWithin{q},X(ii,:)*b.speedAxes(:,1),audit);
                        end
                        assert(norm(b.taskAxes.'*b.taskAxes-eye(2),'fro')<1e-10);
                        numerator=sum((b.heldoutProjection-mean(b.heldoutProjection)).^2);
                        denominator=sum((X-mean(X,1)).^2,'all');
                        assert(abs(numerator/denominator-b.capturedVariance)<1e-12);
                        assert(max(abs(vecnorm(b.speedAxes)-1))<1e-10);
                        caseAxes{policy,epoch}=b.speedAxes;
                        full=reshape(b.speed.fullWeights,200,[]);
                        assert(max(abs(full./vecnorm(full)-b.speedAxes),[],'all')<1e-12);
                        loss=reshape(sum(b.speed.innerSSE,1),25,[]); [~,best]=min(loss,[],1);
                        assert(isequal(best,b.speed.fullLambdaIndex));
                    end
                    assert(max(abs(result.metrics-reshape(summary.metrics(network,level,policy,:),1,11)))<1e-12);
                    audit.cases=audit.cases+1; audit.checks=audit.checks+1;
                    fprintf('Independent prediction audit %d/120 PASS\n',audit.cases);
                end
                loaded=load(fullfile(cfg.predCache,sprintf('matched_n%02d_s%d.mat',network,level)),'paired');
                for lesion=1:3
                    k=min(caseK([1 lesion+1],:),[],1);
                    assert(isequal(k,reshape(summary.matchedK(network,level,lesion,:),1,2)));
                    for condition=1:2
                        policyPair=[1 lesion+1]; pp=policyPair(condition); fit=loaded.paired{lesion,condition};
                        X=caseScores{pp,1}(:,1:k(1)); Y=caseScores{pp,2}(:,1:k(2));
                        assert(isequal(fit.actual,Y)); audit=check_ridge(fit,X,audit);
                        assert(abs(fit.r2-summary.matched(network,level,lesion,condition))<1e-12);
                    end
                    for epoch=1:2
                        aa=caseAxes{1,epoch}; bb=caseAxes{lesion+1,epoch};
                        align=zeros(1,101);
                        for rep=1:101, align(rep)=(aa(:,rep).'*bb(:,rep))^2; end
                        assert(abs(align(1)-summary.orientation(network,level,lesion,epoch))<1e-12);
                        assert(max(abs(align(2:end)-reshape(summary.orientationNull(network,level,lesion,epoch,:),1,100)))<1e-12);
                    end
                end
            end
        end
        values=reshape(summary.metrics,10,[]); boot=zeros(10000,size(values,2));
        for b=1:10000, boot(b,:)=median(values(summary.bootstrapIndices(b,:),:),1); end
        se=sqrt(sum((boot-mean(boot,1)).^2,1)/9999);
        audit.maxBootstrapError=max(abs(se-summary.bootstrap.se)); assert(audit.maxBootstrapError<1e-12);
        assert(max(abs(median(values,1)-summary.bootstrap.median))==0);
        audit=check_bootstrap(summary.matched,summary.matchedBootstrap,summary.bootstrapIndices,audit);
        audit=check_bootstrap(summary.chanceMedian,summary.chanceBootstrap,summary.bootstrapIndices,audit);
        audit=check_bootstrap(summary.orientationDeficit,summary.orientationBootstrap,summary.bootstrapIndices,audit);
        p=zeros(3,3); signs=2*(dec2bin(0:1023,10)-'0')-1;
        for metric=1:3
            for lesion=1:3
                delta=summary.metrics(:,2,lesion+1,metric)-summary.metrics(:,2,1,metric);
                p(lesion,metric)=sum(abs(signs*delta/10)>=abs(sum(delta)/10)-1e-12*max(1,abs(mean(delta))))/1024;
                bmed=median(reshape(delta(summary.bootstrapIndices),10000,10),2);
                assert(abs(std(bmed)-summary.tests{lesion,metric}.medianDifferenceSE)<1e-12);
                assert(median(delta)==summary.tests{lesion,metric}.medianDifference);
            end
        end
        [sorted,order]=sort(p(:)); q=sorted*9./(1:9).';
        for j=8:-1:1, q(j)=min(q(j),q(j+1)); end
        adjusted=zeros(9,1); adjusted(order)=min(1,q);
        assert(max(abs(p-summary.p),[],'all')==0 && max(abs(adjusted-summary.q(:)))<1e-15);
        audit.status='PASS';
    catch exception
        audit.status='STOP'; audit.error=exception.message; audit.stack=exception.stack;
        stage3_write_json(fullfile(cfg.predRoot,'independent_audit.json'),audit); rethrow(exception);
    end
    stage3_write_json(fullfile(cfg.predRoot,'independent_audit.json'),audit); disp(audit);
end

function audit = check_bootstrap(values,saved,indices,audit)
    values=reshape(values,10,[]);
    for j=1:size(values,2)
        v=values(:,j); med=median(reshape(v(indices),10000,10),2);
        se=sqrt(sum((med-mean(med)).^2)/9999);
        err=abs(se-saved.se(j)); audit.maxBootstrapError=max(audit.maxBootstrapError,err);
        assert(err<1e-12 && median(v)==saved.median(j));
    end
end

function audit = check_ridge(fit,X,audit)
    % Primary response plus saved null R2; normal equations independent of SVD.
    for rep=1:numel(fit.r2)
        Y=fit.actual(:,:,rep); prediction=fit.predicted(:,:,rep);
        score=1-sum((Y-prediction).^2,'all')/sum((Y-mean(Y,1)).^2,'all');
        audit.maxR2Error=max(audit.maxR2Error,abs(score-fit.r2(rep))); assert(abs(score-fit.r2(rep))<1e-12);
    end
    Y=fit.actual(:,:,1);
    for outer=1:3
        train=fit.folds.outer~=outer; test=~train;
        B=fit.weights{outer}(:,:,1); a=fit.intercepts{outer}(:,:,1);
        residual=X(train,:)*B+a-Y(train,:);
        equation=X(train,:).'*residual/sum(train)+fit.grid(fit.lambdaIndex(outer,1))*B;
        err=norm(equation,'fro')/max(1,norm(X(train,:).'*Y(train,:)/sum(train),'fro'));
        audit.maxRidgeResidual=max(audit.maxRidgeResidual,err); assert(err<1e-8);
        assert(max(abs(X(test,:)*B+a-fit.predicted(test,:,1)),[],'all')<1e-9);
        losses=zeros(1,numel(fit.grid));
        for inner=1:3
            tr=train & fit.folds.inner(:,outer)~=inner; va=train & fit.folds.inner(:,outer)==inner;
            xx=X(tr,:)-mean(X(tr,:),1); yy=Y(tr,:)-mean(Y(tr,:),1); gram=xx.'*xx; rhs=xx.'*yy;
            for g=1:numel(fit.grid)
                beta=(gram+sum(tr)*fit.grid(g)*eye(size(X,2)))\rhs;
                predicted=(X(va,:)-mean(X(tr,:),1))*beta+mean(Y(tr,:),1);
                losses(g)=losses(g)+sum((predicted-Y(va,:)).^2,'all');
            end
        end
        saved=reshape(fit.innerSSE(outer,:,1),1,[]);
        relative=max(abs(losses-saved)./max(1,abs(saved)));
        audit.maxInnerLossRelativeError=max(audit.maxInnerLossRelativeError,relative); assert(relative<1e-6);
        [~,best]=min(saved); assert(best==fit.lambdaIndex(outer,1));
        assert(losses(best)<=min(losses)+1e-6*max(1,min(losses)));
        audit.checks=audit.checks+1;
    end
end

function audit = check_ols(fit,X,audit)
    design=[ones(size(X,1),1),X]; predicted=zeros(size(fit.actual));
    labels=unique(fit.folds);
    for j=1:numel(labels)
        test=fit.folds==labels(j); train=~test;
        b=design(train,:)\fit.actual(train,:); predicted(test,:)=design(test,:)*b;
    end
    assert(max(abs(predicted-fit.predicted),[],'all')<1e-8);
    Y=fit.actual; score=1-sum((Y-predicted).^2,'all')/sum((Y-mean(Y,1)).^2,'all');
    audit.maxR2Error=max(audit.maxR2Error,abs(score-fit.r2)); assert(abs(score-fit.r2)<1e-7);
    audit.checks=audit.checks+1;
end
