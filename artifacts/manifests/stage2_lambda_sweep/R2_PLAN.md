# STAGE2-LAMBDA-SWEEP-01-R2 — bounded neural-geometry revision

Authority: current top Notion Agent Instructions, updated 2026-09-07 08:34 UTC.
Starting local/tracking/direct-remote checkpoint:
`4938fe927b59a04322f018d5e8742d9047213c02`; clean worktree/index,
`v3-romano-hennequin` / `origin/v3-romano-hennequin`, no packed-refs.lock.

## Scope and implementation order

1. Audit all ten existing deterministic caches, their original SHA-256 hashes,
   kinematic onsets for all 640 movements, reference SDs and requested windows.
2. If all prerequisites pass, recompute only the three R2 neural-geometry
   analyses, using the same network resampling/test conventions.
3. Independently validate neuron indexing, PR, common-K captured variance,
   projection alignment and uncertainty; replace only Results Figure 3 and
   Diagnostic Figures 1–2. Reopen/review the three FIG/PNG pairs.
4. Update affected Notion specification/summary/results, then make one normal
   revision commit/push after checks pass, verify equality/clean status, log
   the actual outcome and stop for scientific review.

The existing hierarchy is retained; no extra task database/pages are created.
Stage-1 assets, Stage-2 controller/cache/configuration, Fig. 4F analogue,
prospective-error values and Results Figures 1–2 are protected. No simulations
are planned; cache inadequacy must be documented before any bounded replay.

## R2 indexing and numerical conventions, fixed before analysis

Cached neural rates are time x neuron x target x lambda. Time is GO -500:598 ms;
cue is GO -500 ms. Cached hand state is time x [x,dx,y,dy] x target, starts at
GO 0 ms and contains the arm's additional terminal sample at 599 ms. Speed is
hypot(dx,dy), in m/s; onset is the first saved 1-ms sample at or above 20% of
that trajectory's positive peak speed, preceded by a subthreshold sample.
No interpolated/subsample crossing or GO=MO assumption is introduced.

Reference normalization uses concatenated GO -500:10:0 and target-specific
kinematic MO -50:10:450, all eight targets, lambda 0.1 only. Overlap is retained.
Sample SD is computed before target centering from a neuron-preserving
(time x targets) x neurons matrix. There is no SD floor. Finite/nonzero SDs
must exceed 100*eps(max(1, maximum absolute reference activity for that neuron));
this is a numerical-degeneracy rejection check, never a replacement scale.
Any rejected neuron is a stop condition, not permission to drop neurons.
The same reference SD vector is applied to every lambda. Target centering
is performed at each aligned time within each condition/epoch, including
target-specific MO-aligned matrices, not on an unaligned trajectory first.

Diagnostics use GO -100:10:0. Results Figure 3 uses reference-only cue
150:10:450 (GO -350:10:-50) and kinematic MO -50:10:350.
For each comparison K=max(minimum K1 capturing strictly >95% variance,
minimum K2 capturing strictly >95% variance). The same K is used for the
reference denominator, comparison numerator and covariance-biased null.
The reference full-window covariance uses the same aligned/normalized/
target-centered concatenation as normalization, without deduplication.
Retain 1,000 null draws with existing seed 20260908+network index; reuse
the same random draw sequence for equal K within a network. Nulls must be
re-evaluated for different reference epochs and common K, not blindly reused.
Retain 10,000 shared whole-network bootstrap indices, seed 20260909, exact
1,024-pattern paired sign-flip tests, separate seven-test PR and alignment
BH families, and per-network OLS slopes against log10(lambda).
The unchanged motor-error family is not recomputed.

Original Stage-2 numerical/figure provenance remains in the starting commit.
Scientific acceptance is not implied by implementation validation.
