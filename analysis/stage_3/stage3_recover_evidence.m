function report = stage3_recover_evidence(cfg,action)
    % Only the frozen missing-evidence whitelist may trigger integration.
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); old=s.result;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=s.registry;
    out=fullfile(cfg.cacheRoot,'evidence_recovery');
    planFile=fullfile(cfg.manifestRoot,'RECOVERY_CASES.mat');
    checksFile=fullfile(cfg.manifestRoot,'RECOVERY_COMPARISONS.json');
    report=struct('task','STAGE3-EVIDENCE-RECOVERY-01','status','IN PROGRESS', ...
        'absoluteTolerance',1e-9,'relativeTolerance',1e-10,'checks',{{}},'completedCases',{{}});
    if strcmp(action,'enumerate')
        assert(~isfile(planFile),'Recovery case list already frozen.');
        plan=struct('movement',{{}},'policies',{{}},'sensitivity',{{}},'fine',struct());
        for j=1:numel(registry.additional)
            d=registry.additional{j}; p=registry.primary{d.member};
            if d.direction==p.direction && d.gridIndex==p.gridIndex, continue; end
            assert(isequal(d.xB,registry.additional{j}.xB));
            match=find(cellfun(@(a)a.network==d.member && a.direction==d.direction && a.gridIndex==d.gridIndex,old.additional));
            assert(isscalar(match));
            plan.movement{end+1}=struct('definition',d,'originalIndex',match, ...
                'id',sprintf('movement_n%02d_d%d_g%02d',d.member,d.direction,d.gridIndex));
        end
        assert(numel(plan.movement)==20);
        ids=cellfun(@(a)a.id,plan.movement,'UniformOutput',false); assert(numel(unique(ids))==20);
        for n=1:10
            for policy=2:3
                plan.policies{end+1}=struct('definition',registry.primary{n},'policy',policy, ...
                    'mode',old.primary{n}.policies{policy}.mode,'id',sprintf('policy_n%02d_p%d',n,policy));
            end
        end
        d=registry.primary{1}; s=load(fullfile(cfg.ensembleRoot,'network_01.mat'),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,'reference_01.mat'),'ref'); ref=s.ref;
        for variant=1:4
            altered=d;
            if variant<=2
                delta=cfg.nonorthogonality(variant); altered.V=sqrt(1-delta^2)*d.V+delta*d.U;
                YB=(d.alpha*d.U*diag(sqrt(d.ell))+d.beta*altered.V)*d.Z;
                altered.xB=ref.meanRate+ref.scale.*YB;
            else
                altered.kappa=max(0,norm(m.W,2)-1)+cfg.kappaMargin*cfg.gainMarginFactors(variant-2);
            end
            assert(all(altered.xB>=0,'all') && old.sensitivity{variant}.rateRealizable);
            plan.sensitivity{variant}=struct('definition',altered,'variant',variant,'label',old.sensitivity{variant}.label, ...
                'id',sprintf('sensitivity_%d',variant),'nullSeed',cfg.nullSeedBase+1);
        end
        plan.fine=struct('definition',d,'id','fine_n01_d1_g05','dt',cfg.stepCheckDt);
        plan.config=cfg; plan.originalConsequencesSHA256=sha256_file(fullfile(cfg.resultsRoot,'consequences.mat'));
        plan.registrySHA256=sha256_file(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'));
        plan.tolerances=rmfield(report,{'checks','completedCases'});
        save(planFile,'plan');
        compact=plan;
        for name={'movement','policies','sensitivity'}
            for j=1:numel(compact.(name{1}))
                a=compact.(name{1}){j}; d=a.definition;
                a.definition=rmfield(d,{'xB','U','V','Z','scale','ell','b','corticalConstant'});
                compact.(name{1}){j}=a;
            end
        end
        compact.fine.definition=compact.sensitivity{1}.definition;
        compact.fine.definition.kappa=plan.fine.definition.kappa;
        stage3_write_json(fullfile(cfg.manifestRoot,'RECOVERY_CASES.json'),compact);
        report=compact; disp(compact); return;
    end
    assert(strcmp(action,'recover') && isfile(planFile));
    s=load(planFile,'plan'); plan=s.plan;
    assert(isequaln(plan.config,cfg),'Configuration changed after enumeration.');
    assert(strcmp(plan.originalConsequencesSHA256,sha256_file(fullfile(cfg.resultsRoot,'consequences.mat'))));
    assert(strcmp(plan.registrySHA256,sha256_file(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'))));
    assert(~isfolder(out) && ~isfile(checksFile),'Refuse repeat integration or overwrite.');
    mkdir(out); started=tic;
    try
        for j=1:numel(plan.movement)
            a=plan.movement{j}; d=a.definition; [m,ref,grid]=inputs(d.member);
            pre=grid.preparations{d.direction,d.gridIndex}; assert(isequaln(d,grid.definitions{d.direction,d.gridIndex}));
            raw=struct('identity',a,'initialState',pre.go,'dt',m.dt,'savedDt',m.samplingDt);
            raw.movement=simulate_published_cortex(m,pre.go,true);
            [raw.theta,raw.hand]=simulate_published_arm(m,raw.movement.torque);
            raw.comparatorMoMs=ref.comparatorMoMs;
            saveRaw(a.id,raw);
            [rms,endpoint]=movementError(raw.hand,ref.comparatorHand,ref.comparatorMoMs);
            compare([a.id ': RMS mm'],rms,old.additional{a.originalIndex}.targetErrorsMM);
            compare([a.id ': endpoint mm'],endpoint,old.additional{a.originalIndex}.endpointErrorMM);
            compare([a.id ': finite'],all(isfinite(raw.hand),'all'),old.additional{a.originalIndex}.finiteMovement);
            complete(a.id);
        end
        for j=1:numel(plan.policies)
            a=plan.policies{j}; d=a.definition; [m,ref,grid]=inputs(d.member);
            assert(ismember(a.policy,[2 3]) && isequal(a.mode,old.primary{d.member}.policies{a.policy}.mode));
            raw=struct('identity',a,'initialState',repmat(m.spontaneous,1,8));
            raw.prep=stage3_recovery_prepare(m,d.xB,d.kappa,d.nu,a.mode,cfg.dt);
            raw.geometry=stage3_geometry(raw.prep.rates(401:10:501,:,:),ref.scale);
            raw.K=max(ref.geometry.k,raw.geometry.k); den=sum(ref.geometry.eigenvalues(1:raw.K));
            raw.null=grid.nulls{raw.K};
            if isempty(raw.null), raw.null=stage2_null(ref.fullCov,ref.geometry.covariance,den,raw.K,cfg.nullDraws,cfg.nullSeedBase+d.member); end
            raw.nullSeed=cfg.nullSeedBase+d.member; saveRaw(a.id,raw);
            g=stage3_recovery_geometry(raw.prep.rates(401:10:501,:,:),ref.scale);
            saved=old.primary{d.member}.policies{a.policy};
            compare([a.id ': PR'],g.pr,saved.pr); compare([a.id ': K'],max(g.k,ref.geometry.k),saved.K);
            obs=sum((ref.geometry.matrix*g.basis(:,1:raw.K)).^2,'all')/((size(ref.geometry.matrix,1)-1)*den);
            compare([a.id ': alignment'],obs,saved.observed);
            compare([a.id ': expected'],mean(raw.null),saved.expected);
            independentNull=stage3_recovery_null(ref.fullCov,ref.geometry.covariance,den,raw.K,cfg.nullDraws,raw.nullSeed);
            compare([a.id ': independent null'],independentNull,raw.null);
            compare([a.id ': state error'],mean(sqrt(sum((raw.prep.go-m.xstar).^2,1))),saved.stateError);
            compare([a.id ': GO'],raw.prep.go,saved.go); compare([a.id ': inputs'],raw.prep.inputMax,saved.inputMax);
            complete(a.id);
        end
        for j=1:4
            a=plan.sensitivity{j}; d=a.definition; [m,ref]=inputs(1);
            raw=struct('identity',a,'initialState',repmat(m.spontaneous,1,8));
            raw.intact=stage3_recovery_prepare(m,d.xB,d.kappa,d.nu,[1 1],cfg.dt);
            raw.block=stage3_recovery_prepare(m,d.xB,d.kappa,d.nu,[0 0],cfg.dt);
            raw.ig=stage3_geometry(raw.intact.rates(401:10:501,:,:),ref.scale);
            raw.bg=stage3_geometry(raw.block.rates(401:10:501,:,:),ref.scale);
            raw.movement=simulate_published_cortex(m,raw.intact.go,true);
            [raw.theta,raw.hand]=simulate_published_arm(m,raw.movement.torque);
            raw.full=zeros(102,m.n,8); raw.moMs=zeros(1,8);
            for q=1:8
                speed=hypot(raw.hand(:,2,q),raw.hand(:,4,q)); mo=find(speed>=.2*max(speed),1)-1; raw.moMs(q)=mo;
                joined=[raw.intact.rates(1:500,:,q);raw.movement.rates(:,:,q)]; ix=501+mo+cfg.fullMO;
                assert(min(ix)>=1 && max(ix)<=size(joined,1));
                raw.full(:,:,q)=[raw.intact.rates(1:10:501,:,q);joined(ix,:)];
            end
            raw.fg=stage3_geometry(raw.full,ref.scale); raw.K=max(raw.ig.k,raw.bg.k);
            den=sum(raw.ig.eigenvalues(1:raw.K));
            raw.null=stage2_null(raw.fg.covariance,raw.ig.covariance,den,raw.K,cfg.nullDraws,a.nullSeed);
            raw.nullSeed=a.nullSeed; saveRaw(a.id,raw);
            ig=stage3_recovery_geometry(raw.intact.rates(401:10:501,:,:),ref.scale);
            bg=stage3_recovery_geometry(raw.block.rates(401:10:501,:,:),ref.scale); saved=old.sensitivity{j};
            compare([a.id ': intact PR'],ig.pr,saved.prIntact); compare([a.id ': block PR'],bg.pr,saved.prBlock);
            compare([a.id ': K'],max(ig.k,bg.k),saved.K);
            obs=sum((ig.matrix*bg.basis(:,1:raw.K)).^2,'all')/((size(ig.matrix,1)-1)*sum(ig.eigenvalues(1:raw.K)));
            compare([a.id ': alignment'],obs,saved.observed); compare([a.id ': expected'],mean(raw.null),saved.expected);
            independentNull=stage3_recovery_null(raw.fg.covariance,raw.ig.covariance,den,raw.K,cfg.nullDraws,raw.nullSeed);
            compare([a.id ': independent null'],independentNull,raw.null);
            compare([a.id ': state error'],mean(sqrt(sum((raw.block.go-m.xstar).^2,1))),saved.stateError);
            compare([a.id ': inputs'],max(raw.intact.inputMax,raw.block.inputMax),saved.inputMax);
            compare([a.id ': rate'],max(raw.intact.rateMax,raw.block.rateMax),saved.rateMax);
            compare([a.id ': settle'],raw.block.settle,saved.settle); compare([a.id ': gain'],d.kappa,saved.kappa);
            complete(a.id);
        end
        a=plan.fine; d=a.definition; [m,~]=inputs(1);
        raw=struct('identity',a); raw.prep=stage3_recovery_prepare(m,d.xB,d.kappa,d.nu,[0 0],a.dt); saveRaw(a.id,raw);
        coarse=old.primary{1}.block;
        compare('fine: curve',max(abs(raw.prep.distance-coarse.distance))/max(1,max(coarse.distance)),old.stepCheck.curveRelative);
        compare('fine: GO',norm(raw.prep.go-coarse.go,'fro')/max(1,norm(coarse.go,'fro')),old.stepCheck.goRelative);
        complete(a.id); report.status='PASS';
    catch err
        report.status='STOP'; report.errorIdentifier=err.identifier; report.errorMessage=err.message;
        report.elapsedSeconds=toc(started); stage3_write_json(checksFile,report); rethrow(err);
    end
    report.elapsedSeconds=toc(started); stage3_write_json(checksFile,report); disp(report);

    function [m,ref,grid]=inputs(n)
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        assert(m.dt==cfg.dt && m.samplingDt==cfg.savedDt && m.tau==cfg.tau);
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        grid=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',n)));
    end
    function saveRaw(id,raw)
        path=fullfile(out,[id '.mat']); assert(~isfile(path)); save(path,'raw','-v7.3');
    end
    function compare(id,actual,expected)
        assert(isequal(size(actual),size(expected)),'Recovery:Shape','Shape mismatch in %s',id);
        delta=max(abs(double(actual)-double(expected)),[],'all');
        tolerance=report.absoluteTolerance+report.relativeTolerance*max(abs(double(expected)),[],'all');
        ok=all(isfinite(double(actual)),'all') && delta<=tolerance;
        report.checks{end+1}=struct('id',id,'maxAbsoluteError',delta,'tolerance',tolerance,'pass',ok);
        if ~ok
            report.mismatch=struct('id',id,'actual',actual,'preserved',expected);
            error('Recovery:Mismatch','%s: discrepancy %.17g exceeds %.17g.',id,delta,tolerance);
        end
    end
    function complete(id)
        report.completedCases{end+1}=id; fprintf('Recovery matched: %s\n',id);
        assert(toc(started)<3600,'Recovery:Budget','Bounded recovery budget exceeded.');
    end
end

function [rms,endpoint]=movementError(hand,reference,onset)
    rms=zeros(1,8); endpoint=zeros(1,8);
    for target=1:8
        rows=1+onset(target)+(0:200);
        dx=hand(rows,1,target)-reference(rows,1,target); dy=hand(rows,3,target)-reference(rows,3,target);
        rms(target)=sqrt(sum(dx.*dx+dy.*dy)/numel(rows))*1000;
        endpoint(target)=hypot(hand(end,1,target)-reference(end,1,target),hand(end,3,target)-reference(end,3,target))*1000;
    end
end
