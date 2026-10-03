# PAPER-MODELLING-FIG6FGH-FINAL-DISPLAY-13

Display-only successor, 3 October 2026. Authority: the complete current Notion instructions saved in [INSTRUCTIONS.md](INSTRUCTIONS.md), especially current f–h and sections 5–8, plus the user's full-support-median clarification. Starting main checkpoint: `8a9dc6f17b944831db8d05d784100df1680ffc4e`. No simulation, parameter change, statistical test, bootstrap, model fit, manuscript edit or network reselection was performed.

## Outcome and selection

Network **8** remains frozen; there is no new network score. Target **1** wins among eligible targets **1,2,3,6,8** by the smallest Intact mean ideal-segment pathRMS of its ten best successful trials. Its score is **0.00061135674965450012 m** (0.061135674965450012 cm). Block determines eligibility only, never quality ranking. This is an outcome-selected illustration, not an inferential or typicality claim.

The pool was reused exactly as saved, including 12,674 completed attempts, 453 successes and all failed outcomes. No attempts were added. Success is first entry into the existing 1.5-cm target zone within the frozen 600-ms horizon. RMS uses the shortest distance to the closed center-to-center segment, from frozen kinematic MO through first entry.

| Target | Intact successes / completed attempts | Block successes / completed attempts | Eligible (30 by attempt 500 both) | Intact ten-best score (m) |
|---|---|---|---|---|
|1|30 / 35|30 / 185|Yes|0.00061135674965450012|
|2|30 / 41|30 / 195|Yes|0.0010380141810301781|
|3|30 / 49|30 / 390|Yes|0.0012830046873245067|
|4|30 / 38|4 / 5000|No|Not ranked|
|5|30 / 37|29 / 3052|No|Not ranked|
|6|30 / 50|30 / 105|Yes|0.00098724845041402035|
|7|30 / 46|30 / 2934|No|Not ranked|
|8|30 / 41|30 / 476|Yes|0.00081391672662802525|

The historical canceled Block target-5 request 3053, seed 612053053, has no saved outcome. It remains explicitly unknown, not recoded as failure or success. No 30th success is invented. Targets 4/5 still provide at least four saved successes for f; target 7 fails g/h eligibility despite eventually reaching 30.

### Fig. 6f selected attempt IDs (ascending pathRMS)

|Target|Intact four|Block four|
|---|---|---|
|1|34,15,29,32|86,22,67,31|
|2|3,21,17,35|96,47,158,169|
|3|8,34,25,49|74,106,227,388|
|4|36,14,5,7|1860,2867,4931,518|
|5|5,13,4,25|2257,1559,1152,2360|
|6|3,5,33,38|78,42,47,28|
|7|25,21,5,20|2048,1470,1114,1180|
|8|31,32,36,40|3,149,476,227|

Thick f trajectories average these same four trials only, after independent linear interpolation of x/y from MO to first entry onto 101 movement-phase samples. The exact manuscript target palette is used, with target 1 bottom-center and increasing IDs counterclockwise. Both condition axes/target zones/aspect are identical.

### Fig. 6g/h selected attempt IDs

- Intact: **34,15,29,32,24,11,23,16,1,20**.
- Block: **86,22,67,31,90,52,163,94,181,40**.

The ten thin g traces remain native unsmoothed speeds aligned to MO. Each ends at its own entry; all subsequent values are NaN. The thick g median uses all 30 successes active at each real-time sample, not the selected ten, and is the only trace smoothed.

|Condition|Last raw-median support (ms from MO)|Last nActive >=15 sample / displayed cutoff (ms)|
|---|---|---|
|Intact|527|274|
|Block|545|413|

The full raw median is smoothed first with the existing 50-sample/50-ms Gaussian. At true support boundaries weights are truncated and renormalized; no missing/post-entry sample is zero-padded. Only then is the displayed thick trace cut off. The correct full-support endpoint minus the incorrectly cutoff-before-smoothing endpoint is -0.016717826316414997 m/s (Intact) and -0.0045644996078269551 m/s (Block); that incorrect procedure is not used.

All g/h condition traces are solid: Intact sky blue [86,180,233]/255, Block vermillion [213,94,0]/255. h uses the same ten IDs; filled points mark each native GO-through-entry unsmoothed peak-speed position. Its inset distances and condition-specific median position use all 30 successes. Both condition panels include the identical black dashed center-to-center path and 1-cm scale bars. This illustrative inset is not the n=6 inferential assay.

