function ns_report(root)
    %#ok<*ALIGN> Compact nested loops below only enumerate report rows.
    cfg=ns_paths(root); s=load(fullfile(cfg.dest,'summary.mat'),'summary'); r=s.summary;
    a=jsondecode(fileread(fullfile(cfg.dest,'audit.json'))); assert(strcmp(a.status,'PASS'));
    output=fullfile(root,'docs','paper_ready','noise_sensitivity','REPORT.md'); assert(~isfile(output));
    fid=fopen(output,'w'); assert(fid>0); closer=onCleanup(@()fclose(fid));
    fprintf(fid,'# Final bounded preparation-noise sensitivity\n\nPAPER-MODELLING-NOISE-SENSITIVITY-01. Numerical analysis complete; scientific review pending.\n\n');
    fprintf(fid,'Release93e9d517d47b48579ef9d5bda6adacc44bf039d7 remains unchanged. No noise/eta selected; no RRR, retuning, staging, commit or push.\n');
    fprintf(fid,'Five unique noise pairs;200 cases,40 reused anchors and160 new cases/38400 new trials. All48000 total trials retained.\n\n');
    fprintf(fid,'## Primary outcomes\n\nTen networks are independent units. Median +/- SE from the fixed10000 whole-network bootstrap rows.\n');
    fprintf(fid,'The0.10/0.10 anchor is one dataset, displayed in both one-factor sweeps; not duplicate evidence.\n\n');
    fprintf(fid,'| eta | s_init | s_temporal | Intact R2 | Block R2 | Intact C | Block C |\n|---:|---:|---:|---:|---:|---:|---:|\n');
    for e=1:2, for v=1:5
        fprintf(fid,'| %g | %.2f | %.2f |',r.eta(e),cfg.pairs(v,:));
        for name={'r2','convergence'}
            b=r.bootstrap.(name{1}); mu=reshape(b.median,2,5,2); se=reshape(b.se,2,5,2);
            for p=1:2, fprintf(fid,' %.10g +/- %.10g |',mu(e,v,p),se(e,v,p)); end
        end
        fprintf(fid,'\n');
    end, end
    fprintf(fid,'\n## Paired effects, not differences of medians\n\n| eta | s_init | s_temporal | deltaC | deltaR2 | R2 loss (%%) | Available loss n | Networks Block lower R2 / lower C |\n|---:|---:|---:|---:|---:|---:|---:|---:|\n');
    for e=1:2, for v=1:5
        fprintf(fid,'| %g | %.2f | %.2f |',r.eta(e),cfg.pairs(v,:));
        for name={'deltaC','deltaR2','lossPct'}
            b=r.bootstrap.(name{1}); mu=reshape(b.median,2,5); se=reshape(b.se,2,5); fprintf(fid,' %.10g +/- %.10g |',mu(e,v),se(e,v));
        end
        fprintf(fid,' %d | %d / %d |\n',nnz(isfinite(r.lossPct(:,e,v))),nnz(r.deltaR2(:,e,v)<0),nnz(r.deltaC(:,e,v)<0));
    end, end
    fprintf(fid,'\n## Supporting controls, geometry and movement\n');
    for name={'shuffle','matched','pr','bias','dispersion','mo','peakTime','peakSpeed','endpoint','separation'}
        b=r.bootstrap.(name{1}); mu=reshape(b.median,2,5,2); se=reshape(b.se,2,5,2);
        fprintf(fid,'\n### %s\n\n| eta | s_init | s_temporal | Intact | Block |\n|---:|---:|---:|---:|---:|\n',name{1});
        for e=1:2, for v=1:5, fprintf(fid,'| %g | %.2f | %.2f | %.10g +/- %.10g | %.10g +/- %.10g |\n',r.eta(e),cfg.pairs(v,:),mu(e,v,1),se(e,v,1),mu(e,v,2),se(e,v,2)); end, end
    end
    fprintf(fid,'\n### Control95 alignment (fractions)\n\n| eta | s_init | s_temporal | K range | Observed | Expected | Deficit |\n|---:|---:|---:|---:|---:|---:|---:|\n');
    for e=1:2, for v=1:5
        fprintf(fid,'| %g | %.2f | %.2f | %d-%d |',r.eta(e),cfg.pairs(v,:),min(r.k(:,e,v)),max(r.k(:,e,v)));
        for name={'observed','expected','deficit'}
            b=r.bootstrap.(name{1}); mu=reshape(b.median,2,5); se=reshape(b.se,2,5); fprintf(fid,' %.10g +/- %.10g |',mu(e,v),se(e,v));
        end
        fprintf(fid,'\n');
    end, end
    fprintf(fid,'\n### QC counts (all flagged trials retained)\n\n| eta | s_init | s_temporal | Condition | Bounds failures/10 | Nonfinite/10 | Near-zero/2400 | Missing/2400 | Boundary/2400 | Multiple peaks/2400 |\n|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|\n');
    for e=1:2, for v=1:5, for p=1:2
        q=[r.qc{:,e,v,p}]; fprintf(fid,'| %g | %.2f | %.2f | %s | %d | %d | %d | %d | %d | %d |\n', ...
            r.eta(e),cfg.pairs(v,:),cfg.names{p},sum(~[q.prepBounds]),sum(~[q.finite]),sum([q.nearZero]),sum([q.missingWindow]),sum([q.boundaryPeak]),sum([q.multiPeak]));
    end, end, end
    fprintf(fid,'\nUndefined C trials: %d. Unevaluable R2 cases: %d. Undefined relative-loss networks/settings: %d.\n',sum(r.undefined,'all'),sum(~isfinite(r.r2),'all'),sum(~isfinite(r.lossPct),'all'));
    fprintf(fid,'Full raw d_cue/d_prego, ratios, reference K/capture and QC for48000 trials are in trial_metrics.csv; no clamping or exclusions.\n');
    fprintf(fid,'\n## Interpretation boundaries\n\n');
    lowerR2=reshape(r.bootstrap.deltaR2.median,2,5)<0; lowerC=reshape(r.bootstrap.deltaC.median,2,5)<0;
    fprintf(fid,'Median Block-minus-Intact R2 is negative at %d/10 unique eta/noise settings; median deltaC is negative at %d/10. See every value above, including network-level exceptions.\n',sum(lowerR2,'all'),sum(lowerC,'all'));
    fprintf(fid,['This is a disclosed follow-up sensitivity diagnostic, not noise fitting or a blind empirical validation. ', ...
        'Only the two one-factor sweeps and two eta endpoints were tested; no noise interactions or general noise robustness are established. ', ...
        'No outcome selects a model, noise level or eta. Movement abnormalities remain limitations even when neural estimates are finite.\n\n']);
    fprintf(fid,['C measures relative held-out deviations from epoch-specific target-reference means, not distance to one fixed equilibrium. ', ...
        'Initial noise changes d_cue; its sign alone cannot establish changed dynamical contraction or mediation of prediction. ', ...
        'It is the model-native cue-to-pre-go analogue, not the experimental pre-cue assay. Prediction PCA75 uses the full balanced ensemble, ', ...
        'not strictly inductive foldwise feature learning. No new significance-test family or quantitative empirical fitting.\n\n']);
    fprintf(fid,'All uncertainty uses the original whole-network bootstrap without selective good-trial subsets. If an estimate is undefined, available n is disclosed and the strict released bootstrap is not rescued by dropping it.\n');
    fprintf(fid,'\n## Independent saved-output audit\n\n```json\n%s\n```\n',jsonencode(a,'PrettyPrint',true));
    fprintf(fid,'\n## Sources and stopping boundary\n\n');
    fprintf(fid,'PLAN.md and CAPTIONS.md hold the locked protocol/full legends. Compact full-precision source tables and summary.mat/json: results/paper_ready/noise_sensitivity/.\n');
    fprintf(fid,'Raw case/fit evidence: ignored results/paper_ready/cache/noise_sensitivity/. Two editable FIG/PNG pairs: plots/paper_ready/noise_sensitivity/{fig,png}/.\n');
    fprintf(fid,'Protected-file receipts, analyzer output and reopened-FIG audits: artifacts/manifests/paper_ready/noise_sensitivity/. Publication/preservation completion is recorded separately after verification.\n');
    fprintf(fid,'No previous file is overwritten. STOP FOR SCIENTIFIC REVIEW.\n');
end
