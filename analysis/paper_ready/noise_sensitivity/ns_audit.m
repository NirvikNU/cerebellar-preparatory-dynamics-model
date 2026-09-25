function audit=ns_audit(root)
    cfg=ns_paths(root); path=fullfile(cfg.dest,'audit.json'); assert(~isfile(path));
    s=load(fullfile(cfg.dest,'summary.mat'),'summary'); summary=s.summary;
    s=load(fullfile(cfg.old.dest,'summary.mat'),'summary'); old=s.summary;
    assert(isequal(summary.indices,old.indices));
    for file={fullfile(cfg.old.dest,'audit.json'),fullfile(cfg.paper,'prediction','primary_audit.json')}
        a=jsondecode(fileread(file{1})); assert(strcmp(a.status,'PASS'));
    end
    audit=struct('status','RUNNING','newCases',0,'anchorCases',0,'shuffleRefits',0,'observedRefits',0,'matchedRefits',0, ...
        'drawError',0,'transitionError',0,'stateError',0,'convergenceError',0,'geometryError',0,'featureError',0, ...
        'pcaError',0,'predictionError',0,'lossError',0,'r2Error',0,'shuffleSummaryError',0,'movementError',0,'bootstrapError',0);
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'c','d'); c=s.c; d=s.d;
        z=zeros(200,240); xi=zeros(200,240,3); steps=[0 1250 2499]; seeds=310000000+10000*n+100*repelem(1:8,30)+repmat(1:30,1,8);
        for j=1:240
            rs=RandStream('mt19937ar','Seed',seeds(j)); z(:,j)=randn(rs,200,1); draws=randn(rs,200,2500); xi(:,j,:)=reshape(draws(:,steps+1),200,1,3);
        end
        s=load(fullfile(cfg.raw,sprintf('null_n%02d.mat',n)),'qrProjectors'); projectors=s.qrProjectors;
        for e=1:2
            for v=1:5
                cases=cell(1,2); directGeometry=cases;
                for p=1:2
                    s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_e%d_v%d_p%d.mat',n,e,v,p)),'result'); r=s.result; cases{p}=r;
                    assert(isequal(r.folds,stage3_prediction_folds(n,repelem((1:8).',30))));
                    if v==2
                        prior=load(fullfile(cfg.old.raw,sprintf('analysis_n%02d_e%d_p%d.mat',n,cfg.oldEta(e),p)),'result');
                        assert(isequaln(r.convergence,prior.result.convergence) && isequaln(r.geometry,prior.result.geometry));
                        assert(isequaln(r.prediction.fit,prior.result.prediction.fit)); audit.anchorCases=audit.anchorCases+1;
                        directGeometry{p}=r.geometry;
                    else
                        [prep,move]=ns_load(cfg,n,e,v,p); eq=m.xstar; if p==2, eq=d.xB; end
                        assert(isequal(prep.seeds,seeds) && prep.dt==.0002 && isequal(prep.flags,cfg.flags(p,:)));
                        assert(prep.sInit==cfg.pairs(v,1) && prep.sTemporal==cfg.pairs(v,2));
                        audit.drawError=max(audit.drawError,max(abs(prep.initial-(m.spontaneous+cfg.pairs(v,1)*z)),[],'all'));
                        for j=1:3
                            a=prep.audit(j); assert(a.step==steps(j));
                            increment=cfg.pairs(v,2)*sqrt(2*m.dt/m.tau)*xi(:,:,j);
                            audit.drawError=max(audit.drawError,max(abs(increment-a.noiseIncrement),[],'all'));
                            equilibrium=eq(:,repelem(1:8,30)); f=-equilibrium+m.W*max(equilibrium,0)+m.h;
                            u=-f-c.kappa0*cfg.eta(e)*(a.x-equilibrium); if p==1, u=u-c.L*(a.x-equilibrium); end
                            next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h+u)+increment;
                            audit.transitionError=max(audit.transitionError,max(abs(next-a.next),[],'all'));
                        end
                        assert(isequal(squeeze(prep.states(end,:,:)),prep.go) && isequal(squeeze(move.states(1,:,:)),prep.go));
                        for a=move.audit
                            next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h+published_movement_input(a.step*m.dt,m));
                            audit.transitionError=max(audit.transitionError,max(abs(next-a.next),[],'all'));
                        end
                        for t=[1 200 599]
                            torque=m.C*max(squeeze(move.states(t,:,:)),0);
                            audit.movementError=max(audit.movementError,max(abs(torque-squeeze(move.torque(t,:,:))),[],'all'));
                        end
                        rates=zeros(11,200,8);
                        for q=1:8
                            ids=(q-1)*30+(1:30); go=reshape(prep.states(end,:,ids),200,30); cue=reshape(prep.states(1,:,ids),200,30);
                            mu=sum(go,2)/30; bias=norm(mu-eq(:,q)); denominator=norm(sum(cue,2)/30-eq(:,q)); spread=sqrt(sum((go-mu).^2,'all')/30);
                            audit.stateError=max([audit.stateError abs(bias-r.bias(q)) abs(denominator-r.cueDistance(q)) abs(spread-r.dispersion(q))]);
                            rates(:,:,q)=sum(max(prep.states(401:10:501,:,ids),0),3)/30;
                        end
                        audit.convergenceError=max(audit.convergenceError,ns_convergence_audit(prep.states,r.scale,r.convergence));
                        g=paper95_direct(rates,r.scale); directGeometry{p}=g; assert(g.k==r.geometry.k);
                        audit.geometryError=max([audit.geometryError abs(g.pr-r.geometry.pr) max(abs(g.cov-r.geometry.cov),[],'all')]);
                        audit.movementError=max(audit.movementError,ns_movement_audit(move,m));
                        bounded=prep.rateMax<=r.bounds(1) && prep.stateMax<=r.bounds(2) && max(prep.componentMax)<=r.bounds(3);
                        assert(bounded==r.qc.prepBounds && all(isfinite(prep.states),'all') && all(isfinite(move.states),'all'));
                        assert(r.qc.missingWindow==sum(move.missingWindow) && r.qc.nearZero==sum(move.nearZero));
                        assert(r.qc.boundaryPeak==sum(move.boundaryPeak) && r.qc.multiPeak==sum(move.multiPeakCount>=2));
                        if r.predictionEvaluable
                            a=ns_prediction_audit(r.prediction,prep.states,move,r.scale,n==1);
                            for name={'featureError','pcaError','predictionError','lossError','r2Error'}, audit.(name{1})=max(audit.(name{1}),a.(name{1})); end
                            audit.observedRefits=audit.observedRefits+1; audit.shuffleRefits=audit.shuffleRefits+(n==1);
                        end
                        audit.newCases=audit.newCases+1; clear prep move
                    end
                    if r.predictionEvaluable
                        audit.shuffleSummaryError=max(audit.shuffleSummaryError,ns_shuffle_audit(r.prediction,n));
                        if n==1 && e==1 && v==2
                            pred=r.prediction; a=ns_fit_audit(pred.pca{1}.scores(:,1:pred.pca{1}.k),pred.shuffleFit,1);
                            for name={'predictionError','lossError','r2Error'}, audit.(name{1})=max(audit.(name{1}),a.(name{1})); end
                            audit.shuffleRefits=audit.shuffleRefits+1;
                        end
                        assert(r.prediction.fit.r2(1)==summary.r2(n,e,v,p));
                        pred=r.prediction;
                        if pred.reusedShuffles, values=pred.fit.r2(2:end); else, values=pred.shuffleFit.r2; end
                        assert(isequal(median(values),summary.shuffle(n,e,v,p)));
                    else
                        assert(isnan(summary.r2(n,e,v,p)));
                    end
                    if r.evaluable
                        assert(isequaln(r.convergence.value,summary.convergence(n,e,v,p)) && isequaln(r.geometry.pr,summary.pr(n,e,v,p)));
                    else
                        assert(isnan(summary.convergence(n,e,v,p)) && isnan(summary.pr(n,e,v,p)));
                    end
                    assert(isequaln(r.qc,summary.qc{n,e,v,p}) && r.convergence.undefined==summary.undefined(n,e,v,p));
                    assert(isequaln(mean(r.relativeBias),summary.bias(n,e,v,p)) && isequaln(mean(r.dispersion),summary.dispersion(n,e,v,p)));
                    assert(isequaln(median(r.movement.moMs),summary.mo(n,e,v,p)) && isequaln(median(r.movement.peakMs),summary.peakTime(n,e,v,p)));
                    assert(isequaln(median(r.movement.peak),summary.peakSpeed(n,e,v,p)));
                    assert(isequaln(1000*mean(r.movement.endpointRmsByTarget),summary.endpoint(n,e,v,p)));
                    assert(isequaln(r.movement.targetSeparationToScatter,summary.separation(n,e,v,p)));
                end
                a=directGeometry{1}; b=directGeometry{2}; k=a.k;
                if cases{1}.evaluable && cases{2}.evaluable
                    assert(abs(trace(projectors{k})-k)<1e-9 && norm(projectors{k}-projectors{k}.','fro')<1e-9);
                    den=sum(a.eigenvalues(1:k)); ob=trace(b.basis(:,1:k).'*a.cov*b.basis(:,1:k))/den; ex=trace(a.cov*projectors{k})/den;
                    assert(summary.k(n,e,v)==k); audit.geometryError=max([audit.geometryError abs(ob-summary.observed(n,e,v)) abs(ex-summary.expected(n,e,v))]);
                end
                if all(cellfun(@(r)r.predictionEvaluable,cases))
                    s=load(fullfile(cfg.raw,sprintf('matched_n%02d_e%d_v%d.mat',n,e,v)),'paired','kk');
                    kk=min([cases{1}.prediction.pca{1}.k cases{1}.prediction.pca{2}.k;cases{2}.prediction.pca{1}.k cases{2}.prediction.pca{2}.k]); assert(isequal(s.kk,kk));
                    for p=1:2
                        assert(isequal(s.paired{p}.actual,cases{p}.prediction.pca{2}.scores(:,1:kk(2))));
                        assert(isequal(s.paired{p}.folds,cases{p}.folds) && isequal(s.paired{p}.grid,cfg.grid));
                        if ~(e==2 && v==2)
                            a=ns_fit_audit(cases{p}.prediction.pca{1}.scores(:,1:kk(1)),s.paired{p},1);
                            for name={'predictionError','lossError','r2Error'}, audit.(name{1})=max(audit.(name{1}),a.(name{1})); end
                            audit.matchedRefits=audit.matchedRefits+1;
                        end
                        assert(s.paired{p}.r2(1)==summary.matched(n,e,v,p));
                    end
                end
            end
        end
        fprintf('Independent saved-output checks complete network%d.\n',n);
    end
    assert(isequaln(summary.deltaC,summary.convergence(:,:,:,2)-summary.convergence(:,:,:,1)));
    assert(isequaln(summary.deltaR2,summary.r2(:,:,:,2)-summary.r2(:,:,:,1)));
    intact=summary.r2(:,:,:,1); loss=-100*summary.deltaR2./intact; loss(~isfinite(intact)|intact<=eps(max(1,abs(intact))))=NaN;
    assert(isequaln(loss,summary.lossPct));
    for name=fieldnames(summary.bootstrap).'
        v=reshape(summary.(name{1}),10,[]); saved=summary.bootstrap.(name{1});
        for j=1:size(v,2)
            values=v(:,j); draws=median(reshape(values(summary.indices),size(summary.indices)),2);
            se=sqrt(sum((draws-sum(draws)/10000).^2)/9999); med=median(values);
            assert(isequal(isnan(se),isnan(saved.se(j))) && isequal(isnan(med),isnan(saved.median(j))));
            if isfinite(se), audit.bootstrapError=max([audit.bootstrapError abs(se-saved.se(j)) abs(med-saved.median(j))]); end
        end
    end
    assert(audit.newCases==160 && audit.anchorCases==40);
    assert(audit.drawError<1e-12 && audit.transitionError<1e-10 && audit.stateError<1e-10);
    assert(audit.convergenceError<1e-8 && audit.geometryError<1e-9 && audit.featureError<1e-10 && audit.pcaError<1e-9);
    assert(audit.predictionError<1e-8 && audit.lossError<1e-6 && audit.r2Error<1e-10 && audit.shuffleSummaryError<1e-10);
    assert(audit.movementError<1e-10 && audit.bootstrapError<1e-10);
    audit.status='PASS'; audit.shuffleCoverage=sprintf(['Predeclared shuffle1, network1,16 new cases plus2 eta0 anchors; ', ...
        '%d/18 independently refitted (a whole unevaluable case is not rescued by trial exclusion). ', ...
        'All saved shuffle permutations/selections/predictions/summaries checked.'],audit.shuffleRefits);
    audit.anchorAuditsReused=true; audit.noNewTrajectoryAuditReplays=true; paper_json(path,audit);
end
