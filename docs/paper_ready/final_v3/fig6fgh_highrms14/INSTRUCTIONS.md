Here is the result of "fetch" for the Page with URL https://app.notion.com/p/3c826c94be30817d8f51d9f6c8c2bc19 as of 2026-10-03T10:13:01.362Z:
<page url="https://app.notion.com/p/3c826c94be30817d8f51d9f6c8c2bc19" icon="🧭">
<ancestor-path>
<parent-page url="https://app.notion.com/p/3c026c94be3081888fd8f5c59493ccd8" title="Cerebellar Preparatory Dynamics Model"/>
</ancestor-path>
<properties>
{"title":"Agent Instructions — Current Task"}
</properties>
<iconMetadata>{"type":"emoji","emoji":"🧭"}</iconMetadata>
<content>
<callout icon="🧪" color="purple_bg">
	**AUTHORIZED — PAPER-MODELLING-FINAL-FIGURES-V3-06.** Build the manuscript-facing modelling figure set that matches the current Results subsection in live Google Drive `Main_text_v9`. Create a new Notion page titled **“Final Paper Figures v3”** under <mention-page url="https://app.notion.com/p/3e026c94be30811dbb4fe27a353fdcd9"/> and a new, non-overwriting `paper_ready/final_v3/` repository bundle. The paper-facing set is exactly **Main Fig. 6a–j** and **Extended Data Fig. 7a,b** as specified below. Reuse validated sources wherever possible. New numerical work is authorized only for (i) denser descriptive sampling of the Fig. 6i/j one-factor noise curves and (ii) the ED Fig. 7b four-policy R² test at the predeclared 0.20/0.20 noise point. Do not tune, refit geometry, alter the final model, resurrect convergence, or promote the prospective-Q variability panels into the manuscript figure set. STOP for scientific review before commit/push/release replacement.
