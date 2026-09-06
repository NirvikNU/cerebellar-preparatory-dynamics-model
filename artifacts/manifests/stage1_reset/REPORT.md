# RESET-S1-REPO-01-R1 — Stage-1-only cleanup and validation

**Physical retirement and bounded Stage-1 validation: PASS.** This controlled
resume reused the existing dirty worktree, archive and manifests. No restart,
replacement archive, recalibration, scientific-result overwrite or new model
was performed. Commit/push verification and the final SHA belong in the
external `r1/completion_receipt.json` and Notion Agent Log, not in a
self-referential amendment of this report.

## Archive and recoverability

Repository:
`G:\My Drive\Monkey_codes\combined_analyses\cerebellar-preparatory-dynamics-model`.

Exact existing external archive:
`G:\My Drive\Monkey_codes\combined_analyses\cerebellar-preparatory-dynamics-model_archive\stage1_reset_20260906T154910Z`.

The archive is **OUTDATED / NOT ACTIVE / DO NOT EXECUTE**. It is not a Git
repository/submodule or an execution dependency. Older Git history is intact.

| Preservation or removal outcome | Files | Bytes |
| --- | ---: | ---: |
| Initial complete inventory, including hidden/ignored/untracked | 1,406 | 3,375,653,070 |
| Original non-metadata retirement candidates copied and SHA256 verified | 856 | 3,243,699,155 |
| Original pre-edit versions preserved | 12 | 57,601 |
| Originals removed during the initial partial run | 92 | 1,464,388 |
| Remaining originals reverified and removed by R1 | 764 | 3,242,234,767 |
| Protected original Stage-1/dependency files unchanged | 346 | 131,849,082 |

R1 reconciled 1,157 existing files against the prior stop: no unexplained
change, all 764 source/archive pairs matched, and the index was empty.
Twenty-five current documentation/audit/code versions were additionally
preserved under `r1/pre_edit/` before updates. This includes the exact original
partial-stop report and leftover manifest; the original Notion log entry is
preserved separately from the R1 entry.

Removal used 752 ordinary forced literal-path deletes, 11 .NET literal-file
deletes and one path-specific move. The former blocker,
`artifacts/manifests/gate5e/final_analyzer.log`, was removed by .NET deletion.
The additional verified move was
`workflows/diagnostics/stage_2b_kao/run_gate2_active_set_figure_refinement.m`;
its duplicate preservation is under `r1/quarantine/`. Two .NET attempts
reported access errors, but subsequent source-absence guards and the authorized
methods resolved them without ACL changes, process killing or safeguard bypass.

All 856 retirement originals are now absent. No persistent nonzero legacy
scientific/code/data file or stubborn-path exception remained after removal.
The original 176 disposable 246-byte Google Drive icon-metadata removals remain
documented. Seventeen harmless ignored icon-metadata files remain: sixteen
under the pinned dependency infrastructure and one in this audit directory.
Their exact paths and hashes are itemized by the final forced inventory;
they are not scientific content or part of the indexed tree. One empty
legacy workflow directory found by the final directory audit was removed
with nonrecursive .NET deletion. Git administration is excluded and unchanged,
including the pre-existing `refs/heads/desktop.ini` warning.

Six tracked files missing before the initial reset remain recorded as
pre-existing deletions; their exact historical HEAD blobs are preserved under
`historical_HEAD_raw/`. Missing uncommitted versions are not claimed recovered.
The original copy/EOL/OS-metadata preservation history and both initial exports
remain external rather than being discarded.

## Retained foundation and reused work

The retained tree contains:

- `src/published_generator/`, Stage-1 configuration, analyses/tests,
  plotting/style helpers and successful construction entry points;
- ten accepted member bundles, accepted targets/results, successful
  acceptance/seed/calibration provenance and pinned-benchmark evidence;
- eight canonical PNG/FIG pairs plus two active-set diagnostic PNG/FIG pairs;
- the untouched pinned source/native cache and acquisition/license/checksum
  infrastructure;
- Stage-1-only root runners/documentation and this compact current audit.

All 346 protected original files remain byte-identical, including every
accepted model payload and all 20 figure assets. No equation, parameter,
readout, calibrated state, target, movement drive, arm, Q, accepted result or
figure changed. The 292 retained local-only scientific/dependency files
(129,959,508 bytes at R1 preflight, including the two separated diagnostic MATs)
remain ignored; none is force-added. All previously tracked Stage-1 assets
remain tracked.

R1 reused the initial reset's twelve reviewed documentation/plumbing edits,
three separated MATLAB helpers and two saved diagnostic MATs. The bootstrap
helper and refinement MAT were byte copies; nine diagnostic tables,
representative movement and ten Stage-1 validation rows were preserved by
exact saved/reopened equality. R1 only finalized status documentation and
current audit evidence; it did not repeat diagnostic extraction or analysis.

