# Repository Guidelines

This is a MATLAB project for modeling cerebellar contributions to motor-cortical preparatory dynamics. Keep it reproducible, scientifically auditable, and suitable for eventual public release with a paper.

## Scientific integrity and scope control

- Never change a scientific assumption silently. Before implementing a request that changes the scientific interpretation, architecture, task, plant, inputs, objective, evaluation, or lesion logic, state the change and obtain explicit direction.
- Do not make undocumented scientific choices or hide assumptions in implementation details.
- `MODEL_SPEC.md` describes only the architecture and workflow actually implemented in the repository. Update it when implementation changes, but do not use it to pre-implement an unfrozen proposal.
- The saved 5,000-update intact V1 checkpoint is a diagnostic artifact, not an accepted intact baseline. Do not describe it as validated or use it as the baseline for scientific lesion comparisons.
- No cerebellar lesion/block condition, cerebellar scaling experiment, lesion retraining, or V2 model is implemented. Do not add any of these without an explicit specification and authorization.
- The scientific team has selected a Hennequin-style inhibition-stabilized-network (ISN) cortical backbone as the next development direction. This is a future direction only. Do not implement or infer its detailed architecture until the team supplies the specification in a later HIVE Codex session.
- Do not overwrite experimental data. Preserve existing V1 results and plots unless replacement is explicitly requested.

## Project organization

- Keep task/model generation in `src/`, numerical analysis in `analysis/`, plotting source in `figures/`, centralized configuration in `config/`, generated numerical artifacts in `results/`, and figure artifacts in `plots/`.
- Keep model generation, plant simulation, training, analysis, validation, and plotting modular.
- Define every important scientific and training parameter centrally in `config/model_params.m`; do not hard-code parameters throughout functions.
- `run_all.m` is the clean-session entry point. It should reproduce the currently implemented workflow, but do not run it casually: the intact V1 training workflow takes about 9.4 hours on the recorded RTX 3080 environment.
- Do not add dependencies unless necessary and documented.
- Do not commit caches, autosaves, temporary files, or large disposable intermediates. Selected scientific results and figure artifacts may be version-controlled deliberately.

## Reproducibility and MATLAB conventions

- Use explicit, documented RNG seeds and separate streams for initialization, training task/delay sampling, training noise, validation, and evaluation.
- Do not use MATLAB section breaks (`%%`).
- Indent function code consistently.
- Prefer computationally and memory-efficient MATLAB implementations.
- Preserve the current custom `dlarray`/`dlgradient` training path unless an authorized specification changes it.
- Before finishing any coding task, run MATLAB Code Analyzer and available focused checks/tests when MATLAB is accessible. Do not start a long retraining run merely to validate documentation or small code changes.

## Plotting conventions

- Use `set(gca,'FontSize',16)` unless otherwise specified, or the repository plotting-style helper that applies the same default.
- Use outward ticks, black axes, grid off, box off, white backgrounds, clear labels, legend boxes off, and centralized target colors for target-based figures.
- Plotting source belongs in `figures/`; generated artifacts belong in `plots/`.
- Existing intact V1 artifacts under `plots/v1_intact/` are the completed `.fig` and PNG snapshot and must not be regenerated during handoff work. For new or revised publication figures, save editable `.fig` plus PNG and PDF unless a later explicit frozen specification says otherwise.

## Handoff discipline

- Read `CODEX_HANDOFF.md`, `MODEL_SPEC.md`, `IMPLEMENTATION_NOTES.md`, and the latest Codex Development Log entry before continuing scientific development on another computer.
- Check Git status before edits. At the 2026-08-20 handoff, the repository had no commits and all files were untracked; do not assume provenance or a recoverable baseline until an initial commit is deliberately created.
- Keep the Notion presentation-ready/model-specification pages untouched unless the user explicitly asks to edit them. Routine implementation records belong only in the existing Codex Development Log.
