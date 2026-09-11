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

## Stage 3 — cerebellar state setting and prospective-error correction

Current implementation: STAGE3-BIOLOGICAL-CONTROLLER-RESUME-02. Scientific
acceptance remains subject to user review. The current plan/report are
`BIO_RESUME_PLAN.md` and `BIO_RESUME_REPORT.md` in the Stage-3 manifest folder.
The previous isotropic controller and REVISION-01 stop are historical; their
code/results and the frozen target geometry remain preserved.

For the unchanged intrinsic state dynamics `f(x)=-x+W*ReLU(x)+h`:

`u0=-f(xB)-kappa0*(x-xB)`

`b=f(xB)-f(x*)+kappa0*(x*-xB)`

`feedback=-L*(x-x*)`

Intact input is u0+b+feedback. Full cerebellar block removes both b and feedback,
leaving identical u0. Thus intact dynamics reduce to
`tau*dx/dt=f(x)-f(x*)-(kappa0*I+L)*(x-x*)`; Block reduces to
`tau*dx/dt=f(x)-f(xB)-kappa0*(x-xB)`. x* and xB are exact equilibria of
their corresponding conditions. Removing only feedback leaves x* an equilibrium;
removing b can change the equilibrium, not only convergence speed.

For each network, compute the largest real eigenvalue of
`M(e)=-I+W*diag(e>0)` across the eight primary xB and eight x*.
The fixed residual gain is `kappa0=max(0,1+max_e max(real(eig(M(e)))))`,
the minimum scalar shift giving the residual local margin -1/tau.
This is not the old global-norm gain or a movement/prediction fit. Check the
intact local Jacobian with L separately and native Euler stability. Local
stability is not a global nonlinear contraction guarantee.

L is the exact saved Stage-2 state-design CARE P divided by fixed lambda=.1,
using identical 200-dimensional internal-state coordinates, frozen Q and
normalized time t/tau. No new CARE solve, Q modification or strength sweep.
The Stage-2 nonlinear rate-feedback implementation and this state-feedback
law are explicitly different where ReLU coordinates are inactive. The frozen
CARE objective is the prospective-error approximation for its all-active
linear design plant; it is not claimed exactly optimal for every nonlinear
active set or the newly residual-stabilized plant.

The target construction is unchanged:
`YI=U*sqrt(Lambda)*Z`,
`YB=(alpha*U*sqrt(Lambda)+beta*V)*Z`.
Preserve all retained directions, neuron SD, target-mean rate baseline, seeded
V and target coordinates Z. Primary alpha=.1, betaNormalized=1, direction1
in all ten networks; no reselection. The same6x6x3x10 map reuses stored
definitions and unchanged analytical/nonnegativity/variance checks.
Recompute only controller-dependent endpoint/input/dynamic/finite-population
classifications. Actual trajectory covariance is not assigned from xB.

RESUME-02 explicitly retires only the old terminal Block relative-distance
cutoff1e-4 at500 ms; no new distance threshold replaces it. Keep exact stable
equilibria, nonnegative constructed rates, finite native trajectories, frozen
rate/state/variance limits and separately bounded controller components.
Each component remains bounded by5*Iref, where Iref=max(1,new intact maximum
total-input norm). Report all component maxima, including the map's
conservative counterfactual component checks; cancellation does not exempt
a component. These are modeling admissibility bounds, not empirical physiology.

Native preparation Euler step0.2 ms, saved1 ms, delay500 ms from cue-500 to
GO0. Frozen spontaneous baseline supplies validated support through cue.
Save each target's distance to x*/xB, state-quadratic E_Q, cue-normalized E_Q,
component norms, first50%/90% reduction crossings and50/100/200-ms values.
Finite convergence/readiness is reported, not fitted or required to be exact.
At GO remove preparation input and pass actual achieved state unchanged to
the frozen drive/readout/arm. Premovement output remains gated; no GO reset.

Population analysis retains frozen Stage-3 per-neuron SD and full-reference
null covariance. Target-center each aligned time; flatten time/target rows
with one neuron per column. Primary prep is GO -100:10:0. PR uses all covariance
eigenvalues; common K is the larger minimum count strictly exceeding95% in
both conditions. Intact covariance projects onto policy top-K PCs and is
normalized by intact top-K variance. The matched10000-draw null uses the
same frozen covariance-biased Gaussian/orth algorithm, seed2026090900+network;
mean projectors are reused by K and applied to each actual new intact window
covariance. Do not reuse historical terminal expected values.

