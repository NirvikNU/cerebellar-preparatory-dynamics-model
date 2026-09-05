# Gate 4E cleanup and checkpoint provenance

Date: 2026-09-05. Parent/start checkpoint:
`6abe019eae0a480fbe3a06821bca2adf60bc61bd`.
Branch/upstream: `v3-romano-hennequin` / `origin/v3-romano-hennequin`.
Remote: `https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model.git`.
Required commit message: `Accept Stage 2B-Cerebellum 13-channel controller`.

This is cleanup/provenance only. Stage 2B-Cerebellum remains
**ACCEPTED / FROZEN**. No controller derivation, simulation, bootstrap,
block, phenotype, prediction, noise, training, tuning, or adaptation ran.
The commit containing this record is the checkpoint; its final SHA and
verified push are recorded subsequently in the Notion Handoff/Development Log.

## Inventory, decisions, and recovery

`cleanup_inventory.csv` classifies all 95 pre-cleanup Gate-4 paths before
removal, including the full 24 modified/untracked Git-visible paths plus
71 associated ignored numerical/export/OS-metadata paths. It records sizes,
SHA-256 (non-OS files), reasons, actions, and the historical source destination.
There were no ambiguous or unexplained files.

- 16 original paths retained for the checkpoint: three active documents,
  root runner, configuration, controller derivation, accepted audit, plotting
  function, and eight reviewed FIG/PNG files.
- One 31,825-byte interrupted network-analysis source archived with only
  trailing-whitespace normalization as non-executable historical `.m.txt`,
  with a dedicated README; the exact original is also in recovery. This is
  evidence of cache generation/summary defects, not an alternative controller.
- 27 files removed to a recoverable OS-temporary folder outside the repository:
  seven obsolete MATLAB scratch/wrapper/summary scripts; ten misleading
  unrestricted-Kao controller saves; four old SVG and four old JPEG exports;
  and the two export-directory `desktop.ini` files.
- 51 ignored paths retained: 27 accepted current payloads, ten required valid
  per-network caches, one historical aggregate, and 13 OS-metadata files.

Removed scripts:
`check_fields.m`, `check_stab.m`, `generate_gate4b_figures.m`,
`run_gate4b_reconcile.m`, `gate4b_reconcile_and_plot.m`,
`analysis/stage_2b_shared/run_stage2b_cerebellum_gate4b_ensemble.m`, and
`analysis/stage_2b_shared/summarize_stage2b_cerebellum_gate4b.m`.

The ten removed saves were under
`results/stage_2b_cerebellum_gate4a_work/current/ensemble/`, named
`network_01_stage2b_kao_controller.mat` through
`network_10_stage2b_kao_controller.mat`. Read-only MATLAB inspection verified
each `controllerSaved` was exactly equal (`isequaln`) to the corresponding
frozen Kao save, including its 200x200 actuator. These are not the accepted
13-channel controllers. Their original hashes are retained in the inventory.

The old `gate4b_ensemble_results.mat` is a historical summary struct and is
not used by the accepted root audit. It remains ignored and explicitly
historical. The ten original `current/per_network/network_*_gate3_result.mat`
files are essential to the accepted audit and were retained at the original
paths. Network 1 includes a 67,687,734-byte representative cache: intentionally
local/ignored, never a staging candidate.

The recovery folder's machine-local location is reported to the user and in
the Notion checkpoint log, not embedded as a dependency in this public tree.
No permanent deletion or Git-history rewrite was used.

## Scientific and figure integrity

`frozen_results_sha256.csv` contains the 474 retained result-file hashes from
the already verified Gate-4D baseline. It excludes only the ten separately
classified duplicate Kao saves. Post-cleanup verification found exactly
474 result files (excluding `desktop.ini`), all matching, with zero
missing/changed/unexpected payloads. Thus accepted Stage 1, Stage 2A, Kao,
Cerebellum, Gate-2, Gate-3C, and Gate-3E-R2 outputs were preserved.

