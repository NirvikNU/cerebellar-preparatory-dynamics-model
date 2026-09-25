# Source table dictionary

All numeric CSV fields use17 significant digits; a separate readback audit checks
source identities. Condition1=Intact,2=full Block. Network1-10 is the independent
unit. Each condition/network/eta/noise case has eight targets and30 trials/target.
The common s_init=s_temporal=.10 pair is stored once per eta/condition/network.

## network_metrics.csv (200 rows)

- `convergence`: released mean C, dimensionless; `pr`: participation ratio.
- `r2`: pooled held-out primary PCA75/ridge R2; negative values remain.
- `shuffle`: within-network median of100 correspondence-shuffled R2 values.
- `matched`: paired matched-PC held-out R2; each epoch uses the smaller paired
  PCA75 count. Full fits/counts are retained in each ignored matched case cache.
- `bias`: mean across targets of trial-mean GO distance to own equilibrium
  divided by trial-mean cue distance to that same equilibrium, dimensionless.
- `dispersion`: mean target RMS Euclidean GO-state spread in raw model-state
  units, around each target's achieved trial mean (not equilibrium bias).
- `mo`, `peakTime`: trial medians, milliseconds after GO; `peakSpeed`: m/s.
- `endpoint`: mean within-target endpoint RMS in millimetres, around each
  target's endpoint centroid, not error relative to the nominal target.
- `separation`: median pairwise target-centroid distance / mean within-target
  endpoint RMS, dimensionless.
- `Control95K`, `observed`, `expected`, `deficit`: Intact-only PC count and
  alignment fractions (multiply by100 for percent/percentage points). The
  identical K sets Block basis width, Intact denominator and frozen null width.
- `prepPC75`, `movePC75`: primary prediction PC counts, distinct from C/geometry.
- `mean_d_cue`, `mean_d_prego`, `mean_ratio`: means across all240 held-out trials
  of the raw normalized-rate projected distances and their trialwise ratio.
- All bounds/maxima and QC counts are retained. Rate maxima are source-rate
  units; state/input maxima are Euclidean norms in their original model units.

## target_metrics.csv (1600 rows)

Raw GO equilibrium bias, cue equilibrium distance, their ratio, GO-state spread,
target-level C and endpoint RMS in **metres** (`endpointRmsM`). These preserve the
denominators and distinguish bias from trial variability.

## trial_metrics.csv (48000 rows)

Trial indices are target-local1-30; fixed folds1-3. `referenceK95`, `capture` and
`captureBefore` describe the target/fold reference-only PCA. Each trial is held
out exactly once. `d_cue` and `d_prego` are Euclidean distances after frozen
per-neuron normalization and unwhitened reference-PC projection of window means.
They are not raw state-space distances or distances to one fixed equilibrium.
`distanceRatio`=d_prego/d_cue; C=1-ratio uses the released numerical denominator
guard. Undefined entries/flags and negative C remain. Movement events/speed and
near-zero, required-window, boundary and multiple-large-peak flags are included.

## Other tables and uncertainty

- `paired_metrics.csv`:100 unique network/eta/noise pairs, Block-minus-Intact
  deltaC/deltaR2 and relative Block loss in percent, computed within network.
  Nonpositive/numerically zero Intact R2 makes only the percentage undefined.
- `shuffle_controls.csv`: all100 shuffles per evaluable case, including selected
  outer/full penalty indices into the unchanged25-value grid.
- `ensemble_summary.csv`: median, bootstrap SE and available network n. Condition0
  identifies paired/alignment metrics rather than either individual policy.
- `summary.mat/json`: original arrays, QC structs, bootstrap summaries; MAT also
  stores the frozen10000 whole-network index rows. The generation status precedes
  independent validation; audit.json/table_audit.json record that later outcome.

No flagged trial is excluded. Safety/bounds or required-window failures make
affected main estimates unevaluable. Raw finite diagnostic evidence remains for
audit; it must not be interpreted as a passed case. The strict released bootstrap
does not silently drop undefined networks; available n is disclosed. Targets,
trials, folds, shuffles and noise levels are not additional independent networks.
