# STAGE2-LAMBDA-SWEEP-01 — scientific review report

Status: computed and numerically validated; **not scientifically accepted**.
The approved sweep was run on all ten frozen Stage-1 networks without training,
retuning or modifying their scientific payload. The only model-run repair was
a cache allocation corrected to the actual frozen 599-sample movement output.
Full predeclared methods, source mapping and implementation notes are in
[PREREGISTRATION.md](PREREGISTRATION.md) and [SOURCE_AUDIT.md](SOURCE_AUDIT.md).

## Main findings

- Unweighted feedback effort decreases in all 70 adjacent network/lambda steps:
  ensemble median 29.1266 at lambda0.1 to 0.1950 at lambda100.
- **No supported preparatory-PR increase.** Median slope -0.015189
  ± 0.015392 PR/decade; exact p=0.30859375.
  Every lambda-versus-reference PR comparison has BH q=0.859375.
- Reference-to-lambda alignment declines. Deficit slope is
  5.5991 ± 0.4316
  percentage points/decade, exact p=0.001953125.
  At lambda100 the network-median deficit is 2.0226
  ± 1.0204 pp (BH q=0.01953125).
  At lambda0.2 through10, observed alignment is significantly **above** expected
  (each q=0.00227864583333333), not evidence of below-null alignment.
- Reference Prep-to-Move alignment is 96.8853
  ± 0.1991%, versus expected
  84.7183 ± 0.3928%.
  Median paired observed-minus-expected=11.9704
  ± 0.3881pp; exact p=0.001953125.
  This is **above-null alignment**, not preparatory–movement orthogonalization.
- Every higher-lambda200-ms prospective-error comparison increases versus reference,
  exact p=BH q=0.001953125. This error is a source-output quadratic approximation,
  not measured hand error or a nonlinear torque-integral equality.

## Ensemble values

Independent n=10; median ±10,000-resample bootstrap SE of the network median.
Deficit is the median of paired differences, not the difference of the two medians.
All alignment percentages and deficit percentage points are distinguished.

| λ | Prep PR ± SE | Observed AI (%) ± SE | Deficit (pp) ± SE | 200-ms error (%) ± SE | Feedback effort ± SE |
| --- | --- | --- | --- | --- | --- |
| 0.1 | 3.1903 ± 0.0451 | 100.000 ± 0.000 | -15.282 ± 0.393 | 0.00477 ± 0.00222 | 29.1266 ± 1.1862 |
| 0.2 | 3.1952 ± 0.0469 | 99.862 ± 0.022 | -15.143 ± 0.379 | 0.00970 ± 0.00275 | 20.7238 ± 0.8538 |
| 0.5 | 3.2000 ± 0.0527 | 99.187 ± 0.135 | -14.459 ± 0.313 | 0.02652 ± 0.00312 | 13.0096 ± 0.5523 |
| 1 | 3.1978 ± 0.0589 | 98.116 ± 0.292 | -13.469 ± 0.236 | 0.05935 ± 0.00756 | 8.9009 ± 0.3920 |
| 2 | 3.1844 ± 0.0652 | 96.497 ± 0.525 | -11.787 ± 0.310 | 0.14054 ± 0.01763 | 5.8612 ± 0.2708 |
| 5 | 3.1511 ± 0.0736 | 93.890 ± 0.821 | -8.966 ± 0.517 | 0.44089 ± 0.05099 | 3.1396 ± 0.1622 |
| 10 | 3.1454 ± 0.0780 | 91.449 ± 0.959 | -6.376 ± 0.728 | 1.05324 ± 0.09060 | 1.8288 ± 0.1043 |
| 100 | 3.1063 ± 0.0755 | 83.457 ± 1.156 | 2.023 ± 1.020 | 12.89881 ± 0.40050 | 0.1950 ± 0.0108 |

Expected alignment is identical acrosslambda by design: 84.7183±0.3928%.
Move PR and every network's captured15-PC variance are available in
`results/stage_2/current/network_metrics.csv`; all full-precision ensemble
values are in `summary.json` and regenerable `analysis.mat`.

