# Frozen foundation and current preparatory-model specifications

## Accepted scope

Stage 1 is ACCEPTED — FROZEN: the first ten independently generated
source-faithful ISNs passing all predeclared checks for eight 10-cm targets.
Each has its own recurrent matrix, spontaneous state/baseline, calibrated
common readout and eight calibrated movement initial states. The unchanged
released Kao realization is a separate benchmark, not an ensemble member.
STAGE2-LAMBDA-SWEEP-01 separately authorizes full-dimensional optimal-feedback
preparation on this frozen foundation. Stage 2 awaits scientific review.

Source: Kao, Sadabadi & Hennequin, Neuron 2021, *Optimal anticipatory control
as a theory of motor preparation: A thalamo-cortical circuit model*; official
source pinned at `40077d2da16e68ab2ab2cff59ec692b97315980b`.
See `THIRD_PARTY_PROVENANCE.md` for attribution and licensing.

## Cortical movement generator

For each member j, 200 threshold-linear units comprise 160 excitatory and
40 inhibitory neurons:

`r = max(0, x)`

`tau dx/dt = -x + W_j r + h_j + alpha(t) 1`.

Cortical tau is 150 ms, Euler integration 0.2 ms, saved sampling 1 ms.
W obeys exact outgoing-column Dale signs and has zero diagonal.
The common target-independent movement input is the unchanged normalized
difference of exponentials with 50-ms rise, 500-ms decay and source-unit
peak 5. Rates are source units, not a fitted Hz scale.

`h_j = x_sp,j - W_j max(0, x_sp,j)` preserves each spontaneous fixed point
in the absence of movement input. To release target q, initialize at that
member's own calibrated `x*_{q,j}`. Target identity resides in the initial
state, not a target-specific movement drive.

## Output, arm and targets

The fixed rank-2 excitatory readout `Ce_j` is 2x160.
The stored full readout is `C_j = [Ce_j, zeros(2,40)]`, 2x200.
Shoulder/elbow torques are `m = C_j r = Ce_j r_E` and drive the exact
published planar two-link arm. Saved torques are passed to the unchanged
1-ms arm implementation.

Target radius is 0.10 m, at angles
`[-90, -45, 0, 45, 90, 135, 180, 225]` degrees.
The target hand/torque layer, each calibrated state/readout pair, common
movement drive and all arm parameters are frozen.

The states are movement-valid initial conditions, not guaranteed unique
optima, movement-period equilibria, or a manifold of any prespecified
dimensionality. Rank-2 motor output does not imply rank-2 neural organization.

## Prospective motor potency

In normalized time `s=t/tau`, the source full-active approximation is

`d(delta)/ds = A delta`, with `A=W-I`.

Integrated future output error is `J(delta_0)=delta_0' Q delta_0`, where

`A'Q + QA + C_j'C_j = 0`.

Q ranks future-output sensitivity, not neural-variance PCA. The actual
generator remains ReLU, with active-set physical-time Jacobian
`(-I + W D)/tau`, `D=diag(x>0)`; it is not replaced by a globally linear
approximation. No Q, readout or recurrent matrix is rederived by cleanup.

## Acceptance and frozen results

One predetermined recurrent/calibration seed pair was used per candidate;
a failed candidate would not receive another seed or relaxed criterion.
The first ten attempts passed: 10 attempted, 10 accepted, zero rejected.

| Criterion | Existing threshold |
| --- | --- |
| Absolute target angular error | 2 degrees |
| Absolute radial error | 0.01 m |
| Endpoint error | 0.02 m |
| Weighted torque cost | 0.002 |
| Source calibration movement cost | 0.0005 |
| Architecture/dynamics | Dale signs, zero diagonal, construction stability and finite values |

Accepted recurrent seeds: 2026083110–2026083119.
Paired calibration seeds: 2026084110–2026084119.
Recorded maxima: angular error 1.806438 degrees; radial error 0.00267021 m;
endpoint error 0.00363731 m; weighted torque cost 0.000499408.
All 80 target rows independently revalidated.
Existing deterministic regression requires saved audit metrics to reproduce
within 1e-12; cleanup does not alter the acceptance or regression thresholds.

Member 1 is the first accepted candidate, not a downstream-selected example.
Its preserved diagnostics include potency PR 9.21648; 50/80/90/95% potency in
4/8/12/15 dimensions; cortical/motor/endpoint mapping R-squared
0.999748/0.999438/0.892168; maximum real movement eigenvalue
-1.27561 per second; maximum sampled transient gain 3.59887; mean/median/max
rates 1.31354/1.30788/2.60096 source units.
The all-trial potency/error Spearman value 0.714596 is descriptive, not a
hard gate; high/intermediate/low potency bands remain completely ordered.

## Retained active-set diagnostic

