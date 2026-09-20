# Panel sources and review boundary

Task: PAPER-MODELLING-PREPREDICTION-01. The only main panels authorized are
a–d. No panel-e data, regression, prediction fit or prediction figure is produced.
Completion is established by actual audit/publication receipts, not this map.

| Figure / panel | Saved source | Status and uncertainty |
| --- | --- | --- |
| Main a: feedback-effort PR | Frozen `results/stage_2/current/neural_geometry_r2/analysis.mat`; exact compact copy `results/paper_ready/stage2_panels_ab.mat` and CSV | Existing Stage-2 result, not a new lesion or calibration; unchanged original tests and network-bootstrap indices |
| Main b: feedback-effort alignment | Same Stage-2 source, observed and expected arrays | Same-epoch reference λ=0.1 projected onto each λ; existing common >95%-variance K rule and original null; median ± network-bootstrap SE |
| Main c: effective architecture | Locked equations in `PLAN.md`, renderer `paper_figures.m` | Schematic, not numerical evidence for two anatomical pathways |
| Main d1: geometry fit | `results/paper_ready/geometry.mat` and `geometry_map.csv` | All 36 fixed α/β points; shared feasibility across 10 networks, fixed V=1; loss uses paired network effects, not movement or prediction |
| Main d2–d3: absolute comparison | Same geometry map plus `empirical/targets.mat` | Data: pooled bars ± resampling SD. Model: network medians ± bootstrap SE. These uncertainty estimators differ |
| Supporting timing / geometry | `timing/timing.mat`, `geometry.mat`, `controls.mat` | Timing-only λ choice precedes geometry; component-removal trajectories and attainable range are descriptive |
| Supporting noise-only controls | `controls.mat`, `noise_controls.csv`, raw `cache/controls_nXX.mat` | Separate predeclared cue-state and temporal sweeps; no selected amplitude; network median ± bootstrap SE, Block reference band ± SE |
| Supporting movement / event QC | `cache/controls_nXX.mat`, `movement_trial_qc.csv`, `movement_target_qc.csv` | Fixed network 1 shows all 8 targets and 30 trials. Event histograms use all 10 networks; trial IQR is distinct from network uncertainty |

All new model geometry uses native ReLU rates, 30 trials per target, trial
averaging before analysis, GO −100:10:0 ms, frozen neuron-preserving scales,
the frozen full-reference covariance bias, K=15 and 10,000 null draws.
Adaptive common K strictly exceeding 95% variance is sensitivity only.
The geometry fit is calibration; no new confirmatory testing family is declared.
The 10 networks are the independent computational units, not 2,400 trials.

All four full figures use matching basenames in `plots/paper_ready/fig/`
and `plots/paper_ready/png/`. The shared cache-only renderer is
`figures/paper_ready/paper_figures.m`; captions are in `FIGURE_LEGENDS.md`.
The reopened-object receipt is `artifacts/manifests/paper_ready/FIGURES.json`.
Final review must also verify native Notion images, source arrays, units,
axes, legends and uncertainty, and record the verified Git release SHA.

Required raw evidence remains under the ignored paper-specific cache rather
than being duplicated into Git. The numerical plan and source identities
remain version-controlled. Accepted Stage-1/2/3 files are never regenerated
by this manuscript renderer.
