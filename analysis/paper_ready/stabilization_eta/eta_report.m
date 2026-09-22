function eta_report(root)
    cfg=eta_paths(root); s=load(fullfile(cfg.dest,'summary.mat'),'summary'); r=s.summary;
    a=jsondecode(fileread(fullfile(cfg.dest,'audit.json'))); assert(strcmp(a.status,'PASS'));
    report=fullfile(root,'docs','paper_ready','stabilization_eta','REPORT.md'); assert(~isfile(report));
    fid=fopen(report,'w'); assert(fid>0); cleanup=onCleanup(@()fclose(fid));
    fprintf(fid,'# Shared residual-stabilization diagnostic\n\nPAPER-MODELLING-STABILIZATION-ETA-01. Completed numerical audit; scientific review pending.\n');
    fprintf(fid,'No eta selected. No RRR, new noise, geometry tuning, staging, commit or push.\n');
    fprintf(fid,'Eta=1 uses existing validated raw trajectories and PCA-ridge fits. Only the four lower eta values were simulated (19,200 new preparation/movement trials).\n');
    fprintf(fid,'The passed preservation, equations/Jacobians and baseline reproduction checks were reused, not repeated.\n\n');
    fprintf(fid,'## Network medians +/- fixed whole-network bootstrap SE\n\n');
    fprintf(fid,'Ten networks are independent units; eight targets and 30 trials/target are nested. All 10,000 original bootstrap rows are reused.\n\n');
    fields={'spectral','bias','dispersion','convergence','pr','r2','mo','peakTime','peakSpeed','endpoint','separation'};
    labels={'A: worst-target spectral abscissa (s^-1)','B: normalized mean GO bias','C: RMS GO spread (state units)', ...
        'D: held-out model-native convergence','E: preparatory PR','F: pooled held-out R2', ...
        'MO (ms)','Peak time (ms)','Peak speed (m/s)','Endpoint RMS (mm)','Target separation/scatter'};
    for j=1:numel(fields)
        b=r.bootstrap.(fields{j}); mu=reshape(b.median,5,2); se=reshape(b.se,5,2);
        fprintf(fid,'### %s\n\n| eta | Intact | Block |\n|---:|---:|---:|\n',labels{j});
        for e=1:5, fprintf(fid,'| %.2f | %.9g +/- %.9g | %.9g +/- %.9g |\n',r.eta(e),mu(e,1),se(e,1),mu(e,2),se(e,2)); end
        fprintf(fid,'\n');
    end
    fprintf(fid,'### Alignment and paired prediction loss\n\n| eta | Control95 K range | Observed (%%) | Expected (%%) | Deficit (pp) | Paired relative R2 reduction (%%) |\n|---:|---:|---:|---:|---:|---:|\n');
    for e=1:5
        fprintf(fid,'| %.2f | %d-%d | %.8g +/- %.8g | %.8g +/- %.8g | %.8g +/- %.8g | %.8g +/- %.8g |\n', ...
            r.eta(e),min(r.k(:,e)),max(r.k(:,e)),100*r.bootstrap.observed.median(e),100*r.bootstrap.observed.se(e), ...
            100*r.bootstrap.expected.median(e),100*r.bootstrap.expected.se(e),100*r.bootstrap.deficit.median(e),100*r.bootstrap.deficit.se(e), ...
            r.bootstrap.relativeLoss.median(e),r.bootstrap.relativeLoss.se(e));
    end
    fprintf(fid,'\n## QC: every trial retained\n\n| eta | Condition | Prep-bound failures / 10 | Near-zero / 2400 | Missing window / 2400 | Boundary peak / 2400 | Multiple peaks / 2400 |\n|---:|---|---:|---:|---:|---:|---:|\n');
    for e=1:5
        for p=1:2
            q=[r.qc{:,e,p}]; fprintf(fid,'| %.2f | %s | %d | %d | %d | %d | %d |\n',r.eta(e),cfg.names{p}, ...
                sum(~r.prepAdmissible(:,e,p)),sum([q.nearZero]),sum([q.missingWindow]),sum([q.boundaryPeak]),sum([q.multiPeak]));
        end
    end
    fprintf(fid,'\nFinite-state/arm checks pass for saved cases. Native preparation limits are inherited unchanged; flagged points are not removed.\n');
    fprintf(fid,'Undefined convergence values: %d / 24000. Missing numerical prediction points: %d / 100.\n\n',sum(r.undefined,'all'),sum(~isfinite(r.r2),'all'));
    fprintf(fid,'## Locked methods and interpretation boundary\n\n');
    fprintf(fid,['Panel D is a **model-native cue-to-pre-go analogue**, not the empirical pre-cue analysis. ', ...
        'Unsmoothed normalized ReLU rates at GO-500:10:0 form reference-only PCA; ', ...
        'minimum K reaches >=95%%. Each same-target fixed fold has20 reference and10 held-out trials; ', ...
        'all trials are held out once. Cue (-500:10:-400) and pre-go (-100:10:0) projected states ', ...
        'are averaged within window first, then compared to corresponding reference means. ', ...
        'C=1-d_prego/d_cue; positive is contraction and negative is divergence. ', ...
        'Numerically zero (<=eps(max(1,Frobenius norm of training observations))) or nonfinite cue distances remain undefined, never clamped. ', ...
        'Trial/fold/target means are arithmetic. Reference-only95%% is an explicitly predeclared model-analysis choice.\n\n']);
    fprintf(fid,['Panel B divides trial-mean GO equilibrium bias by the target trial-mean cue-to-equilibrium distance. ', ...
        'Panel C uses the same raw model-state coordinates at every eta and measures RMS cloud width, not equilibrium bias.\n\n']);
    fprintf(fid,['Geometry uses unsmoothed target means, frozen per-neuron reference scale and across-target invariant removal. ', ...
        'Intact alone supplies K>=95%% for the Block basis, Intact denominator and original10000-draw covariance-shaped null. ', ...
        'PR uses all eigenvalues. The null is not refitted to a favorable eta.\n\n']);
    fprintf(fid,['Prediction retains Gaussian SD30ms at1ms (support+/-150ms with protected boundaries), frozen normalization, ', ...
        'aligned across-target invariant removal, GO-100:10:0 and own-MO0:10:100 averaging, ', ...
        'epoch-specific full-ensemble PCA75 and nested target-stratified3-fold ridge over logspace(-8,4,25). ', ...
        'PCA is manuscript-matched full-ensemble feature estimation, not strictly inductive foldwise PCA. ', ...
        'Pooled held-out R2 and paired relative reduction are descriptive diagnostic outcomes, never selection criteria.\n\n']);
    fprintf(fid,'All local equilibria remain stable even at eta0 (prior completed audit); this does not establish stochastic contraction, complete settling or normal movement. No new inferential test family was introduced.\n\n');
    fprintf(fid,'## Independent audit\n\n```json\n%s\n```\n',jsonencode(a,'PrettyPrint',true));
    fprintf(fid,'\n## Provenance and output paths\n\n');
    fprintf(fid,'- `PRODUCTION_PLAN.md`: resolved prospective implementation; prior stop/baseline reports preserved.\n');
    fprintf(fid,'- `results/paper_ready/stabilization_eta/summary.mat/json`: all network metrics and bootstrap uncertainty.\n');
    fprintf(fid,'- `results/paper_ready/cache/stabilization_eta/`:80 new raw case files,100 derived analysis files and10 null-projector records.\n');
    fprintf(fid,'- `network_metrics.csv`, `target_metrics.csv`, `convergence_trials.csv`: compact/source tables, no omitted cases.\n');
    fprintf(fid,'- `plots/paper_ready/stabilization_eta/{fig,png}/`: six-panel diagnostic, supporting movement QC and network1 kinematics.\n');
    fprintf(fid,'- `artifacts/manifests/paper_ready/stabilization_eta/`: pre-existing baseline receipts plus new execution/figure/static receipts.\n');
    fprintf(fid,'\nOld alignment95, panel-e and RRR artifacts remain separate and unchanged. HEAD remains70fff703f8fd3074bef62ca9954a03bef50e4d99; final Git receipt is recorded separately. STOP FOR SCIENTIFIC REVIEW.\n');
    network=zeros(100,14); targets=zeros(800,9); trials=zeros(24000,11); referenceK=cell(5,2); row=0;
    for n=1:10
        for e=1:5
            for p=1:2
                row=row+1; s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_e%d_p%d.mat',n,e,p)),'result'); z=s.result;
                referenceK{e,p}=[referenceK{e,p};z.convergence.k(:)];
                network(row,:)=[n r.eta(e) p r.spectral(n,e,p) r.bias(n,e,p) r.dispersion(n,e,p) ...
                    r.convergence(n,e,p) r.pr(n,e,p) r.k(n,e) r.observed(n,e) r.expected(n,e) r.r2(n,e,p) r.prepAdmissible(n,e,p) z.convergence.undefined];
                for q=1:8
                    targets((row-1)*8+q,:)=[n r.eta(e) p q z.bias(q) z.cueDistance(q) z.relativeBias(q) z.dispersion(q) z.convergence.targetMean(q)];
                end
                for j=1:240
                    q=ceil(j/30); fold=z.folds.outer(j);
                    trials((row-1)*240+j,:)=[n r.eta(e) p q j-(q-1)*30 fold z.convergence.k(q,fold) ...
                        z.convergence.cue(j) z.convergence.prego(j) z.convergence.c(j) z.convergence.foldMean(q,fold)];
                end
            end
        end
    end
    writeNew(network,{'network','eta','condition','spectral','biasRatio','goRms','convergence','pr','controlK','observed','expected','r2','prepAdmissible','undefined'},fullfile(cfg.dest,'network_metrics.csv'));
    writeNew(targets,{'network','eta','condition','target','rawBias','cueDistance','biasRatio','goRms','convergence'},fullfile(cfg.dest,'target_metrics.csv'));
    writeNew(trials,{'network','eta','condition','target','trial','fold','referenceK95','cueDistance','pregoDistance','convergence','foldMean'},fullfile(cfg.dest,'convergence_trials.csv'));
    fprintf(fid,'\n## Panel-D reference-PCA dimensionality (descriptive)\n\n| eta | Condition | Minimum / median / maximum K |\n|---:|---|---:|\n');
    for e=1:5
        for p=1:2
            v=referenceK{e,p}; fprintf(fid,'| %.2f | %s | %d / %.1f / %d |\n',r.eta(e),cfg.names{p},min(v),median(v),max(v));
        end
    end
    fprintf(fid,'\nThese describe the240 network/target/fold reference fits per eta/condition, not independent replicates. Full fold-level counts are in convergence_trials.csv.\n');
    clear cleanup
end

function writeNew(values,names,path)
    assert(~isfile(path)); writetable(array2table(values,'VariableNames',names),path);
end
