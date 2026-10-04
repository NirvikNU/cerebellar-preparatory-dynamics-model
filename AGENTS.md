# Repository instructions — frozen manuscript production

Read the latest [Agent Instructions — Current Task](https://www.notion.so/3c826c94be30817d8f51d9f6c8c2bc19) for executable authority. Historical tasks, logs, filenames and this repository do not authorize new science.

## Immutable scientific state

Ten frozen 200-unit ReLU networks; eight targets; eta=0, lambda=10, V=1; one shared alpha=.5 / beta_norm=1.25; primary initial/temporal noise .10/.10. No generic residual kappa feedback. Do not train, recalibrate, select alternative networks/trials/geometry, change normalization, tune seeds/noise or alter inference without explicit new authorization. Accepted weights, launch states, readouts, Q, movement drive, arm and 0.2-ms integration remain immutable. Saved sampling is1ms; analysis sampling10ms; tau150ms; rates are native units, not automatically Hz.

Control input is base+b−L(x−x*); Block removes both b and L but keeps base. Single-removal policies retain only b or only L. The decomposition is effective, not anatomical.

## Active production interface

- `run_paper_figures.m` and `run_paper_model.m`.
- `analysis/paper_ready/final_v3/production/`: current code.
- `data/paper_ready/final_v3/`: accepted scientific bundles, graphics recipes, exact static schematic, tables and provenance.
- `plots/paper_ready/final_v3/production/{fig,png,source}/`: canonical masters.
- `docs/paper_ready/final_v3/production/`: specification, legends, audit and reproduction.
- `src/published_generator/`: unchanged movement/arm foundation.
- `generated/`: ignored replay/regeneration products; never a required input.

Current map is Fig6a–h and ED7a–d, as tabulated in README. Do not restore superseded numbering, convergence figures, Q-diagnostic panels, residual-kappa models or review alternatives to current-facing documentation.

Fig6d is exactly Option3/seed18003/network8: four frozen successful trials per target/condition, same-four arithmetic means on101 movement-phase points. Fig6e/f use the frozen fifteen network8/target6 IDs in the manifest; selected-fifteen median, minimum-active8 cutoff; dispersion inset all30 successes. These illustrations must never replace all-trial statistics.

## Working rules

Inspect dirty, hidden, ignored and untracked state before edits. Preserve unrelated work and unique scientific evidence. Do not use archive inputs, historical-cache fallbacks, absolute local paths or recursive project `genpath` in production. Historical snapshots/archives are provenance only, never active-model fallbacks.

Use repository-relative paths and frozen deterministic streams. MATLAB: no `%%` sections; indent function bodies; run Code Analyzer on changed production files. Replay writers refuse to overwrite evidence. Preserve negative results and QC flags. Do not repeatedly poll long operations unless a concrete failure warrants a targeted check.

After figure changes, reopen native FIGs, inspect PNGs, validate graphical data/labels/dimensions and source tables. A launch or file-existence check is not scientific validation. Reproduction commands may run only within the user's authorized scope.

No deletion, staging, commit, push, branch changes, tags or history rewriting without authorization. Use normal Git operations; stop on unresolved preservation, validation, concurrency, permissions or Git problems. No force push, reset, rebase, amend or substitute scientific results.

The production-final task authorizes conservative retirement, reproduction checks, documentation and a normal main checkpoint only. It ends at scientific review. Update Agent Log chronologically, Handoff and START HERE with verified outcomes, not intended outcomes. Keep foundation Stage1/2/3 scientific assets unchanged.
