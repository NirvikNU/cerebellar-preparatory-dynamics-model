# Final parsimonious modelling figures v2 — legends

Numerical completion/validation is recorded separately in REPORT.md and the
audit receipts. Release verification is recorded in RELEASE.md and Notion.

## Common model and statistical conventions

Ten independent frozen 200-unit cortical networks each produce eight targets
and 30 trials/target. The final effective controller has eta=0, lambda=10,
V realization 1 and one globally shared alpha/beta pair selected from the
fixed 36-point grid. The selected values and loss are in geometry_selection.json.
With f(x)=-x+W ReLU(x)+h, the common base input is -f(xB), state setting is
b=f(xB)-f(xstar), and prospective feedback is -L(x-xstar). Intact retains both
cerebellar-dependent terms; full Block removes both. There is no generic
residual kappa feedback. This is a functional decomposition, not an anatomical
localization claim. Achieved GO states enter the frozen movement generator,
readout and arm without resetting or adding post-GO noise.

Primary initial and temporal noise scales are .10/.10 in model-state units.
The two one-factor sweeps vary .05/.10/.20, holding the other source at .10.
They share the same baseline and original standardized streams across all
conditions and levels; neither source nor a noise level is selected by outcome.
Native integration .2 ms, saved sampling 1 ms; no observation/spike noise.

Unless specifically labeled empirical uncertainty, points are medians across
ten networks and error bars are bootstrap SE of the network median from the
same frozen 10,000 whole-network resample rows. Targets, trials and folds are
not independent replicates. Paired effects are formed within network before
summary. Negative results, undefined quantities and QC flags are retained.
Available paired n and undefined counts are in the source tables/report.

## Main Fig A–J — Parsimonious preparation model

**A–B: motivation from the validated prospective-feedback-only effort sweep.**
These panels reuse frozen Stage-2 results rather than re-fit a controller.
Increasing lambda restricts re-optimized prospective feedback. A shows paired
PR change from lambda=.1, with the empirical DeltaPR construction target.
B shows expected minus observed control-to-lambda alignment, with zero and
the empirical deficit target. These historical controls use their original
common >95%-variance rule, covariance null and whole-network bootstrap;
they are labeled controller-restriction provenance, not new eta=0 calibration.
The unchanged arrays document the previously reported failure of feedback
restriction alone to reproduce the joint dimensionality/reorientation effects.

**C: final effective architecture.** Common cortical dynamics/base input are
shared within each Intact/Block pair. Intact adds state setting b and structured
prospective stabilization L. Block removes these terms only. No residual
kappa feedback is included in this final schematic or model.

**D: representative movements.** Predeclared network1, all eight target colors,
Intact and Block with matched axes. Pale thin lines are single trials; thick
lines are target means. Filled target zones have radius1.5 cm. Each displayed
trajectory, including the target mean, ends at its first target-zone entry;
non-entering paths use all available samples in the nominal600-ms movement
epoch (actual frozen arm samples0..599 ms). This is display-only: event,
behavioral and prediction arrays remain complete and untruncated. No network
or target was selected by movement appearance.

**E: position dispersion at own peak speed.** The 2D model analogue uses each
trial's hand position at its own unsmoothed peak-speed time. Trials are matched
one-to-one within target using the empirical active greedy matcher: ascending
abs(vIntact-vBlock)/abs(vBlock), cutoff5%, without trial reuse. For each retained
target/condition, dispersion is the mean Euclidean distance from the coordinate-
wise median position; target values are equally averaged within network.
Empirical coverage criteria are at least5 matched pairs/target and5 targets.
All matching counts/indices and unmatched descriptive values remain available;
insufficient coverage is explicitly undefined, never rescued by retuning.
Thin connectors/pale dots show paired network values. The manuscript's
Anderson-Darling test at.05 on paired differences chooses a two-sided paired
t-test if normal, otherwise a two-sided Wilcoxon signed-rank test. Exact test,
p and available paired n are reported in behavior_statistics.json. No trial-
level inference or outcome-based exclusion is used.

