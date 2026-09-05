# Motor Preparation Model

This repository contains one model developed sequentially through Stage 1,
Stage 2A, Stage 2B-Kao, and Stage 2B-Cerebellum.

## Current state

Stage 1 is **ACCEPTED — FROZEN**. The current project model is the first ten
independently generated source-faithful ISNs that passed every predeclared
movement-fidelity criterion for the eight experimental 10-cm reaches. Each
member has its own recurrent matrix `W_j`, calibrated common readout `C_j`, and
eight calibrated initial states `x*_{q,j}`. The released Kao realization is
preserved separately as an untouched source/provenance benchmark; the project
ensemble is not Kao's unpublished original ten-network ensemble.

Stage 2A is **ACCEPTED — FROZEN** under the predeclared conditional Gate-2
interpretation. The analytical target-specific tonic input was propagated
independently across all ten frozen Stage-1 members, with no training, noise,
or parameter change. Exact fixed-point Jacobians were stable for all 80
network-target pairs. The four historical 5-s full-state misses converged to
the intended fixed points during the authorized 40-s extension and were
94.09–99.15% low-potency by Euclidean residual energy. All original
mechanistic gates and the revised 2-mm endpoint gate passed. The historical
1% full-state threshold is retained as descriptive QC, not a hard gate.

Stage 2B-Kao is **ACCEPTED — FROZEN**. It reproduces the unrestricted
200-dimensional theoretical optimal-feedback controller from the pinned Kao
source and passes the source-equivalence gate. Stage
2B-Cerebellum is **ACCEPTED — FROZEN** after Gate 4B-C. It is a
separate 13-channel prospective-potency controller with the same derivation
but a fixed
13-dimensional actuator given by the leading eigenvectors of the frozen
prospective-potency matrix `Q`. Neither stage is a biological cerebellar
circuit or a learned network.

## Repository layout

- `config/` — stage-specific configurations and dependency checks.
- `src/published_generator/` — published cortical and arm forward models.
- `src/stage_2a/` — analytical tonic input and naive preparation dynamics.
- `analysis/published_generator/` — equivalence, potency, and smoke analyses.
- `analysis/stage_2a/` — convergence, movement-error, and acceptance analyses.
- `figures/published_generator/` — Stage 1 figure construction.
- `figures/stage_2a/` — Gate-2-aware five-figure construction code.
- `src/stage_2b_kao/` — published theoretical controller reproduction.
- `src/stage_2b_cerebellum/` — accepted 13-channel controller derivation.
- `analysis/stage_2b_shared/` — shared comparative and mechanistic analyses.
- `figures/stage_2b_shared/` — accepted Kao and Cerebellum figure construction.
- `results/stage_1/current/` — accepted 10-cm ensemble and canonical audits.
- `results/stage_1/audit_history/` — labeled benchmark and failed-run history.
- `results/stage_2a/current/` — accepted conditional Gate-2 ensemble results,
  diagnostics, audits, and machine-readable summaries for all 10 networks.
- `results/stage_2a/audit_history/` — the initial stopped-gate audit and the
  preserved prior single-network Stage-2A artifacts.
- `plots/stage_1/png/` — eight accepted presentation-ready PNG figures.
- `plots/stage_1/fig/` — eight matching editable MATLAB FIG files.
- `plots/stage_2a/png/` — five accepted ensemble presentation PNGs.
- `plots/stage_2a/fig/` — five matching editable MATLAB FIG files.
- `results/stage_2b_kao/` — machine-readable Stage-2B-Kao controller outputs.
- `plots/stage_2b_kao/{png,fig}/` — canonical figures for Stage 2B-Kao.
- `results/stage_2b_cerebellum/current/` — frozen Gate-4B-C audit, controllers,
  and network-first summaries (local/ignored).
- `plots/stage_2b_cerebellum/{png,fig}/` — four reviewed Gate-4D figure pairs.
- `workflows/stage_1/construction/` — authorized one-time construction and
  rejection-sampling runners, retained but not used for routine validation.
- `workflows/diagnostics/` — current deterministic diagnostic and presentation
  runners.
- `workflows/history/` — superseded runners retained with provenance labels.
- `third_party/kao_optimal_preparation/` — tracked attribution, checksums, and
  setup/verification scripts; unlicensed payloads remain in ignored
  `local_cache/`.
