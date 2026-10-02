# Fig. 6f–h representative display update and cleanup

PAPER-MODELLING-FIG6FGH-CLEANUP-PUSH-09, 2 October 2026. Scientific model, simulations, inferential results, aggregate behavioral statistics, manuscript and unrelated figures are unchanged. This is a display-only update using existing primary .10/.10 trajectories, followed by dependency-aware removal of obsolete ignored caches. Scientific review is pending; no further science is authorized.

## Deterministic selection

Intact-only network score selects **network 9**, score **0.00850928229708846 m** (0.850928229708846 cm). Within it, **target 8** has minimum target RMS **0.0045679328856548518 m** (0.45679328856548518 cm). Complete rankings and all 480 trial ranks/RMS/end times are in the adjacent result root. The selection is explicitly outcome-selected for low variability, not a typicality or inference claim.

The common display end is first saved entry into the 1.5-cm target zone, inclusive, or the frozen 600-ms horizon. Native time samples are 0:599 ms; no 600-ms sample is synthesized. All later samples are NaN before means, RMS ranking, speed smoothing or illustrative peaks. Five examples per condition/target are shown in f; ten in g/h; summaries/insets always use all 30 terminated trials. Colors are the exact specified eight-target RGB matrix. No result-dependent exception was used.

Trial IDs below are within-target IDs (1–30), in RMS-rank order. Global ID = 30*(target−1)+local ID; CSVs provide both IDs and full-precision RMS.

| Target | Fig. 6f Intact | Fig. 6f Block |
|---|---|---|
| 1 | 15, 11, 30, 21, 6 | 7, 23, 6, 30, 19 |
| 2 | 2, 3, 26, 24, 13 | 24, 11, 10, 13, 20 |
| 3 | 23, 25, 27, 20, 14 | 30, 16, 23, 4, 18 |
| 4 | 19, 9, 5, 7, 20 | 19, 22, 8, 25, 30 |
| 5 | 7, 2, 13, 3, 17 | 26, 27, 3, 13, 12 |
| 6 | 4, 12, 30, 17, 15 | 4, 3, 17, 15, 1 |
| 7 | 29, 2, 28, 19, 26 | 21, 14, 24, 1, 17 |
| 8 | 6, 5, 24, 16, 4 | 20, 5, 14, 9, 12 |

Fig. 6g and 6h use target 8, with Intact **6, 5, 24, 16, 4, 15, 22, 28, 27, 1** (global 216,215,234,226,214,225,232,238,237,211) and Block **20, 5, 14, 9, 12, 28, 21, 16, 6, 29** (global 230,215,224,219,222,238,231,226,216,239).

## Outputs and validation

- Current pairs: `plots/paper_ready/final_v3/fig6fgh_cleanup09/{fig,png}/Fig6{f,g,h}.{fig,png}`. Prior f–h pairs remain historical unchanged. Read LEGENDS.md for complete caption-ready methods.
- Sources: `results/paper_ready/final_v3/fig6fgh_cleanup09/`: selection.json, all_intact_target_RMS.csv, network_ranking.csv, selected_network_target_ranking.csv, all_trial_rankings.csv, Fig6f_selected_trials.csv, Fig6gh_selected_trials.csv and Fig6h_all30_inset.csv. Local display_sources.mat holds derived graphics arrays; immutable raw movement sources remain local/ignored at paths in DEPENDENCIES.md.
- Independently calculated network/target selection error: 1.7347e-17 m; source-object error: zero. All 10 network rankings, 480 trial rankings, 142 plotted objects, native FIG labels/error bars/source identities, all-30 summaries and inset, palette, and identical g/h trial selection passed.
- Poisoned discarded-speed sentinel audit confirms no post-end samples enter display smoothing or unsmoothed peak calculations. All twelve current panel FIGs reopen. All three new and three smoke PNGs were visually inspected, and all five current compact result bundles load.
- Code Analyzer passed all five new MATLAB files with zero findings. An initial indentation-only warning was repaired before display calculation, with the failed static receipt retained locally.
- Post-cleanup smoke re-render/revalidation passed from retained native sources; `postCleanupDisplaySourcesExact=true`. The smoke output is separate and not the published panel bundle.
- 2,154 protected files totaling 11,956,889,317 bytes are covered by SHA256 preservation checks, including all current compact/source/statistical/figure artifacts and twenty primary Intact/Block raw cases. Retained-file metadata check independently confirms all 3,827 original non-Git, non-task files outside the exact deletion manifest still have identical size/mtime, with no unplanned removal.
- No inferential recomputation occurred. This includes the established g paired t-test (n=10, p=1.4641906487214610e-8), h Wilcoxon signed-rank test (n=6, p=.03125), all medians/bootstrap SEs/percent changes, corrected a/b/d/e/ED7b inference and current four-level i/j results.

