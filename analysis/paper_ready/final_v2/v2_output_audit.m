function receipt=v2_output_audit(root)
    cfg=v2_paths(root); path=fullfile(cfg.dest,'output_audit.json'); assert(~isfile(path));
    s=load(fullfile(cfg.dest,'figure_sources.mat'),'data'); d=s.data; r=d.summary;
    N=readtable(fullfile(cfg.dest,'network_metrics.csv')); T=readtable(fullfile(cfg.dest,'trial_metrics.csv'));
    P=readtable(fullfile(cfg.dest,'paired_noise_effects.csv')); assert(height(N)==120 && height(T)==28800 && height(P)==50);
    receipt=struct('cases',0,'tableError',0,'statisticsError',0,'trajectoryChecks',0,'targetMeanChecks',0,'readinessChecks',0);
    for n=1:10
        for v=1:5
            ix=P.network==n & P.s_init==cfg.pairs(v,1) & P.s_temporal==cfg.pairs(v,2); assert(nnz(ix)==1);
            assert(isequaln(P.relativeR2LossPct(ix),r.lossPct(n,v)) && isequaln(P.deltaC(ix),r.deltaC(n,v)));
            policies=[1 4]; if v==2, policies=1:4; end
            for p=policies
                s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_v%d_p%d.mat',n,v,p)),'result'); z=s.result;
                ix=N.network==n & N.s_init==cfg.pairs(v,1) & N.s_temporal==cfg.pairs(v,2) & N.policy==p;
                tx=T.network==n & T.s_init==cfg.pairs(v,1) & T.s_temporal==cfg.pairs(v,2) & T.policy==p;
                assert(nnz(ix)==1 && nnz(tx)==240);
                assert(isequaln(N.C(ix),z.convergence.value) && isequaln(N.R2(ix),r.r2(n,v,p)));
                assert(isequaln(T.d_precue(tx),z.convergence.precue) && isequaln(T.d_prego(tx),z.convergence.prego));
                assert(isequaln(T.ratio(tx),z.convergence.ratio) && isequaln(T.C(tx),z.convergence.c));
                assert(isequaln(T.peakPositionX_M(tx),z.peakPosition(:,1)) && isequaln(T.peakPositionY_M(tx),z.peakPosition(:,2)));
                receipt.cases=receipt.cases+1;
            end
        end
    end
    for name={'dispersion','peakSpeed'}
        t=d.tests.(name{1}); values=t.difference; n=numel(values);
        if n<3, assert(isnan(t.p)); continue; end
        [reject,pAD]=adtest(values,'Alpha',.05); assert(reject==t.adReject && pAD==t.adP);
        if ~reject
            sigma=sqrt(sum((values-sum(values)/n).^2)/(n-1)); statistic=(sum(values)/n)/(sigma/sqrt(n));
            p=2*tcdf(-abs(statistic),n-1); assert(strcmp(t.test,'two-sided paired t'));
        else
            values=values(values~=0); n=numel(values); absolute=abs(values); ranks=zeros(n,1);
            for j=1:n, ranks(j)=sum(absolute<absolute(j))+(sum(absolute==absolute(j))+1)/2; end
            observed=sum(ranks(values>0)); sums=zeros(2^n,1);
            for j=1:n, sums=sums+double(bitget(uint32((0:2^n-1).'),j))*ranks(j); end
            p=min(1,2*min(mean(sums<=observed),mean(sums>=observed))); assert(strcmp(t.test,'two-sided Wilcoxon signed-rank'));
        end
        receipt.statisticsError=max(receipt.statisticsError,abs(p-t.p));
    end
    for n=1:10
        for j=1:8
            for q=1:8
                curve=d.readinessCurves(:,q,j,n); valid=false(501,1);
                for ms=0:500, valid(ms+1)=all(curve(ms*5+1:end)<=.1); end
                first=find(valid,1); value=NaN; if ~isempty(first), value=first-1; end
                assert(isequaln(value,d.readiness.readiness(n,j,q))); receipt.readinessChecks=receipt.readinessChecks+1;
            end
        end
    end
    figPath=fullfile(root,'plots','paper_ready','final_v2','main','fig','MainFig_Modelling_v2.fig');
    f=openfig(figPath,'invisible'); closer=onCleanup(@()close(f)); objects=findall(f,'-property','UserData');
    origin=d.representative{1}.hand(1,[1 3],1);
    for h=objects.'
        u=h.UserData; if ~isstruct(u)||~isfield(u,'kind'), continue; end
        if strcmp(u.kind,'trajectory')||strcmp(u.kind,'targetMean')
            raw=d.representative{u.condition}.hand;
            if strcmp(u.kind,'trajectory')
                q=ceil(u.trial/30); xy=reshape(raw(:,[1 3],u.trial),[],2)-origin; receipt.trajectoryChecks=receipt.trajectoryChecks+1;
            else
                q=u.target; xy=sum(raw(:,[1 3],(q-1)*30+(1:30)),3)/30-origin; receipt.targetMeanChecks=receipt.targetMeanChecks+1;
            end
            inside=sum((xy-d.targetXY(q,:)).^2,2)<=.015^2; first=find(inside,1);
            if isempty(first), first=size(xy,1); end
            assert(first==u.stop && numel(h.XData)==first);
            assert(max(abs(h.XData(:)-100*xy(1:first,1)))<1e-10 && max(abs(h.YData(:)-100*xy(1:first,2)))<1e-10);
        end
    end
    assert(receipt.cases==120 && receipt.statisticsError<1e-10 && receipt.readinessChecks==640);
    assert(receipt.trajectoryChecks==480 && receipt.targetMeanChecks==16);
    receipt.status='PASS'; receipt.fullPrecisionRoundTrip=true; receipt.displayTruncationOnly=true;
    paper_json(path,receipt);
end
