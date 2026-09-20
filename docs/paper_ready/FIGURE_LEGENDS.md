# Paper figure candidates: full legends

Scientific review is pending. The completed selection is λ=10, α=0.5,
β_norm=0.5. Numerical audits passed; final publication and release are
documented by the publication receipt and Notion checkpoint, not implied
by this caption file alone.

## Main modelling (a-d; panel e is not generated)

**Cerebellar-dependent state setting and prospective correction: a calibrated
effective mechanism for preparatory population geometry.** (a) Late-preparatory
participation ratio (PR) from the frozen Stage-2 effort-penalty sweep. Increasing
lambda re-optimizes feedback with greater effort penalty while preserving
target-setting input; it is neither literal cerebellar block nor complete
feedback removal. (b) Reference λ=0.1 preparation projected onto the
same-epoch population subspace at each lambda, and its covariance-shaped
random-subspace expectation. Panels a,b reuse the audited current Stage-2
GO-100:10:0-ms arrays and statistics without recomputation or alteration:
reference full-window neuronwise SD without a source-unit floor, target
centering, pairwise common PC count strictly exceeding 95% variance, 1,000 null
draws and 10,000 whole-network bootstrap resamples. Thin points are 10 network
values; connected summaries are medians +/- bootstrap SE of the median.
The specific reference-preserving manipulation decreased PR and did not
produce below-null alignment, not an absence of every geometry change.
The unchanged planned paired tests give PR BH q=0.02734375 at λ=10 and
λ=100; the median paired PR differences from λ=0.1 are respectively
−0.0840562338551589 and −0.161395441390651. Observed-minus-expected
alignment remains positive at every tested non-reference λ (BH q=0.001953125
for each). These are the original seven-test families in
`results/stage_2/current/neural_geometry_r2/planned_tests.csv`, not new tests
of the paper-specific calibrated controller.

(c) Effective two-function cerebellar input to the unchanged recurrent
cortical network: sustained state setting b and prospective-error feedback
-L(x-xstar), with the same residual non-cerebellar stabilization u0 in all
component-removal policies. The decomposition does not assert two distinct
anatomical pathways. Frozen kappa0 values span 0.807817–0.923558 and were
chosen for a local leak-timescale stability margin, not fitted to the new
phenotype. L is the saved Kao-derived P/lambda in state coordinates, not a
new optimality proof for the residual nonlinear plant. All preparation inputs
end at GO. Achieved state, without reset, launches the same non-autonomous
Stage-1 movement generator and arm; movement-drive alpha_mov(t) is distinct
from geometry alpha.

(d1) Predeclared 6 × 6 alpha/beta geometry calibration using direction 1 in every
network. Crosses identify points not jointly feasible in all 10 networks and
the marked point minimizes the prescribed normalized squared-effect loss.
The two fitted effects are median-network Block-minus-Intact PR and
Expected-minus-Observed alignment, compared to exact empirical differences
of the pooled bars. No movement or prediction result enters selection.
(d2,d3) Absolute empirical and selected-model PR and alignment, showing
absolute mismatches rather than hiding them behind fitted effect sizes.
Experimental data come from the supplied FIG: pooled 1,048 + 3,824 motor-cortical
neurons, medians with SD across 1,000 trial-balanced resamples. Model quantities
are 10 network medians with 10,000 network-bootstrap SE, not the same uncertainty
estimator. Each frozen model has 200 rate units (160 excitatory, 40 inhibitory)
and eight targets. Model primary geometry uses native ReLU rates (no Gaussian filter),
30 independent trials per target, trial averaging before analysis, final
GO −100:10:0 ms, frozen per-neuron SD and frozen full-reference covariance bias,
K=15 and 10,000 covariance-shaped null draws. K=15 rank-degenerate candidates are
infeasible; adaptive strictly >95% common-K is a reported sensitivity. Prep
cue-state and temporal EM noise both equal 0.10 source-state units and end at GO.
Lambda is selected independently from sustained Q-error readiness, then
geometry is calibrated. These fitted population metrics are not independent
predictions. No new inferential family is used to decorate a calibrated fit;
original Stage-2 tests remain in their source table. Panel e is explicitly
reserved pending scientific review and is not computed.
The selected primary fit is imperfect: ΔPR=2.184920 ±0.053633 versus
2.645333 in the data; alignment deficit=23.612770 ±0.472751 percentage
points versus 16.802184. Absolute model PR is 3.463191 ±0.128573 Intact and
5.660113 ±0.082327 Block; observed/expected alignment is 62.821665 ±0.406929%
and 87.032437 ±0.386441%. The K=7 adaptive sensitivity does not retain the
below-null result. Thus the primary fitted alignment phenotype is PC-rule
dependent, not a robust independent prediction of the empirical geometry.

## Supporting calibration

