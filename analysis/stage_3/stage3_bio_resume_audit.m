function audit = stage3_bio_resume_audit
    % Independent saved-output audit; no trajectory integration or reselection.
    cfg=stage3_bio_paths; destination=fullfile(cfg.bioRoot,'independent_audit.json'); assert(~isfile(destination));
    s=load(fullfile(cfg.bioRoot,'population.mat'),'result'); pop=s.result;
    s=load(fullfile(cfg.bioRoot,'movement.mat'),'result'); move=s.result;
    s=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); cs=s.controllers;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); reg=s.registry;
    map=readtable(fullfile(cfg.bioRoot,'feasibility_map.csv'));
    bounds=readtable(fullfile(cfg.bioRoot,'preparation_bounds.csv'));
    audit=struct('status','PASS','checks',0,'maxAbsoluteError',0,'nativeTransitions',0, ...
        'networkCount',10,'policyCount',4,'newSimulations',0,'settlingPassFail','Retired, not tested');
    sentinel=reshape(1:11*200*8,11,200,8);
    flat=reshape(permute(sentinel,[1 3 2]),88,200);
    for neuron=1:200
        for q=1:8, compare(flat((q-1)*11+(1:11),neuron),sentinel(:,neuron,q)); end
    end
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        d=reg.primary{n}; c=cs{n};
        s=load(fullfile(cfg.cacheRoot,'gain_time','refined',sprintf('baseline_n%02d.mat',n)),'baseline'); base=s.baseline;
        nullPath=fullfile(cfg.bioCache,sprintf('null_n%02d.mat',n));
        if isfile(nullPath), s=load(nullPath,'nulls'); nulls=s.nulls;
        else, s=load(fullfile(cfg.cacheRoot,'gain_time',sprintf('null_n%02d.mat',n)),'nullEvidence'); nulls=s.nullEvidence; end
        compare(nulls.fullCov,ref.fullCov); compare(d.scale,ref.scale);
        f=@(x)-x+m.W*max(x,0)+m.h;
        compare(f(m.xstar)-c.fB-c.kappa0*(m.xstar-d.xB)+c.b,zeros(200,8));
        compare(f(d.xB)-c.fB,zeros(200,8));
        compare(c.L,c.P/.1); assert(c.eulerRadius<1 && c.intactWorstPole<0);
        prep=cell(4,1); independentRefs=cell(61,1);
        for policy=1:4
            p=stage3_bio_load(cfg,n,policy); prep{policy}=p;
            flags=cfg.policyFlags(policy,:);
            X=reshape(p.nativeStates(:,:,1:2500),200,[]);
            next=reshape(p.nativeStates(:,:,2:2501),200,[]);
            center=(1-flags(1))*d.xB+flags(1)*m.xstar;
            constant=(1-flags(1))*f(d.xB)+flags(1)*f(m.xstar);
            derivative=f(X)-repmat(constant,1,2500)-c.kappa0*(X-repmat(center,1,2500)) ...
                -flags(2)*c.L*(X-repmat(m.xstar,1,2500));
            compare(next-X,m.dt/m.tau*derivative); audit.nativeTransitions=audit.nativeTransitions+2500*8;
            compare(p.go,p.nativeStates(:,:,end)); compare(p.rates,max(p.states,0));
            compare(p.states,permute(p.nativeStates(:,:,1:5:end),[3 1 2]));
            compare(squeeze(p.states(1,:,:)),repmat(m.spontaneous,1,8));
            whole=reshape(p.nativeStates,200,[]); star=repmat(m.xstar,1,2501); block=repmat(d.xB,1,2501);
            u0=-repmat(f(d.xB),1,2501)-c.kappa0*(whole-block);
            b=flags(1)*repmat(c.b,1,2501); fb=-flags(2)*c.L*(whole-star);
            pieces={u0,b,fb,b+fb,u0+b+fb};
            for part=1:5
                norms=reshape(sqrt(sum(pieces{part}.^2,1)),8,2501);
                compare(p.nativeComponentMax(part),max(norms,[],'all'));
                compare(p.componentNorms(:,:,part),norms(:,1:5:end).');
            end
            compare(p.nativeRateMax,max(max(whole,0),[],'all'));
            compare(p.nativeStateNormMax,max(sqrt(sum(whole.^2,1))));
            for q=1:8
                x=squeeze(p.states(:,:,q)).'; delta=x-m.xstar(:,q);
                errors=sqrt(sum(delta.^2,1)).';
                eq=zeros(501,1);
                for t=1:501, eq(t)=delta(:,t).'*c.Q*delta(:,t); end
                compare(p.distanceStar(:,q),errors);
                compare(p.distanceBlock(:,q),sqrt(sum((x-d.xB(:,q)).^2,1)).');
                compare(p.prospectiveError(:,q),eq); compare(p.normalizedProspective(:,q),eq/eq(1));
                compare(p.relativeSettle(q),norm(p.go(:,q)-d.xB(:,q))/max(1,norm(d.xB(:,q)-m.spontaneous)));
                curves=[eq/eq(1),errors/errors(1)]; crossing=nan(1,4);
                for metric=1:2
                    cut=[.5 .1];
                    for lev=1:2
                        k=find(curves(:,metric)<=cut(lev),1);
                        if ~isempty(k), crossing((metric-1)*2+lev)=k-1; end
                    end
                end
                compare(p.crossingMs(q,:),crossing);
            end
            rates=cat(1,repmat(max(base.states(1:200,:),0),1,1,8),p.rates);
            for t=1:61
                ix=701+pop.endpointGO(t)+(-100:10:0);
                if t<=11
                    assert(all(rates(ix,:,:)==rates(ix,:,1),'all'));
                    assert(isnan(pop.pr(n,policy,t)) && isnan(pop.deficit(n,policy,t))); continue;
                end
                g=stage3_recovery_geometry(rates(ix,:,:),ref.scale);
                if policy==1, independentRefs{t}=g; end
                ig=independentRefs{t}; K=max(ig.k,g.k); den=sum(ig.eigenvalues(1:K));
                obs=sum((ig.matrix*g.basis(:,1:K)).^2,'all')/((size(ig.matrix,1)-1)*den);
                expected=trace(ig.covariance*nulls.qrProjectors{K})/den;
                compare(pop.pr(n,policy,t),g.pr); compare(pop.K(n,policy,t),K);
                compare(pop.observed(n,policy,t),obs); compare(pop.expected(n,policy,t),expected);
                compare(pop.deficit(n,policy,t),expected-obs);
                compare(pop.referenceCapture(n,policy,t),sum(ig.eigenvalues(1:K))/sum(ig.eigenvalues));
                compare(pop.policyCapture(n,policy,t),sum(g.eigenvalues(1:K))/sum(g.eigenvalues));
            end
        end
        limit=5*max(1,prep{1}.nativeComponentMax(5)); bRows=bounds(bounds.network==n,:);
        compare(bRows.inputLimit,repmat(limit,4,1));
        assert(all(bRows.boundsPass) && all(bRows.rateMax<=ref.rateLimit) && all(bRows.stateMax<=ref.stateLimit));
        K=pop.K(n,4,end); ig=independentRefs{61};
        nv=stage3_recovery_null(ref.fullCov,ig.covariance,sum(ig.eigenvalues(1:K)),K,cfg.nullDraws,cfg.nullSeedBase+n);
        compare(pop.nullValues{n},nv);
        % Movement: independent saved rates/readout, arm kinematics and error.
        for condition=1:2
            policy=1; if condition==2, policy=4; end
            s=load(fullfile(cfg.bioCache,sprintf('movement_n%02d_p%d.mat',n,policy)),'evidence'); e=s.evidence;
            compare(e.initialState,prep{policy}.go);
            compare(squeeze(e.movement.rates(1,:,:)),max(e.initialState,0));
            for q=1:8
                compare(e.movement.torque(:,:,q),(m.C*e.movement.rates(:,:,q).').');
                theta=e.theta(:,:,q); a=theta(:,1); da=theta(:,2); b=theta(:,3); db=theta(:,4);
                hand=[m.arm.L1*cos(a)+m.arm.L2*cos(a+b), ...
                    -m.arm.L1*da.*sin(a)-m.arm.L2*(da+db).*sin(a+b), ...
                    m.arm.L1*sin(a)+m.arm.L2*sin(a+b), ...
                    m.arm.L1*da.*cos(a)+m.arm.L2*(da+db).*cos(a+b)];
                compare(hand,e.hand(:,:,q));
                ix=ref.comparatorMoMs(q)+(0:200)+1;
                dx=hand(ix,1)-ref.comparatorHand(ix,1,q); dy=hand(ix,3)-ref.comparatorHand(ix,3,q);
                mm=1000*sqrt(sum(dx.^2+dy.^2)/201);
                compare(move.primary{n}.targetErrorMM(q,condition),mm);
            end
            compare(move.earlyErrorMM(n,condition),mean(move.primary{n}.targetErrorMM(:,condition)));
        end
        % Every map cell gets an independent covariance/classification audit.
        s=load(fullfile(cfg.bioCache,sprintf('map_null_n%02d.mat',n)),'nulls'); mapNull=s.nulls;
        for direction=1:3
            s=load(fullfile(cfg.bioCache,sprintf('grid_n%02d_d%d.mat',n,direction)),'batch','selectedSaved');
            rows=find(map.network==n & map.direction==direction);
            for row=rows.'
                tested=map.rateRealizable(row) && map.modulationOK(row) && map.endpointBoundsOK(row);
                assert(logical(map.tested(row))==tested);
                if ~tested, continue; end
                j=map.gridIndex(row);
                if direction==1 && j==5
                    rates=prep{4}.rates(401:10:501,:,:);
                else
                    k=find(s.selectedSaved==j); rates=s.batch.lateRates(:,:,(k-1)*8+(1:8));
                    compare(map.rateMax(row),max(s.batch.nativeRateMax(:,k)));
                    compare(map.stateMax(row),max(s.batch.nativeStateMax(:,k)));
                    imax=reshape(max(s.batch.nativeInputMax(:,k,:),[],1),1,5);
                    compare(map{row,{'corticalMax','sustainedMax','feedbackMax','cbMax','totalMax'}},imax);
                end
                g=stage3_recovery_geometry(rates,ref.scale); K=max(ig.k,g.k); den=sum(ig.eigenvalues(1:K));
                observed=sum((ig.matrix*g.basis(:,1:K)).^2,'all')/(87*den);
                expected=mean(mapNull{K});
                compare(map.prBlock(row),g.pr); compare(map.observed(row),observed); compare(map.expected(row),expected);
                physical=map.rateMax(row)<=ref.rateLimit && map.stateMax(row)<=ref.stateLimit ...
                    && max(map{row,{'corticalMax','sustainedMax','feedbackMax','cbMax','totalMax'}})<=limit ...
                    && map.localMaxReal(row)<0 && map.localEulerRadius(row)<1;
                phenotype=g.pr>ig.pr+cfg.prMargin && expected-observed>cfg.nullHoeffdingRadius+cfg.alignmentMargin;
                assert(logical(map.physical(row))==physical && logical(map.finitePhenotype(row))==phenotype);
                assert(logical(map.feasible(row))==(physical && phenotype && map.analytical(row)));
            end
        end
        fprintf('Independent saved-output audit network %02d complete\n',n);
    end
    % Independent network-bootstrap SE, exact enumeration, and BH family.
    names=fieldnames(pop.summary);
    for j=1:numel(names)
        values=reshape(pop.(names{j}),10,[]); independentBootstrap(values,pop.summary.(names{j}));
    end
    pr=pop.primaryTable{:,{'prIntact','prBlock'}}; ai=pop.primaryTable{:,{'observed','expected'}};
    independentBootstrap(pr,move.statistics.pr); independentBootstrap(ai,move.statistics.alignment);
    independentBootstrap(move.earlyErrorMM,move.statistics.earlyErrorMM);
    diffs={pr(:,2)-pr(:,1),ai(:,1)-ai(:,2),move.earlyErrorMM(:,2)-move.earlyErrorMM(:,1)};
    tests={'prTest','alignmentTest','earlyTest'}; pvalues=zeros(1,3);
    for metric=1:3
        v=diffs{metric}; distribution=zeros(1024,1);
        for b=0:1023
            signs=2*(dec2bin(b,10)-'0')-1; distribution(b+1)=abs(sum(signs(:).*v)/10);
        end
        pvalues(metric)=sum(distribution>=abs(mean(v))-1e-12*max(1,abs(mean(v))))/1024;
        compare(move.statistics.(tests{metric}).p,pvalues(metric));
        independentBootstrap(v,struct('median',move.statistics.(tests{metric}).medianDifference, ...
            'se',move.statistics.(tests{metric}).medianDifferenceSE));
    end
    [ordered,ix]=sort(pvalues(1:2)); adjusted=[min(1,min(2*ordered(1),ordered(2))),min(1,ordered(2))];
    qs=zeros(1,2); qs(ix)=adjusted; compare(move.statistics.geometryQ,qs);
    audit.primaryPhenotype=pop.primaryPass; audit.mapPrimary=true; audit.movementConsequence=move.nontrivialMovement;
    stage3_write_json(destination,audit);

    function independentBootstrap(values,summary)
        values=reshape(values,10,[]); draws=zeros(10000,size(values,2));
        for bootstrapColumn=1:size(values,2)
            v=values(:,bootstrapColumn); sampled=reshape(v(pop.bootstrapIndices),10000,10);
            ordered=sort(sampled,2); draws(:,bootstrapColumn)=(ordered(:,5)+ordered(:,6))/2;
        end
        average=sum(draws,1)/10000;
        se=sqrt(sum((draws-average).^2,1)/9999);
        compare(summary.median,median(values,1)); compare(summary.se,se);
    end

    function compare(actual,expected)
        assert(isequal(size(actual),size(expected)) && isequal(isnan(actual),isnan(expected)));
        valid=~isnan(actual); delta=max(abs(actual(valid)-expected(valid)));
        if isempty(delta), delta=0; end
        tol=1e-9+1e-10*max(abs(expected(valid)));
        if isempty(tol), tol=1e-9; end
        assert(isfinite(delta) && delta<=tol,'BioResume:Audit','Mismatch %.17g > %.17g',delta,tol);
        audit.checks=audit.checks+1; audit.maxAbsoluteError=max(audit.maxAbsoluteError,delta);
    end
end
