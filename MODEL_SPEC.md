# Stage-1 movement-generator specification

## Accepted scope

Stage 1 is ACCEPTED — FROZEN: the first ten independently generated
source-faithful ISNs passing all predeclared checks for eight 10-cm targets.
Each has its own recurrent matrix, spontaneous state/baseline, calibrated
common readout and eight calibrated movement initial states. The unchanged
released Kao realization is a separate benchmark, not an ensemble member.
Preparation awaits a separately authorized design task.

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
not a specification for the new architecture. No new model is implemented.
