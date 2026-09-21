function audit = paper95_control_audit(root)
    % Independent saved-output verification; no simulations or selections changed.
    addpath(fullfile(root,'analysis','stage_3')); cfg=stage3_bio_paths(root);
    dest=fullfile(root,'results','paper_ready','alignment95'); cache=fullfile(root,'results','paper_ready','cache','alignment95');
    s=load(fullfile(dest,'geometry.mat'),'result'); grid=s.result;
    s=load(fullfile(dest,'controls.mat'),'result'); controls=s.result;
    audit=struct('metricError',0,'residualError',0,'movementTransitionError',0, ...
        'endpointError',0,'checks',0,'predictionRun',false);
    losses=nan(36,1); eligible=false(36,1);
    for j=1:36
        rows=grid.map.gridIndex==j; eligible(j)=all(grid.map.feasible(rows));
        if all(grid.map.tested(rows))
            effect=[median(grid.map.prBlock(rows)-grid.map.prIntact(rows)), ...
                median(grid.map.expected(rows)-grid.map.observed(rows))];
            target=[grid.target.deltaPR grid.target.alignmentDeficit];
            losses(j)=sum(((effect-target)./abs(target)).^2);
        end
    end
    finiteLoss=isfinite(losses);
    assert(isequal(isnan(losses),isnan(grid.loss)) && max(abs(losses(finiteLoss)-grid.loss(finiteLoss)))<1e-12 ...
        && isequal(eligible,grid.commonFeasible));
    best=min(losses(eligible)); choices=find(eligible & abs(losses-best)<=1e-12*max(1,abs(best)));
    assert(choices(1)==grid.selectedIndex);
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); scale=s.ref.scale;
        s=load(fullfile(cache,sprintf('controls_n%02d.mat',n)));
        [Ci,evi]=covariance(s.policies{1}.lateRates,scale);
        K=1; while sum(evi(1:K))/sum(evi)<.95, K=K+1; end
        assert(K==controls.kControl(n) && abs(trace(s.qrProjectors{K})-K)<1e-9);
        den=sum(evi(1:K)); expected=trace(Ci*s.qrProjectors{K})/den;
        for p=1:4
            [C,ev,B,res]=covariance(s.policies{p}.lateRates,scale);
            observed=trace(B(:,1:K).'*Ci*B(:,1:K))/den;
            values=[trace(C)^2/trace(C*C),observed,expected,expected-observed,res];
            original=reshape(controls.policy(n,p,1:5),1,5);
            audit.metricError=max(audit.metricError,max(abs(values-original)));
            assert(abs(sum(ev)^2/sum(ev.^2)-values(1))<1e-10);
            move=s.moves{p};
            for a=move.audit
                next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h+published_movement_input(a.step*m.dt,m));
                audit.movementTransitionError=max(audit.movementTransitionError,max(abs(next-a.next),[],'all'));
            end
            endpoint=squeeze(move.hand(end,[1 3],:));
            for q=1:8
                ix=(q-1)*30+(1:30); e=endpoint(:,ix); e=e-mean(e,2);
                rms=sqrt(sum(e.^2,'all')/30);
                audit.endpointError=max(audit.endpointError,abs(rms-move.endpointRmsByTarget(q)));
            end
            audit.checks=audit.checks+16;
            for ti=1:51
                last=(ti-1)*10+1;
                ri=s.policies{1}.meanRates(max(1,last-100):10:last,:,:);
                rb=s.policies{p}.meanRates(max(1,last-100):10:last,:,:);
                padding=repmat(repmat(max(m.spontaneous,0).',1,1,8),11-size(ri,1),1,1);
                qi=paper95_direct(cat(1,padding,ri),scale);
                qb=paper95_direct(cat(1,padding,rb),scale); kt=qi.k;
                assert(kt==controls.kTime(n,ti) && abs(trace(s.qrProjectors{kt})-kt)<1e-9);
                denominator=sum(qi.eigenvalues(1:kt));
                observedTime=sum(var(qi.X*qb.basis(:,1:kt),0,1))/denominator;
                expectedTime=trace(qi.cov*s.qrProjectors{kt})/denominator;
                audit.metricError=max(audit.metricError,max(abs([qb.pr-controls.time(n,p,ti,4), ...
                    expectedTime-observedTime-controls.time(n,p,ti,5)])));
                audit.checks=audit.checks+4;
            end
            halves=cell(1,2);
            for h=1:2
                means=zeros(11,200,8);
                for q=1:8
                    ix=(q-1)*30+(h-1)*15+(1:15);
                    means(:,:,q)=sum(s.policies{p}.lateRates(:,:,ix),3)/15;
                end
                halves{h}=paper95_direct(means,scale);
            end
            kh=halves{1}.k; assert(kh==controls.kHalf(n,p));
            denominator=sum(halves{1}.eigenvalues(1:kh));
            observedHalf=sum(var(halves{1}.X*halves{2}.basis(:,1:kh),0,1))/denominator;
            expectedHalf=trace(halves{1}.cov*s.qrProjectors{kh})/denominator;
            audit.metricError=max(audit.metricError,max(abs([observedHalf-controls.reliability(n,p,5), ...
                expectedHalf-controls.reliability(n,p,6)])));
            audit.checks=audit.checks+3;
        end
        for kind=1:2
            for k=1:5
                [C,~,B,res]=covariance(s.levels{kind,k}.lateRates,scale);
                [~,~,~,raw]=covariance(s.levels{kind,k}.lateRates,ones(200,1));
                observed=trace(B(:,1:K).'*Ci*B(:,1:K))/den;
                values=[trace(C)^2/trace(C*C) observed expected expected-observed res raw];
                original=reshape(controls.noise(n,kind,k,:),1,6);
                audit.metricError=max(audit.metricError,max(abs(values(1:4)-original(1:4))));
                audit.residualError=max(audit.residualError,max(abs(values(5:6)-original(5:6))));
                audit.checks=audit.checks+6;
            end
            assert(isequal(s.levels{kind,3}.go,s.policies{1}.go));
        end
    end
    assert(audit.metricError<1e-9 && audit.residualError<1e-9 && audit.movementTransitionError<1e-9 && audit.endpointError<1e-9);
    audit.status='PASS'; paper_json(fullfile(dest,'control_audit.json'),audit); disp(audit);
end

function [C,ev,B,residual]=covariance(rates,scale)
    X=zeros(88,200); total=0;
    for neuron=1:200
        targetMeans=zeros(11,8);
        for q=1:8
            a=squeeze(rates(:,neuron,(q-1)*30+(1:30)))/scale(neuron);
            targetMeans(:,q)=sum(a,2)/30;
            deviations=a-targetMeans(:,q);
            total=total+sum(deviations.^2,'all')/29;
        end
        targetMeans=targetMeans-sum(targetMeans,2)/8;
        X(:,neuron)=targetMeans(:);
    end
    X=X-sum(X,1)/88; C=X.'*X/87;
    [B,D]=eig((C+C.')/2); [ev,ix]=sort(diag(D),'descend'); B=B(:,ix); ev=max(ev,0);
    residual=total/(11*200*8);
end
