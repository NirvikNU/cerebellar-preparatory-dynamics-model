# PAPER-MODELLING-FIG6IJ-FIVELEVEL-04

## Scope and scientific outcomes

The new active Fig6i/j use exactly [0,0.05,0.10,0.15,0.20]. Only the forty zero-noise cases were simulated/fitted: pairs [0,.10] and [.10,0], policies Intact/full Block, networks1–10. Each case retained eight targets × thirty trials (240), totaling9,600 new trials. Production took1,132.0161187s and passed every per-case independent audit.

All .05/.10/.15/.20 R² values, relative losses, medians and SEs are copied exactly from the frozen original final_v3 summary. The .10/.10 anchor is the same dataset in both sweeps. The .075/.125/.175 data, original figures, three-level inference and superseded seven-level inference are preserved, not rerun or overwritten.

Both five-point Intact R² median curves decrease. Neither relative-loss median curve is monotonic. In particular temporal-noise Block loss decreases from12.1791% at zero to6.46166% at.05, then increases to14.1247% at.20. Do not describe it as a progressive/monotonic increase across the whole displayed range. Friedman is an omnibus test, not a trend test; initial-loss nonsignificance is not an equivalence result.

Zero on an axis removes only that noise component: initial-state zero retains temporal=.10, and temporal zero retains initial=.10. No post-GO noise is introduced.

## Four repeated-measures tests

Each test uses all five levels and ten matched frozen networks, df=4. Raw MATLAB chi-square approximate p-values; no BH across the four tests and no post-hoc pairwise tests.

| Test | χ²(4) | Raw p |
|---|---:|---:|
| Fig6i / initial-state | 35.439999999999998 | 3.7723121732134055e-7 |
| Fig6i / temporal | 38.720000000000006 | 7.9585986521632361e-8 |
| Fig6j / initial-state | 5.0400000000000009 | 0.28321781575835409 |
| Fig6j / temporal | 19.039999999999999 | 0.00077184886896733461 |

## Full-precision medians ± existing whole-network bootstrap SE

Existing positive-noise values are unchanged. At zero only, new medians and SEs use the original fixed10,000×10 network bootstrap index matrix. No new bootstrap seed or trial-level resampling was introduced.

| Noise | Intact R² / initial | Intact R² / temporal | Relative loss (%) / initial | Relative loss (%) / temporal |
|---:|---:|---:|---:|---:|
| 0 | 0.93237539791970736 ± 0.0039962273523106847 | 0.99316414622947424 ± 0.00078553232993208775 | 9.6144170023322033 ± 2.0827234818008344 | 12.17914947363009 ± 2.1014609449898041 |
| 0.05 | 0.93159068732036543 ± 0.004598712469882511 | 0.98935506568325238 ± 0.0020029888019608066 | 9.9172769087496775 ± 1.5194394541529745 | 6.4616566327871103 ± 2.1805158876975193 |
| 0.1 | 0.92424551001304156 ± 0.0065456126935907214 | 0.92424551001304156 ± 0.0065456126935907214 | 9.2715846871724388 ± 1.7838513643810987 | 9.2715846871724388 ± 1.7838513643810987 |
| 0.15 | 0.91885411830100394 ± 0.0057045215873480874 | 0.81340879910837116 ± 0.0036384595563064494 | 10.079421334179804 ± 1.9967495605547554 | 12.911967259266167 ± 1.5878014544585972 |
| 0.2 | 0.90829781002994281 ± 0.0058576600763267754 | 0.73596133708081368 ± 0.0038888931375109384 | 9.9649308750730903 ± 1.6395535122622 | 14.124730605296985 ± 1.4731548149556652 |

## Methods retained exactly

Frozen eta0, lambda10, V1, global alpha=.5/beta_norm=1.25; ten200-unit networks; original controllers, state definitions, reference neuron scales, initial conditions, movement drive/readout/arm/event definitions. Native integration.2ms, saved1ms, 10ms feature centers. The zero amplitudes multiply existing standardized draws; initial draws are still consumed before temporal draws, preserving stream identities.

