# V2 Stage-A deterministic checkpoint metadata

Generated 2026-08-22 on branch `v2-no-plant` from runtime-optimized parent commit `0185fcbdbe1a73589cd78d4ae2bb6cc80c65ac1e`.

## Training

- Authorized/completed updates: 1,000 / 1,000
- Runtime excluding acceleration warm-up: 51.369149 minutes
- Best update: 1,000
- Best fixed-validation loss: 1.310932517
- Final training loss: 1.209411860
- Validation was still improving at the cap.
- Deterministic Stage A only; Stage B and lesion work were not run.

## Frozen-criteria outcome

- Mean endpoint error: 0.878543 mm — pass
- Worst target-averaged endpoint error: 1.561467 mm — pass
- Terminal speed: 0.003666663 m/s — pass
- Pre-go RMS speed: 0.016263906 m/s — **fail** against 0.002 m/s
- Mean hold error: 0.943769 mm — pass
- Mean hold speed: 0.004312878 m/s — pass
- All targets successful and all values finite — pass
- Delay evaluation passed endpoint, worst-target, terminal, and hold checks but failed pre-go speed. Delay pre-go RMS speed ranged 0.009138723–0.027335734 m/s.

## Neural and pathway diagnostics

- Mean/max cortical firing rate: 11.141671 / 109.860893 Hz
- PC1–PC3 variance: 54.604657%, 11.305000%, 9.896021%
- Mean target-centroid separation at go: 13.756213540 Hz RMS per unit
- Mean whole-trial target/go/cerebellar/recurrent drive norms: 2.301748 / 0.292262 / 61.179462 / 579.758301
- Trainable parameter Frobenius norms: `Wtarg` 6.563411; `Wgo` 5.085361; `WcbHidden` 17.385676; `bcbHidden` 1.231170; `WcbLatent` 6.365158; `bcbLatent` 0.197194; `Ucb` 5.395572; `Wout` 0.003794.

## Generated plot inventory

Nine editable `.fig` plus nine PNG files under `plots/v2_no_plant_intact/`: reach trajectories, speed profiles, pre-go motor output, performance across delay, cerebellar latent dynamics, cortical-drive magnitudes, cortical population PCA, preparatory-state geometry, and training diagnostics.

## Ignored reproducibility artifacts

- `stage_a_best_model.mat` — 182,532 bytes — SHA-256 `2A3E5EEAF7B45958DE5B66AB2671A99EF0D11440D785605B3D25123886907E3A`
- `stage_a_checkpoint_latest.mat` — 656,296 bytes — SHA-256 `758D0CF60B9776193F38A1575D69964D195088DD0E1D9FDAE04D8A16EB3A003F`
- `stage_a_training_history.mat` — 281,088 bytes — SHA-256 `C1876B757D3634EC1DD9478FE1DE6EC1C157986FA38952BC01981786272341E1`
- `stage_a_deterministic_evaluation.mat` — 2,923,501 bytes — SHA-256 `F023E7097343B60370B9E3FD7D7019F2A0559B40496B788C79F9457F842B3661`
- `stage_a_delay_robustness.mat` — 77,712 bytes — SHA-256 `371BFD4FBEE7DAFCCA994E1DF9C50922E5FBCE75819C8FC56A21BD206B186762`
- `stage_a_numerical_summary.mat` — 1,326,312 bytes — SHA-256 `23E2620312A2322740C575DB30AD2CE18E9BCDEF1535213958AC376F5E762BE7`

The exact-resume checkpoint contains current/best parameters, packed parameter vector, Adam moments, optimizer layout, update and learning rate, scheduler state, full history, validation task/noise, four RNG states, parameters, and next-update metadata.

## Recommendation

Continue Stage A only if explicitly authorized, because the best validation update was 1,000 and pre-go speed remained the sole failed frozen criterion. Do not begin Stage B automatically.
