# Stage-1 movement landscape: locked diagnostic plan

STAGE1-MOVEMENT-LANDSCAPE-DIAGNOSTIC-01; Notion revision
2026-09-15T10:02:44.077Z; checkpoint2d98681ba83be063ffdcae3a661d12bff9f8b0b9.
Stage1 remains accepted/frozen; no existing scientific asset may change.
No Stage3 reanalysis or new model. Git preflight passed (existing dangling
objects are informational); preserve all scientific assets before numerical work.

## Predeclared choices, before outcomes

Ten networks/eight targets. Frozen dt0.2ms, saved1ms, tau150ms, exact original
movement input/readout/arm and evaluation horizon. Baseline reproduction uses
the existing80-movement QC check once before new figure creation, plus new
state-saving wrapper equality with original cortex/arm output. Saved states
are time x neuron x target; full native baseline states are neuron x time x
target, and native perturbation norms are time x trial. These storage layouts
are explicit; do not substitute rates for states.

Frozen-alpha grid0:0.1:5. Deterministic semismooth Newton root solver:
physical field numerator F=-x+W*ReLU(x)+h+alpha, exact active-set derivative
-I+W*diag(x>0), at most100 steps, residual infinity norm<=1e-10,
backtracking factors2.^-(0:20), Armijo decrease1e-4. Singular Jacobians
(rcond<1e-12) use fixed pseudoinverse tolerance1e-12. Record every attempt
and failed convergence; no outcome-driven solver relaxation.
Deduplicate roots by Euclidean distance<=1e-7*max(1,norm(root)).
Local stable=maxRealEig< -1e-7/s, unstable>1e-7/s, otherwise marginal;
coordinates abs(x)<=1e-8 are flagged nonsmooth, not assigned unqualified
local stability from one active set. Report residuals and minimum abs state.

At every grid alpha use xsp, eight xstar, all eight actual movement states
at saved100/300/500ms, and xsp plus/minus .01*medianPairwiseLaunchDistance
along three fixed isotropic vectors (seed2026091500+network). Four fixed
passes: forward, backward, forward, backward. Include all roots at the
neighboring grid point and existing same-point roots. Preserve pass discovery
counts and forward/backward cross-checks; never claim exhaustive enumeration.
Branch lines only connect roots with identical active sets and mutually
matching continuation; exact affine interpolation then satisfies the field.
Active-set changes/unmatched endpoints appear as gaps, not invented joins.
At each actual saved alpha(t), root-correct all roots from both bracketing
grid points at the exact drive, deduplicate, compute nearest stable-root
distance for each target. This avoids interpolating across unverified branches.
Missing stable roots are explicit NaNs/gaps, not zeros; report coverage.
Report normalized distance (median pairwise launch distance) in addition to
raw state Euclidean distance. 'Close' means <=1% of that launch scale,
fixed now as a descriptive threshold, not a scientific acceptance rule.
Save full-vector-field norm/tau at every actual movement sample.

Fixed example network1/T3(0degrees). Plane origin xsp, axis1 normalized
xstar_T3-xsp, axis2 orthogonal component of state at own peak hand speed
minus xstar_T3. Stop if axis2 norm<=1e-10*max(1,displacement norm), or if
that event lacks a saved state. Snapshots: GO0ms, exact analytic drive-peak
time (log(decay/rise)*decay*rise/(decay-rise)), decay400ms.
31x31 plane grid, common limits from projected actual path, launch, xsp and
snapshot roots, padded15% of each span. Evaluate at xsp+plane*coordinates;
project full200D field, show off-plane equilibrium displacement in caption/
table. These are projected snapshots, not autonomous2D dynamics.

Q eigensystem from symmetric(frozenQ); sort descending, sign each vector
by making its largest absolute component positive for reproducibility.
Potent top5, null bottom5, random10 isotropic unit vectors seeded2026091600+n.
Same vectors across targets, both signs; fractions[0 .01 .025 .05 .10 .20]
of median of28 pairwise launch distances. Compute amplitude0 once/target;
its amplification is undefined0/0, plotted as a gap, other changes0.
Run16000 nonzero movements (10*8*20*2*5) with no process noise/controller.
Save raw state differences/norms, torque, arm and exact initial states.
Maximum amplification uses native0.2ms states, including initial/final;
save native maximum/time plus1ms norm curves. Full same-target unperturbed
native trajectory supplies the comparator, without time/event warping.

Early hand RMS is Euclidean2D discrepancy over unperturbed MO+[0:200]ms;
MO is first saved speed>=20% own unperturbed peak. Endpoint is original
arm evaluation horizon: report deviation from unperturbed final position,
absolute error from intended target and change in that error. Peak-speed
change is signed perturbed peak minus unperturbed peak (each own full horizon).
Torque RMS uses all saved time x two torque coordinates, source units.
Aggregate arithmetic mean over directions within each class/sign, then
equal targets, then median across10networks. Keep both signs separate,
including signed speed changes; no cancellation by averaging signs in plots.
Use existing bootstrap_network_median convention10000 draws, fixed seed
2026091500, shared across all outputs. No new inferential family. Optional
2D perturbation heatmap omitted: four required sensitivity panels suffice.

Cache-only output organization: additionally summarize the already-declared
neural norm time courses at all 599 saved 1-ms times, with the same nested
network aggregation and bootstrap convention. No additional replay or analysis
parameter is introduced. The raw native-time norms remain preserved; this
compact companion makes the requested norm-over-time evidence accessible.
Its independent uncertainty spot checks use fixed saved times
0/100/200/400/598 ms for every class/sign/amplitude (180 checks).

## Validation, publication and completion

Independent root residual/active-set linear solves, Jacobian columns via
finite differences away from kinks, dedup distances, continuation reciprocal
matching and gaps, projected arrows, direction norms/Q eigen residuals,
amplitude scale and seeds, representative independent metric/arm/native-step
checks, all bootstrap SE from separate direct formulas. All outcomes retained;
stop material identity/validation discrepancy, do not tune.

Two new FIG/PNG pairs diagnostic_9_movement_landscape and
diagnostic_10_launch_sensitivity in plots/stage_1/diagnostics/movement_landscape/
{fig,png}; preserve the exact original eight canonical pairs and their bounded
validator's eight-pair contract. This additive output location is fixed before
figure generation; only matching PNG/FIG ignore exceptions are added. Compact
analysis results/stage_1/current/movement_landscape_diagnostic; raw ignored
results/stage_1/cache/movement_landscape_diagnostic. Current report here.
All generated numeric assets remain ignored under existing Stage1 policy;
report/validation receipts and figure pairs/code checkpoint normally.
No numeric-output ignore change or forced inclusion of native caches.

Update existing Stage1 parent/spec/summary/Diagnostics (Results short link),
management handoffs/log/task in place, preserving native hierarchy/images.
No extra task pages or new hierarchy. Code Analyzer on new MATLAB,
bounded smoke/reference checks, preservation hashes, figure reopening/visual
inspection and native publication readback before one normal commit/push.
Safe main fast-forward only if no unique commits; verify all refs/directremote
equal and clean. Stop for scientific review.
