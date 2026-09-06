# RESET-S1-REPO-01-R1 — Stage-1 dependency and preservation audit

Status: physical retirement and the single 80-movement regression completed
under RESET-S1-REPO-01-R1. The original partial-stop report and manifests are
preserved in the existing external archive's `r1/pre_edit/` directory.
Consult REPORT.md and the current preservation/move manifests for evidence.

## Protected scientific foundation

Keep `results/stage_1/current/ensemble/network_01.mat` through `network_10.mat`:
each contains its own `model`, `calibration`, `recurrent`, `networkRow`, and
eight `targetRows`. Model fields include W, spontaneous state, h, xstar, C/Ce,
gamma, A, Qnative, native timing, arm, target hand trajectories and torques.
No model payload is to be rewritten. Cortex integration remains 0.2 ms,
saved sampling 1 ms, tau 150 ms; the unchanged arm consumes saved torques.

Keep the complete `current/targets/` and accepted Stage-1 audit/analysis data.
The successful `audit_history/rejection_sampling_run_20260831/` records all
ten accepted attempts, their predetermined seeds and calibration histories;
these are successful provenance, not failed attempts. Retain successful
published-benchmark replication evidence separately from accepted members.
Pure old cross-stage protection manifests and failed/superseded attempts
leave the active tree. Historical strings embedded in protected MAT/JSON
payloads are not edited to modernize prose.

Keep eight canonical PNG/FIG pairs in `plots/stage_1/{png,fig}/`, two retained
active-set PNG/FIG pairs in `plots/stage_1/diagnostics/active_set_gate2/`, and
existing Stage-1 diagnostic CSV files. Preserve their bytes, not regenerated
approximations.

## Code and dynamic paths

- `config/published_generator_config.m`, `stage_1_gate1_config.m` and
  `require_kao_reference.m`: project-relative native reference, accepted
  ensemble/target/audit paths, timing/acceptance and construction settings.
- `src/published_generator/`: native loader, ReLU cortex, unchanged movement
  bump, two-link arm, and successful source-faithful construction/calibration
  and adjoint/objective helpers. Construction is retained, not executed.
- `analysis/published_generator/`: accepted-candidate validation, source
  equivalence, primary analysis, target-objective summaries and hash helpers.
- `figures/published_generator/`, `figures/apply_plot_style.m` and
  `figures/save_figure_bundle.m`: canonical plotting dependencies, retained
  without regenerating the gallery. The bundle helper is called dynamically
  through the canonical plotter's local save function.
- `workflows/stage_1/construction/`: only successful target/rejection-sampling
  entry points; remove obsolete cross-stage path/hash dependencies.
- Root and diagnostic validation entry points must use explicit Stage-1 paths
  and separate output destinations. No whole-project `genpath`, archive path,
  cached session state, training, or canonical-output overwrite is permitted
  in the cleanup validation.

## Completed dependency separation

Original shared analysis and plotting code was preserved externally from
`analysis/stage_2b_shared/analyze_gate2_active_set_diagnostics.m` and
`figures/stage_2b_shared/create_gate2_active_set_figures.m`. Only Stage-1
functions and their neutral helper
`analysis/stage_2a/bootstrap_network_median.m` belong in the retained tree.
The original code is archived in full; `path_crosswalk.csv` records the
retained functions and their hashes. Static checks passed. No
diagnostic/bootstrap rerun was performed or is authorized by cleanup.

The complete active-set MAT and refinement MAT were preserved externally from
`results/stage_2b_kao/diagnostics/active_set_gate2/`. The former mixes nine
Stage-1 result tables, the representative movement, and validation with
retired preparation results. Stage-1 fields were separated with exact
`isequaln` checks on saved/reopened values; the full original is externally
archived. The refinement's `figureSource` fields are all Stage-1-only.
The two retained Stage-1 MATs reloaded successfully in the R1 validation.

## Required pinned dependency and local-only storage

Preserve `third_party/kao_optimal_preparation/` and its ignored local cache in
place, including the separate untouched pinned source checkout at
`40077d2da16e68ab2ab2cff59ec692b97315980b`, native export, exporter source,
paper and local toolchain. The native package has 167 manifest payloads,
32,508,468 bytes. `load_published_generator` constructs full-precision TSV
paths for weights, baseline, initial states, readouts, Q and metadata;
`run_stage1_smoke_tests` also needs `native_cortical_r1_1.tsv`.
Source verification requires that dependency's own Git administration; do
not traverse or remove it. Upstream controller-named source files are part
of the untouched pinned external dependency, not active project controllers.

The existing setup/verification scripts and provenance/license documents
remain. Previously ignored numerical results and native/checkpoint files
remain local-only; preserve tracked figure assets and do not force-add MATs.
Access is through the authorized project data copy and separately verified
native package, not automatic regeneration of accepted scientific assets.

## Bounded validation contract

R1 Code Analyzer passed all ten changed/relocated MATLAB files. The fresh
entry-point dependency closure contains 36 retained files. The other two
retained MATLAB helpers, `compare_native_matlab.m` and
`summarize_saved_potency_trials.m`, are standalone source-equivalence/saved-data
support; their read-only code audit and protected hashes confirm no retired
dependency. Thus all 38 retained MATLAB files are accounted for. Neither
standalone analysis was rerun.

One pass over ten members times eight targets, using the existing
`evaluate_stage1_gate1_candidate` forward and unchanged QC logic. Compare all
saved target/network metrics against accepted audit values at the existing
1e-12 regression tolerance. Compare the available primary-member complete
rate/torque/final-state/hand reference arrays without an additional rollout.
Other members have saved target/network metrics, not complete accepted
per-time rate arrays in their frozen member bundles; do not claim otherwise.
Check timing, loading, source manifests, paths and changed-file Code Analyzer.
Write separate validation outputs; never call the old wrapper that overwrites
accepted revalidation files or regenerates canonical figures.
