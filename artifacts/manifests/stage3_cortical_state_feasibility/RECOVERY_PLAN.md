# STAGE3-EVIDENCE-RECOVERY-01

Authority: Notion Current Task revision 2026-09-07T23:06:28.204Z.
The existing hierarchy/specification holds the plan; no duplicate task pages.
Preflight: expected dirty worktree, empty index, no locks; local HEAD/tracking/
direct remote all 302138aacac1c81132f57c2da3578e5b29494ffb on the unchanged
v3-romano-hennequin / origin/v3-romano-hennequin branch/upstream.
Before-work hashing passed for all 292 prior inventoried files (1,895,050,885
bytes), including all 233 protected Stage-1/Stage-2 files. No unexpected changes.

## Exact bounded replay list

| Network | Direction | Grid index | Alpha | Normalized beta | Action |
| --- | --- | --- | --- | --- | --- |
| Each of 1–9 | 2 | 24 | 0.5 | 1.25 | Movement from saved achieved GO only |
| Each of 1–9 | 3 | 16 | 0.35 | 0.75 | Movement from saved achieved GO only |
| 10 | 2 | 15 | 0.35 | 0.5 | Movement from saved achieved GO only |
| 10 | 3 | 24 | 0.5 | 1.25 | Movement from saved achieved GO only |
| Each of 1–10 | 1 | 5 | 0.1 | 1 | Two preparations: modes [0 1] and [1 0] only |
| 1 | 1 | 5 | 0.1 | 1 | Prespecified nonorthogonality 0.05 and 0.1 |
| 1 | 1 | 5 | 0.1 | 1 | Prespecified kappa-margin factors 0.9 and 1.1 |
| 1 | 1 | 5 | 0.1 | 1 | Block preparation at the original fine 0.1-ms step |

Actual beta, gains, full states/bases and original summary identities are
enumerated in RECOVERY_CASES.mat/JSON before integration. Native primary
integration is 0.2 ms, saved samples 1 ms, analysis samples 10 ms. The fine
case alone uses 0.1 ms. Eight targets per case, common frozen spontaneous
initial state for preparations, unchanged movement drive/readout/arm.
The four sensitivities require their original paired preparation and intact
movement/full-window covariance evidence; these are not new intact references.

Totals: 20 movement sets / 160 target movements, 20 partial preparations,
4 sensitivity sets (8 preparations and 32 target movements), 1 fine preparation.
No primary movement, duplicate-primary additional record, reference generation,
grid simulation, selection or new point is dispatched. The 10 duplicated
additional identities reuse the existing primary hand arrays. Directions are
loaded, not generated or redrawn. No stochastic neural process is introduced.

## Preserve and compare before using recovered evidence

All original numerical files and configurations remain byte-for-byte intact.
Recovered full rates/hand/torque/state evidence is saved separately under
results/stage_3/current/cache/evidence_recovery/ (existing ignored cache policy).
Compact new comparisons/provenance remain in the Stage-3 manifest folder.
Never overwrite a recovered file or blindly restart the recovery runner.
Each raw file is saved before comparison so a failed case's evidence survives.

Predeclared comparison tolerances: absolute 1e-9 plus relative 1e-10 times
maximum absolute preserved value; discrete identities/K/modes must agree
exactly. This is floating-point replay tolerance, not a relaxed scientific
threshold. Original feasibility/stability/settling/PC/null/statistics rules
are unchanged. A material mismatch stops the batch immediately with actual
and preserved values. No repair of science, overwriting or selection follows.

Independent calculations use explicit time/target/neuron loops and covariance
eigendecomposition for PR and projection, direct squared x/y trajectory
errors over the unchanged comparator-MO+[0:200] window and mm conversion,
and QR subspace projectors for the same fixed Gaussian identities/covariance
factor. Full 10,000 draws are checked for each recovered alignment case.
Sensitivity full covariances use their actual recovered paired reference,
but always the frozen primary SD metric, as originally predeclared.

## Completion gates

1. Before manifest, frozen exact whitelist, new-file Code Analyzer.
2. Bounded recovery, case-by-case independent preserved-summary comparisons.
3. Cache-only independent map/registry, normalization, geometry/null, bootstrap,
   exact signs/BH, controller/bounds/step/GO/movement audit; new audit files only.
4. Repair logical-mask ingestion and actual-object legend; preserve Results 1
   if it passes. Complete/reopen/inspect four approved FIG/PNG pairs.
5. Current Results/Diagnostics tables/captions and native images, readback.
6. Protected/numerical after hashes, all intended accumulated Stage-3 diff,
   one normal commit/push, triple SHA and clean status, log/handoffs, stop.

No repeated polling loop. Jobs run once with output retained and a bounded
completion wait; independent reading/authoring proceeds while they run.
Any substantive discrepancy or preservation/Git problem stops completion.
