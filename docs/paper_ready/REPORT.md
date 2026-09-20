# Paper modelling pre-prediction — scientific review report

Task **PAPER-MODELLING-PREPREDICTION-01**, 20 September 2026.
Starting checkpoint: `37680bad81e3ae441a285b3a4cadf1194df4b5c6`.
Active repository: `E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model`.
All numerical stages and both independent audits completed. Scientific acceptance
is pending user review. Figure/publication/cleanup/release completion is established
by the corresponding final receipts; the verified release SHA is recorded in Notion
after push, not self-referentially inside this report.

**No new prep→early-movement prediction analysis or panel e was run.**
Accepted Stage-1/2/3 models, controllers, numerical results and figures are preserved.
The paper-specific λ/geometry choices below are separate calibrations, not changes
to those accepted files.

## Main findings and limitations

The timing-only rule selects **λ=10**, with sustained 90% Q-error reduction at
**74.25 ms** (target medians within networks, then median across ten networks).
Full-state 90% distance reduction is a different measure: **382.5 ms** by the
same nested medians. Frozen per-network κ₀ is unchanged.

The fixed grid selects **α=0.5, β_norm=0.5, V realization 1**, index 21, shared
across all ten networks. Loss is **0.19459255976704695**. There are 237 physically
screened-in/tested/feasible network-candidate cases and 123 endpoint-screen rejects
among 360 cases. Twenty of the 36 parameter pairs are feasible in every network.
The fixed grid was not expanded; no movement or prediction outcome entered selection.

The primary K=15 calibration has the intended signs, but is quantitatively imperfect.
PR increase is 17.40% below the empirical target and alignment deficit is 40.53%
above it. Absolute model PR and alignment differ substantially from the data.

**The below-null alignment conclusion is not robust to the predeclared PC-rule
sensitivity.** With the same selected geometry, adaptive common K=7 gives an
Expected−Observed deficit of **−2.373314 ±0.489876 percentage points**, rather than
the primary K=15 deficit of **+23.612770 ±0.472751 pp**. The reversal accompanies
a much larger change in the null expectation than in observed alignment. Do not
describe this as a robust reproduction of the empirical joint geometry, or as an
independent prediction. No parameter or PC count was changed to rescue the outcome.

Neither of the two tested fixed isotropic-noise sweeps reproduces the selected
Block PR/alignment combination. This statement concerns those specified families
and amplitudes only, not all structured noise mechanisms or neural prediction.

## Exact empirical extraction

Source: supplied `dimensionality_alignment_epochs_raw_data.fig`, Drive ID
`1T-3vbgRph1bbm-sl_fK0u9GiNzpwKzUT`, 48,341 bytes, modified 13 June 2026.
SHA256: `B2B1381FCFEFABBA5065E8D7617DB0D5A9E5EF08C6A120E539AE980C635A824F`.

| Prep quantity | Exact displayed estimate | Exact displayed error |
| --- | ---: | ---: |
| Control PR | 5.386083461458462 | 0.10849353351504434 |
| Block PR | 8.031416855882718 | 0.1492166304511115 |
| Observed alignment (%) | 32.49312168616452 | 1.1226239345301614 |
| Expected alignment (%) | 49.295305371483224 | 3.2987728284040356 |

These are pooled bars, not individual-monkey dots. The exact empirical fitting
targets are ΔPR=2.6453333944242559 and alignment deficit=16.802183685318703 pp.
The graphics were independently reopened and passed 16 checks. Source objects,
original FIG, inventory, review PNG and extracted doubles remain in
`results/paper_ready/empirical/`.

Main_text_v8 Supplementary Figure 3 identifies the displayed errors as SD across
1,000 trial-balanced resamples of pooled 1,048+3,824 neurons. They are **not**
bootstrap SE across the ten model networks. Paired-effect uncertainty cannot be
recovered from marginal error bars; none was invented. The prescribed relative
squared-effect loss does not use uncertainty weights. Model rates are in source
units and use frozen per-neuron scales without a source-unit floor, unlike the
empirical 1-Hz floor. Thirty independent model trials are not the experimental
trial-balancing/resampling procedure. Full source notes: `EMPIRICAL_SOURCE.md`.

## Timing calibration

| λ | 0.1 | 0.2 | 0.5 | 1 | 2 | 5 | 10 | 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Sustained Q-readiness (ms) | 10 | 13 | 20 | 28 | 38.25 | 57.5 | 74.25 | 116 |

