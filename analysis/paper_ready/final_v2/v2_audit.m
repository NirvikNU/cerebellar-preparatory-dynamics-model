function audit=v2_audit(root)
    cfg=v2_paths(root); path=fullfile(cfg.dest,'audit.json'); assert(~isfile(path));
    s=load(fullfile(cfg.dest,'summary.mat'),'summary'); summary=s.summary;
    s=load(fullfile(cfg.dest,'geometry.mat'),'result'); calibration=s.result.map;
    selection=jsondecode(fileread(fullfile(cfg.dest,'geometry_selection.json')));
    s=load(fullfile(cfg.previous.dest,'summary.mat'),'summary'); assert(isequal(summary.indices,s.summary.indices));
    audit=struct('status','RUNNING','cases',0,'reusedCases',0,'drawError',0,'transitionError',0, ...
        'convergenceError',0,'geometryError',0,'featureError',0,'pcaError',0,'predictionError',0,'lossError',0, ...
        'r2Error',0,'movementError',0,'bootstrapError',0,'shuffleError',0,'observedRefits',0,'shuffleRefits',0,'matchedRefits',0);
    for n=1:10
        [m,c,d]=v2_definition(cfg,n); targets=repelem(1:8,30); xi=zeros(200,240,3); z=zeros(200,240);
        seeds=310000000+10000*n+100*targets+repmat(1:30,1,8); steps=[0 1250 2499];
        for j=1:240
            stream=RandStream('mt19937ar','Seed',seeds(j)); z(:,j)=randn(stream,200,1); draws=randn(stream,200,2500);
            xi(:,j,:)=reshape(draws(:,steps+1),200,1,3);
        end
        s=load(fullfile(cfg.raw,sprintf('null_n%02d.mat',n)),'qrProjectors'); projectors=s.qrProjectors;
        for v=1:5
            policies=[1 4]; if v==2, policies=1:4; end
            geometries=cell(1,4); cases=geometries;
            for p=policies
                s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_v%d_p%d.mat',n,v,p)),'result'); r=s.result; cases{p}=r;
                [prep,move,prior]=v2_load(cfg,n,v,p);
                assert(isequal(r.folds,stage3_prediction_folds(n,repelem((1:8).',30))));
                assert(prep.dt==.0002 && isequal(prep.seeds,seeds) && isequal(prep.flags,cfg.componentFlags(p,:)));
                assert(prep.sInit==cfg.pairs(v,1) && prep.sTemporal==cfg.pairs(v,2));
                audit.drawError=max(audit.drawError,max(abs(prep.initial-(m.spontaneous+cfg.pairs(v,1)*z)),[],'all'));
                assert(isequal(reshape(prep.states(1,:,:),200,240),prep.initial));
                fB=-d.xB+m.W*max(d.xB,0)+m.h; fs=-m.xstar+m.W*max(m.xstar,0)+m.h;
                for j=1:3
                    a=prep.audit(j); assert(a.step==steps(j));
                    increment=cfg.pairs(v,2)*sqrt(2*m.dt/m.tau)*xi(:,:,j);
                    u=-fB(:,targets)+cfg.componentFlags(p,1)*(fB(:,targets)-fs(:,targets))-cfg.componentFlags(p,2)*c.L*(a.x-m.xstar(:,targets));
                    next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h+u)+increment;
                    audit.drawError=max(audit.drawError,max(abs(increment-a.noiseIncrement),[],'all'));
                    audit.transitionError=max(audit.transitionError,max(abs(next-a.next),[],'all'));
                end
                assert(isequal(reshape(prep.states(end,:,:),200,240),prep.go) && isequal(reshape(move.states(1,:,:),200,240),prep.go));
                for a=move.audit
                    next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h+published_movement_input(a.step*m.dt,m));
                    audit.transitionError=max(audit.transitionError,max(abs(next-a.next),[],'all'));
                end
                audit.convergenceError=max(audit.convergenceError,v2_convergence_audit(prep.states,prep.initial,r.scale,r.convergence));
                rates=zeros(11,200,8);
                for q=1:8, rates(:,:,q)=sum(max(prep.states(401:10:501,:,(q-1)*30+(1:30)),0),3)/30; end
                g=paper95_direct(rates,r.scale); geometries{p}=g;
                assert(g.k==r.geometry.k); audit.geometryError=max([audit.geometryError abs(g.pr-r.geometry.pr) max(abs(g.cov-r.geometry.cov),[],'all')]);
                audit.movementError=max(audit.movementError,ns_movement_audit(move,m));
                for j=1:240
                    pos=reshape(move.hand(move.peakMs(j)+1,[1 3],j),1,2);
                    audit.movementError=max(audit.movementError,max(abs(pos-r.peakPosition(j,:))));
                end
                assert(abs(mean(move.peak)-r.peakMean)<1e-12);
                if ~isempty(prior)
                    assert(isequaln(r.prediction,prior.prediction)); audit.reusedCases=audit.reusedCases+1;
                elseif r.predictionEvaluable
                    a=ns_prediction_audit(r.prediction,prep.states,move,r.scale,n==1);
                    for name={'featureError','pcaError','predictionError','lossError','r2Error'}, audit.(name{1})=max(audit.(name{1}),a.(name{1})); end
                    audit.observedRefits=audit.observedRefits+1; audit.shuffleRefits=audit.shuffleRefits+(n==1);
                end
                if r.predictionEvaluable
                    audit.shuffleError=max(audit.shuffleError,ns_shuffle_audit(r.prediction,n));
                    assert(isequaln(summary.r2(n,v,p),r.prediction.fit.r2(1)));
                else
                    assert(isnan(summary.r2(n,v,p)));
                end
                assert(isequaln(summary.convergence(n,v,p),r.convergence.value) && isequaln(summary.pr(n,v,p),r.geometry.pr));
                assert(isequaln(summary.qc{n,v,p},r.qc)); audit.cases=audit.cases+1;
                clear prep move prior
            end
            control=geometries{1}; k=control.k; den=sum(control.eigenvalues(1:k));
            for p=policies
                B=geometries{p}.basis(:,1:k); ob=100*trace(B.'*control.cov*B)/den;
                ex=100*trace(control.cov*projectors{k})/den;
                audit.geometryError=max([audit.geometryError abs(ob-summary.observed(n,v,p)) abs(ex-summary.expected(n,v,p))]);
            end
            if v==2
                selected=calibration(calibration.network==n & calibration.gridIndex==selection.gridIndex,:);
                assert(height(selected)==1 && selected.kControl==k);
                audit.geometryError=max([audit.geometryError abs(summary.pr(n,v,1)-selected.prIntact) ...
                    abs(summary.pr(n,v,4)-selected.prBlock) abs(summary.observed(n,v,4)-selected.observedPct) ...
                    abs(summary.expected(n,v,4)-selected.expectedPct)]);
            end
            if cases{1}.predictionEvaluable && cases{4}.predictionEvaluable
                s=load(fullfile(cfg.raw,sprintf('matched_n%02d_v%d.mat',n,v)),'paired','kk');
                kk=min([cases{1}.prediction.pca{1}.k cases{1}.prediction.pca{2}.k;cases{4}.prediction.pca{1}.k cases{4}.prediction.pca{2}.k]);
                assert(isequal(s.kk,kk)); policiesPair=[1 4];
                for j=1:2
                    p=policiesPair(j); a=ns_fit_audit(cases{p}.prediction.pca{1}.scores(:,1:kk(1)),s.paired{j},1);
                    for name={'predictionError','lossError','r2Error'}, audit.(name{1})=max(audit.(name{1}),a.(name{1})); end
                    assert(s.paired{j}.r2(1)==summary.matched(n,v,p)); audit.matchedRefits=audit.matchedRefits+1;
                end
            end
            if v==2
                b=summary.behavior{n};
                for q=1:8
                    ids=(q-1)*30+(1:30); vi=cases{1}.movement.peak(ids).'; vb=cases{4}.movement.peak(ids).';
                    cost=abs(vi-vb.')./abs(vb.'); directI=[]; directB=[];
                    while true
                        [minimum,linear]=min(cost(:)); if ~isfinite(minimum)||minimum>.05, break; end
                        [i,j]=ind2sub([30 30],linear);
                        directI(end+1)=ids(i); directB(end+1)=ids(j); %#ok<AGROW>
                        cost(i,:)=Inf; cost(:,j)=Inf;
                    end
                    assert(isequal(directI,b.indices{q,1})&&isequal(directB,b.indices{q,2}));
                    ii=b.indices{q,1}; bb=b.indices{q,2}; assert(numel(unique(ii))==numel(ii) && numel(unique(bb))==numel(bb));
                    vi=cases{1}.movement.peak(ii); vb=cases{4}.movement.peak(bb); assert(all(abs(vi-vb)./abs(vb)<=.05));
                    for j=1:2
                        p=1+3*(j-1); ids=b.indices{q,j}; x=cases{p}.peakPosition(ids,:);
                        if numel(ids)>=5
                            value=sum(sqrt(sum((x-median(x,1)).^2,2)))/numel(ids);
                            audit.movementError=max(audit.movementError,abs(value-b.targetDispersion(q,j)));
                        end
                    end
                end
                assert(isequaln(b.network,summary.dispersion(n,:)));
            end
        end
        fprintf('Final-v2 independent audit network%d complete\n',n);
    end
    assert(isequaln(summary.deltaC,summary.convergence(:,:,4)-summary.convergence(:,:,1)));
    assert(isequaln(summary.deltaR2,summary.r2(:,:,4)-summary.r2(:,:,1)));
    ri=summary.r2(:,:,1); loss=-100*summary.deltaR2./ri; loss(~isfinite(ri)|ri<=eps(max(1,abs(ri))))=NaN;
    assert(isequaln(loss,summary.lossPct));
    for name=fieldnames(summary.bootstrap).'
        data=reshape(summary.(name{1}),10,[]); saved=summary.bootstrap.(name{1});
        for j=1:size(data,2)
            v=data(:,j); boot=median(reshape(v(summary.indices),size(summary.indices)),2);
            se=sqrt(sum((boot-sum(boot)/10000).^2)/9999);
            assert(isequal(isnan(se),isnan(saved.se(j))) && isequaln(median(v),saved.median(j)));
            if isfinite(se), audit.bootstrapError=max(audit.bootstrapError,abs(se-saved.se(j))); end
        end
    end
    assert(audit.cases==120 && audit.drawError<1e-12 && audit.transitionError<1e-10);
    assert(audit.convergenceError<1e-8 && audit.geometryError<1e-8 && audit.movementError<1e-10);
    assert(audit.featureError<1e-10 && audit.pcaError<1e-9 && audit.predictionError<1e-8 && audit.lossError<1e-6 && audit.r2Error<1e-10);
    assert(audit.bootstrapError<1e-10 && audit.shuffleError<1e-10); audit.status='PASS';
    audit.shuffleScope='All saved controls checked; independent shuffle1 refit for network1 in every genuinely new case; validated prior fits reused unchanged';
    paper_json(path,audit);
end
