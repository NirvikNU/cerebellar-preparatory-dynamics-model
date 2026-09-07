# STAGE2-KAO-ALIGNMENT-VALIDATION-01

Predeclared 7 September 2026, before new metric calculation. Authority: current
Notion task updated 10:30:32 UTC. Git preflight: no locks; HEAD, tracking and
direct remote equal 4938fe927b59a04322f018d5e8742d9047213c02 on
v3-romano-hennequin. All 29 prior manifest hashes match; 30 staged files and
the untracked checkpoint-stop receipt are preserved. No simulations.

## Source audit and fixed choices

Pinned source HEAD is 40077d2da16e68ab2ab2cff59ec692b97315980b. Its retained
OCaml implementation supplies no Fig. 6 population-analysis routine.
Kao et al., Neuron 2021, retained PDF pp. 10, 28, 29: Figure 6C and Eq. 57
define Prep covariance projected onto Move PCs, minimum K reaching 80% Prep
variance, and a covariance-constrained control across both task epochs.
The prose immediately before Eq. 57 reverses the direction verbally; the
equation, variable definitions, main text, and current task agree on Prep
projected onto Move and are followed here. PDF p. 28 defines model MO as
100 ms after preparatory-input removal for model/data comparisons.

Use reference lambda=0.1, all ten networks and eight targets. Cue=GO-500 ms.
Prep cue 150:10:450 = GO -350:10:-50 ms; Move model-MO -50:10:250 =
GO 50:10:350 ms. Endpoints included: 31 observations per target per epoch.
The two epochs together are the full task covariance for this comparison,
not the manuscript full-reference window or intervening unanalysed time.

Current task explicitly requires Churchland range+5 soft normalization.
No more specific model range horizon/cadence is supplied by the retained
source. Model-specific choice: take each neuron's max-minus-min across all
eight targets and both 31-sample epochs, before centering, add exactly 5
source-rate units, and divide both epochs by that one vector. No SD scaling,
floor, unit conversion or dropped neurons. Deterministic model rates are
sampled directly; no spike-estimation Gaussian smoothing is applied.
These declared model choices preclude claiming exact numerical replication.
Subtract each neuron's across-target mean at each time in each epoch.
Storage is time x neuron x target x lambda; permute selected epoch to
time x target x neuron before reshaping to observations x neurons.

PCA separately; minimum Prep K with cumulative variance >=0.8 determines
both numerator and denominator. No movement-derived K or >95% rule.
AI=trace(Dmove' Cprep Dmove)/sum(top K Prep eigenvalues).

Elsayed sampler audit:
https://github.com/gamaleldin/rand_subspaces/blob/master/sample_rand_subspaces.m
uses U*sqrt(S), Gaussian columns normalized to unit length, then orth.
The shared stage2_null implements the same mathematical sampler, with
deterministic streams instead of rng shuffle. Use the centered, soft-scaled
Prep+Move covariance; fixed 10,000 draws, seed 20260908+network index, same K
and Prep denominator. Expected AI is their mean. Report per-network Monte
Carlo SE and half-draw agreement; neither is a tuning knob. Independently
check the sampler using QR of the same covariance-biased draws.

Network n=10. Median +/- sample SD of 10,000 bootstrap medians, shared
resampling matrix seed 20260909. Exact two-sided paired sign flips of
observed-minus-expected, all 1024 patterns with the established tolerance.
This single predeclared validation test is reported raw, not added to the
existing seven-test families. Paired effect SE is bootstrapped separately.
Kao Fig. 6 uses across-network SD; project presentation retains median +/-
bootstrap SE, explicitly not an exact replication of Kao's error bars.

## Outputs and validation

New standalone run_stage_2_kao_validation; new results under
results/stage_2/current/kao_alignment_validation; new matching figure pair
result_4_kao_prep_move_alignment in plots/stage_2/{fig,png}.
No existing code, five figure pairs, or numerical outputs need replacement.
Independently check normalization/centering with explicit neuron/target loops,
index sentinel, SVD vs covariance PCA/K, direct projection vs trace, QR null,
bootstrap/sign flips; recheck all protected Stage-1 hashes, cache hashes and
prior staged manifest hashes. Code Analyzer only new/changed MATLAB files;
reopen new FIG/PNG and visually inspect. Clean active Notion narrative,
preserve all prior run-log entries. One combined normal commit/push after
validation, triple SHA/clean-status verification, log/handoffs, then stop.
