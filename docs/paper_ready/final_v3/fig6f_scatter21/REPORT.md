# Fig. 6f: peak-position scatter-matched review example

## Scope and outcome

Display-only addition requested on 3 October 2026, based on checkpoint fig6f_scatter21. Frozen network 8; no new simulations, fits, statistics, model changes, or selection by condition contrast. The current manuscript panels and all six preceding review examples remain unchanged. This new example is deliberately matched, not random and not selected to maximize a condition difference.

## Fixed rule

Before evaluation, PLAN.md fixed an equal-weight center and second-moment criterion. For peak-speed hand positions x in each target/condition, m is the coordinatewise median, S = mean((x-m)(x-m)') uses the population denominator, and D = sqrt(trace(S)). For every four-trial subset, minimize J = ||m4-mN||^2 / DN^2 + ||S4-SN||F^2 / ||SN||F^2. Exact ties use the lexicographically first ascending attempt-ID tuple. No outcome-driven adjustment was made.

All 407,422 subsets across 16 cells were scored. Independent native-evidence reconstruction and exhaustive recomputation selected the same global optimum in every cell. S is a median-centered second moment, not an ordinary mean-centered sample covariance. Matching these summaries does not guarantee matching multimodality, tails, or every feature of the full distribution.

## Available evidence and selected IDs

The existing pool has 453 successful trials. Intact has 30 per target. Block has 30, 30, 30, 4, 29, 30, 30, 30; target 4 therefore uses its entire four-success pool, without invented trials or new simulation. These are conditional successful-trial displays, not unbiased all-attempt samples. The retained ledger covers 12,674 attempts (12,221 failures).

| Target | Intact attempt IDs | Block attempt IDs |
|---|---|---|
| 1 | 3, 11, 16, 17 | 53, 70, 71, 163 |
| 2 | 5, 6, 9, 10 | 55, 96, 150, 151 |
| 3 | 10, 30, 33, 42 | 44, 74, 93, 110 |
| 4 | 12, 17, 21, 37 | 518, 1860, 2867, 4931 |
| 5 | 4, 14, 20, 26 | 397, 1122, 1461, 2588 |
| 6 | 9, 13, 26, 41 | 28, 49, 96, 97 |
| 7 | 1, 9, 22, 37 | 343, 1470, 2136, 2237 |
| 8 | 8, 13, 36, 40 | 39, 76, 84, 433 |

## Dispersion and mismatch

D is RMS Euclidean distance to the cloud's own coordinatewise median. Values below are display-selection diagnostics, not new manuscript inference. Full-precision source values are in scatter_match_quality.csv.

| Condition | Target | Pool n | Full D (cm) | Four-trial D (cm) | D mismatch (%) | Center shift (mm) | Relative scatter-matrix error |
|---|---|---:|---:|---:|---:|---:|---:|
| Intact | 1 | 30 | 0.60601 | 0.60020 | -0.958 | 0.2286 | 0.04454 |
| Intact | 2 | 30 | 0.40286 | 0.40444 | 0.392 | 0.1691 | 0.07087 |
| Intact | 3 | 30 | 0.56530 | 0.53500 | -5.360 | 0.4564 | 0.09272 |
| Intact | 4 | 30 | 0.59228 | 0.58940 | -0.487 | 0.5563 | 0.03252 |
| Intact | 5 | 30 | 0.51180 | 0.49324 | -3.626 | 0.3878 | 0.10107 |
| Intact | 6 | 30 | 0.53204 | 0.52636 | -1.069 | 0.2466 | 0.10968 |
| Intact | 7 | 30 | 0.42893 | 0.42593 | -0.700 | 0.4139 | 0.12739 |
| Intact | 8 | 30 | 0.36120 | 0.34979 | -3.159 | 0.1140 | 0.06066 |
| Block | 1 | 30 | 2.78862 | 2.66143 | -4.561 | 1.2797 | 0.07804 |
| Block | 2 | 30 | 0.95963 | 0.98798 | 2.954 | 1.0916 | 0.08051 |
| Block | 3 | 30 | 2.30225 | 2.30011 | -0.093 | 0.8770 | 0.00977 |
| Block | 4 | 4 | 2.80665 | 2.80665 | 0.000 | 0.0000 | 0.00000 |
| Block | 5 | 29 | 1.64584 | 1.56920 | -4.657 | 0.5050 | 0.10219 |
| Block | 6 | 30 | 1.17843 | 1.18819 | 0.829 | 0.7535 | 0.07430 |
| Block | 7 | 30 | 1.13928 | 1.08768 | -4.529 | 1.2336 | 0.30016 |
| Block | 8 | 30 | 0.85520 | 0.89337 | 4.463 | 0.3825 | 0.14125 |

Absolute RMS dispersion mismatch is at most 5.3597352157%; maximum center shift is 1.2796647694 mm. The largest relative scatter-matrix discrepancy is 0.3001637822 (30.02%) for Block target 7. Thus “best” means best under the locked objective, not a claim that four points exactly reproduce the cloud. This limitation is retained unchanged.

## Figure and source definitions

- Thin paths: four selected native trajectories per target/condition, GO to first target-zone entry.
- Filled circles: their native, unsmoothed peak-speed hand positions before entry.
- Thick curves: arithmetic mean of those same four trajectories after 101-point movement-onset-to-entry phase normalization; not a median.
- Existing eight-target palette and 1.5-cm zones; equal aspect and identical limits [-12.65, 12.65] cm on both axes/conditions.
- Pair: plots/paper_ready/final_v3/fig6f_scatter21/{fig,png}/Fig6f_scatter_matched.{fig,png}.
- Sources: results/paper_ready/final_v3/fig6f_scatter21/ — all_peak_positions.csv, selected_trials.csv, displayed_native_paths.csv, same_four_phase_means.csv, scatter_match_quality.csv, selection.json, display_sources.mat and validation.json.
- Native Notion publication: existing review page 3ee26c94be308125a5b0d6dcd9fe1321; current gallery remains navigation-only for this addition.

## Validation and preservation

- All 453 saved successes independently cross-checked for membership, native peak/event values and seeds.
- All 407,422 candidate scores independently recomputed; maximum numerical discrepancy 2.78e-17; all 16 selected optima agree.
- Same-four phase means independently reconstructed; maximum difference 2.78e-17 m.
- Saved FIG reopened: 96 expected graphics objects and 64 peak-position markers checked against sources. PNG visually inspected: no clipping/overlap, consistent scales and distinct target colors.
- Code Analyzer: all three changed MATLAB files, zero findings.
- Preservation: 9,397 old files retain metadata; 7,697 applicable SHA256 digests unchanged. The only modified pre-existing file is CURRENT_PANEL_INDEX.md (navigation).
- All 895 unrelated pre-existing untracked files excluded from staging and retained. No files deleted, moved or overwritten; cleanup is scoped organization only. No broad storage cleanup.
- Native publication byte identity and prior-page preservation are recorded in NOTION_VALIDATION.json. Post-push SHA/ref equality and final size are recorded in Notion and a local .git receipt, avoiding a self-referential release commit.

## Reproducibility dependencies

MATLAB R2025b and the existing unchanged paper_json.m / final_v2/v2_csv.m helpers. The ignored local cache results/paper_ready/cache/fig6fgh_highrms14/display_sources.mat supplies all native hand evidence from the retained fig6fgh_successful11 reservoir. The committed all_saved_attempts.csv in fig6fgh_highrms14 supplies membership. These non-versioned dependencies are preserved, not added to Git. Compact selected data and all peak positions are committed for review.

## Stop boundary

Normal scoped main commit/push after validation; no other analysis or model. No example is automatically promoted to the manuscript. Stop for scientific review.
