# STAGE2-LAMBDA-SWEEP-01-R2 — corrected neural geometry

**Computed and validated; scientific review pending.**

Starting checkpoint: `4938fe927b59a04322f018d5e8742d9047213c02`.
The bounded Git preflight found a clean worktree/index, no packed-refs lock,
the expected branch/upstream, and local/tracking/direct-remote equality.
Hidden, ignored and untracked files were inspected and preserved.

R2 revises only Results Figure 3 and Diagnostic Figures 1–2, their derived
outputs, and corresponding documentation. **No controller, movement or
perturbation simulation was rerun.** The ten original caches, controller,
simulation configuration, Results Figures 1–2 and Stage-1 assets are unchanged.

## Methods and indexing

The pre-analysis [R2_PLAN.md](R2_PLAN.md) and
`config/stage_2_geometry_config.m` define the executable contract.

- Cached rates: time × neuron × target × λ, dimensions 1099 × 200 × 8 × 8,
  GO −500:598 ms. Cue occurs at GO −500 ms.
- Cached hand state: time × [x, dx, y, dy] × target, dimensions 600 × 4 × 8,
  GO 0:599 ms. Speed is hypot(dx,dy) in m/s. MO is the first saved 1-ms sample
  reaching 20% of that trajectory's peak, with every prior sample below.
  No interpolation, smoothing, pooled peak or GO=MO assumption is used.
- Reference normalization concatenates GO −500:10:0 and each target's
  kinematic-MO −50:10:+450 at λ=0.1: 102 samples per target, 816 observations
  per neuron. Overlap is retained.
- Permute time × neuron × target to time × target × neuron, then reshape to
  (time × targets) × neurons. A neuron-coded sentinel exactly matches explicit
  per-neuron loops: every output column contains one neuron.
- Use the actual sample SD before target centering, with no source-unit floor.
  SD must exceed 100×eps(max(1, maximum absolute reference-neuron activity)).
  This is a rejection check, never a replacement scale. No neuron is dropped.
  Apply the identical reference SD vector to every λ.
- Assemble target-specific aligned windows first, normalize, then remove the
  across-target mean at each relative time within each condition/epoch.
- Diagnostics use GO −100:10:0 ms (88 observations).
- Results Figure 3 uses λ=0.1 only: prep cue +150:10:+450 ms
  (GO −350:10:−50; 248 observations), and move kinematic-MO −50:10:+350 ms
  (328 observations).
- Each alignment pair uses K=max(K1,K2), where each minimum Ki captures
  strictly >95% variance, not ≥95%. Reference covariance is projected onto
  comparison top-K PCs and divided by its own top-K captured variance.
- The null uses the same aligned, normalized, target-centered full-reference
  covariance. Its square root biases unit-column-normalized Gaussian matrices,
  followed by orthonormalization. Use 1,000 draws with the comparison's common
  K and denominator, seed 20260908+network index. Equal K reuses the seeded
  sequence; different K or prep epochs receive their appropriate projection.
- Networks are independent, n=10. The original 10,000 whole-network bootstrap
  index rows (seed 20260909) are reused exactly. SE is the sample SD of bootstrap
  medians. Paired effects have separately bootstrapped within-network differences.
  Exact tests enumerate all 1,024 signs, using the original absolute-mean
  statistic and tie tolerance. PR and alignment each have a separate seven-test
  BH family. Slopes against log10(λ) and Prep-to-Move are separate predeclared
  tests. The original motor-error family is not recomputed.

## Cache, onset and SD prerequisites

All ten cache SHA-256 hashes match the original committed manifest.
All 640 MO detections pass: **47–65 ms after GO**. All requested windows exist;
the latest requested sample is GO +515 ms, within the cache ending at +598 ms.

All 2,000 reference neuron SDs are finite/nondegenerate:
**0.17448332975921999–0.63671775487194227 source-rate units**.
There are zero rejected neurons. Complete SDs, onset/peak-speed values and
window bounds are saved in `neural_geometry_r2/cache_preflight.json`.

## Corrected ensemble results

**Neither proposed λ-sweep neural phenotype is reproduced under R2.**
Preparatory PR decreases rather than increases. Control-to-λ alignment declines
but remains above its covariance-matched null at every tested λ. Separately,
reference Prep-to-Move alignment is below-null under the corrected cue/MO epochs.

All values are network median ± bootstrap SE. Alignment is percent; deficit is
expected−observed in percentage points. Paired medians need not equal differences
between the marginal medians.

