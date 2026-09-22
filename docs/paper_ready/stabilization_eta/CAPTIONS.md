# Stabilization-eta figure legends

These are separate diagnostic figures. They do not replace the completed
alignment95, panel-e or RRR figures and do not nominate a new model parameter.
Numerical outcomes and validation are reported in REPORT.md after completion.

## Shared residual stabilization: six-panel diagnostic

Ten frozen networks, eight targets and 30 balanced trials per target are evaluated
at eta=1,0.75,0.5,0.25,0. Intact (sky blue) retains structured prospective feedback
L; full Block (vermillion) lacks L. Both conditions use the same eta*kappa0 residual
stabilizer. The state-setting term b_eta is recomputed consistently, preserving
x* and xB as their intended equilibria. Lambda10, alpha0.5, beta_norm1, V1, networks,
noise amplitudes, trial streams, timing, movement drive, readout and arm are frozen.
Native integration is0.2ms; saved sampling1ms; preparation analysis sampling10ms.
The preparation noise ends at GO. Every movement starts from its achieved GO
state, without reset, post-GO noise or correction. Eta1 is reused from completed
validated evidence, not newly simulated. Thin curves show individual networks;
colored summaries show the network median plus/minus bootstrap SE of that median
using the same frozen10,000 whole-network resamples throughout. The independent
unit is network, not target, trial, fold or bootstrap draw. No eta is selected.

**A. Local stability.** The spectral abscissa is the largest real eigenvalue of
the actual condition-specific closed-loop ReLU Jacobian in physical s^-1 units.
The worst of eight target equilibria is summarized per network. Zero marks the
local stability boundary. Local asymptotic stability is not evidence of complete
500ms settling, stochastic contraction or normal movement.

**B. Systematic equilibrium bias.** For each target, compute the Euclidean
distance from the trial-mean GO internal state to its own intended equilibrium:
x* for Intact and xB for Block. Divide by that target's trial-mean cue-state
distance to the same equilibrium, then average the eight ratios within network.
Raw numerators and denominators are retained in target_metrics.csv.

**C. Trial dispersion.** For each target, compute the RMS Euclidean distance of
the30 GO internal states around their target-specific trial mean, then average
the eight target values. Identical raw model-state coordinates are used at every
eta and in both conditions. This is variability around the achieved mean, not
the bias of that mean relative to an intended equilibrium.

**D. Held-out model-native convergence.** This is a cue-to-pre-go analogue, not
the exact manuscript's pre-cue analysis. The same three fixed target-stratified
folds are used across every eta and condition. For each target/fold,20 reference
trials alone supply a preparatory PCA from unsmoothed normalized ReLU activity
sampled at GO-500:10:0ms. Retain the minimum PCs reaching at least95% of reference
variance; this retention threshold is an explicit predeclared model-analysis
choice. Ten held-out trials are projected into that basis. Average projected
states within the cue (-500:10:-400ms) and pre-go (-100:10:0ms) windows before
taking Euclidean distances from the corresponding reference window-mean states.
For each held-out trial, C=1-d_prego/d_cue. Positive values indicate contraction;
zero no net contraction; negative values divergence. Average trials, then folds,
then targets. Each trial is held out exactly once. Undefined cue denominators
are counted and remain undefined, never clamped or silently omitted. No held-out
trajectory contributes to its reference PCA or reference mean.

**E. Achieved geometry.** The upper mini-axis shows late-preparatory participation
ratio using all covariance eigenvalues. The lower mini-axis shows observed
Intact-onto-Block alignment (dark gray) and the covariance-shaped random-subspace
expectation (light gray). Rates are target-averaged in GO-100:10:0ms, divided by
the frozen reference neuron scales and stripped of the across-target invariant.
For each network/eta, Intact alone supplies the minimum K reaching at least95%
variance. This same K specifies the Block subspace, the Intact variance
denominator and the10,000-draw null. Existing network/K projectors are reused;
any missing K uses the unchanged sampler, covariance and seed. Absolute alignment,
expected-minus-observed deficit and K are retained in source tables.

**F. Neural prediction.** Use the already validated manuscript-matched procedure:
Gaussian-smoothed ReLU rates (SD30ms,1ms sampling,+/-150ms support with protected
epoch boundaries), frozen per-neuron normalization and removal of the aligned
across-target invariant. Average GO-100:10:0ms predictors and each trial's own
kinematic MO0:10:100ms responses. Epoch-specific PCA retains at least75% variance;
this full-balanced-ensemble PCA follows the requested manuscript procedure, not
strictly inductive foldwise feature learning. Target-stratified nested3-fold
ridge selects the penalty by pooled inner SSE from the fixed25-point grid.
R-squared pools all outer held-out predictions. No flagged trials are dropped;
an unavailable required window makes the condition unevaluable rather than
triggering selective exclusion. Paired Block-relative R-squared reduction is
tabulated, not used to choose or reject eta. No RRR or new inferential family.

## Supporting movement QC

All24,000 condition/eta/network/target/trial observations are retained, including
the4,800 reused eta1 observations. Top and middle summary axes show network
medians plus/minus the fixed whole-network-bootstrap SE for movement onset,
peak time, peak speed, within-target endpoint RMS and target separation/scatter.
For onset, peak time and speed, the within-network summary is the trial median.
Endpoint RMS is computed within target around its endpoint centroid and averaged
across targets; it is not endpoint error relative to the instructed target.
Target separation/scatter is the median of28 between-target centroid distances
divided by the mean within-target endpoint RMS.

QC-count curves show boundary peaks (solid) and multiple large peaks (dashed),
without treating flagged trials as exclusions. MO is the first saved speed sample
reaching20% of its own positive peak. A near-zero peak is <=1e-8m/s. Missing-window
flags retain the frozen neural-horizon rule. Multiple large peaks are local maxima
at least50% of the trial peak, greedily separated by at least20ms. The report also
lists finite-state/input/arm checks and all unchanged preparation-bound failures.
Bottom-row distributions pool trials descriptively:5th-95th-percentile whiskers,
25th-75th-percentile thick bars, and medians. Those pooled trials are not used as
independent replicates for uncertainty or inference.

## Supporting target-resolved kinematics

The predeclared example is network1, not selected for a favorable outcome. Columns
show all five eta values; row pairs show Intact and full Block hand trajectories
and unsmoothed speed profiles. Each target has a fixed color across all panels.
Thin traces are all30 individual trials; thick traces are target means. Every
trajectory uses the same deterministic accepted movement generator, readout and
arm from its achieved GO state. Unusual, asymmetric or boundary-peak movements
are retained. These panels support movement QC, not behavioral parameter selection.
