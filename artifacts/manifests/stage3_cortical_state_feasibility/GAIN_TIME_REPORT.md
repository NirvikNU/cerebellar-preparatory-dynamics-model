# STAGE3-DIAGNOSTIC-GAIN-TIME-01 — completion report

## Outcome

The fixed gain/time diagnostic, independent checks, revised Diagnostic Figure 2,
native Notion publication and conservative root organization are complete.
No scientific acceptance is implied. The normal commit/push and safe main
synchronization receipt, including the final SHA, is recorded in Agent Log,
Agent Handoff and START HERE after remote verification.

Active repository:
E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model.
The old Google Drive path and relocated archive were not accessed.
The user performed relocation/desktop.ini removal; this run performed no Git
metadata deletion or repair. Git status/show-ref/fsck --full and one normal
fetch --prune origin passed. Zero desktop.ini and zero locks were found.
Dangling objects were retained. Starting local/tracking/direct-remote v3 was
65816fa4052f55982ba92cc7d9f9cea2a916eaa8; main/default was
f3c85bf5bfea06868a7360e2370d4d29a5ab62c5, an ancestor with zero unique and
16 fewer commits. Main was not advanced at the start.

## Fixed experiment and reuse

Ten frozen networks, eight targets, primary direction 1/grid 5, alpha=.1,
normalized beta=1, unchanged kappa/xB/xstar/initial state and cortical policy.
Only nu=0:.5:6 varied; b present and b absent. Integration .2 ms for 500 ms,
saved 1 ms, analyzed 10 ms. No reference generation, 1080-point map, new
directions, solution selection, movement, prediction, noise, training,
learning, tuning or adaptation.

30 original eight-target trajectories were reused: intact nu=3 and the two
recovered partial-removal endpoints in every network. Exactly 230 missing
eight-target trajectories were integrated once (1840 target preparations).
The original block retained only late rates, so its full nu=0 trajectory was
one authorized diagnostic-grid case, not a repeated full sweep.
One numerical batch took 349.7090137 s, excluding file serialization.

Displayed endpoints GO=-400:10:0; state error is instantaneous full-200D
target-mean distance. PR/alignment use inclusive trailing 100-ms windows.
Frozen intact SD, target centering, per-neuron column identity and original
full-reference null covariance remain unchanged. Matching-window intact
covariance is used in alignment numerator/top-K denominator. Common K is
minimum strictly >95% for both conditions, actual range 5–7.
Null: same 10000 covariance-biased Gaussian/orth draws, mt19937ar seed
2026090900+network, cached by network/K. The average subspace projector uses
linearity of trace to evaluate each window without new random identities or
reused terminal scalars; independent QR projectors verify the expectation.

## Validation

- 54130 comparisons PASS; maximum error 9.325873406851315e-15.
- 240 original-policy GO/state/PR/observed/expected/K comparisons:
  maximum 4.440892098500626e-15. Original block late activity,
  distance curves and GO states also match.
- Independent explicit-loop neuron covariance/eigen PR/K, full-state distance,
  projection/trace and orth/QR null comparisons cover all 10660 cells.
- Tolerance declared before integration: absolute 1e-9 plus relative 1e-10.
  No material discrepancy and no altered scientific definition.
- All changed/new MATLAB files pass Code Analyzer and the neuron sentinel.
- Final saved-figure audit: 28 checks, maximum error zero, including six
  heatmaps checked against independently sorted network medians, axis
  coordinates/orientation and shared color limits.
- New FIG reopened; new PNG visually inspected at full readable resolution.
  Other three Stage-3 FIG/PNG pairs remain byte-identical.
- 420-file baseline, all 292 prior relocation hashes matched. Final strict
  preservation confirms 233 Stage-1/2 protected files and 253 original
  scientific-result/source/configuration files unchanged; no unexpected
  baseline change. These sets overlap, not additive counts.

Detailed checks: GAIN_TIME_AUDIT.json, GAIN_TIME_ALL_FIGURES_AUDIT.json,
GAIN_TIME_PRESERVATION.json, GAIN_TIME_REVIEW.json and GAIN_TIME_FIGURE.json.

## Descriptive result; retain the nearly flat time dependence

The first displayed endpoint is already 100 ms after preparation begins.
Over the displayed range the maximum within-gain variation of the network
median is 7.54e-13 state units, 0.000205 PR and 0.00936 percentage points of
alignment deficit. The window was not shifted to manufacture a transient.

