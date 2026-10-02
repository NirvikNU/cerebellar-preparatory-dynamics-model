# PAPER-MODELLING-CONVERGENCE-REANALYSIS-01 — completed for scientific review

Completed26 September2026 from release
aa63c7914fadf6f7c96c634617e797eac3772246. This is an uncommitted review candidate,
not scientific acceptance or a replacement release. STOP for user review.

## Deliverables

-120 preparation cases,50 matched spontaneous epochs and28,800 held-out trial
  records under the exact frozen design; all raw states, distances/ratios,
  reference bases/indices, native-step probes/extrema and QC retained.
- Three matching FIG/PNG bundles in plots/paper_ready/convergence_reanalysis:
  main_review/MainFig_ConvergenceReview, ED1_convergence/ED1_ConvergenceReview,
  ED2_components/ED2_ComponentsReview (each with fig/png subfolders).
- Main A-H untouched; I/J reuse released prediction arrays. ED2 retains the
  released PR/alignment/R2 arrays with explicit component labels and no C.
- REPORT.md contains all five noise-pair convergence/prediction summaries,
  four-policy primary C and settling QC. FIGURE_LEGENDS.md and PANEL_SOURCES.md
  give full captions/source maps. INTEGRATION_AND_INDEX_AUDIT.md provides
  equations, array/time proofs and audit coverage/limits.
- Native candidate images, complete legends, report tables and seven full-
  precision source attachments published on Notion page04 under
  “Convergence reanalysis — scientific review pending”. Agent Log has a new
  chronological entry; Handoff and START HERE show the review stop.

## Important negative result / limitation

Primary C is negative for Intact (-.0691985037 +/- .0030991432), Block
(-.1624755537 +/- .0059270434), and both partial-removal policies. The paired
Block-Intact effect is -.0929913847 +/- .0025527928 (median +/- bootstrap SE,
n=10). Primary spontaneous last/preceding dispersion grows7.75%; the full
fixed500-ms interval is not established as stationary. No burn-in extension,
tuning, exclusion or favorable-condition selection followed these results.
Condition-specific PCA dependence and distinct convergence versus released
prediction protocols are explicit. No new inferential testing family.

## Validation

- All120 independent covariance/eigen distance audits passed; maximum
  convergence discrepancy3.1441516057384433e-13.
- Initial/temporal draws, native transition equations and cue continuity:
  zero discrepancies in the declared probe scope; pre-cue input exactly zero.
- All50 spontaneous and120 preparation cases finite and within frozen bounds;
  zero undefined C among28,800 records. QC discrepancy1.3322676295501878e-15.
- Independent network-bootstrap SE discrepancy4.9439619065339e-17; CSV
  ratios/paired effects exact, network aggregation error1.6653345369377348e-16.
- Code Analyzer: all12 new MATLAB files, no messages. All3 FIGs reopened,
  536 plotted-source checks; all3 PNGs visually inspected. Published PNGs
  downloaded in memory and SHA256-matched the corresponding local exports.
- All3,270 pre-existing files,278,538,166,388 bytes, passed exact before/after
  SHA256 preservation with no exemptions. No original file was deleted.
- Page04 retains its six released native figures; all historical release
  bodies in page04/Log/Handoff/START remain unchanged. Five new report/source
  tables verified structurally; seven native source attachments resolve.

## Git and reproducibility boundary

Read-only final checks26 September2026 confirmed local HEAD, local main/v3,
both origin tracking refs and direct remote main/v3 all remain
aa63c7914fadf6f7c96c634617e797eac3772246. Branch v3-romano-hennequin still tracks
origin/v3-romano-hennequin. Tracked diff and staged diff are empty; only the
four dedicated review roots are untracked. Raw evidence is intentionally
ignored under results/paper_ready/cache/convergence_reanalysis. Existing local
accepted inputs and caches remain required for full reproducibility.

No staging, commit, push, fetch, main update, history mutation, release
replacement, cleanup/deletion, movement simulation, geometry reselection,
prediction fit or RRR occurred. Technical pre-simulation stop evidence remains
in EXECUTION_NOTES.md and original launch logs. Successful production completed
once; no completed scientific case was rerun. No further execution task is
pending within this authorized review gate. Scientific review is the next step.
