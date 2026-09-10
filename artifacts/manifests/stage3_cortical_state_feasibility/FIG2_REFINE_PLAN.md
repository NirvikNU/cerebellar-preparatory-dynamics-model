# Stage-3 Diagnostic Figure 2 refinement

Authority: STAGE3-DIAGNOSTIC-FIG2-REFINE-01, Notion revision
2026-09-10T08:11:06.791Z. Starting checkpoint
823798ca7dbbdeee14ecb473f1bd7c6fb9ced206 on both local/tracking/remote main
and v3-romano-hennequin. Clean worktree/index, zero desktop.ini/locks,
status/show-ref/full fsck and one normal fetch passed. Dangling objects retained.

## Fixed implementation plan before analysis

1. Preserve every existing scientific/cache file by hash before changes.
2. Source baseline: calibrate_source_faithful_generator.m defines
   h = spontaneous - W*max(spontaneous,0); stage3_prepare.m starts at that
   same spontaneous state. Verify the identity and forward Euler dynamics
   without any preparatory controller over GO -700:-500 ms, dt=.2 ms,
   saving 1 ms. Require cue state agreement with the frozen initial state
   within the existing abs 1e-9 + rel 1e-10 tolerance. Save this evidence
   separately. Do not shift/reinitialize any cached preparation trajectory.
3. Reuse all 260 eight-target preparations and old -400:0 metric arrays.
   Prepend the verified target-independent baseline. State error is valid
   throughout -600:10:0; PR/alignment at zero target-centered covariance
   are undefined and must be NaN/masked, not numerical roundoff structure.
   First new possible population endpoint is -490; retain inclusive trailing
   100-ms windows sampled 10 ms. Independently verify newly computed geometry.
4. Preserve frozen SD/fullCov, seeds, 10,000 draws and strict >95% common K.
   Reuse saved mean null projectors where available; generate only a missing
   K with the same algorithm/seed and independent QR check. No new tests.
5. Independently recompute/check old -400:0 quantities and four original GO
   anchors. Stop on any material discrepancy. Save expanded outputs in
   gain_time/refined/; retain the original compact results and audit unchanged.
6. Replace only Diagnostic Figure 2 with common [-600,0] axes, cue/GO/nu=3
   markers, explicit NaN mask, six independent linear colorbars based on
   finite panel values, and original GO squares. No scale exaggeration of
   machine-precision state error. Reopen FIG, inspect PNG, check plotted data.
7. Update only affected current documentation in existing Notion pages and
   repository. Preserve history. Focused cleanup only, no broad reorganization.
8. Validate preservation/diff; one normal commit/push v3, no-loss FF/push main
   if still possible; verify local/tracking/direct remote equality and clean
   status. Log actual outcome and stop for scientific review.

No new preparation, reference, movement, grid, selection, model, tuning,
noise, prediction, learning or adaptation is planned. Only ten bounded
controller-free baseline segments and cache-only geometry extension.
