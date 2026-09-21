# Corrective panel provenance

This directory is the Control-derived >=95%-variance correction, not a new
model. Its locked plan is PLAN.md. Numerical completion and scientific review
status are recorded in REPORT.md and the current Notion handoff when available.
The unchanged paper_prepare, paper_move, paper_noise, paper_geometry and
paper_json helpers remain explicit dependencies. Historical status applies to
the old primary K15 selection/results, not to valid shared numerical helpers.

## Current versus historical

The entire previous paper checkpoint aebd5fdfd300c19eca85548315357f11ecfd44ac,
including its K=15-selected geometry, common-K sensitivity, figures, raw
trials, source code and report, remains unchanged. It is historical evidence,
not a primary-analysis fallback. The all-file hash inventory and final
comparison live under artifacts/manifests/paper_ready/alignment95/.

| Current output | Scientific source | Unchanged source reused |
|---|---|---|
| main_modelling_alignment95 a/b | copied Stage-2 panel source | frozen Stage-2 effort sweep and original statistics |
| main_modelling_alignment95 c | same two-component controller equations | accepted controllers, lambda=10, kappa0 |
| main_modelling_alignment95 d | alignment95/geometry, controls | empirical FIG extraction, same physical grid/feasibility, saved grid trajectories |
| support_calibration_alignment95 | old timing + corrected grid/window summaries | timing, readiness, native traces; K15 at the newly selected candidate only as sensitivity |
| support_noise_controls_alignment95 | alignment95/controls | fixed seeds, noise levels and standard Intact reference |
| support_movement_qc_alignment95 | alignment95/cache trajectories + QC | unchanged Stage-1 generator/readout/arm and saved Intact movement |

Paths in this table are relative to results/paper_ready/ unless otherwise
specified. Large new raw evidence is in results/paper_ready/cache/alignment95/;
the compact report/source tables are in results/paper_ready/alignment95/.
Renderer: figures/paper_ready/alignment95/paper95_figures.m. Editable FIG and
PNG pairs: plots/paper_ready/{fig,png}/*_alignment95.{fig,png}.

The empirical targets are the frozen graphics-object extraction from
dimensionality_alignment_epochs_raw_data.fig, SHA256
B2B1381FCFEFABBA5065E8D7617DB0D5A9E5EF08C6A120E539AE980C635A824F.
Displayed empirical uncertainty is resample SD; model error bars are SE of
the network median from the frozen whole-network bootstrap indices. No
unrecoverable paired empirical error bar is fabricated.

## Independent evidence

paper95_grid_audit uses explicit neuron loops, covariance eigendecomposition,
projected sample variances and independently accumulated null QR projectors.
It checks minimal >=95% K, comparator width, Control denominator, null width,
unchanged feasibility/PR and selection with the frozen loss/tie rules.
paper95_control_audit checks raw-trial averaging, late/window/half-split
alignment and PR, residual variance, movement increments and endpoint scatter.
paper95_audit checks saved native transitions, arm steps, event flags and
bootstrap error bars. FIG export reopens editable objects and compares tagged
source/error-bar arrays. PNGs also require visual review.

No prep-to-movement prediction, regression or panel e is part of this output.