</callout>
## Current task — PAPER-MODELLING-FINAL-FIGURES-V3-06
### 1. Frozen scientific model and source state
Preserve:
- release baseline `aa63c7914fadf6f7c96c634617e797eac3772246`;
- eta=0, lambda=10, V realization 1;
- shared geometry parameters alpha=0.5, beta_norm=1.25;
- ten frozen 200-unit networks;
- eight targets and 30 trials/target;
- final effective decomposition: common base preparation plus cerebellar-dependent target-state setting `b` and state-dependent anticipatory/prospective feedback `L`;
- Intact = base + b + L; `−L (b only)` = base + b; `−b (L only)` = base + L; Block = base only;
- no generic residual kappa feedback in the final paper model;
- all frozen movement-generator/readout/arm/event rules;
- all validated existing random seeds and standardized stochastic streams.
The decomposition is **functional/effective**, not a claim of anatomically separate cerebellar pathways.
The previous convergence analyses and prospective-Q variability figures remain preserved as diagnostics/provenance but are **not part of the v3 manuscript figure set**.
### 2. New paper-facing Notion page
Create a sibling page under the Paper-ready Modelling parent:
**Final Paper Figures v3**
This page must be self-contained for manuscript writing. For every panel:
1. show the panel image;
2. state exactly what existing/new source generated it;
3. give the final caption-ready definition;
4. provide a **“Manuscript-ready statistics”** block containing the exact values required to replace placeholders in the Results text;
5. include full-precision source values/tables immediately below;
6. explicitly distinguish calibrated quantities from independent/downstream model consequences.
Do not overwrite or rename the existing v2 page.
### 3. Dedicated v3 repository roots and native figure files
Use new roots only, for example:
- `analysis/paper_ready/final_v3/`
- `results/paper_ready/final_v3/`
- `docs/paper_ready/final_v3/`
- `plots/paper_ready/final_v3/`
Every paper panel must have its **own native MATLAB ****`.fig`**** and ****`.png`**** file**:
- Fig6a through Fig6j: ten separate FIG/PNG pairs;
- ED7a and ED7b: two separate FIG/PNG pairs.
Also generate assembled Fig. 6 and assembled Extended Data Fig. 7 FIG/PNG layouts if useful, but the individual panel files are mandatory.
Preserve all old bundles and files unchanged.
## Main Fig. 6 — exact panel specification
### Fig. 6a — weakening anticipatory control does not reproduce increased preparatory dimensionality
Reuse the existing current Main A source and appearance, including the finite control-effort/feedback sweep and separated exact feedforward-only endpoint.
- finite lambda values: 0.1, 0.2, 0.5, 1, 2, 5, 10, 100;
- separated categorical endpoint: feedforward only / prospective control removed exactly, K=0;
- ordinate: paired change in preparatory participation ratio relative to the lambda=0.1 reference;
- show all ten networks and network median ± existing 10,000 whole-network bootstrap SE;
- empirical Block−Control PR effect remains context/reference only.
No simulation rerun is required.
**Manuscript-ready statistics required**
- exact feedforward-only endpoint ΔPR, median ± bootstrap SE, n=10;
- all ten endpoint network values;
- exact two-sided paired sign-flip test of endpoint ΔPR against zero (all 2\^10 sign patterns); report exact raw p;
- also report BH-adjusted q across the two endpoint structural tests 6a/6b, without relabelling q as p;
- retain the complete finite-lambda descriptive table for source completeness.
The manuscript wording should call this **Δ participation ratio relative to intact/reference anticipatory control**, not “Block−Control”, because this sweep is not yet the final Block model.
### Fig. 6b — weakening anticipatory control does not reproduce below-null reorientation
Reuse the existing current Main B source and appearance.
- same x-axis/sweep/end point as 6a;
- ordinate: alignment deficit = expected − observed alignment, percentage points;
- positive means below-null/reorientation greater than expected; negative means observed alignment remains above the covariance-matched null;
- all ten networks plus median ± bootstrap SE;
- empirical Block alignment deficit remains reference/context.
No simulation rerun is required.
**Manuscript-ready statistics required**
- feedforward-only expected−observed alignment deficit, median ± bootstrap SE, n=10;
- all ten endpoint deficits;
- exact two-sided paired sign-flip test against zero; raw p;
- BH q across the two endpoint structural tests 6a/6b;
- complete finite-lambda descriptive table.
### Fig. 6c — final effective model schematic
Reuse/redraw the current Main C concept only as needed for clean standalone formatting.
Show:
- recurrent motor-cortical network;
- common base preparatory input;
- cerebellar-dependent target-specific state-setting component `b`;
- cerebellar-dependent state-dependent anticipatory/prospective feedback `L`;
- downstream movement-generating dynamics and two-link arm;
- Intact retains b+L; Block removes both.
No statistics. State explicitly that this is an effective functional decomposition, not anatomical segregation.
### Fig. 6d — calibrated preparatory dimensionality: experiment versus model
Reuse the existing current Main G source exactly, renumbered/extracted as a standalone panel.
Show experimental Control↔Block PR and model Intact↔Block PR. Mark the model comparison explicitly as a **geometry calibration target, not independent validation**.
No model rerun.
**Manuscript-ready statistics required**
- model paired Block−Intact ΔPR, median ± bootstrap SE, n=10;
- all ten paired network ΔPR values;
- exact two-sided paired sign-flip test against zero; raw p;
- BH q across the two final-geometry structural effects 6d/6e;
- absolute Intact and Block model PR medians ± bootstrap SE;
- empirical calibration target value and its source;
- state explicitly that only the paired ΔPR effect, not the absolute condition means, entered calibration.
### Fig. 6e — calibrated preparatory reorientation: experiment versus model
Reuse current Main H source exactly, renumbered/extracted as standalone.
Show experimental observed↔expected alignment and model observed↔expected alignment. Mark as a **geometry calibration target, not independent validation**.
No model rerun.
**Manuscript-ready statistics required**
- model paired alignment deficit = expected−observed, median ± bootstrap SE, n=10;
- all ten paired network deficits;
- exact two-sided paired sign-flip test against zero; raw p;
- BH q across 6d/6e;
- absolute model observed and expected alignment medians ± bootstrap SE;
- empirical calibration target and source.
### Fig. 6f–h — representative movement panels — UPDATED 3 Oct 2026 (successful-trial visualization pool)
This instruction **supersedes every earlier Fig. 6f–h display-selection rule**, including the fallback-to-failed-trials implementation. Fig. 6f–h are illustrative only and must not alter any inferential result, aggregate behavioral statistic, calibration, prediction analysis, model parameter or statistical unit.
**Freeze the representative network and reuse the completed visualization-only attempt pool**
- Keep the representative network fixed at **network 8**. Do **not** reselect the network.
- Reuse the saved visualization-only attempts from `fig6fgh_successful11`; do **not** launch additional simulations for this revision.
- Those attempts used the frozen final model, Intact and Block conditions, all eight targets, and primary noise `s_init=0.10`, `s_temporal=0.10`, with a separately documented deterministic visualization-only seed/stream family.
- Success remains first entry into the existing 1.5-cm peripheral target zone before the frozen 600-ms movement horizon; movement end for a successful visualization trial is that first-entry sample.
- All attempted trials, including failures, remain retained for audit. Failed attempts are never displayed and never enter the successful-trial summaries.
- The saved pool already contains at least **4 successful trials for every target × condition**, which is sufficient for revised Fig. 6f.
- For Fig. 6g/h, use only targets that accumulated **30 successful trials in both Intact and Block within the first 500 attempts per condition**; do not extend any pool beyond the existing saved attempts.
- This successful-trial pool is **for Fig. 6f–h visualization only**. Do not filter, replace, rerun or reinterpret the validated all-trial datasets used for any quantitative manuscript analysis.
**Ideal straight-path RMS — replaces RMS to the condition mean**
For each target, define the ideal spatial path as the straight line segment from the central target center to that peripheral target center. For every trial, using only samples from movement onset through its defined movement end, compute at each hand-position sample the shortest Euclidean distance to this center-to-center line segment. Define
`pathRMS_i = sqrt(mean_t(distance_to_ideal_line_segment(t)^2))`.
This is the only RMS used for representative selection. Do **not** rank trials by deviation from the condition-specific mean trajectory.
**Successful-trial display ranking — UPDATED: high-deviation successful examples**
Within each target × condition, use saved **successful visualization trials only** and rank them by **descending** `pathRMS_i`. No unsuccessful trial may be used as a fallback.
- Fig. 6f displays the **4 successful trials with highest pathRMS** for each target × condition.
- Fig. 6g/h display the **10 successful trials with highest pathRMS** for the selected representative target, separately within Intact and Block.
- This reversal affects only the individually displayed example trials. The representative network, representative-target eligibility/ranking rule, Fig. 6g all-30-success median, Fig. 6h all-30-success inset distribution/median position, and every manuscript-facing quantitative result remain unchanged.
Use deterministic attempt/trial ID as the tie-breaker for an exact RMS tie. Save pathRMS, descending display rank, attempt/trial ID and target-entry time for every selected successful trial.
Because these are deliberately selected high-deviation successful examples, caption/provenance must state this explicitly; do not describe the selected thin trajectories themselves as typical or statistically representative.
**Representative network**
Network 8 is frozen from the latest validated representative-network selection and is used for all Fig. 6f–h panels. The new successful-trial simulation is **not** used to reselect or compare networks.
**Representative target selection for Fig. 6g/h**
Within network 8, define eligibility using the already saved attempt pool:
1. A target is eligible only if it accumulated **30 successful Intact trials and 30 successful Block trials within the first 500 attempts in each condition**.
2. Verify the eligible set directly from the saved attempt audit (based on the completed run this should be targets 1, 2, 3, 6 and 8; do not hard-code the set without checking).
3. For each eligible target, rank its first 30 Intact successful trials by pathRMS.
4. Define the Intact target display score as the mean pathRMS of the **10 lowest-pathRMS Intact successful trials**.
5. Select the eligible target with the lowest Intact target display score; target ID breaks an exact tie.
Block performance therefore determines **eligibility only**; quality ranking remains Intact-based. Save the full eligibility table, success/attempt counts, all eligible-target scores and the selected target.
This is an explicitly outcome-selected illustrative example, not an inferential or typicality claim; caption/provenance must disclose the deterministic display-selection rule.
**Colors**
For **Fig. 6f only**, target 1 is bottom center and targets 2–8 proceed counterclockwise. Use exactly this manuscript target colormap:
```matlab
cmap = [
    1.0000    0.0000    0.1600
    1.0000    0.6010    0.0000
    0.2549    0.4118    0.8824
    0.0000    1.0000    0.1476
    0.2510    0.8784    0.8157
    0.3137    0.7843    0.4706
    0.4827    0.0000    1.0000
    1.0000    0.0000    0.7500
];
```
For **Fig. 6g and Fig. 6h**, because only one representative target is shown, do **not** use that target's target-specific color. Use the same condition colors as the experimental manuscript:
- Intact / Control: sky blue `[86 180 233]/255`;
- Block / cerebellar block: vermillion `[213 94 0]/255`.
Use these condition colors consistently for thin trajectories/profiles, thick summary traces, peak-speed-position markers and inset distributions as applicable.
### Fig. 6f — illustrative model-generated reaches
Use network 8 and show all eight targets. For each target × condition:
- from the saved successful visualization trials, display the **4 highest-pathRMS successful trials** as thin spatial trajectories;
- all displayed trajectories terminate at first target-zone entry;
- compute the thick mean trajectory from **those exact same 4 selected successful trials only**, after time normalization: normalize each selected trial from movement onset (phase 0) to first target-zone entry (phase 1), linearly interpolate x and y independently onto a common **101-point normalized movement-phase grid** including both endpoints, then average x and y across the four selected trials at each phase sample;
- therefore the thick mean is the time-normalized mean of the four displayed high-deviation successful trajectories, not an all-trial or all-success mean;
- use the target-specific 8-color map above;
- preserve target geometry/zones and identical spatial axes/aspect ratio for Intact and Block.
No inferential statistic is attached to Fig. 6f. Caption/provenance must identify these as deliberately selected high-pathRMS successful examples for visualization.
### Fig. 6g — illustrative hand-speed profiles
Use network 8 and the representative target selected from the saved `fig6fgh_successful11` visualization-only attempt pool according to the current eligibility/ranking rule. For each condition:
- display the **10 highest-pathRMS successful trials** as thin speed profiles;
- terminate each thin profile at that trial's first target-zone entry;
- the **10 displayed thin profiles remain unsmoothed**; only the thick median trace is smoothed, matching the experimental visualization convention;
- for the thick trace, align all **30 successful visualization trials** to movement onset and set each trial's samples after its first target-zone entry to NaN;
- at each real-time sample, compute the raw pointwise median speed across the successful trials that are still active at that sample; also save `nActive(t)`, the number of contributing trials;
- determine the display cutoff independently for each condition as the **last time sample for which ****`nActive(t) >= 15`** (at least half of the 30 successful trials still contribute);
- to avoid an artificial smoothing edge at this cutoff, first compute the raw median over its **full available temporal support beyond the 15-trial cutoff**, then apply the same existing **50-ms Gaussian smoothing used for the experimental median trace** to that complete raw-median trace, and **only after smoothing truncate the displayed thick trace at the ****`nActive >= 15`**** cutoff**;
- smoothing must not zero-pad missing values or treat post-entry samples as zero. At the true beginning/end of the available raw-median support, use the existing boundary-renormalized/truncated Gaussian handling so edge attenuation is not introduced;
- save the raw median, smoothed median, `nActive(t)` vector and exact display cutoff for both conditions so this display rule is auditable;
- use sky blue for Intact and vermillion for Block, not the target-specific color;
- **all Intact and Block thin and thick profiles must be solid lines**; do not use a dashed Block line;
- all manuscript/aggregate peak-speed statistics remain based on the already validated all-trials unsmoothed analysis and are unchanged;
- no aggregate-statistics subplot.
**Manuscript-ready statistics required for the Results text remain unchanged**
Across all ten networks using the existing target-averaged unsmoothed peak-speed metric:
- absolute Intact peak speed median ± bootstrap SE in m/s;
- absolute Block peak speed median ± bootstrap SE in m/s;
- within-network percent reduction `100*(Intact−Block)/Intact`, summarized as median ± bootstrap SE;
- all ten individual percentage reductions;
- established paired-network test name, n and exact p.
The representative panel is not the statistical unit.
### Fig. 6h — illustrative hand-position dispersion at peak speed
Use the exact same network, representative target and **same 10 highest-pathRMS successful trials per condition as Fig. 6g**.
**Empirical Fig. 1e is the graphical template.** Before rendering, visually inspect the current experimental Fig. 1e in live `Main_text_v10` and reproduce its panel organization and graphical logic as closely as possible: same condition-overlay/separation convention, same trajectory/peak-position relationship, same inset placement/type, comparable target/scale-bar treatment and comparable axis presentation. Do not substitute a different distribution visualization or a different panel arrangement merely because it is easier to generate.
For Intact and Block:
- plot those ten successful trajectories terminated at first target-zone entry, using the empirical Fig. 1e trajectory layout;
- all condition trajectory lines are **solid** and use the condition color;
- add the model-specific **black dashed reference line from the central target center to the selected peripheral target center**; this ideal center-to-center path should be visually subordinate and must not obscure the empirical-style trajectory display;
- filled circles mark each displayed trial's hand position at its own unsmoothed peak speed before target entry, following the same visual convention as empirical Fig. 1e;
- use sky blue for Intact and vermillion for Block, not the target-specific color;
- compute the condition-specific median peak-speed position from **all 30 successful visualization trials** for the selected target;
- the inset must use the **same histogram/distribution display style as empirical Fig. 1e**, showing Euclidean distances of all 30 successful trials' peak-speed positions from the corresponding condition-specific median position; do not base the inset on only the displayed ten;
- the ten trajectory/circle examples remain deliberately selected high-deviation successful examples for display only.
Caption/provenance must state that the displayed trajectories are the ten highest-pathRMS successful examples, distinguish them from the all-30-success inset summary, and identify the black dashed line as the ideal center-to-center path.
**Manuscript-ready aggregate statistics remain unchanged**
Use the already validated speed-matched dispersion analysis, not the representative example:
- eligible networks = 1,2,3,6,7,10; n=6;
- frozen matching rule: ≤5% within-target peak-speed mismatch, ≥5 matched pairs/target, ≥5 eligible targets/network;
- Intact and Block dispersion median ± bootstrap SE in cm;
- within-network percent increase `100*(Block−Intact)/Intact`, median ± bootstrap SE;
- all six individual percent increases;
- exact paired test name and exact p;
- retain the unmatched all-ten-network descriptive robustness values, clearly labelled non-primary.
### Fig. 6i — Intact prep→early-movement prediction versus noise
Scientific content remains the current Main I, but densify the displayed x-axis using the fixed seven-point grid:
`[0.05, 0.075, 0.10, 0.125, 0.15, 0.175, 0.20]`.
Two one-factor curves:
- initial-state sweep: vary s_init over the seven points, hold s_temporal=0.10;
- temporal sweep: vary s_temporal over the seven points, hold s_init=0.10;
- the 0.10/0.10 anchor is one shared dataset;
- dashed = initial-state noise; solid = temporal noise;
- y-axis = absolute Intact cross-validated prep→early-movement R²;
- use the existing prediction pipeline exactly.
Reuse the already validated 0.05, 0.10 and 0.20 source cases exactly. Simulate/refit **only** the four intermediate amplitudes for each one-factor sweep. Use the same frozen standardized noise identities/streams scaled to the new amplitudes. No interpolation and no outcome-dependent resampling.
The denser points are **descriptive/visualization only**. Inferential tests remain restricted to the original prespecified three levels 0.05/0.10/0.20.
**Manuscript-ready statistics required**
For the original three-level initial-state sweep:
- Intact R² median ± bootstrap SE at each level;
- Friedman repeated-measures test across the ten matched networks: chi-square statistic, df=2, exact/returned p.
For the original three-level temporal sweep:
- Intact R² median ± bootstrap SE at each level;
- Friedman chi-square, df=2, p.
Also list all ten network values for each original level and all seven descriptive medians/SEs.
Do not assume the initial-state effect is nonsignificant: report the result as obtained. If the current manuscript wording “had little effect” is not supported by the planned test, flag this explicitly for user revision.
### Fig. 6j — relative Block prediction deficit versus noise
Scientific content remains current Main J, with the same seven-point denser x-axis and same new intermediate simulations as 6i.
Within each network:
`relative Block loss (%) = 100*(R2_Intact−R2_Block)/R2_Intact`.
Show initial-state and temporal one-factor curves using the same conventions as 6i. Reuse old 0.05/0.10/0.20 cases exactly; generate only intermediate amplitudes. The 7-point curves are descriptive; inference remains the original 3-level family.
**Manuscript-ready statistics required**
Temporal sweep at 0.05/0.10/0.20:
- relative Block loss median ± bootstrap SE at each level;
- explicitly provide low-noise and high-noise values for direct insertion into the sentence “increased from xx ± xx% to xx ± xx%”;
- Friedman chi-square, df=2, p.
Initial-state sweep at 0.05/0.10/0.20:
- relative Block loss median ± bootstrap SE at each level;
- Friedman chi-square, df=2, p.
List all ten network-level relative losses for each original point and all seven descriptive summaries.
Do not assume “comparatively insensitive” unless supported by the planned test; flag wording if necessary.
## Extended Data Fig. 7
### Extended Data Fig. 7a — shared state-setting calibration grid
Reuse **exactly the current model Extended Data Fig. 5a 6×6 calibration-loss grid**, with no rerun and no scientific change.
- shared alpha grid = \[0.10,0.20,0.35,0.50,0.75,1.00\];
- shared beta_norm grid = \[0.10,0.25,0.50,0.75,1.00,1.25\];
- same selected point alpha=0.5, beta_norm=1.25;
- preserve the exact loss definition/source values.
Only rename/re-export as **Extended Data Fig. 7a** in the v3 bundle.
No inferential statistics required. The page should state the selected parameter pair, loss, and that only empirical ΔPR and alignment deficit entered calibration.
### Extended Data Fig. 7b — which cerebellar-dependent components are required for prep→movement prediction?
This is the one new component-removal analysis.
Use the same graphical logic as the current prospective-variability ED1D, but the dependent variable is **prep→early-movement cross-validated R²**.
Predeclare and use one fixed stress-test noise point:
- `s_init=0.20`;
- `s_temporal=0.20`.
Run the exact final prediction pipeline for the same ten frozen networks and four fixed policies:
1. Intact (b+L)
2. −L (b only)
3. −b (L only)
4. Block (−b,−L)
Use identical standardized noise identities/streams across matched policies. No post-GO noise. No parameter/model/geometry change. Do not try another noise point after seeing the result.
Display:
- all ten network values;
- thin paired connectors;
- median ± existing whole-network bootstrap SE;
- explicit policy labels above.
**Predeclared inferential family**
Three planned paired contrasts versus Intact:
- −L versus Intact;
- −b versus Intact;
- Block versus Intact.
For each contrast:
- compute within-network paired ΔR² and report median paired effect;
- use the established exact two-sided paired sign-flip test over all 2\^10 sign patterns;
- report raw exact p;
- Benjamini–Hochberg correct across these three contrasts and report q;
- retain all ten paired differences.
Also report absolute R² median ± bootstrap SE for all four policies.
Do not write or select the interpretation in advance. The manuscript currently contains placeholders asking whether full Block is required and whether either single-component removal is sufficient. The new page must explicitly state which of the three planned contrasts is significant after correction. If either single removal significantly reduces R², flag the existing manuscript wording for revision rather than tuning or changing the analysis.
Retain movement/QC flags at 0.20/0.20; do not exclude trials/networks because outcomes look pathological. If prediction is undefined anywhere, report it and stop for review rather than changing the noise point.
## 4. Manuscript placeholder checklist
The new “Final Paper Figures v3” page must finish with a compact copy/paste table containing exactly these values:
- 6a: feedforward-only ΔPR median ± SE; exact p; q.
- 6b: feedforward-only alignment deficit median ± SE (pp); exact p; q.
- 6d: Block−Intact model ΔPR median ± SE; p/q; empirical target.
- 6e: model alignment deficit median ± SE (pp); p/q; empirical target.
- 6g: Intact and Block peak speed medians ± SE; percent reduction median ± SE; exact paired test/p.
- 6h: Intact and Block speed-matched dispersion medians ± SE in cm; percent increase median ± SE; exact paired test/p; n=6.
- 6i: Friedman chi-square(2), p for Intact R² across original initial-noise levels; Friedman chi-square(2), p across original temporal-noise levels; three medians ± SE for each.
- 6j: temporal relative Block loss at 0.05 and 0.20 (plus 0.10) median ± SE; Friedman chi-square(2), p; corresponding initial-sweep Friedman statistic/p and medians.
- ED7b: absolute R² median ± SE for all four policies; paired ΔR², raw exact p and BH q for −L, −b and Block versus Intact; a one-line outcome statement saying which removals are significant after correction.
Use manuscript-scale rounding alongside full precision, but never discard full-precision source tables.
## 5. Validation
Independently verify:
- all manuscript-facing quantitative results/statistics outside the representative Fig. 6f–h visualization update remain identical to their current validated sources;
- no additional simulation is run in this revision: reuse the saved network-8 visualization-only attempts from `fig6fgh_successful11`;
- Fig. 6f uses only saved successful trials; Fig. 6g/h use only targets that reached 30 successes in both conditions within the first 500 attempts/condition;
- all attempted visualization trials, including failures, are retained in an audit table with seed/stream identity and success flag;
- success is first entry into the existing 1.5-cm target zone before the frozen 600-ms horizon;
- pathRMS is computed against the ideal center-to-center straight line segment, never against a condition mean trajectory;
- network 8 remains frozen and is not reselected using the saved visualization-only pool;
- Fig. 6g/h target eligibility is derived from the saved audit as 30 successes in both conditions within the first 500 attempts/condition; expected eligible targets are 1, 2, 3, 6 and 8, but this must be verified rather than hard-coded; among eligible targets, selection is Intact-only using the mean pathRMS of the 10 lowest-pathRMS Intact successes;
- Fig. 6f displays exactly the four **highest-pathRMS** successful trials per target/condition, with no unsuccessful fallback, and its thick mean is computed from those exact same four displayed high-deviation successes after 0–1 movement-phase normalization and interpolation onto the 101-point grid;
- Fig. 6g displays the ten **highest-pathRMS** successful trials per condition as **unsmoothed** thin solid traces; the thick trace remains the pointwise median of all 30 successful trials aligned to movement onset, with post-entry samples NaN, and **only this median** is smoothed with the existing 50-ms Gaussian; the raw median is computed over its full available support before smoothing, the displayed smoothed median is then truncated at the last sample with `nActive >= 15`, and no zero-padding/post-entry samples contaminate the smoothing; Intact is sky blue `[86 180 233]/255` and Block is vermillion `[213 94 0]/255`;
- Fig. 6h uses the exact same ten highest-pathRMS successful trials as Fig. 6g, all condition trajectories are solid, its all-30-success inset uses the same histogram/distribution style and overall graphical organization as empirical Fig. 1e, and a black dashed center-to-center ideal-path reference line is present without obscuring that empirical-style layout;
- the existing aggregate Fig. 6g/h behavioral statistics and every other quantitative model analysis remain based on their validated datasets and are not refit/recomputed from the success-conditioned visualization pool;
- Fig. 6g provenance saves the raw median, smoothed median, `nActive(t)` and exact condition-specific `nActive >= 15` cutoff; all new/current panel FIGs reopen and source objects/labels/error bars match source tables;
- MATLAB Code Analyzer passes modified/new MATLAB files;
- current final-v3 manuscript-facing source tables and all code needed for current figures remain preserved.
## 5A. Final Paper Figures v3 Notion-page cleanup
After the revised Fig. 6f–h panels are validated, clean the Notion page **“Final Paper Figures v3”** so it contains only the current manuscript-facing material.
Retain:
- one concise current status callout;
- the current frozen-model/statistical conventions needed to interpret the figures;
- exactly one current section for each Fig. 6a–j and Extended Data Fig. 7a,b, containing the current image, concise caption-ready definition, manuscript-ready statistics and essential current source/provenance links;
- the current downloadable source-table bundle/link and the latest committed report/commit SHA;
- a short **Archive / superseded checkpoints** note with links/SHAs to historical reports if provenance needs to remain discoverable.
Remove from this page:
- superseded 2 Oct / earlier Fig. 6f–h images, selection tables and narrative;
- duplicate historical status callouts;
- redundant execution logs and repeated source tables already preserved in committed reports/files;
- superseded five-/seven-level Fig. 6i/j narrative when the current four-level version is present;
- duplicate caption/statistics blocks that are not the current manuscript-facing result.
Do **not** delete underlying historical repository files, source tables or committed reports; this is a Notion-page presentation cleanup only. Re-fetch the page after editing and verify that all current panels/statistics remain present and no current content was accidentally removed.
## 6. Storage state after completed cleanup
The dependency-aware bulk cleanup was already completed successfully under checkpoint `54c965d8083dd51b30b4b67894d2a5ec6a62e439` (approximately 501.020 → 201.677 GB). **Do not perform another broad historical-cache deletion in this Fig. 6f–h revision.**
- preserve the retained current final-v3 dependencies and all protected source inputs from the completed cleanup;
- create only the compact sources/provenance and figure outputs required for this revised display-selection analysis;
- remove only temporary/scratch files created by this new revision when they are no longer needed;
- report the final project-folder size and confirm that no previously retained dependency was deleted.
## 7. Git commit/push — authorized after successful Fig. 6f–h revision
After the revised Fig. 6f–h validation passes and the retained storage/dependency state is confirmed:
- run `git status` and inspect the complete tracked diff;
- ensure no raw caches, large generated binaries, credentials, temporary files or unrelated changes are staged;
- commit only intended tracked code/documentation/provenance changes with a clear commit message describing the high-pathRMS successful Fig. 6f–h display update, time-normalized four-trial Fig. 6f means, all-30-success Fig. 6g median/inset summaries, empirical-style Fig. 6h layout with black dashed ideal path, and Final Paper Figures v3 Notion-page cleanup;
- push normally to the **main** branch;
- no force push, rebase, reset, amend or history rewrite;
- verify local HEAD, tracking main and remote main agree after the push;
- report the commit SHA and final project-folder size.
## 8. Final stop boundary
After the successful normal push to main, **STOP FOR SCIENTIFIC REVIEW**.
No model retuning, new geometry search, alternate ED7b noise point, convergence analysis, prospective-Q manuscript promotion, release/tag replacement or manuscript editing is authorized by this task.
</content>
</page>
