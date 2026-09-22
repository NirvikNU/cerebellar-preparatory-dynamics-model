# Shared residual-stabilization diagnostic

PAPER-MODELLING-STABILIZATION-ETA-01. Completed numerical audit; scientific review pending.
No eta selected. No RRR, new noise, geometry tuning, staging, commit or push.
Eta=1 uses existing validated raw trajectories and PCA-ridge fits. Only the four lower eta values were simulated (19,200 new preparation/movement trials).
The passed preservation, equations/Jacobians and baseline reproduction checks were reused, not repeated.

## Network medians +/- fixed whole-network bootstrap SE

Ten networks are independent units; eight targets and 30 trials/target are nested. All 10,000 original bootstrap rows are reused.

### A: worst-target spectral abscissa (s^-1)

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | -6.81588364 +/- 0.0170775043 | -6.66666667 +/- 0.127242846 |
| 0.75 | -5.44747475 +/- 0.0482759988 | -5.32016928 +/- 0.0952039013 |
| 0.50 | -4.08204215 +/- 0.0580767282 | -3.97367189 +/- 0.0631677003 |
| 0.25 | -2.68929808 +/- 0.0681679712 | -2.62717449 +/- 0.031142712 |
| 0.00 | -1.31345017 +/- 0.0923914959 | -1.27929625 +/- 0.00159990777 |

### B: normalized mean GO bias

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 0.0990141401 +/- 0.00136809187 | 0.102975002 +/- 0.000910803918 |
| 0.75 | 0.132705657 +/- 0.00174883189 | 0.143704599 +/- 0.00188933229 |
| 0.50 | 0.209989297 +/- 0.00546007544 | 0.232744106 +/- 0.0026501105 |
| 0.25 | 0.376515218 +/- 0.0124389021 | 0.42410384 +/- 0.00938726211 |
| 0.00 | 0.722754873 +/- 0.0369979218 | 0.80581176 +/- 0.0232455672 |

### C: RMS GO spread (state units)

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 1.34975779 +/- 0.0123124707 | 1.41134582 +/- 0.0114807045 |
| 0.75 | 1.53006251 +/- 0.0130494206 | 1.61627842 +/- 0.0120527321 |
| 0.50 | 1.79869023 +/- 0.0137847365 | 1.92618246 +/- 0.0120969422 |
| 0.25 | 2.23077611 +/- 0.0106361059 | 2.43041298 +/- 0.0127061563 |
| 0.00 | 2.98043658 +/- 0.0245296296 | 3.30726042 +/- 0.039674025 |

### D: held-out model-native convergence

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | -0.0986700124 +/- 0.00885986704 | -0.141322282 +/- 0.00874830869 |
| 0.75 | -0.222635388 +/- 0.0104496456 | -0.286144582 +/- 0.00954365829 |
| 0.50 | -0.426765801 +/- 0.0124830958 | -0.51624279 +/- 0.012101896 |
| 0.25 | -0.76743685 +/- 0.0146118511 | -0.89565813 +/- 0.0156753432 |
| 0.00 | -1.32652859 +/- 0.0320202457 | -1.51307745 +/- 0.0317415594 |

### E: preparatory PR

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 3.4631909 +/- 0.12857273 | 6.75407975 +/- 0.0188918083 |
| 0.75 | 3.49067463 +/- 0.124982379 | 6.75728033 +/- 0.0136031067 |
| 0.50 | 3.52790629 +/- 0.107342466 | 6.75912965 +/- 0.01295275 |
| 0.25 | 3.55357063 +/- 0.0702038395 | 6.66091699 +/- 0.0404566641 |
| 0.00 | 3.46466637 +/- 0.0810046228 | 6.32797455 +/- 0.114631539 |

### F: pooled held-out R2

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 0.994680407 +/- 0.000628305682 | 0.96554428 +/- 0.0115829246 |
| 0.75 | 0.991994409 +/- 0.00120290804 | 0.962660093 +/- 0.00318482482 |
| 0.50 | 0.987148337 +/- 0.00090835438 | 0.921701375 +/- 0.00777283764 |
| 0.25 | 0.967780176 +/- 0.00340894677 | 0.860028883 +/- 0.0154079394 |
| 0.00 | 0.92424551 +/- 0.00654561269 | 0.812651781 +/- 0.0131927566 |

### MO (ms)

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 55.75 +/- 0.373818023 | 55 +/- 1.39789043 |
| 0.75 | 56 +/- 0.250107987 | 54.25 +/- 1.62580002 |
| 0.50 | 56 +/- 0.378531513 | 54.5 +/- 1.77203915 |
| 0.25 | 55.5 +/- 0.433737078 | 53.5 +/- 2.12131333 |
| 0.00 | 56 +/- 0.377945788 | 52 +/- 2.34524492 |

