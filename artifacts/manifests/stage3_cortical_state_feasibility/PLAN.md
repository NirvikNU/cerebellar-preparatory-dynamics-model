# Stage 3: predeclared implementation and sampling plan

Task STAGE3-CORTICAL-STATE-FEASIBILITY-01, current Notion instruction dated
2026-09-07 20:57:42 UTC. Starting checkpoint
302138aacac1c81132f57c2da3578e5b29494ffb; branch/upstream
v3-romano-hennequin/origin/v3-romano-hennequin. Bounded preflight found clean
worktree/index, no locks and local/tracking/direct-remote equality. Existing
ignored caches/logs/OS metadata remain untouched. Exactly four new component
pages under Stage 3, not an extra task database; the specification holds the plan.

## Scientific status and order

This is inverse design of a sufficient mechanism, not an independent prediction
of PR/alignment, unique explanation, learned policy or anatomical E/I circuit.
DERIVATION.md records the independent algebra and synthetic checks.
First hash all Stage-1 scientific/support assets, all completed Stage-2
code/configuration/results and figures. Generate and freeze only the new
Stage-3 intact reference. Then construct and screen states, simulate the fixed
map, select solely by geometry/admissibility, freeze the selected registry,
and only then evaluate movement. Never change Stage-1/2 numerical files.

## Gains, state dynamics and sampling

For each frozen network kappa=max(0,||W||2-1)+3, nu=3, held fixed throughout
the primary map. Conservative contraction rates are at least 20/s block and
40/s intact; Euler bounds are .996 and .992 on these frozen assets. Check
these bounds and local endpoint Jacobians, not just continuous-time poles.
Preparation: same spontaneous initial state, 500 ms; integration .2 ms,
saved summaries 1 ms, population samples 10 ms. State feedback acts on x.
uC=-f(xB)-kappa(x-xB); b=f(xB)-f(x*)+kappa(x*-xB);
uCB=b-nu(x-x*). Removing CB removes both b and feedback without changing uC.
At GO pass achieved state unchanged to the existing movement/readout/arm
functions and common drive. No target reset/post-GO correction. Arm/motor
output is gated off during preparation, as in Stage 2.

Reference trajectories/scaling are generated from the reduced intact identity,
then verified against the explicit paired inputs for selected solutions.
The exact x*-initialized frozen-generator trajectory is the movement-valid
comparison: load saved accepted trajectories where available; otherwise a
read-only frozen forward evaluation is part of the new Stage-3 comparator,
not a Stage-1 acceptance rerun or canonical writer. No calibration/retraining.
Require intact GO state relative error <=1e-7 and maximum hand discrepancy
<=1e-5 m against this comparator. Save comparator only under Stage 3.

Reference SD uses all eight target-by-time observations of GO -500:10:0 plus
target-specific kinematic-MO -50:10:450, overlap retained, before centering.
MO is first 1-ms hand-speed sample >=20% of its own positive peak. Stop if
reference MO/window unavailable. SD must exceed 100*eps(max(1,neuron max
absolute reference activity)); no source-unit floor/drop/SD import from Stage 2.
Apply unchanged scaling to block/ablations/directions. Center targets per time.

## State family, directions and fixed grid

SVD of the target-centered normalized x* rates defines U, ell and z. Numerical
rank: singular value >100*max(matrix size)*eps(max singular value), retaining
all directions above threshold, with reconstruction residual recorded.
Covariance uses sample divisor 7, Cov(z)=I; rank<=7. Do not drop neurons.
Use the intact target-mean rate vector for block baseline, no baseline offset.
An exactly zero proposed rate uses min(mean(x*,targets),0) for its internal
state; a positive rate uses x=r. Any negative rate is infeasible, never clipped.

Three direction sets/network, seed=2026090800+100*network+direction. Generate
one 200-by-d Gaussian matrix, weighted per row by target-mean-rate/SD, zero
where mean rate is exactly zero. Remove projection onto U; thin QR with
positive diagonal-R sign convention. Require d independent residual columns
and U'V~0. No redraws. Weighting supports distributed realizable activity,
not a movement-cost criterion. All 200 neurons remain in population analysis.

alpha=[.1 .2 .35 .5 .75 1]; normalized beta b=[.1 .25 .5 .75 1 1.25].
Actual beta=b*sqrt(T/d), rho=beta^2/alpha^2. Six by six points, 3 directions,
10 networks =1080 full-eight-target state protocols. Total normalized target
variance ratio is alpha^2+b^2; no pointwise amplitude renormalization.
Show contours .25, .5, 1, 2 and highlight equal variance 1.
Store alpha, normalized/actual beta, rho, and raw/normalized total variance.

## Admissibility assumptions (not empirical physiological bounds)

- Nonnegative proposed rates exactly; no clipping, baseline shifts or neuron removal.
- Both raw and normalized target-dependent covariance-trace ratios in [.25,2].
- Peak preparation rate <=3 times maximum new intact reference rate or x* rate.
- State norm per target <=3*max(1, largest intact reference/x*/spontaneous norm).
- Each input separately (uC, b, -nu(x-x*), uCB, total) has norm <=5*Iref;
  Iref=max(1,max over intact reference time/target of norm(-f(x*)-(kappa+nu)(x-x*)))).
  Record actual component maxima; cancellation does not exempt either component.
- Equilibrium relative residual <=1e-10; global Euler contraction <1.
- Terminal block distance to xB / max(1,||xB-xsp||) <=1e-4 for every target.
- Check full preparation trajectory rates/states/components at native steps,
  not only endpoints. Individual failures are recorded, not repaired.

