# Canonical manuscript code and data index

Current map: Fig6a–h and ED7a–d. [Model](final_v3/production/MODEL.md), [legends/statistics](final_v3/production/LEGENDS.md), [report](final_v3/production/REPORT.md), [reproduction](final_v3/production/REPRODUCTION.md).

| Layer | Repository path |
|---|---|
| Public commands | `run_paper_figures.m`, `run_paper_model.m` |
| Native figure reconstruction and audit | `analysis/paper_ready/final_v3/production/pf_figures.m`, `pf_draw.m`, `pf_snapshot.m`, `pf_validate_sources.m` |
| Frozen model replay | `pf_model.m`, `pf_prepare.m`, `pf_move.m`, `pf_noise.m` in the same production folder |
| Feature extraction/prediction | `pf_features.m`, `pf_folds.m`, `pf_ridge.m`, `pf_prediction.m` |
| Sweep/grid/frozen illustration replay | `pf_replay_lambda.m`, `pf_replay_geometry.m`, `pf_replay_illustrations.m` |
| All-trial behavior | `pf_behavior.m`, `pf_audit_behavior.m` |
| Accepted models and reference preprocessing | `data/paper_ready/final_v3/network_01.mat` … `network_10.mat` |
| Plain-array graphics / static schematic | `data/paper_ready/final_v3/*_graphics.mat`, `Fig6c_schematic.png` |
| Full-precision sources / immutable inference | `data/paper_ready/final_v3/tables/` |
| Canonical figures / sources | `plots/paper_ready/final_v3/production/{fig,png,source}/` |
| Local generated outputs | `generated/paper_figures/`, `generated/paper_model/` |
| Unchanged foundation | `src/published_generator/` |

[Panel provenance](../../data/paper_ready/final_v3/panel_provenance.json) records historical source names only, not runtime dependencies. [Cleanup inventory](final_v3/production/cleanup_plan.csv) and the report document retirement. Historical code/figures remain recoverable at pre-production commit16aed212496647858770733919fb34c628dac85f; unique uncommitted material is separately preserved. No archive or ignored cache is needed for the current workflow.
