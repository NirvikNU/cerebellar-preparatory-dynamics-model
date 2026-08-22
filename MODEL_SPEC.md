# No-plant V2 implemented model specification

## Status

This document describes the intact no-plant V2 implementation on branch `v2-no-plant`. Static, forward, gradient, and two-update smoke validation passed before implementation commit `afee3d4bd6f304ef7ee9dfd2ee3b7f782c7f243f`. Full training results are not accepted until the intact behavioral criteria pass and the user reviews them. No cerebellar removal, scaling, shuffle, time shift, adaptation, or lesion retraining is implemented.

## Fixed cortical scaffold

- 200-unit ReLU rate network with 150-ms time constant and 5-ms forward-Euler integration.
- Exact unscaled official `why-prep-2` recurrent matrix, verified at runtime by SHA-256 `1E5DC654FD9EAE46E2F01C0BB67118378CE6AE9007227A1A3BF5488EA39B411D`.
- `W_rec` is fixed.
- Fixed baseline rates use the recovered deterministic lognormal-quantile construction with mean and standard deviation 5 Hz. Fixed background drive is `r0 - W_rec*r0`.

## Inputs and cerebellar pathway

- Persistent 8-D one-hot cortical target input for targets `[-90 -45 0 45 90 135 180 225]` degrees.
- Target-independent 75-ms cortical go pulse.
- The cerebellum receives target identity only through an 8→180 tanh→5 mapping.
- The 5-D state follows `tau_cb*dc/dt=-c+c_target`, implemented analytically from `c(0)=0` as `c_target*(1-exp(-t/tau_cb))`, with fixed `tau_cb=150 ms`.
- The cerebellum receives no go, elapsed-time input, cortical state, output state, desired trajectory, or desired velocity.

## Output and task

- Linear cortical-rate readout produces `[vx, vy]` in m/s.
- Position is the kinematic accumulation `p(t+dt)=p(t)+dt*v(t)`; there are no joints, torques, mass, inertia, muscles, or other biomechanical dynamics.
- Eight center-out targets lie 0.06 m from the origin.
- Training uses balanced 64-trial batches with eight trials per target and cue-to-go delays sampled from 500:5:600 ms.
- Trials contain target cue, instructed delay, go, 500-ms movement window, and 200-ms hold.

## Plasticity and objective

- Trainable: `W_targ`, `W_go`, both cerebellar-generator layers and biases, `U_cb`, and `W_out`.
- Fixed: `W_rec`, baseline rates/drive, cortical/cerebellar time constants, task geometry, and noise magnitudes.
- The velocity readout uses a `0.001` learning-rate multiplier. A two-update smoke comparison rejected larger provisional multipliers because their normalized Adam steps caused immediate pre-go output growth.
- Behavioral loss penalizes pre-go displacement/speed, increasing endpoint error during movement, terminal position/speed, hold position/speed, and modest velocity effort, activity, and trainable-weight magnitude.
- No neural-state, PCA, rotation, preparatory-geometry, minimum-jerk, or lesion objective is used.

## Optimization and validation

- Stage A: deterministic variable-delay acquisition, maximum 2,000 Adam updates at base learning rate `1e-3`.
- Stage B: variable-delay robustness with recovered 0.5-Hz initial and dynamic neural noise, maximum 1,000 Adam updates at base learning rate `1e-4`.
- Adam uses beta1 0.9, beta2 0.999, epsilon `1e-8`, global gradient clipping at 1, fixed validation sets, plateau learning-rate reduction, best-checkpoint preservation, and early stopping.
- A 20-update RTX 6000 Ada benchmark must predict no more than 60 minutes for 3,000 updates before full training can start.
- Intact targets: mean endpoint error at most 3 mm, worst target-averaged error at most 5 mm, deterministic pre-go RMS speed at most 0.002 m/s, terminal speed at most 0.02 m/s, stable hold, finite state, all-target success, and delay robustness.

## Current runtime-gate outcome

- GPU: NVIDIA RTX 6000 Ada Generation.
- Root cause: the original warm-up/timing helper requested zero accelerated-function outputs, while the update loop requested loss and gradients. MATLAB keys traces by output count, so this created a second trace at the first apparent post-update call. New fixed-shape task values and Adam-updated parameter values do not add traces.
- The execution path now keeps the eight trainable arrays in one fixed-order GPU `dlarray` vector, captures fixed GPU model tensors and configuration once, and uses one invariant two-output accelerated signature. Trial tensors remain fixed at 261 time samples with per-trial delay masks.
- MATLAB performs a one-time slow internal optimization on the sixth cached call without increasing cache occupancy. Six fixed-signature calls are therefore completed before timed updates.
- Exact-equivalence validation observed zero difference at tolerance `1e-6` in total loss, every loss component, parameters, every trainable gradient, gradient norm, cortical rates, velocity, and position.
- Corrected required 20-update benchmark: mean 2.794626 s/update, median 2.778389 s/update, first timed update 2.926799 s, updates 2–20 mean 2.787670 s, 2.0469 GiB GPU memory, unchanged cache occupancy, and estimated 46.461 minutes for 1,000 updates. Loss decreased from 210.073044 to 208.422943 and remained finite.
- The practical after-warm-up target of at most 3 s/update passes. The complete planned 3,000 updates would still estimate to 139.383 minutes, so the pre-existing 60-minute full-workflow launch guard remains active.
- Stage A and Stage B were not launched. No trained intact model, intact evaluation, or required final plot set exists yet.