Five superseded partial-reset audit files were removed only after their R1
pre-edit copies were reverified: the old/intermediate analyzer reports,
static dependency report, partial Notion receipt and 764-row leftover list.
They remain recoverable under `r1/pre_edit/artifacts/manifests/stage1_reset/`.
The current `matlab_checks_r1.json`, move/preservation manifests and this report
replace them without creating an in-repository history collection.

## Single bounded regression and smoke results

MATLAB R2025b Update 1 ran in a fresh default-path session with explicit
Stage-1 paths only. The archive and retired models were not added to its path.
One invocation replayed each member's own eight frozen movements: **10 batched
forward calls / 80 target rows**, completing the regression in 46.664 seconds.
There was no calibration, construction, noise, bootstrap, phenotype, prediction
or figure-generation job.

| Check | Result |
| --- | --- |
| Accepted networks / target rows passing unchanged QC | 10/10; 80/80 |
| Maximum difference against saved member MAT metrics | 0 |
| Primary rates, torque, final state and hand, against both saved primary bundles | 0 |
| Maximum network-metric difference against CSV audit | 4.884981308350689e-15 |
| Maximum target-metric difference against CSV audit | 5.115907697472721e-13 |
| Existing deterministic regression tolerance | 1e-12, unchanged |
| Maximum endpoint error | 0.003637309718883566 m |
| Maximum absolute angular error | 1.806437782142325 degrees |
| Maximum absolute radial error | 0.002670213436409316 m |
| Native five-sample maximum absolute error | 2.220446049250313e-16 |
| Q relative Lyapunov residual | 7.345231414670959e-14 |
| Native manifest / pinned source | 167/167; 32,508,468 bytes; pinned HEAD matched |
| Changed/relocated MATLAB Code Analyzer | 10/10 clean |
| Saved Stage-1 diagnostic loading / figure basenames | PASS; 2 matching pairs |
| Canonical figure basenames / protected figure hashes | PASS; 8 matching pairs / 20 unchanged files |

Complete per-time accepted rate arrays are available for the primary member
in two saved bundles. Other members were compared against their saved network
and target metrics; this report does not invent missing full-trajectory
references. Validation outputs are separate from all canonical results.
The two exported validation CSVs are byte-identical to their frozen network
and target audit CSVs; the small in-memory-versus-CSV differences above remain
within the pre-existing tolerance.

The fresh entry-point dependency closure contains 36 project files. Two other
retained standalone helpers (`compare_native_matlab.m` and
`summarize_saved_potency_trials.m`) were separately audited read-only and
hash-preserved, accounting for all 38 retained MATLAB files. Neither requires
retired material. See DEPENDENCIES.md.

## Git and evidence

Starting branch/upstream:
`v3-romano-hennequin` / `origin/v3-romano-hennequin`.
Starting HEAD, tracking ref and direct remote:
`650ea32d9001e5963a6aecc6a77ed8759cd7fe4b`.
Existing remote:
`https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model.git`.

The cleanup changes twelve tracked documents/plumbing files, adds three
Stage-1-only MATLAB helpers and compact current evidence, and deletes 144
retired tracked paths (including six pre-existing deletions). No accepted
scientific payload or figure is edited. The intended commit is
`Retain Stage 1 foundation and archive legacy models`. Staging is restricted
to the explicit external `r1/staging_plan.csv`; no blanket add, force-add,
branch switch, history rewrite or force-push is allowed.

Current evidence: `DEPENDENCIES.md`, `move_manifest.csv`,
`protected_hash_verification.csv`, `rewritten_files.csv`,
`path_crosswalk.csv`, `diagnostic_extraction.json`,
`preservation_summary.json`, `matlab_checks_r1.json`,
`forward_regression.json`, the two `forward_*_metrics.csv` files and
`sync_exceptions.csv`.

Detailed original inventories, preserved dirty patches, historical blobs,
pre-edit versions and removal events remain in the existing archive.
R1 evidence includes `r1/inventory_resume.csv`,
`leftovers_reverified.csv`, `removal_events.jsonl`,
`compact_audit_removals.csv`, `matlab_validation.log`,
`native_cache_validation.txt`, final forced physical inventories and
index/upstream verification. The final commit SHA, remote equality and clean
Git outcome are recorded in `r1/completion_receipt.json` and the dated
**RESET-S1-REPO-01-R1** Agent Log entry after push verification.

Cleanup completion is not acceptance or implementation of a new preparatory
architecture. Stop after the authorized checkpoint and reporting.
