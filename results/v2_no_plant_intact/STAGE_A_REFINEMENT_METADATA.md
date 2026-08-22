# V2 Stage-A deterministic stationarity refinement

- Source checkpoint: absolute update 1,000, preserved in `stage_a_checkpoint_latest.mat`.
- Refinement: 500 additional deterministic updates, absolute updates 1,001–1,500.
- Runtime: 29.498 minutes on NVIDIA RTX 6000 Ada Generation.
- Best checkpoint: update 1,500; validation loss 1.114119649; final training loss 1.152739406.
- Best-model SHA-256: `672ED251C5EF690FF081762AC922341E910319F1A032A2626EF37578F81F6D5B`.
- Original pre-go velocity loss: full pre-go mean squared velocity magnitude normalized by `(0.25 m/s)^2`, weight 100.
- Mask audit: correct per-trial `time < actual go`; no bug or off-by-one error.
- Added behavioral loss: the same normalized velocity energy over each trial's final 150 ms before actual go, weight 50. No neural or subspace target was added.
- Candidate tests: late weight 50 and 100 for 100 updates each from identical update-1,000 optimizer/RNG state; weight 50 selected as the minimum justified strengthening.

## Best-checkpoint behavior

- Mean endpoint error: 0.334135 mm — pass.
- Worst target-averaged endpoint error: 0.540132 mm — pass.
- Terminal speed: 0.00355010 m/s — pass.
- Canonical full pre-go RMS speed: 0.00750161 m/s — fail.
- Canonical final-150-ms RMS speed: 0.01230473 m/s.
- Canonical final-100-ms RMS speed: 0.01443398 m/s.
- Canonical maximum pre-go speed: 0.04028648 m/s.
- Mean hold error/speed: 0.362980 mm / 0.00413798 m/s — pass.
- All eight targets and all finite-state checks passed.
- Delay-grid per-target values are in `stage_a_refinement_pre_go_by_delay_and_target.csv`.

## Descriptive neural diagnostics

- Top-10-PC preparatory-by-movement alignment: 0.792106.
- Top-10-PC movement-by-preparatory alignment: 0.746488.
- Preparatory variance captured by movement PCs: 78.4958%.
- Movement variance captured by preparatory PCs: 72.9008%.
- Preparatory variance in the two-dimensional `Wout` row space: 0.072701%.
- Normalized preparatory output-potent alignment: 0.000894.
- These diagnostics were computed after training and never entered the loss.

## Interpretation boundary

The refinement substantially reduced leakage and retained excellent reaching, but it did not meet the frozen 0.002-m/s pre-go RMS criterion and did not eliminate systematic late acceleration. Validation was still improving at update 1,500, but the authorized 500-update limit was reached. No further training, Stage B noise, lesion, cerebellar removal, or adaptation was run.
