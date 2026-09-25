# Primary conditional dispersion and unmatched robustness control

Speed-matched hand-position dispersion; 6/10 networks met the prespecified matching criterion.

Primary Main E includes networks 1, 2, 3, 6, 7 and 10. Networks 4, 5, 8 and 9
remain undefined for this assay only: four eligible targets, below the fixed
five-target minimum. Criteria remain 5% within-target greedy peak-speed mismatch,
five matched pairs/target and five eligible targets/network. No imputation.

| Assay | Networks | Intact median +/- bootstrap SE (cm) | Block median +/- bootstrap SE (cm) |
|---|---:|---:|---:|
| Primary speed-matched subset | 6 | 0.55267160633162271 +/- 0.0273189850320376 | 2.6840010552961773 +/- 0.33160946624453685 |
| Unmatched robustness control | 10 | 0.53818096754341627 +/- 0.018179041301185181 | 3.0147396368904831 +/- 0.20337064971540525 |

Primary paired test: **Wilcoxon signed-rank, n=6, p=0.03125** (two-sided).
Paired-difference Anderson-Darling p=0.021789232569363721 selected the test.
Original ten-network arrays/NaNs remain in summary.mat and figure_sources.mat.

The unmatched analysis is a descriptive robustness control, not Main E. It
uses all 30 trials/target, eight targets and ten networks without speed matching.
Both assays use mean Euclidean distance of own-peak-speed hand positions from
the coordinate-wise median, then equally average eligible targets within
network. No additional inferential family/p-value is introduced. Unmatched
Block dispersion is greater in all ten networks, but this control does not
remove speed-distribution differences.

Network is the independent unit. Both summaries use 10,000 paired network
bootstrap rows; the six-network subset uses original seed 2026091000, and the
all-ten control reuses frozen ten-network rows. Independent recomputation from
saved peak positions differs by at most 8.8817841970012523e-16. Separate sorted
order statistics and explicit sample variance verify bootstrap medians/SE.
No simulation, selection or fitting was rerun.

## Sources under results/paper_ready/final_v2/

- dispersion_resolution.mat: membership, bootstrap indices/draws, both assays,
  medians/SE and original test; JSON counterpart carries the audited summary.
- dispersion_matched_subset.csv: six paired network values (cm).
- dispersion_unmatched_all10.csv: ten paired network values (cm).
- dispersion_unmatched_targets.csv: 160 network/target/condition rows.
- dispersion_summary.csv: n, median and SE for each assay (cm).
- Original summary.mat, behavior_matching.csv and trial_metrics.csv preserve
  counts, trial identities, missingness and peak positions. Original
  test.difference remains in metres; panel summaries use cm; p is unchanged.

Frozen geometry alpha=.5, beta_norm=1.25, eta=0, lambda=10, primary noise .10/.10.
