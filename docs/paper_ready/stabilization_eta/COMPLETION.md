# Completion and visual-review receipt

22 September 2026. PAPER-MODELLING-STABILIZATION-ETA-01 completed as a separate
diagnostic. Stop for scientific review. No eta selected; no RRR or further model.

- Reused the passed preservation, equation/Jacobian and eta1 reproduction
  evidence. Those gates were not run again.
- Ran exactly80 lower-eta network/condition preparation-and-movement cases,
  covering19,200 new trajectories, once. The simulation receipt reports
  2,150.8seconds and zero new baseline simulations.
- Reused4,800 eta1 trajectories and the original observed PCA-ridge fits.
- All100 derived cases pass the independent saved-output audit. Maximum
  convergence discrepancy1.715e-13, geometry8.89e-15, held-out prediction
  1.47e-13, R2 discrepancy4.45e-16, bootstrap-SE discrepancy0.
- Synthetic reference-only/leakage and neuron-column identity tests pass.
- All14 MATLAB files under the diagnostic analysis/figure roots pass Code
  Analyzer without messages. This includes the three previously completed
  baseline helpers; none of their scientific routines was rerun.
- Every FIG was reopened and checked against its plotted source values and
  uncertainty:154 objects for the six-panel diagnostic,204 for movement QC,
  and160 for network1 kinematics (518 total).
- Every matching PNG was visually inspected. Labels, condition legends,
  zero boundaries, error bars, all five eta values, separated PR/alignment
  mini-axes and shared kinematic limits are readable. No prior figure replaced.
- All100 cases pass frozen preparation bounds; all movements are finite.
  All24,000 trial observations are retained, including boundary/multiple-peak
  flags. No missing prediction window or undefined convergence denominator.

The main outcome is negative for preserved positive Intact contraction:
network-level C is negative in both conditions at every eta. Lower residual
stabilization worsens bias/dispersion in both conditions and changes the
calibrated geometry. Prediction loss grows but is not a selection criterion.
See INTERPRETATION.md and REPORT.md for complete quantitative conclusions.

All new output and documentation are under stabilization_eta roots. The
separate output inventory hashes this diagnostic only; the prior full-project
preservation check is reused, not repeated. Original model, alignment95,
panel-e and RRR files remain read-only and unchanged by this run.

Execution notes: one unused Code Analyzer suppression stopped the initial
launcher before simulation; removing that obsolete comment allowed the sole
production run. The first native image-upload attempt was rejected because
the multipart content type was generic; a fresh upload with image/png succeeded.
Neither issue changed or reran scientific outputs. No files were deleted.

Native Notion publication and final Git receipts are recorded under
artifacts/manifests/paper_ready/stabilization_eta. HEAD remains
70fff703f8fd3074bef62ca9954a03bef50e4d99 on v3-romano-hennequin.
Tracked worktree/index diffs remain empty; previous prediction and new
diagnostic review files remain untracked. No staging, commit or push.
