# Final parsimonious paper modelling — release content and validation

Task: PAPER-MODELLING-FINAL-FIGURES-V2-01, with the explicit conditional-Panel-E
resumption authorization. Release subject: **Finalize parsimonious paper
modelling figures and code**. Release note: finalized eta=0 figures with the
prespecified speed-matched dispersion subset (6/10 eligible networks).

## Scientific freeze and exact scope

Shared alpha=.5, beta_norm=1.25, eta=0, lambda=10, V1 and primary noise .10/.10
are unchanged on resumption. No geometry selection, model/noise replay,
prediction fit, RRR, tuning or added mechanism occurred after the stop.
The original grid winner was frozen before all downstream evaluation.

Main E: **Speed-matched hand-position dispersion; 6/10 networks met the
prespecified matching criterion.** Networks 1,2,3,6,7,10; unchanged 5% mismatch,
five-pair/target and five-target/network rules. Median +/- bootstrap SE in cm:
Intact .5526716063 +/-.0273189850; Block 2.6840010553 +/-.3316094662.
Wilcoxon signed-rank, n=6, p=.03125. Four excluded networks remain undefined
only here, with no imputation. The separate unmatched all-ten-network control
is documented in [DISPERSION_CONTROL.md](DISPERSION_CONTROL.md).

All other panels use ten networks. The single-pre-cue convergence definition,
Control95 alignment and PCA75 nested-ridge analyses are frozen. Negative C,
movement abnormalities, upper-grid-boundary beta, imperfect calibration and
eta0 readiness109.5ms (not historical75ms) remain explicit. No outcome was
used to select another noise point or lambda. Historical RRR is not promoted
to the final-v2 set.

## Validation evidence

| Gate | Evidence |
|---|---|
| Unique global grid / no downstream selection | geometry_selection.json; calibration_csv_audit.json; all360 network/candidate audits |
| Equations, draws, corrected convergence, geometry, features/ridge/controls, movement | audit.json PASS120 cases; draw/native checked-transition error0; C/geometry error<=3.27e-13; R2 error<=1.12e-15 |
| Full-precision tables, paired tests, readiness, display-only trajectory truncation | output_audit.json PASS120 cases,640 readiness cases,480 trajectories,16 means; statistic discrepancy0 |
| Conditional and unmatched dispersion | dispersion_resolution.json PASS; independent peak-position discrepancy<=8.89e-16; separate order-statistic/bootstrap check |
| Code Analyzer | static_canvas_final.json PASS29 new MATLAB files; packaging_static.json also covers the18 prior noise-sensitivity files |
| Native FIG/PNG | final_figures.json562 source/error-bar checks; canvas_repair.json; visual_review.json all six pairs |
| Notion native publication | notion_publication.json six uploaded PNGs SHA256-equal to local; page02's twelve historical images unchanged |
| Preservation | preservation_after.json and preservation_resume.json: prior assets hash-checked, only authorized navigation documentation excluded |
| Cleanup | INVENTORY.csv, DELETIONS.csv and CLEANUP.json: conservative classification, no original/scientific asset deletion |

Scientific metrics/CSVs are under `results/paper_ready/final_v2/`; manifests
are under `artifacts/manifests/paper_ready/final_v2/`. Full methods/values:
[REPORT.md](REPORT.md), [FIGURE_LEGENDS.md](FIGURE_LEGENDS.md),
[SOURCE_DATA.md](SOURCE_DATA.md), [PANEL_SOURCES.md](PANEL_SOURCES.md).

## Packaging and reproducibility

The commit contains durable final-v2 code, compact results/full-precision
tables, plans/audits, six matching FIG/PNG pairs, paper-facing navigation and
the already completed uncommitted noise-sensitivity bundle. Previous accepted
models/results and negative/mixed findings remain unchanged. Large raw caches,
frozen local scientific inputs and pre-resolution draft-render provenance stay
ignored/local. Only new, closed, zero-byte execution logs qualify for deletion;
each removed path is in DELETIONS.csv. No scientific evidence is removed.

See [PAPER_CODE_INDEX.md](../PAPER_CODE_INDEX.md) for entry points and boundaries.
Git supports compact-result/figure inspection, not a fresh-clone full scientific
replay without the explicitly non-versioned accepted models, source and caches.

## Git identity and synchronization receipt

The release SHA is the **containing single normal commit** of this content
manifest, based on `93e9d517d47b48579ef9d5bda6adacc44bf039d7`. Resolve it with:

`git log -1 --format=%H -- docs/paper_ready/final_v2/RELEASE.md`

A commit cannot embed its own content-addressed SHA without changing that SHA.
Therefore the exact post-push SHA and verified reference values are recorded
in Notion and the local `.git/paper-modelling-final-v2-release.json`, not by a
second commit or amendment. This committed content manifest is not itself a
claim that a network push has succeeded.

`synchronize.ps1` requires the reviewed staged-tree receipt and exactly one
normal commit. It verifies expected-old93e9d517 on both remote branches and
local/tracking main, pushes v3 normally, rechecks main, fast-forwards local main
using an expected-old-SHA guard, pushes main normally, fetches and compares
HEAD/local/tracking/direct-remote refs. Any divergence, unexpected ref, lock or
dirty status stops instead of force pushing/rebasing/resetting. Final actual
receipt requires clean tracked/index state, no untracked durable files and
only intended ignored scientific inputs/caches.

Stop for scientific review after verified synchronization. No further model
fitting, parameter family or figure family is authorized.
