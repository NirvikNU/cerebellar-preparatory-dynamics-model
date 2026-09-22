# Exact panel/source map

All paths are repository-relative. Existing figure pairs are untouched.

| New figure | Numeric source | Fitting/raw evidence |
|---|---|---|
| plots/paper_ready/prediction/{fig,png}/panel_e_pca_ridge | results/paper_ready/prediction/primary.mat: r2, bootstrap, relativeChange, relativeBootstrap, tests, p, q | results/paper_ready/cache/prediction/primary_nXX_pP.mat: full features, PCA bases/spectra, folds, permutations, nested losses, selected penalties, predicted/actual arrays |
| plots/paper_ready/prediction/{fig,png}/panel_e_controls | primary.mat: matched, matchedK, chanceMedian, K, capture | matched_nXX.mat: six paired fits per network; primary_nXX_pP.mat: all100 shuffled fits |
| plots/paper_ready/prediction/{fig,png}/extended_data_rrr | results/paper_ready/prediction/rrr.mat: mean, se, rank, threshold, peak, bootstrap summaries, shuffleMedian, tests/p/q | rrr_nXX_pP.mat: all101 correspondence sets x10 repeats x200 ranks, every inner search, selected penalties, observed fit factors and splits |

The cache-only renderer is figures/paper_ready/prediction/pe_figures.m.
Each plotted network vector, median and SE is tagged with source values
and independently checked after reopening its saved FIG. PNG and FIG are
exported from the same graphics object before closure. Visual inspection
and native Notion publication are separate final checks, not implied by
a render launch or a file's mere existence.

series_nXX_pP.mat preserves recovered1-ms Prep and movement cortical states,
frozen reference scale, existing trial-specific MO, two-epoch aligned
features, and provenance. Recovery does not change any controller/model,
run the arm again, choose new trials, or reconstruct new noise streams.
Intact preparation reuses its complete old paper grid states; other
preparations recover only the frozen selected geometry. Movement series
start at each original saved GO state and stop at the existing horizon.
Saved torque, final-state and native-transition comparisons provide
full-network/policy fidelity gates before regression.

Independent checks are recovery.json, primary_audit.json, rrr_audit.json,
statistics_audit.json and the synthetic unit/unit_wide receipts. Full
preservation checks, source/static review and figure/publication receipts
are under artifacts/manifests/paper_ready/prediction. Source outputs retain
negative values, bad-kinematics trials, all100 shuffles and all200 ranks.

Empirical contextual percentages come from Main_text_v8, Drive ID
1ZMY8I_aalyKtAfdE4Sz_uoO4zE8v3W_E0d-_s0T09gI, revision13September2026.
They are not model fit targets or digitized points. The same source's
RRR equation was checked in native mathematical XML because text extraction
omits equations. Complete pre-outcome declarations are in PLAN.md and the
existing Notion Analysis Decisions page. This work does not re-label a
model calibration as a held-out result: only these new prediction analyses
are held-out tests of the already selected geometry/timing.