| λ | Prep PR ± SE | Observed AI (%) ± SE | Expected AI (%) ± SE | Deficit (pp) ± SE |
| --- | --- | --- | --- | --- |
| 0.1 | 3.579551 ± 0.084955 | 100.000000 ± 0.000000 | 47.354088 ± 0.955746 | -52.645912 ± 0.955746 |
| 0.2 | 3.580518 ± 0.088657 | 99.799509 ± 0.030418 | 47.354088 ± 0.955746 | -52.445169 ± 0.960033 |
| 0.5 | 3.578497 ± 0.092804 | 98.822264 ± 0.198557 | 47.354088 ± 0.955746 | -51.394481 ± 0.918816 |
| 1 | 3.566785 ± 0.095754 | 97.204533 ± 0.452509 | 47.986964 ± 1.081164 | -49.195029 ± 0.745811 |
| 2 | 3.530476 ± 0.089143 | 94.555813 ± 0.810858 | 47.986964 ± 1.081164 | -46.568849 ± 0.522265 |
| 5 | 3.419692 ± 0.088470 | 89.680797 ± 1.291237 | 49.000928 ± 1.270308 | -41.707336 ± 1.288671 |
| 10 | 3.350841 ± 0.099400 | 85.368661 ± 1.530827 | 49.000928 ± 1.270308 | -37.180097 ± 1.371271 |
| 100 | 3.343101 ± 0.070678 | 72.265205 ± 1.685652 | 50.522087 ± 0.725913 | -23.246963 ± 2.100143 |


### Slopes and reference Prep-to-Move

- PR slope: **−0.059626153736232874 ± 0.012036639086301528 PR/decade**;
  exact p=**0.00390625**. Nine slopes are negative, one positive.
- Deficit slope: **+10.456683678489297 ± 0.7072164932560044 pp/decade**;
  exact p=**0.001953125**. All ten slopes are positive; all deficits stay negative.
- Prep-to-Move observed: **57.03647186079969 ± 1.9452472665698422%**.
- Prep-to-Move expected: **73.34175274076227 ± 0.6532428262759574%**.
- Paired observed−expected: **−15.945532169868354 ± 1.2662255381063267 pp**;
  exact p=**0.001953125**. All ten networks are below-null. This is separation
  relative to the matched null, not literal orthogonality or zero shared variance.

### All revised planned paired tests

PR effects use PR units; alignment effects below use fractions (multiply by 100
for percentage points). The original motor-error family remains unchanged.

| Family | λ | Median paired difference ± SE | Exact p | BH q |
| --- | --- | --- | --- | --- |
| Prep PR: lambda-reference | 0.2 | -0.000759398 ± 0.003097094 | 0.51171875 | 0.51171875 |
| Prep PR: lambda-reference | 0.5 | -0.003065258 ± 0.008096857 | 0.234375 | 0.2734375 |
| Prep PR: lambda-reference | 1 | -0.021262669 ± 0.017396149 | 0.12109375 | 0.16953125 |
| Prep PR: lambda-reference | 2 | -0.048796435 ± 0.027330716 | 0.05859375 | 0.1025390625 |
| Prep PR: lambda-reference | 5 | -0.072099674 ± 0.045648015 | 0.021484375 | 0.050130208333333336 |
| Prep PR: lambda-reference | 10 | -0.084056234 ± 0.056672848 | 0.0078125 | 0.02734375 |
| Prep PR: lambda-reference | 100 | -0.161395441 ± 0.030395655 | 0.0078125 | 0.02734375 |
| Prep alignment: observed-expected | 0.2 | 0.524451694 ± 0.009600329 | 0.001953125 | 0.001953125 |
| Prep alignment: observed-expected | 0.5 | 0.513944814 ± 0.009188158 | 0.001953125 | 0.001953125 |
| Prep alignment: observed-expected | 1 | 0.491950291 ± 0.007458111 | 0.001953125 | 0.001953125 |
| Prep alignment: observed-expected | 2 | 0.465688488 ± 0.005222654 | 0.001953125 | 0.001953125 |
| Prep alignment: observed-expected | 5 | 0.417073361 ± 0.012886707 | 0.001953125 | 0.001953125 |
| Prep alignment: observed-expected | 10 | 0.371800967 ± 0.013712706 | 0.001953125 | 0.001953125 |
| Prep alignment: observed-expected | 100 | 0.232469626 ± 0.021001428 | 0.001953125 | 0.001953125 |


Only λ=10 and 100 PR decreases pass BH q<0.05 (q=.02734375).
At λ=5, q=.050130208333333336 is not below .05.
Every higher-λ observed-minus-expected alignment test has p=q=.001953125 in the
above-null direction; none supports below-null control-to-λ alignment.

## Common-K audit

| λ | Kref range | Kλ range | Common K range | Min ref captured (%) | Min comparison captured (%) |
| --- | --- | --- | --- | --- | --- |
| 0.1 | 5–6 | 5–6 | 5–6 | 95.24803 | 95.24803 |
| 0.2 | 5–6 | 5–6 | 5–6 | 95.24803 | 95.17329 |
| 0.5 | 5–6 | 5–6 | 5–6 | 95.24803 | 95.05644 |
| 1 | 5–6 | 6–6 | 6–6 | 96.11095 | 95.68967 |
| 2 | 5–6 | 6–6 | 6–6 | 96.11095 | 95.49930 |
| 5 | 5–6 | 6–7 | 6–7 | 96.11095 | 95.33177 |
| 10 | 5–6 | 6–7 | 6–7 | 96.11095 | 95.11375 |
| 100 | 5–6 | 6–7 | 6–7 | 96.34344 | 95.00600 |