Eligible λ values are 5 and 10; λ=10 is closest to 75 ms. The 50–100-ms range is
an approved modelling constraint, not a universal physiological lower bound.
Crossing is reported on the saved 1-ms grid and is sustained at every subsequent
native 0.2-ms step through GO. Timing used deterministic Intact preparations,
not noisy geometry or movement appearance. All 80 network/λ protocols passed
CARE, local-stability, Euler and rate/state checks. λ=0.1 preparations match
the frozen biological trajectories exactly; independent native-increment error
is at most 4.440892098500626e−16. All target/network timings and bounds are saved.

## Geometry and PC-rule sensitivity

Model estimates below are network medians ± SE of the network median using the
frozen 10,000 whole-network bootstrap resamples. Paired effect medians need not
equal differences of separately pooled medians.

| Quantity | Model K=15 | Empirical target / bar |
| --- | ---: | ---: |
| Intact / Control PR | 3.463191 ±0.128573 | 5.386083 |
| Block PR | 5.660113 ±0.082327 | 8.031417 |
| Observed alignment (%) | 62.821665 ±0.406929 | 32.493122 |
| Expected alignment (%) | 87.032437 ±0.386441 | 49.295305 |
| Paired Block−Intact PR | 2.184920 ±0.053633 | 2.645333 |
| Paired Expected−Observed (pp) | 23.612770 ±0.472751 | 16.802184 |

Across common feasible points, median PR effects span 0.1176769663–3.5918277236;
alignment deficits span −10.9632383300–81.1412478922 pp. These separate ranges
are not a claim that every combination is jointly attainable.

Every tested candidate has numerical ranks 77/77, the maximum after per-time
target centering of 11 times × 8 targets. K=15 is therefore not numerically
degenerate under the locked tolerance. It captures 99.91527766–99.92358081% of
Intact variance and 99.83070159–99.84755825% of Block variance at the selected
point. High cumulative variance does not establish PC-rule robustness.

| PC rule, same selected geometry | Observed (%) | Expected (%) | Paired deficit (pp) |
| --- | ---: | ---: | ---: |
| K=15 primary | 62.821665 ±0.406929 | 87.032437 ±0.386441 | 23.612770 ±0.472751 |
| Adaptive common >95%, K=7 in all networks | 60.804919 ±0.602281 | 58.262624 ±0.547595 | −2.373314 ±0.489876 |

Null Monte Carlo SE is reported separately from network-bootstrap uncertainty:
K=15 ranges 0.0237576–0.0287481 pp; adaptive K=7 ranges 0.0674926–0.0788012 pp.
All 10,000 draws per required K, seeds and covariance bias are retained in the
local caches. Expected values are recomputed from current Intact covariance,
not copied from the old controller.

## Separate noise-only controls

Vary one source over the fixed five amplitudes with the other held at 0.10.
The Intact components, normalization, targets/trials and standardized draws remain
fixed. The expected alignment is 87.032437 ±0.386441% for every row because the
standard Intact reference and its null are fixed. No level was selected or retuned.

| Varied source | Amplitude | PR | Observed (%) | Deficit (pp) | Normalized residual variance | Raw residual variance |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Cue-state | 0.00 | 3.4635 ± 0.1286 | 99.9969 ± 0.0003 | -12.9645 ± 0.3860 | 0.124822 ± 0.002479 | 0.009331 ± 0.000161 |
| Cue-state | 0.05 | 3.4633 ± 0.1286 | 99.9992 ± 0.0001 | -12.9668 ± 0.3863 | 0.124929 ± 0.002485 | 0.009342 ± 0.000162 |
| Cue-state | 0.10 | 3.4632 ± 0.1286 | 100.0000 ± 0.0000 | -12.9676 ± 0.3864 | 0.125294 ± 0.002518 | 0.009370 ± 0.000164 |
| Cue-state | 0.20 | 3.4631 ± 0.1285 | 99.9968 ± 0.0003 | -12.9645 ± 0.3860 | 0.126796 ± 0.002665 | 0.009476 ± 0.000173 |
| Cue-state | 0.40 | 3.4637 ± 0.1284 | 99.9713 ± 0.0029 | -12.9398 ± 0.3824 | 0.132859 ± 0.003323 | 0.009893 ± 0.000209 |
| Temporal | 0.00 | 3.4123 ± 0.1249 | 99.2837 ± 0.0234 | -12.2885 ± 0.3466 | 0.000482 ± 0.000046 | 0.000034 ± 0.000003 |
| Temporal | 0.05 | 3.4280 ± 0.1269 | 99.8399 ± 0.0059 | -12.8177 ± 0.3762 | 0.031701 ± 0.000665 | 0.002370 ± 0.000043 |
| Temporal | 0.10 | 3.4632 ± 0.1286 | 100.0000 ± 0.0000 | -12.9676 ± 0.3864 | 0.125294 ± 0.002518 | 0.009370 ± 0.000164 |
| Temporal | 0.20 | 3.5929 ± 0.1319 | 99.4296 ± 0.0188 | -12.4321 ± 0.3527 | 0.499018 ± 0.010048 | 0.037291 ± 0.000656 |
| Temporal | 0.40 | 4.0534 ± 0.1396 | 95.5370 ± 0.1944 | -8.7701 ± 0.1385 | 1.921888 ± 0.036075 | 0.143897 ± 0.002440 |


