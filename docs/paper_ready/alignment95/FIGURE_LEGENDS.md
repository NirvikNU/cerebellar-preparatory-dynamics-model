# Corrected paper figure candidates — Control-derived >=95% alignment

PAPER-MODELLING-ALIGNMENT95-01. Scientific review pending. Outcomes and selected
geometry are in REPORT.md/REPORT.json after independent validation; this
caption file is not evidence that computation or publication has completed.
No panel e or prep-to-movement regression is included.

## Main modelling a–d

**Reference-preserving feedback and a calibrated two-function cerebellar input.**
(a) Late-preparatory participation ratio (PR) and (b) reference-to-comparison
alignment across the frozen Stage-2 effort-penalty sweep. Increasing lambda
re-optimizes feedback at greater effort penalty while retaining target setting;
it is not literal block or complete feedback removal. These two panels reuse
unchanged accepted Stage-2 arrays: GO−100:10:0 ms, reference lambda=.1 full-window
neuronwise SD without source-unit floor, target centering, pairwise common
strictly >95%-variance PCs, 1,000 null draws and 10,000 network bootstraps.
The new Control-only rule applies to the paper calibration, not a silent rewrite
of these frozen Stage-2 results. PR decreased, and observed alignment stayed
above its matched expectation. Original seven-test families are unchanged:
PR BH q=.02734375 at lambda10/100 (median paired changes −.0840562/−.1613954);
observed-minus-expected alignment is positive at every nonreference lambda,
BH q=.001953125 each. Individual network points and connected median±SE
summaries represent ten independent networks, not trial-level inference.

(c) The unchanged 200-unit ReLU cortex receives a common residual preparation
policy u0=−f(xB)−kappa0(x−xB), plus effective cerebellar state setting b and
prospective feedback −L(x−x*). Intact retains both; remove-feedback retains b;
remove-b retains feedback; Block retains neither. The identical u0 remains
within each pair. This is an effective functional decomposition, not evidence
for two anatomical pathways. Frozen kappa0 is approximately .808–.924, selected
for a local leak-timescale stability margin, not fitted here. L uses the saved
Kao-derived P/lambda at lambda10, not a new proof of optimality for the modified
nonlinear residual plant. All preparatory inputs and noise end at GO; achieved
state enters unchanged Stage-1 movement/readout/arm without reset.

(d1) Re-score the same 6×6 alpha/beta grid using exact empirical paired-effect
targets and the corrected Control-only alignment rule. A single pair must be
feasible in all ten networks; crosses mark non-common-feasible points and gray
cells lack full-ensemble evaluation. Star marks the minimum of the fixed sum
of squared relative errors in median-network Block−Intact PR and
Expected−Observed alignment. No movement or prediction outcome selects a point.
(d2,d3) Absolute data/model PR and alignment are displayed, including imperfect
agreement. Empirical pooled Prep bars are PR5.38608346/8.03141686 and
observed/expected32.49312169/49.29530537%; differences2.64533339 and16.80218369pp.
Errors are SD across 1,000 trial-balanced resamples of pooled 1,048 + 3,824 neurons,
not model network-bootstrap SE. Paired empirical-effect covariance is not
available from the FIG; no paired uncertainty is fabricated.

Corrected model primary: native ReLU rates, no Gaussian smoothing; 30 trials
per each of 8 targets/network; target means computed before analysis; final
GO−100:10:0 ms; frozen per-neuron SD and per-time target centering. For EACH
network/reference spectrum, K_control is the minimum number reaching >=95%
cumulative variance. The same K controls Block basis width, Control top-K
eigenvalue-sum denominator and covariance-shaped null width. Do not force K
across networks or maximize with Block K. PR uses all eigenvalues. Null bias
remains the frozen full-reference covariance, with 10,000 fixed draws; expected
scalars are evaluated on the actual reference covariance. Report network K
and Control/Block capture in the source table. The model has 200 rate units
(160E/40I), not the empirical neuron count; no source-unit SD floor is used.
Noise amplitudes s_init=s_temporal=.10 are model-state units, preparation only.
Independent model trials are not the experimental bootstrap-averaging procedure.
Model error bars: median across 10 networks ± SE of the network median using
10,000 frozen whole-network bootstrap resamples. Fitted contrasts are
descriptive calibration, not independent predictions; no new inferential family.

## Supporting calibration