Reference Prep-to-Move has Kprep=8–9, Kmove/common K=11–13.
Its common-K captured variance is at least 98.398811% Prep and 95.013959% Move.
Across all 90 comparisons (80 diagnostic, including reference anchors; 10
Prep-to-Move), both sides capture strictly >95%; minimum **95.00600453571652%**.
Minimum counts were independently reproduced from singular values, and their
preceding counts do not exceed 95%. Both network tables retain every minimum
count, common K and achieved variance.

## Independent validation and preservation

| Check | Outcome |
| --- | --- |
| Code Analyzer | 7 changed/new MATLAB files; zero issues |
| Sentinel versus explicit per-neuron indexing | Exact |
| Eigenvalue PR versus independent SVD | Maximum error 8.881784197001252e-15 |
| Captured variance versus independent SVD | Maximum error 8.881784197001252e-16 |
| Covariance AI versus direct activity projection | Maximum error 2.1094237467877974e-15 |
| Reference self-alignment | All ten equal 1 to numerical precision |
| Independent marginal and paired bootstrap SEs | Maximum discrepancy 0 |
| Independent exact tests | All 17 reproduced by explicit bit enumeration |
| Independent BH correction | Both seven-test families reproduced, including ties |
| Synthetic alignment | Identical=1; orthogonal=0 |
| Isotropic 20-D, K=5 null | Mean .25304747392521748; theoretical .25 |
| Stage-1 protected hashes | All 132 scientific/support files unchanged |
| Controller/configuration and Results Figures 1–2 | Unchanged against starting commit |
| Original caches | All ten hash-verified; no cache writer called |
| MATLAB execution | Both jobs exited 0 |

Original `analysis.mat` remains SHA-256
`fb31842a9249ac158c0196fe11fc05c5f80a3fa63510cc9274bf81bc9870c1c1`.
Its floor/K15/GO=MO neural fields are historical/superseded, not a current
fallback. Original controller/error/effort/perturbation evidence remains valid.

## Figure review and files

Exactly three matching pairs were replaced under `plots/stage_2/{png,fig}/`:

1. `result_3_prep_move_alignment`
2. `diagnostic_1_pr_lambda`
3. `diagnostic_2_alignment_lambda`

All three FIGs were reopened/drawn and checked for font-16 axes/error bars.
All three PNGs were read and visually inspected. Individual networks, ensemble
median±SE, log-λ/reference marks, comparison-specific K and negative findings
remain visible. No extra formats or Results Figures 1–2 regeneration.

Six new MATLAB files implement the R2 configuration, cache preflight, population
analysis, ensemble analysis, validation and three-figure renderer.
The only modified existing MATLAB file is `run_stage_2.m`, routing analyze,
figures and validate to R2. Original simulation routing/configuration are fixed.
Active README/MODEL_SPEC/AGENTS and original-report status are reconciled.

Current compact outputs are under `results/stage_2/current/neural_geometry_r2/`:
`analysis.mat`, `summary.json`, `configuration.json`, `cache_preflight.json`,
`network_metrics.csv`, `network_paired_metrics.csv`, `planned_tests.csv`,
`final_validation.json`. The MAT retains null samples, shared bootstrap
indices, scales and eigenspectra. Original root outputs remain unchanged;
`NEURAL_GEOMETRY_STATUS.md` distinguishes their historical neural fields.
Caches and logs remain intentionally ignored/local-only.

`run_stage_2('figures')` regenerates the three R2 pairs from the saved MAT;
`run_stage_2('validate')` runs bounded output checks without model simulation.
The original five-figure renderer is not the current R2 route.

## Notion updates and verification

The existing parent/four-child hierarchy is retained. Technical Specification,
Presentation-ready Summary, Results Figure 3, both Diagnostic figures, methods,
captions, tables and current conclusions are updated.

Notion rejected exact-match edits containing temporary signed image URLs.
The successful native-reference method reused the **same original upload IDs**
for Results Figures 1–2 without reuploading their bytes. Readback proves their
native image identities and complete paragraph/caption text unchanged after
removing temporary URL query parameters. The two pages were serialized with
all unaffected content preserved; no child page was deleted or moved.

Three new PNG uploads are visibly attached with captions. Results has three
images/three captions and Diagnostics two of each. Valid multiline native
tables replace malformed old neural-statistics table markup. The original
Fig. 4F descriptive paragraph is preserved. Native upload IDs and sizes are in
`R2_NOTION_IMAGE_RECEIPTS.json`, without secrets or signed URLs.

The Notion specification-to-implementation workflow guided requirement parsing,
the pre-analysis plan and validation gates within the existing hierarchy; no
additional task database or unrequested pages were created.

## Checkpoint and stop

Stage only reviewed R2 code, compact results, documentation and the three pairs.
After a normal commit/push, record the verified final SHA, local/tracking/direct
remote equality and clean status in Agent Log/Handoff/START HERE. The receipt
belongs there rather than in a self-referential commit amendment.
No force-push, history rewrite, Git maintenance, model tuning or later model.

**Stop for scientific review; Stage 2 remains unaccepted.**
