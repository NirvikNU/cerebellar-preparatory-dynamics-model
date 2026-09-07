function result = stage3_consequences(cfg)
    % Movement starts only after the immutable geometry-only registry exists.
    assert(isfile(fullfile(cfg.manifestRoot,'MAP_COMPLETE.json')));
    output=fullfile(cfg.resultsRoot,'consequences.mat'); assert(~isfile(output));
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=s.registry;
    started=tic; result=struct('hasPrimary',~isempty(registry.primaryGridIndex),'primary',{{}},'additional',{{}},'sensitivity',{{}});
    result.movementTargetRollouts=160; result.preparationProtocols=10;
    map=readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv')); result.preparationProtocols=result.preparationProtocols+sum(map.tested);
    for member=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',member)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',member)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',member)));
        if result.hasPrimary
            def=registry.primary{member}; pre=s.preparations{1,def.gridIndex};
            primary=struct('definition',def,'block',pre,'intactGeometry',ref.geometry,'intactDistance',ref.prep.distance, ...
                'intactHand',ref.hand,'comparatorHand',ref.comparatorHand,'targetHand',m.targetHand);
            movement=simulate_published_cortex(m,pre.go,false);
            [~,primary.blockHand]=simulate_published_arm(m,movement.torque);
            primary.errorIntact=early_error(ref.hand,ref.comparatorHand,ref.comparatorMoMs);
            primary.errorBlock=early_error(primary.blockHand,ref.comparatorHand,ref.comparatorMoMs);
            primary.endpointErrorMM=1000*squeeze(vecnorm(primary.blockHand(end,[1 3],:)-ref.comparatorHand(end,[1 3],:),2,2)).';
            primary.finiteMovement=all(isfinite(primary.blockHand),'all');
            result.movementTargetRollouts=result.movementTargetRollouts+8;
            primary.mapRow=map(map.network==member & map.direction==1 & map.gridIndex==def.gridIndex,:);
            modes=[1 1;0 1;1 0;0 0]; primary.policies=cell(4,1);
            for policy=1:4
                p=stage3_prepare(m,def.xB,def.kappa,def.nu,modes(policy,:));
                g=stage3_geometry(p.rates(401:10:501,:,:),ref.scale);
                K=max(ref.geometry.k,g.k); denom=sum(ref.geometry.eigenvalues(1:K));
                observed=trace(g.basis(:,1:K).'*ref.geometry.covariance*g.basis(:,1:K))/denom;
                if isempty(s.nulls{K}), s.nulls{K}=stage2_null(ref.fullCov,ref.geometry.covariance,denom,K,cfg.nullDraws,cfg.nullSeedBase+member); end
                primary.policies{policy}=struct('mode',modes(policy,:),'stateError',p.distance(end),'pr',g.pr, ...
                    'observed',observed,'expected',mean(s.nulls{K}),'K',K,'go',p.go,'inputMax',p.inputMax);
                if policy==1
                    assert(max(abs(p.go-ref.prep.go),[],'all')<1e-10,'Explicit/reduced intact mismatch.');
                elseif policy==4
                    assert(max(abs(p.go-pre.go),[],'all')<1e-10,'Block cache/replay mismatch.');
                end
                result.preparationProtocols=result.preparationProtocols+1;
            end
            result.primary{member,1}=primary;
        end
        for k=1:numel(registry.additional)
            def=registry.additional{k}; if def.member~=member, continue; end
            pre=s.preparations{def.direction,def.gridIndex};
            if result.hasPrimary && def.direction==1 && def.gridIndex==registry.primaryGridIndex
                hand=result.primary{member}.blockHand;
            else
                movement=simulate_published_cortex(m,pre.go,false); [~,hand]=simulate_published_arm(m,movement.torque);
                result.movementTargetRollouts=result.movementTargetRollouts+8;
            end
            result.additional{end+1,1}=struct('network',member,'direction',def.direction,'gridIndex',def.gridIndex, ...
                'alpha',def.alpha,'betaNormalized',def.betaNormalized,'targetErrorsMM',early_error(hand,ref.comparatorHand,ref.comparatorMoMs), ...
                'finiteMovement',all(isfinite(hand),'all'),'endpointErrorMM',1000*squeeze(vecnorm(hand(end,[1 3],:)-ref.comparatorHand(end,[1 3],:),2,2)).');
        end
        assert(toc(started)<cfg.maxWallSeconds,'Consequence compute budget exceeded.');
    end
    if result.hasPrimary
        s=load(fullfile(cfg.ensembleRoot,'network_01.mat'),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,'reference_01.mat'),'ref'); ref=s.ref; def=registry.primary{1};
        fine=stage3_prepare(m,def.xB,def.kappa,def.nu,[0 0],cfg.stepCheckDt);
        coarse=result.primary{1}.block;
        result.stepCheck=struct('curveRelative',max(abs(fine.distance-coarse.distance))/max(1,max(coarse.distance)), ...
            'goRelative',norm(fine.go-coarse.go,'fro')/max(1,norm(coarse.go,'fro')));
        assert(result.stepCheck.curveRelative<=cfg.stepCurveRelativeTolerance && result.stepCheck.goRelative<=cfg.stepReleaseRelativeTolerance);
        result.preparationProtocols=result.preparationProtocols+1;
        for variant=1:4
            altered=def;
            if variant<=2
                delta=cfg.nonorthogonality(variant); altered.V=sqrt(1-delta^2)*def.V+delta*def.U;
                YB=(def.alpha*def.U*diag(sqrt(def.ell))+def.beta*altered.V)*def.Z;
                rates=ref.meanRate+ref.scale.*YB; altered.xB=rates;
                valid=all(rates>=0,'all'); label=sprintf('nonorthogonality_%g',delta);
            else
                factor=cfg.gainMarginFactors(variant-2);
                altered.kappa=max(0,norm(m.W,2)-1)+cfg.kappaMargin*factor;
                valid=true; label=sprintf('gain_margin_%g',factor);
            end
            sens=struct('label',label,'rateRealizable',valid,'status','infeasible negative rates');
            if valid
                ip=stage3_prepare(m,altered.xB,altered.kappa,altered.nu,[1 1]);
                bp=stage3_prepare(m,altered.xB,altered.kappa,altered.nu,[0 0]);
                ig=stage3_geometry(ip.rates(401:10:501,:,:),ref.scale);
                bg=stage3_geometry(bp.rates(401:10:501,:,:),ref.scale);
                im=simulate_published_cortex(m,ip.go,true); [~,ih]=simulate_published_arm(m,im.torque);
                full=zeros(102,m.n,8);
                for q=1:8
                    speed=hypot(ih(:,2,q),ih(:,4,q)); mo=find(speed>=.2*max(speed),1)-1;
                    joined=[ip.rates(1:500,:,q);im.rates(:,:,q)]; ix=501+mo+cfg.fullMO;
                    assert(min(ix)>=1 && max(ix)<=size(joined,1));
                    full(:,:,q)=[ip.rates(1:10:501,:,q);joined(ix,:)];
                end
                fg=stage3_geometry(full,ref.scale); K=max(ig.k,bg.k); den=sum(ig.eigenvalues(1:K));
                nv=stage2_null(fg.covariance,ig.covariance,den,K,cfg.nullDraws,cfg.nullSeedBase+1);
                sens.status='computed, not used for selection'; sens.prIntact=ig.pr; sens.prBlock=bg.pr;
                sens.observed=trace(bg.basis(:,1:K).'*ig.covariance*bg.basis(:,1:K))/den;
                sens.expected=mean(nv); sens.K=K; sens.stateError=bp.distance(end);
                sens.inputMax=max(ip.inputMax,bp.inputMax); sens.rateMax=max(ip.rateMax,bp.rateMax);
                sens.settle=bp.settle; sens.kappa=altered.kappa;
                result.preparationProtocols=result.preparationProtocols+2; result.movementTargetRollouts=result.movementTargetRollouts+8;
            end
            result.sensitivity{variant,1}=sens;
        end
        stream=RandStream('mt19937ar','Seed',cfg.bootstrapSeed);
        indices=randi(stream,10,cfg.bootstrapDraws,10); result.bootstrapIndices=indices;
        pr=zeros(10,2); ai=zeros(10,2); early=zeros(10,2);
        for n=1:10
            p=result.primary{n}; pr(n,:)=[p.intactGeometry.pr,p.block.geometry.pr];
            ai(n,:)=[p.mapRow.observed,p.mapRow.expected];
            early(n,:)=[mean(p.errorIntact),mean(p.errorBlock)];
        end
        result.metrics=struct('pr',pr,'alignmentObservedExpected',ai,'earlyErrorMM',early);
        result.statistics=stage3_statistics(pr,ai,early,indices);
    else
        result.unavailable='No common feasible direction-1 setting across all ten networks. Primary paired figures, component-removal and primary-scoped sensitivities are unavailable by predeclaration.';
        result.statistics=struct('status','No primary: no primary inferential tests performed.');
    end
    assert(result.movementTargetRollouts<=cfg.maxMovementTargetRollouts && result.preparationProtocols<=cfg.maxPreparationProtocols);
    result.elapsedSeconds=toc(started); result.selectionBeforeMovement=true;
    save(output,'result','cfg','-v7.3');
    stage3_write_json(fullfile(cfg.resultsRoot,'statistics.json'),result.statistics);
    if ~isempty(result.additional)
        writetable(struct2table(vertcat(result.additional{:})),fullfile(cfg.resultsRoot,'additional_solution_movements.csv'));
    end
end

function errors = early_error(hand, comparator, onset)
    errors=zeros(1,8);
    for q=1:8
        ix=onset(q)+(0:200)+1; assert(max(ix)<=size(hand,1));
        delta=hand(ix,[1 3],q)-comparator(ix,[1 3],q);
        errors(q)=1000*sqrt(mean(sum(delta.^2,2)));
    end
end
