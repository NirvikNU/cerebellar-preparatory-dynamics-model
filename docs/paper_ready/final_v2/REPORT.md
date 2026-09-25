# Final parsimonious paper model v2 — numerical report

Numerical assays audited. Figure visual inspection, preservation, Notion publication and release are separate gates; see completion receipt.

## Frozen shared structural calibration

Eta=0, lambda=10, V1, primary noise0.10/0.10. One shared alpha=0.5, beta_norm=1.25 for all ten networks; grid index24.

All36 candidates scored in all10 networks. Only network-median paired DeltaPR and alignment deficit entered loss; no QC/behavior/convergence/R2 screen. The selected receipt predates downstream simulation.

| Calibration quantity | Model median | Empirical target |
|---|---:|---:|
| Block-Intact PR | 3.23576041862 | 2.6453333944 |
| Expected-observed (pp) | 16.4092852081 | 16.802184 |

Loss=0.050363119828606938. Exact ties were checked; no network-specific fit.

Only the two paired effects were calibrated, not absolute condition means. The unique winner is a minimum over this fixed grid, not a continuous optimum. Beta is at the upper tested boundary; the grid was not expanded. An independent PowerShell CSV/order-statistics audit agrees with the frozen selection.

All 360 candidate/network geometries were independently checked by neuron-column covariance/eigendecomposition and the separate QR null. Maximum native-transition discrepancy=2.2204460492503131e-16; maximum geometry/null discrepancy=2.5579538487363607e-13. Intact-derived minimum-95% K spans 6 to 7.

## Primary conditions and functional components

| Policy | PR | Alignment deficit (pp) | Corrected C | PCA75-ridge R2 |
|---|---:|---:|---:|---:|
| Intact | 3.4646664 +/- 0.081004623 | -54.679253 +/- 0.62951136 | -1.849602 +/- 0.047216159 | 0.92424551 +/- 0.0065456127 |
| State setting only | 3.2635002 +/- 0.093828637 | -39.25485 +/- 1.6934083 | -2.3418139 +/- 0.058403584 | 0.91423166 +/- 0.0064567636 |
| Prospective feedback only | 5.6884049 +/- 0.10170497 | 27.622054 +/- 1.0204294 | -1.8665994 +/- 0.038130442 | 0.96464004 +/- 0.0020245412 |
| Block | 6.6401483 +/- 0.088367783 | 16.409285 +/- 1.3633781 | -2.2533421 +/- 0.048869226 | 0.84380699 +/- 0.015846577 |

Network n=10, median +/- bootstrap SE; no component selected from these descriptive outcomes. Calibration agreement is not independent validation.

## Noise effects, all prespecified points

| s_init | s_temporal | Intact R2 | Block R2 | Relative Block R2 loss (%) | Intact C | Block C | Block-Intact C |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 0.05 | 0.10 | 0.93159069 +/- 0.0045987125 | 0.84349609 +/- 0.011647387 | 9.9172769 +/- 1.5194395 | -4.4911711 +/- 0.083681638 | -5.2169317 +/- 0.087707953 | -0.75666 +/- 0.03113089 |
| 0.10 | 0.10 | 0.92424551 +/- 0.0065456127 | 0.84380699 +/- 0.015846577 | 9.2715847 +/- 1.7838514 | -1.849602 +/- 0.047216159 | -2.2533421 +/- 0.048869226 | -0.38801534 +/- 0.016744908 |
| 0.20 | 0.10 | 0.90829781 +/- 0.0058576601 | 0.81948186 +/- 0.014471416 | 9.9649309 +/- 1.6395535 | -0.65730141 +/- 0.02993248 | -0.88519325 +/- 0.03296993 | -0.22121733 +/- 0.0088556448 |
| 0.10 | 0.05 | 0.98935507 +/- 0.0020029888 | 0.92574638 +/- 0.021639715 | 6.4616566 +/- 2.1805159 | -0.81166533 +/- 0.037686204 | -1.0965257 +/- 0.049108823 | -0.27934589 +/- 0.01462575 |
| 0.10 | 0.20 | 0.73596134 +/- 0.0038888931 | 0.63334795 +/- 0.012149235 | 14.124731 +/- 1.4731548 | -3.9825668 +/- 0.05883706 | -4.4765234 +/- 0.05135592 | -0.50399289 +/- 0.029032965 |

No noise point selected. No new testing family for these sensitivity curves. Undefined relative losses=0/50; undefined convergence trial counts=0. Distances/ratios/K/capture are retained in trial_metrics.csv.

The corrected baseline is one stochastic pre-cue state, not the historical post-cue window. It changes the estimand; historical C results remain intact. Changing initial noise changes d_precue, so C is not alone evidence of stability or mediation.

## Behavior and movement QC

Speed-matched hand-position dispersion; 6/10 networks met the prespecified matching criterion.
Main E uses networks 1, 2, 3, 6, 7, 10. Median +/- bootstrap SE: Intact
0.5526716063 +/- 0.0273189850 cm; Block 2.6840010553 +/- 0.3316094662 cm.
Wilcoxon signed-rank, n=6, p=0.03125. No matching criterion or other panel changed.