Analytically evaluate every grid point first. Simulate every point passing
endpoint/rate/variance/input screen, even outside the sufficient theorem bound.
Thus the declared low-b/high-alpha outside-boundary points are included when
physically admissible; screen failures are explicitly not dynamically tested.
Save every mask and every failure reason. No grid expansion or limit relaxation.

## Null and finite-window criteria

Use new intact full-window covariance, Elsayed covariance-square-root-biased
unit-Gaussian/orth sampler. 10,000 draws, seed2026090900+network, cache by K;
separate settled C/T null eta_d and actual finite-prep C/top-K null, never mix.
Report draw SE and half-sample difference. Bound Monte Carlo deviation by
Hoeffding radius sqrt(log(2*10000/.01)/(2*10000)) for at most10,000 distinct
null means, family error .01; additionally reserve .005 alignment margin.
Use etaLower=max(0,etaHat-radius-.005) in the sufficient boundary. This is a
probabilistic certificate for a finite estimate, not an exact expectation.

Measured geometry is GO -100:10:0, [time*target]-by-neuron. PR from every
covariance eigenvalue; common K=max(KI,KB), each minimum strictly >95%.
Save both K, capture fractions, spectral gaps and actual covariance spectra.
Require PR_B>PR_I+1e-6 and observed AI<expectedHat-radius-.005 for finite
phenotype classification. AI is intact projected onto block, denominator
sum intact top-K eigenvalues. Report analytic-vs-finite PR/AI differences.
The certified feasible set intersects the analytical sufficient region,
physical/dynamic admissibility and these measured finite-window criteria.
Outside-bound points that meet measured criteria are reported separately;
failure of the sufficient bound does not prove impossibility.

## Primary and additional selection: before movement inspection

Primary: common grid point feasible in all10 networks at direction1, minimizing
abs(log(alpha^2+b^2)); ties descending alpha then ascending b. No use of
effect-size maxima, hand error or p values. If none, no primary; show this
honestly in Results, no network replacement or forced success panel.
Additional: at most3 solutions/network, one per direction in order1..3.
Direction1 uses primary ordering; direction2/3 maximize minimum Euclidean
distance in alpha/b normalized to their fixed grid spans from earlier samples;
ties use primary ordering. Missing feasible directions remain missing.
Save complete xB,uC constants,b,kappa,nu,U,V,z,scale and identities before
movement calls. Cache duplicate selected solutions rather than rerun them.

## Functional consequences and component removal

Early movement error: RMS Euclidean hand-position difference in millimetres
over the frozen comparator's kinematic-MO+[0:200] ms, using the same GO times
for both conditions, then average eight targets within network. No time warp
or exclusion due to incorrect/missing block onset. Report all eight reaches
and endpoint errors; nonfinite movement is an explicit functional failure,
not a reason to select another state. Geometry selection excludes behavior.

Four primary policies share uC: intact, remove b only, remove CB feedback
only, remove both. Simulate actual partial-removal dynamics; no assigned xB.
Diagnostics: terminal prep distance to x*, PR and expected-observed alignment.
For each actual prep covariance/common K, reuse the fixed intact null bias
but evaluate its correct intact covariance/top-K denominator.

Sensitivity at member1/direction1/primary only: U'V=.05I and .1I via
V_delta=sqrt(1-delta^2)V+delta U (orthonormal columns); no theorem claim.
Kappa margin factors .9 and1.1 (nu fixed): preserve selected state definitions
and primary metric, recompute actual intact trajectories/full covariance/null.
No sensitivity contributes new candidates or selected behavioral examples.
If primary absent these checks are not available, explicitly reported.
Native .2ms versus .1ms preparation at member1/primary: max relative curve
error <=.01, terminal relative error <=1e-4. No integration-step tuning.

## Statistics, figures and bounded execution

Networks are independent n=10; directions/solutions nested, not extra n.
10,000 whole-network bootstrap medians, seed2026091000; sample SD of those
medians is SE. Exact two-sided paired sign flips use all1024 signs and the
established 1e-12*max(1,|statistic|) tie tolerance. Two primary constructed
geometry tests (PR difference; observed-expected) form one BH family;
the primary early-movement error test is separate. Diagnostics and additional
solution summaries are descriptive; aggregate nested solutions per network.
No grid-wide significance tests, outcome-selected windows or p-value search.

Exactly four FIG/PNG pairs with prescribed names. Results1: prep distance,
member1 eight reaches, paired early error, secondary sampled-solution table.
Results2: finite prep spectra, paired PR, paired observed/expected AI.
Diagnostic1: actual alpha/beta map member1/direction1, sufficient-bound line,
physical/finite masks and constraint classes, contours, primary/sample marks;
generality frequencies over exactly30 network/direction sets, per-network
tables and small sensitivities adjacent. Diagnostic2: four actual component
policies for prep state error, PR, expected-observed alignment. Empty-region
outcomes use honest failure panels, not fabricated successful measurements.

Maximum1080 grid protocols,1220 total preparation protocols,600 movement
target rollouts (including comparators),3600s compute budget checked at batch
boundaries. Cache intact references and nulls; native preparations batched.
Only late geometry samples/GO states, distance curves and extrema are needed
for the grid; selected full definitions are retained. No repeated job polling
or blind restarts. A mathematical/preservation failure stops execution.

Independent checks: derivation, explicit policy identities, eigen/SVD PR,
neuron sentinel/normalization, PCA K, projection/trace/null, bootstrap/exact/BH,
stability/settling/components, unchanged release/arm, preservation hashes,
Code Analyzer on all changed MATLAB, FIG reopening/PNG visual review/native
Notion caption readback. One normal commit/push only after checks, then
local/tracking/direct-remote equality and clean status, log/handoffs and stop.
