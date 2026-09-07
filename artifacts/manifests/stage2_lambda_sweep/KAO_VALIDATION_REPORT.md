# STAGE2-KAO-ALIGNMENT-VALIDATION-01 — completion audit

## Result and scientific boundary

Observed alignment is 17.2485 ± 2.1608%, expected 47.3525 ± 1.3304% (network median ± bootstrap SE, n=10). The paired observed-minus-expected median is -29.3611 ± 1.9931 percentage points, exact paired p=0.001953125. All ten networks are below their matched null. Minimum Prep-derived K is 3–4, capturing 80.1125–85.7627% Prep variance; K−1 captures only 70.3525–78.9344%.

The result is qualitatively consistent with the low LQR alignment relative to constrained random subspaces in Kao Figure 6C. The published ISN LQR bar is visually near 0.16; our median is 0.1725, but no precise digitized source value or identical published network ensemble was supplied, so this is not an exact numerical replication. The declared model normalization horizon, direct deterministic-rate sampling, different frozen network realizations, and median/bootstrap-SE presentation are explicit limits. The manuscript-matched Prep-to-Move analysis remains the project's primary result (57.0365 ± 1.9452% observed versus 73.3418 ± 0.6532% expected; p=0.001953125). The two analyses use different preprocessing, epochs and K rules and are not interchangeable. No model, λ, window, threshold, null, seed or amplitude was adjusted.

## Network-level values

| Network | K | Prep captured (%) | Observed (%) | Expected (%) | Difference (pp) |
| --- | --- | --- | --- | --- | --- |
| 1 | 4 | 83.0237 | 17.2013 | 48.0528 | -30.8514 |
| 2 | 4 | 83.7042 | 24.5080 | 49.2574 | -24.7494 |
| 3 | 4 | 83.8266 | 21.2200 | 49.0907 | -27.8707 |
| 4 | 3 | 81.2668 | 24.5469 | 44.8749 | -20.3280 |
| 5 | 4 | 85.7627 | 15.2332 | 46.6475 | -31.4143 |
| 6 | 4 | 84.1698 | 22.8238 | 49.9743 | -27.1505 |
| 7 | 4 | 85.6874 | 13.3335 | 46.6522 | -33.3187 |
| 8 | 3 | 80.1125 | 16.7186 | 41.4488 | -24.7302 |
| 9 | 4 | 83.3873 | 17.2957 | 49.1513 | -31.8556 |
| 10 | 3 | 82.2657 | 10.4336 | 41.6480 | -31.2144 |

## Methods and independent validation

The predeclared KAO_VALIDATION_PLAN.md records source mapping, the Eq. 57
prose/equation direction discrepancy, and every model-specific choice.
No archived Stage-2 material was read. No model simulations or existing
scientific analyses were rerun. Both 31-sample epochs are present in all
80 network-target references. Kao MO=GO+100 ms, not detected kinematic MO.

Explicit neuron/target-loop normalization agrees exactly; target centering
error <=1.111e-16. Neuron-index sentinel passes. Independent SVD confirms
minimal K>=80%; captured variance error <=6.662e-16. Direct projection/trace
AI discrepancy <=3.609e-16. Independent QR/direct-activity checks of 20
random draws per network agree with the Elsayed sampler <=7.772e-16.
Explicit 10,000-resample marginal and paired bootstrap SE discrepancy is
zero; independent enumeration reproduces the exact paired p=2/1024.

10,000 null draws were fixed before calculation, not adjusted. Per-network
Monte Carlo SE is 0.09747–0.12134 percentage points; first/second-half mean
differences are <=0.54568 pp, much smaller than the observed paired deficits
(20.3280–33.3187 pp). Null uncertainty is not network uncertainty.

All 132 Stage-1 protected files, ten cache hashes, and all 29 prior completed
manifest files match. Existing five Stage-2 figure pairs and numerical
outputs remain unchanged. Existing staged code/documentation was not edited
or reconstructed; the prior stop receipt is preserved for the combined
checkpoint. Three new MATLAB files pass Code Analyzer with zero issues.
The FIG was reopened and PNG inspected; a clipped title required one
presentation-only re-render from the saved new analysis, with no metric rerun.

## Added outputs

- run_stage_2_kao_validation.m (bounded additive runner; overwrite guard).
- analysis/stage_2/analyze_stage2_kao_validation.m.
- figures/stage_2/create_stage2_kao_figure.m.
- results/stage_2/current/kao_alignment_validation/: analysis.mat,
  network_metrics.csv, summary.json, validation.json.
- plots/stage_2/{fig,png}/result_4_kao_prep_move_alignment.{fig,png}.
- This report, KAO_VALIDATION_PLAN.md and final image/preservation receipts.

Active Notion parent/specification/summary/Results/Diagnostics/handoffs are
cleaned to current scientific narrative; all prior Agent Log entries are
retained. Existing five native Notion image upload identities are preserved;
Figure 4 is newly uploaded and captioned after the primary Figure 3.

Checkpoint receipt is recorded in Agent Log/Handoff/START HERE only after a
normal combined commit/push, triple-SHA equality and clean-status verification.
This report does not pre-claim push success. Stop for scientific review;
Stage 2 is not scientifically accepted and no later model is authorized.
