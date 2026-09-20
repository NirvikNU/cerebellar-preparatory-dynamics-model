function result = paper_controls(root)
    addpath(fullfile(root,'analysis','stage_3')); cfg=stage3_bio_paths(root);
    dest=fullfile(root,'results','paper_ready'); cache=fullfile(dest,'cache');
    s=load(fullfile(dest,'geometry.mat'),'result'); grid=s.result;
    assert(strcmp(grid.status,'GEOMETRY_PASS') && ~isfile(fullfile(dest,'controls.mat')));
    result.levels=[0 .05 .1 .2 .4]; result.lambda=grid.lambda; result.gridIndex=grid.selectedIndex;
    result.noise=nan(10,2,5,6); result.policy=nan(10,4,10);
    result.time=nan(10,4,51,5); result.nativeBounds=nan(10,4,4);
    result.QC=cell(10,4); result.reliability=nan(10,4,6);
    result.noiseBounds=nan(10,2,5,5);
    result.policyNames=cfg.policyNames; result.timeGO=-500:10:0;
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); result.indices=s.result.bootstrapIndices;
    started=tic;
    for n=1:10
        path=fullfile(cache,sprintf('controls_n%02d.mat',n)); assert(~isfile(path));
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cache,sprintf('grid_n%02d.mat',n))); c=s.c; d=s.definitions{grid.selectedIndex};
        policies=cell(1,4); policies{1}=s.intact; policies{4}=s.blocks{grid.selectedIndex};
        policies{1}.componentMax=s.intactComponents(grid.selectedIndex,:);
        policies{1}.counterfactualMax=policies{1}.componentMax;
        for t=1:501
            x=squeeze(policies{1}.states(t,:,:));
            policies{1}.distanceBlock(t,:)=mean(reshape(vecnorm(x-d.xB(:,repelem(1:8,30))),30,8),1);
        end
        % Complete raw intact evidence already lives in the grid cache, no duplicate.
        policies{1}.nativeStates=[]; policies{1}.states=[];
        projectors=s.projectors; qrProjectors=s.qrProjectors;
        noise=paper_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
        for p=2:3, policies{p}=paper_prepare(m,{d},c,cfg.policyFlags(p,:),.1,.1,noise); end
        ig=paper_geometry(policies{1}.meanRates(401:10:501,:,:),ref.scale);
        levels=cell(2,5); moves=cell(1,4); inputLimit=5*max(1,policies{1}.componentMax(5));
        for p=1:4
            prep=policies{p}; g=paper_geometry(prep.meanRates(401:10:501,:,:),ref.scale);
            [ob,ex]=compare(ig,g,projectors{15},15);
            moves{p}=paper_move(m,prep.go); move=moves{p};
            result.policy(n,p,:)=[g.pr ob ex ex-ob residual(prep.lateRates,ref.scale), ...
                mean(move.endpointRmsByTarget)*1000,median(move.moMs),median(move.peakMs),median(move.peak),move.targetSeparationToScatter];
            result.nativeBounds(n,p,:)=[prep.rateMax prep.stateMax max(prep.componentMax) inputLimit];
            result.QC{n,p}=struct('nearZero',sum(move.nearZero),'boundaryPeak',sum(move.boundaryPeak), ...
                'missingWindow',sum(move.missingWindow),'multiPeak',sum(move.multiPeakCount>=2), ...
                'finite',all(isfinite(move.hand),'all'),'prepBounds',prep.rateMax<=ref.rateLimit && prep.stateMax<=ref.stateLimit && max(prep.componentMax)<=inputLimit, ...
                'movementRateMax',move.rateMax,'movementStateMax',move.stateMax);
            % Fixed split descriptive reliability; no split chosen for fit.
            halves=cell(1,2);
            for h=1:2
                ix=[]; for q=1:8, ix=[ix (q-1)*30+(h-1)*15+(1:15)]; end %#ok<AGROW>
                rr=reshape(prep.lateRates(:,:,ix),11,200,15,8);
                halves{h}=paper_geometry(squeeze(mean(rr,3)),ref.scale);
            end
            [halfObserved,halfExpected]=compare(halves{1},halves{2},projectors{15},15);
            result.reliability(n,p,:)=[halves{1}.pr halves{2}.pr halves{1}.capture15 halves{2}.capture15 halfObserved halfExpected];
            for t=1:51
                endSample=(t-1)*10+1;
                rr=prep.meanRates(max(1,endSample-100):10:endSample,:,:);
                if size(rr,1)<11
                    rr=cat(1,repmat(repmat(max(m.spontaneous,0).',1,1,8),11-size(rr,1),1,1),rr);
                end
                rI=policies{1}.meanRates(max(1,endSample-100):10:endSample,:,:);
                if size(rI,1)<11
                    rI=cat(1,repmat(repmat(max(m.spontaneous,0).',1,1,8),11-size(rI,1),1,1),rI);
                end
                qg=paper_geometry(rr,ref.scale); qi=paper_geometry(rI,ref.scale);
                [a,e]=compare(qi,qg,projectors{15},15);
                result.time(n,p,t,:)=[mean(prep.distanceStar(endSample,:)),mean(prep.distanceBlock(endSample,:)), ...
                    mean(prep.eq(endSample,:)./prep.eq(1,:)),qg.pr,e-a];
            end
        end
        for kind=1:2
            for k=1:5
                level=result.levels(k); si=.1; st=.1;
                if kind==1, si=level; else, st=level; end
                if level==.1, p=policies{1}; else, p=paper_prepare(m,{d},c,[1 1],si,st,noise); end
                levels{kind,k}=p; g=paper_geometry(p.meanRates(401:10:501,:,:),ref.scale);
                [ob,ex]=compare(ig,g,projectors{15},15);
                result.noise(n,kind,k,:)=[g.pr ob ex ex-ob residual(p.lateRates,ref.scale) residual(p.lateRates,ones(200,1))];
                result.noiseBounds(n,kind,k,:)=[p.rateMax p.stateMax max(p.componentMax) ...
                    p.rateMax<=ref.rateLimit && p.stateMax<=ref.stateLimit && max(p.componentMax)<=inputLimit g.rank];
                assert(all(isfinite(p.go),'all'));
            end
        end
        save(path,'policies','moves','levels','projectors','qrProjectors','c','d','-v7.3');
        fprintf('Controls/movement network%02d complete %.1fs\n',n,toc(started));
    end
    result.summary.noise=stage2_bootstrap(result.noise,result.indices);
    result.summary.policy=stage2_bootstrap(result.policy,result.indices);
    result.summary.time=stage2_bootstrap(result.time,result.indices);
    result.status='GENERATED_NOT_YET_INDEPENDENTLY_VALIDATED'; result.predictionRun=false;
    save(fullfile(dest,'controls.mat'),'result','-v7.3');
    paper_json(fullfile(dest,'controls.json'),rmfield(result,'indices'));
end

function [observed,expected]=compare(ig,g,P,K)
    den=sum(ig.eigenvalues(1:K)); B=g.basis(:,1:K);
    observed=trace(B.'*ig.cov*B)/den; expected=trace(ig.cov*P)/den;
end

function v=residual(rates,scale)
    r=reshape(rates,11,200,30,8)./reshape(scale,1,200,1,1);
    v=mean(var(r,0,3),'all');
end
