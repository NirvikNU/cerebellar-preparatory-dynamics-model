# Representative movement figure legends

## Common display methods

Use only frozen primary s_init=0.10/s_temporal=0.10 movement evidence; eta=0, lambda=10, shared alpha=0.5/beta_norm=1.25, ten networks, eight targets and 30 trials per target/condition remain unchanged. Display end is first saved entry into the 1.5-cm peripheral zone, inclusive, or the 600-ms horizon. Native samples are GO 0:599 ms; no synthetic 600-ms point is created. Every later sample is NaN before ranking, summary, smoothing or peak calculations. Sources remain untruncated on disk.

Path RMS is the square root of mean squared shortest distance to the CLOSED central-to-peripheral target line segment, from saved kinematic movement onset through display end. It is NOT deviation from a condition mean. Successes rank first, then ascending path RMS, then trial ID; unsuccessful trials fill only missing display slots. Selection is separate by target/condition.

Network 8 has the minimum Intact score, **0.0007875659342411926 m**, equal to the mean of its eight target scores, each the mean RMS of five selected Intact trials. Network selection is frozen before Block is read. No target in network 8 reaches ten successes in both conditions. The prescribed fallback therefore selects target 6: its minimum success count is 7 (Intact 18, Block 7), uniquely greater than every other target's minimum. Its Intact ten-trial score is **0.0019923392754508775 m**; no score or ID tie-break is needed. Block informs availability only, not the quality score.

This is an explicitly outcome-selected illustration, not an inferential unit or a claim of typicality.

## Figure 6f

Five success-first trials per target/condition are thin trajectories; thick curves are the mean of ALL 30 terminated trials, not the selected five. Network 8, all eight targets, identical axes/aspect and 1.5-cm target zones. Target 1 is bottom and 2–8 run counterclockwise; the exact eight-row manuscript palette is recorded in code/source data. No inferential statistic is attached.

| Target | Success Intact / Block | f Intact IDs | f Block IDs |
|---|---|---|---|
| 1 | 24 / 5 | 19, 9, 18, 7, 10 | 30, 28, 11, 10, 4 |
| 2 | 20 / 5 | 7, 18, 24, 16, 12 | 17, 19, 1, 18, 11 |
| 3 | 22 / 1 | 2, 22, 3, 20, 9 | 12, 19, 28, 16, 18 |
| 4 | 21 / 0 | 3, 11, 1, 8, 4 | 25, 22, 4, 13, 1 |
| 5 | 22 / 0 | 14, 1, 15, 11, 24 | 28, 9, 27, 16, 25 |
| 6 | 18 / 7 | 23, 27, 22, 5, 1 | 13, 23, 24, 17, 30 |
| 7 | 18 / 0 | 25, 8, 6, 1, 23 | 20, 22, 12, 11, 10 |
| 8 | 20 / 3 | 4, 17, 14, 15, 25 | 13, 21, 7, 3, 24 |

## Figure 6g

Network 8, target 6. Ten success-first trials per condition are thin speed traces; the thick condition trace is the median of all 30 terminated native speed profiles, followed by the existing Gaussian50 display smoothing. Individual smoothing uses only each retained prefix. Intact is sky blue [86,180,233]/255; Block is vermillion [213,94,0]/255. Intact solid and Block dashed; no aggregate subplot. The late all-30 median reflects surviving trials and can remain after the ten successful example curves terminate.

Local trial IDs, in selection order: Intact **23, 27, 22, 5, 1, 17, 11, 4, 18, 7**; Block **13, 23, 24, 17, 30, 12, 18, 22, 7, 3**. All ten displayed Intact trials succeed. The first seven displayed Block trials succeed; IDs 22, 7 and 3 are unsuccessful fill-ins. Global IDs equal local ID +150 for target 6.

The independent aggregate assay is unchanged: ten network-level unsmoothed peak speeds, Intact 0.42026633892887771 ± 0.00095732016011368989 m/s; Block 0.29334637066412139 ± 0.011120979564432407 m/s; within-network reduction 29.620738559012963 ± 2.5030943906286582%. AD-selected two-sided paired t-test, n=10, t(9)=-18.944070455588200, raw p=1.4641906487214610e-8. No multiplicity correction. These results are copied from unchanged validated sources, not recomputed here.

## Figure 6h

Same network, target and EXACT ten trial IDs as 6g. Thin terminated trajectories and filled circles at each trial's own unsmoothed retained-prefix peak speed; same sky-blue/vermillion condition colors. Preserve the empirical Fig. 1e scale-bar/inset logic, with 1-cm scale bars. Coordinate-wise median peak position and the inset distance distribution use ALL 30 terminated trials per condition, not the ten displayed examples. Marker rims additionally distinguish conditions. The illustrative inset is not the primary speed-matched assay.

Speed-matched hand-position dispersion; 6/10 networks met the prespecified matching criterion. Eligible IDs 1,2,3,6,7,10; matching remains ≤5% within-target peak-speed mismatch, ≥5 pairs/target and ≥5 eligible targets/network. Intact 0.55267160633162271 ± 0.027318985032037599 cm; Block 2.6840010552961773 ± 0.33160946624453685 cm; within-network increase 395.37364598900677 ± 63.030615020997878%. AD-selected two-sided Wilcoxon signed-rank, n=6, W_plus=21, raw p=0.03125; no multiplicity correction. Unmatched all-ten robustness values remain Intact 0.538181 ± 0.018179 cm and Block 3.01474 ± 0.203371 cm, non-primary. No exclusions or aggregate numerical values changed.
