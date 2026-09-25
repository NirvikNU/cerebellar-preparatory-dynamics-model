function result=v2_grid(root)
    cfg=v2_paths(root); selectedPath=fullfile(cfg.dest,'geometry_selection.json'); assert(~isfile(selectedPath));
    r=jsondecode(fileread(fullfile(cfg.manifest,'preservation_before.json'))); assert(strcmp(r.status,'PASS'));
    r=jsondecode(fileread(fullfile(cfg.dest,'preflight.json'))); assert(strcmp(r.status,'PASS'));
    started=tic; rows=cell(10,1); audits=zeros(10,2); outputs=cell(10,1); inputs=cell(10,1); existing=false(10,1);
    for n=1:10
        path=fullfile(cfg.raw,sprintf('grid_n%02d.mat',n)); existing(n)=isfile(path);
        if existing(n)
            s=load(path,'out'); outputs{n}=s.out;
        else
            item=struct;
            s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); item.model=s.model;
            s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); item.ref=s.ref;
            s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',n)),'definitions'); item.definitions=s.definitions(1,:);
            s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'c'); item.controller=s.c;
            s=load(fullfile(cfg.previous.old.raw,sprintf('raw_n%02d_e5_p1.mat',n)),'raw');
            item.intact=s.raw.prep; item.eta=s.raw.eta; item.network=s.raw.network;
            s=load(fullfile(cfg.previous.raw,sprintf('null_n%02d.mat',n)),'projectors','qrProjectors');
            item.projectors=s.projectors; item.qrProjectors=s.qrProjectors; inputs{n}=item;
        end
    end
    assert(isempty(gcp('nocreate'))); pool=parpool('Threads',10); closer=onCleanup(@()delete(pool));
    parfor n=1:10
        if ~existing(n), outputs{n}=v2_grid_network(inputs{n},n); end
    end
    for n=1:10
        out=outputs{n}; rows{n}=out.rows; audits(n,:)=[out.auditError out.geometryError];
        path=fullfile(cfg.raw,sprintf('grid_n%02d.mat',n));
        if ~isfile(path), save(path,'out','-v7.3'); end
        outputs{n}=[];
    end
    map=vertcat(rows{:}); assert(height(map)==360 && all(isfinite(map.deltaPR)) && all(isfinite(map.deficitPP)));
    ensemble=map(map.network==1,{'gridIndex','alpha','betaNormalized'});
    ensemble.deltaPR=zeros(36,1); ensemble.deficitPP=zeros(36,1);
    for j=1:36
        ix=map.gridIndex==j; assert(nnz(ix)==10 && isscalar(unique(map.alpha(ix))) && isscalar(unique(map.betaNormalized(ix))));
        ensemble.deltaPR(j)=median(map.deltaPR(ix)); ensemble.deficitPP(j)=median(map.deficitPP(ix));
    end
    assert(isequal(unique(ensemble.alpha).',cfg.alpha) && isequal(unique(ensemble.betaNormalized).',cfg.beta));
    ensemble.loss=((ensemble.deltaPR-cfg.targets(1))/cfg.targets(1)).^2+((ensemble.deficitPP-cfg.targets(2))/cfg.targets(2)).^2;
    candidates=find(ensemble.loss==min(ensemble.loss));
    writetable(map,fullfile(cfg.dest,'geometry_network.csv')); writetable(ensemble,fullfile(cfg.dest,'geometry_ensemble.csv'));
    result=struct('status','AUDITED_PENDING_SELECTION','map',map,'ensemble',ensemble,'targets',cfg.targets,'auditErrors',audits);
    save(fullfile(cfg.dest,'geometry.mat'),'result','-v7.3');
    assert(isscalar(candidates),'FinalV2:ExactTie','Exact minimum tie: stop; no tie breaker is authorized.');
    j=candidates(1); row=ensemble(j,:);
    % Independent selection using sorted paired network effects, no median helper.
    independent=zeros(36,1);
    for k=1:36
        v=sort([map.deltaPR(map.gridIndex==k) map.deficitPP(map.gridIndex==k)],1);
        med=(v(5,:)+v(6,:))/2; independent(k)=sum(((med-cfg.targets)./cfg.targets).^2);
    end
    assert(max(abs(independent-ensemble.loss))<1e-12 && find(independent==min(independent),1)==j);
    receipt=struct('status','FROZEN','task','PAPER-MODELLING-FINAL-FIGURES-V2-01','eta',0,'lambda',10, ...
        'direction',1,'sInit',.1,'sTemporal',.1,'networks',10,'candidates',36,'gridIndex',row.gridIndex, ...
        'alpha',row.alpha,'betaNormalized',row.betaNormalized,'deltaPR',row.deltaPR,'deficitPP',row.deficitPP, ...
        'loss',row.loss,'targets',cfg.targets,'networkSpecificFit',false,'qcSelection',false, ...
        'downstreamEvaluated',false,'utc',char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ssXXX')), ...
        'elapsedSeconds',toc(started));
    paper_json(selectedPath,receipt); disp(receipt); clear closer
end
