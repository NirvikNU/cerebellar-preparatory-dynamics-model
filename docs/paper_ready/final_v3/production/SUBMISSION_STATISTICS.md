# Prediction statistics

Paired temporal-noise comparisons and trial-shuffled prediction floors for Fig. 6g,h.

## Paired temporal comparisons

Each of eight amplitudes uses ten matched network differences, Control minus Block R², with initial-state noise 0.05. MATLAB composite-normal Anderson–Darling alpha=0.05 did not reject at any level, so all tests are two-sided paired t-tests (df=9). Benjamini–Hochberg correction is one family of exactly eight comparisons. All 240 trials are retained per network/case; trials are not independent inferential units.

| Temporal noise | AD statistic | AD p | t(9) | Raw p | BH q |
|---:|---:|---:|---:|---:|---:|
| 0.050000000000000003 | 0.65685214539456815 | 0.060258273190390135 | 5.421115018565807 | 0.00042122507642767257 | 0.00042122507642767257 |
| 0.10000000000000001 | 0.25939278674816535 | 0.67507621367850956 | 8.6153405486914085 | 1.2187607315315623e-05 | 1.6250143087087499e-05 |
| 0.14999999999999999 | 0.44526441013112894 | 0.23279893976596608 | 8.7627751192334742 | 1.0617647010370626e-05 | 1.6250143087087499e-05 |
| 0.20000000000000001 | 0.56744608142995823 | 0.10731856344129104 | 12.178139376563239 | 6.7909001737168641e-07 | 5.4327201389734912e-06 |
| 0.25 | 0.5091661010814672 | 0.15584587373126998 | 9.9894335210348384 | 3.6098615551968703e-06 | 9.8703539095874681e-06 |
| 0.29999999999999999 | 0.50231566929181426 | 0.1627559315468361 | 9.2725721404319508 | 6.6846088678216952e-06 | 1.336921773564339e-05 |
| 0.34999999999999998 | 0.39204646958531164 | 0.32275806399404372 | 7.6756225266855855 | 3.0762489744618863e-05 | 3.5157131136707269e-05 |
| 0.40000000000000002 | 0.37043514298545155 | 0.36715926124873977 | 9.9594194194183672 | 3.7013827160953008e-06 | 9.8703539095874681e-06 |

Mean of the ten within-network medians over the eight paired differences: **0.087319716383444795 ± 0.0078108922382883073 R²**, mean ± sample SEM. This is separate from the original figure medians ± SE of 10,000 whole-network bootstrap medians, which are retained exactly in `paired/paired_tests.csv` alongside the new tests. Raw differences, normality critical values, CI95 and network medians are preserved under `data/paper_ready/final_v3/submission_statistics_20261021/paired/`.

## Shuffled noise-floor summaries

| Sweep | Mean R² | Between-network SEM | Mean Monte Carlo SE | SEM Monte Carlo SE |
|---|---:|---:|---:|---:|
| Control_initial | -0.011067295611708512 | 8.6949259635277169e-05 | 8.1223704865762401e-05 | 2.3938679930233598e-06 |
| Control_temporal | -0.010469517317725174 | 2.2226884884234247e-05 | 1.9618901485962262e-05 | 6.5954243652843386e-06 |
| Block_temporal | -0.010467687327424858 | 1.5304576137065777e-05 | 1.3767509841951577e-05 | 1.7614566226770334e-06 |

The estimator is median over 2,000 shuffles within case, median across eight levels within network, then mean and sample SEM across ten network medians. The shared Control 0.05/0.05 anchor is computed once: 150 Control plus 80 temporal-Block cases, 230 distinct cases, 460,000 complete nested null fits. Negative R² is retained. Full/half three-decimal rounding and the prespecified four-batch Monte Carlo SE threshold of 0.000125 passed without extension or seed selection.

For network n and shuffle r, MATLAB mt19937ar seed is `352000000+100000*n+r`. A global bijective permutation of all 240 response trials is reused across matched conditions/noise within each network. Within-target shuffling would be a different estimand and is not used. Frozen preparatory/movement features, trial identities, folds and PCA reference arrays are committed in `inputs/`. Every replay reconstructs original PCA75 and unshuffled predictions exactly before testing the null. Three outer and three inner target-matched folds use the original 25 penalties, `logspace(-8,4,25)`, with the original first-minimum tie rule.

All inner losses, selected penalties, permutation identities and direct held-out SSE/SST/R² are retained in `null/`. A sufficient-statistic evaluation of inner loss was checked against unmodified `pf_ridge` on 32 smoke permutations and 16 fixed permutations per case; exact penalty selection and discrepancies below the original 1e-12 numerical gate are required. Every deterministic reproduction compares complete null-result structures exactly, not just rounded summaries.

Important limitation: the frozen condition-specific preprocessing/PCA uses all 240 trials before ridge cross-validation. Ridge coefficient fitting and penalty selection use their training folds. This preserves the established estimator and does not claim fully held-out preprocessing. These tests do not establish monotonic growth of the Block gap, a condition-by-noise interaction, equivalence or causal behavioral mediation.

## Copy-ready manuscript wording

Across the eight temporal-noise levels, Control R² exceeded Block R² in paired comparisons across ten networks (two-sided paired t-tests, all eight Benjamini–Hochberg-adjusted p < 0.001; Anderson–Darling normality checks did not reject at alpha=0.05). For each network, we took the median Control-minus-Block R² difference across the eight levels; the mean ± SEM of these ten network medians was 0.08732 ± 0.00781 R² (0.087 ± 0.008 to three decimals).

Trial-shuffled prediction gave mean ± between-network SEM R² values of −0.0110673 ± 0.0000869 for the Control initial-noise sweep, −0.0104695 ± 0.0000222 for the Control temporal-noise sweep, and −0.0104677 ± 0.0000153 for the Block temporal-noise sweep. Each network value was the median across eight noise levels of the median R² over 2,000 global trial-correspondence shuffles per case. Monte Carlo SEs of the three reported means were 0.0000812, 0.0000196 and 0.0000138, respectively; these are separate from the between-network SEMs.

## Reproduction

From MATLAB R2025b at the repository root, run `addpath('workflows')` followed by `reproduce_submission_statistics` to reproduce all 230 × 2,000 nested null fits, paired comparisons and uncertainty summaries. Statistics and Machine Learning Toolbox is required. Complete original outputs are supplied under `data/paper_ready/final_v3/submission_statistics_20261021/`.

For a numerical audit of the supplied permutation results, copy that folder's `null/` directory to a new output directory and run `reproduce_submission_statistics(outputDirectory,'validate')`. This verifies complete result structures, recomputes the paired statistics and summaries, and checks all source tables and Monte Carlo precision.