**Timing, attainable geometry and component-removal time courses.** Timing is
unchanged: sustained cue-normalized Q error ≤0.10, saved 1-ms crossing maintained
at every native 0.2-ms step through GO; median targets within network then median
networks. Lambda 10 was selected by the predeclared 50–100-ms interval, closest
to 75 ms (74.25 ms observed). This is a modelling constraint, not a universal
physiological bound. Full-state 90% settling is distinct (382.5 ms nested median).
Loss, attainable-effect scatter, PR-effect map and corrected alignment-deficit
map retain the fixed grid and unselected/failed points. Yellow star=data,
diamond=selected fit in the attainable-effect panel; separate ranges are not
a claim of rectangular joint attainability.

Four-policy curves show distance to x*, distance to xB, normalized Q error,
trailing 100-ms PR and alignment deficit every 10 ms. Early windows are padded
with the unchanged spontaneous pre-cue baseline. Each matching Intact window
defines its own >=95% Control K and top-K denominator, used identically for
the comparison and null. Curves are network medians±network-bootstrap SE.
The last panel compares corrected primary against K15 sensitivity at the SAME
new selected geometry. Fixed K15 and the former adaptive common-K analysis
are provenance/sensitivity only; neither selects geometry. Original K15-selected
figures and values remain separately preserved, not overwritten.

## Supporting separate noise controls

**Cue-state and temporal isotropic-noise alternatives with Intact components.**
Top row varies s_init over [0, 0.05, 0.10, 0.20, 0.40], holding s_temporal=0.10;
bottom varies s_temporal over that fixed set, holding s_init=.10. Standard
Intact(.10,.10) is the reference, including its Control-derived K; varied
noise does not redefine the reference or choose K. All amplitudes share fixed
standardized draws, targets/trials, controller and preprocessing. Compare
late-prep PR, observed/expected alignment, deficit and normalized within-target
residual neural variance with the selected full Block reference (orange band:
network median±SE). Raw residual variance is also tabulated. Residual variance
uses individual trials with sample divisor 29, averaged over neurons, late times
and targets; PR/alignment use target means. The .10 vertical marker denotes
the prespecified primary amplitude, not an amplitude selected from results.
Black crosses identify any native bound failure without omitting the point.
Thin points are networks; lines connect ensemble medians±SE. A negative result
rules out neither all noise families nor all amplitudes and says nothing by
itself about prediction. No R² or regression is computed.

## Supporting movement and event QC

**Deterministic movements launched from the corrected selected geometry.**
Rows show Intact, remove feedback, remove b and Block. Network 1 is fixed before
results. Target-colored paths and unsmoothed speed profiles show all 30 trials
per target; thick curves are target-specific medians, shading is trial IQR,
not network-bootstrap uncertainty. T1–T8 angles are −90,−45,0,45,90,135,180,225
degrees in the frozen registry. Paths are home-relative (black+); circles mark
nominal 10-cm targets. Common path/speed scales are used; opposing targets are
never pooled into one trajectory. No scientific arrays change for display.

All 10 networks contribute 2,400 trials/policy to event histograms. Own-trial MO
is the first 1-ms speed sample reaching 20% of that trial's positive peak; near
zero ≤1e−8 m/s, boundary peaks first/last saved sample, large multiple peaks
≥50% own peak separated by ≥20 ms. Availability of MO+0:100 uses the neural 0–598-ms
horizon; arm evidence includes 599 ms. No flagged trial is silently excluded.
Final-row peak-speed distributions share bins; within-target endpoint RMS
(around its mean, not nominal-target bias) and target-centroid separation
divided by within-target scatter use network medians±SE with network points.
Geometry is selected before movements and is never retuned from QC.
Preparation noise and inputs stop at GO; no post-GO correction/noise/reset.
Unchanged Intact movement is reused; only required new-policy movements are
replayed if the selected geometry differs. Exact reuse/replay counts and all
finite/input/state/arm checks belong in the report.

## Provenance and review boundary

Code: analysis/paper_ready/alignment95 and figures/paper_ready/alignment95.
Compact results: results/paper_ready/alignment95; new required raw evidence:
results/paper_ready/cache/alignment95. Old roots remain K15 provenance.
Four new masters: plots/paper_ready/{fig,png}/*_alignment95.{fig,png}.
All FIG data/error objects must be reopened and matched; PNGs visually
reviewed and natively uploaded/read back in Notion. Final release identity is
recorded only after verification. No scientific acceptance or panel e is implied.
