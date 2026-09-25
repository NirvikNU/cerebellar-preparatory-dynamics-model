# Final-v2 release hold — Panel E coverage

Historical stop receipt, preserved verbatim below. Resolved by the user's
25 September 2026 authorization in SUBSET_RESOLUTION.md. This is not current
execution authority or release status; see RELEASE.md and the final receipts.

25 September 2026. PAPER-MODELLING-FINAL-FIGURES-V2-01 was not released at this stop.

## Decision required

The manuscript-grounded speed matcher was applied without relaxation: within-target greedy pairs with relative speed difference at most 5%, at least five pairs per target and at least five qualifying targets per network. Networks 1, 2, 3, 6, 7 and 10 have defined paired peak-speed position dispersion. Networks 4, 5, 8 and 9 have only four qualifying targets and remain undefined.

The frozen ten-network bootstrap correctly propagates those undefined values. Consequently the draft Main E displays six paired network values but has undefined ensemble median/error bars. The paired behavioral test is defined on those six networks (two-sided Wilcoxon signed-rank, p=0.03125; paired-difference Anderson–Darling p=0.021789232569363721). This does not make the required ensemble uncertainty complete.

Requested resolution, not yet implemented: permit an explicitly labelled six-network conditional summary with 10,000 paired whole-network bootstrap draws using the original bootstrap seed, preserving all original ten-network arrays, missingness, matching counts and QC. This changes only the sample-size handling of Panel E, not matching, geometry, noise, movement or model parameters. Do not implement without user approval; do not relax eligibility or silently omit missing values.

## Completed and preserved

- All 36 shared geometry candidates were evaluated in ten networks. Alpha=0.5, beta_norm=1.25 was uniquely selected and frozen at 2026-09-25T14:02:38Z before downstream evaluation. DeltaPR=3.2357604186198508, alignment deficit=16.409285208138037 percentage points, relative-squared loss=0.050363119828606938. The beta choice is the upper fixed-grid boundary; no grid expansion is authorized.
- All 120 final-v2 cases are complete: 50 geometry-independent Intact cases reused, 70 new cases, 28,800 total trials. No new RRR or parameter selection followed the geometry freeze.
- The independent numerical audit passed, including exact standardized draws/native checked transitions, corrected single-sample pre-cue convergence, Control95 geometry, PCA75/ridge, matched/shuffle controls, movement metrics and bootstrap calculations. Exact errors are in `results/paper_ready/final_v2/audit.json`.
- Main A–J and ED1–5 exist as six new native FIG/PNG pairs. All six were reopened (562 tagged source-object checks) and all six PNGs visually inspected. They are drafts, not graphics-validated release artifacts.
- Visual review found unwanted automatic `data1`/`data2` legend entries in Main I/J, ED1 and ED3. A cache-only legend repair remains; no simulation or fitting is needed.
- Corrected convergence is negative at every tested noise pair; retain the signs and raw distances. Eta=0 lambda=10 readiness is 109.5 ms rather than the historical approximately 75 ms. Lambda remains frozen at 10.
- Full numerical results, source data and draft legends are in this directory and `results/paper_ready/final_v2/`. Existing scientific assets, prior figures and uncommitted noise-sensitivity content remain protected.

## Resume boundaries

Read the final saved-output, packaging and preservation receipts before resuming; never rerun successful scientific writers. Resolve Panel E first. Then repair/reopen/reinspect affected figures from saved outputs, independently verify any authorized conditional summary and complete Notion publication and conservative release steps. No cleanup, staging, commit, push or main synchronization has been performed at this hold.

Do not rerun the grid, simulations, selection, ridge or shuffles to resolve this presentation/statistical coverage question. Preserve the selected pair and all negative/QC results. No new figure family or model is authorized.

## Verified Git / Notion state at hold

Read-only verification on 25 September 2026: HEAD, local main/v3, both tracking refs and both direct remote branches remain `93e9d517d47b48579ef9d5bda6adacc44bf039d7`. Tracked worktree and index diffs are empty. Twelve dedicated final_v2/noise_sensitivity directories remain untracked; required raw evidence remains ignored/local. This is not a clean release worktree and no new commit exists.

Page 04, Agent Handoff, START HERE and Agent Log contain the release-hold entry; each was fetched again and verified. Page 02 and historical figures were not changed. New final-v2 figures have not been published as validated.

The single launched saved-output/static/preservation sequence is not cancelled. Its completion was still pending at this hold; inspect its exit status and `results/paper_ready/final_v2/output_audit.json`, `artifacts/manifests/paper_ready/final_v2/packaging_static.json` and `preservation_after.json` on resumption, without relaunching successful work. Do not infer those checks passed from the separate numerical audit PASS.