- `artifacts/manifests/` — lightweight Git-trackable cleanup and provenance
  records.
- `MODEL_SPEC.md` — mathematical and scientific specification.
- `THIRD_PARTY_PROVENANCE.md` — upstream source and reference provenance.

## Running Stage 1

Run `run_all.m` for bounded smoke validation only.

Run `run_stage_1.m` for deterministic analysis of accepted member 1 and
regeneration of the eight matching PNG/FIG figure pairs. It verifies the
10-member audit and pinned benchmark but performs no optimization or training.

The accepted ensemble was generated once by
`workflows/stage_1/construction/run_stage_1_gate1_rejection_sampling.m`. That
gated construction script uses one preassigned recurrent/calibration seed pair
per attempt and never retries a failed realization. It is not part of routine
deterministic regeneration.

Stage 1 uses the ignored project-local cache at
`third_party/kao_optimal_preparation/local_cache/`. On a fresh clone, follow
`third_party/kao_optimal_preparation/README.md` and run its setup/verification
scripts. `run_all.m` fails with that actionable instruction when the verified
native package is absent; it never silently substitutes a historical result.

## Running Stage 2A

`run_stage_2a.m` is the complete deterministic 10-network Gate-2 entry point.
It loads each accepted Stage-1 member independently, writes first to the
isolated `results/stage_2a_gate2_work/` tree, and then applies the frozen-point
stability, extended-convergence, and Q-potency conditional diagnostics. The
canonical tree may be installed only when every predeclared criterion passes.
`workflows/diagnostics/stage_2a/run_stage_2a_gate2_diagnostic.m` reruns only
that diagnostic against an already completed isolated Gate-2 work tree.

## Running Stage 2B

`run_stage_2b_kao.m` and `run_stage_2b_cerebellum.m` are scientific entry
points for accepted/frozen stages; do not rerun them without separate
authorization. Accepted Stage-2B-Cerebellum outputs are in
`results/stage_2b_cerebellum/current/`. Presentation-only regeneration is
`create_stage2b_cerebellum_gate4b_figures(stage_2b_cerebellum_config(pwd))`
after adding `config/` and `figures/stage_2b_shared/` to the MATLAB path;
it reads saved accepted outputs without rewriting scientific results.

The Cerebellum contract is fixed per network: the descending top-13
eigenvectors of normalized/symmetrized `Q_j` define `B_CB` (200x13),
`R_CB = 0.1 I_13`, signed CARE gain `K_CB = -G`, and
`F_CB = B_CB K_CB`. During PREP, `u = tonicInput + F_CB (r-rstar)`;
tonic and feedback inputs are stored separately and both removed at GO.
All 10 structural/stabilizability/CARE audits and all 80 target
fixed-point/zero-feedback/Jacobian audits passed. The accepted network-median
t95 is 14.0 +/- 0.35 ms; endpoint errors are 3.771 +/- 0.690 mm at 100 ms
and 1.712 +/- 0.283 mm at 200 ms (network-bootstrap SE).

The root runner is the bounded accepted-audit replay, not a fresh ensemble
construction workflow. It uses the valid historical per-network cache at
`results/stage_2b_cerebellum_gate4a_work/current/per_network/` and may write
audit outputs; invoking it requires separate scientific-rerun authorization.
Keep that cache. The old aggregate alongside it is historical only; the
incorrect unrestricted-controller saves and duplicate runners were removed.
Cache-generation source is retained as non-executable historical text in
`workflows/history/stage_2b_cerebellum_gate4b/`. The exact cleanup inventory,
frozen-result hashes, and verification record are in
`artifacts/manifests/gate4e/`.

## Frozen boundary

For every accepted member, do not retrain, retune, or replace `W_j`, its
spontaneous state and baseline drive, eight `x*_{q,j}`, readout `C_j`, common
movement input, two-link arm, or derived prospective-potency Gramian `Q_j`.
Stage 2A, Stage 2B-Kao, and Stage 2B-Cerebellum are frozen at their accepted
results. Historical Gate 3A changed only repository organization and dependency
resolution; it did not alter or recompute any accepted controller. Gate 4E
checkpoints the accepted Gate-4B-C science and reviewed Gate-4D presentation;
block, phenotype, prediction, noise, training, tuning, and adaptation remain
outside this checkpoint.
