# PAPER-MODELLING-FIG6FGH-HIGHRMS-EMPIRICALSTYLE-14

Display-only successor,3 October2026. Starting main checkpoint **20ad6be8c52f8a88693fb07807aed259d8db3fdf**. Authority: complete current [Notion instructions](INSTRUCTIONS.md), specifically current f–h, validation, gallery cleanup, storage, main checkpoint and stop. No model, controller, simulation, parameter, random draw, fitting, scientific statistics or manuscript edit.

## Frozen target selection, changed example selection

Network **8 remains frozen**, not reselected or rescored. Target **1 remains selected**. Eligibility is independently derived as30 successes in both conditions by attempt500, giving targets1,2,3,6,8. Selection still uses the **ten lowest-pathRMS Intact successes**, with target-ID tie-break. Scores (m):

|Target|Intact target score|
|---|---|
|1|0.00061135674965450012|
|2|0.0010380141810301781|
|3|0.0012830046873245067|
|6|0.00098724845041402035|
|8|0.00081391672662802525|

Only the displayed individual examples reverse to **descending** ideal-segment pathRMS, with ascending deterministic attempt-ID tie-break. This is deliberately outcome-selected, high-deviation successful visualization; the thin paths are not claimed to be statistically typical.

### Fig.6f selected attempt IDs, highest RMS first

|Target|Intact high-RMS four|Block high-RMS four|
|---|---|---|
|1|7,22,6,28|185,49,84,160|
|2|19,27,10,29|38,136,187,151|
|3|2,31,24,10|6,367,265,290|
|4|19,34,29,23|518,4931,2867,1860|
|5|6,9,7,29|2002,1929,1127,1258|
|6|50,45,29,9|29,56,58,101|
|7|8,46,38,40|2765,515,343,2597|
|8|35,13,24,10|103,126,233,140|

The thick mean uses these exact same four displayed successes, MO→first-entry x/y interpolation onto101 equally spaced0–1 phase samples. No all-success or all-trial f mean is substituted. Target geometry/1.5cm zones, equal axes/aspect and the exact eight-target palette remain unchanged.

### Fig.6g/h selected attempt IDs, highest RMS first

- Intact: **7,22,6,28,3,4,17,13,27,25**.
- Block: **185,49,84,160,54,97,80,137,71,53**.

Fig.6g thin traces are raw unsmoothed solid speeds, MO-aligned and ended at entry. Thick medians still use all30 successful trials active at each real-time sample, with post-entry NaNs. Full-support raw medians are smoothed only once using the existing50ms Gaussian, truncated/renormalized at actual support boundaries, and only then displayed through the last nActive>=15 sample.

|Condition|Full raw support ends (ms from MO)|Displayed median cutoff (ms)|
|---|---|---|
|Intact|527|274|
|Block|545|413|

The entire raw median/full smoothed median/displayed median/nActive/cutoff CSV is **bit-identical** to task13. No artificial cutoff-edge smoothing or zero padding.

## Live empirical Fig.1e graphical match

