function summary = eta_analyze(root)
    cfg=eta_paths(root); started=tic; receipt=fullfile(cfg.dest,'summary.mat'); assert(~isfile(receipt));
    s=jsondecode(fileread(fullfile(cfg.dest,'simulation.json'))); assert(strcmp(s.status,'PASS'));
    s=load(fullfile(cfg.dest,'baseline.mat'),'audit'); summary.spectral=max(s.audit.spectralAbscissa,[],4);
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); summary.indices=s.result.bootstrapIndices;
    summary.eta=cfg.eta; summary.names=cfg.names; summary.bias=zeros(10,5,2);
    summary.dispersion=summary.bias; summary.convergence=summary.bias; summary.pr=summary.bias;
    summary.r2=nan(10,5,2); summary.k=zeros(10,5); summary.observed=zeros(10,5); summary.expected=summary.observed;
    summary.qc=cell(10,5,2); summary.undefined=zeros(10,5,2); summary.prepAdmissible=false(10,5,2);
    summary.mo=zeros(10,5,2); summary.peakTime=summary.mo; summary.peakSpeed=summary.mo;
    summary.endpoint=summary.mo; summary.separation=summary.mo; summary.pc75=zeros(10,5,2,2);
    assert(isempty(gcp('nocreate'))); pool=parpool('Threads',10); cleanup=onCleanup(@()delete(pool));
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)), ...
            'd','policies','projectors','qrProjectors');
        d=s.d; projectors=s.projectors; qrProjectors=s.qrProjectors;
        inputLimit=5*max(1,s.policies{1}.componentMax(5)); preps=cell(10,1); moves=preps; priors=preps;
        for j=1:10
            [e,p]=ind2sub([5 2],j); [preps{j},moves{j},priors{j}]=eta_load_case(cfg,n,e,p);
        end
        calculated=cell(10,1); eq={m.xstar,d.xB}; scale=ref.scale;
        parfor j=1:10
            [~,p]=ind2sub([5 2],j);
            calculated{j}=eta_case(n,preps{j},moves{j},scale,eq{p},priors{j}); %#ok<PFBNS>
        end
        for e=1:5
            gi=calculated{e}.geometry; gb=calculated{e+5}.geometry; K=gi.k;
            if numel(projectors)<K || isempty(projectors{K})
                [projectors{K},qrProjectors{K}]=stage3_bio_projector(ref.fullCov,K,10000,2026090900+n);
            end
            [summary.observed(n,e),summary.expected(n,e)]=paper95_compare(gi,gb,projectors{K});
            summary.k(n,e)=K;
            for p=1:2
                j=e+5*(p-1); result=calculated{j}; prep=preps{j}; move=moves{j};
                result.eta=cfg.eta(e); result.network=n; result.condition=p;
                result.scale=scale; result.inputLimit=inputLimit;
                result.bounds=[ref.rateLimit ref.stateLimit inputLimit];
                summary.bias(n,e,p)=mean(result.relativeBias); summary.dispersion(n,e,p)=mean(result.dispersion);
                summary.convergence(n,e,p)=result.convergence.value; summary.pr(n,e,p)=result.geometry.pr;
                summary.undefined(n,e,p)=result.convergence.undefined;
                if result.predictionEvaluable
                    summary.r2(n,e,p)=result.prediction.fit.r2(1);
                    summary.pc75(n,e,p,:)=[result.prediction.pca{1}.k result.prediction.pca{2}.k];
                end
                bounded=prep.rateMax<=ref.rateLimit && prep.stateMax<=ref.stateLimit && max(prep.componentMax)<=inputLimit;
                summary.prepAdmissible(n,e,p)=bounded;
                qc=struct('nearZero',sum(move.nearZero),'missingWindow',sum(move.missingWindow), ...
                    'boundaryPeak',sum(move.boundaryPeak),'multiPeak',sum(move.multiPeakCount>=2), ...
                    'finite',all(isfinite(move.hand),'all') && all(isfinite(move.theta),'all'), ...
                    'prepBounds',bounded,'prepRateMax',prep.rateMax,'prepStateMax',prep.stateMax, ...
                    'prepInputMax',max(prep.componentMax),'movementRateMax',move.rateMax,'movementStateMax',move.stateMax);
                result.qc=qc; summary.qc{n,e,p}=qc;
                summary.mo(n,e,p)=median(move.moMs); summary.peakTime(n,e,p)=median(move.peakMs);
                summary.peakSpeed(n,e,p)=median(move.peak); summary.endpoint(n,e,p)=1000*mean(move.endpointRmsByTarget);
                summary.separation(n,e,p)=move.targetSeparationToScatter;
                path=fullfile(cfg.raw,sprintf('analysis_n%02d_e%d_p%d.mat',n,e,p));
                assert(~isfile(path)); save(path,'result','-v7.3');
            end
        end
        path=fullfile(cfg.raw,sprintf('null_n%02d.mat',n)); assert(~isfile(path));
        save(path,'projectors','qrProjectors','-v7.3');
        fprintf('Saved analysis network %d, all eta and policies: %.1fs.\n',n,toc(started));
    end
    summary.deficit=summary.expected-summary.observed;
    summary.relativeLoss=100*(summary.r2(:,:,1)-summary.r2(:,:,2))./summary.r2(:,:,1);
    fields={'spectral','bias','dispersion','convergence','pr','r2','observed','expected','deficit', ...
        'relativeLoss','mo','peakTime','peakSpeed','endpoint','separation'};
    for j=1:numel(fields), field=fields{j}; summary.bootstrap.(field)=stage2_bootstrap(summary.(field),summary.indices); end
    summary.status='GENERATED_PENDING_INDEPENDENT_AUDIT'; summary.elapsedSeconds=toc(started);
    summary.newBaselineSimulations=0; summary.rrrRun=false; summary.etaSelected=false;
    save(receipt,'summary','-v7.3'); paper_json(fullfile(cfg.dest,'summary.json'),rmfield(summary,'indices'));
    clear cleanup
end
