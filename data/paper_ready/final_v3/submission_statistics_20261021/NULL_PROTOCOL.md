# Prespecified shuffled-control calculation — 22 October 2026 execution

Authority: the 21 October active Notion task. Source publication commit: 7977e16de7c406210b6df7dd44d8e457670858d2. No published model result or figure may change.

## Procedure and source

Main_text_v13 was fetched read-only. Its neural-prediction Methods permute preparatory/movement trial correspondence within condition, pooled across targets. The retained `analysis/stage_3/stage3_prediction_case.m` implements this as a global 240-trial response permutation; within-target permutations are used for the separate behavioral speed control. Therefore this neural null uses global response permutations, independently by network, shared across policies and noise cases. Every permutation is a bijection of all 240 trials and preserves the complete target distribution; no trial exclusion or conditioning on success is used.

Use the saved exact 240-by-200 preparatory and movement feature matrices from `noise_6gh_20261019/analysis/`. Recompute the original condition-specific PCA75 and the unshuffled nested fit and require exact agreement with saved R2, SSE, SST, ranks, folds and trial counts before accepting null results. Existing preprocessing/PCA is applied across the condition's complete trial ensemble, as in the frozen code and original Methods; ridge coefficients and penalty selection use only their respective training folds. This preserves the original estimator rather than introducing new training-only PCA or changing published predictions. The preprocessing convention is disclosed as a limitation. No new neural simulation is needed when these saved inputs pass validation.

The null repeats the complete original outer three-fold / inner three-fold ridge selection over 25 penalties `logspace(-8,4,25)`, retaining the first minimum. Shuffling occurs before this complete regression refit. No held-out responses enter coefficient fitting or penalty selection, and each original response occurs exactly once in a permutation. Negative R2 is retained. The observed and null use identical frozen folds and source features.

## Seeds and Monte Carlo precision, fixed before inspecting any null output

For network n and repeat r, create MATLAB `RandStream('mt19937ar','Seed',352000000+100000*n+r)` and use `randperm(stream,240)`. Seeds are distinct for all networks and repeats up to 8000. Use the same permutation for all cases within a network/repeat, preserving matched comparisons. Control's shared 0.05/0.05 anchor is computed once and reused in both sweeps: 150 Control cases plus 80 temporal-Block cases, 230 distinct cases total.

Initial planned repeats: 2000 per case. All repetitions and all cases are retained. For each of the three requested summaries, compute per-case median over repeats, per-network median across eight amplitudes, then mean and sample SEM across ten network medians. Report between-network SEM separately from Monte Carlo error.

Precision gate: compare the first and second halves, the full set and four disjoint equal-size batches. Full and half estimates must round identically to three decimals for both the grand mean and its between-network SEM. The Monte Carlo SE estimated as sample SD of the four batch-level summary estimates divided by two must be below 0.000125, for both reported mean and SEM. If this fails, append the next prespecified repeats to reach 4000, then 8000, retaining all earlier draws and using the same rule. If precision remains unresolved at 8000, stop and report; do not choose seeds or omit cases. This extension depends only on numerical precision, not significance or favorable null levels.

## Implementation and validation

Compact committed inputs must contain the exact original feature matrices, target/trial IDs, frozen folds and unshuffled reference statistics, with per-file source hashes. Reproduction must not read ignored raw caches. Preserve complete per-repeat R2, SSE, SST, selected penalties and inner-validation loss grids in compact source MAT files, plus full-precision case/network/summary CSV and JSON tables, seeds, permutations and code.

A sufficient-statistic calculation of inner squared errors may reuse predictor factorizations, as already permitted by `pf_ridge`, but must evaluate the same complete nested regression. Before use, compare it against the unmodified `pf_ridge` on 32 fixed permutations for network 1 at baseline Control, maximum initial-noise Control, maximum temporal-noise Control and maximum temporal-noise Block. Require identical selected penalty indices, relative SSE/SST/inner-loss discrepancy below 1e-12, and R2 discrepancy below 1e-12. Independently check a fixed 16-permutation subset in every case. No tolerance is applied to source identity or unshuffled baseline preservation. Every permutation's held-out SSE is computed directly from its predicted and actual responses, not inferred from the inner-loss shortcut.

Run a small fixed smoke batch before the full calculation and record runtime, peak dimensions and expected output storage. Subsequent clean candidate and fresh GitHub-clone checks reproduce all 230 cases and the same precision decision from committed inputs and seeds, plus all existing publication acceptance checks. Figures remain unchanged.
