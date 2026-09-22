# Locked panel-e and full-space RRR plan

PAPER-MODELLING-PANEL-E-PREDICTION-01, 21 September 2026. Starting HEAD
70fff703f8fd3074bef62ca9954a03bef50e4d99, clean v3 worktree/index; local main,
both tracking refs and both direct remote branches agree. Current Notion task
read at revision 2026-09-21T10:50:39.871Z. Main_text_v8 Drive source
1ZMY8I_aalyKtAfdE4Sz_uoO4zE8v3W_E0d-_s0T09gI, modified
2026-09-13T18:12:41.246Z, read directly. No prediction outcomes inspected.

## Immutable inputs and preservation

All existing files remain byte-for-byte unchanged. New work is isolated in
prediction subdirectories of analysis/paper_ready, figures/paper_ready,
docs/paper_ready, results/paper_ready, results/paper_ready/cache and
artifacts/manifests/paper_ready. New FIG/PNG names use prediction-specific
paths. No old figure, summary, controller or helper is overwritten.
No staging/commit/push: the current top task does not authorize these.

Lambda10, alpha .5, beta_norm1, direction1, saved kappa0/L/Q/xB, all ten
networks, eight targets and thirty trials per target remain frozen. Initial
and temporal noise amplitudes .10; same saved seeds and draw order. No noise
or preparation inputs after GO. No reset. Reuse saved Intact preparation;
reconstruct only missing preparation series for the other three policies and
movement neural series for all policies. Validate against saved initial/GO,
late rates, mean rates, native extrema/spot transitions, movement torque and
final state before fitting. Existing arm/events are reused, not recomputed
to select trials. All flagged trials remain included.

## Preprocessing and primary prediction

Time x neuron x target-major trial arrays, 240 trials, 200 neurons. Gaussian
SD30ms, support +/-150ms at1ms, renormalized at boundaries, exactly as the
validated Stage3 prediction implementation: Prep cannot use post-GO samples;
early movement cannot use pre-MO samples. Frozen ref.scale, no SD floor or
second standardization. Remove equal-weight cross-target invariant at each
aligned time, then average GO -100:10:0 and each trial's MO 0:10:100.
Full balanced ensemble PCA separately per epoch/policy, minimum >=75%.
This is manuscript-matched, not strictly inductive fold-wise PCA.

Reuse stage3_prediction_folds and stage3_prediction_ridge unchanged. Outer
10 trials/target/fold; inner7/7/6. Penalties logspace(-8,4,25), objective mean
training SSE + lambda*Frobenius norm squared, unpenalized intercept. Inner
pooled SSE selects first minimum; pooled outer R2 uses full response mean SST.
Retain negative values. Matched-PC uses minimum paired K separately per epoch.
100 global response permutations, seed322000000+10000*network+100*shuffle,
same across policies, complete nested selection rerun, median shuffle R2 floor.
No behavior, speed-axis, movement-end or other prediction functions invoked.

## Secondary RRR implementation declarations

Full200-neuron X and Y, no PCA reduction. Candidate ranks1:200 inclusive;
ranks above training matrix rank saturate naturally, never selected by
inspecting outcomes. Ridge rank constraint is solved by augmented-design
least squares: A=Xc'Xc+lambda*I, B0=A\(Xc'Yc), project B0 onto the top-r
right singular subspace of A^(-1/2)Xc'Yc. This minimizes penalized SSE subject
to rank(B)<=r; it is not unweighted truncation of B0.
Ten target-stratified fold assignments: repeat1 is the primary fixed split;
repeat2..10 use the same fold generator with network argument n+100*(rep-1),
equivalently seed offsets1,000,000*(rep-1). Same folds for all ranks/policies
and shuffles. Same penalty grid/tie rule, select separately per rank.
The manuscript equation was recovered directly from native DOCX equation XML:
min rank(B)<=m [||Y-XB||F^2 + lambda||B||F^2]. RRR therefore uses SUM-SSE
penalty scaling, unlike the explicitly retained validated panel-e MEAN-SSE
implementation. This distinction is locked before outcomes, not concealed.
Mean pooled R2 and sample SD/sqrt(10) across repeats. Peak is first maximum
mean R2. Threshold=peak mean minus SE at that peak; predictive rank is first
crossing, linearly interpolated between adjacent integer ranks; if rank1
already qualifies return1. Do not extrapolate to an unfit rank0. Each of the
same100 fixed shuffles repeats the entire ten-repeat nested procedure;
report median across shuffle-specific peak mean R2. No balancing resampling.
These numerical implementation declarations are fixed before outcomes.

Execution-only resource preflight: the installed Parallel Computing Toolbox
is licensed and the existing local Processes profile permits20 workers.
Use20 production workers and12 audit workers, without editing the profile.
The initial24-worker implementation request was corrected before RRR
production; no rank, fold, shuffle, seed or scientific parameter changed.

Execution-only recovery, 21 September 2026: the Processes pool failed during
worker startup before production RRR fitting. Preserve STOP_RRR.json. A
20-worker Threads pool starts successfully, but V7.3 MAT loading is not
supported inside thread workers. Production already loads on the client;
the independent audit now preloads its same immutable evidence on the client
as well. Only numerical calculations use the thread pool (20 production,
12 audit). A serial-versus-thread full-rank fit identity test is required
before the retry. No scientific grid, seed, fold, estimator, criterion,
result or completed primary calculation is changed or rerun.

The first thread production attempt exposed a parfor input-slicing defect
before any case was saved: the conditional shuffle-minus-one expression
requested column0 during input distribution. An explicit identity column
followed by the unchanged100 frozen permutations removes this invalid
index without changing a trial pairing. The exact two-correspondence batch
preflight (all10 repeats and200 ranks) passes, including zero serial-fit
R2 discrepancy. Preserve both failed-start receipts; no outcomes drove the
repair. See history/EXECUTION_RECOVERY.md and BATCH_PREFLIGHT.json.

## Inference, figures and validation

Network n10; reuse frozen10000 whole-network bootstrap indices. Separate
families for panel-e R2, RRR rank and RRR peak R2, each exactly three paired
policy-minus-Intact contrasts, exact2^10 sign flips of mean paired difference
and BH within that family. Controls descriptive. Report paired relative
Block R2 change without clipping, alongside empirical reductions43.6% N and
29.6% T; no fit/scaling. All network counts/captures/results retained.

Panel e: four policies, paired network values, median+/-bootstrap SE, empirical
context. Supporting output matched counts/R2 and100-shuffle distributions.
RRR Extended Data: fixednetwork1 rank curves+repeat SE+peak/one-SE annotations;
all-network paired rank; all-network peak R2+shuffle floor. Reopen FIG object
arrays/error bars and inspect every PNG. Independently recompute PCA, seeds,
splits, penalty selection, predictions and R2 using direct normal equations,
matched-PC/shuffle, RRR objective/rank criterion and statistics. Stop on
material discrepancies; do not retune or overwrite evidence. Publish verified
figures/results and update existing Notion management/paper pages, then stop
for scientific review. Historical prohibitions are not current execution
authority; accepted prior outputs remain unchanged.
