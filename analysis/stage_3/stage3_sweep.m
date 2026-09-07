function map = stage3_sweep(cfg)
    % Bounded geometry-only scan. No block movement is called here.
    assert(isfile(fullfile(cfg.manifestRoot,'REFERENCE_FROZEN.json')));
    assert(~isfile(fullfile(cfg.resultsRoot,'feasibility_map.csv')),'Map already exists.');
    started=tic; rows=cell(1080,1); rowIndex=0;
    for member=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',member)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',member)),'ref'); ref=s.ref;
        nulls=cell(200,1); definitions=cell(3,36); preparations=cell(3,36);
        for direction=1:3
            stream=RandStream('mt19937ar','Seed',cfg.directionSeedBase+100*member+direction);
            G=randn(stream,m.n,ref.d).*(ref.meanRate./ref.scale);
            G(ref.meanRate==0,:)=0; G=G-ref.U*(ref.U.'*G);
            [V,R]=qr(G,0); V=V*diag(sign(diag(R)));
            assert(min(abs(diag(R)))>1e-10 && norm(V.'*V-eye(ref.d),'fro')<1e-10);
            assert(norm(ref.U.'*V,'fro')<1e-10);
            candidates=cell(36,1); localRows=cell(36,1); pass=[];
            for ia=1:6
                for ib=1:6
                    j=(ia-1)*6+ib; alpha=cfg.alpha(ia); bn=cfg.betaNormalized(ib);
                    beta=bn*sqrt(ref.T/ref.d); rho=(beta/alpha)^2;
                    YB=(alpha*ref.U*diag(sqrt(ref.ell))+beta*V)*ref.Z;
                    rates=ref.meanRate+ref.scale.*YB;
                    xB=rates; zmask=rates==0; internal=repmat(min(mean(m.xstar,2),0),1,8);
                    xB(zmask)=internal(zmask);
                    f=@(x)-x+m.W*max(x,0)+m.h;
                    fB=f(xB); b=fB-f(m.xstar)+ref.kappa*(m.xstar-xB);
                    rawTrace=sum((rates-ref.meanRate).^2,'all')/7;
                    normRatio=sum(YB.^2,'all')/(7*ref.T); rawRatio=rawTrace/ref.rawTrace;
                    inputMax=zeros(1,5);
                    for state={repmat(m.spontaneous,1,8),xB,m.xstar}
                        x=state{1}; ci=-fB-ref.kappa*(x-xB); fb=-ref.nu*(x-m.xstar);
                        pieces={ci,b,fb,b+fb,ci+b+fb};
                        for k=1:5, inputMax(k)=max(inputMax(k),max(vecnorm(pieces{k}))); end
                    end
                    r=struct('network',member,'direction',direction,'gridIndex',j,'alphaIndex',ia,'betaIndex',ib, ...
                        'alpha',alpha,'betaNormalized',bn,'beta',beta,'rho',rho,'rank',ref.d, ...
                        'normalizedVarianceRatio',normRatio,'rawVarianceRatio',rawRatio, ...
                        'minimumRate',min(rates,[],'all'),'endpointRateMax',max(rates,[],'all'), ...
                        'endpointStateMax',max(vecnorm(xB)),'endpointInputMax',max(inputMax), ...
                        'analytical',rho>ref.rhoBound,'rhoMargin',rho-ref.rhoBound, ...
                        'rateRealizable',all(rates>=0,'all'), ...
                        'modulationOK',min([rawRatio normRatio])>=cfg.modulationEnvelope(1) && max([rawRatio normRatio])<=cfg.modulationEnvelope(2), ...
                        'endpointBoundsOK',max(rates,[],'all')<=ref.rateLimit && max(vecnorm(xB))<=ref.stateLimit && max(inputMax)<=ref.inputLimit, ...
                        'tested',false,'physical',false,'finitePhenotype',false,'feasible',false, ...
                        'settle',NaN,'rateMax',NaN,'stateMax',NaN,'corticalMax',NaN,'sustainedMax',NaN,'feedbackMax',NaN,'cbMax',NaN,'totalMax',NaN, ...
                        'prIntact',ref.geometry.pr,'prBlock',NaN,'analyticPRBlock',(ref.T+ref.d*rho)^2/(ref.S+2*rho*ref.T+ref.d*rho^2), ...
                        'analyticAI',sum(ref.ell.^2./(ref.ell+rho))/ref.T, ...
                        'kIntact',ref.geometry.k,'kBlock',NaN,'commonK',NaN,'intactCapture',NaN,'blockCapture',NaN,'blockGap',NaN, ...
                        'observed',NaN,'expected',NaN,'nullSE',NaN,'nullHalfDifference',NaN,'alignmentMargin',NaN, ...
                        'equilibriumResidual',norm(f(xB)-fB,'fro'),'localMaxReal',NaN,'localEulerRadius',NaN,'reason',"");
                    candidates{j}=struct('member',member,'direction',direction,'gridIndex',j,'alpha',alpha,'betaNormalized',bn, ...
                        'beta',beta,'xB',xB,'U',ref.U,'V',V,'Z',ref.Z,'scale',ref.scale,'ell',ref.ell, ...
                        'kappa',ref.kappa,'nu',ref.nu,'b',b,'corticalConstant',-fB+ref.kappa*xB);
                    % Direct settled covariance/AI proof for every candidate, before dynamics.
                    C=YB*YB.'/7; directPR=trace(C)^2/sum(C.^2,'all');
                    [D,~,~]=svd(YB,'econ'); B=D(:,1:ref.d);
                    directAI=sum((ref.Y.'*B).^2,'all')/(7*ref.T);
                    assert(abs(directPR-r.analyticPRBlock)<1e-9 && abs(directAI-r.analyticAI)<1e-9);
                    if ~r.rateRealizable, r.reason=r.reason+"negative_rate;"; end
                    if ~r.modulationOK, r.reason=r.reason+"modulation_envelope;"; end
                    if ~r.endpointBoundsOK, r.reason=r.reason+"endpoint_bounds;"; end
                    if r.rateRealizable && r.modulationOK && r.endpointBoundsOK, pass(end+1)=j; end %#ok<AGROW>
                    localRows{j}=r;
                end
            end
            if ~isempty(pass)
                batch=cellfun(@(c)c.xB,candidates(pass),'UniformOutput',false);
                prep=stage3_prepare(m,cat(2,batch{:}),ref.kappa,ref.nu,[0 0],cfg.dt,ref.prep.nativeStates);
                for k=1:numel(pass)
                    j=pass(k); r=localRows{j}; ix=(k-1)*8+(1:8); r.tested=true;
                    g=stage3_geometry(prep.rates(401:10:501,:,ix),ref.scale);
                    K=max(ref.geometry.k,g.k); denom=sum(ref.geometry.eigenvalues(1:K));
                    observed=trace(g.basis(:,1:K).'*ref.geometry.covariance*g.basis(:,1:K))/denom;
                    projected=sum((ref.geometry.matrix*g.basis(:,1:K)).^2,'all')/((size(ref.geometry.matrix,1)-1)*denom);
                    assert(abs(observed-projected)<1e-10);
                    if isempty(nulls{K})
                        nulls{K}=stage2_null(ref.fullCov,ref.geometry.covariance,denom,K,cfg.nullDraws,cfg.nullSeedBase+member);
                    end
                    nv=nulls{K}; r.prBlock=g.pr; r.kBlock=g.k; r.commonK=K;
                    r.intactCapture=sum(ref.geometry.eigenvalues(1:K))/sum(ref.geometry.eigenvalues);
                    r.blockCapture=sum(g.eigenvalues(1:K))/sum(g.eigenvalues); r.blockGap=g.gap;
                    r.observed=observed; r.expected=mean(nv); r.nullSE=std(nv)/sqrt(numel(nv));
                    r.nullHalfDifference=mean(nv(1:5000))-mean(nv(5001:end));
                    r.alignmentMargin=r.expected-cfg.nullHoeffdingRadius-cfg.alignmentMargin-observed;
                    r.settle=prep.settle(k); r.rateMax=prep.rateMax(k); r.stateMax=prep.statesNormMax(k);
                    imax=max(prep.inputMax(k,:),prep.intactInputMax(k,:));
                    r.corticalMax=imax(1); r.sustainedMax=imax(2); r.feedbackMax=imax(3); r.cbMax=imax(4); r.totalMax=imax(5);
                    r.localMaxReal=-Inf; r.localEulerRadius=0;
                    for q=1:8
                        J=(-(1+ref.kappa)*eye(m.n)+m.W.*(candidates{j}.xB(:,q)>0).')/m.tau;
                        ev=eig(J); r.localMaxReal=max(r.localMaxReal,max(real(ev)));
                        r.localEulerRadius=max(r.localEulerRadius,max(abs(1+cfg.dt*ev)));
                    end
                    r.physical=r.rateMax<=ref.rateLimit && r.stateMax<=ref.stateLimit && max(imax)<=ref.inputLimit && r.settle<=cfg.settleRelativeTolerance && r.localMaxReal<0 && r.localEulerRadius<1;
                    r.finitePhenotype=g.pr>ref.geometry.pr+cfg.prMargin && r.alignmentMargin>0;
                    r.feasible=r.analytical && r.physical && r.finitePhenotype;
                    if ~r.physical, r.reason=r.reason+"dynamic_bounds_or_settling;"; end
                    if ~r.finitePhenotype, r.reason=r.reason+"finite_geometry;"; end
                    if ~r.analytical, r.reason=r.reason+"outside_sufficient_bound;"; end
                    if r.feasible, r.reason="certified_feasible"; end
                    localRows{j}=r;
                    preparations{direction,j}=struct('go',prep.go(:,ix),'distance',prep.distance(:,k),'lateRates',prep.rates(401:10:501,:,ix), ...
                        'geometry',g,'inputMax',imax,'rateMax',r.rateMax,'stateMax',r.stateMax,'settle',r.settle);
                end
            end
            for j=1:36, rowIndex=rowIndex+1; rows{rowIndex}=localRows{j}; definitions{direction,j}=candidates{j}; end
            fprintf('Map network %02d direction %d: %d/36 nonlinear protocols\n',member,direction,numel(pass));
            assert(toc(started)<cfg.maxWallSeconds,'Sweep compute budget exceeded.');
        end
        save(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',member)),'definitions','preparations','nulls','-v7.3');
    end
    map=struct2table(vertcat(rows{:})); assert(height(map)==cfg.maxGridProtocols);
    writetable(map,fullfile(cfg.resultsRoot,'feasibility_map.csv'));
    registry=select_solutions(map,cfg);
    save(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry','cfg','-v7.3');
    stage3_registry_receipt(cfg,registry);
    stage3_write_json(fullfile(cfg.manifestRoot,'MAP_COMPLETE.json'),struct('completedUTC',char(datetime('now','TimeZone','UTC')), ...
        'rows',height(map),'tested',sum(map.tested),'feasible',sum(map.feasible),'primaryGridIndex',registry.primaryGridIndex, ...
        'selectionBeforeBlockMovement',true,'elapsedSeconds',toc(started)));
end

function registry = select_solutions(map,cfg)
    common=[];
    for j=1:36
        if sum(map.feasible & map.direction==1 & map.gridIndex==j)==10, common(end+1)=j; end %#ok<AGROW>
    end
    base=map(map.network==1 & map.direction==1,:);
    key=[abs(log(base.alpha.^2+base.betaNormalized.^2)),-base.alpha,base.betaNormalized];
    [~,order]=sortrows(key,[1 2 3]);
    eligible=order(ismember(order,common));
    registry.primaryGridIndex=[]; registry.primary=cell(0,1); registry.additional=cell(0,1);
    if ~isempty(eligible), registry.primaryGridIndex=eligible(1); end
    for member=1:10
        s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',member)),'definitions');
        if ~isempty(registry.primaryGridIndex), registry.primary{member,1}=s.definitions{1,registry.primaryGridIndex}; end
        prior=zeros(0,2);
        for direction=1:3
            available=map.gridIndex(map.network==member & map.direction==direction & map.feasible);
            if isempty(available), continue; end
            candidates=order(ismember(order,available));
            if ~isempty(prior)
                distance=zeros(numel(candidates),1);
                for k=1:numel(candidates)
                    point=[base.alpha(candidates(k)),base.betaNormalized(candidates(k))];
                    distance(k)=min(vecnorm((point-prior)./[range(cfg.alpha),range(cfg.betaNormalized)],2,2));
                end
                candidates=candidates(distance==max(distance));
            end
            selected=candidates(1); prior(end+1,:)=[base.alpha(selected),base.betaNormalized(selected)]; %#ok<AGROW>
            registry.additional{end+1,1}=s.definitions{direction,selected};
        end
    end
    registry.frozenUTC=char(datetime('now','TimeZone','UTC'));
    registry.rule=cfg.primaryRule; registry.additionalRule=cfg.sampleRule;
    registry.movementInspected=false;
end