Speed-matched hand-position dispersion; 6/10 networks met the prespecified matching criterion.
Main E is explicitly conditional on eligible networks 1, 2, 3, 6, 7, 10;
networks 4, 5, 8, 9 are undefined here only. Median +/- bootstrap SE uses
10,000 paired resamples of the six eligible networks with the original
bootstrap seed 2026091000. Wilcoxon signed-rank, n=6, p=0.03125.
The 5% mismatch, five matched trials per condition/target and five eligible
targets/network criteria are unchanged. No missing value is imputed.
The separately labelled unmatched all-ten-network robustness control is in
DISPERSION_CONTROL.md and full-precision dispersion_unmatched_all10.csv;
it uses all 30 trials/target and is not the primary Panel E assay. All other
model panels retain ten networks.

**F: speed profiles and peak speed.** Left: predeclared network1/target2, all
single-trial speed profiles and condition medians; only median visualization
uses a50-ms Gaussian window, following the manuscript convention. Right:
trial peak speeds are averaged within target, then equally across targets
within network. The same paired-network display/test rule as E applies.
Event detection, dispersion and peak-speed summaries use unsmoothed frozen
arm velocities; visualization smoothing does not redefine events.

**G–H: disclosed geometry calibration targets.** Experimental pooled estimates
and their original resample SD are taken directly from the frozen empirical
FIG extraction; resamples are not treated as independent biological units.
Model dots are ten paired networks, with median plus network-bootstrap SE.
G shows Control/Intact versus Block PR; H observed versus expected alignment.
The same single shared alpha/beta pair minimizes the two target-normalized
squared deviations of network-median DeltaPR and alignment deficit over the
full6x6 grid. Only these two preparatory-geometry effects enter calibration.
Model proximity to G/H is therefore not independent inferential validation.
The selected shared pair is alpha=0.5, beta_norm=1.25; beta is at the upper
boundary of the fixed grid, which was not expanded. Absolute condition means
were not fit. The imperfect paired effects and all 36 candidate scores are
retained rather than described as exact empirical reproduction.
PR uses the complete spectrum. For each network, Intact supplies the minimum
K reaching >=95% variance, also used in the Block basis, Intact normalization
and original10,000-draw covariance-constrained null. Preprocessing retains
the frozen per-neuron scales and across-target-invariant removal over late
preparation GO-100:10:0. Full-precision deficits/K/capture are in source tables.

**I: prediction vulnerability to preparation noise.** The two black traces
distinguish initial (dashed) and temporal (solid) one-factor sweeps. The ordinate
is100*(R2_Intact-R2_Block)/R2_Intact computed within network, not a ratio of
marginal medians. Nonpositive/numerically zero Intact R2 makes this ratio
undefined; absolute R2 and DeltaR2 remain available. .10 marks the fixed primary
condition, not a favorable-noise choice. There is no empirical target band.

Prediction reuses the manuscript-matched committed procedure: unsmoothed
source states become ReLU rates; boundary-protected SD30-ms Gaussian smoothing
at1-ms sampling, frozen neuron scales and aligned across-target-invariant
subtraction; one vector/trial from GO-100:10:0 and own kinematic MO+0:10:100.
Separate epoch/condition full-balanced-ensemble PCAs retain minimum>=75%
variance. This feature learning is disclosed as not foldwise. Target-stratified
nested3-fold ridge uses fixed folds,25 logspace(-8,4,25) penalties, mean-SSE
scaling, unpenalized intercept and fixed tie rules; R2 pools outer-held-out
predictions. Existing matched-PC and100 fixed correspondence shuffles support
the primary results. No RRR or new decoder is run for v2.

