# Paper modelling code and evidence index

## Current final-v2 model

`f(x)=-x+W*ReLU(x)+h`; eta=0, lambda=10, V realization 1.
Base input `-f(xB)`; state setting `b=f(xB)-f(x*)`; structured prospective
feedback `-L*(x-x*)`. Intact includes base+b+feedback; full Block includes
base only. No generic residual kappa feedback. Shared alpha=.5, beta_norm=1.25
was frozen before downstream evaluation. Primary s_init=s_temporal=.10.

Current figures: `plots/paper_ready/final_v2/` (Main A–J and ED1–5, native FIG/PNG).
Current report/legends/panel mapping: `docs/paper_ready/final_v2/`.
Compact numerical evidence: `results/paper_ready/final_v2/`.
Validation, inventory and preservation: `artifacts/manifests/paper_ready/final_v2/`.

| Assay | Exact implementation / evidence |
|---|---|
| Fixed shared geometry grid | `v2_grid`, `v2_grid_network`; geometry.mat, geometry_selection.json, calibration_*_fullprecision.csv; full 36-point scores and Control-derived minimum-95% K |
| Frozen policy / stochastic replay | `v2_definition`, `v2_simulate`, `v2_load`, `v2_reuse`; original `paper_prepare`, `paper_noise`, `eta_move`; simulations completed, not a reader-side entry point |
| Corrected pre-cue convergence | `v2_convergence`, `v2_convergence_audit`; trial_metrics.csv contains the single pre-cue and pre-go distances, ratios, guards, reference-only PCA95 capture/K |
| PCA75 nested ridge / controls | `v2_case`, `v2_analyze`; unchanged `pe_features`, `stage3_prediction_ridge`, `ns_controls`; network_metrics.csv, paired_noise_effects.csv, full shuffle/control source tables |
| Speed-matched dispersion | `v2_behavior`, `v2_dispersion_resolution`; six-network conditional Main E, dispersion_resolution.mat/JSON and dispersion_matched_subset.csv; unchanged 5%/5-pair/5-target rules |
| Unmatched robustness control | `v2_dispersion_resolution`; dispersion_unmatched_all10.csv, dispersion_unmatched_targets.csv and DISPERSION_CONTROL.md; descriptive all-ten-network control only |
| Movement / event QC | `v2_case`, `eta_move`; trial_metrics.csv and network_metrics.csv; every flagged trial retained, no display truncation in analysis |
| Readiness provenance | `v2_readiness`; readiness.mat and figure_sources.mat; eta0 lambda10=109.5 ms, no lambda reselection |
| Tables / figures | `v2_sources`, `v2_control_tables`, `v2_figures`, then authorized `v2_finalize_figures`; figure_sources.mat plus dispersion_resolution.mat are the final figure sources |
| Independent verification | `v2_audit`, `v2_output_audit`, `v2_dispersion_resolution`, `v2_finalize_figures`; audit.json, output_audit.json, final_figures.json, visual_review.json |

New analysis helpers reside in `analysis/paper_ready/final_v2/`; renderers in
`figures/paper_ready/final_v2/`. Add these two directories explicitly, then
`v2_paths(pwd)` resolves existing dependencies; never use project-wide genpath.
Writers intentionally refuse completed-output overwrites. Do not execute grid,
simulation, selection or fitting writers merely to inspect saved results.

## Reproduction boundary

Git contains durable source, plans, compact results/source tables, native figures,
captions and audit manifests. All exact panel series/error bars are embedded in
the committed FIGs and compact figure master; figures can be inspected without
large raw caches. On a separate output tree with required source inputs restored,
the cache-only rendering sequence is `v2_figures(root)` followed by
`v2_finalize_figures(root)`; it does not simulate or fit. `v2_finalize_figures`
expects the committed dispersion_resolution.mat and saves draft backups locally.

A complete scientific replay additionally requires intentionally non-versioned
`results/stage_1/current/ensemble/`, Stage-3 reference/controller caches,
`results/paper_ready/cache/` (including exact reused alignment95, prediction,
eta and noise caches), plus pinned licensed source inputs. The loaders and
preservation manifests identify exact files/hashes. These assets are not fetched
or reconstructed by a fresh clone. No clean-room full rerun is claimed.

The final source master retains cached historical Stage-2/empirical arrays for
A/B/G/H. Empirical uncertainty is the original pooled resample SD, not biological
replicate SE. Earlier Intact raw component-wise metadata remains historical
where explicitly documented in final_v2/SOURCE_DATA.md; total trajectories,
noise, movement and feature evidence were reused exactly.

## Preserved earlier analyses — not final-v2 parameter definitions

| Bundle | Code | Results / documentation / figures |
|---|---|---|
| Corrected alignment95 | `analysis/paper_ready/alignment95/paper95_*` | `results/paper_ready/alignment95/`; `docs/paper_ready/alignment95/`; `plots/paper_ready/{fig,png}/*alignment95*` |
| Prior PCA-ridge and full-space RRR | `analysis/paper_ready/prediction/pe_primary`, `pe_rrr`, associated audit helpers | `results/paper_ready/prediction/`; `docs/paper_ready/prediction/`; `plots/paper_ready/prediction/`; RRR is historical secondary analysis, not rerun for v2 |
| Residual-stabilization eta sweep | `analysis/paper_ready/stabilization_eta/eta_*` | corresponding stabilization_eta result/doc/plot roots; all five eta values retained, historical post-cue C differs from corrected v2 C |
| Prior bounded noise sensitivity | `analysis/paper_ready/noise_sensitivity/ns_*` | corresponding noise_sensitivity roots; two four-panel figures and original .5/1 geometry/eta0–1 analyses retained unchanged |
| Frozen Stage-1/2/3 | `src/`, `analysis/published_generator/`, `analysis/stage_2/`, `analysis/stage_3/` | root historical documentation and dated manifests; accepted science unchanged |

The final commit also packages the already completed, previously uncommitted
noise-sensitivity bundle. Historical task stops/receipts are provenance, not
permission to repeat analyses. Final Git identity is the containing release
commit; verified local/tracking/direct remote identity is recorded in Notion
and `.git/paper-modelling-final-v2-release.json` after push.