## Unchanged manuscript science

All accepted models, calibration, noise, prediction, aggregate behavior, statistics, other panel objects and earlier review bundles are retained. No inferential computation was invoked. Current i/j remain the four displayed levels .05/.10/.15/.20, Friedman df=3, raw p, n=10. Current AD-selected tests and BH families remain unchanged.

- g: Intact 0.42026633892887771 ± 0.00095732016011368989 m/s; Block 0.29334637066412139 ± 0.011120979564432407 m/s. Within-network reduction 29.620738559012963 ± 2.5030943906286582%. Paired t(9)=-18.944070455588200, raw p=1.4641906487214610e-8, n=10.
- h: speed-matched dispersion, eligible networks 1,2,3,6,7,10 only: Intact 0.55267160633162271 ± 0.027318985032037599 cm; Block 2.6840010552961773 ± 0.33160946624453685 cm. Increase 395.37364598900677 ± 63.030615020997878%. Wilcoxon W_plus=21, p=0.03125, n=6. The all-ten unmatched control remains unchanged.

These copied descriptive/inferential values come from the existing validated sources, not the success-conditioned reservoir.

## Validation and files

Independent saved-output audit: PASS, 453 successes. Maximum difference in independently computed pathRMS 8.6736173798840355e-18 m; 101-point interpolation/means 4.163336342344337e-17 m; independently truncated/renormalized Gaussian 2.7755575615628914e-16 m/s. Raw thin curves, ranking/tie rules, target eligibility, nActive, support/cutoff ordering, all30 inset, and plotted-source identity passed. Seven new MATLAB files passed Code Analyzer with zero issues. All twelve current native FIGs were reopened; 128 new display objects checked. All three revised PNGs were visually inspected: matching geometry, no stray legend entries, readable labels, solid colors and ideal paths confirmed.

An initial cache-only audit stopped on a MATLAB argument-position error in its independent smoothing check. Only that syntax was repaired; the already completed display-source build was reused by `fd13_finish`. No source trajectory was rerun or changed.

New native pairs:
- `plots/paper_ready/final_v3/fig6fgh_final13/fig/Fig6f.fig`, `png/Fig6f.png`
- `plots/paper_ready/final_v3/fig6fgh_final13/fig/Fig6g.fig`, `png/Fig6g.png`
- `plots/paper_ready/final_v3/fig6fgh_final13/fig/Fig6h.fig`, `png/Fig6h.png`

New analysis code: `analysis/paper_ready/final_v3/fig6fgh_final13/fd13_*.m`.
Compact results: `results/paper_ready/final_v3/fig6fgh_final13/`; selection.json and all CSVs include IDs, seeds, ranks, RMS, entry times, eligibility, same-four means, raw thin speeds, raw/full-smoothed/displayed medians, nActive and all30 inset distances. Separate canceled-request record preserves its unknown outcome.

See [LEGENDS.md](LEGENDS.md), [DEPENDENCIES.md](DEPENDENCIES.md), saved-output/figure `validation.json` in the results root, and the independent [Code Analyzer receipt](code_analyzer_final.json). [CURRENT_PANEL_INDEX.md](../CURRENT_PANEL_INDEX.md) points to this successor. The current source-table ZIP contains copied—not recomputed—current quantitative tables plus new display provenance.

## Preservation, publication and checkpoint

No pre-existing file was deleted or cleaned. No broad storage cleanup was performed. All originally untracked content, including task11's stopped pool/code/evidence, remains outside this task's staging scope. `preserved_before.json` inventories 9,141 pre-existing non-Git files; the paired after receipt verifies preservation, including raw reservoir SHA256s and twenty quantitative primary movement-cache hashes. Only the current-panel navigation file is permitted to change among originals.

Final-v3 Notion cleanup retains exactly twelve current panel sections/images, current statistics, source-table download, one status callout and concise archive links. Historical repository evidence is preserved. Publication and preservation receipts record the actual checks. The normal main checkpoint SHA and final folder size are reported in Notion/Agent Log and the final task response; no release tag or other branch is changed. STOP FOR SCIENTIFIC REVIEW after verified push.
