# Fig6g/h: fifteen-trial current display

Completed display-only extension from checkpoint 00630f27b4d6fe4bf9bd33beb43709f0c15777fb. Same user-approved network 8 and target 6 in both panels. No model simulation, parameter change, scientific fit, inference or manuscript edit. All Fig6f variants and other panels remain unchanged.

## Selection and exact IDs

All original ten trials are retained in order. Continuing mt19937ar seeds 170801 (Intact) and 170802 (Block) after the original ten randi(3) draws, sample five of the existing ten peak-position strata without replacement and choose one of each stratum's two unshown members uniformly. No speed/RMS/contrast screening, rerolls, new seed or fallback. Added selections were saved before reading their speed descriptives. The target remains deliberately chosen during prior review, not an unbiased or statistically typical target sample.

- Intact original: 10, 3, 41, 33, 38, 20, 7, 15, 19, 9; added: 31, 42, 14, 28, 29.
- Block original: 67, 102, 28, 78, 22, 88, 96, 49, 9, 29; added: 2, 56, 47, 58, 61.
- Added strata, Intact: 7, 2, 8, 4, 10; Block: 4, 10, 2, 9, 5.
- Both panels use the exact same fifteen trials per condition. The source pool remains the first thirty successes, achieved by attempts 50/105.

## Unchanged conventions and necessary count changes

Fig6g: fifteen native unsmoothed solid traces per condition; selected-fifteen pointwise median after MO alignment and post-entry NaNs. Same Gaussian50 applied over the entire true raw-median support, then display truncation. Preserve at-least-half support as nActive>=ceil(15/2)=8. Full support ends 305/523 ms; display ends 270/321 ms (Intact/Block). No zero padding or smoothing at an artificial cutoff.

Fig6h: same fifteen paths/filled native peak markers, solid skyblue/vermillion, common native spatial coordinates, target key, hidden axes, 1-cm L-scale, angled overlapping histogram and black dashed ideal path. The all-thirty condition-specific median positions, distances and histogram are unchanged. Edges 0:0.5:2.5 cm; counts Intact 13,16,1,0,0 and Block 3,11,12,3,1. Only the displayed-trial flag in the new all30 source table changes; its native values remain exact.

| Illustration-only quantity, not manuscript inference | Selected15 Intact | Selected15 Block | All30 Intact | All30 Block |
|---|---:|---:|---:|---:|
| Median native peak speed (m/s) | 0.4413345114366153 | 0.3729889764285133 | 0.4390734989272691 | 0.33478077839326814 |
| RMS distance to own median peak position (cm) | 0.4647314083063932 | 1.1626202824915532 | 0.5320402815310069 | 1.178426498045259 |

These frozen additional draws retain lower Block speed and broader Block spread in this illustration. No selection or rendering decision depended on obtaining those directions. The manuscript all-trial network-level values, bootstrap SEs and inferential statistics are unchanged; these display diagnostics do not replace them.

## Files

Native pairs: plots/paper_ready/final_v3/fig6gh_fifteen23/{fig,png}/Fig6g.{fig,png} and Fig6h.{fig,png}. New code, compact display CSV/MAT, selection strata/identities and audit receipts use the same fig6gh_fifteen23 stem under analysis/results/docs. The previous ten-trial files remain intact under fig6gh_representative17 as provenance. LEGENDS.md provides full captions; DEPENDENCIES.md classifies retained inputs and cleanup.

## Validation

Independent original spatial-partition and scalar RNG replay verifies all original identities and every added draw; no replacement of prior examples. Native hand calculations verify all sixty success/onset/peak events, aligned raw speeds, all30 residualization and histogram. Sort-based median error 0; explicit truncated/renormalized Gaussian error 2.220446049250313e-16. Both saved FIGs reopened and all 75 data-bearing objects verified against sources. Two PNGs visually inspected; same graphical organization retained with no clipped annotations. Code Analyzer: six new MATLAB files, zero findings.

Preservation verifies 9,451 original file metadata identities and 7,752 applicable SHA256 hashes; only existing CURRENT_PANEL_INDEX.md navigation changes. All 895 unrelated untracked files and retained caches remain untouched. No deletions or broad cleanup. Large ignored caches not in the protected hash subset are checked by size/mtime, not claimed hash-verified. No new full raw cache is duplicated.

Publication replaces only current g/h display portions and the current source ZIP; aggregate-statistics blocks, ten unrelated panels, frozen conventions and manuscript placeholder table remain exact. The source archive receipt verifies twenty-one unrelated/scientific entries against the previous ZIP. The Fig6f review page remains unchanged except any concise current-checkpoint status update. Notion validation receipts establish actual read-back and native upload identities.

After scoped staged-diff review, normal main commit/push is authorized. Actual release SHA, reference equality, clean tracked/index state and measured folder size are recorded after verification in Notion and local Git receipts. Stop for scientific review; no further model or analysis.
