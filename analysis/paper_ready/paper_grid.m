function result = paper_grid(root)
    addpath(fullfile(root,'analysis','stage_3')); cfg=stage3_bio_paths(root);
    dest=fullfile(root,'results','paper_ready'); cache=fullfile(dest,'cache');
    assert(~isfile(fullfile(dest,'geometry.mat'))); if ~isfolder(cache), mkdir(cache); end
    s=load(fullfile(dest,'timing','timing.mat'),'result'); timing=s.result;
    assert(strcmp(timing.status,'TIMING_PASS'));
    s=load(fullfile(dest,'preflight.mat'),'audit'); assert(strcmp(s.audit.status,'PASS'));
    s=load(fullfile(dest,'empirical','targets.mat'),'target'); target=s.target;
    s=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); cs=s.controllers;
    original=readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv'));
    map=original(original.direction==1,{'network','gridIndex','alpha','betaNormalized','rateRealizable','modulationOK'});
    fields={'inputLimit','endpointInputMax','rateMax','stateMax','componentMax','prIntact','prBlock', ...
        'rankIntact','rankBlock','captureIntact15','captureBlock15','observed','expected','deltaPR', ...
        'deficit','commonK','observedAdaptive','expectedAdaptive','inputAuditError','localPole','eulerRadius'};
    for k=1:numel(fields), map.(fields{k})=nan(height(map),1); end
    map.tested=false(height(map),1); map.feasible=false(height(map),1); map.reason=repmat({''},height(map),1);
    result.intact=cell(10,1); started=tic;
    for n=1:10
        path=fullfile(cache,sprintf('grid_n%02d.mat',n)); assert(~isfile(path),'Refuse cache overwrite');
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',n)),'definitions'); definitions=s.definitions(1,:);
        s=load(fullfile(root,'results','stage_2','current','cache',sprintf('network_%02d.mat',n)),'net');
        c=cs{n}; c.P=s.net.controller{timing.lambda==timing.selectedLambda}.P;
        c.L=c.P/timing.selectedLambda; c.lambda=timing.selectedLambda;
        noise=paper_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
        intact=paper_prepare(m,definitions(5),c,[1 1],.1,.1,noise,m.dt,true,true);
        intactComponents=paper_intact_components(m,intact,definitions,c);
        inputLimit=5*max(1,intact.componentMax(5));
        assert(intact.rateMax<=ref.rateLimit && intact.stateMax<=ref.stateLimit);
        ig=paper_geometry(intact.meanRates(401:10:501,:,:),ref.scale);
        result.intact{n}=ig; rows=find(map.network==n); passed=[];
        for j=1:36
            r=rows(j); d=definitions{j};
            assert(d.alpha==map.alpha(r) && d.betaNormalized==map.betaNormalized(r));
            fB=-d.xB+m.W*max(d.xB,0)+m.h;
            b=fB-c.fStar+c.kappa0*(m.xstar-d.xB); imax=0;
            for state={repmat(m.spontaneous,1,8),d.xB,m.xstar}
                x=state{1}; u0=-fB-c.kappa0*(x-d.xB); fb=-c.L*(x-m.xstar);
                parts={u0,b,fb,b+fb,u0+b+fb};
                for z=1:5, imax=max(imax,max(vecnorm(parts{z}))); end
            end
            active=unique((d.xB>0).','rows'); ev=[];
            for z=1:size(active,1), ev=[ev;eig((-eye(200)+m.W.*active(z,:)-c.kappa0*eye(200))/m.tau)]; end %#ok<AGROW>
            map.localPole(r)=max(real(ev)); map.eulerRadius(r)=max(abs(1+m.dt*ev));
            map.inputLimit(r)=inputLimit; map.endpointInputMax(r)=imax;
            good=map.rateRealizable(r)&&map.modulationOK(r)&&imax<=inputLimit && max(intactComponents(j,:))<=inputLimit ...
                && max(max(d.xB,0),[],'all')<=ref.rateLimit && max(vecnorm(d.xB))<=ref.stateLimit ...
                && map.localPole(r)<0 && map.eulerRadius(r)<1;
            if good, passed(end+1)=j; else, map.reason{r}='physical endpoint screen'; end %#ok<AGROW>
        end
        % Batching only changes independent-column scheduling, not equations.
        blocks=cell(1,36);
        for first=1:6:numel(passed)
            jj=passed(first:min(first+5,numel(passed)));
            batch=paper_prepare(m,definitions(jj),c,[0 0],.1,.1,noise);
            for z=1:numel(jj), blocks{jj(z)}=batch(z); end
        end
        projectors=cell(200,1); qrProjectors=projectors; nullDraws=projectors;
        for j=passed
            r=rows(j); p=blocks{j}; d=definitions{j}; map.tested(r)=true;
            g=paper_geometry(p.meanRates(401:10:501,:,:),ref.scale);
            auditError=0; targets=repelem(1:8,30);
            fB=-d.xB+m.W*max(d.xB,0)+m.h;
            for a=p.audit
                predicted=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h-fB(:,targets)-c.kappa0*(a.x-d.xB(:,targets)))+a.noiseIncrement;
                auditError=max(auditError,max(abs(predicted-a.next),[],'all'));
            end
            assert(auditError<1e-10);
            K=max(ig.k,g.k); ks=unique([15 K]); ob=zeros(1,2); ex=ob;
            for z=1:numel(ks)
                k=ks(z);
                if isempty(projectors{k})
                    [projectors{k},qrProjectors{k}]=stage3_bio_projector(ref.fullCov,k,10000,2026090900+n);
                    nullDraws{k}=stage2_null(ref.fullCov,ig.cov,sum(ig.eigenvalues(1:k)),k,10000,2026090900+n);
                end
            end
            for z=1:2
                kval=[15 K]; k=kval(z); den=sum(ig.eigenvalues(1:k)); B=g.basis(:,1:k);
                ob(z)=trace(B.'*ig.cov*B)/den; ex(z)=trace(ig.cov*projectors{k})/den;
                assert(abs(ex(z)-mean(nullDraws{k}))<1e-10);
            end
            vals=[p.rateMax,p.stateMax,max(p.counterfactualMax),ig.pr,g.pr,ig.rank,g.rank, ...
                ig.capture15,g.capture15,ob(1),ex(1),g.pr-ig.pr,ex(1)-ob(1),K,ob(2),ex(2),auditError];
            names=fields(3:19);
            for z=1:numel(names), map.(names{z})(r)=vals(z); end
            map.feasible(r)=ig.k15Valid&&g.k15Valid&&p.rateMax<=ref.rateLimit ...
                &&p.stateMax<=ref.stateLimit&&max(p.counterfactualMax)<=inputLimit;
            if map.feasible(r), map.reason{r}='feasible'; else, map.reason{r}='dynamic bound or K15 degeneracy'; end
        end
        save(path,'intact','intactComponents','blocks','definitions','c','projectors','qrProjectors','nullDraws','-v7.3');
        writetable(map,fullfile(dest,'geometry_progress.csv'));
        fprintf('Geometry network%02d: %d screened-in, %d feasible %.1fs\n',n,numel(passed),nnz(map.feasible(rows)),toc(started));
    end
    result.map=map; result.loss=nan(36,1); result.commonFeasible=false(36,1);
    result.deltaPR=nan(36,1); result.deficit=nan(36,1);
    for j=1:36
        r=map.gridIndex==j; result.commonFeasible(j)=all(map.feasible(r));
        if all(map.tested(r))
            result.deltaPR(j)=median(map.deltaPR(r)); result.deficit(j)=median(map.deficit(r));
            result.loss(j)=((result.deltaPR(j)-target.deltaPR)/abs(target.deltaPR))^2 ...
                +((result.deficit(j)-target.alignmentDeficit)/abs(target.alignmentDeficit))^2;
        end
    end
    result.selectedIndex=NaN;
    if any(result.commonFeasible)
        eligible=find(result.commonFeasible); best=min(result.loss(eligible));
        candidates=eligible(abs(result.loss(eligible)-best)<=1e-12*max(1,abs(best)));
        result.selectedIndex=candidates(1); result.status='GEOMETRY_PASS';
    else
        result.status='STOP_NO_COMMON_FEASIBLE_GEOMETRY';
    end
    result.lambda=timing.selectedLambda; result.target=target;
    save(fullfile(dest,'geometry.mat'),'result','-v7.3');
    compact=rmfield(result,{'intact','map'}); paper_json(fullfile(dest,'geometry.json'),compact);
    writetable(map,fullfile(dest,'geometry_map.csv')); disp(compact);
end
