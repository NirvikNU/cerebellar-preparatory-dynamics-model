function audit = paper_audit(root)
    addpath(fullfile(root,'analysis','stage_3')); cfg=stage3_bio_paths(root);
    dest=fullfile(root,'results','paper_ready');
    s=load(fullfile(dest,'geometry.mat'),'result'); grid=s.result;
    s=load(fullfile(dest,'controls.mat'),'result'); controls=s.result;
    audit=struct('checks',0,'maxPR',0,'maxAlignment',0,'maxCapture',0,'maxAdaptive',0,'maxTransition',0,'maxArm',0,'maxSE',0);
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(dest,'cache',sprintf('grid_n%02d.mat',n)));
        [Ci,evi]=independentCov(s.intact.meanRates(401:10:501,:,:),ref.scale);
        for j=1:36
            row=find(grid.map.network==n & grid.map.gridIndex==j);
            if isempty(s.blocks{j}), assert(~grid.map.tested(row)); continue; end
            p=s.blocks{j}; [Cb,ev,B]=independentCov(p.meanRates(401:10:501,:,:),ref.scale);
            pr=sum(ev)^2/sum(ev.^2); obs=sum(sum((B(:,1:15).'*Ci).*B(:,1:15).'))/sum(evi(1:15));
            expc=trace(Ci*s.qrProjectors{15})/sum(evi(1:15));
            audit.maxPR=max(audit.maxPR,max(abs([pr-grid.map.prBlock(row),sum(evi)^2/sum(evi.^2)-grid.map.prIntact(row)])));
            audit.maxAlignment=max(audit.maxAlignment,max(abs([obs-grid.map.observed(row),expc-grid.map.expected(row)])));
            capture=[sum(evi(1:15))/sum(evi) sum(ev(1:15))/sum(ev)];
            audit.maxCapture=max(audit.maxCapture,max(abs(capture-[grid.map.captureIntact15(row) grid.map.captureBlock15(row)])));
            K=max(find(cumsum(evi)>.95*sum(evi),1),find(cumsum(ev)>.95*sum(ev),1));
            assert(K==grid.map.commonK(row));
            adaptive=[trace(B(:,1:K).'*Ci*B(:,1:K)),trace(Ci*s.qrProjectors{K})]/sum(evi(1:K));
            audit.maxAdaptive=max(audit.maxAdaptive,max(abs(adaptive-[grid.map.observedAdaptive(row) grid.map.expectedAdaptive(row)])));
            assert(abs(pr-trace(Cb)^2/trace(Cb*Cb))<1e-10);
            audit.checks=audit.checks+10;
        end
        s=load(fullfile(dest,'cache',sprintf('controls_n%02d.mat',n)));
        targets=repelem(1:8,30); c=s.c; d=s.d;
        for policy=1:4
            p=s.policies{policy}; flags=cfg.policyFlags(policy,:);
            fB=-d.xB+m.W*max(d.xB,0)+m.h;
            fS=-m.xstar+m.W*max(m.xstar,0)+m.h;
            b=fB-fS+c.kappa0*(m.xstar-d.xB);
            for a=p.audit
                xx=a.x; u0=-fB(:,targets)-c.kappa0*(xx-d.xB(:,targets));
                cb=flags(1)*b(:,targets)-flags(2)*c.L*(xx-m.xstar(:,targets));
                pred=xx+m.dt/m.tau*(-xx+m.W*max(xx,0)+m.h+u0+cb)+a.noiseIncrement;
                audit.maxTransition=max(audit.maxTransition,max(abs(pred-a.next),[],'all'));
                audit.checks=audit.checks+1;
            end
            move=s.moves{policy}; speed=sqrt(squeeze(move.hand(:,2,:)).^2+squeeze(move.hand(:,4,:)).^2);
            [pk,pi]=max(speed,[],1); assert(max(abs(pk-move.peak))<1e-12 && isequal(pi-1,move.peakMs));
            for trial=1:240
                if pk(trial)>0, onset=find(speed(:,trial)>=.2*pk(trial),1)-1; else, onset=NaN; end
                assert(isequaln(onset,move.moMs(trial))); audit.checks=audit.checks+1;
            end
            assert(isequal(pk<=1e-8,move.nearZero));
            assert(isequal(pi==1|pi==size(speed,1),move.boundaryPeak));
            assert(isequal(pk<=0|move.moMs+100>m.nSamples-1,move.missingWindow));
            audit.checks=audit.checks+3;
            for t=[1 200 599]
                if t>size(move.torque,1), continue; end
                q=squeeze(move.theta(t,:,:)); tq=squeeze(move.torque(t,:,:));
                q1=q(1,:); v1=q(2,:); q2=q(3,:); v2=q(4,:); arm=m.arm;
                a1=arm.I1+arm.I2+arm.M2*arm.L1^2; a2=arm.M2*arm.L1*arm.S2; a3=arm.I2;
                m11=a1+2*a2*cos(q2); m12=a3+a2*cos(q2); m22=a3;
                rhs=tq-[-a2*sin(q2).*v2.*(2*v1+v2);a2*sin(q2).*v1.^2]-arm.B*[v1;v2];
                detm=m11*m22-m12.^2;
                acc=[(m22*rhs(1,:)-m12.*rhs(2,:))./detm;(m11.*rhs(2,:)-m12.*rhs(1,:))./detm];
                next=[q1+m.samplingDt*v1;v1+m.samplingDt*acc(1,:);q2+m.samplingDt*v2;v2+m.samplingDt*acc(2,:)];
                audit.maxArm=max(audit.maxArm,max(abs(next-squeeze(move.theta(t+1,:,:))),[],'all'));
                audit.checks=audit.checks+240;
            end
        end
    end
    for name={'noise','policy','time'}
        values=reshape(controls.(name{1}),10,[]); expected=controls.summary.(name{1});
        for j=1:size(values,2)
            v=values(:,j); medians=median(v(controls.indices),2);
            se=sqrt(sum((medians-mean(medians)).^2)/(numel(medians)-1));
            if isfinite(se)
                audit.maxSE=max(audit.maxSE,abs(se-expected.se(j)));
                assert(abs(median(v)-expected.median(j))<1e-10);
            end
            audit.checks=audit.checks+1;
        end
    end
    assert(audit.maxPR<1e-9 && audit.maxAlignment<1e-9 && audit.maxCapture<1e-9 && audit.maxAdaptive<1e-9 ...
        && audit.maxTransition<1e-9 && audit.maxArm<1e-9 && audit.maxSE<1e-9);
    audit.status='PASS'; audit.predictionRun=false;
    paper_json(fullfile(dest,'independent_audit.json'),audit); disp(audit);
end

function [C,ev,B]=independentCov(rates,scale)
    X=zeros(size(rates,1)*size(rates,3),numel(scale));
    for neuron=1:numel(scale)
        a=squeeze(rates(:,neuron,:))/scale(neuron); a=a-mean(a,2);
        X(:,neuron)=a(:);
    end
    X=X-mean(X,1); C=cov(X); [B,D]=eig((C+C.')/2);
    [ev,order]=sort(diag(D),'descend'); B=B(:,order); ev=max(ev,0);
end