The comparison to the 215-file Gate-4D Git-visible snapshot found:
202 original files byte-identical, two active MATLAB files with whitespace-only
normalization, three deliberately reconciled documents, and eight classified
original paths removed/archived. No unexpected changes. The staged whitespace
check exposed pre-existing trailing spaces in the previously untracked
configuration, controller derivation, and historical source snapshot. Only
trailing spaces and extra EOF blank lines were removed; non-whitespace content
was verified identical. Inventory hashes describe the originals. All other
retained active MATLAB files, upstream tracked science, and all eight reviewed
Cerebellum FIG/PNG files are byte-identical to Gate 4D.

Read-only loading of the accepted MAT audit confirmed 10/10 controller and
80/80 target acceptance flags. Saved values remain:
t95 14.0 +/- 0.35 ms; Cerebellum endpoints 3.771 +/- 0.690 mm at 100 ms and
1.712 +/- 0.283 mm at 200 ms; frozen 200-ms endpoints Stage 2A
152.926 +/- 2.740 mm and Kao 0.0905 +/- 0.0118 mm.
No values were recomputed for display.

Gate-4D FIG reopen/PNG visual checks are reused because all eight file hashes
are identical; no figure regeneration or redundant reopening was needed.
Code Analyzer reported zero findings on each of the two active MATLAB files
changed only for whitespace in Gate 4E: the configuration and controller
derivation. No other MATLAB file was analyzed in this gate. The historical
snapshot is non-executable text. The Gate-4D plotting-file check had zero findings.
A read-only MATLAB path/dependency check resolved the active functions and
11 project dependencies, with no historical workflow dependency. An initial
one-line dependency-check string-construction typo was corrected in that
check only; neither check invoked scientific functions.
`run_all.m` remains byte-identical and smoke-only; it was not executed.

## Reviewed checkpoint inventory

21 intended additions/modifications: four modifications and 17 additions,
no tracked deletions (removed scratch was untracked or ignored).
The five newly added provenance files are this README, the two CSV manifests,
the historical-source README, and its `.m.txt` snapshot.

Only final reviewed code, active documentation, the four figure pairs, and
small provenance are eligible for staging. Candidate-size and secret-pattern
checks passed; largest candidate is the endpoint PNG, 296,791 bytes.
Excluded: every numerical `results/**` payload, upstream local cache/nested
Git metadata, unlicensed sources, PDFs, executables/toolchains, credentials,
OS metadata, MATLAB temporary/autosave/cache files, and superseded exports.
No candidate exceeds 50 MiB.

The working-tree whitespace check passed before staging. The first staged
check exposed the previously untracked whitespace defects described above;
they were corrected without scientific changes. The final staged
name/status, whitespace, actual blob-size, exclusion, and parent/branch
checks must pass before the one authorized commit. Push only the existing
branch, without force; after push verify HEAD, tracking ref, and direct
remote SHA independently. Notion bookkeeping is authorized only afterward.

## Canonical paths and stop boundary

Active runner: `run_stage_2b_cerebellum.m`.
Controller: `src/stage_2b_cerebellum/derive_stage2b_cerebellum_controller.m`.
Audit: `analysis/stage_2b_shared/audit_stage2b_cerebellum_gate4b.m`.
Presentation:
`figures/stage_2b_shared/create_stage2b_cerebellum_gate4b_figures.m`.

Final pairs in `plots/stage_2b_cerebellum/{fig,png}/`:
1. `01_stage2b_cerebellum_actuator_q_geometry`
2. `02_stage2b_cerebellum_prospective_q_preparation`
3. `03_stage2b_cerebellum_endpoint_by_preparation_duration`
4. `04_stage2b_cerebellum_structural_controller_validation`

The future paper-phenotype specification remains Prep/Move only, with
supplementary grouped bars and error bars, no connected lines or network
dots/trajectories. Its execution is not part of this gate. Stop for review
after the verified checkpoint; block definition and intact-vs-block geometry
require separate authorization.

Sources:
- [Gate-4E instructions](https://app.notion.com/p/3c826c94be30817d8f51d9f6c8c2bc19)
- [Accepted Cerebellum hierarchy](https://app.notion.com/p/3d226c94be3081b6bc17d487bd2c1a4a)
- [Development Log / Gate-4D audit](https://app.notion.com/p/3c126c94be308123ade2cc6adf68eb6b)
