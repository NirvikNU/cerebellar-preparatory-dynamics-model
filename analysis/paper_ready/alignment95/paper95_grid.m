function result=paper95_grid(root)
    addpath(fullfile(root,'analysis','paper_ready'),fullfile(root,'analysis','stage_2'),fullfile(root,'analysis','stage_3'));
    cfg=stage3_bio_paths(root); old=fullfile(root,'results','paper_ready');
    dest=fullfile(old,'alignment95'); cache=fullfile(old,'cache','alignment95');
    if ~isfolder(dest), mkdir(dest); end
    if ~isfolder(cache), mkdir(cache); end
    assert(~isfile(fullfile(dest,'geometry.mat')),'Refuse overwrite');
    p=jsondecode(fileread(fullfile(root,'artifacts','manifests','paper_ready','alignment95','PREFLIGHT.json')));
    assert(strcmp(p.status,'PASS'));
    s=load(fullfile(old,'geometry.mat'),'result'); result=s.result;
    result.oldSelectedIndex=result.selectedIndex; result.lossK15=result.loss;
    result.map.observedK15=result.map.observed; result.map.expectedK15=result.map.expected;
    result.map.kControl=nan(height(result.map),1); result.map.captureControl=nan(height(result.map),1);
    result.map.beforeControl=nan(height(result.map),1); result.map.captureBlockControlK=nan(height(result.map),1);
    result.map.denominator=nan(height(result.map),1);
    for n=1:10
        path=fullfile(cache,sprintf('alignment_n%02d.mat',n)); assert(~isfile(path));
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(old,'cache',sprintf('grid_n%02d.mat',n)),'intact','blocks','projectors','qrProjectors');
        ig=paper95_geometry(s.intact.meanRates(401:10:501,:,:),ref.scale);
        projectors=s.projectors; qrProjectors=s.qrProjectors; K=ig.k;
        if isempty(projectors{K})
            [projectors{K},qrProjectors{K}]=stage3_bio_projector(ref.fullCov,K,10000,2026090900+n);
        end
        nullValues=stage2_null(ref.fullCov,ig.cov,sum(ig.eigenvalues(1:K)),K,10000,2026090900+n);
        assert(abs(mean(nullValues)-trace(ig.cov*projectors{K})/sum(ig.eigenvalues(1:K)))<1e-10);
        result.intact{n}=ig;
        for row=find(result.map.network==n).'
            result.map.kControl(row)=K; result.map.captureControl(row)=ig.captureControl;
            result.map.beforeControl(row)=ig.beforeControl;
            if ~result.map.tested(row), continue; end
            g=paper95_geometry(s.blocks{result.map.gridIndex(row)}.meanRates(401:10:501,:,:),ref.scale);
            [ob,ex,den,~,capture]=paper95_compare(ig,g,projectors{K});
            assert(abs(g.pr-result.map.prBlock(row))<1e-10 && abs(ig.pr-result.map.prIntact(row))<1e-10);
            result.map.observed(row)=ob; result.map.expected(row)=ex;
            result.map.deficit(row)=ex-ob; result.map.denominator(row)=den;
            result.map.captureBlockControlK(row)=capture;
        end
        save(path,'ig','projectors','qrProjectors','nullValues','-v7.3');
        fprintf('Corrected saved grid network %d, Control K=%d\n',n,K);
    end
    for j=1:36
        rows=result.map.gridIndex==j;
        if all(result.map.tested(rows))
            result.deficit(j)=median(result.map.deficit(rows));
            result.loss(j)=((result.deltaPR(j)-result.target.deltaPR)/abs(result.target.deltaPR))^2 ...
                +((result.deficit(j)-result.target.alignmentDeficit)/abs(result.target.alignmentDeficit))^2;
        end
    end
    eligible=find(result.commonFeasible); best=min(result.loss(eligible));
    selected=eligible(abs(result.loss(eligible)-best)<=1e-12*max(1,abs(best)));
    assert(~isempty(selected)); result.selectedIndex=selected(1);
    result.rule='Control-only minimum cumulative variance >=0.95';
    result.status='GEOMETRY_PASS'; result.predictionRun=false;
    save(fullfile(dest,'geometry.mat'),'result','-v7.3');
    writetable(result.map,fullfile(dest,'geometry_map.csv'));
    paper_json(fullfile(dest,'geometry.json'),rmfield(result,{'map','intact'}));
    disp(result.map(result.map.gridIndex==result.selectedIndex,{'network','alpha','betaNormalized','kControl','prIntact','prBlock','observed','expected'}));
end
