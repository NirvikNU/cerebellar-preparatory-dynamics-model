function summary=v2_analyze(root)
    cfg=v2_paths(root); output=fullfile(cfg.dest,'summary.mat'); assert(~isfile(output));
    a=jsondecode(fileread(fullfile(cfg.dest,'simulation.json'))); assert(strcmp(a.status,'PASS'));
    s=load(fullfile(cfg.previous.dest,'summary.mat'),'summary'); summary.indices=s.summary.indices;
    summary.pairs=cfg.pairs; summary.names={'Intact','State setting only','Prospective feedback only','Block'};
    fields={'convergence','pr','r2','peakSpeed','endpoint','separation','shuffle','matched'};
    for name=fields, summary.(name{1})=nan(10,5,4); end
    summary.observed=nan(10,5,4); summary.expected=summary.observed; summary.k=nan(10,5);
    summary.pc75=nan(10,5,4,2); summary.qc=cell(10,5,4); summary.undefined=nan(10,5,4);
    summary.dispersion=nan(10,2); summary.behavior=cell(10,1); started=tic;
    assert(isempty(gcp('nocreate'))); pool=parpool('Threads',10); closer=onCleanup(@()delete(pool));
    for n=1:10
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.previous.raw,sprintf('null_n%02d.mat',n)),'projectors','qrProjectors');
        projectors=s.projectors; qrProjectors=s.qrProjectors;
        for v=1:5
            policies=[1 4]; if v==2, policies=1:4; end
            cases=cell(1,4); preps=cases; moves=cases; priors=cases; existing=false(1,4);
            for p=policies
                path=fullfile(cfg.raw,sprintf('analysis_n%02d_v%d_p%d.mat',n,v,p)); existing(p)=isfile(path);
                if existing(p), s=load(path,'result'); cases{p}=s.result;
                else, [preps{p},moves{p},priors{p}]=v2_load(cfg,n,v,p); end
            end
            scale=ref.scale;
            parfor p=1:4
                if ismember(p,policies)&&~existing(p)
                    cases{p}=v2_case(n,preps{p},moves{p},scale,priors{p});
                end
            end
            clear preps moves priors
            control=cases{1}.geometry; K=control.k; summary.k(n,v)=K;
            if isempty(projectors{K}), [projectors{K},qrProjectors{K}]=stage3_bio_projector(ref.fullCov,K,10000,2026090900+n); end
            for p=policies
                result=cases{p}; summary.convergence(n,v,p)=result.convergence.value; summary.pr(n,v,p)=result.geometry.pr;
                [ob,ex]=paper95_compare(control,result.geometry,projectors{K}); summary.observed(n,v,p)=100*ob; summary.expected(n,v,p)=100*ex;
                summary.undefined(n,v,p)=result.convergence.undefined; summary.qc{n,v,p}=result.qc;
                summary.peakSpeed(n,v,p)=result.peakMean; summary.endpoint(n,v,p)=mean(result.movement.endpointRmsByTarget);
                summary.separation(n,v,p)=result.movement.targetSeparationToScatter;
                if result.predictionEvaluable
                    pred=result.prediction; summary.r2(n,v,p)=pred.fit.r2(1); summary.pc75(n,v,p,:)=[pred.pca{1}.k pred.pca{2}.k];
                    if pred.reusedShuffles, values=pred.fit.r2(2:end); else, values=pred.shuffleFit.r2; end
                    summary.shuffle(n,v,p)=median(values);
                end
                if ~existing(p)
                    path=fullfile(cfg.raw,sprintf('analysis_n%02d_v%d_p%d.mat',n,v,p)); assert(~isfile(path)); save(path,'result','-v7.3');
                end
            end
            if cases{1}.predictionEvaluable && cases{4}.predictionEvaluable
                kk=min([cases{1}.prediction.pca{1}.k cases{1}.prediction.pca{2}.k;cases{4}.prediction.pca{1}.k cases{4}.prediction.pca{2}.k]);
                path=fullfile(cfg.raw,sprintf('matched_n%02d_v%d.mat',n,v)); paired=cell(1,2);
                if isfile(path), s=load(path,'paired'); paired=s.paired;
                else
                    for j=1:2
                        p=[1 4]; r=cases{p(j)}.prediction;
                        paired{j}=stage3_prediction_ridge(r.pca{1}.scores(:,1:kk(1)),r.pca{2}.scores(:,1:kk(2)),r.folds,cfg.grid);
                    end
                    save(path,'paired','kk','-v7.3');
                end
                summary.matched(n,v,1)=paired{1}.r2(1); summary.matched(n,v,4)=paired{2}.r2(1);
            end
            if v==2, summary.behavior{n}=v2_behavior(cases{1},cases{4}); summary.dispersion(n,:)=summary.behavior{n}.network; end
        end
        path=fullfile(cfg.raw,sprintf('null_n%02d.mat',n)); if ~isfile(path), save(path,'projectors','qrProjectors','-v7.3'); end
        fprintf('Final-v2 corrected assays network%d, %.1fs\n',n,toc(started));
    end
    summary.deficit=summary.expected-summary.observed;
    summary.deltaC=summary.convergence(:,:,4)-summary.convergence(:,:,1); summary.deltaR2=summary.r2(:,:,4)-summary.r2(:,:,1);
    intact=summary.r2(:,:,1); summary.lossPct=-100*summary.deltaR2./intact;
    summary.lossPct(~isfinite(intact)|intact<=eps(max(1,abs(intact))))=NaN;
    for name=[fields {'observed','expected','deficit','deltaC','deltaR2','lossPct','dispersion'}]
        summary.bootstrap.(name{1})=stage2_bootstrap(summary.(name{1}),summary.indices);
        summary.available.(name{1})=sum(isfinite(summary.(name{1})),1);
    end
    summary.status='GENERATED_PENDING_INDEPENDENT_AUDIT'; summary.elapsedSeconds=toc(started);
    save(output,'summary','-v7.3'); paper_json(fullfile(cfg.dest,'summary.json'),rmfield(summary,'indices')); clear closer
end
