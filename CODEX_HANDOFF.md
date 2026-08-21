# Codex Handoff: Intact V1 Snapshot Before HIVE Development

**Handoff recorded:** 2026-08-20 13:05 +03:00  
**Current local repository root:** `G:\My Drive\Monkey_codes\combined_analyses\cerebellar-preparatory-dynamics-model`  
**Project identifier in saved artifacts:** `finalized-intact-v1-retrained-2026-08-19`

## Read this first

This is the transfer record for opening the project in a new Codex session on the HIVE computer. The completed intact V1 run is preserved for diagnosis, but **the current intact checkpoint is not accepted as the scientific baseline**. Do not begin lesion comparisons from it.

The scientific team has decided that the next development direction will replace the generic cortical rate RNN with a Hennequin-style inhibition-stabilized-network (ISN) cortical backbone. This decision is recorded for continuity only. **Do not implement, infer, or parameterize that architecture yet.** The detailed scientific specification will be supplied in the next HIVE Codex session.

Before continuing on HIVE, read:

1. `AGENTS.md` for permanent repository/Codex rules.
2. `MODEL_SPEC.md` for the model that is actually implemented now.
3. `IMPLEMENTATION_NOTES.md` for technical implementation details.
4. This handoff and the latest entry in the Notion Codex Development Log.

## Current implemented V1 architecture

- Task: eight 6-cm center-out reaches at `[-90 -45 0 45 90 135 180 225]` degrees.
- Timing: target cue at 0 ms; independently sampled go delay 500-600 ms during training; canonical go at 550 ms; 500-ms minimum-jerk desired reach.
- Cortical inputs: continuous 8-D one-hot target identity and a target-independent scalar go signal.
- Cortex: 100-unit continuous-time tanh rate RNN, `tau = 20 ms`, Euler `dt = 5 ms`.
- Noise: configurable initial-state and ongoing Gaussian noise; finalized noisy values are both 0.05.
- Cerebellar generator: feedforward `9 -> 12 -> 5`; input is 8-D target identity plus normalized elapsed cue time; tanh hidden layer and unsupervised linear 5-D latent.
- Cerebellar restrictions: no go, cortical state/activity, plant state/feedback, target coordinates/angle, or desired/future kinematics. Its output is deterministic for target and elapsed cue time.
- Cerebellar-to-cortex projection: `U_cb` is `100 x 5`, randomly initialized once, present throughout intact trials, and fixed exactly during training.
- Motor output: linear `2 x 100` cortical readout to shoulder/elbow torque, not endpoint velocity.
- Plant: fixed horizontal two-link nonlinear arm, semi-implicit Euler at 5 ms, with documented damping, joint limits, differentiable safety penalties, and hard numerical safety clips.

All scientific and training parameters are centralized in `config/model_params.m`. The exact equations and parameter values are in `MODEL_SPEC.md`.

## Training and plasticity configuration

- Custom MATLAB `dlarray`/`dlgradient` loop using Adam and ordinary GPU `dlfeval`.
- Execution environment recorded in the run: NVIDIA GeForce RTX 3080.
- Balanced minibatch size 64: exactly eight trials per target, shuffled every update.
- Independent delay and noise draw per trial with dedicated deterministic RNG streams.
- Stage A: 1,000 deterministic updates, base learning rate `1e-3`.
- Stage B: 4,000 noisy updates, base learning rate `3e-4`; at Stage-B update 2,500 the rate becomes `9e-5` (factor 0.3).
- Adam settings: beta1 0.9, beta2 0.999, epsilon `1e-8`; global gradient-norm clip 1.
- Plasticity multipliers:
  - `1.0x`: `W_targ`, `W_go`, cerebellar hidden/latent weights and biases, `W_out`.
  - `0.1x`: `W_rec` via its actual parameter-specific Adam learning rate.
  - `0x`: `U_cb`, excluded from `dlgradient`, optimizer state, and updates.
- Validation: fixed balanced noisy set every 50 updates; checkpoint selected by minimum Stage-B validation behavioral loss.
- Objective: behavioral performance only—post-go position/velocity errors, terminal position/speed, strengthened pre-go speed, joint/torque penalties, and modest activity/weight regularization. Neural or lesion phenomena are not optimization targets.

RNG seeds are initialization 1729, training task/delay 1730, training noise 1731, validation task 1732, validation noise 1733, deterministic evaluation 1734, noisy evaluation 1735, deterministic delay 1736, and noisy delay 2736.

## Completed 5,000-update run

