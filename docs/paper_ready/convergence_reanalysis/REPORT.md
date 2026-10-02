# Convergence reanalysis — scientific review pending

Candidate only; release aa63c7914fadf6f7c96c634617e797eac3772246 is unchanged. No movement simulation, prediction fit or geometry selection.

## Genuine spontaneous baseline

GO-1000:-500 intrinsic dynamics only plus temporal noise; no target-specific input, reset or cue perturbation. Existing initial/cue-GO draws retained; added pre-cue mt19937ar seeds410000000+10000*network+slot. Native0.2ms, saved1ms, analysis10ms.

PCA uses GO-600:10:0, reference-only20 trials; held-out10 same-target trials in each of three frozen folds. Minimum95% centered normalized unsmoothed-rate variance. Baseline mean GO-600:10:-500, pre-go mean GO-100:10:0. C=1-d_prego/d_precue, unchanged guard/aggregation. n=10 networks, median+/-10,000 whole-network bootstrap SE. No new inferential test family.

## Convergence effects

| Initial | Temporal | Intact C | Block C | Block-Intact C |
|---:|---:|---:|---:|---:|
| 0.05 | 0.10 | -0.1118667962 +/- 0.003031251939 | -0.2120968113 +/- 0.004824018156 | -0.09738669438 +/- 0.003159594444 |
| 0.10 | 0.10 | -0.0691985037 +/- 0.00309914321 | -0.1624755537 +/- 0.005927043415 | -0.09299138467 +/- 0.002552792815 |
| 0.20 | 0.10 | 0.05793794839 +/- 0.003618981041 | -0.02165137596 +/- 0.005831948981 | -0.08036425868 +/- 0.002070540735 |
| 0.10 | 0.05 | 0.04755255951 +/- 0.003154372725 | -0.03657058453 +/- 0.006774280283 | -0.08763347861 +/- 0.003125765931 |
| 0.10 | 0.20 | -0.06830624663 +/- 0.005602248114 | -0.1382291803 +/- 0.006631535806 | -0.0722458465 +/- 0.001964675146 |

## Components at primary noise

| Policy | Median C | Bootstrap SE |
|---|---:|---:|
| Intact (b+L) | -0.0691985036957 | 0.00309914320965 |
| -L (b only) | -0.179525818794 | 0.00744723775667 |
| -b (L only) | -0.0561924567356 | 0.00310785795255 |
| Block (-b,-L) | -0.162475553691 | 0.0059270434148 |

## Spontaneous settling QC

Pooled future-trial slots, RMS per neuron in source-state units. First0:100ms, preceding300:400ms, last400:500ms (inclusive1-ms samples). Values below are medians across networks; full network values/trajectories retained. No stationarity threshold or selection is introduced.

| Initial | Temporal | Mean drift total | First/last mean shift | Late mean shift / last dispersion | First dispersion | Last dispersion | Last / first | Last / preceding |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0.05 | 0.10 | 0.01548373195 | 0.01541991143 | 0.05222801072 | 0.08593898617 | 0.223766796 | 2.605472476 | 1.098611883 |
| 0.10 | 0.10 | 0.0168770313 | 0.01644630995 | 0.05163016259 | 0.1175602606 | 0.2334250085 | 1.98781273 | 1.077462454 |
| 0.20 | 0.10 | 0.02166971462 | 0.02026801359 | 0.05135662494 | 0.1973120172 | 0.268548689 | 1.360813442 | 1.022439016 |
| 0.10 | 0.05 | 0.01084382209 | 0.01014182263 | 0.05146782752 | 0.09865643027 | 0.1344298903 | 1.362385068 | 1.02271601 |
| 0.10 | 0.20 | 0.03131978005 | 0.03020842439 | 0.05155904557 | 0.1718779316 | 0.4425048096 | 2.578456809 | 1.092620613 |

Spontaneous finite/bounded: 50/50 and 50/50; preparation finite/bounded: 120/120 and 120/120. Undefined C trials: 0/28800. No trial or network removed from the source tables.

The fixed 500-ms spontaneous interval is not assumed to be a stationary sample. Interpret mean drift and last/preceding dispersion ratios explicitly; retain incomplete settling without extending the interval. C compares deviations from two epoch-specific target-matched reference means, not distance to one equilibrium or a causal mediation test.

## Independent numerical audit

All120 cases and50 spontaneous epochs; zero pre-cue policy input and exact cue continuity. Independent covariance/eigen distances compared with production SVD; three native transition checks per epoch, not a second full replay.

- drawError: 0
- transitionError: 0
- cueResetError: 0
- convergenceError: 3.1441516057384433e-13
- qcError: 1.3322676295501878e-15

## Prediction panels reused unchanged

| Initial | Temporal | Main I Intact R2 | Main J relative Block loss (%) |
|---:|---:|---:|---:|
| 0.05 | 0.10 | 0.93159068732 +/- 0.00459871246988 | 9.91727690875 +/- 1.51943945415 |
| 0.10 | 0.10 | 0.924245510013 +/- 0.00654561269359 | 9.27158468717 +/- 1.78385136438 |
| 0.20 | 0.10 | 0.90829781003 +/- 0.00585766007633 | 9.96493087507 +/- 1.63955351226 |
| 0.10 | 0.05 | 0.989355065683 +/- 0.00200298880196 | 6.46165663279 +/- 2.1805158877 |
| 0.10 | 0.20 | 0.735961337081 +/- 0.00388889313751 | 14.1247306053 +/- 1.47315481496 |

Prediction, PR and alignment in Main/ED2 remain the released preparation protocol, not outcomes of the new convergence-only 1000-ms trajectory. They are separate assays. Original MainA-H and every historical figure remain unchanged. Candidates are not a scientific acceptance or release replacement. No commit, push, deletion or main update.

## Scientific-review limitations and completion checks

At primary .10/.10 noise, both Intact and Block have negative median C
(-.0691985037 and -.1624755537); the paired Block-minus-Intact effect is
-.09299138467. Thus neither condition demonstrates positive contraction by
this assay at the primary setting. All four primary component-policy medians
are negative. Intact C changes sign at the high-initial and low-temporal
settings; none of these settings is selected or promoted.

The spontaneous epoch is not convincingly stationary across the entire grid.
Median last/preceding-100-ms dispersion ratios span1.022439016 to1.098611883.
At primary noise the ratio is1.077462454 (7.75% additional late dispersion),
and first-to-last dispersion rises from.1175602606 to.2334250085 source-state
units. Total mean-state drift is.0168770313 RMS per neuron; the late mean shift
is5.16% of last-window dispersion. These are descriptive observations, not
post-hoc pass thresholds. The fixed500-ms interval was not extended.

Interpret negative values and remaining baseline dependence cautiously:
policy-specific reference PCA can yield different projected d_precue from
identical raw spontaneous activity. C compares deviations from two different
epoch-specific reference means; it is not a proof of fixed-equilibrium
stability or of convergence causing prediction differences. The new ED1 is
retained only in the scientific-review section, not promoted to the released
paper-facing figure set.

Independent saved-CSV arithmetic checked all28,800 distance ratios and all120
network aggregations, plus50 paired effects: ratio/pair errors0, aggregation
error1.6653345369377348e-16. All three FIGs were saved/reopened and their PNGs
visually inspected;536 native plotted-source checks passed. Main A-H and the
retained ED2 scientific arrays are unchanged. Code Analyzer passed all12 new
MATLAB files without messages. All3,270 pre-existing files (278,538,166,388
bytes) passed exact SHA256 preservation with no exemptions.