Separate **unmatched all-10-network robustness control**: Intact
0.5381809675 +/- 0.0181790413 cm; Block 3.0147396369 +/- 0.2033706497 cm.
This is descriptive, not the primary assay. Full precision, independent checks
and source paths: [DISPERSION_CONTROL.md](DISPERSION_CONTROL.md).

- dispersion: two-sided Wilcoxon signed-rank; paired network n=6; exact p=0.03125; Anderson-Darling p=0.021789232569363721.
- peakSpeed: two-sided paired t; paired network n=10; exact p=1.464190648721461e-08; Anderson-Darling p=0.63262125699845573.

| Network | Matched pairs by target | Eligible targets | Intact dispersion (cm) | Block dispersion (cm) |
|---:|---|---:|---:|---:|
| 1 | 8 1 2 11 17 5 6 5 | 6 | 0.6092247528 | 4.669916592 |
| 2 | 11 3 4 7 14 8 6 0 | 5 | 0.6139734784 | 2.724776483 |
| 3 | 19 2 14 10 8 4 5 11 | 6 | 0.5515867137 | 2.371326119 |
| 4 | 5 2 10 6 4 19 3 4 | 4 | NaN | NaN |
| 5 | 3 2 6 9 2 12 5 2 | 4 | NaN | NaN |
| 6 | 11 8 1 7 6 8 10 14 | 7 | 0.5064407311 | 2.643225628 |
| 7 | 16 2 5 14 7 2 7 13 | 6 | 0.5133424448 | 3.120547457 |
| 8 | 7 3 2 1 7 11 3 6 | 4 | NaN | NaN |
| 9 | 7 9 8 4 0 5 0 3 | 4 | NaN | NaN |
| 10 | 3 11 6 6 10 5 7 7 | 7 | 0.553756499 | 2.596150485 |

| Noise pair | Condition | Near-zero / missing / boundary / multi-peak trials | Endpoint RMS median (cm) | Separation/scatter median |
|---|---|---|---:|---:|
| 0.05/0.10 | Intact | 0 / 0 / 0 / 8 | 2.637695405 | 5.564122859 |
| 0.05/0.10 | Block | 0 / 0 / 248 / 741 | 5.989773816 | 1.572159022 |
| 0.10/0.10 | Intact | 0 / 0 / 0 / 9 | 2.637672366 | 5.560631316 |
| 0.10/0.10 | Block | 0 / 0 / 260 / 728 | 6.162895155 | 1.542615022 |
| 0.20/0.10 | Intact | 0 / 0 / 0 / 10 | 2.646677222 | 5.525774246 |
| 0.20/0.10 | Block | 0 / 0 / 279 / 713 | 6.810463437 | 1.425378889 |
| 0.10/0.05 | Intact | 0 / 0 / 0 / 0 | 1.321150622 | 10.91360392 |
| 0.10/0.05 | Block | 0 / 0 / 188 / 793 | 3.445053428 | 2.756127358 |
| 0.10/0.20 | Intact | 0 / 0 / 4 / 128 | 5.25774982 | 2.917837728 |
| 0.10/0.20 | Block | 0 / 0 / 389 / 669 | 11.61407313 | 0.8654430459 |

All flagged trials retained. Counts are nested within ten networks, not independent sample sizes. Finite prediction does not establish normal movements. Target-circle truncation is only for display.

## Readiness provenance

Eta0 readiness medians over networks for lambda [.1,.2,.5,1,2,5,10,100]: [10 14 22.5 33.25 49.5 83 109.5 271.25] ms. Lambda10 remains frozen regardless of this diagnostic.

## Independent validation scope

120 cases; 50 prior cases reused without replacing fits. Independent new observed fits=70, matched fits=100, bounded shuffle1/network1 refits=7; all saved shuffle controls checked.

| Check | Maximum absolute discrepancy |
|---|---:|
| drawError | 0 |
| transitionError | 0 |
| convergenceError | 3.2684965844964609e-13 |
| geometryError | 3.2684965844964609e-13 |
| featureError | 3.0198066269804258e-14 |
| pcaError | 2.6556534749033744e-13 |
| predictionError | 1.6520118606422329e-13 |
| lossError | 2.9103830456733704e-11 |
| r2Error | 1.1102230246251565e-15 |
| movementError | 3.5527136788005009e-15 |
| bootstrapError | 1.5543122344752192e-14 |
| shuffleError | 1.5543122344752192e-15 |

Native-transition/noise reconstruction covers the three predeclared saved audit steps per trial; stream implementation/seeds are frozen. No additional full-trajectory replay or full independent100-shuffle refit is claimed.

Canonical compact sources: results/paper_ready/final_v2/; ignored raw evidence: results/paper_ready/cache/final_v2/ plus validated reused caches. Full legends and panel map are adjacent. No RRR, new model family, noise fitting or downstream geometry selection.
