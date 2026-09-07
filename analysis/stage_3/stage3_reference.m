function summary = stage3_reference(cfg)
    % Freeze the new intact metric before constructing any block state.
    assert(~isfile(fullfile(cfg.cacheRoot,'reference_10.mat')),'Reference already exists.');
    if ~isfolder(cfg.cacheRoot), mkdir(cfg.cacheRoot); end
    started=tic;
    protected=["src/published_generator","config/published_generator_config.m", ...
        "config/stage_1_gate1_config.m","analysis/published_generator", ...
        "figures/published_generator","results/stage_1","plots/stage_1", ...
        "workflows/stage_1","run_stage_1.m","run_all.m", ...
        "src/stage_2","analysis/stage_2","figures/stage_2","results/stage_2", ...
        "plots/stage_2","config/stage_2_config.m","config/stage_2_geometry_config.m", ...
        "run_stage_2.m","artifacts/manifests/stage2_lambda_sweep", ...
        "figures/apply_plot_style.m","figures/save_figure_bundle.m"];
    manifest=hash_tree(cfg.projectRoot,protected);
    manifest=manifest(~endsWith(lower(manifest.relative_path),'desktop.ini'),:);
    writetable(manifest,fullfile(cfg.manifestRoot,'PROTECTED_BEFORE.csv'));
    stage3_write_json(fullfile(cfg.manifestRoot,'PREDECLARED_CONFIG.json'),cfg);
    algebra=test_stage3_derivation(cfg.projectRoot);
    save(fullfile(cfg.resultsRoot,'derivation_audit.mat'),'algebra');
    summary=zeros(10,10);
    for member=1:10
        path=fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',member));
        assert(~isfile(path),'Refuse to overwrite existing reference.');
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',member)),'model'); m=s.model;
        assert(m.dt==cfg.dt && m.tau==cfg.tau && m.samplingDt==cfg.savedDt);
        ref.member=member; ref.kappa=max(0,norm(m.W,2)-1)+cfg.kappaMargin;
        ref.nu=cfg.nu;
        ref.prep=stage3_prepare(m,m.xstar,ref.kappa,ref.nu,[1 1]);
        ref.movement=simulate_published_cortex(m,ref.prep.go,true);
        [~,ref.hand]=simulate_published_arm(m,ref.movement.torque);
        ref.comparator=simulate_published_cortex(m,m.xstar,false);
        [~,ref.comparatorHand]=simulate_published_arm(m,ref.comparator.torque);
        ref.releaseRelative=max(vecnorm(ref.prep.go-m.xstar)./max(1,vecnorm(m.xstar)));
        ref.handErrorMax=max(abs(ref.hand-ref.comparatorHand),[],'all');
        assert(ref.releaseRelative<=cfg.intactReleaseRelativeTolerance,'Intact GO fidelity failed.');
        assert(ref.handErrorMax<=cfg.intactHandToleranceM,'Intact movement fidelity failed.');
        full=zeros(102,m.n,8); ref.moMs=zeros(1,8); ref.comparatorMoMs=zeros(1,8);
        for q=1:8
            speed=hypot(ref.hand(:,2,q),ref.hand(:,4,q));
            assert(max(speed)>0); mo=find(speed>=.2*max(speed),1)-1; ref.moMs(q)=mo;
            speed=hypot(ref.comparatorHand(:,2,q),ref.comparatorHand(:,4,q));
            ref.comparatorMoMs(q)=find(speed>=.2*max(speed),1)-1;
            joined=[ref.prep.rates(1:500,:,q);ref.movement.rates(:,:,q)];
            ix=501+mo+cfg.fullMO; assert(min(ix)>=1 && max(ix)<=size(joined,1),'MO window unavailable.');
            full(:,:,q)=[ref.prep.rates(1:10:501,:,q);joined(ix,:)];
        end
        observations=reshape(permute(full,[1 3 2]),[],m.n);
        ref.scale=std(observations,0,1).';
        assert(all(isfinite(ref.scale) & ref.scale>100*eps(max(1,max(abs(observations),[],1).'))));
        fullGeometry=stage3_geometry(full,ref.scale); ref.fullCov=fullGeometry.covariance;
        ref.geometry=stage3_geometry(ref.prep.rates(401:10:501,:,:),ref.scale);
        ref.meanRate=mean(max(m.xstar,0),2);
        ref.Y=(max(m.xstar,0)-ref.meanRate)./ref.scale;
        [U,S,V]=svd(ref.Y,'econ'); singular=diag(S);
        ref.rankThreshold=cfg.rankMultiplier*max(size(ref.Y))*eps(max(singular));
        ref.d=sum(singular>ref.rankThreshold); assert(ref.d>=1 && ref.d<=7);
        ref.U=U(:,1:ref.d); ref.ell=singular(1:ref.d).^2/7;
        ref.Z=sqrt(7)*V(:,1:ref.d).';
        ref.T=sum(ref.ell); ref.S=sum(ref.ell.^2);
        ref.reconstruction=max(abs(ref.Y-ref.U*diag(sqrt(ref.ell))*ref.Z),[],'all');
        assert(ref.reconstruction<1e-10 && norm(cov(ref.Z.')-eye(ref.d),'fro')<1e-10);
        ref.rawTrace=sum((max(m.xstar,0)-ref.meanRate).^2,'all')/7;
        ref.rateLimit=cfg.rateMultiplier*max([ref.prep.rateMax,max(ref.movement.rates,[],'all'),max(max(m.xstar,0),[],'all')]);
        ref.stateLimit=cfg.stateMultiplier*max([1,ref.prep.statesNormMax,max(vecnorm(m.xstar)),norm(m.spontaneous)]);
        ref.inputReference=max(1,ref.prep.inputMax(5)); ref.inputLimit=cfg.inputMultiplier*ref.inputReference;
        settled=ref.U*diag(ref.ell)*ref.U.';
        ref.settledNull=stage2_null(ref.fullCov,settled,ref.T,ref.d,cfg.nullDraws,cfg.nullSeedBase+member);
        ref.eta=mean(ref.settledNull);
        ref.etaLower=max(0,ref.eta-cfg.nullHoeffdingRadius-cfg.alignmentMargin);
        ref.rhoBound=max([0,(.05*ref.T-min(ref.ell))/(1-.05*ref.d),max(ref.ell)*(1/ref.etaLower-1)]);
        ref.createdUTC=char(datetime('now','TimeZone','UTC')); ref.config=cfg;
        save(path,'ref','-v7.3');
        summary(member,:)=[member ref.d min(ref.scale) max(ref.scale) ref.eta ref.etaLower ref.rhoBound ref.releaseRelative ref.handErrorMax toc(started)];
        fprintf('Frozen reference %02d: rank=%d, eta=%.6f, GO=%.3g, hand=%.3g\n',member,ref.d,ref.eta,ref.releaseRelative,ref.handErrorMax);
        assert(toc(started)<cfg.maxWallSeconds,'Reference compute budget exceeded.');
    end
    summary=array2table(summary,'VariableNames',{'network','rank','minSD','maxSD','eta','etaLower','rhoBound','releaseRelative','handMax','elapsedSeconds'});
    writetable(summary,fullfile(cfg.resultsRoot,'reference_summary.csv'));
    stage3_write_json(fullfile(cfg.manifestRoot,'REFERENCE_FROZEN.json'),struct('status','frozen before block construction','config',cfg,'summary',table2struct(summary)));
end
