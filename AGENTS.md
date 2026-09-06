# Repository Guidelines

This MATLAB repository retains the accepted Stage-1 movement generator and its
complete reproducibility, validation and diagnostic support. Preparation is
awaiting a separately authorized design task. Do not implement a new model from
historical instructions.

RESET-S1-REPO-01-R1 completed physical retirement and bounded Stage-1
validation. Read `artifacts/manifests/stage1_reset/REPORT.md` for preservation
and regression evidence, and the current Notion handoff for the final
checkpoint/push receipt. The archived models are not active dependencies.
Cleanup completion does not authorize a new preparatory model.

## Frozen scientific foundation

- Ten independently generated 200-unit ReLU networks (160E/40I), accepted as
  the first ten sequential candidates passing all predeclared checks for eight
  10-cm targets. Each has its own W, spontaneous state, baseline drive, eight
  calibrated movement initial states, rank-2 excitatory readout and Q.
- Never recalibrate, retrain, retune or replace accepted weights, states,
  readouts, target geometry, movement input, arm or prospective-potency matrix.
- Native cortical integration is 0.2 ms; saved sampling is 1 ms; tau is 150 ms.
  Rates use source units, not automatically Hz.
- The released Kao realization is a separate untouched source benchmark pinned
  at `40077d2da16e68ab2ab2cff59ec692b97315980b`, not an ensemble member.
- Calibrated initial states are validated movement initial conditions, not
  necessarily unique optima or fixed points, nor a prespecified low-dimensional
  manifold. A rank-2 output does not establish neural dimensionality.

## Active paths and execution

- Model source: `src/published_generator/`.
- Stage-1 configuration: `config/published_generator_config.m` and
  `config/stage_1_gate1_config.m`.
- Analyses/tests: `analysis/published_generator/`.
- Figure code: `figures/published_generator/` plus the shared style and
  figure-bundle helpers in `figures/`.
- Accepted local-only data: `results/stage_1/current/`.
- Successful acceptance/source provenance: `results/stage_1/audit_history/`.
- Canonical gallery: eight PNG and eight matching FIG files in
  `plots/stage_1/{png,fig}/`; two additional retained active-set figure pairs
  and data are under the Stage-1 `diagnostics/active_set_gate2/` directories.
- `run_all.m` remains bounded smoke-only. `run_stage_1.m` is bounded
  deterministic validation of all ten frozen members, not figure regeneration,
  optimization or a canonical-result writer.
- Successful construction entry points are retained in
  `workflows/stage_1/construction/` for reproducibility only. Do not execute
  construction without separate authorization or overwrite an accepted bundle.
- The ignored native cache remains under
  `third_party/kao_optimal_preparation/local_cache/`. Follow
  `THIRD_PARTY_PROVENANCE.md` and its setup/verification instructions.
  Preserve its pinned checkout and licensing boundary.
- Current cleanup evidence is under `artifacts/manifests/stage1_reset/`.

## Safety and reproducibility

Inspect dirty, hidden, ignored and untracked state before editing; preserve
unrelated work. Use explicit provenance and deterministic seeds. Do not add
MATLAB `%%` sections; indent function bodies. Run Code Analyzer on changed
MATLAB files and relevant bounded checks. Keep generated numerical artifacts
local under the existing ignore policy; canonical tracked figures stay tracked.

Never use whole-project `genpath`, archive paths, old controllers or historical
result fallbacks for active loading. The timestamped sibling archive is
OUTDATED / NOT ACTIVE / DO NOT EXECUTE: do not browse it as routine task context,
restore its models, add it to Git, or treat archived instructions as authority.
Git history and pinned source administration remain intact.

Do not commit, tag, push, change branches or rewrite history without explicit
authorization. Do not repeatedly poll long operations unless concrete failure
evidence warrants a targeted check. Stop on unresolved preservation, validation,
permission, concurrency or Git problems.

## Current management

Read [Agent Instructions — Current Task](https://www.notion.so/3c826c94be30817d8f51d9f6c8c2bc19)
for executable authority. Maintain
[Agent Log — Run Outputs](https://www.notion.so/3d326c94be3081e897a2e5e0c855c4c0),
[Agent Handoff](https://www.notion.so/3c826c94be308156a677c50c2106fb37) and
[START HERE](https://www.notion.so/3d226c94be308194adadf691ed5822a2)
with verified outcomes. Keep the current Notion hierarchy intact and do not
reopen the excluded legacy subtree. A log entry does not grant another task.
