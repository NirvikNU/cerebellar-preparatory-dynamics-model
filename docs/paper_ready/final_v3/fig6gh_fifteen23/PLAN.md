# Fig6g/h: fifteen-trial extension — locked before added draws

User instruction, 4 October 2026: replace current g/h with the same examples but 15 instead of 10 trials, otherwise unchanged; scoped cleanup/publication and normal main commit/push. Base 00630f27b4d6fe4bf9bd33beb43709f0c15777fb. Network 8, target 6 remains fixed. All Fig6f variants, scientific parameters, raw trials, aggregate statistics and manuscript text remain unchanged. Current Notion task text is historical task14; the direct instruction controls this bounded display update.

## Selection

Keep every one of the existing ten task17 trials, in the same order. Load their fixed ten three-member peak-position strata and selected IDs from the validated task17 cache and cross-check its committed source tables. Continue the same mt19937ar streams (170801 Intact, 170802 Block) after the ten original randi(3) draws. Make one randperm(10,5) draw of five distinct strata; in draw order, make one randi(2) draw from the two unshown members of each selected stratum, retaining their original within-stratum order. Append these five trials to the original ten. Thus every stratum remains represented and no added stratum contributes more than one extra trial. Conditional on the original ten, each remaining trial has inclusion probability (5/10)*(1/2)=1/4. No speed/RMS/contrast screening, rerolls, seed search or fallback selection. Freeze identities on disk before reading subset speed diagnostics.

This is a deliberately chosen network/target with a spatially stratified extension, not a statistically typical sample or an optimization to obtain either visual effect. Original g/h trial identities are preserved as a subset; additional sampling is new display-only work, not simulation.

## Unchanged conventions, count-dependent updates

- Same selected 15 successes in g/h, same native coordinates/events, solid skyblue/vermillion lines, no smoothing of individual speed traces, target-entry truncation.
- g median from only the 15 displayed trials. Same MO alignment/post-entry NaNs; raw median over full nonempty support; unchanged Gaussian50 applied with true-boundary renormalization; then display cutoff at last nActive>=ceil(15/2)=8. This preserves the at-least-half rule; no artificial cutoff edge or zero padding.
- h unchanged empirical-style overlay, native peak markers, target key, hidden axes, 1-cm scale bars and black dashed ideal path. Histogram and reference medians remain exactly all30; bin edges/counts unchanged. No jitter, deformation or differential scaling.
- Original ten-trial FIG/PNG/code/results remain untouched as provenance. New current bundle uses fig6gh_fifteen23 roots; no overwrites or scientific writer calls.

## Acceptance and post steps

Inventory hidden/ignored/untracked; hash protected current data/caches; preserve 895 unrelated untracked files. Independently replay extension, verify old-ten inclusion, native data/events, sort-based medians, explicit Gaussian sums, nActive/cutoff and all30 histogram identity. Run Code Analyzer on new MATLAB only. Reopen both FIGs, compare source objects and visually inspect PNGs. Replace only g/h display sections on the current Notion gallery, leaving their aggregate-statistics blocks, all other panels and manuscript placeholder table unchanged. Refresh the source ZIP with only display updates; preserve identical unrelated entries. Update current navigation, concise historical link and statuses. No broad storage cleanup or deletion. After all audits, scoped normal main commit/push and exact local/tracking/direct-remote equality; stop for review.
