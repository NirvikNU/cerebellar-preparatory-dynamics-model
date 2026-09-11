function path = stage3_prediction_report(root)
    cfg=stage3_prediction_paths(root);
    loaded=load(fullfile(cfg.predRoot,'summary.mat'),'summary'); s=loaded.summary;
    audit=jsondecode(fileread(fullfile(cfg.predRoot,'independent_audit.json'))); assert(strcmp(audit.status,'PASS'));
    figAudit=jsondecode(fileread(fullfile(cfg.predRoot,'figure_audit.json'))); assert(strcmp(figAudit.status,'PASS'));
    path=fullfile(cfg.manifestRoot,'PREDICTION_REPORT.md'); assert(~isfile(path));
    fid=fopen(path,'w'); assert(fid>0); closeFile=onCleanup(@()fclose(fid));
    fprintf(fid,'# Stage-3 fixed-controller prediction validation\n\n');
    fprintf(fid,'Starting checkpoint: %s. STAGE3-PREDICTION-VALIDATION-01, binding repair 2026-09-11.\n\n',cfg.checkpoint);
    fprintf(fid,'The original locked plan and binding analysis choices were unchanged. The only repair to the existing stochastic wrapper was nargin<9 to nargin<8. Failed-attempt evidence is preserved separately.\n\n');
    fprintf(fid,'Ten networks x eight targets x 30 trials x four policies x three fixed noise scales = 28,800 task trials. Primary s=.10; .05 and .20 are non-selected sensitivities. Native .2-ms integration, saved1-ms activity, analysis10-ms samples. No controller, geometry, movement, noise or inference parameter was tuned.\n\n');
    fprintf(fid,'All values below are network median +/- SE of the median from the original10,000 whole-network bootstrap draws, n=10, unless explicitly labeled ranges. Trials/targets are nested, not independent inferential units. Negative R2 is retained.\n\n');
    fprintf(fid,'## Primary metrics and fixed noise sensitivities\n\n');
    fprintf(fid,'| s | Policy | Prep-to-early neural R2 | Prep-to-hand R2 | Prep-to-speed R2 |\n| --- | --- | --- | --- | --- |\n');
    for level=1:3
        for policy=1:4
            fprintf(fid,'| %.2f | %s |',cfg.noiseLevels(level),cfg.policyNames{policy});
            for metric=1:3, b=stage2_bootstrap(s.metrics(:,level,policy,metric),s.bootstrapIndices); fprintf(fid,' %.10g +/- %.10g |',b.median,b.se); end
            fprintf(fid,'\n');
        end
    end
    fprintf(fid,'\n## Nine primary paired contrasts: s=.10 only\n\n');
    fprintf(fid,'Lesion minus Intact; exact paired mean-difference sign flips over all1,024 signs, two-sided, one nine-test BH family.\n\n');
    fprintf(fid,'| Metric | Lesion | Median difference +/- SE | Mean difference | Exact p | BH q |\n| --- | --- | --- | --- | --- | --- |\n');
    for metric=1:3
        for lesion=1:3
            t=s.tests{lesion,metric};
            fprintf(fid,'| %s | %s | %.10g +/- %.10g | %.10g | %.10g | %.10g |\n', ...
                s.metricNames{metric},cfg.policyNames{lesion+1},t.medianDifference,t.medianDifferenceSE, ...
                t.meanDifference,s.p(lesion,metric),s.q(lesion,metric));
        end
    end
    fprintf(fid,'\n## Within-target prediction (supporting)\n\n');
    fprintf(fid,'Fixed full-ensemble hand plane/speed axis; only the per-target OLS relationship is leave-one-out. Eight target-specific R2 values are averaged within network. These are not strict fold-wise feature-learning estimates.\n\n');
    write_metrics(fid,s,cfg,[4 5 8 9]);
    fprintf(fid,'\n## Pre-peak controls and held-out speed-axis variance\n\n');
    fprintf(fid,'Movement-period features: own peak-speed -150:10:-50 ms, same preprocessing/CV. Captured variance uses outer-training axes applied to held-out activity; the pooled projection variance is divided by pooled full-population variance.\n\n');
    write_metrics(fid,s,cfg,[6 7 10 11]);
    fprintf(fid,'\n## Matched-PC control\n\n| s | Pair | Intact R2 | Lesion R2 | Prep K range | Early K range |\n| --- | --- | --- | --- | --- | --- |\n');
    for level=1:3
        for lesion=1:3
            a=stage2_bootstrap(reshape(s.matched(:,level,lesion,:),10,2),s.bootstrapIndices);
            k=reshape(s.matchedK(:,level,lesion,:),10,2);
            fprintf(fid,'| %.2f | Intact vs %s | %.10g +/- %.10g | %.10g +/- %.10g | %d-%d | %d-%d |\n', ...
                cfg.noiseLevels(level),cfg.policyNames{lesion+1},a.median(1),a.se(1),a.median(2),a.se(2),min(k(:,1)),max(k(:,1)),min(k(:,2)),max(k(:,2)));
        end
    end
    fprintf(fid,'\n## Neural chance and original 75-percent PCA counts\n\n');
    fprintf(fid,'Chance: median over100 fixed response-correspondence permutations per network, followed by network median/SE. Permutations preserve complete-ensemble target counts.\n\n');
    fprintf(fid,'| s | Policy | Chance R2 | Prep K range | Early K range |\n| --- | --- | --- | --- | --- |\n');
    for level=1:3
        for policy=1:4
            b=stage2_bootstrap(s.chanceMedian(:,level,policy),s.bootstrapIndices); k=reshape(s.K(:,level,policy,:),10,2);
            fprintf(fid,'| %.2f | %s | %.10g +/- %.10g | %d-%d | %d-%d |\n', ...
                cfg.noiseLevels(level),cfg.policyNames{policy},b.median,b.se,min(k(:,1)),max(k(:,1)),min(k(:,2)),max(k(:,2)));
        end
    end
    fprintf(fid,'\n## Speed-axis orientation (supporting)\n\n');
    fprintf(fid,'Squared cosine between the single full-condition axes. Expected alignment averages100 within-target speed-shuffle refits. Values below are percentage points/percent on a0-100 scale. No additional primary tests.\n\n');
    fprintf(fid,'| s | Epoch | Intact vs | Observed | Expected | Expected-observed |\n| --- | --- | --- | --- | --- | --- |\n');
    epochs={'Prep','Prepeak'};
    for level=1:3
        for epoch=1:2
            for lesion=1:3
                values=100*[s.orientation(:,level,lesion,epoch),s.expectedOrientation(:,level,lesion,epoch),s.orientationDeficit(:,level,lesion,epoch)];
                b=stage2_bootstrap(values,s.bootstrapIndices);
                fprintf(fid,'| %.2f | %s | %s | %.10g +/- %.10g | %.10g +/- %.10g | %.10g +/- %.10g |\n', ...
                    cfg.noiseLevels(level),epochs{epoch},cfg.policyNames{lesion+1},b.median(1),b.se(1),b.median(2),b.se(2),b.median(3),b.se(3));
            end
        end
    end
    fprintf(fid,'\n## Validation evidence\n\n');
    fprintf(fid,'Independent saved-output audit PASS: %d cases, %d counted regression/case checks plus all trial events, preprocessing and state/arm spot checks.\n\n',audit.cases,audit.checks);
    fields={'maxIncrementError','maxArmError','maxFeatureError','maxRidgeResidual','maxR2Error','maxBootstrapError','maxInnerLossRelativeError'};
    for j=1:numel(fields), fprintf(fid,'- %s: %.12g\n',fields{j},audit.(fields{j})); end
    fprintf(fid,'\nReopened FIG/errorbar audit: %d figures, %d errorbar series, maximum discrepancy %.12g. Visual PNG review and final preservation/Git receipts are recorded in the completion section after they occur.\n\n',figAudit.figuresReopened,figAudit.errorbarSeries,figAudit.maxError);
    fprintf(fid,'## Figure paths\n\n');
    names={'result_3_prediction_validation','diagnostic_3_prediction_noise','diagnostic_4_prediction_specificity'};
    for j=1:3, fprintf(fid,'- plots/stage_3/fig/%s.fig and plots/stage_3/png/%s.png\n',names{j},names{j}); end
    fprintf(fid,'\nThe four pre-existing Stage3 figure pairs are preserved unchanged.\n\n');
    fprintf(fid,'## Data and reproduction\n\n');
    fprintf(fid,'Compact summary/CSV/audits: results/stage_3/current/prediction_validation/. Full trial states/arm trajectories, feature arrays, PCA bases, folds, inner losses, coefficients, actual/held-out predictions and permutations: results/stage_3/current/cache/prediction_validation/ (ignored). The old preflight and its raw evidence are preserved.\n\n');
    fprintf(fid,'Entry points in analysis/stage_3: stage3_prediction_preflight_repair, stage3_prediction_production, stage3_prediction_analysis_test, stage3_prediction_pipeline_test, stage3_prediction_analyze, stage3_prediction_audit, stage3_prediction_figure_audit, stage3_prediction_report. Renderer: figures/stage_3/stage3_prediction_figures. Production and canonical result writers refuse overwriting existing evidence.\n\n');
    fprintf(fid,'## Interpretation and checkpoint\n\nScientific interpretation, final preservation, publication and Git receipts must be appended only after review. This generated numeric report does not claim a push or scientific acceptance.\n');
    clear closeFile
end

function write_metrics(fid,s,cfg,metrics)
    fprintf(fid,'| s | Policy |');
    for metric=metrics, fprintf(fid,' %s |',s.metricNames{metric}); end
    fprintf(fid,'\n| --- | --- |'); for metric=metrics, fprintf(fid,' --- |'); end; fprintf(fid,'\n');
    for level=1:3
        for policy=1:4
            fprintf(fid,'| %.2f | %s |',cfg.noiseLevels(level),cfg.policyNames{policy});
            for metric=metrics, b=stage2_bootstrap(s.metrics(:,level,policy,metric),s.bootstrapIndices); fprintf(fid,' %.10g +/- %.10g |',b.median,b.se); end
            fprintf(fid,'\n');
        end
    end
end
