function audit = pe_primary_statistics(root)
    cfg=pe_paths(root); s=load(fullfile(cfg.dest,'primary.mat'),'summary'); r=s.summary;
    values={r.r2,reshape(r.matched,10,[]),r.chanceMedian,r.relativeChange};
    refs={r.bootstrap,r.matchedBootstrap,r.chanceBootstrap,r.relativeBootstrap};
    audit=struct('status','RUNNING','summaryError',0,'pairedError',0,'pError',0,'qError',0);
    for family=1:numel(values)
        v=values{family}; expected=refs{family};
        for p=1:size(v,2)
            draws=sort(reshape(v(r.indices,p),size(r.indices)),2); z=(draws(:,5)+draws(:,6))/2;
            se=sqrt(sum((z-mean(z)).^2)/(numel(z)-1)); sorted=sort(v(:,p)); med=(sorted(5)+sorted(6))/2;
            audit.summaryError=max(audit.summaryError,max(abs([med-expected.median(p),se-expected.se(p)])));
        end
    end
    signs=2*(dec2bin(0:1023,10)-'0')-1; pv=zeros(1,3);
    for p=2:4
        delta=r.r2(:,p)-r.r2(:,1); obs=abs(sum(delta)/10); null=abs(signs*delta/10);
        pv(p-1)=sum(null>=obs-1e-12*max(1,obs))/1024;
        draws=sort(reshape(delta(r.indices),size(r.indices)),2); z=(draws(:,5)+draws(:,6))/2;
        se=sqrt(sum((z-mean(z)).^2)/(numel(z)-1)); sorted=sort(delta); med=(sorted(5)+sorted(6))/2;
        t=r.tests{p-1}; audit.pairedError=max(audit.pairedError,max(abs([mean(delta)-t.meanDifference,med-t.medianDifference,se-t.medianDifferenceSE])));
    end
    [sorted,order]=sort(pv); qv=zeros(1,3); last=1;
    for j=3:-1:1, last=min(last,3*sorted(j)/j); qv(order(j))=last; end
    audit.pError=max(abs(pv-r.p)); audit.qError=max(abs(qv-r.q));
    assert(audit.summaryError<1e-10 && audit.pairedError<1e-10 && audit.pError==0 && audit.qError==0);
    audit.status='PASS'; paper_json(fullfile(cfg.dest,'primary_statistics_audit.json'),audit); disp(audit);
end
