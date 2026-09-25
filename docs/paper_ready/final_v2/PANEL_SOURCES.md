# Final-v2 panel/source map

Final Main E overrides only the old undefined ten-network ensemble summary:
use `dispersion_resolution.mat`, `dispersion_matched_subset.csv` and
`dispersion_summary.csv`. Six eligible networks, fixed original matching rule.
The all-ten unmatched robustness control is outside Main E in
DISPERSION_CONTROL.md and `dispersion_unmatched_all10.csv` /
`dispersion_unmatched_targets.csv`. All other panel sources below are unchanged.

Paths below are relative to results/paper_ready/final_v2/ unless stated.
Full-precision MAT master: figure_sources.mat (data struct). All CSV values
written by v2_csv use17 significant digits; MAT retains exact doubles.

| Panel | Master/source | Definition |
|---|---|---|
| Main A/B | data.stage2; MainAB_controller_effort.csv; results/stage_2/current/neural_geometry_r2/analysis.mat | Original Stage-2 PR/observed/expected and bootstrap indices; delta from reference and expected-observed only |
| Main C | docs PLAN/FIGURE_LEGENDS; frozen definition/controller sources | Eta0 equations; no residual feedback |
| Main D | data.representative{1,2}.hand; data.targetXY; MainDF_network1_untruncated.csv | Network1 all targets; display-only1.5cm first entry; unmodified raw arm arrays retained |
| Main E | summary.behavior; behavior_matching.csv; trial_metrics.csv; behavior_statistics.json | Peak positions, exact greedy speed-match indices/coverage, target mean distances from median |
| Main F | data.representative.speed; MainDF_network1_untruncated.csv; network_metrics.csv; trial_metrics.csv; behavior_statistics.json | Target2 display median50ms Gaussian; target-averaged unsmoothed peaks |
| Main G/H | data.empirical; empirical_targets.csv; network_metrics.csv; calibration_map_fullprecision.csv | Original empirical FIG values/resample SD versus current paired networks; calibration disclosure |
| Main I/J | paired_noise_effects.csv; summary.mat | Within-network relative R2 loss and corrected DeltaC; one shared anchor |
| ED1 | network_metrics.csv; summary.mat | Intact absolute R2/C at each fixed one-factor point |
| ED2 | network_metrics.csv primary noise/policies1..4 | PR, alignment deficit, corrected C and PCA75-ridge R2; descriptive |
| ED3 | readiness.mat/json; readiness_bounds.csv | New bounded eta0 timing-only provenance plus preserved historical eta1 comparison |
| ED4 | network_metrics.csv; trial_metrics.csv; summary.qc | Endpoint/separation and all frozen event QC flags |
| ED5 A-C | calibration_ensemble_fullprecision.csv; geometry_selection.json | All36 global losses/effects; no QC screen; frozen winner |
| ED5 D | calibration_map_fullprecision.csv | Control-derived minimum>=95% K/capture/denominator |
| ED5 E | summary.mat/network_metrics.csv; shuffle_controls.csv; raw matched/analysis files | Primary matched-PC fits and100-shuffle median floors |

Policy encoding:1 Intact;2 state-setting only;3 prospective-feedback only;
4 full Block. Noise-pair order: [.05,.10], [.10,.10], [.20,.10], [.10,.05],
[.10,.20]. Units: states source units, hand positions metres in tables,
centimetres in main movement panels, speed m/s, times milliseconds,
alignment percentage or percentage points as explicit column names state.

Core entry points, in dependency order: v2_preflight, v2_grid (selection
receipt gate), v2_simulate, v2_analyze, v2_audit, v2_readiness, v2_sources,
v2_figures, v2_report, v2_control_tables, v2_output_audit. v2_unit and
v2_behavior_unit use synthetic arrays only; v2_static and
v2_packaging_check are read-only source checks. Writers refuse canonical
output replacement.
Resume only the incomplete stage; do not rerun completed writers for inspection.

The following raw paths are relative to results/paper_ready/ (not the
compact final_v2 directory). Raw calibration: cache/final_v2/grid_nXX.mat. Downstream new raw:
cache/final_v2/raw_nXX_vV_pP.mat; corrected assay/fits:
analysis_nXX_vV_pP.mat; pair controls: matched_nXX_vV.mat.
v2_load records exact logical reuse of existing eta0 Intact cases from
cache/noise_sensitivity and cache/stabilization_eta. A full rerun requires
non-versioned accepted networks, frozen reference/grid/controller assets and
the large local raw inputs. Public compact results support inspection and
figure rendering, not a falsely claimed clean-room simulation rerun.

The committed figure_sources.mat contains every numerical array used by the
six renderers, including network-1 untruncated hand/speed arrays and all
readiness curves. Figure regeneration needs this master and committed helper
code, but no raw trial cache. The writer deliberately refuses to overwrite
existing pairs: inspect the committed FIGs directly, or reproduce into an
otherwise prepared scratch copy with those output paths absent. Full scientific
re-audit additionally needs the ignored trial/reference/model caches; it is
not equivalent to merely regenerating a figure from its compact master.
