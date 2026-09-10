# Biological-controller revision: locked execution plan

Task STAGE3-BIOLOGICAL-CONTROLLER-REVISION-01, Notion revision
2026-09-10T10:27:49.301Z. Starting checkpoint
166d2bbc15cb6a9f0b4d9b7c061e48b180b9b68b. This plan is recorded before
any revised preparation simulation. The read-only matrix preflight has run.

## Coordinates and derivation

Both stages integrate the same 200-dimensional internal state x, with
tau*dx/dt=-x+W*ReLU(x)+h+u, tau=0.15 seconds. No neuron permutation,
normalization transform, unit conversion, or dimensionality reduction occurs
between the frozen models. Stage 2 designs its CARE in normalized time t/tau
with A=W-I, B=I and state cost dx'*Q*dx; Q=N*sym(Qnative)/trace(Qnative).
Its nonlinear implementation applies its gain to rectified rates, but this
does not change the coordinates in which its CARE was solved. Inactive x*
coordinates exist in four networks: we explicitly do NOT equate rate and state
feedback globally or claim A is the exact local ReLU Jacobian there.

Reuse the exact saved lambda=0.1 P and Q from each Stage-2 network cache:
L=P/0.1, without resolving CARE or modifying Q. This is the state-feedback
analogue requested by the current contract, not a replay of the Stage-2
nonlinear rate-feedback law. It is optimal for the frozen all-active linear
design plant, not claimed optimal for the new residual-stabilized nonlinear
plant. Q is the frozen prospective-cost approximation, not a proof of exact
nonlinear future hand error. The latter remains a separate movement test.

For each of the 16 primary equilibria e (eight x*, eight xB), define
M(e)=-I+W*diag(e>0). Then kappa0=max(0,1+max_e max(real(eig(M(e))))).
The residual Jacobian is (M-kappa0*I)/tau, so its worst pole is -1/tau
when a positive shift is required. Check Euler poles at dt=0.0002 seconds.
The intact local Jacobian additionally subtracts L; do not assume that adding
a positive-semidefinite L guarantees stability for a nonnormal plant.

With f(x)=-x+W*ReLU(x)+h, set u0=-f(xB)-kappa0*(x-xB),
b=f(xB)-f(x*)+kappa0*(x*-xB), FB=-L*(x-x*).
Expanding f+u0+b+FB gives f(x)-f(x*)-(kappa0*I+L)*(x-x*).
Expanding f+u0 gives f(x)-f(xB)-kappa0*(x-xB).
Check these identities at deterministic off-equilibrium states, both exact
equilibria, finite-difference Jacobians, CARE residual, feedback sign and
unchanged P/Q. Save all local spectra and L eigenspectrum, numerical rank,
95%-squared-gain subspace dimension, and Q trace captured by that subspace
versus an equal-dimensional isotropic fraction. Do not call all nonzero gain
directions prospective-potent.

## Execution order and fixed gates

1. All ten frozen controllers receive algebra/coordinate/local-stability
   checks before simulations. No model or reference is fitted or recomputed.
2. Primary geometry remains registry direction 1, grid 5, alpha=.1,
   betaNormalized=1 in every network; preserve xB/U/ell/Z/V/scaling exactly.
3. Evaluate primary intact/block pairs in ascending network order, 500-ms
   preparation from the same spontaneous state; Euler dt=.2 ms, save1 ms.
   Record native states/extrema for an independent reduced-equation residual
   audit. Stop at the first material physical/dynamic failure, before further
   networks, grid, component-removal simulations, null analysis or movements.
4. Keep the original nonnegative proposed-rate, raw/normalized variance
   [.25,2], frozen rate and state envelopes. Retain the original terminal block
   settling criterion max_q ||xGO-xB||/max(1,||xB-xsp||)<=1e-4. Minimal local
   stabilization does not imply this finite-time criterion; its failure is
   reportable, never a reason to increase kappa0 or lengthen preparation.
5. Update input decomposition only: u0, b, FB, b+FB, total, each separately
   bounded by 5*Iref. Iref=max(1,maximum new intact total-input norm over native
   times/targets), with the factor fixed before simulation. Record delivered
   and counterfactual component norms explicitly. Do not conceal cancellation.
6. The predecessor's near-zero intact endpoint/hand tolerances tested its
   isotropic settling claim; they are not imposed as exact predecessor-output
   equivalence on a deliberately revised controller. Instead save actual GO
   errors/readiness and test the requested independent movement consequence
   only after primary physical and population acceptance. No state reset.

## Analysis retained if physical gates pass

Use frozen Stage-3 neuron SD and full-window null covariance; no new scaling,
direction, seed or null bias chosen from outcomes. Prep population window
GO -100:10:0; neuron-preserving [time,target]-by-neuron matrix after per-time
target centering. PR uses every eigenvalue; common K is the larger minimum
strictly >95%-variance count. Intact projected onto block with intact top-K
eigenvalue-sum denominator. Reuse frozen covariance-biased null projectors
when available, else identical 10000-draw seeds 2026090900+network; evaluate
the new intact covariance. Retain PR margin1e-6 and the existing Hoeffding
radius plus .005 alignment margin. If either fails, stop without reselection.

Only after all primary checks pass, recompute controller-dependent quantities
on the existing 6x6x3x10 map with unchanged geometry and limits. No new points.
Achieved GO states enter the unchanged drive/readout/arm; early error uses
frozen comparator MO+[0:200] ms, RMS hand error in mm then target mean.
Require nontrivial movement consequence without outcome-based parameter
choices. Network n=10, bootstrap10000/seed2026091000, exact paired sign flips,
two geometry tests one BH family, movement separately; descriptive diagnostics.

Four policy order: intact [1,1], remove feedback [1,0], remove b [0,1],
block [0,0], where flags are [b,FB]. Save full state distances to x*/xB,
E_Q=(x-x*)'*Q*(x-x*), cue-normalized E_Q (undefined for degenerate cue),
and all component norms per target at1 ms. Report first50/90% reduction
crossings (no interpolation) in E_Q and unsquared full-state distance, plus
50/100/200-ms values. Crossings are descriptive and never used for selection.
Reuse validated controller-free -700:-500-ms baseline. Diagnostic2 common
-600:0 GO axis, cue-500; trailing100-ms PR/alignment every10 ms, undefined
zero-covariance pre-cue cells masked. Median across networks with bootstrap
SE, four distinguishable policies; five specified time-course panels.

## Preservation and stop behavior

New candidate evidence stays under cache/biological_revision and
results/stage_3/current/biological_revision. No canonical overwrite before
validation. Preserve all prior controller code, outputs and figures on failure.
BIO_INPUTS_BEFORE.csv hashes718 existing files; PROTECTED_BEFORE.csv protects
233 Stage-1/2 files. Run Code Analyzer on added/changed MATLAB only, independent
saved-output checks, and after hashes. A scientific stop is documented in the
current instructions, scientific pages and log/handoffs; no success checkpoint,
canonical figure replacement, full-grid run or automatic downstream work.
On success only, finish four figure pairs, native publication/readback,
focused cleanup and the authorized normal commit/push and safe main fast-forward.
