# Cleanup/release audit

23 September 2026. PAPER-MODELLING-CLEANUP-RELEASE-01; starting checkpoint
70fff703f8fd3074bef62ca9954a03bef50e4d99. This task performs no simulations,
fits, RRR, eta selection, parameter changes or scientific reinterpretation.
Stabilization remains numerically validated and pending scientific review.

## Notion preservation and cleanup

Created **99 — Archive — Historical Modelling Checkpoints & Figures** under
the existing paper-ready parent. Six native duplicates preserve the complete
pre-cleanup 01/02/03, Task, Handoff and START HERE pages. A seventh snapshot
preserves the parent prose, converting its child links to references without
moving the active child pages. Content comparisons pass after normalizing
Notion mention rendering and temporary image URL signatures.

The archive retains all14 original native images. The active gallery retains
ten current review figures with full scientific legends: four alignment95,
three prediction/RRR, three stabilization. Each current image was reattached
as native Notion media and downloaded in memory for SHA256 comparison to its
unchanged local PNG; all ten match. No signed URL is stored as a durable link.
Parent/01/03 are concise and current. All13 unique internal page targets resolve.
The Agent Log chronology is not pruned; compact management status is updated
only after successful Git synchronization.

Native archive: https://www.notion.so/3e326c94be3081228b90c49a81c0c600
Current gallery: https://www.notion.so/3e026c94be30810c8b2ce843260cd7db

## File inventory and actions

Full pre-cleanup inventory: **2,296 files /169,191,379,199 bytes**, including
hidden, ignored and untracked files, excluding Git administration and this new
release-manifest directory. Both prior protected manifests pass:2,295 rows,
2,293 unique paths. Full SHA256 verification, not a size-only preflight.

Prediction/stabilization scope:454 artifacts /56,143,597,861 bytes:

| Category | Files | Bytes | Disposition |
|---|---:|---:|---|
| Durable source/code |31|111,806|Retain unchanged|
| Compact results/source tables |27|6,652,270|Retain unchanged|
| Docs/captions/reports |17|103,053|Retain; historical notes consolidated|
| FIG/PNG publication masters |12|48,600,354|Retain unchanged; six matching pairs|
| Audit/manifests/receipts |47|739,755|Retain unique execution/failure provenance|
| Required raw caches |320|56,087,390,623|Retain ignored/local, never stage|

No byte-identical duplicates occur among these454 original artifacts.
Unselected/negative eta outcomes, source tables, raw fitting evidence and all
QC flags are retained. The largest new durable file is the required editable
stabilization kinematics FIG,44,854,137 bytes (below50MiB); it is not a raw cache.

**26 byte-preserving relocations:** five historical phase/stop/contract docs
into their bundle's history directory, plus21 closed nonempty historical logs
into cleanup_release/history_logs as durable text. Each copy was SHA256-checked
before its original path was removed. All remain recoverable by copying back
from RELOCATIONS.csv. Two identical old Stage-2 figure logs are deliberately
retained as separately named phase receipts, not deleted as scientific data.
No figure or scientific code/result file was moved.

**Only three files deleted, all zero bytes:**

- artifacts/manifests/paper_ready/numerical_preflight.log
- artifacts/manifests/paper_ready/render_final.log
- artifacts/manifests/paper_ready/render_review.log

They contained no evidence; they can be recreated as empty files. Their full
paths, empty-file SHA256 and reasons are recorded in DELETIONS.csv. There is
no material data deletion. PACKAGING_CLASSIFICATION.csv was written before
these operations; CLEANUP_INVENTORY.csv classifies the full original scope.

## Preservation and validation

- Final hashes of all unchanged durable protected files pass, including all70
  new scientific source/results/figure files. All26 moved files retain their
  original hashes. Seven documentation/navigation cross-reference edits are
  explicitly allowlisted and reviewed; only AGENTS.md and README.md change
  among prior tracked files. No numerical value or scientific code changed.
- Raw files received full hashes before cleanup; final size/write-time checks
  confirm no subsequent modification, and no scientific writer was called.
- Read-only Code Analyzer passes all31 new scientific MATLAB files and the
  packaging verifier. No scientific helper is executed.
- All ten current FIG files reopen; all matching PNGs decode. Figures are
  neither saved nor re-exported. Prior independent scientific/error-bar audits
  remain intact rather than being rerun.
- Only1,321 intentionally ignored files remain:167 accepted Stage-1 local
  assets,10 Stage-2 caches,777 Stage-3 caches,360 paper raw caches and7 pinned
  source/reference-cache files. No ignored log, transient worker or autosave
  remains. Required source-cache licensing boundaries are unchanged.
- Paths/links in active documentation reflect historical relocations. Dated
  reports and manifests retain original execution/Git statements as provenance,
  not current release status. No failed-start evidence is silently discarded.

The initial staged whitespace check reported original trailing whitespace and
blank final lines in historical stdout/contract snapshots. These records are
deliberately verbatim. Narrow `.gitattributes` rules disable text conversion
and whitespace lint only for relocated history folders; scientific source is
not exempt. Their staged blob bytes are checked against relocation SHA256.
No Git setting was changed and no historical content was trimmed.

## Git release boundary

Stage only reviewed durable artifacts and navigation/cleanup evidence; inspect
the staged diff and exclude all raw caches. One normal commit with message:
`Finalize paper modelling prediction and stabilization diagnostics`.
Then normally push v3; fast-forward main only with safe ancestry and an explicit
expected-old-SHA guard. No force push, reset, rebase, amend or history rewrite.

Final synchronization is not preclaimed by this pre-commit report. Its verified
SHA, refs, clean status and no-lock receipt are written after push to
`.git/paper-modelling-cleanup-release.json` and Notion Agent Log/Handoff/START
HERE/Current Task. This avoids a self-referential commit hash or second commit.
After success, stop for scientific review; no further analysis is authorized.