## All planned paired tests

Differences below are PR units, normalized motor-error percentage points, or
alignment fractions as identified by family. Multiply alignment fractions by100
for percentage points. Exact tests enumerate all1024 network sign patterns;
seven comparisons are BH-corrected within each displayed family.

| Family | λ | Median paired difference ± SE | Exact p | BH q |
| --- | --- | --- | --- | --- |
| Prep PR: lambda-reference | 0.2 | 0.002912 ± 0.003792 | 0.460937500 | 0.859375000 |
| Prep PR: lambda-reference | 0.5 | 0.007453 ± 0.007744 | 0.658203125 | 0.859375000 |
| Prep PR: lambda-reference | 1 | 0.004837 ± 0.009289 | 0.859375000 | 0.859375000 |
| Prep PR: lambda-reference | 2 | -0.005658 ± 0.014673 | 0.802734375 | 0.859375000 |
| Prep PR: lambda-reference | 5 | -0.020300 ± 0.024860 | 0.404296875 | 0.859375000 |
| Prep PR: lambda-reference | 10 | -0.043077 ± 0.033666 | 0.183593750 | 0.859375000 |
| Prep PR: lambda-reference | 100 | -0.017966 ± 0.052720 | 0.564453125 | 0.859375000 |
| Motor error 200ms: lambda-reference | 0.2 | 0.004649 ± 0.000625 | 0.001953125 | 0.001953125 |
| Motor error 200ms: lambda-reference | 0.5 | 0.021198 ± 0.002485 | 0.001953125 | 0.001953125 |
| Motor error 200ms: lambda-reference | 1 | 0.054758 ± 0.006522 | 0.001953125 | 0.001953125 |
| Motor error 200ms: lambda-reference | 2 | 0.132989 ± 0.017164 | 0.001953125 | 0.001953125 |
| Motor error 200ms: lambda-reference | 5 | 0.437621 ± 0.047275 | 0.001953125 | 0.001953125 |
| Motor error 200ms: lambda-reference | 10 | 1.049595 ± 0.088139 | 0.001953125 | 0.001953125 |
| Motor error 200ms: lambda-reference | 100 | 12.888177 ± 0.400322 | 0.001953125 | 0.001953125 |
| Prep alignment: observed-expected | 0.2 | 0.151430 ± 0.003788 | 0.001953125 | 0.002278646 |
| Prep alignment: observed-expected | 0.5 | 0.144587 ± 0.003127 | 0.001953125 | 0.002278646 |
| Prep alignment: observed-expected | 1 | 0.134686 ± 0.002364 | 0.001953125 | 0.002278646 |
| Prep alignment: observed-expected | 2 | 0.117869 ± 0.003104 | 0.001953125 | 0.002278646 |
| Prep alignment: observed-expected | 5 | 0.089661 ± 0.005173 | 0.001953125 | 0.002278646 |
| Prep alignment: observed-expected | 10 | 0.063758 ± 0.007284 | 0.001953125 | 0.002278646 |
| Prep alignment: observed-expected | 100 | -0.020226 ± 0.010204 | 0.019531250 | 0.019531250 |

## Validation and limitations

All640 network-target-lambda movements and8,000 approved perturbation trials are finite.
All132 protected Stage-1 scientific/support files have unchanged hashes.
Maximum CARE residual 3.339267126486351e-14; fixed-point residual
2.1316282072803006e-14; maximum normalized-time closed-loop pole
-0.18732807139953273. Reference self-alignment is1 in all networks.
Independent SVD PR discrepancy ≤6.217248937900877e-15;
captured-variance discrepancy ≤7.771561172376096e-16;
direct-activity versus covariance alignment discrepancy ≤7.771561172376096e-16.
Independent bootstrap-SE discrepancy is0. Exact-signflip and BH synthetic checks pass.
Code Analyzer:16 changed/new MATLAB files, zero issues at validation.

