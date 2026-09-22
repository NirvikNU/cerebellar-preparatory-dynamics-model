# PAPER-MODELLING-PANEL-E-PREDICTION-01 — validation receipt

Scientific computations and all three figure bundles are complete; stop for
scientific review. Starting checkpoint70fff703f8fd3074bef62ca9954a03bef50e4d99.
No scientific parameter, old result, staging, commit or push was changed.

| Check | Outcome |
|---|---|
| Frozen replay fidelity | PASS, all40 cases, every saved checked state/rate/torque/native-transition quantity matches exactly |
| GO joins, scales, seeds, policy flags, geometry, event windows | PASS, all40 cases |
| Primary observed/shuffle/matched recomputation | PASS,40 observed +4000 shuffled +60 matched fits; R2 error<=1.78e-15 |
| Full-space RRR observed audit | PASS,400 repeated nested fits and all200 held-out ranks; prediction error<=1.534e-12, R2 error<=3.331e-15 |
| RRR shuffle audit | PASS,40 independent shuffle-repeat refits; all40000 saved shuffle-repeat searches/selection/rank/peak summaries checked; not a full independent shuffle rerun |
| RRR one-SE rank | PASS, independent discrepancy0 |
| All summary/paired uncertainty and exact p/BH q | PASS, discrepancies0 |
| Code Analyzer | PASS, all17 new MATLAB files, STATIC_CURRENT.json |
| Figures | PASS, three FIG/PNG pairs;60 reopened source/error-bar checks; every PNG visually inspected |
| Native Notion images | PASS, allthree uploaded PNGs downloaded and SHA256-matched; all8 prior gallery images preserved |
| Final preservation | PASS, all1842 pre-existing files byte-for-byte unchanged, PRESERVATION_FINAL.json |

The primary paired Block R2 reduction is only2.951655 +/-1.172088%, versus
empirical43.6% and29.6%. It is directional, not quantitative reproduction.
RRR Block peak R2 is lower, but its predictive-rank contrast is not significant
(BH q=.23046875); ranks remain high. Full negative/mixed results are in
docs/paper_ready/prediction/RESULTS.md and compact numerical source files.

Runtime-only repairs preserved in docs/paper_ready/prediction/history/EXECUTION_RECOVERY.md: process-pool startup
failure; thread-worker V7.3 I/O moved to the client; identity-column indexing
repair before the first saved RRR case. Serial/thread and full batch checks
matched exactly, and the first saved case passed independent augmented QR.
No outcome-dependent scientific choice was made. Failed-start receipts stay.

INVENTORY.csv/json enumerate/classify allnew task artifacts, including ignored
raw caches. All are retained; no deletion. Inventory self-receipts and the
final Git receipt are explicitly excluded from self-hashing. FINAL_GIT.json
records actual read-only local/tracking/direct-remote checks and untracked
review files. A dirty worktree due to new untracked review files must not be
described as clean; the original tracked tree and index remain unchanged.
