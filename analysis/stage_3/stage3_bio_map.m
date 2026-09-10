function map = stage3_bio_map
    % Same stored geometry; only controller-dependent classification changes.
    cfg=stage3_bio_paths; destination=fullfile(cfg.bioRoot,'feasibility_map.csv'); assert(~isfile(destination));
    s=load(fullfile(cfg.bioRoot,'population.mat'),'result'); pop=s.result; assert(pop.primaryPass);
    s=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); cs=s.controllers;
    map=readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv')); oldMap=map;
    dynamic={'settle','rateMax','stateMax','corticalMax','sustainedMax','feedbackMax','cbMax','totalMax', ...
        'prBlock','kBlock','commonK','intactCapture','blockCapture','blockGap','observed','expected', ...
        'nullSE','nullHalfDifference','alignmentMargin','localMaxReal','localEulerRadius'};
    for name=dynamic, map.(name{1})(:)=NaN; end
    for name={'tested','physical','finitePhenotype','feasible'}, map.(name{1})(:)=false; end
    map.reason(:)={''}; started=tic;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',n)),'definitions'); definitions=s.definitions;
        c=cs{n}; intact=stage3_bio_load(cfg,n,1); inputLimit=5*max(1,intact.nativeComponentMax(5));
        ig=pop.late{n}{1}; nulls=cell(200,1);
        for direction=1:3
            rows=find(map.network==n & map.direction==direction); pass=[];
            for j=1:36
                row=rows(j); d=definitions{direction,j}; fB=-d.xB+m.W*max(d.xB,0)+m.h;
                b=fB-c.fStar+c.kappa0*(m.xstar-d.xB); imax=zeros(1,5);
                for state={repmat(m.spontaneous,1,8),d.xB,m.xstar}
                    x=state{1}; ci=-fB-c.kappa0*(x-d.xB); fb=-c.L*(x-m.xstar);
                    pieces={ci,b,fb,b+fb,ci+b+fb};
                    for k=1:5, imax(k)=max(imax(k),max(vecnorm(pieces{k}))); end
                end
                map.endpointInputMax(row)=max(imax);
                map.endpointBoundsOK(row)=map.endpointRateMax(row)<=ref.rateLimit ...
                    && map.endpointStateMax(row)<=ref.stateLimit && max(imax)<=inputLimit;
                map.prIntact(row)=ig.pr; map.kIntact(row)=ig.k;
                reasonLabels={'negative_rate','modulation_envelope','endpoint_bounds'};
                reasons=reasonLabels(~[map.rateRealizable(row),map.modulationOK(row),map.endpointBoundsOK(row)]);
                map.reason{row}=strjoin(reasons,';');
                if isempty(reasons), pass(end+1)=j; end %#ok<AGROW>
            end
            % Exclude the already computed primary; do not duplicate its replay.
            selected=pass;
            if direction==1, selected(selected==5)=[]; end
            path=fullfile(cfg.bioCache,sprintf('grid_n%02d_d%d.mat',n,direction));
            if isfile(path)
                s=load(path,'batch','selectedSaved'); batch=s.batch; assert(isequal(selected,s.selectedSaved));
            elseif ~isempty(selected)
                states=cellfun(@(d)d.xB,definitions(direction,selected),'UniformOutput',false);
                batch=stage3_bio_grid_prepare(m,cat(2,states{:}),c,intact.nativeStates);
                selectedSaved=selected; save(path,'batch','selectedSaved','-v7.3');
            end
            for j=pass
                row=rows(j); d=definitions{direction,j}; map.tested(row)=true;
                if direction==1 && j==5
                    p=stage3_bio_load(cfg,n,4); rates=p.rates(401:10:501,:,:);
                    % Same counterfactual component convention as the map screen.
                    x=reshape(p.nativeStates,200,[]); rep=2501;
                    fb=-c.L*(x-repmat(m.xstar,1,rep)); b=repmat(c.b,1,rep);
                    ci=-repmat(c.fB,1,rep)-c.kappa0*(x-repmat(d.xB,1,rep));
                    pieces={ci,b,fb,b+fb,ci+b+fb}; imax=zeros(1,5);
                    for k=1:5, imax(k)=max(max(vecnorm(pieces{k})),intact.nativeComponentMax(k)); end
                    rateMax=p.nativeRateMax; stateMax=p.nativeStateNormMax; settle=max(p.relativeSettle);
                else
                    index=find(selected==j); ix=(index-1)*8+(1:8);
                    rates=batch.lateRates(:,:,ix); imax=batch.inputMax(index,:);
                    rateMax=batch.rateMax(index); stateMax=batch.stateMax(index); settle=batch.relativeBlock(index);
                end
                g=stage3_geometry(rates,ref.scale); K=max(ig.k,g.k); denom=sum(ig.eigenvalues(1:K));
                obs=trace(g.basis(:,1:K).'*ig.covariance*g.basis(:,1:K))/denom;
                if isempty(nulls{K}), nulls{K}=stage2_null(ref.fullCov,ig.covariance,denom,K,cfg.nullDraws,cfg.nullSeedBase+n); end
                nv=nulls{K}; margin=mean(nv)-cfg.nullHoeffdingRadius-cfg.alignmentMargin-obs;
                worst=-Inf; radius=0;
                % Positive xB candidates share an active set; no gain selection.
                active=unique((d.xB>0).','rows');
                for a=1:size(active,1)
                    ev=eig((-(1+c.kappa0)*eye(200)+m.W.*active(a,:))/m.tau);
                    worst=max(worst,max(real(ev))); radius=max(radius,max(abs(1+m.dt*ev)));
                end
                vals=[settle rateMax stateMax imax g.pr g.k K ...
                    sum(ig.eigenvalues(1:K))/sum(ig.eigenvalues) sum(g.eigenvalues(1:K))/sum(g.eigenvalues) ...
                    g.gap obs mean(nv) std(nv)/sqrt(numel(nv)) mean(nv(1:5000))-mean(nv(5001:end)) margin worst radius];
                for k=1:numel(dynamic), map.(dynamic{k})(row)=vals(k); end
                map.physical(row)=rateMax<=ref.rateLimit && stateMax<=ref.stateLimit ...
                    && max(imax)<=inputLimit && worst<0 && radius<1;
                map.finitePhenotype(row)=g.pr>ig.pr+cfg.prMargin && margin>0;
                map.feasible(row)=map.analytical(row) && map.physical(row) && map.finitePhenotype(row);
                map.reason{row}='';
                if ~map.physical(row), map.reason{row}='dynamic_or_input_bounds;'; end
                if ~map.finitePhenotype(row), map.reason{row}=[map.reason{row} 'finite_geometry;']; end
                if ~map.analytical(row), map.reason{row}=[map.reason{row} 'outside_sufficient_bound;']; end
                if map.feasible(row), map.reason{row}='certified_feasible'; end
            end
            fprintf('Revised map network%02d direction%d: %d fixed points evaluated; %.1fs\n',n,direction,numel(pass),toc(started));
            assert(toc(started)<7200,'BioResume:Budget','Map two-hour bound');
        end
        save(fullfile(cfg.bioCache,sprintf('map_null_n%02d.mat',n)),'nulls','-v7');
    end
    unchanged={'network','direction','gridIndex','alpha','betaNormalized','beta','rho', ...
        'normalizedVarianceRatio','rawVarianceRatio','rateRealizable','modulationOK','analytical','analyticPRBlock','analyticAI'};
    for key=unchanged, assert(isequaln(map.(key{1}),oldMap.(key{1}))); end
    primary=map.direction==1 & map.gridIndex==5;
    writetable(map,destination);
    stage3_write_json(fullfile(cfg.bioRoot,'map_complete.json'),struct('rows',height(map),'tested',sum(map.tested), ...
        'physical',sum(map.physical),'feasible',sum(map.feasible),'empirical',sum(map.physical & map.finitePhenotype), ...
        'primaryPass',all(map.physical(primary) & map.finitePhenotype(primary)), ...
        'retiredCriterion','500-ms relative Block distance <=1e-4 only; distances remain saved','elapsedSeconds',toc(started)));
    assert(all(map.physical(primary) & map.finitePhenotype(primary)),'BioResume:MapPrimary','Retained primary map criterion failed');
end