- Completed all 5,000 configured updates: 1,000 deterministic plus 4,000 noisy.
- Runtime: 9.384 hours.
- No early stop: validation continued improving near the cap.
- Best saved validation checkpoint: update 4,950.
- Best validation behavioral loss: `2.32613468`.
- Best validation unweighted components:
  - position `0.0386`;
  - velocity `0.1034`;
  - terminal position `0.0178`;
  - terminal velocity `0.0599`;
  - pre-go `0.0156`;
  - joint `1.5245e-5`;
  - torque `7.8203e-6`;
  - activity `0.1211`;
  - weight `0.0050`.
- Corresponding weighted behavioral contributions were approximately position `0.193044`, velocity `0.310063`, terminal position `0.445068`, terminal velocity `0.598724`, and pre-go `0.779234`.
- Normalized recurrent-weight change: `0.151211186`.
- Absolute `U_cb` change: exactly `0`.

The best checkpoint at update 4,950, only 50 updates before the hard cap, is evidence that the optimization had not reached a genuine plateau.

## Quantitative performance and acceptance status

Canonical evaluations use a 550-ms go delay. Deterministic evaluation has one trial per target; noisy evaluation has 20 trials per target.

| Metric | Deterministic | Noisy | Acceptance threshold | Status used for acceptance |
|---|---:|---:|---:|---|
| Movement trajectory RMSE | 0.010619 m | 0.011693 m | diagnostic | — |
| Velocity RMSE | 0.071743 m/s | 0.072049 m/s | diagnostic | — |
| Mean endpoint error | 0.005472 m | 0.007369 m | noisy <= 0.003 m | **fail** |
| Median endpoint error | 0.005999 m | 0.007374 m | diagnostic | — |
| Maximum target-averaged endpoint error | 0.007257 m | 0.009377 m | noisy <= 0.005 m | **fail** |
| Mean terminal speed | 0.052897 m/s | 0.053958 m/s | noisy <= 0.020 m/s | **fail** |
| Pre-go RMS endpoint speed | 0.027156 m/s | 0.028305 m/s | deterministic <= 0.002; noisy <= 0.015 m/s | **fail both** |
| Hard joint-limit contact fraction | 0 | 0 | noisy <= 0.001 | pass |
| Hard torque-saturation fraction | 0 | 0 | noisy <= 0.001 | pass |

Overall `validation.allPassed` is false. The endpoint, terminal-speed, and pre-go-stationarity criteria were not relaxed. **The current intact V1 baseline is not accepted.**

## Diagnostic findings

### Systematic pre-go drift and incomplete braking

- Deterministic and noisy pre-go RMS speeds are very similar (`0.027156` versus `0.028305` m/s).
- Deterministic and noisy terminal speeds are also very similar (`0.052897` versus `0.053958` m/s).
- Therefore the failures are not primarily a stochastic noise floor. They indicate systematic learned pre-go drift and incomplete end-of-reach braking in the current solution.
- The optimization still trades substantial error to stationarity and terminal stopping despite strengthened behavioral loss weights.

### Cerebellar latent and drive

- Mean cortical cerebellar-drive norm: preparation `0.893405`, movement `0.929558`.
- Mean late-preparation latent derivative norm: `2.837944 s^-1` over 400-495 ms.
- Mean late-preparation latent start-to-end change: `0.269579`.
- The time-conditioned 5-D cerebellar latent does not settle during late preparation. This is descriptive only; no settling loss was used and none should be added silently.

### PCA and jPCA

- Whole-trial target-averaged M1 PCA variance: PC1 `88.188%`, PC2 `5.395%`, PC3 `2.124%`.
- Movement-only PCA variance: PC1 `83.245%`, PC2 `7.142%`, PC3 `3.389%`.
- Movement jPCA diagnostic: skew-symmetric rotational fit `R^2 = -3.6358`; unconstrained fit `R^2 = -0.2633`; dominant frequency `1.919 Hz`.
- The rotational diagnostic is weak/negative and was reported without tuning or forcing rotational dynamics. PCA/jPCA never entered the loss.

### Delay robustness

Delays were evaluated at 500:10:600 ms in deterministic and noisy conditions.

- Deterministic mean endpoint error range: `0.002470-0.008094 m`; 600-ms minus 500-ms difference `-0.005624 m`.
- Noisy mean endpoint error range: `0.006334-0.009676 m`; late-minus-early difference `-0.003097 m`.
- Noisy trajectory RMSE range: `0.010685-0.013651 m`.
- Noisy terminal-speed range: `0.048406-0.060901 m/s`.
- Noisy pre-go RMS speed range: `0.024840-0.031375 m/s`.
- Later go times did not systematically worsen endpoint error in this run; the endpoint trend was negative. This does not rescue the failed canonical acceptance criteria.

### Plant safety

