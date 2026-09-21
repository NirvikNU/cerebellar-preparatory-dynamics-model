function audit=paper95_grid_audit(root)
    old=fullfile(root,'results','paper_ready'); dest=fullfile(old,'alignment95');
    cache=fullfile(old,'cache','alignment95'); cfg=stage3_bio_paths(root);
    s=load(fullfile(dest,'geometry.mat'),'result'); g=s.result;
    s=load(fullfile(old,'geometry.mat'),'result'); original=s.result;
    assert(isequal(g.map.feasible,original.map.feasible) && isequal(g.map.tested,original.map.tested));
    assert(isequal(g.map.prIntact,original.map.prIntact) || isequaln(g.map.prIntact,original.map.prIntact));
    assert(isequaln(g.map.prBlock,original.map.prBlock) && g.lambda==10);
    assert(paper95_k([95;5])==1 && paper95_k([94;6])==2 && paper95_k([96;4])==1);
    % The Block threshold must not determine the retained projection dimension.
    ci=struct('k',1,'rank',2,'cov',diag([95 5]),'eigenvalues',[95;5],'basis',eye(2));
    cb=struct('k',2,'rank',2,'cov',diag([50 50]),'eigenvalues',[50;50],'basis',eye(2));
    [a,e,d,K]=paper95_compare(ci,cb,diag([1 0]));
    assert(a==1 && e==1 && d==95 && K==1);
    audit=struct('checks',4,'maxMetricError',0,'maxDenominatorError',0,'maxNullError',0,'predictionRun',false);
    for n=1:10
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); scale=s.ref.scale;
        s=load(fullfile(old,'cache',sprintf('grid_n%02d.mat',n)),'intact','blocks');
        ci=paper95_direct(s.intact.meanRates(401:10:501,:,:),scale);
        a=load(fullfile(cache,sprintf('alignment_n%02d.mat',n))); K=ci.k;
        assert(abs(trace(a.projectors{K})-K)<1e-9 && abs(trace(a.qrProjectors{K})-K)<1e-9);
        den=sum(ci.eigenvalues(1:K)); expected=trace(ci.cov*a.qrProjectors{K})/den;
        audit.maxNullError=max(audit.maxNullError,abs(expected-mean(a.nullValues)));
        for row=find(g.map.network==n & g.map.tested).'
            j=g.map.gridIndex(row); cb=paper95_direct(s.blocks{j}.meanRates(401:10:501,:,:),scale);
            B=cb.basis(:,1:K);
            observed=sum(var(ci.X*B,0,1))/den;
            errors=[ci.pr-g.map.prIntact(row),cb.pr-g.map.prBlock(row),observed-g.map.observed(row),expected-g.map.expected(row)];
            assert(K==g.map.kControl(row) && sum(ci.eigenvalues(1:K-1))/sum(ci.eigenvalues)<.95 ...
                && sum(ci.eigenvalues(1:K))/sum(ci.eigenvalues)>=.95);
            audit.maxMetricError=max(audit.maxMetricError,max(abs(errors)));
            audit.maxDenominatorError=max(audit.maxDenominatorError,abs(den-g.map.denominator(row)));
            audit.checks=audit.checks+9;
        end
    end
    loss=nan(36,1);
    for j=1:36
        rows=g.map.gridIndex==j;
        if all(g.map.tested(rows))
            effect=[median(g.map.prBlock(rows)-g.map.prIntact(rows)),median(g.map.expected(rows)-g.map.observed(rows))];
            target=[g.target.deltaPR g.target.alignmentDeficit];
            loss(j)=sum(((effect-target)./abs(target)).^2);
        end
    end
    assert(max(abs(loss(isfinite(loss))-g.loss(isfinite(loss))))<1e-12);
    best=min(loss(g.commonFeasible)); selected=find(g.commonFeasible & abs(loss-best)<=1e-12*max(1,abs(best)));
    assert(selected(1)==g.selectedIndex);
    assert(audit.maxMetricError<1e-9 && audit.maxDenominatorError<1e-9 && audit.maxNullError<1e-9);
    audit.status='PASS'; paper_json(fullfile(dest,'grid_audit.json'),audit); disp(audit);
end
