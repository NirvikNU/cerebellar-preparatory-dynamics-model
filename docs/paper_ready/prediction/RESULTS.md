# Panel e and full-space RRR — scientific review

Frozen checkpoint: 70fff703f8fd3074bef62ca9954a03bef50e4d99. No tuning.
Ten independent networks; 30 trials per target, eight targets; all four policies retained.
Gaussian SD30ms analysis only; geometry remains unsmoothed and unchanged.
Full-ensemble PCA follows the manuscript, not strictly inductive fold-wise feature estimation.
No post-GO noise, correction or reset. No trial exclusions for prior kinematic QC flags.

## Network medians +/- whole-network bootstrap SE

| Policy | PCA-ridge R2 | Shuffle floor | RRR predictive rank | RRR peak R2 | RRR shuffled peak |
|---|---:|---:|---:|---:|---:|
| Intact | 0.994680407 +/- 0.000628305682 | -0.0115741329 +/- 0.000690046585 | 105.319269 +/- 1.45048871 | 0.911891028 +/- 0.00129566571 | -0.013757065 +/- 0.000173152242 |
| Remove feedback | 0.993225669 +/- 0.00123180311 | -0.0118589918 +/- 0.00078477044 | 106.15197 +/- 1.26904328 | 0.905628197 +/- 0.00153868955 | -0.0135561047 +/- 0.000194645472 |
| Remove b | 0.963276037 +/- 0.0115455209 | -0.0105905958 +/- 0.000434071581 | 108.112134 +/- 1.13212014 | 0.896378368 +/- 0.00239802972 | -0.0129954602 +/- 0.000177111523 |
| Block | 0.96554428 +/- 0.0115829246 | -0.0102468216 +/- 0.000415884912 | 103.338916 +/- 2.23648968 | 0.853701227 +/- 0.00244552034 | -0.0118848299 +/- 5.9768557e-05 |

Paired Block-versus-Intact relative primary R2 change: -2.95165494 +/- 1.17208814 percent.
Empirical reductions43.6% (N),29.6% (T) are descriptive context, not targets fitted here.

## Exact paired tests

| Outcome | Contrast minus Intact | Mean difference | Median difference +/- SE | p | BH q |
|---|---|---:|---:|---:|---:|
| Primary R2 | Remove feedback | -0.00241491663 | -0.00124958128 +/- 0.000671155379 | 0.001953125 | 0.001953125 |
| Primary R2 | Remove b | -0.038049744 | -0.0318309246 +/- 0.0113416808 | 0.001953125 | 0.001953125 |
| Primary R2 | Block | -0.0451022808 | -0.0293656928 +/- 0.0116585969 | 0.001953125 | 0.001953125 |
| RRR rank | Remove feedback | 0.554409808 | 0.770422507 +/- 0.278831961 | 0.23046875 | 0.23046875 |
| RRR rank | Remove b | 2.54853982 | 3.16040974 +/- 0.942273096 | 0.015625 | 0.046875 |
| RRR rank | Block | -1.86728088 | -0.507935784 +/- 0.795888314 | 0.177734375 | 0.23046875 |
| RRR peak R2 | Remove feedback | -0.00595231979 | -0.00594278672 +/- 0.000318279929 | 0.001953125 | 0.001953125 |
| RRR peak R2 | Remove b | -0.0156279138 | -0.0149469953 +/- 0.00131836657 | 0.001953125 | 0.001953125 |
| RRR peak R2 | Block | -0.0610025372 | -0.0595286954 +/- 0.00222032893 | 0.001953125 | 0.001953125 |

Each outcome has its own three-contrast BH family; exact1024 sign flips of mean paired difference.
The same frozen10000 whole-network bootstrap rows determine all displayed network-median SEs.

## All-network primary and RRR values

