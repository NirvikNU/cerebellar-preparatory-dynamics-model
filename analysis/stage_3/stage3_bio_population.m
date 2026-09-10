function result = stage3_bio_population
    % Actual finite-time trajectories, frozen neuron SD and frozen null bias.
    cfg=stage3_bio_paths; target=fullfile(cfg.bioRoot,'population.mat'); assert(~isfile(target));
    assert(isfile(fullfile(cfg.bioRoot,'preparation_complete.json')));
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); indices=s.result.bootstrapIndices;
    result=struct('policyNames',{cfg.policyNames},'endpointGO',-600:10:0, ...
        'dimensionOrder','network,policy,endpoint','bootstrapIndices',indices,'late',{{}});
    fields={'distanceStar','distanceBlock','normalizedEQ','pr','observed','expected','deficit','K','referenceK','policyK','referenceCapture','policyCapture'};
    for j=1:numel(fields), result.(fields{j})=nan(10,4,61); end
    result.fullTimeGO=-600:0;
    result.fullDistanceStar=zeros(10,4,601); result.fullDistanceBlock=zeros(10,4,601);
    result.fullNormalizedEQ=zeros(10,4,601);
    primaryRows=cell(10,1); nullValues=cell(10,1); started=tic;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.cacheRoot,'gain_time','refined',sprintf('baseline_n%02d.mat',n)),'baseline'); baseline=s.baseline;
        s=load(fullfile(cfg.cacheRoot,'gain_time',sprintf('null_n%02d.mat',n)),'nullEvidence'); nulls=s.nullEvidence;
        assert(isequal(nulls.fullCov,ref.fullCov) && nulls.draws==cfg.nullDraws && nulls.seed==cfg.nullSeedBase+n);
        newNull=false; preRates=repmat(max(baseline.states(1:200,:),0),1,1,8);
        igs=cell(61,1); late=cell(4,1);
        for policy=1:4
            p=stage3_bio_load(cfg,n,policy);
            assert(isequal(squeeze(p.states(1,:,:)),repmat(m.spontaneous,1,8)));
            rates=cat(1,preRates,p.rates);
            distances=mean(p.distanceStar,2); blocks=mean(p.distanceBlock,2);
            eq=mean(p.normalizedProspective,2);
            result.fullDistanceStar(n,policy,:)=[repmat(distances(1),100,1);distances];
            result.fullDistanceBlock(n,policy,:)=[repmat(blocks(1),100,1);blocks];
            result.fullNormalizedEQ(n,policy,:)=[ones(100,1);eq];
            for t=1:61
                endpoint=result.endpointGO(t); ix=701+endpoint+(-100:10:0);
                result.distanceStar(n,policy,t)=result.fullDistanceStar(n,policy,601+endpoint);
                result.distanceBlock(n,policy,t)=result.fullDistanceBlock(n,policy,601+endpoint);
                result.normalizedEQ(n,policy,t)=result.fullNormalizedEQ(n,policy,601+endpoint);
                if endpoint<=-500
                    assert(all(rates(ix,:,:)==rates(ix,:,1),'all')); continue;
                end
                g=stage3_geometry(rates(ix,:,:),ref.scale);
                if policy==1, igs{t}=g; end
                ig=igs{t}; K=max(ig.k,g.k); denominator=sum(ig.eigenvalues(1:K));
                B=g.basis(:,1:K); observed=trace(B.'*ig.covariance*B)/denominator;
                if K>numel(nulls.projectors) || isempty(nulls.projectors{K})
                    [nulls.projectors{K},nulls.qrProjectors{K}]=stage3_bio_projector(ref.fullCov,K,cfg.nullDraws,cfg.nullSeedBase+n);
                    newNull=true;
                end
                expected=trace(ig.covariance*nulls.projectors{K})/denominator;
                independent=trace(ig.covariance*nulls.qrProjectors{K})/denominator;
                assert(abs(expected-independent)<1e-10);
                vals=[g.pr,observed,expected,expected-observed,K,ig.k,g.k, ...
                    sum(ig.eigenvalues(1:K))/sum(ig.eigenvalues),sum(g.eigenvalues(1:K))/sum(g.eigenvalues)];
                for j=4:numel(fields), result.(fields{j})(n,policy,t)=vals(j-3); end
                if t==61, late{policy}=g; end
            end
        end
        if newNull, save(fullfile(cfg.bioCache,sprintf('null_n%02d.mat',n)),'nulls','-v7.3'); end
        K=result.K(n,4,end); denom=sum(late{1}.eigenvalues(1:K));
        nv=stage2_null(ref.fullCov,late{1}.covariance,denom,K,cfg.nullDraws,cfg.nullSeedBase+n);
        assert(abs(mean(nv)-result.expected(n,4,end))<1e-10);
        nullValues{n}=nv; result.late{n}=late;
        deltaPR=result.pr(n,4,end)-result.pr(n,1,end);
        margin=result.deficit(n,4,end)-cfg.nullHoeffdingRadius-cfg.alignmentMargin;
        primaryRows{n}=table(n,result.pr(n,1,end),result.pr(n,4,end),result.observed(n,4,end), ...
            result.expected(n,4,end),K,result.referenceK(n,4,end),result.policyK(n,4,end), ...
            deltaPR,margin,std(nv)/sqrt(numel(nv)),mean(nv(1:5000))-mean(nv(5001:end)), ...
            deltaPR>cfg.prMargin && margin>0, ...
            'VariableNames',{'network','prIntact','prBlock','observed','expected','K','intactK','blockK', ...
            'deltaPR','conservativeAlignmentMargin','nullSE','nullHalfDifference','finitePhenotype'});
        fprintf('Population network %02d complete (actual trajectories, frozen scaling/null); %.1fs\n',n,toc(started));
    end
    result.primaryTable=vertcat(primaryRows{:}); result.nullValues=nullValues;
    result.primaryPass=all(result.primaryTable.finitePhenotype);
    for j=1:numel(fields), result.summary.(fields{j})=stage2_bootstrap(result.(fields{j}),indices); end
    for name={'fullDistanceStar','fullDistanceBlock','fullNormalizedEQ'}
        result.summary.(name{1})=stage2_bootstrap(result.(name{1}),indices);
    end
    save(target,'result','-v7.3'); writetable(result.primaryTable,fullfile(cfg.bioRoot,'primary_population.csv'));
    stage3_write_json(fullfile(cfg.bioRoot,'population_complete.json'),struct('primaryPass',result.primaryPass, ...
        'networkCount',10,'policyCount',4,'elapsedSeconds',toc(started),'preCueMask','All population endpoints <= -500 undefined'));
    assert(result.primaryPass,'BioResume:Phenotype','Primary population phenotype failed; do not retune');
end