Existing Stage-1 movement diagnostics and their two figure pairs are
retained unchanged: 72/80 movements have no threshold crossing; eight show
sparse switching in 0.5–1.5% of neurons. All 280 target-pair union active
sets have Jaccard overlap 1. Sparse switching can nevertheless cause material
errors under a GO-mask-frozen approximation. These are existing diagnostic
results, not recomputed evidence from the repository reset.

## Reproducibility and boundary

Accepted files remain in `results/stage_1/current/`; successful provenance
in `results/stage_1/audit_history/`; the eight canonical FIG/PNG pairs in
`plots/stage_1/{fig,png}/`; active-set files under Stage-1 diagnostics.
Use the explicit Stage-1 paths and bounded validation entry points described
in README. No accepted asset or canonical figure is regenerated by cleanup.

Current authority and outcomes are maintained in
[Agent Instructions](https://www.notion.so/3c826c94be30817d8f51d9f6c8c2bc19),
[Agent Log — Run Outputs](https://www.notion.so/3d326c94be3081e897a2e5e0c855c4c0),
[Agent Handoff](https://www.notion.so/3c826c94be308156a677c50c2106fb37) and
[START HERE](https://www.notion.so/3d226c94be308194adadf691ed5822a2).
Retired preparatory/comparison/phenotype work is external, historical and
not a specification for the new architecture.

## Stage 2 — full-dimensional optimal-feedback preparation

The pre-run methods and exact analysis plan are preserved in
`artifacts/manifests/stage2_lambda_sweep/PREREGISTRATION.md`. They were written
in Notion before the first Stage-2 simulation. This addition never changes
the accepted Stage-1 scientific payload.

For each member, use `A=W-I`, `B=I200` and the source-defined trace-200
normalization of the frozen observability Gramian. Solve
`A'P + PA - P*P/lambda + Q = 0`; the signed full-state gain is `K=-P/lambda`.
The nonlinear controller is `u=tonic+K*(ReLU(x)-ReLU(x*))`, with
`tonic=x*-h-W*ReLU(x*)`. Equivalently the pinned implementation adds
`x*-h-(W+K)*ReLU(x*)` and `K*ReLU(x)`. At GO remove preparation input and
feedback and use the unchanged Stage-1 movement drive/readout/arm.

The fixed sweep is `[0.1,0.2,0.5,1,2,5,10,100]`, reference 0.1. Standard
preparation is 500 ms; demonstration releases are 25/50/100/200 ms for member1.
Native integration remains 0.2 ms, saved sampling 1 ms, tau 150 ms.
STAGE2-LAMBDA-SWEEP-01-R2 supersedes only the three neural-geometry analyses.
Kinematic MO is each target/network/lambda's first saved hand-speed sample
reaching 20% of its own peak; it is not GO. The reference normalization/null
window concatenates -500:10:0 GO and target-specific -50:10:450 kinematic MO,
retaining overlap. Use the actual lambda0.1 per-neuron sample SD, with no
source-unit floor; stop for zero/numerically degenerate SD rather than dropping
neurons or inventing a scale. Apply that vector to all lambdas. Align each
target's epoch before removing target means per condition/relative time.

Diagnostic PR and reference-to-lambda alignment use GO -100:10:0 ms.
Results Figure3 uses lambda0.1 prep cue150:10:450 ms and movement kinematic
MO -50:10:350 ms. PR uses covariance eigenvalues. For each alignment pair,
find minimum counts K1 and K2 capturing strictly >95% variance; use common
K=max(K1,K2) for both numerator/denominator and all1000 covariance-biased null
draws. Reference prep variance is projected onto comparison PCs, normalized
by variance captured by reference's own K PCs. Networks (n10) are independent;
summaries are median with10,000-network-bootstrap SE and exact sign-flip/BH
tests. See R2_PLAN.md for indexing, seeds, numerical checks and scope.
The original floor/K15/GO=MO neural-geometry results are superseded; original
controller, prospective-error analysis, perturbations and Results Figures1-2
remain unchanged. No outcome-selected lambda or PC count is authorized.

The approved Fig.4F analogue uses isotropic Gaussian state perturbations,
SD0.10,100 trials per target, seed20260907, all80 network-targets,500ms,
reference lambda, no process noise. It measures squared state error in the
top/bottom-ten Q directions. Source-unspecified choices are explicit; this
is not claimed as an exact numerical reproduction. Initial norm/active-set
changes are descriptive and cannot trigger amplitude tuning.

Source-output prospective error uses `(ReLU(x)-x*)'Q(ReLU(x)-x*)`, distinct
from state error when negative coordinates occur. Both are saved and named.
Higher lambda restricts optimal-control usage normatively; it does not
represent a literal cerebellar lesion/circuit or establish new predictions.

## Stage 3 — cerebellar correction of cortical preparation

The complete derivation, bounded grid, limits, seeds and sampling rules are
predeclared in `artifacts/manifests/stage3_cortical_state_feasibility/`.
This new inverse-design model preserves the frozen Stage-1 generator and all
completed Stage-2 computations. It is not scientifically accepted until review.

For `f(x)=-x+W*ReLU(x)+h`, keep the cortical policy
`uC=-f(xB)-kappa*(x-xB)` identical within each intact/block pair. Add
`uCB=b-nu*(x-x*)`, with `b=f(xB)-f(x*)+kappa*(x*-xB)` when intact.
Block removes both sustained correction and state feedback, not feedback
alone. Gains are fixed from the frozen norm: `kappa=max(0,norm(W,2)-1)+3`,
`nu=3`. The full-state/full-actuation controller acts on subthreshold x too;
it is not an anatomically constrained E/I or learned cerebellar circuit.

Starting at the shared spontaneous state, prepare for 500 ms with native
0.2-ms Euler integration, 1-ms saved sampling and 10-ms analysis sampling.
GO removes all preparation inputs and releases the actual achieved state to
the unchanged movement drive, readout and arm; premovement output is gated.
No target-state reset or post-GO correction is introduced.

Freeze a new intact per-neuron SD and full covariance from GO -500:10:0 plus
kinematic-MO -50:10:450 before constructing block states. No SD floor or
Stage-2 scaling is imported. Settled target-centered normalized states have
factorization `YI=U*sqrt(Lambda)*Z`; retain every measured positive-rank
direction. `YB=(alpha*U*sqrt(Lambda)+beta*V)*Z` uses seeded orthogonal V,
the same target coordinates, and the intact target-mean rate baseline.
Negative proposed rates are infeasible, never clipped. Three directions and
a fixed 6-by-6 grid are screened in each of ten networks. Activity, separate
input components, state norms, total modulation and settling have finite
predeclared modeling bounds; they are not physiological estimates.

Primary geometry uses actual GO -100:10:0 trajectories. PR uses all covariance
eigenvalues; directed intact-to-block alignment uses the common maximum
minimum PC count strictly exceeding 95% variance and the intact top-K
variance denominator. The 10,000-draw covariance-constrained null uses this
Stage-3 intact full reference, with predeclared Monte Carlo margin. Settled
theorem and measured finite-window results are kept distinct.

The full analytical/physical/finite-window intersection determines feasible
solutions. A common primary and additional spanning samples are selected
without movement outcomes, and their complete policies are saved before
movement evaluation. Early hand RMS error uses each frozen comparator's
MO+[0:200] ms, common GO times across conditions, in millimetres. Networks
are independent n=10; multiple states/directions are nested. Geometry is
constructed, movement consequences are measured independently, and neither
implies a prediction deficit. Empty-region outcomes are retained unchanged.

### Fixed-gain/time mechanistic diagnostic

The primary geometry and accepted nu=3 policy remain unchanged. The separate
bounded descriptive diagnostic uses only nu=0:.5:6 at alpha=.1 and normalized
beta=1, with fixed kappa, cortical policy, selected states and initial states.
Compare uC+b-nu*(x-x*) against uC-nu*(x-x*) in all ten networks/eight targets.
Reuse valid original trajectories; integrate each missing gain/policy once,
without movement or reselection. Native .2 ms, saved 1 ms, population 10 ms.
Display endpoints GO=-600:10:0, with cue=-500: instantaneous full-200D state error and trailing
inclusive 100-ms PR/alignment. Both normalization and null bias remain the
original intact full-reference metric. Reference covariance in the alignment
numerator/top-K denominator is the intact trajectory's matching time window;
common K is minimum strictly >95% for both compared conditions. Reuse the
original seed and 10,000 covariance-biased random subspaces by network/K,
not a terminal expected scalar. The mean-projector trace is algebraically
the mean of those same draws and is independently audited against QR.
The source baseline h=xsp-W*ReLU(xsp) makes the frozen spontaneous state an
equilibrium. The controller-free -700:-500 segment is verified by native Euler
integration to match the frozen preparatory initial state; cached preparation
is reused unchanged. Before/at cue all targets are identical, so population
covariance is zero and PR/alignment are undefined (masked), not zero-valued.
The first valid population endpoint is -490 with the unchanged trailing window.
Network medians (n=10), no new inference; six independently scaled linear heatmaps in
Diagnostic Figure 2. All original four-policy GO cells must match preserved
metrics before replacement. This is an effective-controller decomposition,
not an anatomical assertion, tuning objective or new scientific acceptance.
Colors are not quantitatively comparable across panels. Every prior -400:0
value is independently rechecked and retained bit-for-bit in the expanded
output; original numerical/audit provenance is not overwritten.