**Timing, geometry attainability and component-removal time courses.** Timing
uses first post-cue saved 1-ms sample at which cue-normalized Q-weighted state
error is ≤0.10 and every later native 0.2-ms sample through GO stays ≤0.10.
Targets are summarized by median within each network, then networks by median.
Eligible ensemble readiness is 50–100 ms; closest to 75 ms selects one common
lambda from the fixed grid. This range is an approved modelling constraint,
not a universal physiological lower bound. Full-state-distance 90% settling
is reported separately and never substituted for functional readiness.
Loss map and attainable-effect plot retain every tested point, including
infeasible outcomes; no grid expansion or favorable post-hoc amplitude choice.
Separate PR-effect and alignment-deficit maps show the two coordinates of
the fit. Gray cells are not evaluated across all ten networks; crosses mark
points not jointly feasible. The PC-rule sensitivity panel retains the same
selected geometry: primary K=15 versus the predeclared common >95%-variance
count, K=7 in every network. With K=7, observed/expected alignment is
60.804919 ±0.602281% and 58.262624 ±0.547595%, and the paired deficit is
−2.373314 ±0.489876 percentage points. The below-null interpretation reverses.
K=15 captures 99.9153–99.9236% of Intact variance and 99.8307–99.8476% of
Block variance; numerical rank is valid, but high cumulative variance alone
does not establish robustness of alignment to the retained PC count.
Distance to xstar, distance to xB, cue-normalized Q error, trailing 100-ms PR
and alignment deficit show all four policies. Timecourse windows advance 10 ms;
pre-cue support is the frozen spontaneous baseline. Curves are 10 network
medians +/- network-bootstrap SE. All protocols retain the same residual u0
within each intact/block pair. Component removal is not a pure causal
separation of PR from orientation. Geometric calibration cannot establish
anatomical localization, global equilibrium uniqueness or neural predictability.

## Supporting noise-only controls

**Cue-state variability and temporal process noise tested separately.** Top:
vary s_init over [0, 0.05, 0.10, 0.20, 0.40] with s_temporal=.10. Bottom: vary
s_temporal over the same fixed set with s_init=.10. The cerebellar components
and mean controller input remain Intact throughout; same standardized draws,
30 trials/target, native-rate preprocessing and reference normalization.
Horizontal comparison is full Block at (0.10, 0.10); primary Intact reference
is (0.10, 0.10). Plotted metrics are final 100-ms target-mean PR, observed and
expected alignment against standard Intact, alignment deficit and within-
target residual neural variance (averaged neurons/late times/targets after
frozen normalization). Raw-unit residual variance is also in source tables.
Each curve shows 10 network values and network median +/- bootstrap SE.
No trial-level noise amplitude is selected by PR, alignment, residual variance
or prediction. High-amplitude abnormal outcomes and bounds are reported rather
than silently excluded. A black × marks any amplitude at which at least one
network fails a retained native rate/state/input bound; those points remain
in the curves and tables. No statement about all possible structured noise
mechanisms follows from testing this isotropic family. No new R-squared
analysis is included.

## Supporting movement and event QC

**Achieved noisy preparatory states drive unchanged deterministic movements.**
Rows show Intact, remove prospective feedback, remove b and full Block.
Network 1 is a fixed illustrative member, not selected for its behavior.
Target-colored paths and unsmoothed speed traces show all 30 trials for each
of 8 targets; thick paths/speeds are target-specific medians, never averages
across opposing targets. Speed shading is within-target trial IQR, not
network-level uncertainty. All 10 networks’ 2,400 trials/policy contribute to
event histograms; these trials are nested, not independent network replicates.
Target IDs T1–T8 correspond to −90°, −45°, 0°, 45°, 90°, 135°, 180° and 225°
in the frozen target registry. All four policies use common path/speed scales.
Hand paths are displayed relative to the unchanged home position (black +);
open target-colored circles mark the nominal 10-cm targets. This plotting
translation does not alter any saved trajectory or movement statistic.
Movement onset is the first saved speed sample reaching 20% of that same
trial's own positive peak. Histograms distinguish MO and peak time. All
trial-level values, near-zero (≤1e-8 m/s) / boundary peaks, large multiple peaks,
missing MO+0:100-ms windows, finite states/arm and input/rate bounds are retained
in QC tables. Endpoint dispersion is within-target RMS around the mean;
centroid separation/scatter is descriptive, not an exclusion rule. Geometry
was selected before looking at movements; no retuning or abnormal-Block
exclusion is permitted. Preparation noise ends at GO; there is no post-GO
noise, corrective input or reset. Numerical source evidence, not attractive
kinematics, determines validation. No prediction panel is run.
The final row shows own-trial peak-speed distributions in common bins,
mean within-target endpoint RMS and target-centroid separation relative to
within-target scatter. Endpoint and separation summaries use the ten
network medians with bootstrap SE; points identify network values. The
histograms retain every trial and are descriptive, not trial-level inference.

## Shared provenance

Analysis: analysis/paper_ready/paper_*.m. Renderer:
figures/paper_ready/paper_figures.m. Each output has an editable FIG and
matching same-array PNG under plots/paper_ready/{fig,png}/. Sources and
full-precision network tables: results/paper_ready/. Large required raw
evidence is in its cache/ subfolder, not a duplicate accepted model tree.
Locked plan, preservation/validation and publication/cleanup receipts:
artifacts/manifests/paper_ready/ and docs/paper_ready/PLAN.md. Final release
SHA is recorded only after verified push in Notion, never preclaimed here.
