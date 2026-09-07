# STAGE3-FINALIZE-01 — stopped at missing audit evidence

2026-09-07 22:32 UTC / 2026-09-08 Asia/Jerusalem.
Status: INCOMPLETE / STOPPED FOR REVIEW. No simulation, rendering, selection,
scientific-result overwrite, staging, commit or push occurred in this task.
The original figure-stop receipt and all accumulated uncommitted work remain.

## Authority and preflight

Read the updated Notion continuation contract dated
2026-09-07T22:20:57.840Z, the historical stop log/receipts, current handoffs,
Technical Specification, local PLAN.md and DERIVATION.md, and repository
guidelines. The contract expressly requires stopping for missing required
numerical evidence and prohibits any new neural or arm integration.

One bounded Git preflight confirmed the expected dirty Stage-3 worktree,
empty index, no Git locks and unchanged branch/upstream:
`v3-romano-hennequin` / `origin/v3-romano-hennequin`.
Local HEAD = tracking ref = direct remote:
`302138aacac1c81132f57c2da3578e5b29494ffb`.
Remote remains the existing NirvikNU/cerebellar-preparatory-dynamics-model
GitHub repository. No unrelated changes were identified or modified.
Hidden/ignored state includes existing local caches, logs and desktop.ini;
none was removed. The excluded archive was not opened.

## Exact blocker, confirmed from actual MAT files

A single read-only MATLAB command loaded `consequences.mat` and every one of
the ten `grid_XX.mat` files, inspected saved schemas, and exited0. It invoked
no runner, preparation, movement, null recomputation or selection function.
Full observed fields/counts are preserved in `FINALIZE_EVIDENCE_STOP.json`;
the console evidence is retained in ignored `stage3_finalize_evidence.log`.
Recursive Stage-3 inventory found the eight original compact result files,
ten reference caches and ten grid caches, plus OS metadata; no other raw
movement, partial-removal or sensitivity caches were present.

| Required evidence | Present | Missing / consequence |
| --- | --- | --- |
| Primary intact/block movements, ten networks | Saved intactHand, blockHand and comparatorHand | Primary RMS discrepancy can be audited cache-only, but that audit has not been run after this prerequisite stop |
| Additional sampled movements, thirty records | Identities, parameters, eight target RMS errors, eight endpoint discrepancies and finite flag | No hand trajectories in any additional record. Ten records duplicate the primary; the remaining twenty distinct network/solution sets (160 target trajectories) cannot have RMS errors independently recomputed |
| Two partial-removal policies, ten networks each | mode, stateError, pr, observed, expected, K, go and inputMax | No rates, lateRates, geometry, covariance or projected activity for these twenty network/policy sets; their actual finite-window PR/alignment cannot be independently recalculated |
| Four nonorthogonality/gain sensitivities | Summary PR/alignment, K, state error, input/rate maxima, settling and kappa | No sensitivity prep/full-reference rates, covariances, projection matrices or random draws; summary values cannot independently validate themselves |
| Native-versus-fine integration check | curveRelative and goRelative scalars | Fine-step trajectory/GO state not retained; threshold comparison of the scalars is possible, independent paired-trajectory verification is not |
| Grid geometry | go, distance, lateRates, geometry, inputMax, rateMax, stateMax, settle; definitions and nulls | No additional hand trajectories or partial-removal/sensitivity trajectories are hidden in these caches |

The scientific implementation explains these omissions: in
`analysis/stage_3/stage3_consequences.m`, the additional loop retains only
the output of `early_error` and endpoint differences, not `hand`; each partial
policy retains summary metrics and terminal state, not `p.rates` or `g`;
sensitivity records omit `ip`, `bp`, `im`, `full`, `ig`, `bg`, `fg` and `nv`;
the fine-step check saves only two differences, not `fine`.
These are existing retention gaps, not numerical mismatches demonstrated by
this task. The complete original numeric records remain intact.

