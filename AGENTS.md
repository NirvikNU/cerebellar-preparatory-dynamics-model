# Repository Guidelines

This MATLAB repository studies cerebellar contributions to motor-cortical
preparatory dynamics. Keep work reproducible, scientifically auditable, and
suitable for eventual public release.

## Current branch scope

- `v3-romano-hennequin` contains the authorized untrained V3 hybrid scaffold
  documented in `MODEL_SPEC.md`.
- The current entry point runs smoke tests only. Do not start deterministic
  training without explicit Step-4 authorization.
- Historical V2 is immutable on branch `v2-no-plant`, annotated tag
  `v2-no-plant-final`, and commit
  `7f8463976c0faaaebe5af653aebb12c2796ff44a`.
- Historical plant-based V1 remains on branch `v1-hennequin-isn`, tag
  `pre-cleanup-plant-isn`, and commit
  `ba6f6e968d9551bc02328d3a2176f3b4a8ecefa4`.
- Do not rewrite, move, or delete historical branches, tags, or the external
  V2 artifact archive.

## Scientific integrity and scope control

- Never change an architecture, input, task, objective, training, analysis,
  or lesion assumption silently.
- V3 has one fixed recurrent matrix. Do not introduce separate preparation
  and movement matrices or switch synapses at go.
- Do not add neural-geometry, lesion, block, scaling, retraining, or
  phenotype-matching objectives without explicit authorization.
- Do not treat untrained smoke diagnostics as scientific model results.

## Project organization

- Keep model/task source in `src/`, numerical analysis in `analysis/`,
  plotting source in `figures/`, configuration in `config/`, generated
  numerical artifacts in `results/`, and generated figures in `plots/`.
- V3 generated roots are `results/v3_hybrid/` and `plots/v3_hybrid/`.
- `run_all.m` is the clean-session entry point and must remain smoke-only
  until deterministic training is explicitly authorized.

## Reproducibility and MATLAB conventions

- Use explicit seeds and separate RNG streams for distinct randomness.
- Do not use MATLAB section breaks (`%%`).
- Prefer modular, vectorized, memory-conscious implementation.
- Run MATLAB Code Analyzer and focused smoke tests before handoff.

## Artifacts and handoff

- Generated `results/` and `plots/` contents are ignored by default.
- Do not commit caches, autosaves, temporary checkpoints, or disposable
  intermediates.
- Routine implementation history belongs only in the existing Codex
  Development Log. Do not modify presentation/scientific-summary Notion
  pages without explicit authorization.
