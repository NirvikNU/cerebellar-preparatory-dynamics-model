# PAPER-MODELLING-NOISE-SENSITIVITY-01 — completion

23 September 2026. Numerically validated and published; **STOP FOR SCIENTIFIC REVIEW**.
Starting release: `93e9d517d47b48579ef9d5bda6adacc44bf039d7`.
No noise/eta selection, RRR, retuning, post-GO/observation noise, new model,
deletion, staging, commit or push.

## Execution and reuse

- Ten frozen networks, eight targets, 30 trials/target; Intact/full Block at
  eta0/eta1. Only the five unique predeclared one-factor noise pairs.
- Exactly160 new cases/38,400 trajectories, completed once in4615.643s.
  Forty existing0.10/0.10 anchors were reused, not resimulated or duplicated
  as evidence. Total200 cases/48,000 trials; no trial exclusion.
- Released convergence/PCA75-ridge, noise/preparation/movement helpers invoked
  without modification. Existing eta1 observed/matched/2,000 shuffle controls
  reused; eta0 observed fits retained and only missing controls added.
-18,000 new/missing-control shuffles complete;20,000 saved shuffle rows total.
  No new scientific parameter or inferential-test family.

## Results for review

The full medians, bootstrap SE, paired effects, geometry and movement-QC tables
are in [REPORT.md](REPORT.md);17-digit CSV values are canonical source tables.

Both primary and matched-PC Block R2 are lower in every network at every tested
eta/noise point. C_Block-C_Intact is also negative in all100 network/setting
pairs. Relative Block R2 loss spans3.7684-18.4302% at eta0 and2.9517-19.1140%
at eta1. These are bounded one-factor results, not general noise robustness.

At eta0 C remains negative throughout. At eta1 C is positive in both conditions
for initial0.20/temporal0.10 and initial0.10/temporal0.05; it remains negative
at the other points. In the eta1 initial-noise sweep, the median across networks
of within-network mean Intact d_cue is2.325502/3.287281/5.514167, whereas d_prego
is3.580048/3.585153/3.530266. These descriptive distance means are not the
trialwise ratio used to aggregate C. A C sign change alone does not demonstrate
changed dynamical contraction, fixed-equilibrium stability or mediation of R2.

Temporal eta1 relative loss is nonmonotonic:5.7291%,2.9517%,19.1140%. Nothing
is selected from this curve. Matched-PC results and negative shuffle floors
remain in the report/source tables.

All200 cases are finite/within preparation bounds; zero missing prediction
windows, near-zero peaks, undefined C trials or undefined relative losses.
Nevertheless Block has93-365 boundary-peak and676-807 multiple-large-peak trials
per2,400. At temporal0.20/eta0, Block endpoint scatter is116.666+/-4.157mm and
target-separation/scatter0.751023+/-0.056382. Intact there has4 boundary and128
multiple-peak trials; Block365/682. All flags remain. Finite neural prediction
does not establish normal movements. No quantitative empirical fit is claimed.

## Independent validation

-160 new cases plus40 anchors; anchor C/geometry/observed fits match exactly.
- Independent160 observed and180 matched nested fits;18/18 predeclared
  shuffle1/network1 refits. All20,000 saved shuffle permutations, penalty
  selections, predictions and summaries checked. This is not a full independent
  refit of every shuffle.
- Maximum absolute discrepancies: standardized draws0; native transitions
  4.45e-16; C/distances1.76e-13; geometry8.00e-15; features2.85e-14; PCA2.56e-13;
  held-out predictions1.66e-13; R2 1.12e-15; bootstrap SE2.42e-13.
- Full-precision readback:200 cases,48,000 trial rows,100 paired rows PASS.
  Supporting tables contain1,600 target and20,000 shuffle rows.
- All18 new MATLAB files Code Analyzer PASS. Reference-only PCA leakage,
  neuron identity and bounded independent ridge unit checks PASS.
- No additional trajectory simulation for the saved-output audit.

## Figures and Notion

Both four-panel PNGs visually inspected: readable labels/legends, three levels,
shared anchor, zero references, negative ranges and individual-network lines.
No rendering correction was needed. Both FIGs reopened,176+88=264 plotted-source
and error-bar object checks passed.

- `plots/paper_ready/noise_sensitivity/fig/noise_sensitivity_absolute.fig`
- `plots/paper_ready/noise_sensitivity/png/noise_sensitivity_absolute.png`
- `plots/paper_ready/noise_sensitivity/fig/noise_sensitivity_paired.fig`
- `plots/paper_ready/noise_sensitivity/png/noise_sensitivity_paired.png`

Published two native PNGs with full captions under one **Final preparation-noise
sensitivity** section in the existing [gallery](https://app.notion.com/p/3e026c94be30810c8b2ce843260cd7db).
Both native hashes match local files. Ten prior native images and captions
unchanged; gallery now12. Parent retains four native children;99 retains its
seven child references unchanged. Agent Log prior chronology preserved.
Pages01/03, parent, Instructions, Handoff and START HERE now record completion
and stop for review. Readback and native-image receipts are in manifests.

## Preservation and Git boundary

All2,327 pre-existing files/169,192,893,554 bytes retain their SHA256 hashes.
All2,293 rows in the previous release's preservation manifest also matched the
initial inventory. Accepted models/controllers and every prior scientific
artifact remain unchanged. Required new raw evidence is ignored/local under
`results/paper_ready/cache/noise_sensitivity/`; other new files use only dedicated
analysis/figures/results/plots/docs/manifests `paper_ready/noise_sensitivity/` roots.

The bounded final Git check and full task inventory are recorded separately in
`artifacts/manifests/paper_ready/noise_sensitivity/FINAL_GIT.json` and
`TASK_INVENTORY.csv`. No staging or Git mutation is performed by that check.
There is no new release commit. Do not infer scientific acceptance or permission
for another run from numerical validation.

Long stages were coordinated with native process-exit waits; no repeated
intermediate progress-log polling loop. Initial static-check false-positive
evidence is retained. A publication-hash helper needed a tooling-only URL-parser
repair and a longer single-call wait; no figure/scientific data or upload was
changed/reposted. All completion receipts are actual readbacks, not planned work.

**STOP. No further scientific analysis or model choice.**