At the largest cue-state amplitude, PR remains approximately 3.464 despite
normalized residual variance approaching the Block reference (0.136876 ±0.002955).
Increasing temporal noise to 0.40 raises PR to 4.0534 and residual variance to
1.9219, but observed alignment remains above its null. No tested amplitude
reproduces the selected primary Block combination. No new prediction R² was
computed. All 100 network/source/level records pass the retained native bounds;
the shared 0.10 baseline was reused, not simulated twice.

## Four-policy movement and event QC

Thirty trials × eight targets × ten networks × four policies = **9,600 movements**.
Each achieved GO state enters the unchanged deterministic movement generator,
readout and arm, with no reset, correction or post-GO noise. MO is the first saved
sample reaching 20% of that trial's own positive speed peak. The 0–598-ms neural
horizon governs availability of MO+0:100-ms windows; the arm includes 599 ms.

| Policy | PR | Observed (%) | Deficit (pp) | Endpoint RMS (mm) | MO (ms) | Peak time (ms) | Peak speed (m/s) | Separation/scatter |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Intact | 3.4632 ± 0.1286 | 100.0000 ± 0.0000 | -12.9676 ± 0.3864 | 19.7533 ± 0.5204 | 55.75 ± 0.37 | 200.75 ± 0.37 | 0.4166 ± 0.0007 | 7.3573 ± 0.2151 |
| Remove feedback | 3.4861 ± 0.1247 | 99.7477 ± 0.0311 | -12.7001 ± 0.3518 | 29.2732 ± 0.9047 | 55.00 ± 0.25 | 200.00 ± 0.25 | 0.4171 ± 0.0007 | 4.8880 ± 0.1240 |
| Remove b | 3.9383 ± 0.0646 | 55.1103 ± 0.8389 | 31.6832 ± 0.6732 | 19.5459 ± 0.4913 | 42.50 ± 0.55 | 189.25 ± 0.48 | 0.2877 ± 0.0035 | 4.8646 ± 0.1718 |
| Block | 5.6601 ± 0.0823 | 62.8217 ± 0.4069 | 23.6128 ± 0.4728 | 28.5645 ± 0.8854 | 55.00 ± 0.79 | 205.50 ± 1.79 | 0.2141 ± 0.0046 | 2.7758 ± 0.1347 |


Endpoint RMS is dispersion about the within-target mean, averaged across targets
within each network, not endpoint bias from the nominal target. Separation/scatter
is the median pairwise target-centroid distance divided by mean within-target RMS.
MO/peak/speed columns first summarize trials within network; network medians and
SE are shown above. Target-resolved source tables retain all targets and trials.

| Policy | Trials | Near-zero peaks | Boundary peaks | Missing response windows | Multiple large peaks |
| --- | ---: | ---: | ---: | ---: | ---: |
| Intact | 2400 | 0 | 0 | 0 | 0 |
| Remove feedback | 2400 | 0 | 0 | 0 | 9 |
| Remove b | 2400 | 0 | 0 | 0 | 91 |
| Block | 2400 | 0 | 26 | 0 | 433 |

All cortical/arm states and inputs are finite; all 40 primary network/policy
preparations pass the native rate/state/input bounds. Multiple-peak flags use
the locked ≥50%-of-own-peak, ≥20-ms separation rule; near-zero is ≤1e−8 m/s.
No abnormal Block trial was excluded. Boundary/multiple peaks are scientific
QC findings, not a reason to choose a different geometry. Fixed first-15/last-15
trial reliability values remain in `policy_source.csv`; no favorable split was
selected and no held-out prediction claim is made.

