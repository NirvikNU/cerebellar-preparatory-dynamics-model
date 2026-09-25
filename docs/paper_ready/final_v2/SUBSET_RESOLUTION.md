# Binding Panel E resolution — 25 September 2026

User authorization at resumption resolves REVIEW_STOP.md. No model, matching, geometry, timing, noise or prediction parameter changes.

Main E is a conditional subset analysis of networks 1, 2, 3, 6, 7, 10 only. Networks 4, 5, 8, 9 remain undefined for this assay and remain in every other panel. Use 10,000 whole-network paired resamples of these six networks, with the original bootstrap seed (2026091000). Retain the original ten-network arrays and missingness without replacement or imputation.

Required wording: “Speed-matched hand-position dispersion; 6/10 networks met the prespecified matching criterion.” Paired test: Wilcoxon signed-rank, n=6, p=0.03125.

Authorized robustness control: unmatched all-ten-network dispersion, using all 30 trials per target, the same coordinate-wise-median position and mean Euclidean-distance definition, equal target weighting and frozen ten-network bootstrap rows. Report descriptively outside Main E in the source report; do not add a new inferential family or conflate it with speed matching.

Recompute these summaries only from saved peak positions, independently cross-check saved matching evidence and bootstrap arithmetic, repair figure legends from native saved FIGs, then validate and release. Geometry remains alpha=0.5, beta_norm=1.25, eta=0, lambda=10, primary noise 0.10/0.10. No simulation, geometry selection, ridge or RRR rerun.
