# Frozen Stage 1 and full-dimensional Stage-2 preparation

**Stage-1-only reset validated:** RESET-S1-REPO-01-R1 completed the physical
cleanup and the single 80-movement forward regression without changing frozen
scientific assets. See `artifacts/manifests/stage1_reset/REPORT.md` for the
archive, preservation and validation evidence; the final checkpoint/push
receipt is recorded externally and in the current Notion handoff.

The active scientific foundation is ten accepted, independently generated
source-faithful movement networks. STAGE2-LAMBDA-SWEEP-01 adds a separately
authorized full-dimensional Kao optimal-feedback controller, without changing
that foundation. Stage 2 is not scientifically accepted until user review.
It is a normative control model, not a cerebellar circuit or literal lesion.

Each 200-unit ReLU network (160E/40I) has its own frozen recurrent weights,
spontaneous state, baseline drive, eight calibrated movement initial states,
rank-2 excitatory readout and prospective-potency matrix. Its initial state
selects the target; the common movement input and two-link arm do not change
across targets. Internal integration is **0.2 ms**, saved sampling **1 ms**,
and cortical tau **150 ms**. Source rates are not automatically Hz.

All 80 accepted network–target movements passed recorded validation: maximum
angular error 1.806438 degrees and endpoint error 0.00363731 m. These are
validated reaches, not mathematically exact trajectories. Initial states are
not asserted to be unique optima or movement-period fixed points.

## Layout

- `src/published_generator/`: frozen loading/forward dynamics and retained
  source-faithful construction helpers.
- `config/`: Stage-1 settings and required-reference check.
- `analysis/published_generator/`: validation, source equivalence and Stage-1
  diagnostic methods.
- `figures/published_generator/`: canonical and retained active-set plotting;
  shared style/save helpers remain directly under `figures/`.
- `results/stage_1/current/`: accepted ensemble, target bundle, audits and
  primary analysis (local-only).
- `results/stage_1/audit_history/`: successful construction/acceptance and
  pinned-benchmark replication provenance, not failed candidates.
- `plots/stage_1/{png,fig}/`: eight canonical matching figure pairs.
- `results/stage_1/diagnostics/active_set_gate2/` and
  `plots/stage_1/diagnostics/active_set_gate2/{png,fig}/`: retained Stage-1
  active-set data and two matching figure pairs. The directory suffix is a
  preserved provenance identifier, not an active gate instruction.
- `workflows/stage_1/construction/`: successful construction entry points,
  retained for reproduction only; do not rerun without separate authorization.
- `workflows/diagnostics/stage_1/`: bounded validation entry point.
- `third_party/kao_optimal_preparation/`: source attribution, licensing,
  checksums and local-cache setup.
- `artifacts/manifests/stage1_reset/`: current reset report, dependency audit
  and preservation/move evidence.

## Stage-2 reproducibility