### Peak time (ms)

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 200.75 +/- 0.371640897 | 211.5 +/- 2.9617004 |
| 0.75 | 200.5 +/- 0.433427948 | 212.5 +/- 2.95456502 |
| 0.50 | 200 +/- 0.109745168 | 212.5 +/- 3.39077398 |
| 0.25 | 200 +/- 0.127310075 | 215.25 +/- 4.29840656 |
| 0.00 | 200 +/- 0.109796382 | 232.75 +/- 27.9138415 |

### Peak speed (m/s)

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 0.416579364 +/- 0.000736893059 | 0.219751785 +/- 0.00915487179 |
| 0.75 | 0.416533727 +/- 0.000829417704 | 0.223427889 +/- 0.00853890066 |
| 0.50 | 0.417175089 +/- 0.00092780828 | 0.225692959 +/- 0.00769210904 |
| 0.25 | 0.418108906 +/- 0.000908446739 | 0.23814312 +/- 0.00632093797 |
| 0.00 | 0.418733818 +/- 0.00108972894 | 0.267222441 +/- 0.0073828654 |

### Endpoint RMS (mm)

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 19.7533146 +/- 0.52040476 | 28.6335539 +/- 0.875727746 |
| 0.75 | 20.9378138 +/- 0.548434681 | 32.4619361 +/- 1.04976338 |
| 0.50 | 22.358841 +/- 0.600540543 | 38.0902877 +/- 1.29923499 |
| 0.25 | 24.1032357 +/- 0.701889641 | 46.8717858 +/- 1.65708885 |
| 0.00 | 26.3767237 +/- 0.91484192 | 61.6847352 +/- 2.03637067 |

### Target separation/scatter

| eta | Intact | Block |
|---:|---:|---:|
| 1.00 | 7.35727896 +/- 0.215065387 | 2.99314012 +/- 0.176241912 |
| 0.75 | 6.94699146 +/- 0.20647445 | 2.57078341 +/- 0.144392399 |
| 0.50 | 6.50994791 +/- 0.207661214 | 2.13944458 +/- 0.100623972 |
| 0.25 | 6.03938967 +/- 0.20257922 | 1.70479612 +/- 0.0953284257 |
| 0.00 | 5.56063132 +/- 0.206170783 | 1.38440748 +/- 0.1152704 |

### Alignment and paired prediction loss

| eta | Control95 K range | Observed (%) | Expected (%) | Deficit (pp) | Paired relative R2 reduction (%) |
|---:|---:|---:|---:|---:|---:|
| 1.00 | 5-6 | 31.995182 +/- 0.75727709 | 52.340264 +/- 0.71783832 | 20.925236 +/- 1.2465318 | 2.9516549 +/- 1.1720881 |
| 0.75 | 5-6 | 32.162116 +/- 0.63993427 | 52.30883 +/- 0.6115978 | 20.398621 +/- 0.83085838 | 3.0568863 +/- 0.32374434 |
| 0.50 | 5-6 | 32.046997 +/- 0.57722689 | 51.699199 +/- 0.56065566 | 19.9162 +/- 0.85600857 | 6.4502721 +/- 0.82559162 |
| 0.25 | 6-6 | 33.32624 +/- 0.70510076 | 49.381077 +/- 0.80537809 | 17.154128 +/- 1.0644098 | 11.053537 +/- 1.4900459 |
| 0.00 | 6-7 | 34.987352 +/- 1.8650636 | 45.320747 +/- 0.62951136 | 9.3927045 +/- 1.3175348 | 12.95998 +/- 1.5761052 |

## QC: every trial retained

| eta | Condition | Prep-bound failures / 10 | Near-zero / 2400 | Missing window / 2400 | Boundary peak / 2400 | Multiple peaks / 2400 |
|---:|---|---:|---:|---:|---:|---:|
| 1.00 | Intact | 0 | 0 | 0 | 0 | 0 |
| 1.00 | Block | 0 | 0 | 0 | 125 | 699 |
| 0.75 | Intact | 0 | 0 | 0 | 0 | 1 |
| 0.75 | Block | 0 | 0 | 0 | 136 | 710 |
| 0.50 | Intact | 0 | 0 | 0 | 0 | 1 |
| 0.50 | Block | 0 | 0 | 0 | 147 | 739 |
| 0.25 | Intact | 0 | 0 | 0 | 0 | 1 |
| 0.25 | Block | 0 | 0 | 0 | 187 | 758 |
| 0.00 | Intact | 0 | 0 | 0 | 0 | 9 |
| 0.00 | Block | 0 | 0 | 0 | 233 | 735 |

Finite-state/arm checks pass for saved cases. Native preparation limits are inherited unchanged; flagged points are not removed.
Undefined convergence values: 0 / 24000. Missing numerical prediction points: 0 / 100.

