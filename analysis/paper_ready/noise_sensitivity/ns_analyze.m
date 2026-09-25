function summary=ns_analyze(root)
    cfg=ns_paths(root); output=fullfile(cfg.dest,'summary.mat'); assert(~isfile(output)); started=tic;
    a=jsondecode(fileread(fullfile(cfg.dest,'simulation.json'))); assert(strcmp(a.status,'PASS'));
    s=load(fullfile(cfg.old.dest,'summary.mat'),'summary'); old=s.summary; summary.indices=old.indices;
    summary.eta=cfg.eta; summary.pairs=cfg.pairs; summary.names=cfg.names;
    fields={'convergence','pr','r2','bias','dispersion','mo','peakTime','peakSpeed','endpoint','separation','shuffle','matched'};
    for name=fields, summary.(name{1})=nan(10,2,5,2); end
    summary.k=nan(10,2,5); summary.observed=summary.k; summary.expected=summary.k;
    summary.pc75=nan(10,2,5,2,2); summary.qc=cell(10,2,5,2); summary.undefined=nan(10,2,5,2);
    assert(isempty(gcp('nocreate'))); pool=parpool('Threads',10); cleanup=onCleanup(@()delete(pool));
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'d','policies'); d=s.d;
        bounds=[ref.rateLimit ref.stateLimit 5*max(1,s.policies{1}.componentMax(5))];
        s=load(fullfile(cfg.old.raw,sprintf('null_n%02d.mat',n)),'projectors','qrProjectors'); projectors=s.projectors; qrProjectors=s.qrProjectors;
        for e=1:2
            preps=cell(10,1); moves=preps; priors=preps; calculated=preps; existing=false(10,1);
            for j=1:10
                [v,p]=ind2sub([5 2],j); path=fullfile(cfg.raw,sprintf('analysis_n%02d_e%d_v%d_p%d.mat',n,e,v,p));
                existing(j)=isfile(path);
                if existing(j)
                    s=load(path,'result'); calculated{j}=s.result;
                else
                    [preps{j},moves{j}]=ns_load(cfg,n,e,v,p);
                    if v==2
                        s=load(fullfile(cfg.old.raw,sprintf('analysis_n%02d_e%d_p%d.mat',n,cfg.oldEta(e),p)),'result'); priors{j}=s.result;
                    end
                end
            end
            eq={m.xstar,d.xB}; scale=ref.scale; grid=cfg.grid;
            parfor j=1:10
                if ~existing(j)
                    [~,p]=ind2sub([5 2],j);
                    calculated{j}=ns_case(n,preps{j},moves{j},scale,eq{p},bounds,priors{j},grid); %#ok<PFBNS>
                end
            end
            clear preps moves priors
            for v=1:5
                gi=calculated{v}.geometry; gb=calculated{v+5}.geometry; K=gi.k;
                if numel(projectors)<K || isempty(projectors{K})
                    [projectors{K},qrProjectors{K}]=stage3_bio_projector(ref.fullCov,K,10000,2026090900+n);
                end
                if calculated{v}.evaluable && calculated{v+5}.evaluable
                    [summary.observed(n,e,v),summary.expected(n,e,v)]=paper95_compare(gi,gb,projectors{K}); summary.k(n,e,v)=K;
                end
                matchedPath=fullfile(cfg.raw,sprintf('matched_n%02d_e%d_v%d.mat',n,e,v));
                paired=cell(1,2);
                if isfile(matchedPath)
                    s=load(matchedPath,'paired'); paired=s.paired;
                elseif calculated{v}.predictionEvaluable && calculated{v+5}.predictionEvaluable
                    a=calculated{v}.prediction; b=calculated{v+5}.prediction;
                    kk=min([a.pca{1}.k a.pca{2}.k;b.pca{1}.k b.pca{2}.k]);
                    if e==2 && v==2
                        s=load(fullfile(cfg.paper,'cache','prediction',sprintf('matched_n%02d.mat',n)),'paired'); paired=s.paired(3,:);
                    else
                        for p=1:2
                            r=calculated{v+5*(p-1)}.prediction;
                            paired{p}=stage3_prediction_ridge(r.pca{1}.scores(:,1:kk(1)),r.pca{2}.scores(:,1:kk(2)),r.folds,grid);
                        end
                    end
                    assert(~isfile(matchedPath)); save(matchedPath,'paired','kk','-v7.3');
                end
                for p=1:2
                    j=v+5*(p-1); result=calculated{j}; result.network=n; result.eta=cfg.eta(e); result.pair=cfg.pairs(v,:); result.condition=p;
                    if result.evaluable
                        summary.convergence(n,e,v,p)=result.convergence.value; summary.pr(n,e,v,p)=result.geometry.pr;
                    end
                    summary.bias(n,e,v,p)=mean(result.relativeBias); summary.dispersion(n,e,v,p)=mean(result.dispersion);
                    summary.undefined(n,e,v,p)=result.convergence.undefined; summary.qc{n,e,v,p}=result.qc;
                    if result.predictionEvaluable
                        r=result.prediction; summary.r2(n,e,v,p)=r.fit.r2(1);
                        summary.pc75(n,e,v,p,:)=[r.pca{1}.k r.pca{2}.k];
                        if r.reusedShuffles, values=r.fit.r2(2:end); else, values=r.shuffleFit.r2; end
                        summary.shuffle(n,e,v,p)=median(values);
                        if ~isempty(paired{p}), summary.matched(n,e,v,p)=paired{p}.r2(1); end
                    end
                    move=result.movement; summary.mo(n,e,v,p)=median(move.moMs); summary.peakTime(n,e,v,p)=median(move.peakMs);
                    summary.peakSpeed(n,e,v,p)=median(move.peak); summary.endpoint(n,e,v,p)=1000*mean(move.endpointRmsByTarget);
                    summary.separation(n,e,v,p)=move.targetSeparationToScatter;
                    if v==2
                        oe=cfg.oldEta(e);
                        assert(isequaln(summary.convergence(n,e,v,p),old.convergence(n,oe,p)) && isequaln(summary.r2(n,e,v,p),old.r2(n,oe,p)));
                        assert(isequaln(summary.pr(n,e,v,p),old.pr(n,oe,p)) && isequaln(summary.observed(n,e,v),old.observed(n,oe)));
                    end
                    if ~existing(j)
                        path=fullfile(cfg.raw,sprintf('analysis_n%02d_e%d_v%d_p%d.mat',n,e,v,p)); assert(~isfile(path)); save(path,'result','-v7.3');
                    end
                end
            end
        end
        path=fullfile(cfg.raw,sprintf('null_n%02d.mat',n));
        if ~isfile(path), save(path,'projectors','qrProjectors','-v7.3'); end
        fprintf('Saved primary/convergence/controls/QC network%d, %.1fs.\n',n,toc(started));
    end
    summary.deficit=summary.expected-summary.observed;
    summary.deltaC=summary.convergence(:,:,:,2)-summary.convergence(:,:,:,1);
    summary.deltaR2=summary.r2(:,:,:,2)-summary.r2(:,:,:,1);
    intact=summary.r2(:,:,:,1); summary.lossPct=-100*summary.deltaR2./intact;
    summary.lossPct(~isfinite(intact)|intact<=eps(max(1,abs(intact))))=NaN;
    fields=[fields {'observed','expected','deficit','deltaC','deltaR2','lossPct'}];
    for name=fields
        summary.bootstrap.(name{1})=stage2_bootstrap(summary.(name{1}),summary.indices);
        summary.available.(name{1})=sum(isfinite(summary.(name{1})),1);
    end
    summary.status='GENERATED_PENDING_INDEPENDENT_AUDIT'; summary.elapsedSeconds=toc(started);
    summary.noiseSelected=false; summary.etaSelected=false; summary.rrrRun=false;
    save(output,'summary','-v7.3'); paper_json(fullfile(cfg.dest,'summary.json'),rmfield(summary,'indices')); clear cleanup
end
