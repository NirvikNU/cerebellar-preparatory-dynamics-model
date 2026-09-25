# PAPER-MODELLING-FINAL-FIGURES-V2-01 — prospective execution plan

Locked before new numerical evaluation, 25 September 2026. Authority: current
top Agent Instructions (Notion 3c826c94be30817d8f51d9f6c8c2bc19).
Starting release: 93e9d517d47b48579ef9d5bda6adacc44bf039d7. All old science,
including the uncommitted noise-sensitivity bundle, is protected provenance.

## Calibration gate

Eta=0, lambda=10, V realization 1, all ten frozen networks, eight targets,
30 trials/target, s_init=s_temporal=0.10. Alpha=[.10,.20,.35,.50,.75,1]
and beta_norm=[.10,.25,.50,.75,1,1.25]. Evaluate all 36 shared points in all
ten networks, not network-specific fits. Reuse frozen constructed xB values
and standardized streams; do not reconstruct population directions.

Intact input = -f(xB) + f(xB)-f(xstar) - L*(x-xstar); Block input=-f(xB).
There is no residual kappa term. Intact is algebraically independent of xB:
reuse its validated eta=0 trajectories after checking the algebra/evidence.
No movement, convergence, prediction, safety/QC or historical feasibility
screen enters candidate ranking. Nonfinite/undefined required geometry is a
stop, not permission to skip a point or introduce a screen.

Use existing frozen neuron scales, late preparation GO -100:10:0, target
means, across-target invariant removal, and Control-only minimum >=95%
variance K for comparison width, denominator and covariance-constrained
10,000-draw null. PR uses the complete spectrum. The exact current targets
are DeltaPR=2.6453333944 and deficit=16.802184 percentage points.
Loss is the sum of the two squared relative deviations of network-median
paired effects. Exact equal minima stop. No legacy tolerance/tie breaker.
Write all 360 rows, 36 ensemble rows, independent audit, and a single shared
selected-point receipt before any downstream analysis starts.

## Frozen sampling and reuse

Native dt=0.0002 s; tau=0.15 s; save 1 ms; preparation -500..0 ms.
Initial draw precedes 200x2500 temporal draws in each mt19937ar stream.
Seed=310000000+10000*network+100*target+trial. No new/reordered draws.
Initial offset=s_init*z; increments=s_temporal*sqrt(2*dt/tau)*xi.
No post-GO/observation noise. Frozen deterministic movement/readout/arm.
Noise pairs: [.05,.1;.1,.1;.2,.1;.1,.05;.1,.2]. Reuse the same .1/.1
anchor in both displayed sweeps. Reuse geometry-independent eta=0 Intact
trajectories/features/fits; reuse Block only if the frozen geometry matches.
Component flags [b,L]=[1,1;1,0;0,1;0,0], primary noise only.

## Corrected convergence

Single pre-cue state=prep.initial=xsp+s_init*z; verify equals saved sample 1.
Use normalized ReLU rates; no simulated pre-cue period. Ref-only PCA on
GO -500:10:0, fixed same-target three folds, 20 reference/10 held-out;
minimum >=95%, unchanged centering and denominator guard. Pre-cue mean
and held-out distance use ONLY the single sample, never a window.
Pre-go uses GO -100:10:0 window means. C=1-d_prego/d_precue.
Retain all distances, ratios, K/capture, folds and undefined counts;
unchanged trial/fold/target/network arithmetic averaging. Audit separately
by covariance eigendecomposition and an explicit no-baseline-leakage test.

## Prediction and uncertainty

Reuse committed boundary-protected SD30ms smoothing, normalized/invariant-
removed features, GO -100:10:0 and own MO 0:10:100 means, full-ensemble
epoch-specific PCA75 (not foldwise feature learning), nested three-fold
ridge, logspace(-8,4,25), fixed folds/seeds/ties and pooled held-out R2.
Run only missing fits and the existing matched-PC/100-shuffle controls.
No RRR or selecting a noise point. Independent observed and matched fits;
bounded shuffle refit: permutation 1, network 1, every new dataset.
Check all permutations, saved selections and summaries.

Ten networks are independent. Reuse frozen 10,000 whole-network bootstrap
indices, median +/- bootstrap SE. Form paired effects per network first.
R2 relative loss undefined for nonpositive/numerically zero Intact R2;
retain absolute values and flags. E/F: Anderson-Darling on paired differences
at .05; two-sided paired t if normal, otherwise signed rank. ED2 descriptive
paired effects only; no changed/recycled inferential hypothesis family.
G/H explicitly calibration targets, not independent validation.

## Behavioral source and display

Main_text_v8, Drive 1ZMY8I_aalyKtAfdE4Sz_uoO4zE8v3W_E0d-_s0T09gI,
Methods behavioral/statistics paragraphs, and read-only empirical source:
G:/My Drive/Monkey_codes/combined_analyses/supporting_functions/plot_related/
regression_neural_behavior_V3/behavior_plotting_functions/plot_behavior_v2.m.
Read-only source SHA256:
49B4D72DD63622AD8208B28A593050B53FE62F55D2F38B71433426C20DCD28DA.
The same behavioral definitions, normality/test rule and50-ms display window
were also confirmed in the newer Main_text_v9, Drive
1_KoX6j5ouWWn411g_3C9SwW5Ulm0vKAI0cap8aKplqI (24 September version).
Peak-speed position dispersion: target-wise mean Euclidean distance from
condition-specific coordinate-wise median position. Empirical matching
sorts all within-target abs(vC-vB)/abs(vB) pairs ascending; greedily consumes
each trial at most once, cutoff .05, stable original column-major tie order.
Record matches/coverage. Source minimum is 5 pairs/target and 5 targets;
report missing/insufficient evidence rather than fabricate or conceal it.
The model is intrinsically 2D; no extra fitted empirical coordinate mapping.
Peak speed: arithmetic mean per target, then equal-target network mean.
Reuse frozen own-peak/MO events and preserve all raw/QC-flagged trials.
Representative network 1, speed target 2. Speed median visualization only
uses a 50-ms Gaussian smoothing window, never metric/event arrays.
Target circles radius .015 m; display-only first target-entry truncation.
Existing 600-sample arm arrays span 0..599 ms; show all available samples
for non-entering paths, label the nominal 600-ms epoch and disclose the
last sampled time. Do not extend frozen dynamics to invent another sample.

## Outputs and gates

Dedicated final_v2 code/docs/results/manifests; ignored cache/final_v2.
Main A-J plus ED1 noise, ED2 components, ED3 readiness, ED4 movement QC,
ED5 calibration/controls, each native FIG+PNG in its specified identity
folder. Full-precision source tables/legends. A/B reuse validated Stage-2
effort restriction results; distinguish those historical controller tests
from final eta=0. ED3 bounded noiseless timing-only provenance sweep with
eta=0, frozen geometry/lambda choices; never select lambda anew.

Independently audit equations, full-grid loss, no outcome leakage, stream
reuse, convergence, PR/alignment, features/ridge, behavior/events, paired
bootstrap/statistics, plotting sources and visual FIG/PNG integrity.
Only then publish native figures on existing page04; preserve page02/99.
Only then inventory cleanup decisions, update README/code index, review
staged diff, make the one specified normal commit (including prior noise
bundle), push v3, guarded nondivergent main fast-forward and normal push,
verify every local/tracking/direct remote SHA and clean worktree/index.
Update Notion status/log after actual verification. Stop on scientific,
preservation or synchronization discrepancy. Never repeatedly poll jobs.
