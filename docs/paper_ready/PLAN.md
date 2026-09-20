# Paper modelling pre-prediction: locked analysis plan

Task PAPER-MODELLING-PREPREDICTION-01, 20 September 2026. Authority is the
current top Agent Instructions contract, read with all three manuscript
workspace pages. Starting checkpoint37680bad81e3ae441a285b3a4cadf1194df4b5c6.
The empirical graphics extraction precedes this plan; no model calibration
has run. No new prediction calculation, including panel e, is authorized.

## Empirical targets and uncertainty

Source: supplied dimensionality_alignment_epochs_raw_data.fig, Drive ID
1T-3vbgRph1bbm-sl_fK0u9GiNzpwKzUT,48341bytes, modified13June2026.
SHA256 B2B1381FCFEFABBA5065E8D7617DB0D5A9E5EF08C6A120E539AE980C635A824F.
Exact Prep bars (second epoch, not monkey-specific dots):

| Quantity | Plotted value | Symmetric displayed error |
| --- | ---: | ---: |
| Control PR | 5.386083461458462 | 0.10849353351504434 |
| Block PR | 8.031416855882718 | 0.1492166304511115 |
| Observed alignment (%) | 32.49312168616452 | 1.1226239345301614 |
| Expected alignment (%) | 49.295305371483224 | 3.2987728284040356 |

Use differences of these exact marginal bars as explicitly instructed,
not median paired differences: DeltaPR=2.645333394424256;
alignment deficit=16.8021836853187 percentage points. All calculations
derive from graphics doubles, not rounded text. Do not infer paired-effect
SD by adding marginal variances: covariance/resample data are not in FIG.
This does not prevent the prescribed effect-normalized loss (no uncertainty
weighting was authorized).

Main_text_v8, Drive1ZMY8I_aalyKtAfdE4Sz_uoO4zE8v3W_E0d-_s0T09gI,
revision13September2026, Supplementary Figure3 caption identifies pooled
neurons (1048+3824), median across1000 trial-balanced resamples and SD across
those resamples. These are not bootstrap SE across10 model networks. Its
Methods confirm GO-100:10:0, neuronwise control full-reference SD with1Hz
floor, per-time target centering, K15 and covariance-shaped random subspaces.
The model uses source-rate units, native ReLU without smoothing and frozen
neuron SD without arbitrary source-unit floor, as the existing model
convention. Thirty independent model trials are not the experimental1000
trial-balancing resamples. Display and disclose these distinctions.

## Immutable foundation and controller calibration

Preserve10accepted200-unit networks,8targets, W,h,xsp,xstar,C,Qnative,
movement drive and arm. Use native dt=.0002s,tau=.15s,saved.001s.
Use exact saved Stage2 Q and P for each lambda [0.1 .2 .5 1 2 5 10 100],
L=P/lambda. Do not resolve CARE, refit Q or modify frozen kappa0.
f(x)=-x+W ReLU(x)+h; u0=-f(xB)-kappa0(x-xB),
b=f(xB)-f(xstar)+kappa0(xstar-xB), FB=-L(x-xstar).
Policies [b,FB]=[1,1],[1,0],[0,1],[0,0], identical u0 within each pair.
All preparation inputs end at GO; movement starts at achieved state, no reset.
Feedback is Kao-derived state-feedback, not a claim of newly optimal
control of the modified nonlinear residual plant.

Timing selection uses noiseless Intact,500ms from xsp, independent of xB
by algebraic cancellation. First post-cue1ms saved sample at/below10% of
cue Q-error with all subsequent native samples throughGO at/below10%.
No interpolation; never-achieved/degenerate remains invalid, not500ms.
Median8targets then median10networks. Eligible50--100ms, closest75ms;
if numerical tie, first ascending lambda. No eligible value means stop.
Report ordinary state-distance90% separately. Check baseline lambda.1
against frozen biological trajectories<=1e-10; validate CARE, equilibrium,
local stability/Euler radius and rate/state bounds. Fixed kappa remains
approximately.808--.924; no outcome-selected replacement.

## Geometry and trials

Reuse saved state definitions for direction1, alpha=[.1 .2 .35 .5 .75 1],
betaNormalized=[.1 .25 .5 .75 1 1.25]. No new realization or gridpoint.
One selected pair must be feasible in every network. Preserve current
nonnegative constructed rates, raw/normalized variance ratio[.25,2], saved
rateLimit/stateLimit, stable local poles and native Euler radius<1.
Retain component limits5*max(1,Intact maximum total input), evaluating
u0,b,FB,b+FB,total separately including endpoint/counterfactual checks.
Do not reinstate the retired Block settling cutoff; report terminal distance.
The constructed analytical sufficient phenotype is descriptive, not a new
physical feasibility requirement or geometry-fit loss term.

