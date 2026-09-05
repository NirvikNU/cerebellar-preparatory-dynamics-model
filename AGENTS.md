# Repository Guidelines

This MATLAB repository contains one motor-preparation model developed in
stages. Keep all work reproducible, scientifically auditable, and suitable for
eventual public release.

## Current scientific state

- Stage 1 is **ACCEPTED — FROZEN** as the first 10 independently generated
  source-faithful ISNs passing every predeclared QC threshold for the 10-cm
  eight-target task. Each member has its own frozen `W_j`, `C_j`, spontaneous
  state/baseline drive, and eight `x*_{q,j}`.
- The official Kao/Sadabadi/Hennequin released realization remains a separate
  untouched benchmark pinned at commit
  `40077d2da16e68ab2ab2cff59ec692b97315980b`.
- The verified native realization is project-local but ignored at
  `third_party/kao_optimal_preparation/local_cache/kao_optimal_preparation/native_reference_40077d2`.
  Only attribution, checksums, and acquisition/verification instructions are
  tracked because the upstream software has no identified license grant.
- Do not retrain, retune, or replace any accepted member's `W_j`, spontaneous
  state/baseline drive, eight `x*_{q,j}`, readout `C_j`, movement input, arm,
  or derived `Q_j`.
- Stage 2A is **ACCEPTED — FROZEN** under the predeclared conditional Gate-2
  interpretation. All 80 fixed points are locally stable, all four historical
  5-s full-state misses converge to their intended fixed points, their residual
  state energy is predominantly low-potency, all original mechanistic gates
  pass, and all rows meet the revised 2-mm endpoint threshold. The historical
  1% full-state threshold remains descriptive rather than hard QC.
- The accepted Gate-2 ensemble is in `results/stage_2a/current/`; the initial
  stopped-gate audit and prior single-network artifacts are retained under
  `results/stage_2a/audit_history/`. Stage 2B was not inspected or recomputed
  during Stage-2A conditional acceptance.
- Do not add a cerebellar/thalamic population model, block condition,
  adaptation, target jump, or trainable pathway.
- Stage 2B-Kao is **ACCEPTED — FROZEN** after the final Gate-3 Figure-5
  diagnostic. Its unrestricted network-specific Kao-LQR controllers and
  validated ten-network results must not be retrained, retuned, or replaced.
  The Stage-2A 100-to-200-ms endpoint worsening is verified as a genuine
  feature of the naive trajectory, not an indexing or extraction error.
- Stage 2B-Cerebellum is **ACCEPTED — FROZEN** after Gate 4B-C, with the
  reviewed Gate-4D four-figure presentation. Each network uses the descending
  top-13 eigenvectors of its normalized/symmetrized `Q_j`: `B_CB` is 200x13,
  `R_CB = 0.1 I_13`, `K_CB = -G`, and `F_CB = B_CB K_CB`. Tonic input and
  feedback remain separate: `u = tonicInput + F_CB (r-rstar)` during PREP;
  both turn off at GO. Structural/stabilizability/CARE gates passed 10/10;
  exact fixed-point/zero-feedback/active-set Jacobian gates passed 80/80.

## Active organization

- Stage 1 source: `src/published_generator/`.
- Stage 1 analyses: `analysis/published_generator/`.
- Stage 1 figure code: `figures/published_generator/`.
- Stage 1 canonical results: `results/stage_1/current/`.
- Stage 1 history/provenance: `results/stage_1/audit_history/`.
- Canonical figures: exactly eight PNG files in `plots/stage_1/png/` and eight
  matching editable FIG files in `plots/stage_1/fig/`.
- Smoke entry point: `run_all.m`.
- Complete deterministic accepted-member entry point: `run_stage_1.m`.
- One-time accepted-ensemble construction entry point:
  `workflows/stage_1/construction/run_stage_1_gate1_rejection_sampling.m`; do
  not rerun without authorization.
- Stage 2A source/analysis/figures: `src/stage_2a/`, `analysis/stage_2a/`, and
  `figures/stage_2a/`.
- Stage 2A entry point: `run_stage_2a.m`.
- Stage 2A accepted results: `results/stage_2a/current/`.
- Stage 2A audit/provenance history: `results/stage_2a/audit_history/`.
- Stage 2A figures: exactly five PNG files in `plots/stage_2a/png/` and five
  matching editable FIG files in `plots/stage_2a/fig/`.
- Stage 2B-Kao paths: `config/stage_2b_kao_config.m`,
  `src/stage_2b_kao/`, `results/stage_2b_kao/`, and
  `plots/stage_2b_kao/{png,fig}/`.
- Stage 2B-Cerebellum paths: `config/stage_2b_cerebellum_config.m`,
  `src/stage_2b_cerebellum/`, `results/stage_2b_cerebellum/current/`, and
  `plots/stage_2b_cerebellum/{png,fig}/` (four matching figure pairs).
- Shared analyses and figures: `analysis/stage_2b_shared/` and
  `figures/stage_2b_shared/`.
- Noncanonical construction and diagnostic runners: `workflows/`; scripts in
  `workflows/history/` are provenance-only.
- Third-party metadata and local cache contract:
  `third_party/kao_optimal_preparation/`.
- Stage 2B entry points: `run_stage_2b_kao.m` and `run_stage_2b_cerebellum.m`.
  Both stages are accepted/frozen; do not rerun controller science without
  separate authorization. Presentation-only regeneration uses saved outputs.
- The Cerebellum root runner replays the bounded Gate-4B-C audit using the
  retained per-network cache at `results/stage_2b_cerebellum_gate4a_work/current/per_network/`.
  That ignored cache is required provenance, not an alternative controller.
  The interrupted cache-generation source is non-executable historical text
  under `workflows/history/stage_2b_cerebellum_gate4b/`.

Use only Stage 1, Stage 2A, Stage 2B-Kao, and Stage 2B-Cerebellum terminology
in the active tree.

## Execution and change rules

- Inspect the dirty worktree before editing and preserve unrelated user work.
- `run_all.m` must remain bounded and smoke-only.
- The project-local ignored native-reference cache is restored and verified at
  the canonical path recorded in `THIRD_PARTY_PROVENANCE.md`.
- Use explicit provenance and deterministic seeds where randomness is needed.
- Do not add MATLAB `%%` sections.
- Run Code Analyzer and relevant smoke checks after code changes.
- Generated numerical artifacts remain local unless the user requests them to
  be tracked. Accepted Stage-1 and Stage-2A PNG/FIG pairs are canonical assets.
- Stage 2B-Cerebellum is **ACCEPTED — FROZEN** after Gate 4B-C: the exact
  network-specific top-13 prospective-potency actuator and accepted CARE
  controllers/results must not be rederived, retuned, or replaced.
- Do not commit, tag, push, or rewrite Git history without explicit user
  authorization.
- Record verified implementation history in the Notion Codex Development Log
  and keep the Notion Agent Handoff current.