The actual image anchored to Fig.1 in live [Main_text_v10](https://docs.google.com/document/d/1jCZOSdMZTXcHXQ8Aeb61P748bABL-0fFSO0rmxPm2UA/edit) was inspected before plotting, including a magnified panel-e detail. [EMPIRICAL_TEMPLATE.md](EMPIRICAL_TEMPLATE.md) records Doc revision, objectID, image hash and exact visual observations.

Fig.6h now has **one overlaid spatial field**, not separate condition panels. It follows empirical Fig.1e's faint solid paths, filled peak-speed circles, hidden axes/ticks, left L-shaped1cm scale bar, upper-right target-direction key, and **lower-right angled overlapping translucent filled histogram bars with condition-colored outlines**. It does not use a detached ordinary histogram/count-axis panel or outline-only Block stairs.

The model's actual target1/native orientation remains unchanged rather than being rotated to empirical target2. The black dashed ideal center-to-center path is subordinate. Distances and coordinatewise condition median peak position use **all30 successes**, not the selected ten. Histogram edges are shared0:.5:6cm; counts sum30 each and patch vertices are independently checked. Distance scale=1cm; count scale=2trials. Intact is sky blue [86,180,233]/255 and Block vermillion [213,94,0]/255 throughout g/h.

Initial visual QA found a clipped direction-key box. The final display-only repair extended its axis margin and uses zero-width transparent surfaces for h paths so edges connect only adjacent saved samples, never a polygon-closing chord. The provisional task14 h pair is preserved in ignored/local cache; old task13 figures were never overwritten. No source selection/summary array was changed during this rendering repair.

## Reused attempts and preserved evidence

All **12,674** saved completed visualization attempts are retained, **453 successes /12,221 failures**. No new attempt was simulated.

|Target|Intact successes/attempts|Block successes/attempts|
|---|---|---|
|1|30/35|30/185|
|2|30/41|30/195|
|3|30/49|30/390|
|4|30/38|4/5000|
|5|30/37|29/3052|
|6|30/50|30/105|
|7|30/46|30/2934|
|8|30/41|30/476|

Block target5 canceled request3053, seed612053053, remains explicitly unknown with no saved outcome. No missing success is invented and no failure is displayed.

## Validation and unchanged manuscript quantities

Independent saved-output audit passes: event/success/seed identities, closed-segment RMS, descending display ranking versus ascending target ranking, same-four101-point interpolation, raw thin speeds, full-support smoothing, all30 positions/distances, histogram counts and plotted-source identity. Max independent RMS difference8.6736173798840355e-18m; interpolation4.163336342344337e-17m; Gaussian2.7755575615628914e-16m/s. All30 source arrays exactly equal the previous validated display cache; only display order and f means differ.

Seven new MATLAB files pass Code Analyzer. All12 current FIGs reopen; all3 revised PNGs are visually inspected. The final figure receipt is `final_figure_validation.json`, supplementing the initial combined validation receipt.

**No quantitative manuscript result or inferential statistic changed.** Current a/b corrected BH families, d/e/g/h paired-test identities/values, ED7b component-removal inference, four-level i/j Friedman tests and every median/bootstrap SE remain protected without recomputation. Fig.6g retains the independent all-trial n10 peak-speed assay; h retains the prespecified matched n6 IDs1,2,3,6,7,10 with raw Wilcoxon p=.03125 plus unchanged all10 unmatched control. Success-conditioned display selection never replaces those datasets.

## Outputs, preservation and publication

- Code: `analysis/paper_ready/final_v3/fig6fgh_highrms14/`.
- Sources/receipts: `results/paper_ready/final_v3/fig6fgh_highrms14/`. Descending ranks, attempt IDs/seeds/RMS/entry times, unchanged eligibility, four-trial means, raw thin traces, full-support medians/nActive/cutoffs, all30 peaks/distances and histogram counts are explicit.
- Native pairs: `plots/paper_ready/final_v3/fig6fgh_highrms14/fig/Fig6f.fig`, `Fig6g.fig`, `Fig6h.fig` and matching files in `png/`.
- [LEGENDS.md](LEGENDS.md), [DEPENDENCIES.md](DEPENDENCIES.md), current source-table ZIP, Notion/preservation receipts and [panel navigation](../CURRENT_PANEL_INDEX.md).

No broad cleanup and no original file/dependency deletion. Prior untracked work remains untouched and excluded from the checkpoint. Raw caches/reference images/provisional h/logs remain local/ignored. The original-file snapshot has9,189 entries, with7,516 full SHA256s; the after receipt verifies preservation except the authorized current-panel navigation edit.

Final Paper Figures v3 keeps exactly12 current panel sections/images, one current status, unchanged current statistics/placeholder and concise archive links. Previous task13 figures/reports remain historical provenance, not current displays. Normal main checkpoint SHA, direct-remote equality and final project size are recorded after push in the gallery, Agent Log/Handoff/START HERE and final response. No other branch or release tag is altered. STOP FOR SCIENTIFIC REVIEW.