Features and prediction use the original unmodified `v3_prediction`, `pe_features`, `stage3_prediction_folds` and `stage3_prediction_ridge`. Prep GO−100:10:0; movement own kinematic MO+0:10:100; native ReLU, immutable per-neuron scales, boundary-protected Gaussian SD30ms ±150ms, time-aligned condition-invariant subtraction, trial window means. Epoch-specific balanced-ensemble PCA retains>=75% variance. Fixed target-matched nested3-fold CV selects among the original25 ridge penalties with an unpenalized intercept and first-minimum tie rule. R²=1−pooled held-out SSE/response SST. Relative loss is calculated within network:100*(Intact−Block)/Intact, then summarized across networks.

No RRR, shuffle/matched-PC variant, retuning, calibration, geometry, component-removal reanalysis, scientific parameter change, post-hoc test, manuscript edit, cleanup, staging, commit or push.

## Independent audits

Per-case maxima across all40 cases:

| Check | Maximum discrepancy |
|---|---:|
| draw | 0.0000000000000000 |
| transition | 0.0000000000000000 |
| movement | 7.1054273576010019e-15 |
| features | 3.1974423109204508e-14 |
| PCA | 2.7000623958883807e-13 |
| prediction | 9.5035090907913400e-14 |
| innerLoss | 1.4551915228366852e-11 |
| R2 | 1.1102230246251565e-16 |

Checks independently regenerated frozen standardized streams, verified initial states and transition equations, movement/arm/event rules, feature values, PCA eigensystems/75% thresholds, fold identities, ridge penalty selections and held-out predictions via normal equations. Every40-case audit passed; all trials/QC flags retained.

Friedman was independently checked using within-network ranks, ties and the df4 survival formula exp(−χ²/2)*(1+χ²/2). Maximum statistic discrepancy 8.8817841970012523e-15; maximum p discrepancy 8.8817841970012523e-16. Additional saved-output, CSV, bootstrap, FIG/PNG, preservation and publication receipts are recorded in `COMPLETION.md` only after those checks finish.

## Source and figure navigation

All successors are under the new `fig6ij_fivelevel` subdirectories:

- Code: `analysis/paper_ready/final_v3/fig6ij_fivelevel/`.
- Current numeric results: `results/paper_ready/final_v3/fig6ij_fivelevel/{summary.mat,statistics.json,Fig6ij_network_values.csv,Fig6ij_summaries.csv,new_case_QC.csv}`.
- Active figures: `plots/paper_ready/final_v3/fig6ij_fivelevel/fig/Fig6i.fig`, `Fig6j.fig`, with matching PNGs under `png/`.
- New raw caches: ignored/local `results/paper_ready/cache/final_v3/fig6ij_fivelevel/`; forty raw files, forty corresponding saved analysis/audit files. Frozen model/controller/reference caches remain required local reproducibility dependencies.
- Predecessors: original `final_v3/summary.mat`, `plots/paper_ready/final_v3/{fig,png}/Fig6i,j`, and `fig6ij_ed7b_stats_correction/` remain immutable historical sources. ED7b's corrected paired-test/BH results remain current and unchanged.
- Notion target: [Final Paper Figures v3](https://app.notion.com/p/3e826c94be308179870cda177f0b75af). Current i/j sections and manuscript-placeholder rows only, with a clearly historical collapsed seven-level archive.

Preflight implementation-only repairs are documented in `PREPARATION_REPAIRS.md`. The Fig6j legend-only repair and preserved first export are documented in `LAYOUT_REPAIR.md`; no source/error-bar coordinate changes are permitted.

STOP FOR SCIENTIFIC REVIEW after final validation/publication. Baseline HEAD remains `aa63c7914fadf6f7c96c634617e797eac3772246`.