## Storage outcome

File-length totals include hidden/ignored files and .git; these are logical bytes, not filesystem allocation estimates. Before: **501,020,219,061 bytes**. After cleanup and separate smoke output: **201,680,471,416 bytes**. Exactly **1,400 ignored files / 299,383,822,654 bytes** were removed; net reduction at that inventory is **299,339,747,645 bytes** (59.75%). New display/smoke/audit artifacts account for the difference; the final checkpoint adds a small amount of Git/documentation metadata.

| Deleted path/class | Files | Bytes |
|---|---:|---:|
| results/paper_ready/cache/stationary_convergence/ | 610 | 84,246,918,848 |
| results/paper_ready/cache/noise_sensitivity/ obsolete e2 and e1/p2 raw only | 120 | 51,338,646,786 |
| results/stage_3/current/cache/prediction_validation/nXX_sX_pX.mat raw only | 120 | 49,263,955,673 |
| results/paper_ready/cache/convergence_reanalysis/ | 290 | 32,072,300,495 |
| results/paper_ready/cache/stabilization_eta/ obsolete e2–e4 and e5/p2 raw only | 70 | 29,938,698,211 |
| results/stage_3/current/cache/postgo_noise_diagnostic/ | 80 | 19,672,294,225 |
| results/paper_ready/cache/final_v3/fig6ij_fivelevel/ zero-noise raw only | 40 | 17,085,537,659 |
| results/stage_1/cache/movement_landscape_diagnostic/ | 70 | 15,765,470,757 |

Exact file paths, sizes, reasons and checks are in cleanup_manifest.json / cleanup_executed.json; inventories and retained_metadata_validation.json give the before/after accounting. Files were removed with path-specific native Windows operations after containment, identity, ignored/tracked, protected-set and reparse checks. These ignored historical raw caches are not recoverable from Git; regenerating them would require separate authorization. Historical scientific reports, compact results and figures remain. No current manuscript raw dependency was deleted.

Largest remaining directories (non-additive where nested): current final_v3 cache 85.869 GB; final_v2 cache 37.294 GB; retained noise_sensitivity 20.615 GB; historical prediction/RRR cache 20.433 GB; Stage-3 cache 7.203 GB; stabilization_eta 5.716 GB; alignment95 2.625 GB. Original root grid/control files and prediction/RRR caches are conservatively retained as upstream/ambiguous dependencies, not guessed disposable.

## Notion and checkpoint scope

The existing Final Paper Figures v3 page now displays the new native images and all full-precision selection/inset tables in the corresponding panel sections. Previous displays are explicitly historical; exact expiring-image-URL replacement was rejected, so the prior images were preserved rather than risking unrelated content. Readback verifies current images/tables, unchanged pre-f/post-h sections and unchanged g/h aggregate blocks (only expiring URL query strings and whitespace normalized).

The checkpoint is bounded to the new representative-display code, small FIG/PNG pairs, compact selection/audit tables, cleanup/provenance documents and necessary shared graphics validator, plus durable reports/receipts for retired historical caches. Large source MATs/raw caches, temporary process logs, smoke duplicates, expiring signed-URL snapshots and unrelated pre-existing review work are not staged. Those pre-existing untracked review bundles remain preserved; a clean tracked tree is not a claim that the entire workspace is free of untracked files. The unchanged released science baseline is aa63c7914fadf6f7c96c634617e797eac3772246. Final commit and direct remote equality are reported in Notion and the final response after the normal main push; no tag/release replacement or v3 branch rewrite.

STOP FOR SCIENTIFIC REVIEW after verification. No simulation, fitting, tuning, manuscript edit or new analysis follows.
