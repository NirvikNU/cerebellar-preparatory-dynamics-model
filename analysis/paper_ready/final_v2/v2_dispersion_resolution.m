function out=v2_dispersion_resolution(root)
    % Authorized conditional Panel E and descriptive unmatched robustness only.
    cfg=v2_paths(root); path=fullfile(cfg.dest,'dispersion_resolution.mat'); assert(~isfile(path));
    s=load(fullfile(cfg.dest,'figure_sources.mat'),'data'); d=s.data; r=d.summary;
    out.networks=[1 2 3 6 7 10]; out.excluded=[4 5 8 9]; out.seed=2026091000;
    assert(isequal(find(all(isfinite(r.dispersion),2)).',out.networks));
    stream=RandStream('mt19937ar','Seed',out.seed); out.indices=randi(stream,6,10000,6);
    stream=RandStream('mt19937ar','Seed',out.seed); assert(isequal(randi(stream,10,10000,10),r.indices));
    out.matchedCM=100*r.dispersion(out.networks,:); out.unmatchedCM=zeros(10,2);
    targetRows=zeros(160,5); k=0; maxError=0;
    T=readtable(fullfile(cfg.dest,'trial_metrics.csv'));
    for n=1:10
        for p=1:2
            policy=[1 4]; b=r.behavior{n}; values=zeros(8,1);
            for q=1:8
                rows=T.network==n & T.policy==policy(p) & T.s_init==.1 & T.s_temporal==.1 & T.target==q;
                xy=[T.peakPositionX_M(rows) T.peakPositionY_M(rows)]; assert(size(xy,1)==30);
                sorted=sort(xy,1); center=(sorted(15,:)+sorted(16,:))/2;
                values(q)=sum(sqrt(sum((xy-center).^2,2)))/30;
                maxError=max(maxError,abs(values(q)-b.unmatchedDispersion(q,p)));
                if b.count(q)>=5
                    ids=b.indices{q,p}-(q-1)*30; z=sort(xy(ids,:),1); m=numel(ids);
                    center=(z(floor((m+1)/2),:)+z(ceil((m+1)/2),:))/2;
                    value=sum(sqrt(sum((xy(ids,:)-center).^2,2)))/m;
                    maxError=max(maxError,abs(value-b.targetDispersion(q,p)));
                end
                k=k+1; targetRows(k,:)=[n q policy(p) 30 100*values(q)];
            end
            out.unmatchedCM(n,p)=100*sum(values)/8;
            maxError=max(maxError,abs(out.unmatchedCM(n,p)-100*b.unmatchedNetwork(p)));
        end
    end
    [out.matched,out.matchedDraws]=summarize(out.matchedCM,out.indices);
    [out.unmatched,out.unmatchedDraws]=summarize(out.unmatchedCM,r.indices);
    out.test=d.tests.dispersion; assert(out.test.n==6 && out.test.p==.03125);
    assert(abs(signrank(out.matchedCM(:,1),out.matchedCM(:,2))-.03125)<eps);
    out.label='Speed-matched hand-position dispersion; 6/10 networks met the prespecified matching criterion.';
    out.robustnessLabel='Unmatched all-10-network dispersion; descriptive robustness control, not the primary speed-matched assay';
    out.maxIndependentError=maxError; assert(maxError<1e-10); out.status='PASS';
    save(path,'out','-v7.3');
    v2_csv(fullfile(cfg.dest,'dispersion_matched_subset.csv'),{'network','IntactCM','BlockCM'},[out.networks.' out.matchedCM]);
    v2_csv(fullfile(cfg.dest,'dispersion_unmatched_all10.csv'),{'network','IntactCM','BlockCM'},[(1:10).' out.unmatchedCM]);
    v2_csv(fullfile(cfg.dest,'dispersion_unmatched_targets.csv'),{'network','target','policy','trials','dispersionCM'},targetRows);
    v2_csv(fullfile(cfg.dest,'dispersion_summary.csv'),{'matched','n','IntactMedianCM','IntactSECM','BlockMedianCM','BlockSECM'}, ...
        [1 6 out.matched.median(1) out.matched.se(1) out.matched.median(2) out.matched.se(2); ...
        0 10 out.unmatched.median(1) out.unmatched.se(1) out.unmatched.median(2) out.unmatched.se(2)]);
    receipt=rmfield(out,{'indices','matchedDraws','unmatchedDraws'}); paper_json(fullfile(cfg.dest,'dispersion_resolution.json'),receipt);
end

function [s,draws]=summarize(values,indices)
    draws=zeros(size(indices,1),2);
    for p=1:2
        v=values(:,p); draws(:,p)=median(reshape(v(indices),size(indices)),2);
    end
    s.median=median(values,1); s.se=std(draws,0,1);
    % Separate sorted order-statistic calculation and explicit sample variance.
    n=size(values,1); x=sort(values,1); med=(x(floor((n+1)/2),:)+x(ceil((n+1)/2),:))/2;
    check=zeros(size(draws));
    for b=1:size(indices,1)
        z=sort(values(indices(b,:),:),1); check(b,:)=(z(floor((n+1)/2),:)+z(ceil((n+1)/2),:))/2;
    end
    se=sqrt(sum((check-sum(check,1)/size(check,1)).^2,1)/(size(check,1)-1));
    assert(max(abs(med-s.median))<1e-12 && max(abs(se-s.se))<1e-12);
end
