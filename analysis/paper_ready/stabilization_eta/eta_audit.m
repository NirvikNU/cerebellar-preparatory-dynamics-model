function audit = eta_audit(root)
    % Independent saved-output analysis; no trajectory replays or parameter changes.
    cfg=eta_paths(root); path=fullfile(cfg.dest,'audit.json'); assert(~isfile(path));
    s=load(fullfile(cfg.dest,'summary.mat'),'summary'); summary=s.summary;
    audit=struct('status','RUNNING','cases',0,'stateError',0,'convergenceError',0, ...
        'geometryError',0,'featureError',0,'predictionError',0,'lossError',0,'r2Error',0, ...
        'transitionError',0,'torqueError',0,'movementError',0,'bootstrapError',0,'undefined',0);
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'c','d','policies'); c=s.c; d=s.d;
        anchor=s.policies{1};
        s=load(fullfile(cfg.raw,sprintf('null_n%02d.mat',n)),'qrProjectors'); projectors=s.qrProjectors;
        for e=1:5
            geometries=cell(1,2);
            for p=1:2
                [prep,move]=eta_load_case(cfg,n,e,p);
                assert(isequal(prep.initial,anchor.initial) && isequal(prep.seeds,anchor.seeds));
                assert(prep.sInit==.1 && prep.sTemporal==.1 && prep.dt==m.dt && isequal(prep.flags,cfg.flags(p,:)));
                for j=1:numel(prep.audit), assert(isequal(prep.audit(j).noiseIncrement,anchor.audit(j).noiseIncrement)); end
                s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_e%d_p%d.mat',n,e,p)),'result'); r=s.result;
                assert(isequal(r.folds,stage3_prediction_folds(n,repelem((1:8).',30))));
                validateFolds(r.folds,n);
                equilibrium=m.xstar; if p==2, equilibrium=d.xB; end
                for q=1:8
                    ids=(q-1)*30+(1:30); go=reshape(prep.states(end,:,ids),200,30);
                    cue=reshape(prep.states(1,:,ids),200,30);
                    mu=sum(go,2)/30; bias=sqrt(sum((mu-equilibrium(:,q)).^2));
                    denominator=sqrt(sum((sum(cue,2)/30-equilibrium(:,q)).^2));
                    spread=0; for trial=1:30, spread=spread+norm(go(:,trial)-mu)^2/30; end
                    audit.stateError=max([audit.stateError abs(bias-r.bias(q)) ...
                        abs(denominator-r.cueDistance(q)) abs(sqrt(spread)-r.dispersion(q))]);
                end
                audit=convergenceAudit(prep.states,r.scale,r.convergence,audit);
                rates=zeros(11,200,8);
                for q=1:8, rates(:,:,q)=sum(max(prep.states(401:10:501,:,(q-1)*30+(1:30)),0),3)/30; end
                g=paper95_direct(rates,r.scale); geometries{p}=g;
                assert(g.k==r.geometry.k);
                audit.geometryError=max([audit.geometryError abs(g.pr-r.geometry.pr) max(abs(g.cov-r.geometry.cov),[],'all')]);
                assert(abs(r.geometry.pr-summary.pr(n,e,p))<1e-12);
                assert(isequal(squeeze(prep.states(end,:,:)),prep.go) && isequal(squeeze(move.states(1,:,:)),prep.go));
                for a=prep.audit
                    eq=equilibrium(:,repelem(1:8,30)); f=-eq+m.W*max(eq,0)+m.h;
                    u=-f-c.kappa0*cfg.eta(e)*(a.x-eq);
                    if p==1, u=u-c.L*(a.x-eq); end
                    next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h+u)+a.noiseIncrement;
                    audit.transitionError=max(audit.transitionError,max(abs(next-a.next),[],'all'));
                end
                for a=move.audit
                    next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h+published_movement_input(a.step*m.dt,m));
                    audit.transitionError=max(audit.transitionError,max(abs(next-a.next),[],'all'));
                end
                for t=[1 200 599]
                    torque=m.C*max(squeeze(move.states(t,:,:)),0);
                    audit.torqueError=max(audit.torqueError,max(abs(torque-squeeze(move.torque(t,:,:))),[],'all'));
                end
                audit=movementAudit(move,m,audit);
                bounded=prep.rateMax<=r.bounds(1) && prep.stateMax<=r.bounds(2) && max(prep.componentMax)<=r.bounds(3);
                assert(bounded==summary.prepAdmissible(n,e,p));
                if r.predictionEvaluable
                    if e>1
                        audit=predictionAudit(r.prediction,prep.states,move.states,r.scale,audit);
                    end
                    assert(r.prediction.fit.r2(1)==summary.r2(n,e,p));
                else
                    assert(isnan(summary.r2(n,e,p)));
                end
                audit.cases=audit.cases+1; audit.undefined=audit.undefined+r.convergence.undefined;
            end
            a=geometries{1}; b=geometries{2}; k=a.k; assert(k==summary.k(n,e));
            den=sum(a.eigenvalues(1:k)); ob=sum(var(a.X*b.basis(:,1:k),0,1))/den;
            ex=trace(a.cov*projectors{k})/den;
            assert(abs(trace(projectors{k})-k)<1e-9);
            audit.geometryError=max([audit.geometryError abs(ob-summary.observed(n,e)) abs(ex-summary.expected(n,e))]);
        end
        fprintf('Independent saved-output audit complete: network %d.\n',n);
    end
    fields=fieldnames(summary.bootstrap);
    for j=1:numel(fields)
        v=reshape(summary.(fields{j}),10,[]); saved=summary.bootstrap.(fields{j});
        for column=1:size(v,2)
            values=v(:,column); boot=median(reshape(values(summary.indices),size(summary.indices)),2);
            mu=sum(boot)/numel(boot); se=sqrt(sum((boot-mu).^2)/(numel(boot)-1));
            audit.bootstrapError=max([audit.bootstrapError abs(se-saved.se(column)) abs(median(values)-saved.median(column))]);
        end
    end
    assert(audit.cases==100 && audit.stateError<1e-10 && audit.convergenceError<1e-8 && audit.geometryError<1e-9);
    assert(audit.featureError<1e-10 && audit.predictionError<1e-8 && audit.lossError<1e-6 && audit.r2Error<1e-10);
    assert(audit.transitionError<1e-10 && audit.torqueError<1e-10 && audit.movementError<1e-10 && audit.bootstrapError<1e-10);
    audit.status='PASS'; audit.reusedBaselineAudit='baseline.json'; audit.newTrajectoryReplays=0;
    audit.etaOnePredictionAuditReused='results/paper_ready/prediction/primary_audit.json';
    paper_json(path,audit);
end

function audit=convergenceAudit(states,scale,r,audit)
    scores=nan(240,1);
    for q=1:8
        ids=(q-1)*30+(1:30);
        for fold=1:3
            ref=ids(r.folds.outer(ids)~=fold); test=ids(r.folds.outer(ids)==fold);
            assert(isequal(ref,r.references{q,fold}) && isequal(test,r.heldout{q,fold}));
            X=zeros(51*20,200); cue=zeros(30,200); prego=cue;
            for neuron=1:200
                a=squeeze(max(states(1:10:501,neuron,ref),0))/scale(neuron); X(:,neuron)=a(:);
                cue(:,neuron)=squeeze(sum(max(states(1:10:101,neuron,ids),0),1))/11/scale(neuron);
                prego(:,neuron)=squeeze(sum(max(states(401:10:501,neuron,ids),0),1))/11/scale(neuron);
            end
            [V,D]=eig(cov(X)); [ev,order]=sort(max(diag(D),0),'descend'); V=V(:,order);
            k=1; while sum(ev(1:k))/sum(ev)<.95, k=k+1; end
            assert(k==r.k(q,fold)); B=V(:,1:k);
            ri=ref-(q-1)*30; ti=test-(q-1)*30;
            projectedCue=cue*B; projectedPrego=prego*B;
            rc=sum(projectedCue(ri,:),1)/20; rp=sum(projectedPrego(ri,:),1)/20;
            for j=1:10
                dc=norm(projectedCue(ti(j),:)-rc); dp=norm(projectedPrego(ti(j),:)-rp);
                audit.convergenceError=max([audit.convergenceError abs(dc-r.cue(test(j))) abs(dp-r.prego(test(j)))]);
                if isfinite(dc) && dc>eps(max(1,norm(X,'fro'))), scores(test(j))=1-dp/dc; end
            end
        end
    end
    assert(isequal(isnan(scores),isnan(r.c)));
    good=isfinite(scores); audit.convergenceError=max([audit.convergenceError max(abs(scores(good)-r.c(good))) abs(mean(scores)-r.value)]);
end

function audit=movementAudit(move,m,audit)
    speed=sqrt(squeeze(move.hand(:,2,:)).^2+squeeze(move.hand(:,4,:)).^2);
    endpoints=reshape(move.hand(end,[1 3],:),2,240); centers=zeros(2,8); scatters=zeros(8,1);
    for j=1:240
        [peak,ix]=max(speed(:,j)); mo=NaN;
        if peak>0, mo=find(speed(:,j)>=peak/5,1)-1; end
        assert(abs(peak-move.peak(j))<1e-12 && ix-1==move.peakMs(j) && isequaln(mo,move.moMs(j)));
        assert((peak<=1e-8)==move.nearZero(j));
        assert((ix==1 || ix==size(speed,1))==move.boundaryPeak(j));
        assert((~isfinite(mo)||mo+100>598)==move.missingWindow(j));
        previous=-Inf; count=0;
        for t=2:size(speed,1)-1
            if speed(t,j)>speed(t-1,j) && speed(t,j)>=speed(t+1,j) && speed(t,j)>=peak/2 && t-previous>=20
                count=count+1; previous=t;
            end
        end
        assert(count==move.multiPeakCount(j));
        for t=[1 200 599]
            state=reshape(move.theta(t,:,j),4,1); next=reshape(move.theta(t+1,:,j),4,1);
            q1=state(1); q2=state(3); v1=state(2); v2=state(4); a=m.arm;
            coupling=a.M2*a.L1*a.S2; z=coupling*cos(q2);
            mass=[a.I1+a.I2+a.M2*a.L1^2+2*z a.I2+z;a.I2+z a.I2];
            centrifugal=[-coupling*sin(q2)*v2*(2*v1+v2);coupling*sin(q2)*v1^2];
            acceleration=mass\(reshape(move.torque(t,:,j),2,1)-centrifugal-a.B*[v1;v2]);
            expected=state+m.samplingDt*[v1;acceleration(1);v2;acceleration(2)];
            hand=[a.L1*cos(q1)+a.L2*cos(q1+q2);-a.L1*v1*sin(q1)-a.L2*(v1+v2)*sin(q1+q2); ...
                a.L1*sin(q1)+a.L2*sin(q1+q2);a.L1*v1*cos(q1)+a.L2*(v1+v2)*cos(q1+q2)];
            audit.movementError=max([audit.movementError max(abs(expected-next)) max(abs(hand-reshape(move.hand(t,:,j),4,1)))]);
        end
    end
    for q=1:8
        x=endpoints(:,(q-1)*30+(1:30)); centers(:,q)=sum(x,2)/30;
        scatters(q)=sqrt(sum((x-centers(:,q)).^2,'all')/30);
    end
    distances=[];
    for q=1:7, for j=q+1:8, distances(end+1)=norm(centers(:,q)-centers(:,j)); end, end %#ok<AGROW>
    ratio=median(distances)/(sum(scatters)/8);
    audit.movementError=max([audit.movementError max(abs(scatters(:)-move.endpointRmsByTarget(:))) abs(ratio-move.targetSeparationToScatter)]);
end

function validateFolds(folds,n)
    outer=zeros(240,1); inner=zeros(240,3); targets=repelem((1:8).',30);
    for q=1:8
        ids=find(targets==q); rs=RandStream('mt19937ar','Seed',320000000+10000*n+q); ids=ids(randperm(rs,30));
        for j=1:30, outer(ids(j))=ceil(j/10); end
    end
    for o=1:3
        for q=1:8
            ids=find(targets==q & outer~=o); rs=RandStream('mt19937ar','Seed',321000000+10000*n+100*o+q); ids=ids(randperm(rs,20));
            for j=1:20, inner(ids(j),o)=1+mod(j-1,3); end
        end
    end
    assert(isequal(folds.outer,outer) && isequal(folds.inner,inner));
end

function audit=predictionAudit(r,prep,movement,scale,audit)
    for e=1:2
        ev=sort(max(eig(cov(r.features.X{e})),0),'descend');
        k=1; while sum(ev(1:k))/sum(ev)<.75, k=k+1; end
        assert(k==r.pca{e}.k && norm(r.pca{e}.basis.'*r.pca{e}.basis-eye(200),'fro')<1e-10);
    end
    X=r.pca{1}.scores(:,1:r.pca{1}.k); fit=r.fit; Y=fit.actual; pred=zeros(size(Y)); p=size(X,2);
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
        audit.lossError=max(audit.lossError,max(abs(loss-reshape(fit.innerSSE(o,:,:),25,1))));
        [~,best]=min(loss); assert(best==fit.lambdaIndex(o));
        D=[ones(sum(train),1) X(train,:)]; Dt=[ones(sum(~train),1) X(~train,:)];
        B=(D.'*D+diag([0 repmat(sum(train)*fit.grid(best),1,p)]))\(D.'*Y(train,:));
        pred(~train,:)=Dt*B;
    end
    audit.predictionError=max(audit.predictionError,max(abs(pred-fit.predicted),[],'all'));
    value=1-norm(Y-pred,'fro')^2/norm(Y-mean(Y,1),'fro')^2;
    audit.r2Error=max(audit.r2Error,abs(value-fit.r2));
    for j=[1 120 240]
        for e=1:2
            if e==1, t=(-500:0).'; raw=prep(:,:,j); centers=-100:10:0;
            else, t=(0:size(movement,1)-1).'; raw=movement(:,:,j); centers=r.features.moMs(j)+(0:10:100); end
            for z=1:11
                ids=find(abs(t-centers(z))<=150);
                if e==2, ids=ids(t(ids)>=r.features.moMs(j)); end
                w=exp(-((t(ids)-centers(z))/30).^2/2); w=w/sum(w);
                values=sum(w.*max(raw(ids,:),0),1)./scale(:).'-r.features.invariant(z,:,1,e);
                audit.featureError=max(audit.featureError,max(abs(values-r.features.aligned(z,:,j,e))));
            end
        end
    end
end
