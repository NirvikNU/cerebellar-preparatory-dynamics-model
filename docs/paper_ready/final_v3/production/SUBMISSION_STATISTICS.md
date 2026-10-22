# Submission statistical supplement — 21 October 2026 authorization

This additive supplement preserves every original scientific model result, bootstrap draw, source table and publication FIG/PNG from base commit `7977e16de7c406210b6df7dd44d8e457670858d2`. Fig6g remains the Control initial/temporal comparison; Fig6h remains absolute Control/Block temporal R². The figures and original four Friedman omnibus tests are unchanged. The repository ED7a–c assets correspond to manuscript-v13 Extended Data Fig.5a–c; no source filenames were renamed. Google Docs were not edited.

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

## Reproduction from this repository only

MATLAB R2025b Update 1 and Statistics and Machine Learning Toolbox are required for the paired normality/tests. No ignored raw cache, historical checkout or remote attachment is an input. Run from the repository root into new output folders:

```matlab
restoredefaultpath
addpath('workflows')
validate_publication(fullfile(pwd,'generated','submission_publication'))
addpath('workflows')
validate_submission_graphics(fullfile(pwd,'generated','submission_publication'), ...
    fullfile(pwd,'generated','submission_raster.json'))
addpath('workflows')
reproduce_submission_statistics(fullfile(pwd,'generated','submission_statistics'))
```

The publication workflow genuinely generates 11 panels/two assemblies, verifies 26 byte-exact original source tables and 261 native objects, retains the hand-drawn Fig6c and runs the real 480-trial primary model check. The statistical workflow verifies committed-source hashes, reproduces all 230×2,000 null fits and the paired tests, compares full numerical objects and CSV/JSON tables exactly, and writes its loaded-code/toolbox/Code Analyzer receipts. Parallel MATLAB processes can use `phase='compute'` with disjoint network IDs, followed by one `phase='validate'`; no output may be overwritten. Original calculation outputs are immutable references, not replaced by replay output.

Source manifest: `data/paper_ready/final_v3/submission_statistics_20261021/source_manifest.json`. This includes source code, inputs, full null/paired/summary evidence and protected original sources. The source manifest itself is secured by Git. `validation/` preserves independent initial Python audits. Required post-push execution receipts are recorded in the dated Notion Agent Log, because adding those generated receipts to the tested commit would change its SHA.

## Historical exact-image qualification — superseded by the approved consolidated rule

Independent repeated rendering found only edge-coverage/compositing variation with exact native scientific content. On 22 October the user approved proposal SHA256 `951BADEF0C76E42C56AA19830E3E828C2872A4D1D448E0539E4DCFB3B215EFBC`. `raster_acceptance.json` permits exactly two complete decoded images for Fig6f, eight for ED7c and eight for the ED7 assembly. Dimensions and whole-image RGBA SHA256 must match the finite list. Every other panel/assembly has one exact reference hash. No image-wide tolerance, automatic extension, crop/resize or original-master overwrite is allowed. Any unobserved variant stops release. Native scientific/layout/label/style checks and source hashes remain strict. Assembly textures must exactly equal their corresponding validated panel PNGs; all other assembly content remains exact. Existing earlier master-size qualifications are unchanged.

The PNG file bytes and decoded pixel identities are distinct provenance: metadata-distinct PNG files are not assumed to be byte-identical duplicates. The original source masters remain untouched.

## Current consolidated graphical policy — approved 22 October 2026

The active validator is `workflows/validate_submission_graphics.m`. It implements the original, unchanged proposal SHA256 `98B575FDC9E76E7FE294941B1A112B0DE535127CDD269FAD401EE62476AF08A8`, with the user approval recorded separately. The old exact-image validator and proposal are historical provenance, not the current gate.

All 13 outputs require exact dimensions and exact decoded RGBA pixels outside the individually listed edge sites. Each approved site admits only explicitly enumerated complete RGBA tuples; descriptive minima/maxima do not define a tolerance. There are 24 panel sites and 18 assembly sites. No automatic growth, global tolerance, interpolation, registration, crop or resize is permitted. Unknown sites or colors stop release. Every scientific array and complete accessible native-property graph remains exact, including labels, axes, styles, ordering and layout. Composite image textures must equal their own validated panel PNGs exactly before comparing the remaining assembly content. The static schematic's image data remain exact.

The versioned `consolidated_graphics/` package contains the exact approved policy, approval receipt, byte-identical reference PNGs and persisted canonical native graphs. The validator checks the pinned original Git blobs, all package-source SHA256 hashes, exact MATLAB R2025b Update 1 / NVIDIA Quadro RTX 8000 ANGLE WebGL renderer identity, 96 screen DPI, smoothing, and existing 160-DPI export settings. It exports through a separate native-readback instance, preserves each canonical FIG's bytes, and revalidates native content after export. In-memory negative controls reject changes outside sites, dimensions, alpha and unlisted colors. Bounded evidence does not guarantee all future renderer states.

For byte-exact source checks on Windows, create the independent clone with `git -c core.autocrlf=false clone <GitHub URL> <new-folder>`; this invocation does not change the original repository's Git settings. Every exported source must match its committed blob, while the original Windows working-tree hashes are verified independently.