At GO, b present yields essentially zero state error, PR 3.392271 and
expected-minus-observed approximately -49.5532 pp throughout the gain grid.
For b absent, increasing nu from 0 to 6 changes median state error
3.465835 -> 3.044834; PR 6.999270 -> 6.979147; deficit 56.849559 -> 48.897091 pp.
Nu=3 yields state error 3.241699, PR 6.994415 and deficit 53.516757 pp.
These are network medians, no new SE or p values. Feedback changes the
b-absent equilibrium as well as convergence; do not claim it affects speed
only. The prescribed displayed window cannot resolve the much earlier
convergence transient. This is an effective-controller decomposition, not an
anatomical or quantitative experimental-fit claim.

## Figure and Notion publication

Current pair:
plots/stage_3/fig/diagnostic_2_component_removal.fig
plots/stage_3/png/diagnostic_2_component_removal.png

Six heatmaps, 3 rows x 2 columns, matched row color scales, nu=3 dashed line,
GO line and four original policy reference markers; no new standalone panels.
PNG SHA-256 b204c16a1c732579a01617c6a9162334eedd1cc95009d352f3965119bcc8c690.
Native upload 3d626c94-be30-814c-b784-00b2f5a84f66, 258336 bytes, confirmed uploaded
and attached with full caption to the existing Stage-3 Diagnostics page:
https://www.notion.so/3d426c94be30818988a2f9a409023f0b

The first diagnostic's native uploaded file/caption and all prespecified
sensitivity/envelope content remain preserved. Terminal four-policy values
and original bootstrap SE remain explicitly labelled validation anchors,
not new heatmap uncertainty. The Technical Specification adds the fixed
gain/time definition and current figure description. Results, Presentation-
ready Summary/Mermaid and Stage-3 parent/four child-page identities are
unchanged (Results comparison ignores regenerated signed image URLs).
The skill-guided workflow kept updates in existing pages rather than creating
a duplicate task/model hierarchy.

## Root organization, before -> after

Every one of the 41 original top-level entries is classified in
GAIN_TIME_ROOT_ORGANIZATION.csv, with exact destinations and reasons.

- Retained 22 entries: .git/.gitignore, four project-level Markdown files,
  seven documented canonical MATLAB runners, and nine established directories.
  No tracked entry point was moved just for cosmetic symmetry.
- Moved 15 nonempty historical Stage-3 logs, with matching SHA-256, into
  artifacts/manifests/stage3_cortical_state_feasibility/execution_logs/.
  They remain ignored/local provenance. Historical receipts retain their
  original basenames; README and this mapping explain their current location.
- Removed only four zero-byte scratch logs: stage3_code_preflight.log,
  stage3_diagnostic2_headroom_review.log,
  stage3_finalization_code_mask_fixed.log,
  stage3_recovery_audit_code_fixed.log. They contained no scientific evidence.
- No live MATLAB/PowerShell source refers to a moved/deleted log as an input.
  No public runner path changed. Source, tests, figures and documentation use
  the maintained diagnostic under analysis/stage_3/ and figures/stage_3/.

## New outputs and implementation-only fixes

Compact data: results/stage_3/current/gain_time/gain_time.mat (131592 bytes),
summary.json and review_anchors.csv. New rates/states/null projector evidence
remain local-only in cache/gain_time/. The full initial audit-bearing MAT
was slow to serialize in v7.3 (many small structures); it is preserved with
its hash in cache/gain_time/gain_time_with_checks.mat. The compact tracked
MAT was proven value-identical after separating detailed checks, which
remain in JSON. No integration or summary calculation was rerun to compact it.
There are 241 new local cache files, 1097214784 bytes including that complete
serialization provenance; no large cache was staged.

The first figure-validator coordinate check assumed a two-element XData/
YData representation; MATLAB retained full vectors. The check now verifies
endpoints, uniform coordinate grid, image size/orientation and every plotted
value. This audit-harness repair required no re-render or data change.
Notion exact replacement against expiring signed image URLs failed without
mutation; the existing Diagnostics body was updated with stable native-upload
references, preserving all unrelated content and the first figure.
No scientific mismatch was hidden by either presentation/export fix.

New code: run_stage3_gain_time, stage3_gain_time, stage3_gain_time_prepare,
stage3_gain_time_check_figure, stage3_gain_time_compact,
stage3_gain_time_review and stage3_gain_time_figure. Existing dispatcher and
saved-figure audit select the new validated figure while preserving original
renderer execution provenance and original audit receipts. README/MODEL_SPEC,
the Diagnostic-2 pair and the planned manifests/results are intended changes.
The earlier untracked GAIN_TIME_GIT_REPAIR.md stop receipt is included unchanged.

## Checkpoint boundary

After the complete diff and Notion readback, make one normal v3 commit/push.
Use only a no-force fast-forward operation for main, verify all four local/
tracking refs against a direct remote lookup and a clean index/worktree,
then record the actual SHA/outcome in Notion and stop for scientific review.
No scientific acceptance or further model is implied.
