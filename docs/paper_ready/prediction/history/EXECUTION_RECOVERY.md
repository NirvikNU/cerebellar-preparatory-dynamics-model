# Execution-only RRR recovery

The initial RRR launch failed in `parpool('Processes',20)` before any
production RRR case was fitted or saved. MATLAB reported that a worker shut
down unexpectedly with status 1. `STOP_RRR.json` preserves the failure.
The precise cause of that process-worker exit was not established; do not
describe it as a scientific discrepancy or assert an unverified root cause.
Read-only inspection found ample available physical memory. Existing user
MATLAB sessions were left untouched. No profile, installation, permission,
license, system process or accepted scientific file was changed.

A bounded alternative-runtime test successfully started20 thread workers.
It exposed the documented runtime restriction that V7.3 MAT-file loading is
unsupported inside thread workers (`THREAD_PREFLIGHT_STOP.json`). File I/O
was therefore kept on the client. The production fitting loop already used
client-side loading; the independent audit now preloads the same40 immutable
source/evidence bundles before its parallel numerical loop. It does not
change the values, case identities or audit calculations.

The repaired compute-only test independently executed the exact full-rank
fit serially and on two thread tasks for the same fixed input/folds/grid.
Both R2 vectors matched exactly (maximum absolute difference0).
`THREAD_COMPUTE_PREFLIGHT.json` records this PASS. Code Analyzer passed both
execution-only MATLAB edits (`STATIC_THREAD_REPAIR.json`). Production uses
20 thread workers and the independent audit12. These are computational
resource choices, not scientific parameters or alternative estimators.

The retry starts at `pe_rrr`, then runs `pe_rrr_audit`, the RRR-only renderer
and the combined reporting audit. It does not replay trajectories, rerun
panel e/controls, overwrite its figures, change any seed/fold/grid/criterion,
or inspect outcomes to choose a different analysis. All previous partial
evidence and the failed-start receipts are retained. Launching a retry is
not completion; the final RRR/audit/figure/publication receipts must PASS
before declaring the task complete.

The first thread-based production attempt then exposed a pre-distribution
indexing defect before its first case was computed/saved. The branch using
`perm(:,shuffle-1)` for shuffled cases allowed MATLAB's `parfor` input slicer
to request column0 for the unshuffled iteration. `STOP_RRR_THREAD.json`
preserves this failure. The implementation now defines
`correspondence=[identity,perm]` and indexes column `shuffle` unconditionally.
Column1 is exactly the original unshuffled response; columns2:101 are exactly
the same100 frozen permutations. This changes no pairing or estimator.
`pe_batch_test` exercises the exact production batch assignments for the
identity/first-shuffle cases, all10 repeats and all200 ranks, and compares
two fixed serial fits before the subsequent production launch. No scientific
outcomes from this test are selected, displayed or used for tuning.

Final outcome: the batch preflight passed with both serial R2 discrepancies0.
The first saved case also passed an independent augmented-QR check of every
rank and selected penalty for its first repeat. The subsequent full40-case
production,400-observed-repeat/40-shuffle-refit audit, saved40000-shuffle-search
audit, RRR figure export/reopen and combined statistics/report all completed
successfully. Production elapsed5531.1 seconds (about92.2 minutes). Final
preservation passed all1842 original files. No scientific setting changed.