## Locked methods and interpretation boundary

Panel D is a **model-native cue-to-pre-go analogue**, not the empirical pre-cue analysis. Unsmoothed normalized ReLU rates at GO-500:10:0 form reference-only PCA; minimum K reaches >=95%. Each same-target fixed fold has20 reference and10 held-out trials; all trials are held out once. Cue (-500:10:-400) and pre-go (-100:10:0) projected states are averaged within window first, then compared to corresponding reference means. C=1-d_prego/d_cue; positive is contraction and negative is divergence. Numerically zero (<=eps(max(1,Frobenius norm of training observations))) or nonfinite cue distances remain undefined, never clamped. Trial/fold/target means are arithmetic. Reference-only95% is an explicitly predeclared model-analysis choice.

Panel B divides trial-mean GO equilibrium bias by the target trial-mean cue-to-equilibrium distance. Panel C uses the same raw model-state coordinates at every eta and measures RMS cloud width, not equilibrium bias.

Geometry uses unsmoothed target means, frozen per-neuron reference scale and across-target invariant removal. Intact alone supplies K>=95% for the Block basis, Intact denominator and original10000-draw covariance-shaped null. PR uses all eigenvalues. The null is not refitted to a favorable eta.

Prediction retains Gaussian SD30ms at1ms (support+/-150ms with protected boundaries), frozen normalization, aligned across-target invariant removal, GO-100:10:0 and own-MO0:10:100 averaging, epoch-specific full-ensemble PCA75 and nested target-stratified3-fold ridge over logspace(-8,4,25). PCA is manuscript-matched full-ensemble feature estimation, not strictly inductive foldwise PCA. Pooled held-out R2 and paired relative reduction are descriptive diagnostic outcomes, never selection criteria.

All local equilibria remain stable even at eta0 (prior completed audit); this does not establish stochastic contraction, complete settling or normal movement. No new inferential test family was introduced.

## Independent audit

```json
{
  "status": "PASS",
  "cases": 100,
  "stateError": 1.3322676295501878E-15,
  "convergenceError": 1.7141843500212417E-13,
  "geometryError": 8.8817841970012523E-15,
  "featureError": 2.6645352591003757E-14,
  "predictionError": 1.4699352846037073E-13,
  "lossError": 1.4551915228366852E-11,
  "r2Error": 4.4408920985006262E-16,
  "transitionError": 4.4408920985006262E-16,
  "torqueError": 0,
  "movementError": 1.7763568394002505E-15,
  "bootstrapError": 0,
  "undefined": 0,
  "reusedBaselineAudit": "baseline.json",
  "newTrajectoryReplays": 0,
  "etaOnePredictionAuditReused": "results/paper_ready/prediction/primary_audit.json"
}
```

## Provenance and output paths

- `PRODUCTION_PLAN.md`: resolved prospective implementation; prior stop/baseline reports preserved.
- `results/paper_ready/stabilization_eta/summary.mat/json`: all network metrics and bootstrap uncertainty.
- `results/paper_ready/cache/stabilization_eta/`:80 new raw case files,100 derived analysis files and10 null-projector records.
- `network_metrics.csv`, `target_metrics.csv`, `convergence_trials.csv`: compact/source tables, no omitted cases.
- `plots/paper_ready/stabilization_eta/{fig,png}/`: six-panel diagnostic, supporting movement QC and network1 kinematics.
- `artifacts/manifests/paper_ready/stabilization_eta/`: pre-existing baseline receipts plus new execution/figure/static receipts.

Old alignment95, panel-e and RRR artifacts remain separate and unchanged. HEAD remains70fff703f8fd3074bef62ca9954a03bef50e4d99; final Git receipt is recorded separately. STOP FOR SCIENTIFIC REVIEW.

## Panel-D reference-PCA dimensionality (descriptive)

| eta | Condition | Minimum / median / maximum K |
|---:|---|---:|
| 1.00 | Intact | 86 / 95.0 / 104 |
| 1.00 | Block | 85 / 92.0 / 99 |
| 0.75 | Intact | 79 / 87.0 / 96 |
| 0.75 | Block | 77 / 84.0 / 91 |
| 0.50 | Intact | 69 / 78.0 / 87 |
| 0.50 | Block | 68 / 74.0 / 81 |
| 0.25 | Intact | 58 / 67.0 / 76 |
| 0.25 | Block | 57 / 64.0 / 69 |
| 0.00 | Intact | 47 / 56.0 / 64 |
| 0.00 | Block | 47 / 53.0 / 58 |

These describe the240 network/target/fold reference fits per eta/condition, not independent replicates. Full fold-level counts are in convergence_trials.csv.