Early movement consequence is RMS Euclidean hand discrepancy in mm against
the frozen comparator, at common comparator MO+[0:200] ms, then target mean.
Network n=10, median plus10000-whole-network-bootstrap SE with the original
saved index matrix/seed2026091000. Exact paired sign flips and the two-test
geometry BH family are unchanged; movement is a separate test. Geometry
constraints and movement consequences remain conceptually distinct.

Current Diagnostic2 compares Intact, remove feedback, remove b, Block over
GO -600:0 ms. Five panels show distance x*, distance xB, normalized E_Q,
trailing100-ms PR and expected-minus-observed alignment. Population endpoints
every10 ms use the matched new intact window; cells through cue are undefined
because target covariance is zero. Network median with descriptive bootstrap
SE; no inferential timing/gain search. The historical nu heatmaps, sampled
movements and gain/nonorthogonality sensitivity numbers are not current
biological-controller results.

This is an effective full-state/full-actuation computational hypothesis,
not an anatomical localization of the two cerebellar-dependent terms or
a dedicated biological cortical pathway for kappa0. That deterministic
evaluation contains no prediction/noise. The separately authorized experiment
below preserves all its parameters and results; learning/adaptation and
further model extensions remain excluded.

## Fixed-controller stochastic prediction-validation experiment

STAGE3-PREDICTION-VALIDATION-01 uses the unchanged four biological-controller
policies, all ten networks and eight fixed targets. Thirty independent trial
identities per target use the same standardized Gaussian draws across policies
and noise levels. Cue state is xsp+s*eta0. Continuous physical-time SDE:

`dx=F(x)/tau*dt+s*sqrt(2/tau)*dW`, with tau=.15 s.

Euler-Maruyama uses native dt=.0002 s and saves every .001 s. Primary s=.10
source-state units; .05/.20 are predeclared non-selected sensitivities. At GO,
remove preparation input without resetting the state and continue the same
noise stream through the frozen movement generator. No added readout/arm noise.
This is a reference perturbation scale, not a fit to empirical physiology.

Per-trial kinematic MO is the first speed reaching20% of its own peak; peak
time and physical x/y hand position come from that trial. ReLU rates are
smoothed with Gaussian SD30 ms, support+/-150 ms and renormalized protected
boundaries (GO, MO, or peak-50 ms). Apply the frozen neuron-specific Intact
reference SD, no empirical1-Hz floor, and aligned-time target-invariant
removal. Average GO -100:10:0, MO0:10:100, and prepeak -150:10:-50 ms.

Full-balanced-ensemble PCA is separate for predictor and response, each
retaining minimum >=75% variance. Primary neural prediction is outer3-fold
ridge with training-only inner3-fold selection, objective mean-SSE plus
lambda*||B||F^2, unpenalized intercept, fixed logspace(-8,4,25), no additional
standardization. Pool held-out predictions and compute1-SSE/SST around the
pooled actual mean; retain negative R2. Matched-PC controls use the smaller
paired-condition count separately per epoch.

Hand prediction uses full-ensemble target-mean PCA >=95%, then sequential
instructed x and null-projected y axes; pooled3-fold OLS and within-target
LOO OLS use this fixed plane. Peak-speed prediction uses full-neuron nested
ridge. A single full-condition refit axis is held fixed for secondary
within-target LOO and orientation. Captured variance uses outer-training
axes on held-out trials. Repeat behavior procedures in the prepeak epoch.
These full-ensemble feature definitions follow the binding manuscript scope,
not strictly inductive fold-wise feature learning.

Chance uses100 fixed neural response-correspondence permutations; expected
speed-axis squared-cosine alignment uses100 within-target speed-shuffle
refits. Networks n=10 are the independent units; reuse10,000 whole-network
bootstrap indices for median +/- SE. Nine primary s=.10 lesion-minus-Intact
contrasts (three lesions x neural/hand/speed R2) share one exact paired
sign-flip/BH family. All other controls are supporting, not rescue criteria.
No prediction outcome may tune model, noise, timing, seed, grid or inference.

Locked PREDICTION_PLAN.md, repair addendum, separate prediction outputs and
independent audit/report provide the execution provenance. Original
controller/geometry results and four existing figure pairs remain unchanged.

The completed fixed prediction experiment gives mixed support. At primary
s=.10, full Block reduces neural and hand-position R2 but increases the weak
peak-speed R2 relative to Intact; all three Block contrasts have q=.005859375.
The pre-peak hand deficit persists, and within-target preparatory hand R2 has
negative network medians under every policy. A general preparation-specific
prediction phenotype is therefore not established. All outcomes/sensitivities
are retained unchanged in PREDICTION_REPORT.md; scientific review is pending.