| Network | Policy | Primary R2 | Prep K (capture) | Move K (capture) | RRR rank | Peak R2 | Shuffle peak |
|---|---|---:|---:|---:|---:|---:|---:|
| 1 | Intact | 0.995956658 | 5 (0.777799) | 2 (0.760915) | 93.6263018 | 0.91781085 | -0.0135843342 |
| 1 | Remove feedback | 0.987617649 | 5 (0.763684) | 3 (0.813019) | 95.3009441 | 0.911064858 | -0.0133715866 |
| 1 | Remove b | 0.963228048 | 6 (0.784919) | 5 (0.785250) | 96.7026886 | 0.89726163 | -0.0128669251 |
| 1 | Block | 0.967146121 | 7 (0.848845) | 6 (0.781908) | 94.8591724 | 0.858149313 | -0.0118956695 |
| 2 | Intact | 0.993983834 | 5 (0.792198) | 2 (0.758273) | 109.634152 | 0.912792579 | -0.0136552374 |
| 2 | Remove feedback | 0.987321289 | 5 (0.780446) | 3 (0.816579) | 110.418685 | 0.907951573 | -0.0134624776 |
| 2 | Remove b | 0.938828808 | 6 (0.794137) | 5 (0.786055) | 113.372101 | 0.902388267 | -0.0127026959 |
| 2 | Block | 0.889382802 | 6 (0.754494) | 6 (0.765507) | 107.85664 | 0.852751284 | -0.0117558799 |
| 3 | Intact | 0.996494786 | 4 (0.763327) | 2 (0.784578) | 102.432846 | 0.918376508 | -0.013890247 |
| 3 | Remove feedback | 0.995173866 | 4 (0.751447) | 2 (0.774479) | 103.536749 | 0.912267151 | -0.0136363653 |
| 3 | Remove b | 0.985990783 | 6 (0.800520) | 5 (0.800699) | 102.384946 | 0.904811962 | -0.0131487327 |
| 3 | Block | 0.877030019 | 6 (0.755330) | 6 (0.773756) | 96.5755844 | 0.853528788 | -0.0116899119 |
| 4 | Intact | 0.995103549 | 5 (0.784811) | 2 (0.794964) | 104.301239 | 0.911535134 | -0.0134904679 |
| 4 | Remove feedback | 0.99452508 | 5 (0.771419) | 2 (0.781574) | 104.419331 | 0.905241682 | -0.0134758442 |
| 4 | Remove b | 0.923554008 | 6 (0.779940) | 5 (0.759639) | 110.026111 | 0.88858588 | -0.0125390858 |
| 4 | Block | 0.960821011 | 7 (0.838549) | 7 (0.803452) | 103.089686 | 0.831678339 | -0.0118739904 |
| 5 | Intact | 0.991885424 | 5 (0.782109) | 3 (0.816166) | 108.027814 | 0.908553743 | -0.0135878742 |
| 5 | Remove feedback | 0.990287906 | 5 (0.766848) | 3 (0.806213) | 108.784126 | 0.903100947 | -0.0134537679 |
| 5 | Remove b | 0.975071198 | 6 (0.781224) | 5 (0.784058) | 108.368383 | 0.893238533 | -0.0127557513 |
| 5 | Block | 0.97498273 | 7 (0.838730) | 6 (0.775828) | 107.894372 | 0.853873666 | -0.0119246349 |
| 6 | Intact | 0.995499368 | 5 (0.786283) | 2 (0.759800) | 103.945658 | 0.910073886 | -0.0138588926 |
| 6 | Remove feedback | 0.994359281 | 5 (0.777300) | 2 (0.750930) | 105.262916 | 0.904435608 | -0.013789938 |
| 6 | Remove b | 0.971243138 | 6 (0.796480) | 5 (0.794526) | 107.626855 | 0.895495106 | -0.0132404284 |
| 6 | Block | 0.942184146 | 6 (0.762296) | 6 (0.783056) | 103.526252 | 0.850678032 | -0.0120965625 |
| 7 | Intact | 0.994257265 | 5 (0.781327) | 2 (0.762086) | 103.696573 | 0.91179093 | -0.0145027445 |
| 7 | Remove feedback | 0.993281795 | 5 (0.767195) | 2 (0.752522) | 104.332127 | 0.906014713 | -0.0144219791 |
| 7 | Remove b | 0.963324026 | 6 (0.780675) | 5 (0.779527) | 106.941005 | 0.895127601 | -0.0134763536 |
| 7 | Block | 0.973771912 | 7 (0.838929) | 6 (0.762664) | 103.151579 | 0.855076431 | -0.0122880233 |
| 8 | Intact | 0.995855258 | 5 (0.776383) | 2 (0.791617) | 106.3373 | 0.911991126 | -0.0142544729 |
| 8 | Remove feedback | 0.994677015 | 5 (0.762511) | 2 (0.780493) | 108.199261 | 0.905176679 | -0.0142563676 |
| 8 | Remove b | 0.935276319 | 6 (0.784608) | 5 (0.787581) | 112.105308 | 0.898890988 | -0.0131239953 |
| 8 | Block | 0.974690712 | 7 (0.841956) | 6 (0.779576) | 108.433465 | 0.858816433 | -0.0119446688 |
| 9 | Intact | 0.993707056 | 5 (0.771502) | 2 (0.797611) | 107.005495 | 0.915187804 | -0.0143810224 |
| 9 | Remove feedback | 0.992043897 | 5 (0.757517) | 2 (0.788201) | 107.265 | 0.909931348 | -0.0141641639 |
| 9 | Remove b | 0.93672196 | 6 (0.789467) | 5 (0.800718) | 109.118181 | 0.902866844 | -0.013403389 |
| 9 | Block | 0.971631785 | 7 (0.840881) | 6 (0.775702) | 106.534616 | 0.859601482 | -0.0118098797 |
| 10 | Intact | 0.993863289 | 4 (0.761123) | 2 (0.765264) | 110.008686 | 0.9046525 | -0.0136479693 |
| 10 | Remove feedback | 0.993169543 | 5 (0.779014) | 2 (0.753660) | 107.041024 | 0.898057302 | -0.0134511583 |
| 10 | Remove b | 0.972870759 | 6 (0.780392) | 5 (0.760431) | 107.855886 | 0.887819111 | -0.0125804097 |
| 10 | Block | 0.96394244 | 7 (0.842796) | 6 (0.761239) | 98.4218887 | 0.838585919 | -0.0116915058 |

