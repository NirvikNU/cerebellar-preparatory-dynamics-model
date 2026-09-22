function report = pe_report(root)
    cfg=pe_paths(root); s=load(fullfile(cfg.dest,'primary.mat'),'summary'); a=s.summary;
    s=load(fullfile(cfg.dest,'rrr.mat'),'summary'); b=s.summary;
    report=struct('status','PASS','primary',rmfield(a,'indices'),'rrr',rmfield(b,'indices'));
    report.recovery=jsondecode(fileread(fullfile(cfg.dest,'recovery.json')));
    report.seriesAudit=jsondecode(fileread(fullfile(cfg.dest,'series_audit.json')));
    assert(strcmp(report.recovery.status,'PASS') && strcmp(report.seriesAudit.status,'PASS'));
    families={a.r2,b.rank,b.peak}; reference={a.bootstrap,b.rankBootstrap,b.peakBootstrap};
    ps={a.p,b.p(1,:),b.p(2,:)}; qs={a.q,b.q(1,:),b.q(2,:)};
    audit=struct('bootstrapMaxError',0,'pairedSummaryError',0,'pMaxError',0,'qMaxError',0,'status','RUNNING');
    signs=2*(dec2bin(0:1023,10)-'0')-1;
    for family=1:3
        v=families{family}; med=zeros(1,4); se=zeros(1,4);
        for p=1:4
            draws=sort(reshape(v(a.indices,p),size(a.indices)),2);
            z=(draws(:,5)+draws(:,6))/2; se(p)=sqrt(sum((z-mean(z)).^2)/(numel(z)-1));
            z=sort(v(:,p)); med(p)=(z(5)+z(6))/2;
        end
        audit.bootstrapMaxError=max(audit.bootstrapMaxError,max(abs([med-reference{family}.median,se-reference{family}.se])));
        pv=zeros(1,3);
        for p=2:4
            delta=v(:,p)-v(:,1); obs=abs(sum(delta)/10); null=abs(signs*delta/10);
            pv(p-1)=sum(null>=obs-1e-12*max(1,obs))/1024;
            draws=sort(reshape(delta(a.indices),size(a.indices)),2); z=(draws(:,5)+draws(:,6))/2;
            se=sqrt(sum((z-mean(z)).^2)/(numel(z)-1)); ordered=sort(delta); med=(ordered(5)+ordered(6))/2;
            if family==1, t=a.tests{p-1}; else, t=b.tests{family-1,p-1}; end
            audit.pairedSummaryError=max(audit.pairedSummaryError,max(abs([mean(delta)-t.meanDifference,med-t.medianDifference,se-t.medianDifferenceSE])));
        end
        [sorted,order]=sort(pv); qv=zeros(1,3); last=1;
        for j=3:-1:1, last=min(last,3*sorted(j)/j); qv(order(j))=last; end
        audit.pMaxError=max(audit.pMaxError,max(abs(pv-ps{family})));
        audit.qMaxError=max(audit.qMaxError,max(abs(qv-qs{family})));
    end
    controls={reshape(a.matched,10,[]),a.chanceMedian,a.relativeChange,b.shuffleMedian};
    controlReferences={a.matchedBootstrap,a.chanceBootstrap,a.relativeBootstrap,b.shuffleBootstrap};
    for family=1:numel(controls)
        v=controls{family}; expected=controlReferences{family};
        for p=1:size(v,2)
            draws=sort(reshape(v(a.indices,p),size(a.indices)),2); z=(draws(:,5)+draws(:,6))/2;
            se=sqrt(sum((z-mean(z)).^2)/(numel(z)-1)); sorted=sort(v(:,p)); med=(sorted(5)+sorted(6))/2;
            audit.bootstrapMaxError=max(audit.bootstrapMaxError,max(abs([med-expected.median(p),se-expected.se(p)])));
        end
    end
    assert(audit.bootstrapMaxError<1e-10 && audit.pairedSummaryError<1e-10 && audit.pMaxError==0 && audit.qMaxError==0);
    audit.status='PASS'; report.statisticsAudit=audit;
    paper_json(fullfile(cfg.dest,'statistics_audit.json'),audit); paper_json(fullfile(cfg.dest,'REPORT.json'),report);
    network=repelem((1:10)',4); policy=repmat((1:4)',10,1);
    reshapePolicy=@(v)reshape(v.',[],1);
    rows=table(network,policy,reshapePolicy(a.r2),reshapePolicy(a.chanceMedian),reshapePolicy(a.K(:,:,1)), ...
        reshapePolicy(a.K(:,:,2)),reshapePolicy(a.capture(:,:,1)),reshapePolicy(a.capture(:,:,2)), ...
        reshapePolicy(b.rank),reshapePolicy(b.peak),reshapePolicy(b.shuffleMedian), ...
        'VariableNames',{'network','policy','primaryR2','shuffleR2','prepK','moveK','prepCapture','moveCapture','predictiveRank','peakR2','shuffledPeakR2'});
    writetable(rows,fullfile(cfg.dest,'network_results.csv'));
    path=fullfile(root,'docs','paper_ready','prediction','RESULTS.md'); assert(~isfile(path));
    fid=fopen(path,'w'); guard=onCleanup(@()fclose(fid));
    fprintf(fid,'# Panel e and full-space RRR — scientific review\n\n');
    fprintf(fid,'Frozen checkpoint: 70fff703f8fd3074bef62ca9954a03bef50e4d99. No tuning.\n');
    fprintf(fid,'Ten independent networks; 30 trials per target, eight targets; all four policies retained.\n');
    fprintf(fid,'Gaussian SD30ms analysis only; geometry remains unsmoothed and unchanged.\n');
    fprintf(fid,'Full-ensemble PCA follows the manuscript, not strictly inductive fold-wise feature estimation.\n');
    fprintf(fid,'No post-GO noise, correction or reset. No trial exclusions for prior kinematic QC flags.\n\n');
    names={'Intact','Remove feedback','Remove b','Block'};
    fprintf(fid,'## Network medians +/- whole-network bootstrap SE\n\n');
    fprintf(fid,'| Policy | PCA-ridge R2 | Shuffle floor | RRR predictive rank | RRR peak R2 | RRR shuffled peak |\n|---|---:|---:|---:|---:|---:|\n');
    for p=1:4
        fprintf(fid,'| %s | %.9g +/- %.9g | %.9g +/- %.9g | %.9g +/- %.9g | %.9g +/- %.9g | %.9g +/- %.9g |\n',names{p}, ...
            a.bootstrap.median(p),a.bootstrap.se(p),a.chanceBootstrap.median(p),a.chanceBootstrap.se(p), ...
            b.rankBootstrap.median(p),b.rankBootstrap.se(p),b.peakBootstrap.median(p),b.peakBootstrap.se(p),b.shuffleBootstrap.median(p),b.shuffleBootstrap.se(p));
    end
    fprintf(fid,'\nPaired Block-versus-Intact relative primary R2 change: %.9g +/- %.9g percent.\n',a.relativeBootstrap.median,a.relativeBootstrap.se);
    fprintf(fid,'Empirical reductions43.6%% (N),29.6%% (T) are descriptive context, not targets fitted here.\n\n');
    fprintf(fid,'## Exact paired tests\n\n| Outcome | Contrast minus Intact | Mean difference | Median difference +/- SE | p | BH q |\n|---|---|---:|---:|---:|---:|\n');
    outcomes={'Primary R2','RRR rank','RRR peak R2'};
    for family=1:3
        for j=1:3
            if family==1, t=a.tests{j}; else, t=b.tests{family-1,j}; end
            fprintf(fid,'| %s | %s | %.9g | %.9g +/- %.9g | %.9g | %.9g |\n',outcomes{family},names{j+1}, ...
                t.meanDifference,t.medianDifference,t.medianDifferenceSE,ps{family}(j),qs{family}(j));
        end
    end
    fprintf(fid,'\nEach outcome has its own three-contrast BH family; exact1024 sign flips of mean paired difference.\n');
    fprintf(fid,'The same frozen10000 whole-network bootstrap rows determine all displayed network-median SEs.\n\n');
    fprintf(fid,'## All-network primary and RRR values\n\n| Network | Policy | Primary R2 | Prep K (capture) | Move K (capture) | RRR rank | Peak R2 | Shuffle peak |\n|---|---|---:|---:|---:|---:|---:|---:|\n');
    for n=1:10
        for p=1:4
            fprintf(fid,'| %d | %s | %.9g | %d (%.6f) | %d (%.6f) | %.9g | %.9g | %.9g |\n',n,names{p},a.r2(n,p),a.K(n,p,1),a.capture(n,p,1),a.K(n,p,2),a.capture(n,p,2),b.rank(n,p),b.peak(n,p),b.shuffleMedian(n,p));
        end
    end
    fprintf(fid,'\n## Matched-PC control\n\n| Network | Contrast | Prep K | Move K | Intact R2 | Comparator R2 |\n|---|---|---:|---:|---:|---:|\n');
    for n=1:10
        for j=1:3
            fprintf(fid,'| %d | %s | %d | %d | %.9g | %.9g |\n',n,names{j+1},a.matchedK(n,j,1),a.matchedK(n,j,2),a.matched(n,j,1),a.matched(n,j,2));
        end
    end
    fprintf(fid,'\n## Validation scope and interpretation boundaries\n\n');
    fprintf(fid,'Recovery independently checks original saved states/rates/torques/transitions; no arm/event rerun or reselection.\n');
    fprintf(fid,'All40 network/policy cases: maximum absolute fidelity discrepancy %.9g. Ten complete Intact preparations reused,30 missing preparation series recovered,40 missing neural movement series recovered. Original hand trajectories/events reused.\n',max(report.recovery.errors,[],'all'));
    fprintf(fid,'All40 Prep-GO/movement-start joins, frozen reference scales, original trial seeds, policy flags, fixed geometry and onset-window identities independently verified.\n');
    fprintf(fid,'Primary audit directly recomputes all40 observed,4000 shuffled and60 matched fits and all selected penalties, pooled predictions and R2; covariance/eigen PCA threshold audit, fixed split/seed checks and neuron-wise feature spot checks.\n');
    fprintf(fid,'RRR audit uses augmented QR independent of production SVD: all400 observed repeated nested searches and explicit held-out rank predictions, plus40 predeclared shuffle/repeat refits. All40000 remaining shuffle-search repeat summaries/selected penalties and rank/peak criteria checked from saved search arrays. This is not an independent rerun of every shuffled fit.\n');
    fprintf(fid,'Do not interpret full-ensemble or target-pooled prediction as within-target-only prediction.\n');
    fprintf(fid,'Irregular Block kinematics and trial-specific movement alignment remain potential interpretive limitations, not criteria for exclusion.\n');
    fprintf(fid,'No behavioral prediction, speed axis, movement-end prediction, adaptation, target-jump, extra RRR variant, noise or geometry tuning.\n');
    fprintf(fid,'All old artifacts remain protected; no staging, commit or push. Stop for scientific review.\n');
    clear guard
end