**J: corrected pre-cue convergence vulnerability.** Same noise/line conventions;
ordinate DeltaC=C_Block-C_Intact, not percent, with zero reference. Each trial's
single state immediately before cue/controller onset is xsp+s_init*z_init.
There is no simulated pre-cue period and no post-cue sample in d_precue or its
reference mean. Each same-target fold has20 reference/10 held-out trials;
reference-only PCA uses existing normalized unsmoothed GO-500:10:0 preparation
and minimum>=95% variance. The single pre-cue sample and GO-100:10:0 window mean
are projected into that basis and compared with corresponding target-specific
reference means. C=1-d_prego/d_precue, followed by unchanged trial/fold/target/
network aggregation and denominator guard. Reference PCA may use post-cue
reference activity; baseline states/distances may not. Raw distances, ratios,
K/capture and undefined counts are retained. Changing initial noise changes
the denominator; C alone is not proof of fixed-equilibrium stability or of
convergence mediating prediction. I/J are descriptive prespecified sensitivity
curves, with no added post-hoc testing family.

## Extended Data 1 — Intact noise sensitivity

A: absolute Intact PCA75-ridge R2. B: corrected single-pre-cue convergence C.
Initial and temporal sweeps use sky blue dashed/solid traces, individual
network lines and median plus bootstrap SE, with the shared .10 anchor marked.
The same methods and caveats as Main I/J apply. These curves show effects of
noise within Intact; Main I/J show paired condition vulnerability, not a claim
that only Block is noise-sensitive.

## Extended Data 2 — Functional component contributions

At frozen shared geometry and primary noise, the four policies retain [b,L]
as [1,1], [1,0], [0,1], [0,0]. Identical base input and standardized draws are
used within every comparison. PR, Intact-derived Control95 alignment deficit,
corrected C and PCA75-ridge R2 are shown. Network values/medians/SE are
descriptive; no altered hypothesis family is borrowed from historical tests.
No component is selected or tuned to these downstream outcomes.

## Extended Data 3 — Controller-effort/readiness provenance

Frozen lambda grid [.1,.2,.5,1,2,5,10,100], final eta=0 and frozen selected
geometry; noiseless eight-target preparation only. A compares current eta=0
and historical eta=1 target-median readiness, showing the original75-ms timing
target and frozen lambda10 without reselection. B shows normalized prospective
Q error at lambda10. Readiness is the first saved1-ms sample at which Q error
is <=10% of cue value and remains so at every subsequent native.2-ms step
throughGO. Unreached thresholds remain undefined. C shows Frobenius gain norm
versus effort penalty. Timing provenance is not a behavioral/prediction fit.

## Extended Data 4 — Movement and event QC

All five prespecified noise pairs, Intact and Block, including primary and
both source extremes. Panels show within-target endpoint RMS, target-centroid
separation divided by within-target scatter, near-zero peaks, missing own-MO
prediction windows, boundary peaks and multiple large peaks. Counts are per240
trials/network; networks remain the independent summary unit. Frozen definitions
and every flagged trial are retained. Finite neural prediction does not by
itself establish physiologically normal movements. Full target/trial data and
rate/state/input extrema accompany the figures; no QC enters geometry fitting.

## Extended Data 5 — Calibration and analysis controls

A–C show all36 shared-grid losses, DeltaPR and alignment deficits, with the
globally selected point. No network-specific geometry fit or downstream screen
is used. D records Control-derived>=95% K by network, used unchanged for the
Block projection and null. E shows primary observed PCA75-ridge R2, paired
matched-PC fits and100-shuffle median floors. Full controls, negative values
and feature-learning scope are retained. The final text panel explicitly
separates the two fitted geometry effects from out-of-objective behavior,
convergence and prediction. Historical K15, eta, RRR and prior noise results
remain provenance rather than being overwritten or promoted to v2 panels.

## Source locations

All v2 compact outputs/tables: results/paper_ready/final_v2/.
Shared figure master: figure_sources.mat; panel map: PANEL_SOURCES.md.
Raw trajectories/fits: ignored results/paper_ready/cache/final_v2/ and exact
reused caches identified by the loaders/receipts. They are local reproducibility
assets, not a claim of a public clean-room rerun. Renderers and analysis code
live under figures/paper_ready/final_v2/ and analysis/paper_ready/final_v2/.
