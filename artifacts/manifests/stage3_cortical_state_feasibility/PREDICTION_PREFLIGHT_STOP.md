# STAGE3-PREDICTION-VALIDATION-01 — analysis-authority preflight stop

Date: 2026-09-10. Status: STOP BEFORE IMPLEMENTATION/SIMULATION, pending
scientific clarification under section 7 of the current task.

## Authority and starting state

- Current Notion task revision: 2026-09-10T17:57:32.574Z.
- Manuscript: Main_text_v8, Google document
  https://docs.google.com/document/d/1ZMY8I_aalyKtAfdE4Sz_uoO4zE8v3W_E0d-_s0T09gI/edit
  (modified 2026-09-10T15:57:38.963Z), fetched directly through Drive.
- Read single-trial firing-rate estimation, neural population preprocessing,
  both prediction Methods, matched-PC and within-target controls, speed-axis
  diagnostics, and the corresponding neural/kinematic prediction Results.
- Active repository:
  E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model.
- HEAD, local main/v3, tracking main/v3 and both direct remote branches match
  c40e0eb74679a0122cb1e54c784c2e56946a5e14.
- Initial worktree/index clean; integrity check and normal fetch succeeded;
  main has no unique commits. No Git locks. Existing dangling-object notices
  are non-blocking; no unrelated repair was attempted.
- Confirmed existing biological raw evidence remains present (108 resume
  cache files plus the previously preserved parent n1 pair).

## Resolved directly from the current manuscript

Gaussian width is explicitly SD=30 ms, at 1-ms resolution. Protected
smoothing boundaries are GO for preparatory activity, movement onset for
early movement, and peak-speed minus50 ms for the pre-peak predictor.
Kernel mass crossing the boundary is discarded and the remainder renormalized.
Matched-PC control uses the SMALLER condition-specific >=75% count separately
within each epoch. These points do not require user clarification.

The task fixes 30 trials/target, primary s=.10 and sensitivities .05/.20,
common standardized initial/process draws, sigma=s*sqrt(2/tau), the four
policies, all frozen models and analysis windows. No uncertainty about these
settings is being used to reopen them.

## Material unresolved analysis details

### 1. Ridge candidate set and penalty convention

The manuscript specifies nested three-fold selection by pooled inner
prediction error, but does not supply the candidate regularization values
or whether the objective is summed SSE or mean SSE plus the penalty.
Their numerical meaning also depends on extra predictor standardization.
The active repository has only an unrelated Stage-1 fixed ridge coefficient;
it is not authority for this manuscript-matched trial regression.
These choices can materially alter selected shrinkage and held-out R2.

### 2. Multivariate R2 with leakage-free response PCA

The manuscript says epoch PCA followed by pooled held-out PC-score R2.
The task additionally requires no held-out response information in fitted
PCA. Outer-fold movement bases, means and >=75% retained dimensions can then
differ. Pooling those score columns as if they shared one coordinate system
is not valid without a specified scoring convention. Variance-weighted
pooled squared error, per-PC averaged R2, or reconstruction scoring in full
neuron space are distinct metrics. The manuscript does not state which
fold-local scoring/denominator convention to use.

### 3. Pooled speed dimension in within-target leave-one-out tests

The manuscript retains the speed dimension obtained from pooled targets for
the within-target LOO regression, without stating whether that dimension is
refitted after excluding each held-out trial. A full-data speed axis depends
on the held-out speed and would violate the task's explicit no-leakage rule.
The task's no-leakage rule is clear; the manuscript-matched implementation
needs the exact cross-fitting scope declared before outcomes. The same
training-only principle applies to neural task-plane axes.

## One proposed resolution package — NOT YET APPROVED OR EXECUTED

1. Fit ridge by mean squared error + lambda*||B||_F^2; unpenalized intercept;
   only frozen per-neuron scaling and training centering, no extra PC/neuron
   variance standardization. Lock 25 candidates logspace(-8,4,25), select
   minimum pooled inner validation SSE, choose the larger lambda on exact
   ties, and never extend the grid after boundary selections.
2. Fit centering, predictor/response PCA and any target-plane construction
   using training trials only, including refits in inner folds. Use each
   outer training movement basis for held-out responses. Define neural R2
   as 1 minus total held-out retained-score SSE divided by total squared
   held-out retained scores relative to their outer-training response mean,
   summed across folds/dimensions; no per-PC averaging or negative clipping.
   This explicitly uses a training-mean baseline and must be approved as the
   model scoring convention rather than silently called exact manuscript R2.
   Use the analogous pooled training-mean-baseline error ratio in physical
   x/y coordinates for position and in speed units for speed.
3. In every within-target LOO test, refit the pooled-target speed dimension
   from all training targets excluding that held-out trial, with nested
   ridge selection confined to those training data; then fit the scalar
   within-target regression on the remaining same-target trials. Refit the
   pooled target-plane construction excluding the held-out trial likewise.
   Full-data refits remain descriptive orientation diagnostics only, never
   predictors of their own held-out trials.

Alternatively, supply the exact current empirical analysis implementation
that resolves these points; it will be audited against the no-leakage task
requirements before use. This is a proposal, not a locked production plan.

## Actual work and stop boundary

No MATLAB, isolated-leak preflight, noisy trajectories, deterministic replay,
prediction fitting, numerical result inspection or figure generation ran.
No model, noise, trial-count, seed, window, regression parameter or previous
scientific asset was changed. Full asset hashing and the locked production
plan remain pending because implementation stopped at manuscript authority.
There is no prediction result, failed phenotype or noise failure to interpret.

Only this preflight-stop report is added locally. No staging, commit, push,
branch change, cleanup or history rewrite. Existing Stage-3 scientific pages
and figures remain unchanged. Agent Log, Agent Handoff, START HERE and task
execution status record the actual clarification stop, not completion.
Resume only after the material analysis choices are resolved; do not launch
the ensemble or choose among implementations using observed R2.
