function v2_report(root)
    cfg=v2_paths(root); path=fullfile(cfg.docs,'REPORT.md'); assert(~isfile(path));
    s=load(fullfile(cfg.dest,'figure_sources.mat'),'data'); d=s.data; r=d.summary; selection=d.selection;
    audit=jsondecode(fileread(fullfile(cfg.dest,'audit.json'))); assert(strcmp(audit.status,'PASS'));
    fid=fopen(path,'w'); assert(fid>0); closer=onCleanup(@()fclose(fid));
    fprintf(fid,'# Final parsimonious paper model v2 — numerical report\n\n');
    fprintf(fid,'Numerical assays audited. Figure visual inspection, preservation, Notion publication and release are separate gates; see completion receipt.\n\n');
    fprintf(fid,'## Frozen shared structural calibration\n\n');
    fprintf(fid,'Eta=0, lambda=10, V1, primary noise0.10/0.10. One shared alpha=%.17g, beta_norm=%.17g for all ten networks; grid index%d.\n\n',selection.alpha,selection.betaNormalized,selection.gridIndex);
    fprintf(fid,'All36 candidates scored in all10 networks. Only network-median paired DeltaPR and alignment deficit entered loss; no QC/behavior/convergence/R2 screen. The selected receipt predates downstream simulation.\n\n');
    fprintf(fid,'| Calibration quantity | Model median | Empirical target |\n|---|---:|---:|\n| Block-Intact PR | %.12g | %.12g |\n| Expected-observed (pp) | %.12g | %.12g |\n\nLoss=%.17g. Exact ties were checked; no network-specific fit.\n\n',selection.deltaPR,selection.targets(1),selection.deficitPP,selection.targets(2),selection.loss);
    fprintf(fid,'Only the two paired effects were calibrated, not absolute condition means. The unique winner is a minimum over this fixed grid, not a continuous optimum. Beta is at the upper tested boundary; the grid was not expanded. An independent PowerShell CSV/order-statistics audit agrees with the frozen selection.\n\n');
    fprintf(fid,'All 360 candidate/network geometries were independently checked by neuron-column covariance/eigendecomposition and the separate QR null. Maximum native-transition discrepancy=%.17g; maximum geometry/null discrepancy=%.17g. Intact-derived minimum-95%% K spans %d to %d.\n\n',max(d.geometry.auditErrors(:,1)),max(d.geometry.auditErrors(:,2)),min(d.geometry.map.kControl),max(d.geometry.map.kControl));
    fprintf(fid,'## Primary conditions and functional components\n\n');
    fprintf(fid,'| Policy | PR | Alignment deficit (pp) | Corrected C | PCA75-ridge R2 |\n|---|---:|---:|---:|---:|\n');
    for p=1:4
        fields={'pr','deficit','convergence','r2'}; values=zeros(1,8);
        for j=1:4, b=stage2_bootstrap(r.(fields{j})(:,2,p),r.indices); values(2*j-1:2*j)=[b.median b.se]; end
        fprintf(fid,'| %s | %.8g +/- %.8g | %.8g +/- %.8g | %.8g +/- %.8g | %.8g +/- %.8g |\n',r.names{p},values);
    end
    fprintf(fid,'\nNetwork n=10, median +/- bootstrap SE; no component selected from these descriptive outcomes. Calibration agreement is not independent validation.\n\n');
    fprintf(fid,'## Noise effects, all prespecified points\n\n');
    fprintf(fid,'| s_init | s_temporal | Intact R2 | Block R2 | Relative Block R2 loss (%%) | Intact C | Block C | Block-Intact C |\n|---:|---:|---:|---:|---:|---:|---:|---:|\n');
    for v=1:5
        values=[r.r2(:,v,1) r.r2(:,v,4) r.lossPct(:,v) r.convergence(:,v,1) r.convergence(:,v,4) r.deltaC(:,v)];
        b=stage2_bootstrap(values,r.indices); numbers=reshape([b.median;b.se],1,[]);
        fprintf(fid,'| %.2f | %.2f | %.8g +/- %.8g | %.8g +/- %.8g | %.8g +/- %.8g | %.8g +/- %.8g | %.8g +/- %.8g | %.8g +/- %.8g |\n',cfg.pairs(v,:),numbers);
    end
    fprintf(fid,'\nNo noise point selected. No new testing family for these sensitivity curves. Undefined relative losses=%d/50; undefined convergence trial counts=%d. Distances/ratios/K/capture are retained in trial_metrics.csv.\n\n',sum(~isfinite(r.lossPct),'all'),sum(r.undefined(isfinite(r.undefined))));
    fprintf(fid,'The corrected baseline is one stochastic pre-cue state, not the historical post-cue window. It changes the estimand; historical C results remain intact. Changing initial noise changes d_precue, so C is not alone evidence of stability or mediation.\n\n');
    fprintf(fid,'## Behavior and movement QC\n\n');
    for name={'dispersion','peakSpeed'}
        t=d.tests.(name{1}); fprintf(fid,'- %s: %s; paired network n=%d; exact p=%.17g; Anderson-Darling p=%.17g.\n',name{1},t.test,t.n,t.p,t.adP);
    end
    fprintf(fid,'\n| Network | Matched pairs by target | Eligible targets | Intact dispersion (cm) | Block dispersion (cm) |\n|---:|---|---:|---:|---:|\n');
    for n=1:10
        b=r.behavior{n}; fprintf(fid,'| %d | %s | %d | %.10g | %.10g |\n',n,strtrim(sprintf('%d ',b.count)),numel(b.validTargets),100*b.network);
    end
    fprintf(fid,'\n| Noise pair | Condition | Near-zero / missing / boundary / multi-peak trials | Endpoint RMS median (cm) | Separation/scatter median |\n|---|---|---|---:|---:|\n');
    for v=1:5
        for p=[1 4]
            counts=zeros(1,4);
            for n=1:10, q=r.qc{n,v,p}; counts=counts+[q.nearZero q.missingWindow q.boundaryPeak q.multiPeak]; end
            fprintf(fid,'| %.2f/%.2f | %s | %d / %d / %d / %d | %.10g | %.10g |\n',cfg.pairs(v,:),r.names{p},counts,100*median(r.endpoint(:,v,p)),median(r.separation(:,v,p)));
        end
    end
    fprintf(fid,'\nAll flagged trials retained. Counts are nested within ten networks, not independent sample sizes. Finite prediction does not establish normal movements. Target-circle truncation is only for display.\n\n');
    fprintf(fid,'## Readiness provenance\n\n');
    fprintf(fid,'Eta0 readiness medians over networks for lambda [.1,.2,.5,1,2,5,10,100]: %s ms. Lambda10 remains frozen regardless of this diagnostic.\n\n',mat2str(d.readiness.ensembleMedian,12));
    fprintf(fid,'## Independent validation scope\n\n');
    fprintf(fid,'120 cases; %d prior cases reused without replacing fits. Independent new observed fits=%d, matched fits=%d, bounded shuffle1/network1 refits=%d; all saved shuffle controls checked.\n\n',audit.reusedCases,audit.observedRefits,audit.matchedRefits,audit.shuffleRefits);
    fields={'drawError','transitionError','convergenceError','geometryError','featureError','pcaError','predictionError','lossError','r2Error','movementError','bootstrapError','shuffleError'};
    fprintf(fid,'| Check | Maximum absolute discrepancy |\n|---|---:|\n');
    for name=fields, fprintf(fid,'| %s | %.17g |\n',name{1},audit.(name{1})); end
    fprintf(fid,'\nNative-transition/noise reconstruction covers the three predeclared saved audit steps per trial; stream implementation/seeds are frozen. No additional full-trajectory replay or full independent100-shuffle refit is claimed.\n\n');
    fprintf(fid,'Canonical compact sources: results/paper_ready/final_v2/; ignored raw evidence: results/paper_ready/cache/final_v2/ plus validated reused caches. Full legends and panel map are adjacent. No RRR, new model family, noise fitting or downstream geometry selection.\n');
end