Primary/additional identity comparison confirms ten duplicates, one per
network: direction1/grid5. There are40 registry entries but30 unique sampled
network/direction/grid identities, nested within ten independent networks.
For networks1..9, missing additional hand sets are direction2/grid24 and
direction3/grid16. For network10 they are direction2/grid15 and direction3/grid24.
No selection was rerun or changed. A duplicate is not a new independent unit.

## Why completion stopped

The requested finalization must independently calculate actual movement RMS
discrepancies and measured finite-window geometry from saved evidence. Endpoint
states, saved metric scalars or repeating their arithmetic cannot substitute
for missing hand trajectories or actual partial-removal population data.
Reconstructing them would require forbidden neural/arm integration; using
settled-state formulas would replace the specified finite-window analysis.
Neither was done. No claim is made that the reported values are false; their
required independent verification is unavailable under the current cache-only
authority. The prior report's claim that numerical computation completed does
not establish that all raw evidence needed for this new audit was retained.

Following the explicit stop rule, the numeric-mask/legend repairs and remaining
figures were not started. The original two FIG/PNG pairs remain byte-for-byte
preserved. No summary-only diagnostics were published as validated figures.
No complete independent scientific audit, Code Analyzer rerun, final summary
export, native image upload or Git checkpoint is claimed.

## Preservation and files

`finalize_preservation_check.ps1` is a new read-only provenance helper. It
hashes all233 prior protected Stage-1/Stage-2 paths against the old manifest,
plus existing Stage-3 numerical inputs, source, figures, historical receipts,
configuration and accumulated dirty documentation. It writes only new
`FINALIZE_INPUTS_BEFORE.csv`, `FINALIZE_INPUTS_AFTER.csv` and
`FINALIZE_PRESERVATION.json`; these contain the actual outcome. No original
file is overwritten. New receipt filenames are protected from repeat overwrite.

Preservation completed successfully at 2026-09-07T22:35:53.2139964Z:
all 233 protected Stage-1/Stage-2 paths match the prior manifest, and all
292 inventoried existing files (1,895,050,885 bytes) match before/after,
with zero mismatches. The hashing command exited 0. This verifies preservation,
not the incomplete scientific audit.

Final read-only Git inspection confirmed the unchanged HEAD and tracking SHA,
unchanged branch/upstream and empty index. The four pre-existing tracked edits
remain (.gitignore, AGENTS.md, MODEL_SPEC.md, README.md; 98 insertions and
2 deletions), together with the accumulated untracked Stage-3 work and these
new receipts. Git reports routine LF/CRLF notices for those four existing edits;
no line-ending conversion was performed. The worktree intentionally remains dirty.

This task adds only that helper and FINALIZE-prefixed inventory/preservation/
stop receipts. No pre-existing MATLAB code, scientific file, figure or root
documentation file was edited. The original STOP_REPORT.md and
STOP_PRESERVATION.json remain historical and unchanged. No MATLAB code was
changed, so no new-file Code Analyzer pass is asserted.

Notion receives one new stop entry under Run entries, actual task/handoff
status and a precise evidence-availability qualification on the existing
Stage-3 pages. Equations, Mermaid, current provisional numerical values,
four native children, prior log entries and Stage-1/Stage-2 scientific pages
remain unchanged. No new model or task-page hierarchy was created.

## Review decision needed

Provide the missing original raw caches if they exist elsewhere in the active
project, or separately authorize a narrowly bounded deterministic recovery
that saves the missing evidence and compares it with every existing summary
without changing original outputs. Recovery is a proposal, not current
authorization, and no such replay has been performed. Alternatively, an
explicitly revised audit/acceptance scope would be a scientific review decision,
not something the agent can silently infer.

All remaining publication/checkpoint work is blocked behind that decision.
No new commit SHA exists; the original checkpoint and expected dirty worktree
are preserved. No prediction, noise, tuning, learning, adaptation or new model.
