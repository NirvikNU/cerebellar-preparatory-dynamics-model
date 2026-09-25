# Current paper-modelling review set — final v2

Current paper-facing outputs: [final-v2 report](final_v2/REPORT.md),
[figure legends](final_v2/FIGURE_LEGENDS.md),
[code index](PAPER_CODE_INDEX.md) and [release receipt](final_v2/RELEASE.md).
Eta=0, lambda=10, shared alpha=.5 / beta_norm=1.25, primary noise .10/.10.
Panel E uses the authorized six-network speed-matched subset; all-ten-network
unmatched dispersion is a separate robustness control. All other panels use
ten networks. No geometry, noise or downstream outcome was retuned on resumption.

The prior review narrative below is preserved historical provenance. Its
earlier parameter-review and “current” wording does not supersede final v2.

## Historical review set from the preceding release

Stabilization-eta is complete and numerically validated. Scientific
interpretation and any eta choice remain pending user review. No further
analysis is authorized. A release checkpoint is packaging, not scientific
acceptance. Do not rerun completed writers to inspect these results.

## Read in this order

1. [Corrected alignment95 report](alignment95/REPORT.md): current primary
   geometry, exact Control-derived K, imperfect empirical agreement, separate
   noise controls and movement/event QC. Old K=15-selected results remain
   historical provenance, not the primary calibration.
2. [Prediction/RRR results](prediction/RESULTS.md): completed panel e,
   matched-PC/shuffle controls and full-space RRR; retain negative/mixed
   outcomes and distinct PCA-ridge versus RRR estimands.
3. [Stabilization report](stabilization_eta/REPORT.md),
   [existing interpretation](stabilization_eta/INTERPRETATION.md), and
   [completion receipt](stabilization_eta/COMPLETION.md): the entire fixed
   eta grid, all QC flags and independently audited uncertainty. No eta chosen.

Reports are dated scientific/execution receipts. Their original statements
about then-uncommitted work or an earlier stop remain historical, not current
Git status or authority to repeat a run. Current release state is recorded in
Notion and the cleanup-release receipt after synchronization.

## Ten current figure pairs

Each basename has an editable `.fig` and a matching `.png`; source arrays,
legends, numbers and prior visual/numerical audits are unchanged by cleanup.

| Bundle | Basenames | Pair roots |
|---|---|---|
| Corrected alignment95 | main_modelling_alignment95; support_calibration_alignment95; support_noise_controls_alignment95; support_movement_qc_alignment95 | plots/paper_ready/{fig,png}/ |
| Prediction/RRR | panel_e_pca_ridge; panel_e_controls; extended_data_rrr | plots/paper_ready/prediction/{fig,png}/ |
| Stabilization | stabilization_eta_six_panel; stabilization_eta_movement_qc; stabilization_eta_kinematics | plots/paper_ready/stabilization_eta/{fig,png}/ |

Full legends are in the corresponding `FIGURE_LEGENDS.md` or `CAPTIONS.md`.
Compact outputs/source tables and audits are under matching
`results/paper_ready/{alignment95,prediction,stabilization_eta}/` roots.
Large trajectory, fit and null caches remain required and local-only under
`results/paper_ready/cache/`; never stage or delete them as scratch.

## Historical provenance and release navigation

- Prediction and stabilization historical phase/stop notes are under each
  documentation bundle's `history/` directory. Original dates/text are intact.
- [Cleanup plan](../../artifacts/manifests/paper_ready/cleanup_release/PLAN.md),
  inventory, relocations, deletion ledger and preservation/static/figure
  receipts are under `artifacts/manifests/paper_ready/cleanup_release/`.
- Historical manifests retain their original paths. `RELOCATIONS.csv` maps
  those paths to retained byte-identical documents/logs. This is not an active
  model archive and introduces no archived scientific dependency.
- Native [current figure gallery](https://www.notion.so/3e026c94be30810c8b2ce843260cd7db)
  and [historical checkpoint archive](https://www.notion.so/3e326c94be3081228b90c49a81c0c600).
- [Agent Log](https://www.notion.so/3d326c94be3081e897a2e5e0c855c4c0) retains
  chronology. Current Task, Handoff and START HERE carry the verified final SHA.

Frozen Stage-1/2/3 science and all prior committed paper science remain
unchanged. Cleanup runs no simulation, fit, RRR, parameter selection or
scientific reinterpretation. Stop for scientific review.
