# Cerebellar preparatory dynamics — final manuscript production

The frozen effective model combines cortical/base preparation, target-dependent state setting and anticipatory control in ten independently instantiated 200-unit recurrent ReLU networks. It uses eight targets, **eta=0, lambda=10, V=1, shared alpha=0.5 and beta_norm=1.25**, with primary initial/temporal noise 0.10/0.10. There is no generic residual kappa feedback. This is a functional decomposition, not a claim of anatomically separate cerebellar pathways.

For `f(x)=-x+W*ReLU(x)+h`, define `u_base=-f(xB)` and `b=f(xB)-f(x*)`.

| Condition | Preparatory input |
|---|---|
| Control / Intact | `u_base + b - L*(x-x*)` |
| Target-specific only | `u_base + b` |
| Anticipatory-control only | `u_base - L*(x-x*)` |
| Block | `u_base` |

The shared geometry was calibrated only to empirical PR change and alignment deficit, before downstream outcomes. Accepted networks, movement drive, readout, arm and noise streams are unchanged. The authorized 19 October Fig6g,h update expands both noise sweeps to eight levels (0.05–0.40), fixes the other source at 0.05 and reuses one exact 0.05/0.05 baseline. All other panel science and inference remain unchanged.

## Current manuscript panels

| Panel | Content |
|---|---|
| Fig6a | Preparatory PR change across anticipatory-control effort penalties |
| Fig6b | Expected−observed alignment across the same sweep |
| Fig6c | Hand-drawn static functional-model schematic |
| Fig6d | All-target illustration: network8, Option3, seed18003 |
| Fig6e | Fifteen-trial network8/target6 speed example |
| Fig6f | Same fifteen peak-position trajectories; all30-success inset |
| Fig6g | Control preparatory→early-movement R² versus noise |
| Fig6h | Relative Block R² deficit versus noise |
| ED7a | Fixed shared-geometry calibration-loss map |
| ED7b | Experimental/model PR — calibration target |
| ED7c | Experimental/model alignment — calibration target |

**Fig6d–f are success-conditioned illustrations only.** Their selected trials do not define manuscript statistical units. Peak-speed inference uses all trials and ten networks; the prespecified speed-matched dispersion assay uses six eligible networks 1,2,3,6,7,10. ED7b/c are calibration targets, not independent validation.

## Regenerate the paper

In MATLAB R2025b, from this repository root:

```matlab
restoredefaultpath
run_paper_figures
```

This regenerates eleven separate FIG/PNG panels (ten model-derived native panels and the static hand-drawn Fig6c), assembled `Figure_6` and `Extended_Data_Figure_7`, full-precision sources and validation receipts under `generated/paper_figures/`. It needs only version-controlled inputs. Canonical checked-in masters are in [plots/paper_ready/final_v3/production](plots/paper_ready/final_v3/production).

For numerical reproduction from accepted networks and deterministic streams:

```matlab
restoredefaultpath
run_paper_model('check') % actual network1 primary Intact/Block replay + prediction/behavior checks
% run_paper_model('all') % complete frozen components; computationally expensive
```

The full interface also provides `lambda`, `geometry`, `stochastic` and `illustrations` modes. It never retrains or reselects parameters. See [reproduction instructions](docs/paper_ready/final_v3/production/REPRODUCTION.md) for requirements, exact scope and executed checks. Full lambda replay requires Control System Toolbox; paper regeneration needs MATLAB graphics, not a licensed third-party checkout.

## Navigation

- [Model specification](MODEL_SPEC.md)
- [Fig6g,h noise update and executed candidate validation](docs/paper_ready/final_v3/production/NOISE_UPDATE.md)
- [Panel definitions, statistics and exact illustrative IDs](docs/paper_ready/final_v3/production/LEGENDS.md)
- [Code and source-data index](docs/paper_ready/PAPER_CODE_INDEX.md)
- [Publication cleanup and verification](docs/paper_ready/final_v3/production/PUBLICATION_CLEANUP.md)
- [Historical ED7d archive — excluded from current publication](archive/paper_ready/ED7d_retired_20261013/README.md)
- [Frozen inputs and source tables](data/paper_ready/final_v3)
- [Historical pre-production checkpoint](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/tree/16aed212496647858770733919fb34c628dac85f)

Stage1/2/3 foundation code and accepted assets remain preserved. Their historical diagnostics are not the manuscript-production interface. Large obsolete paper caches and review alternatives are retired after dependency validation; unique uncommitted historical evidence has a hash-verified external archive documented in the cleanup receipt. That archive is not a runtime dependency.

Completion of production is not new scientific acceptance. Stop for scientific review; no further fitting or model extension is authorized.

Current authority is Main_text_v12: Fig6a–h and ED7a–c only. ED7d was retired with exact source/data/code/interpretation preservation at checkpoint04a65d78d4901a8350473aa3b93ba1673d87fdd4; its archive is not a runtime dependency.
