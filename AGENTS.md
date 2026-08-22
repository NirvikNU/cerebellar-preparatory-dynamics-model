# Repository Guidelines

This MATLAB repository studies cerebellar contributions to motor-cortical preparatory dynamics. Keep all work reproducible, scientifically auditable, and suitable for eventual public release.

## Current branch scope

- `v2-no-plant` contains the explicitly authorized intact no-plant V2 architecture documented in `MODEL_SPEC.md`.
- Validate and review the intact baseline before implementing any cerebellar removal or adaptation experiment.
- Historical plant-based implementations remain recoverable from branch `v1-hennequin-isn`, annotated tag `pre-cleanup-plant-isn`, and checkpoint commit `ba6f6e968d9551bc02328d3a2176f3b4a8ecefa4`.
- Do not rewrite, move, or delete the historical branch or tag from this branch.

## Scientific integrity and scope control

- Never change a scientific assumption silently. State any proposed change to architecture, inputs, task, objective, training, evaluation, or lesion logic and obtain explicit direction before implementing it.
- Do not make undocumented scientific choices or hide assumptions in implementation details.
- Do not add lesion, block, scaling, retraining, or phenotype-matching experiments without an explicit specification and authorization.
- Do not overwrite experimental data or treat an exploratory checkpoint as a validated baseline.

## Project organization

- Keep model and task source in `src/`, numerical analysis in `analysis/`, plotting source in `figures/`, centralized configuration in `config/`, generated numerical artifacts in `results/`, and generated figures in `plots/`.
- Define important scientific and training parameters centrally once implementation begins.
- Keep model generation, training, analysis, validation, and plotting modular.
- Do not add dependencies unless necessary and documented.
- `run_all.m` is the clean-session entry point for the implemented intact workflow. Respect its runtime gate and do not launch unbounded training.

## Reproducibility and MATLAB conventions

- Use explicit, documented RNG seeds and separate streams for scientifically distinct sources of randomness.
- Do not use MATLAB section breaks (`%%`).
- Indent function code consistently and prefer computationally and memory-efficient implementations.
- Run MATLAB Code Analyzer and focused checks before finishing future coding tasks when MATLAB is accessible. Do not start long training merely to validate documentation or small code changes.

## Artifacts and plotting

- Generated contents of `results/` and `plots/` are ignored by default. Version selected scientific artifacts only through an explicit, documented decision.
- Do not commit caches, autosaves, temporary files, or large disposable intermediates.
- Use outward ticks, black axes, grid off, box off, white backgrounds, clear labels, and legend boxes off unless a later specification says otherwise.

## Handoff discipline

- Check Git status and the latest Codex Development Log entry before scientific development.
- Keep presentation-ready and model-specification Notion pages untouched unless the user explicitly asks to edit them. Routine implementation records belong only in the existing Codex Development Log.
- Update root documentation when an authorized implementation changes the active repository state.
