# Locked prediction-validation plan

STAGE3-PREDICTION-VALIDATION-01, Notion revision 2026-09-10T20:29:09.453Z.
Locked before noise preflight, production or prediction outcomes. Starting
checkpoint c40e0eb74679a0122cb1e54c784c2e56946a5e14. Main_text_v8 was read
from Drive, revision 2026-09-10T15:57:38.963Z. The earlier preflight-stop
proposal is historical; the Notion binding resolution supersedes it.

## Preservation and scientific invariants

PREDICTION_INPUTS_BEFORE.csv protects 866 existing scientific/code/evidence
files including ignored caches. No existing model, result, figure or seed is
overwritten. Use only the active E: repository and accepted network files.
Ten networks, eight targets, alpha=.1, normalized beta=1, direction1, saved
primary xB, kappa0, Q/P/L, b, lambda=.1, initial states, movement drive,
readout and arm remain frozen. Four policies retain the identical residual
u0=-fB-kappa0*(x-xB): Intact=u0+b-L*(x-xstar); remove feedback=u0+b;
remove b=u0-L*(x-xstar); Block=u0. All preparation inputs end at GO.

## Stochastic trial generator and numerical gates

Thirty trials per target; primary s=.10, sensitivities .05 and .20. Every
network/target/trial uses MATLAB mt19937ar seed 310000000+10000*network+
100*target+trial. Draw eta0 (200x1), then standardized process normals in
neuron-by-native-step order. All policies and all amplitudes reuse exactly
these draws; no outcome-dependent reseeding. xcue=xsp+s*eta0. EM update is
xnext=x+(dt/tau)*F(x)+s*sqrt(2*dt/tau)*eta. Native dt=.0002 s, tau=.15 s,
saved dt=.001 s. Continue noise over the complete frozen movement horizon;
no additional arm/readout/target noise. Cache double-precision saved states,
rates derivable by ReLU, hand trajectories, trial identity/events, native
extrema and exact seed metadata separately from pre-existing evidence.

Preflight, without fitting any prediction, is mandatory before production:

1. Isolated leak: seed319000001, 20000 independent stationary initial draws,
   2-second evolution at dt=.0002, s=.1. Check sample final SD against EM
   theoretical SD s/sqrt(1-dt/(2*tau)) within 2%; check lag-10-ms correlation
   against (1-dt/tau)^50 within .02. Independently check the exact diffusion
   variance identity sigma^2*dt=2*s^2*dt/tau to floating-point tolerance.
2. Repeated seed construction must give bit-identical eta0/process draws
   for all four policies; different trial IDs must differ. Same standards
   rescaled at all s; no policy identifier enters a noise seed.
3. Deterministic s=0: network1, all eight targets and all four policies,
   entire preparation and movement. Compare prep states and GO with saved
   biological-controller evidence; compare movement with the frozen source
   movement/arm routines, max absolute numerical discrepancy <=1e-10.
   These are bounded validation replays, not canonical-output writers.
4. Stochastic step check: network1, targets1 and5, trial1, all policies and
   all three s, full horizon, dt .2 versus .1 ms. Couple Brownian increments
   with a seed319100000+target Brownian bridge: each pair of fine normalized
   normals is (coarse+bridge)/sqrt(2), (coarse-bridge)/sqrt(2).
   At common saved times require state relative RMS <=1% (denominator
   max(1,RMS fine state)), and hand-position RMS difference <=1% of the
   frozen .1-m target radius. These are numerical checks, not R2 criteria.
5. Check all native rates and state norms against the unchanged saved
   reference rateLimit/stateLimit; no nonfinite values. Apply the same
   checks in production. Check event windows. A failed level/case is
   retained and reported, never replaced or tuned; material failure stops.

## Events and preprocessing

For each trial, hand speed=hypot(vx,vy), using the frozen arm velocities.
MO is first saved speed >=20% of its own peak; first maximum is peak time.
Hand position at peak is physical arm x/y. Verify all windows exist.
Use ReLU rates, Gaussian SD30 ms at saved 1 ms with support +/-150 ms
(five SD, renormalized at protected boundaries). Prep smoothing never uses
post-GO samples; early-movement smoothing never uses pre-MO samples;
prepeak smoothing never uses samples later than peak-50 ms. Include available
surrounding samples up to these boundaries, not only the averaging window.
Divide each neuron by the existing frozen Intact-reference ref.scale, no
source-unit floor and no second standardization. Remove across-target
condition-invariant activity at each aligned time within policy; exact
balance makes this the mean of eight target means. Arrays explicitly retain
time x neuron x trial order. Sentinel tests prove neuron identity.
Average GO -100:10:0, MO 0:10:100, and peak -150:10:-50 ms respectively.

