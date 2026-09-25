# Final-v2 source-data dictionary

All compact paths below are under `results/paper_ready/final_v2/`.
`figure_sources.mat` is the original numerical figure master; the authorized
Main E six-network summary is separately held in `dispersion_resolution.mat`.
Both masters are required for the final rendering sequence; neither original
ten-network arrays nor missingness were overwritten. Their fields
are mapped in [PANEL_SOURCES.md](PANEL_SOURCES.md). CSVs written by `v2_csv`
use 17 significant digits. NaN is an undefined result, never zero.

## Common indices and units

- `network`: 1–10, the independent statistical unit.
- `target`: 1–8, frozen angular order −90, −45, 0, 45, 90, 135, 180, 225 degrees.
- `trial`: 1–30 within target. Global trial indices are `(target-1)*30+trial`.
- `policy`: 1 Intact; 2 state-setting only; 3 prospective-feedback only;
  4 full Block. Only primary noise has all four policies.
- Five unique `(s_init,s_temporal)` pairs: (.05,.10), (.10,.10), (.20,.10),
  (.10,.05), (.10,.20). The primary anchor is not duplicated as evidence.
- Positions are metres except explicitly named centimetre columns; speed is
  m/s; event times are integer milliseconds from GO. Rates are source units,
  not Hz. Alignment is in percent and deficits in percentage points.

## Tables and masters

| File | Meaning |
|---|---|
| `calibration_map_fullprecision.csv` | 360 network/candidate rows: paired PR effects, Control-to-Block observed and null alignment, Control-derived K, capture, denominator |
| `calibration_ensemble_fullprecision.csv` | 36 shared points, network medians and two-target relative-squared loss |
| `geometry_selection.json` | Immutable pre-downstream selection receipt, target constants, unique global winner, parameters and UTC |
| `geometry.mat` | Exact calibration arrays and independent numerical errors |
| `network_metrics.csv` | 120 evaluated cases, geometry, corrected C, PCA75-ridge R², matched-PC/shuffle summaries, movement/event QC |
| `trial_metrics.csv` | 28,800 nested trial rows, raw pre-cue/pre-go distances, ratios/C, convergence K/capture/guard/fold, own MO/peak events, QC flags and absolute peak hand positions |
| `paired_noise_effects.csv` | 50 within-network Intact/Block pairs: ΔC, ΔR², relative R² loss and its definedness |
| `behavior_matching.csv` | Exact retained global trial-index pairs within network/target, using the frozen empirical greedy 5% rule |
| `behavior_statistics.json` | Paired differences, eligible network mask/n, Anderson–Darling decision and the selected two-sided behavioral test/p |
| `dispersion_resolution.mat` / `.json` | Authorized six-network Panel E median/SE, exact eligibility, subset bootstrap, original paired test and unmatched all-ten-network robustness summary |
| `dispersion_matched_subset.csv` / `dispersion_summary.csv` | Final Panel E six network values and both assays' medians/SE in cm |
| `dispersion_unmatched_all10.csv` / `dispersion_unmatched_targets.csv` | Separate descriptive all-ten-network unmatched control; not the primary speed-matched assay |
| `shuffle_controls.csv` | Each of 100 correspondence shuffles per evaluable case, its R² and selected ridge-penalty indices |
| `empirical_targets.csv` | Original empirical Control PR, Block PR, observed alignment and expected alignment, with source resample SD |
| `MainAB_controller_effort.csv` | 80 unchanged historical Stage-2 network/lambda rows, explicitly separate from final-v2 Control95 calibration |
| `MainDF_network1_untruncated.csv` | All 288,000 network-1 Intact/Block arm samples, untruncated displacements and unsmoothed speeds |
| `readiness.mat` / `readiness.json` | All 640 target/network/lambda readiness values and complete native-step Q-error curves; no lambda reselection |
| `readiness_bounds.csv` | Bounded provenance sweep's controller gain and achieved rate/state/input maxima |
| `summary.mat` / `summary.json` | Network metrics, all retained QC extrema, behavior matching/coverage and bootstrap summaries; MAT also stores the frozen bootstrap indices |

`geometry_network.csv` and `geometry_ensemble.csv` are the initial selection-gate
exports. The explicitly named `*_fullprecision.csv` files and MAT master are
the canonical numerical sources; do not infer precision from display rounding.

`network_metrics.K95` is the Intact/control-derived geometry K. In contrast,
`trial_metrics.K95` is the same-target reference-only convergence PCA K for that
trial's fold. These are intentionally different estimands. Convergence distances
are Euclidean distances in normalized-rate PC coordinates. `d_precue` uses one
pre-controller sample only; `d_prego` uses GO−100:10:0 window means.

Peak positions in `trial_metrics` are absolute arm coordinates in metres.
`MainDF` subtracts the fixed home hand position and converts to centimetres for
display. Target-entry truncation exists only in plotted objects, never in either
source table. Condition codes in `MainDF` are 1 Intact / 2 Block (not policy codes).

Ridge indices refer to the frozen 25 penalties `logspace(-8,4,25)`.
The three outer-fold selections produce held-out R²; `fullPenaltyIndex` records
the separate full-data coefficient fit and is not substituted for held-out R².
Matched-PC counts are the paired minimum within each epoch. Shuffle summaries
are medians of 100 fixed correspondences, not extra biological replicates.

## Validation and provenance

Generated MAT status strings describe the generation phase. Subsequent
`audit.json`, `output_audit.json`, `control_tables.json` and the manifest-side
visual/preservation/release receipts establish actual completion; do not
reinterpret an immutable generation-phase label as a current execution status.
The full selection receipt predates downstream simulations. Its
`downstreamEvaluated=false` field describes that historical gate, not a claim
that the released downstream outputs are missing.

Detailed trial-state arrays, PCA bases/fits and saved-step replay evidence remain
required ignored inputs under `results/paper_ready/cache/final_v2/`, with exact
Intact reuse from the earlier eta/noise caches. Public compact data permit figure
inspection/reproduction, but are not a substitute for these inputs in a full
independent scientific replay. Existing historical results and figures are not
modified or numerically relabeled as final-v2 outputs.

Intact trajectory reuse is justified by the reduced eta=0 field
`f(x)-f(xstar)-L*(x-xstar)`, which cancels xB. Reused historical raw records
remain byte-identical and retain their original geometry metadata. In particular,
their term-wise base/b input maxima, counterfactual component maxima and
distance-to-old-xB fields are historical provenance, not final-v2 component
amplitude/distance measurements. Final-v2 assays use the geometry-independent
states/rates, initial/GO states, noise/equation evidence, total input and frozen
movement/features/fits. The newly replayed Block/component cases use the frozen
v2 xB explicitly. No historical component diagnostic is relabeled as a newly
measured final-v2 result.
