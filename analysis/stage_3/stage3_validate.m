function audit = stage3_validate(cfg)
    % Independent saved-output audit, no model retuning or scientific rewrite.
    audit=struct('status','IN PROGRESS','normalizationMaxError',0,'fullCovMaxError',0, ...
        'prMaxError',0,'alignmentMaxError',0,'settledEigenMaxError',0, ...
        'policyIdentityMaxError',0,'nullDrawMaxError',0,'bootstrapMaxError',0);
    map=readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv'));
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); result=s.result;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=s.registry;
    assert(height(map)==1080 && numel(unique(map.network))==10 && numel(unique(map.direction))==3);
    assert(isequal(logical(map.feasible),logical(map.analytical & map.physical & map.finitePhenotype)));
    assert(all(~map.tested | (map.rateRealizable & map.modulationOK & map.endpointBoundsOK)));
    assert(all(map.tested | ~(map.rateRealizable & map.modulationOK & map.endpointBoundsOK)));
    sentinel=zeros(11,200,8);
    for t=1:11
        for n=1:200
            for q=1:8, sentinel(t,n,q)=10000*n+100*q+t; end
        end
    end
    X=reshape(permute(sentinel,[1 3 2]),[],200);
    for n=1:200, assert(all(floor(X(:,n)/10000)==n)); end
    audit.neuronIdentity='PASS: [time,neuron,target] -> permute[1,3,2] -> [time*target,neuron]; all 200 sentinel columns contain one neuron only.';
    audit.nativeStability=zeros(10,4); audit.fidelity=zeros(10,2);
    for member=1:10
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',member)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',member)),'model'); m=s.model;
        raw=zeros(816,200); centered=zeros(816,200); full=zeros(102,200,8);
        for q=1:8
            joined=[ref.prep.rates(1:500,:,q);ref.movement.rates(:,:,q)];
            full(:,:,q)=[ref.prep.rates(1:10:501,:,q);joined(501+ref.moMs(q)+cfg.fullMO,:)];
            raw((q-1)*102+(1:102),:)=full(:,:,q);
        end
        mu=mean(raw,1); sd=sqrt(sum((raw-mu).^2,1)/(size(raw,1)-1)).';
        audit.normalizationMaxError=max(audit.normalizationMaxError,max(abs(sd-ref.scale)));
        means=mean(full,3);
        for q=1:8, centered((q-1)*102+(1:102),:)=(full(:,:,q)-means)./sd.'; end
        C=cov(centered); audit.fullCovMaxError=max(audit.fullCovMaxError,max(abs(C-ref.fullCov),[],'all'));
        g=ref.geometry; tracePR=trace(g.covariance)^2/trace(g.covariance*g.covariance);
        audit.prMaxError=max(audit.prMaxError,abs(tracePR-g.pr));
        assert(sum(g.eigenvalues(1:g.k))>.95*sum(g.eigenvalues));
        assert(g.k==1 || sum(g.eigenvalues(1:g.k-1))<=.95*sum(g.eigenvalues));
        f=@(x)-x+m.W*max(x,0)+m.h; fStar=f(m.xstar);
        Wnorm=norm(m.W,2); a=cfg.dt/m.tau;
        qB=abs(1-a*(1+ref.kappa))+a*Wnorm; qI=abs(1-a*(1+ref.kappa+ref.nu))+a*Wnorm;
        evMax=-Inf; eulerMax=0;
        for q=1:8
            J=(-(1+ref.kappa+ref.nu)*eye(m.n)+m.W.*(m.xstar(:,q)>0).')/m.tau;
            ev=eig(J); evMax=max(evMax,max(real(ev))); eulerMax=max(eulerMax,max(abs(1+cfg.dt*ev)));
        end
        assert(qB<1 && qI<1 && evMax<0 && eulerMax<1);
        audit.nativeStability(member,:)=[qB qI evMax eulerMax];
        audit.fidelity(member,:)=[ref.releaseRelative ref.handErrorMax];
        assert(ref.releaseRelative<=cfg.intactReleaseRelativeTolerance && ref.handErrorMax<=cfg.intactHandToleranceM);
        % Independent QR projector agrees with SVD/orth for the same biased draws.
        [U,S,~]=svd(ref.fullCov); bias=U*diag(sqrt(max(diag(S),0)));
        stream=RandStream('mt19937ar','Seed',cfg.nullSeedBase+member);
        settled=ref.U*diag(ref.ell)*ref.U.';
        for draw=1:12
            gaussian=randn(stream,200,ref.d); gaussian=gaussian./vecnorm(gaussian);
            [Q,~]=qr(bias*gaussian,0); independent=trace(Q.'*settled*Q)/ref.T;
            audit.nullDrawMaxError=max(audit.nullDrawMaxError,abs(independent-ref.settledNull(draw)));
        end
        s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',member)),'definitions','preparations');
        for direction=1:3
            for j=1:36
                d=s.definitions{direction,j}; rate=ref.meanRate+ref.scale.*((d.alpha*ref.U*diag(sqrt(ref.ell))+d.beta*d.V)*ref.Z);
                rho=(d.beta/d.alpha)^2; predicted=d.alpha^2*(ref.ell+rho);
                y=(rate-ref.meanRate)./ref.scale; ev=sort(eig(y*y.'/7),'descend');
                audit.settledEigenMaxError=max(audit.settledEigenMaxError,max(abs(ev(1:ref.d)-predicted)));
                x=.3*m.spontaneous+.7*m.xstar;
                ci=d.corticalConstant-d.kappa*x; cb=d.b-d.nu*(x-m.xstar);
                residual=f(x)+ci+cb-(f(x)-fStar-(d.kappa+d.nu)*(x-m.xstar));
                audit.policyIdentityMaxError=max(audit.policyIdentityMaxError,max(abs(residual),[],'all'));
                assert(norm(f(d.xB)+d.corticalConstant-d.kappa*d.xB,'fro')/max(1,norm(d.xB,'fro'))<cfg.equilibriumRelativeTolerance);
                p=s.preparations{direction,j};
                if isempty(p), continue; end
                g=p.geometry; independent=trace(g.covariance)^2/sum(g.covariance.^2,'all');
                audit.prMaxError=max(audit.prMaxError,abs(independent-g.pr));
                K=max(g.k,ref.geometry.k); assert(g.capture>.95);
                assert(g.k==1 || sum(g.eigenvalues(1:g.k-1))<=.95*sum(g.eigenvalues));
                denom=sum(ref.geometry.eigenvalues(1:K));
                projection=sum((ref.geometry.matrix*g.basis(:,1:K)).^2,'all')/((size(ref.geometry.matrix,1)-1)*denom);
                row=map(map.network==member & map.direction==direction & map.gridIndex==j,:);
                audit.alignmentMaxError=max(audit.alignmentMaxError,abs(projection-row.observed));
            end
        end
    end
    assert(audit.normalizationMaxError<1e-12 && audit.fullCovMaxError<1e-9 && audit.prMaxError<1e-9);
    assert(audit.alignmentMaxError<1e-10 && audit.settledEigenMaxError<1e-8);
    assert(audit.policyIdentityMaxError<1e-10 && audit.nullDrawMaxError<1e-10);
    if result.hasPrimary
        for name={'pr','alignmentObservedExpected','earlyErrorMM'}
            values=result.metrics.(name{1}); draws=zeros(cfg.bootstrapDraws,2);
            for j=1:cfg.bootstrapDraws
                ordered=sort(values(result.bootstrapIndices(j,:),:),1);
                draws(j,:)=(ordered(5,:)+ordered(6,:))/2;
            end
            independent=sqrt(sum((draws-mean(draws,1)).^2,1)/(cfg.bootstrapDraws-1));
            standard=stage2_bootstrap(values,result.bootstrapIndices);
            audit.bootstrapMaxError=max(audit.bootstrapMaxError,max(abs(independent-standard.se)));
        end
        differences=[diff(result.metrics.pr,1,2),result.metrics.alignmentObservedExpected(:,1)-result.metrics.alignmentObservedExpected(:,2),diff(result.metrics.earlyErrorMM,1,2)];
        independentP=zeros(1,3);
        for metric=1:3
            d=differences(:,metric); sums=0;
            for j=1:10, sums=[sums+d(j);sums-d(j)]; end
            statistic=abs(mean(d)); independentP(metric)=mean(abs(sums/10)>=statistic-1e-12*max(1,statistic));
        end
        savedP=[result.statistics.prTest.p,result.statistics.alignmentTest.p,result.statistics.earlyTest.p];
        assert(isequal(independentP,savedP));
        [ordered,ix]=sort(independentP(1:2)); q=zeros(1,2); q(ix)=[min(2*ordered(1),ordered(2)),ordered(2)];
        assert(max(abs(q-result.statistics.geometryQ))<1e-15 && audit.bootstrapMaxError<1e-12);
        audit.statistics='PASS: independently sorted bootstrap medians, recursive exact signs and direct two-test BH';
        assert(~isempty(registry.primaryGridIndex) && numel(registry.primary)==10);
    else
        audit.statistics='No primary inferential results; unavailable under fixed rule, not a failed uncertainty calculation.';
    end
    protected=readtable(fullfile(cfg.manifestRoot,'PROTECTED_BEFORE.csv'),'TextType','string');
    after=hash_tree(cfg.projectRoot,protected.relative_path);
    assert(isequal(protected.relative_path,after.relative_path) && isequal(protected.bytes,after.bytes) && isequal(protected.sha256,after.sha256),'Protected assets changed.');
    writetable(after,fullfile(cfg.manifestRoot,'PROTECTED_AFTER.csv'));
    audit.protectedFiles=height(after); audit.protectedBytes=sum(after.bytes); audit.preservation='All protected SHA-256 values unchanged.';
    files=[dir(fullfile(cfg.projectRoot,'src','stage_3','*.m'));dir(fullfile(cfg.projectRoot,'analysis','stage_3','*.m')); ...
        dir(fullfile(cfg.projectRoot,'figures','stage_3','*.m'));dir(fullfile(cfg.projectRoot,'config','stage_3_config.m'));dir(fullfile(cfg.projectRoot,'run_stage_3.m'))];
    for j=1:numel(files)
        issues=checkcode(fullfile(files(j).folder,files(j).name),'-id');
        if ~isempty(issues), disp(files(j).name); disp(struct2table(issues)); end
        assert(isempty(issues),'Changed MATLAB Code Analyzer findings.');
    end
    figs=dir(fullfile(cfg.plotsFigRoot,'*.fig')); pngs=dir(fullfile(cfg.plotsPngRoot,'*.png')); assert(numel(figs)==4 && numel(pngs)==4);
    for j=1:4
        f=openfig(fullfile(figs(j).folder,figs(j).name),'invisible'); assert(isgraphics(f)); close(f);
        info=imfinfo(fullfile(pngs(j).folder,pngs(j).name)); assert(info.Width>1000);
    end
    audit.figureBundles=4; audit.hasPrimary=result.hasPrimary; audit.mapRows=height(map); audit.feasiblePoints=sum(map.feasible);
    referenceReceipt=jsondecode(fileread(fullfile(cfg.manifestRoot,'REFERENCE_FROZEN.json')));
    mapReceipt=jsondecode(fileread(fullfile(cfg.manifestRoot,'MAP_COMPLETE.json')));
    audit.totalProductionSeconds=referenceReceipt.summary(end).elapsedSeconds+mapReceipt.elapsedSeconds+result.elapsedSeconds;
    assert(audit.totalProductionSeconds<=cfg.maxWallSeconds,'Aggregate production compute budget exceeded.');
    audit.status='PASS'; audit.completedUTC=char(datetime('now','TimeZone','UTC'));
    stage3_write_json(fullfile(cfg.manifestRoot,'FINAL_AUDIT.json'),audit);
    disp(audit);
end