- Noisy shoulder range: `-26.101` to `28.714` degrees.
- Noisy elbow range: `49.557` to `117.196` degrees.
- Maximum absolute noisy shoulder/elbow torque: `0.035395/0.040144 N m`.
- Hard joint contact and torque saturation were both zero.

## Exact artifacts to transfer and preserve

Paths below are relative to the repository root and therefore portable to HIVE.

### Numerical results/checkpoint

| Path | Purpose | SHA-256 |
|---|---|---|
| `results/intact_model.mat` | Best checkpoint at update 4,950 plus metadata/validation | `BD95EDB7CA181F1A345444AFDD70F9723CBFAAB90E4BEF2B0649B7BA4F3DA1FC` |
| `results/intact_training_history.mat` | Full 5,000-update training/validation history and initialization snapshots | `ADAACF1A3A163BEFDFAB663FCCA8C784CF3604773F65BF3B7B06BC24F0D85364` |
| `results/intact_numerical_summary.mat` | Compact quantitative summary used in this handoff | `EEE72ED5654E6E18AF2ECA705C1ADE99514FF2403049D65CD4ACDE890FD3F9D1` |
| `results/intact_evaluation.mat` | Canonical deterministic/noisy diagnostics and delay results | `A4780E4767FD00EC898F85B05537436F6CFDB39173C3CD7B2DF82D4EED810ACA` |

### Diagnostic plots

Every listed base name has both `.fig` and `.png`; the completed snapshot contains 8 editable figures and 8 PNG previews, with no PDFs.

```text
plots/v1_intact/behavior/intact_reach_trajectories.{fig,png}
plots/v1_intact/behavior/intact_speed_profiles.{fig,png}
plots/v1_intact/behavior/intact_performance_vs_delay.{fig,png}
plots/v1_intact/neural/intact_m1_pca.{fig,png}
plots/v1_intact/neural/intact_m1_movement_pca.{fig,png}
plots/v1_intact/neural/intact_m1_jpca.{fig,png}
plots/v1_intact/cerebellar/intact_cerebellar_latents.{fig,png}
plots/v1_intact/plant/intact_joint_kinematics_and_torques.{fig,png}
```

Plotting source is in `figures/`; numerical analysis is in `analysis/`; model/task/training/plant code is in `src/`; centralized parameters are in `config/model_params.m`; `run_all.m` is the full clean-session workflow.

## Current Git state at handoff

Read-only `git status --short --branch` on 2026-08-20 reported:

```text
## No commits yet on main
?? .gitignore
?? AGENTS.md
?? CODEX_HANDOFF.md
?? IMPLEMENTATION_NOTES.md
?? MODEL_SPEC.md
?? README.md
?? analysis/
?? config/
?? figures/
?? plots/
?? results/
?? run_all.m
?? src/
```

There is no commit history, and all repository content is untracked. Consequently, the scientific files exist locally/through Drive sync but are not yet protected by a Git baseline. No commit, branch, push, deletion, cleanup, or result replacement was performed during this handoff.

## What is implemented

- Intact V1 target/task generation and minimum-jerk desired reaches.
- Generic 100-unit continuous-time cortical rate RNN.
- Time/target-conditioned 5-D feedforward cerebellar generator and fixed `U_cb` projection.
- Torque readout and differentiable two-link arm simulation.
- Staged balanced-minibatch custom training with explicit plasticity hierarchy and seeds.
- Best-checkpoint selection, saved history/model/evaluation/summary.
- Deterministic/noisy canonical evaluation, 500-600-ms delay evaluation, validation thresholds, PCA, movement PCA, jPCA, cerebellar diagnostics, plant diagnostics, and eight figure bundles.

## What is not implemented

- No accepted intact baseline.
- No cerebellar lesion or block simulation of any kind.
- No full-block, preparation-only, movement-only, graded-scaling, or retraining-after-lesion condition.
- No lesion phenotype tuning or lesion acceptance criteria.
- No V2 model or state-dependent cerebellar feedback.
- No Hennequin-style cortical backbone and no ISN implementation.
- No detailed specification yet for the next architecture.

## Recommended next HIVE step

1. Confirm the four result hashes after Drive transfer and confirm MATLAB/Deep Learning Toolbox/GPU availability on HIVE.
2. Establish a deliberate initial Git commit or other immutable snapshot before scientific changes, because the current repository has no commits.
3. Read the new team-supplied Hennequin/ISN specification and explicitly compare it with the current implemented V1 before editing code.
4. Update the specification and implementation plan only after the new scientific assumptions are frozen.
5. Do not run lesions and do not treat the current checkpoint as an accepted baseline.

No retraining, parameter change, result deletion, lesion experiment, or ISN/V2 implementation was performed as part of this handoff.