## Prediction estimands and fixed CV

Full balanced ensemble features are authorized manuscript replication,
not strictly inductive fold-wise feature learning. Separately center/PCA
prep and response once per network/policy/s; use the smallest count reaching
75% variance. Matched-PC control uses the smaller paired condition count
separately in each epoch, fixed before CV, reporting both paired estimates.

Use one deterministic target-stratified three-fold outer partition: permute
30 trial IDs within target with seed320000000+10000*network+target, allocate
10/target/fold. Inner folds stratify the 20 remaining trials using seed
321000000+10000*network+100*outerFold+target (counts7/7/6). Identical folds
across policies/s; no repetition selected from results. Ridge objective is
mean training SSE + lambda*||B||F^2, with unpenalized intercept; candidates
logspace(-8,4,25), ties first minimum. Inner pooled validation SSE selects
lambda independently in each outer train set. Save split IDs, losses,
selected lambdas, coefficients, actual and out-of-fold predicted responses.
R2=1-pooled SSE/pooled component-mean SST; never clip or average component R2.

Hand plane: full-ensemble target-mean prep PCA >=95%, sequential instructed
target x regression, project into its neural null, then y regression.
Normalize orthogonal axes, keep fixed for pooled outer-three-fold OLS and
separate within-target leave-one-out OLS. Average eight within-target R2s.
Peak speed: full-neuron nested ridge primary. Unit-normalized outer-training
weights project held-out activity for the pooled captured-variance fraction.
Full-condition speed dimension uses the grid candidate minimizing summed
inner-validation SSE over the three fixed outer-training searches (the same
nested-CV selection evidence), then refits all balanced trials. Keep this
single dimension fixed for within-target leave-one-out OLS and orientation.
Repeat both behavioral procedures using the prepeak epoch without changes.

Use 100 fixed permutations, seed322000000+10000*network+100*permutation
(identical permutations across policies/s). Neural chance globally permutes
response correspondence, preserving exact target counts, then reruns nested
ridge. Speed-axis orientation uses squared cosine between unit weights;
shuffle speeds within target, refit with the same selection procedure,
and report observed and mean expected alignment for each lesion/Intact pair.
Permutations quantify chance, not independent network replication. Report
all noise sensitivities and secondary controls, without selecting a result.

## Statistics, figures, audit and completion

Independent unit n=10 networks. Median +/- bootstrap SE uses the existing
10000 whole-network bootstrap indices. Primary lesion-minus-Intact contrasts
for neural, hand and speed R2 give nine exact 2^10 paired sign-flip tests
(absolute mean paired difference), with one BH family. No other primary
tests. Full Block strongest deficit and movement-control preservation are
hypotheses, not acceptance criteria. Negative, near-zero/one and reversed
order outcomes remain unchanged.

New Results Figure3 shows three primary metrics plus two within-target
supporting panels. Diagnostic Figure3 shows all noise levels and matched-PC
control; Diagnostic Figure4 shows chance, prepeak controls and speed-axis
checks. Preserve all existing four FIG/PNG pairs. Consistent four-policy
colors, network points and median/SE; .10 clearly primary. Save/reopen FIGs,
inspect every PNG and audit plotted values. Independently recompute events,
arm steps, preprocessing/PCA, regression/splits/R2 and all uncertainty/tests
from saved outputs. Run Code Analyzer only new/changed MATLAB files.

Compact new results: results/stage_3/current/prediction_validation/;
raw new evidence: results/stage_3/current/cache/prediction_validation/.
Update existing Stage3 scientific pages without replacing current biology;
append actual run status to Agent Log/Handoff/START HERE. After successful
validation/preservation/publication, one normal v3 commit and push, safely
fast-forward main only if no unique commits, and verify all local/tracking/
direct-remote refs equal plus clean status. No force/history rewrite. Any
material implementation or scientific validation failure stops before
checkpoint. Stop for scientific review; no tuning or further extension.
