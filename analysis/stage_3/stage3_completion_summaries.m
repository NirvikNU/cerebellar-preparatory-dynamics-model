function summary = stage3_completion_summaries(cfg)
    % Audited saved-data exports, including independently checked local Jacobians.
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); r=s.result;
    map=readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv'));
    policies=zeros(10,4,6);
    for n=1:10
        for p=1:4
            a=r.primary{n}.policies{p}; policies(n,p,:)=[a.stateError,a.pr,a.observed,a.expected,a.expected-a.observed,a.K];
        end
    end
    summary=struct('policyMedian',zeros(4,6),'policySE',zeros(4,6),'statistics',r.statistics, ...
        'stepCheck',r.stepCheck,'sensitivity',{r.sensitivity});
    for p=1:4
        stat=stage2_bootstrap(squeeze(policies(:,p,:)),r.bootstrapIndices);
        summary.policyMedian(p,:)=stat.median; summary.policySE(p,:)=stat.se;
    end
    summary.policyColumns={'stateError','PR','observed','expected','expectedMinusObserved','K'};
    samples=readtable(fullfile(cfg.resultsRoot,'recovery_audit','sampled_solutions.csv'));
    summary.nested=zeros(10,8);
    for n=1:10
        a=samples(samples.network==n,:);
        summary.nested(n,:)=[n,height(a),min(a.earlyErrorMM),max(a.earlyErrorMM),median(a.earlyErrorMM),min(a.PR),max(a.PR),sum(a.earlyErrorMM>mean(r.primary{n}.errorIntact))];
    end
    summary.nestedColumns={'network','uniqueSolutions','minimumEarlyMM','maximumEarlyMM','medianEarlyMM','minimumPR','maximumPR','largerErrorThanIntact'};
    summary.activityLimits=zeros(10,8); summary.localJacobianMaximumError=0;
    for n=1:10
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        grid=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',n)),'definitions');
        rows=map(map.network==n & map.tested,:);
        summary.activityLimits(n,:)=[n,min(ref.scale),max(ref.scale),ref.rateLimit,ref.stateLimit,ref.inputLimit,ref.rawTrace,ref.T];
        activeSets=containers.Map('KeyType','char','ValueType','any');
        for row=1:height(rows)
            d=grid.definitions{rows.direction(row),rows.gridIndex(row)}; localReal=-Inf; localEuler=0;
            for target=1:8
                mask=d.xB(:,target)>0; key=char('0'+mask.');
                if isKey(activeSets,key)
                    eigen=activeSets(key);
                else
                    J=(m.W*diag(double(mask))-(1+d.kappa)*eye(m.n))/m.tau;
                    eigen=eig(J); activeSets(key)=eigen;
                end
                localReal=max(localReal,max(real(eigen))); localEuler=max(localEuler,max(abs(1+cfg.dt*eigen)));
            end
            delta=max(abs([localReal localEuler]-[rows.localMaxReal(row) rows.localEulerRadius(row)]));
            summary.localJacobianMaximumError=max(summary.localJacobianMaximumError,delta);
            assert(delta<1e-9,'Completion:Stability','Saved local Jacobian summary mismatch.');
        end
    end
    summary.activityLimitColumns={'network','minSD','maxSD','rateLimit','stateLimit','inputLimit','rawSettledTrace','normalizedSettledTrace'};
    names={'rateMax','stateMax','corticalMax','sustainedMax','feedbackMax','cbMax','totalMax','settle','rawVarianceRatio','normalizedVarianceRatio'};
    summary.nativeRanges=struct();
    for j=1:numel(names)
        values=map.(names{j})(logical(map.tested)); summary.nativeRanges.(names{j})=[min(values),max(values)];
    end
    summary.maximumPRFiniteMinusSettled=max(abs(map.prBlock-map.analyticPRBlock),[],'omitnan');
    summary.maximumAIFiniteMinusSettled=max(abs(map.observed-map.analyticAI),[],'omitnan');
    summary.maxNullSE=max(map.nullSE,[],'omitnan'); summary.maxNullHalfDifference=max(abs(map.nullHalfDifference),[],'omitnan');
    summary.hoeffdingRadius=cfg.nullHoeffdingRadius;
    destination=fullfile(cfg.resultsRoot,'recovery_audit','summary.json'); assert(~isfile(destination));
    stage3_write_json(destination,summary);
end