The complete pre-run specification is in
`artifacts/manifests/stage2_lambda_sweep/PREREGISTRATION.md` and the
[Stage-2 Technical Specification](https://www.notion.so/3d326c94be30816cbe53d67f3f0cd31f).
Configuration: `config/stage_2_config.m`; controller/dynamics: `src/stage_2/`;
population analysis/statistics/tests: `analysis/stage_2/`; plotting:
`figures/stage_2/`. The fixed lambda sweep is `[0.1 0.2 0.5 1 2 5 10 100]`.

```matlab
run_stage_2('test')     % bounded synthetic and source-algebra checks
run_stage_2('figures')  % R2: regenerate only Results 3 and Diagnostics 1-2
run_stage_2('validate') % R2: bounded saved-output and preservation checks
```

`run_stage_2('analyze')` recomputes only R2 neural-geometry metrics from the
local validated sweep cache, after the saved R2 cache/SD preflight passes.
Current outputs for these three figures are in
`results/stage_2/current/neural_geometry_r2/`; see
`artifacts/manifests/stage2_lambda_sweep/R2_PLAN.md` for the corrected contract.
The original `analysis.mat` and original analysis/plotting helpers preserve
the unchanged Results Figures 1-2 and original execution provenance; their
floor/K15/GO=MO neural-geometry fields are superseded, not current results.
Do not call the original five-figure renderer to regenerate current R2 figures.

`run_stage_2('simulate')` executes the authorized fixed sweep and refuses to
overwrite existing network caches. A pre-network technical-failure retry is
allowed only when no network cache/success receipt exists and original input
hashes still match. Neither operation trains or recalibrates Stage 1.
Do not remove a cache to bypass this protection. Large trajectory/controller
caches stay ignored in `results/stage_2/current/cache/`; compact analysis,
configuration and audits stay in `results/stage_2/current/`. Figure pairs are
under `plots/stage_2/{png,fig}/`. MATLAB Control System Toolbox is required for
the algebraic controller design. No archived model is an active dependency.

## Bounded Stage-1 validation

From the repository in a clean MATLAB session:

```matlab
run_all
run_stage_1
```

`run_all` checks the native source reference with a five-sample smoke segment.
`run_stage_1` checks the ten frozen members against saved acceptance metrics
and available primary trajectories. Neither trains, recalibrates, runs long
diagnostics, regenerates figures, nor overwrites canonical results. Do not use
whole-project `genpath` or rely on a previously populated MATLAB session.

MATLAB R2025b is the verified runtime. Forward regression uses base MATLAB and
the retained project functions. Broader retained analysis/construction code
uses Control System Toolbox (`lyap`), Statistics and Machine Learning Toolbox
(e.g. correlation/bootstrap summaries), Deep Learning Toolbox
(`lbfgsState/lbfgsupdate`), and Parallel Computing Toolbox for GPU-aware
construction helpers. These construction/diagnostic dependencies do not
authorize their execution during routine validation.

## Local-only assets and source provenance

The accepted numerical bundles and pinned native package remain intentionally
ignored, not embedded in a fresh Git clone. Obtain an authorized project-data
copy from the maintainers and verify its preservation manifest; do not rebuild
accepted members as a substitute for missing data. For the native package,
follow `third_party/kao_optimal_preparation/README.md` and run its
`verify_local_cache.ps1`. Loading fails explicitly if the cache is absent.

The separate untouched released Kao realization is pinned at
`40077d2da16e68ab2ab2cff59ec692b97315980b`. It is not an eleventh accepted
network. The ignored cache includes the pinned source, 167-file native export,
exporter, paper and local toolchain. Upstream controller-named modules remain
inside that untouched dependency, not as active project controllers.
No software-license grant was identified at the pinned revision; do not
redistribute its source or generated payload by adding it to this repository.
See `THIRD_PARTY_PROVENANCE.md` and `LICENSE_STATUS.md` in the dependency
directory. Existing tracked Stage-1 PNG/FIG assets remain tracked.

Scientific specification: [MODEL_SPEC.md](MODEL_SPEC.md).

## Management and archive boundary

[Agent Instructions — Current Task](https://www.notion.so/3c826c94be30817d8f51d9f6c8c2bc19)
is the executable authority.
[Agent Log — Run Outputs](https://www.notion.so/3d326c94be3081e897a2e5e0c855c4c0)
records actual outcomes;
[Agent Handoff](https://www.notion.so/3c826c94be308156a677c50c2106fb37) and
[START HERE](https://www.notion.so/3d226c94be308194adadf691ed5822a2)
give the current state and continuation point.
The [Stage-1 foundation](https://www.notion.so/3c426c94be308184a8e9d89034b8a477)
and its four support pages remain active.

Retired work belongs in the verified timestamped sibling archive documented
in the reset report. It is OUTDATED / NOT ACTIVE / DO NOT EXECUTE and is
excluded from active paths, test discovery and agent context. Git history is
preserved; no historical model is thereby active. Consult the reset report
for the actual completion/validation state, rather than inferring completion
from this layout description.