## Matched-PC control

| Network | Contrast | Prep K | Move K | Intact R2 | Comparator R2 |
|---|---|---:|---:|---:|---:|
| 1 | Remove feedback | 5 | 2 | 0.995956658 | 0.994705449 |
| 1 | Remove b | 5 | 2 | 0.995956658 | 0.985218531 |
| 1 | Block | 5 | 2 | 0.995956658 | 0.956601417 |
| 2 | Remove feedback | 5 | 2 | 0.993983834 | 0.992783932 |
| 2 | Remove b | 5 | 2 | 0.993983834 | 0.98428601 |
| 2 | Block | 5 | 2 | 0.993983834 | 0.965339875 |
| 3 | Remove feedback | 4 | 2 | 0.996494786 | 0.995173866 |
| 3 | Remove b | 4 | 2 | 0.996494786 | 0.987202018 |
| 3 | Block | 4 | 2 | 0.996494786 | 0.96229468 |
| 4 | Remove feedback | 5 | 2 | 0.995103549 | 0.99452508 |
| 4 | Remove b | 5 | 2 | 0.995103549 | 0.979075121 |
| 4 | Block | 5 | 2 | 0.995103549 | 0.935320519 |
| 5 | Remove feedback | 5 | 3 | 0.991885424 | 0.990287906 |
| 5 | Remove b | 5 | 3 | 0.991885424 | 0.97754627 |
| 5 | Block | 5 | 3 | 0.991885424 | 0.946609849 |
| 6 | Remove feedback | 5 | 2 | 0.995499368 | 0.994359281 |
| 6 | Remove b | 5 | 2 | 0.995499368 | 0.980083345 |
| 6 | Block | 5 | 2 | 0.995499368 | 0.962087471 |
| 7 | Remove feedback | 5 | 2 | 0.994257265 | 0.993281795 |
| 7 | Remove b | 5 | 2 | 0.994257265 | 0.988039633 |
| 7 | Block | 5 | 2 | 0.994257265 | 0.977589077 |
| 8 | Remove feedback | 5 | 2 | 0.995855258 | 0.994677015 |
| 8 | Remove b | 5 | 2 | 0.995855258 | 0.984405164 |
| 8 | Block | 5 | 2 | 0.995855258 | 0.959709348 |
| 9 | Remove feedback | 5 | 2 | 0.993707056 | 0.992043897 |
| 9 | Remove b | 5 | 2 | 0.993707056 | 0.990414529 |
| 9 | Block | 5 | 2 | 0.993707056 | 0.920608641 |
| 10 | Remove feedback | 4 | 2 | 0.993863289 | 0.992006545 |
| 10 | Remove b | 4 | 2 | 0.993863289 | 0.98834698 |
| 10 | Block | 4 | 2 | 0.993863289 | 0.924984647 |

