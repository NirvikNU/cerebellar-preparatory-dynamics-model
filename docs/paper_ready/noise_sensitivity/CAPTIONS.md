# Final preparation-noise sensitivity — full figure legends

These are proposed Extended Data robustness diagnostics, not a new primary model
or a quantitative model-data fit. Prior corrected geometry, prediction/RRR and
stabilization results remain unchanged. No noise amplitude or eta is selected.

## Figure 1 — absolute Intact/full Block curves

Two one-factor sweeps separate initial cue-state noise (left column; temporal
scale fixed at0.10) and ongoing preparation noise (right; initial scale fixed
at0.10). Each varied scale is0.05,0.10,0.20 in the original model-state units,
not Hz or an inferred common physiological magnitude. Sky blue is Intact and
vermillion full Block; solid lines eta0 and dashed eta1. Points and error bars
are the median across ten independent networks plus/minus bootstrap SE of that
median using the released10000 whole-network resample rows. Pale lines retain
individual networks. The vertical0.10 marker denotes the reused baseline,
not an outcome-selected optimum. Both columns share that same anchor evidence.

Eight targets and30 balanced trials/target are nested within each network.
Five unique noise pairs across two conditions/two eta endpoints give200 cases:
40 reused anchors and160 new cases (38400 new trials;48000 total). Networks,
alpha0.5,beta_norm1,V1,lambda10,kappa0,L,Q/P and movement/arm rules remain frozen.
Both conditions receive identical eta*kappa0 residual stabilization and the
eta-dependent offset is recomputed to preserve their intended equilibria.
Specifically, `u0_eta=-f(xB)-eta*kappa0*(x-xB)`,
`Intact=u0_eta+b_eta-L*(x-x*)`, and full `Block=u0_eta`, with
`b_eta=f(xB)-f(x*)+eta*kappa0*(x*-xB)` and `f(x)=-x+W*ReLU(x)+h`.
Thus full Block removes both effective cerebellar contributions, not only L;
this is not a counterfactual that isolates feedback at a common equilibrium.
Intact retains structured prospective feedback L; Block has no L. Eta0 removes
only the added generic residual stabilizer, not intrinsic recurrence or
target-setting offsets. Identical standardized initial and process draws are
scaled across conditions/eta/levels. The cue offset is s_init*z; native
Euler-Maruyama increments are s_temporal*sqrt(2*dt/tau)*xi with dt0.2ms and
tau150ms. Save1ms, prepare GO-500:0ms. All preparation inputs and process noise
end at GO; the achieved state launches unchanged deterministic movement,
without reset, post-GO or observation noise.

**A,B: PCA-to-ridge prediction.** Boundary-protected Gaussian smoothing (SD30ms,
support+/-150ms), frozen neuron scales and aligned across-target-invariant
removal precede trial-window means at GO-100:10:0 and own kinematic MO0:10:100.
PCA is estimated separately for each epoch/condition/dataset on its full balanced
ensemble, retaining the minimum PCs reaching75% variance. This is the released
manuscript-matched full-ensemble feature procedure, not strictly inductive
foldwise feature learning. Fixed target-stratified nested three-fold ridge uses
25 penalties logspace(-8,4,25), the mean-SSE penalty convention, an unpenalized
intercept and unchanged tie rules. R2 pools outer held-out predictions as
1-SSE/SST; negative values are retained. Existing matched-PC and100 fixed
correspondence-shuffle controls are in the supporting full-precision tables.

**C,D: held-out model-native convergence.** The unchanged helper uses unsmoothed
normalized ReLU activity GO-500:10:0. In each fixed same-target fold,20 reference
trials alone define a centered PCA, retaining minimum PCs reaching95% variance;
10 held-out trials are projected without whitening. Distances are between
window-mean projected states and the corresponding target-specific reference
window means: cue GO-500:10:-400 and pre-go GO-100:10:0. Trial C=1-d_prego/d_cue
is averaged trials, folds, targets within network; each trial is held out once.
The released numerical denominator guard is unchanged; undefined cases remain
undefined. Negative C and the zero line are retained. This is a model-appropriate
cue-to-pre-go analogue, not the unavailable empirical pre-cue assay and not a
distance to one fixed equilibrium. Changing initial noise changes its denominator;
a C sign change alone is not evidence for changed dynamical contraction.

All QC flags remain included. Bounds or required-window failures are retained
as unevaluable affected estimates, never rescued by selecting good trials.
The report tabulates every case, raw distances, reference K/capture, Control95
PR/alignment, movement events and endpoint/target-scatter QC. No new inferential
family or claim that convergence mediates prediction is introduced.

Sources: results/paper_ready/noise_sensitivity/summary.mat, network_metrics.csv,
target_metrics.csv, trial_metrics.csv, shuffle_controls.csv and ensemble_summary.csv;
raw evidence in ignored results/paper_ready/cache/noise_sensitivity. Matching
native files: plots/paper_ready/noise_sensitivity/fig/noise_sensitivity_absolute.fig
and png/noise_sensitivity_absolute.png. Renderer ns_figures.m; unchanged released
eta_convergence, pe_features and stage3_prediction_ridge assays. The independent
audit and full numerical outcomes accompany this caption in REPORT.md.

## Figure 2 — within-network condition effects

The same one-factor sweeps, shared anchor, frozen trials and endpoint eta values
as Figure1. Solid dark-gray curves show eta0, dashed light-gray curves eta1;
pale lines are individual networks. All three levels, zero references and
baseline markers are retained. Error bars again use the fixed10000 whole-network
bootstrap rows; targets/trials/folds are not independent replicates.

**A,B: relative Block prediction loss.** For each network compute
100*(R2_Intact-R2_Block)/R2_Intact before taking the network median. Positive
means lower Block R2. When Intact R2 is nonpositive or numerically zero the
percentage is undefined/uninterpretable; raw R2 and absolute Block-minus-Intact
deltaR2 remain in paired_metrics.csv and available n is reported. This is not
a ratio of marginal ensemble medians.

**C,D: paired convergence difference.** Compute C_Block-C_Intact within each
network before summarizing; negative means lower Block C. Zero/negative/reversed
effects are not filtered. The raw numerator and denominator are retained, so
relative convergence can be distinguished from initial-cloud changes.

These disclosed follow-up diagnostics test only two one-factor sweeps and two
eta endpoints. They do not test noise interactions, establish general robustness,
select an eta/noise pair, demonstrate causal mediation of prediction, or fit
experimental percentages. Geometry and movement QC are supporting checks, not
selection criteria. Native pair: noise_sensitivity_paired.fig/png in the same
figure roots as Figure1; source summary/paired_metrics.csv and ns_figures.m.
Negative and mixed results are reported without retuning.
