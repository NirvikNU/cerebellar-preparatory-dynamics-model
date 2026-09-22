# Paper panel-e prediction review bundle

Task: PAPER-MODELLING-PANEL-E-PREDICTION-01. Frozen starting checkpoint:
`70fff703f8fd3074bef62ca9954a03bef50e4d99`.

## Review order

1. `RESULTS.md`: completed combined primary/RRR numbers, all-network values,
   matched-PC control and exact paired tests; scientific review pending.
2. `PLAN.md`: fixed inputs, timing, preprocessing, folds, penalties, seeds,
   primary controls, RRR rank rule and network-level inference.
3. `history/PRIMARY_RESULTS.md`: independently audited primary-phase report,
   retained as historical phase evidence, not a separate current summary.
4. `FIGURE_LEGENDS.md` and `PANEL_SOURCES.md`: caption/array provenance.
5. `RRR_DERIVATION.md`: manuscript objective, independent solver derivation,
   one-SE rule and distinct uncertainty units.
6. `history/EXECUTION_RECOVERY.md`: transparent runtime-only recovery; failed-start
   receipts are provenance, not scientific outcomes or alternate estimators.

## New paths only

- Source: `analysis/paper_ready/prediction/`.
- Cache-only rendering: `figures/paper_ready/prediction/pe_figures.m`.
- Compact summaries/audits: `results/paper_ready/prediction/`.
- Required raw evidence: `results/paper_ready/cache/prediction/` (ignored,
  local-only; retain these files for independent reproduction).
- Editable figure pairs: `plots/paper_ready/prediction/{fig,png}/`.
- Preservation, runtime, publication, inventory and Git receipts:
  `artifacts/manifests/paper_ready/prediction/`.

Raw `series_nXX_pP.mat` holds recovered neural series and exact frozen
trial identities/features; `primary_nXX_pP.mat` holds the PCA, folds,
permutations, nested ridge evidence and predictions; `matched_nXX.mat`
holds matched-PC fits. `rrr_nXX_pP.mat` retains all repeated rank curves,
inner-search losses, selected penalties, folds/permutations and observed
fitting factors. Policy order throughout is Intact, remove-feedback,
remove-b, Block. No target or flagged movement trial is excluded.

Production writers refuse overwrites. Do not call trajectory recovery,
primary regression, RRR or renderers merely to inspect this bundle. Existing
saved outputs and the Notion completion/stop receipt determine actual status.
No completion claim follows from a launched process or an implementation file.

All accepted models and prior paper artifacts remain protected byte-for-byte.
No behavioral/speed/movement-end prediction, adaptation, target jump, extra
RRR variant or model/noise/geometry tuning is included. Scientific review,
not automatic continuation, is the stopping boundary. The original run left
review artifacts uncommitted. The separately authorized cleanup/release now
packages them; see `../CURRENT_REVIEW.md` and the cleanup-release receipt.
No scientific computation is authorized by this navigation update.