## Validation scope and interpretation boundaries

Recovery independently checks original saved states/rates/torques/transitions; no arm/event rerun or reselection.
All40 network/policy cases: maximum absolute fidelity discrepancy 0. Ten complete Intact preparations reused,30 missing preparation series recovered,40 missing neural movement series recovered. Original hand trajectories/events reused.
All40 Prep-GO/movement-start joins, frozen reference scales, original trial seeds, policy flags, fixed geometry and onset-window identities independently verified.
Primary audit directly recomputes all40 observed,4000 shuffled and60 matched fits and all selected penalties, pooled predictions and R2; covariance/eigen PCA threshold audit, fixed split/seed checks and neuron-wise feature spot checks.
RRR audit uses augmented QR independent of production SVD: all400 observed repeated nested searches and explicit held-out rank predictions, plus40 predeclared shuffle/repeat refits. All40000 remaining shuffle-search repeat summaries/selected penalties and rank/peak criteria checked from saved search arrays. This is not an independent rerun of every shuffled fit.
Do not interpret full-ensemble or target-pooled prediction as within-target-only prediction.
Irregular Block kinematics and trial-specific movement alignment remain potential interpretive limitations, not criteria for exclusion.
No behavioral prediction, speed axis, movement-end prediction, adaptation, target-jump, extra RRR variant, noise or geometry tuning.
All old artifacts remain protected; no staging, commit or push. Stop for scientific review.

## Scientific interpretation — mixed outcome, no retuning

The primary PCA-to-ridge result has the expected direction but not the
experimental-sized effect: the paired median Block reduction is only
2.951655 +/- 1.172088%, versus43.6% and29.6% in the manuscript. All policies
remain near ceiling. The full Block policy is not uniformly less predictable
than the remove-b policy. These findings do not establish quantitative
reproduction of the experimental neural-prediction loss.

Full-space RRR peak R2 decreases in all three contrasts versus Intact
(each BH q=.001953125); the Block paired median difference is
-0.0595286954 +/- .00222032893. Predictive rank is high in every policy
(ensemble medians approximately103-108), not a low-dimensional collapse.
The Block rank contrast is not significant (q=.23046875), nor is removal
of feedback (q=.23046875); removal of b modestly raises rank (paired median
+3.16040974 +/- .942273096, q=.046875). The rank outcome is therefore mixed,
not a general or monotonic reduction under component removal.

Panel e scores retained movement PCs; RRR scores all200 response neurons.
Their absolute R2 values are not interchangeable, and the secondary RRR
result must not replace the primary result to claim an empirical match.
No behavioral prediction or new mechanistic/model claim follows automatically.

## Final numerical and preservation verification

All17 new MATLAB files pass Code Analyzer. The full independent RRR audit
passes: maximum nested-loss discrepancy3.346940502524376e-10, held-out
prediction discrepancy1.5338841308221163e-12, R2 discrepancy
3.3306690738754696e-15, one-SE-rank discrepancy0, and the independently
refitted shuffle-loss discrepancy9.38598532229662e-9. All bootstrap summary,
paired-summary, exact p and BH q discrepancies are0. All three FIGs were
reopened (5+24+31=60 source/error-bar checks), and all three PNGs visually
inspected. Final SHA256 preservation passes all1842 pre-existing files.

The two startup defects and their bounded, exact-equivalence repairs are
recorded in history/EXECUTION_RECOVERY.md; failed-start evidence remains retained.
The completed numerical outputs were not overwritten or retuned. Publication
and final Git/inventory receipts are under the task manifest directory.