Thirty trials/target. Seeds310000000+10000*network+100*target+trial,
MATLAB mt19937ar. Each stream draws200cue normals then200-by-step process
normals in the frozen order. xcue=xsp+s_init*z; EM increment
s_temporal*sqrt(2dt/tau)*xi. Primary both.10, no postGO noise. Same standards
all policies, lambdas/candidates/noise levels; no result-driven reseeding.
Noisy preparation500ms. Save trial late-window rates, GO, target-mean
timecourses, native extrema and components; large evidence cache ignored.

Population arrays [time,neuron,target,trial], average trials FIRST. Scale by
existing frozen per-neuron ref.scale, target-center at each time, permute
to [time,target,neuron], reshape observations-by-neuron. Sentinel test.
GO-100:10:0. PR=trace(C)^2/trace(C^2), all eigenvalues. K15 primary;
numerical rank uses100*max(size(X))*eps(largest singular value), same family
as frozen reference; rank<15 means infeasible, never substitute adaptive K.
Record K15 captured variance and common larger minimum strictly>95% count
as sensitivity. Reference covariance/null bias remains frozen ref.fullCov.
Control projection onto Block PCs divided by reference topK eigenvalue sum.
Use existing covariance-shaped null10000 draws, seed2026090900+network,
same projectors across candidates for a given K. Recompute expected scalar
from current Intact covariance, never reuse a historical expected value.

L=((median(PR_B-PR_I)-DeltaPR_data)/abs(DeltaPR_data))^2 +
((median(Expected-Observed)-Deficit_data)/abs(Deficit_data))^2.
Compute alignment consistently as fraction (or both as percentage points).
Tie if loss difference<=1e-12*max(1,abs(minLoss)), ascending alpha then beta.
Report every candidate/rejection, absolute model/data values, attainable
ranges and imperfect fit. Geometry is calibration, not independent prediction.
If no common feasible candidate, stop for review without relaxing criteria.

## Controls and movement QC after selection

Intact one-factor sweeps amplitudes[0 .05 .10 .20 .40]: vary cue state with
temporal=.10; separately vary temporal with cue=.10. Reference is standard
Intact(.10,.10), compared with selected Block(.10,.10). Report PR, observed,
expected, deficit and mean neuronwise within-target late-prep residual
variance in both raw and frozen-normalized units. No variance-selected
amplitude, no new prediction. Reuse identical.10 baseline instead of rerun.
Trial-split reliability: fixed first15/last15 within target, descriptive
PR/alignment differences, no alternative selection. No new held-out claim.

All4policies240trials/network deterministic postGO movement. Native arm,
speed=hypot(vx,vy), first positive peak/first saved20%-own-peak MO. Preserve
all trials. Flag nonfinite, peak<=1e-8m/s, first/last-sample peaks, missing
MO+0:100ms, and >=2local maxima above50% own peak separated>=20ms.
Describe these thresholds as QC, not phenotype exclusion. Report endpoint
dispersion about within-target mean and median target-pair centroid distance
relative to within-target RMS endpoint scatter as a degeneracy diagnostic.
Show fixed network1examples all8targets and4policies with thin trials,
within-target median speed and IQR; show ensemble QC distributions separately.
No selecting geometry using movement appearance or QC outcome.

## Statistics, outputs, validation and release

Network n10, targets/trials nested. Median +/- SE using frozen10000whole-
network bootstrap indices seed2026091000. Geometry-selected contrasts are
descriptive/calibrated, not confirmatory tests. Retain original Stage2 tests
unchanged on reused panels a,b; do not add tests for decoration or count grid
points/trials as independent. Separate MonteCarlo null SE and trialIQR from
network bootstrapSE. Independent trace/PR, activity-projection, QR-null,
resampling/SE and event/arm calculations. Baseline/draw/diffusion/indexing
checks before production. Fine-step checks use coupled existing Brownian
bridge seed319100000+target on predeclared network1targets1,5trial1;
relative state RMS<=1%,handRMS<=.001m. No tuning on failures.

Dedicated results/paper_ready, plots/paper_ready/{fig,png}, docs/paper_ready,
artifacts/manifests/paper_ready; no accepted output overwrites. Main a,b
reuse audited Stage2 R2 late-prep results; c editable two-function schematic;
d loss/feasibility and absolute fit. Supporting timing/geometry, noise-only,
movement/QC. No panel e or R2 regression. Arial/project16point axes,
skyblueIntact/vermillionBlock, distinct partial removals, explicit units.
Reopen every FIG, compare plotted arrays/errorbars, visually inspect PNGs,
native Notion publication with full legends/readback. Retain full evidence.
Run CodeAnalyzer newfiles, smoke/pinnedreference and protectedSHA256checks.
Classify scratch/duplicates before removal, preserve ambiguous evidence.
Only after all gates pass, one normal v3commit/push,safe mainFF/push,
directremote/local/tracking equality+cleanstatus. Update threepaperpages,
AgentInstructions,Log,Handoff,STARTHERE with actual outcome; stopreview.