The fixed split gives the following descriptive network medians (no new
inference or favorable split selection):

| Policy | Median absolute half-PR difference | Median half1→half2 alignment (%) | Median half-null (%) |
| --- | ---: | ---: | ---: |
| Intact | 0.015571 | 97.485050 | 86.457857 |
| Remove feedback | 0.012036 | 97.264602 | 86.439411 |
| Remove b | 0.015748 | 96.408154 | 53.401903 |
| Block | 0.056865 | 94.582028 | 45.343746 |

Half-to-half alignment uses each policy's two independent 15-trial means
and the same K=15 definition. These within-policy reliability comparisons
are not the primary Intact-to-Block comparison or a regression prediction.

## Independent validation

- Exact empirical FIG extraction/reopen: 16 checks.
- Standardized initial/process draws match the frozen streams exactly; per-neuron
  indexing sentinel passes. Zero-noise preparations reproduce all four frozen
  network-1 policy preparations with zero discrepancy.
- Coupled fine-step checks at λ=10: maximum relative state RMS 0.0001498271;
  maximum hand RMS 0.0269721 mm, below the locked 1% / 1-mm tolerances.
- Saved-output audit: **42,130 checks, PASS**. Maximum PR error 9.770e−15,
  alignment error 4.774e−15, capture error 8.882e−16, adaptive-alignment error
  1.887e−15, transition error 4.441e−16, arm error 2.220e−16 and bootstrap-SE
  error 1.099e−14.
- Additional control/selection/raw-variance audit: **1,240 checks, PASS**.
  Maximum metric error 7.994e−15, residual-variance error 5.329e−15,
  movement-transition error zero and endpoint-scatter error 1.041e−17.
- Bounded Stage-1 smoke/pinned-reference check passes: source checkpoint
  `40077d2da16e68ab2ab2cff59ec692b97315980b`, short-segment error 2.220e−16,
  Q residual 7.345e−14. No recalibration or full ensemble rerun.
- The final post-production preservation recheck confirms 1,516 protected files unchanged,
  including all 52 old plot files. Only AGENTS.md navigation and the paper-cache
  .gitignore entry are declared baseline documentation changes. The final
  post-production receipt is `PRESERVATION.json`.

No new inferential family is used for calibrated contrasts. Frozen Stage-2
statistics remain unchanged: PR BH q=0.02734375 at λ=10 and 100; observed exceeds
expected at every non-reference λ, q=0.001953125 in the original seven-test family.
The new calibration and noise/QC comparisons are descriptive.

## Figures, provenance and operational repairs

Four cache-only FIG/PNG pairs: `main_modelling`, `support_calibration`,
`support_noise_controls`, `support_movement_qc`, under
`plots/paper_ready/{fig,png}/`. Supporting figures show the PC-rule sensitivity,
both noise families, target-resolved traces and all-network event/dispersion QC.
The fixed network-1 example was not chosen from outcomes. FIGs are editable;
data/error-bar objects are reopened and checked. Native PNG publication and
readback are recorded separately. Full legends and panel map are in this folder.

Operational fixes did not change scientific parameters: an initial Code Analyzer
formatting stop occurred before production; the final renderer corrects a
quiver hold-state defect and a sprintf Greek-escape warning, plus labels,
home-relative display, target markers and explicit sensitivity/QC presentation.
First-render hashes are preserved in RENDER_REVIEW_BEFORE.csv. Regeneration
uses saved outputs only; no timing, geometry, noise or movement replay is repeated.

The locked plan, empirical source notes and implementation/indexing proof are
`PLAN.md`, `EMPIRICAL_SOURCE.md`, and `IMPLEMENTATION_NOTES.md`.
Compact MAT/JSON/CSV outputs are under `results/paper_ready/`; required raw
evidence remains in its ignored `cache/` directory. Cleanup inventory/action
receipts classify every paper file before any removal; only the byte-identical
interim geometry CSV is eligible for removal. No accepted scientific evidence
or unsuccessful candidate is removed.

## Review boundary

Review the imperfect absolute/effect fit, strong PC-rule dependence, tested
noise-family limits and Block movement flags before authorizing anything else.
No panel e, new neural/behavioral prediction fit, training, adaptation, new
noise family, new parameter point or later model has been run or authorized.
