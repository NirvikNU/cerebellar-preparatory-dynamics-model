# Stabilization-eta production resume

Binding Notion resolution read 22 September 2026. Reuse the completed baseline,
preservation and all-eta equation/Jacobian audits; do not execute them again.
Only eta=0.75,0.5,0.25,0 Intact/Block preparation and deterministic movement are
new simulations. The eta=1 raw series, movement and prediction fits are read-only.
All new writers refuse to overwrite completed output. No staging/commit/push.

Panel D uses unsmoothed ReLU rates divided by the frozen neuron-specific reference
scale. For each target and existing prediction outer fold, train a PCA on the
51 preparation samples of the 20 reference trials only. Observations are
time-by-trial; columns are individual neurons. Center training observations and
retain minimum K reaching >=95%. Project window-mean states, subtract the matching
reference window mean, and compute C=1-d_prego/d_cue. The windows contain the
11 samples at -500:10:-400 and -100:10:0 ms. No across-target subtraction is used
in this target-matched convergence assay. Fold identities are identical for all
eta/conditions. Average held-out trials, folds, then targets arithmetically.
Undefined denominators are counted and remain undefined, not clamped or omitted.
This threshold is an explicit model-analysis choice, not an empirical-method claim.

Panel B uses the trial-mean GO internal state and its own equilibrium, divided
by the distance from the same target's trial-mean cue state to that equilibrium.
Panel C uses raw internal-state Euclidean coordinates, unchanged for every eta,
and RMS spread around the target GO mean. Both target summaries are arithmetic
means. Raw distances, denominators, target/fold/trial values are retained.

Panel E retains frozen reference normalization, target-invariant removal, all-
eigenvalue PR, and Intact95 K for Block projection/denominator/covariance null.
Existing projectors are reused by network/K; missing K uses the unchanged
10000-draw sampler and original network seed. Panel F uses the existing pure
PCA75/nested-three-fold ridge implementation; no additional RRR/shuffle family.
Original eta=1 observed fits are reused. No eta is selected.

New raw evidence includes all saved preparation/movement states, hand/torque
trajectories, native extrema and transition samples, folds and predictions.
Existing rate/state/input limits remain frozen at the baseline definition;
finite out-of-bound points and kinematic flags are reported, not excluded.
Any missing prediction window is explicitly unevaluable without dropping trials.

Independent saved-output audit: state metrics via direct target loops;
convergence via covariance eigendecomposition; geometry via neuron-column
construction/eigenanalysis; ridge via augmented normal equations; movement
events/endpoints and native transitions directly recomputed. Whole-network
median/bootstrap SE uses the original 10000 fixed network resamples and is
checked independently. Reopen FIG objects and inspect every matching PNG.
Only this diagnostic's new files may be written; prior scientific artifacts
and completed prediction/RRR outputs remain untouched. Stop for review.