Fixed15 PCs capture at least99.96373% of Prep variance
and99.81092% of Move variance across every network/lambda.
K was not adjusted. All200 neurons in every network hit the fixed SD floor1, so
the primary normalization does not rescale these model rates. This source-unit
analogue is a material limitation when comparing to experimental1-Hz normalization;
no alternate floor or sensitivity sweep was introduced after outcomes.

The approved isotropic Gaussian initial perturbation has Euclidean norm
median1.41092, central95% interval
[1.27807,1.54979],
range[1.13326,1.69182]
source-state units. Per-trial initial ReLU status-change fraction has median0,
97.5th percentile0.5%, maximum1%. These are descriptive distributions over8,000
trials, not8,000 independent networks. No amplitude, count or seed was changed.
Potent-direction errors rapidly decay while least-potent deviations remain;
the exact curves are saved in analysis.mat. No added panel-C hypothesis test.

Source-output prospective cost uses rates minus xstar, including its nonlinear
rate/state discrepancy. The primary epochs include the shared GO sample.
The full-reference window retains the specified GO/MO overlap. No late-window,
floor, PC-count, null or statistic was chosen to improve results.

## Figure inventory and visual review

Exactly five PNG/FIG pairs under `plots/stage_2/{png,fig}/`:
1. `result_1_preparation_trajectories`
2. `result_2_controller_operation`
3. `result_3_prep_move_alignment`
4. `diagnostic_1_pr_lambda`
5. `diagnostic_2_alignment_lambda`

All PNGs were visually inspected; FIGs reopened and checked for axes font16 and
plotted content. The final two prospective-error axes are linear: the first
logarithmic rendering could not display negative lower median±SE bounds.
This presentation-only correction preserves all numerical arrays and complete
uncertainty bands. No PDF/JPG/SVG variants were produced.

Member1 descriptive endpoint-error ranges after25/50/100/200ms respectively:
25ms: 7.059–19.418mm; 50ms: 2.097–6.194mm; 100ms: 0.080–2.909mm; 200ms: 0.410–5.487mm.
Longer preparation is not guaranteed to improve every individual hand endpoint.

## Notion hierarchy

[Stage2 parent](https://www.notion.so/3d326c94be3081718cb2e138574b99fc)
with exactly four children:
[Technical Specification](https://www.notion.so/3d326c94be30816cbe53d67f3f0cd31f),
[Presentation-ready Summary](https://www.notion.so/3d326c94be30814aa5a1eff9d6ec5c31),
[Results](https://www.notion.so/3d326c94be3081348a8bffdd51348a42),
[Diagnostics & Sensitivity](https://www.notion.so/3d326c94be3081598d2afdc612e9e4e5).

## Reproduction and checkpoint boundary

Use `run_stage_2('figures')` to regenerate from analysis.mat; no model replay is
needed. Large validated caches remain ignored, with hashes in cache_manifest.csv.
The fixed model, analysis and bootstrap/null configuration is recorded in
configuration.json and the preregistration. One normal Stage2 commit/push is
authorized only after visible Notion figures and final validation; the actual
final SHA/push receipt is recorded in Agent Log/Handoff/START HERE after verification.
No later model or prediction analysis is authorized.

Final presentation verification: Results has three native uploaded PNG image
blocks and three immediately following captions; Diagnostics has two of each.
No upload placeholders remain. The final linear-axis controller figure was
reinspected after moving its legend clear of the curves. All five FIGs and
PNGs reopened successfully, with axes font16; final Code Analyzer has zero
issues across16 MATLAB files. Regeneration did not change analysis.mat:
SHA256 fb31842a9249ac158c0196fe11fc05c5f80a3fa63510cc9274bf81bc9870c1c1.
One initial Notion upload was rejected because the client used octet-stream
instead of image/png. A fresh upload with explicit PNG MIME succeeded; no
duplicate image was inserted and no user file was deleted.
