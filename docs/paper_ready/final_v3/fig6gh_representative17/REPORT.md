# Fig6g/h spatially stratified target6 display — 17

Completed display-only revision for scientific review. Network8 and target6 are the user-approved pair for both panels. No simulations, inference, model changes, scientific recomputation, or manuscript edits.

## Frozen selection and transparent scope

The target was deliberately chosen in the prior review to illustrate distributed Block spatial spread; it is not an unbiased network/target selection or a formal unimodality claim. Within this fixed target, ten trials per condition were sampled exactly once using the predeclared spatial strata and mt19937ar seeds170801/170802. Every terminal stratum contains three of the first30 successes; one is drawn uniformly. No speed, pathRMS, condition contrast, or search over subsets/seeds enters this selection. This is spatially stratified random illustration, not a uniformly drawn simple-random sample or a best-fit subset.

The frozen selection was saved before checking its speeds. Both panels use the same exact trials:
- Intact: 10,3,41,33,38,20,7,15,19,9.
- Block: 67,102,28,78,22,88,96,49,9,29.

The parent saved pool reached30 successes by attempts50/105 respectively, within the500-attempt eligibility bound. All other successes/failures and prior illustrative selections remain preserved. Fig6f is unchanged.

## Illustration-only checks (not manuscript statistics)

| Metric | Selected10 Intact | Selected10 Block | All30 Intact | All30 Block |
|---|---:|---:|---:|---:|
| Native median peak speed, m/s | 0.43846406393595561 | 0.3605165417957355 | 0.4390734989272691 | 0.33478077839326814 |
| RMS distance from own coordinatewise median peak position, cm | 0.45039803844131132 | 1.228750320907249 | 0.53204028153100691 | 1.178426498045259 |

The selected subset shows broader Block spread and lower Block speed. No fallback draw was needed. Spatial stratification aims at coverage, not exact matching of every30-trial moment; selected and full-population values are disclosed without correction or resampling.

## Figure definitions and paths

- plots/paper_ready/final_v3/fig6gh_representative17/fig/Fig6g.fig and png/Fig6g.png.
- plots/paper_ready/final_v3/fig6gh_representative17/fig/Fig6h.fig and png/Fig6h.png.

g: ten unsmoothed solid profiles per condition. Thick pointwise median uses exactly these ten, movement-onset aligned with post-entry samples NaN. Smooth the entire available raw-median support using the existing50-ms Gaussian, with boundary truncation/renormalization; only afterward truncate display at the last nActive>=5 sample. Intact/Block full support ends295/523ms and displayed cutoffs270/413ms. No zero padding.

h: same ten native paths and filled unsmoothed peak-speed positions; no jitter, rotation, unequal spatial scaling, deletion or synthetic points. Skyblue/vermillion solid paths, hidden axes,1-cm L-scale, target key, black dashed central-to-target ideal path and lower-right angled overlapping filled histogram match the live empirical Fig1e graphical organization. All30 successes define the coordinatewise median positions and inset distances. Identical prior target6 histogram:0.5-cm bins0–2.5cm, Intact13,16,1,0,0; Block3,11,12,3,1.

## Validation

Six MATLAB files pass Code Analyzer (code_analyzer_complete.json). Independent iterative spatial partition and scalar RNG draws reproduce the frozen recursive/vectorized selection. Independent raw-hand calculations verify all60 success events, movement onset, native peak speed/position, all30 inset residualization and bin counts. Independent sort-based medians and explicit truncated Gaussian sums match: maximum peak/median error0, Gaussian error2.7755575615628914e-16.

Both native FIGs reopened;55 data-bearing graphics objects match sources, selected IDs, colors, line styles, histogram arrays and ideal path. Both exported PNGs visually inspected. Live Main_text_v10 Fig1 source hash unchanged; empirical Fig1e crop inspected before plotting. No manuscript image/text was altered.

The current Notion gallery is updated with only the two new display sections, source bundle and concise status/provenance. Its ten unrelated panel sections, g/h aggregate statistical blocks, conventions and manuscript-placeholder table must remain byte-identical after normalizing signed attachment URLs; publication receipt records verification.

## Preservation, cleanup and checkpoint

The full before inventory includes9298 original non-Git files,7625 SHA256 entries and all dirty/untracked/ignored paths. Post receipt verifies unchanged originals except the authorized navigation file. Other large ignored caches are checked by size/mtime, not falsely described as hash-verified. See preservation_after.json and DEPENDENCIES.md.

No previous dependency or unique evidence is deleted. All original task15/16 uncommitted outputs remain local as provenance. No temporary file from this revision requires deletion; failed-start/static receipts are retained as tiny audit evidence. No repeated broad cleanup.

Only this successor's compact code/sources/docs/FIG/PNG plus current-panel navigation are checkpoint scope; previous unrelated untracked files remain unstaged. The derived display MAT stays ignored/local. The exact final commit SHA and verified HEAD/tracking/direct-remote equality are recorded in the Notion current status and local Git synchronization receipt after normal main push. No commit hash is embedded in its own committed report.

STOP FOR SCIENTIFIC REVIEW after authorized checkpoint/publication. This does not authorize further scientific work.
