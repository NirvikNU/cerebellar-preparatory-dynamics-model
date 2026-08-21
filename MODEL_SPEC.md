# Implemented Intact V1 Model Specification

**Implementation identifier:** `finalized-intact-v1-retrained-2026-08-19`  
**Status:** implemented and trained, but **not an accepted intact baseline**  
**Scope:** the current intact V1 only; no lesion/block condition and no V2/ISN implementation

This document describes what the repository currently implements. It is not a specification for the scientific team's proposed next architecture.

## Scientific question

The implemented V1 asks whether a low-dimensional feedforward, target-conditioned cerebellar signal can help organize cortical activity for accurate torque-driven, two-joint reaching.

## Task and timing

- Eight center-out targets are fixed at `[-90 -45 0 45 90 135 180 225]` degrees.
- Target radius is 0.06 m around the hand position produced by the initial arm posture, approximately `[0.15; 0.21]` m.
- Target identity is an 8-D one-hot cue supplied to cortex from cue onset at 0 ms through preparation and movement.
- Training cue-to-go delays are sampled independently on the 5-ms grid from 500 through 600 ms.
- Canonical evaluation uses a 550-ms delay. Delay robustness is evaluated at 500:10:600 ms.
- A target-independent scalar go input switches on at the trial's go time and is supplied only to cortex.
- The desired hand remains at the center before go and follows a 500-ms minimum-jerk endpoint trajectory after go.
- Training trials share a 1,100-ms tensor duration; trial-specific pre-go, movement, and terminal masks define the losses.

## Cortical rate RNN

The implemented cortical network is a 100-unit continuous-time tanh rate RNN with `tau = 20 ms` and Euler step `dt = 5 ms`:

```text
r(t) = tanh(x(t))

tau dx/dt = -x + W_rec r(t) + W_targ q + W_go g(t)
            + U_cb c_q(t) + sigmaDynamic noise(t)

x(0) = sigmaInitial epsilon
```

The finalized noisy condition uses `sigmaInitial = 0.05` and `sigmaDynamic = 0.05`. The cortex receives target identity only, never target angle or Cartesian target coordinates. The scalar go signal is target-independent.

## Feedforward cerebellar pathway

The intact cerebellar signal is `c_q(t) = F(q,t)`.

- Input: 8-D one-hot target identity plus one normalized elapsed-time-since-cue variable.
- Generator: `9 -> 12 -> 5`, with a tanh hidden layer and an unsupervised 5-D linear latent output.
- Cortical projection: a randomly initialized `100 x 5` matrix `U_cb`.
- `U_cb` is fixed exactly throughout training and excluded from `dlgradient`, Adam state, and optimizer updates.
- Cerebellar drive is present throughout every intact trial.

The generator receives no go signal, cortical state/activity, arm/joint/endpoint state, plant feedback, target angle/coordinates, or desired/future kinematics. For a fixed target and elapsed cue time, its output is independent of trial noise. No loss imposes latent semantics, settling, dimensionality, rotation, or an experimental neural signature.

## Motor output and two-link arm

The linear cortical readout produces shoulder and elbow torque:

```text
tauArm(t) = W_out r(t)
```

It does not directly read out endpoint velocity. The fixed horizontal arm ignores gravity and uses:

```text
L1 = 0.15 m       L2 = 0.21 m
m1 = 0.30 kg      m2 = 0.30 kg
lc1 = 0.07 m      lc2 = 0.12 m
I1 = 0.005 kg m^2 I2 = 0.009 kg m^2
D = [0.0050 0.0025; 0.0025 0.0050] N m s/rad
```

Initial joint angles are `[0; 90]` degrees with zero joint velocity. Joint limits are shoulder `[-45, 135]` degrees and elbow `[0, 135]` degrees. The torque guideline is 0.25 N m and the hard numerical safety limit is 0.50 N m. Integration is semi-implicit Euler at 5 ms. Differentiable joint/torque penalties are training terms; hard clips are numerical safety guards and are reported diagnostically.

## Plasticity configuration

Training starts from a deterministic fresh initialization. Adam uses parameter-specific effective learning rates:

```text
W_targ, W_go                         1.0 x base rate
WcbHidden, bcbHidden                 1.0 x base rate
WcbLatent, bcbLatent                 1.0 x base rate
W_out                                1.0 x base rate
W_rec                                0.1 x base rate
U_cb                                 fixed; excluded from optimizer
```

The completed run recorded normalized `W_rec` change `0.151211186` and absolute `U_cb` change exactly `0`.

## Training schedule and objective

- Balanced minibatch: 64 trials, exactly eight trials per target, shuffled each update.
- Each trial has independently sampled delay, initial-state noise, and dynamic noise from documented independent streams.
- Stage A: 1,000 deterministic updates at base learning rate `1e-3`.
- Stage B: up to 4,000 noisy updates at base learning rate `3e-4`, reduced by factor 0.3 after 2,500 Stage-B updates.
- Adam: `beta1 = 0.9`, `beta2 = 0.999`, epsilon `1e-8`; global gradient-norm threshold 1.
- Fixed balanced noisy validation set evaluated every 50 updates.
- Best checkpoint is selected by Stage-B validation behavioral loss.
- Early stopping is allowed only after at least 2,000 noisy updates and 1,000 updates without meaningful validation improvement (`1e-5`).

The behavioral objective contains:

- full post-go endpoint-position trajectory error, weight 5;
- full post-go endpoint velocity-vector error, weight 3;
- terminal endpoint-position error, weight 25;
- terminal endpoint-speed penalty, weight 10;
- pre-go endpoint-speed penalty, weight 50;
- joint-limit and torque penalties, each weight 0.05;
- cortical-activity regularization `1e-4` and trainable-weight regularization `1e-5`.

Position errors are normalized by reach radius. Velocity/speed errors are normalized by the minimum-jerk peak speed. Reported behavioral metrics remain in SI units.

There is no supervision of joint trajectories, joint velocity, torque, interjoint coordination, cerebellar latent coordinates, lesion effects, preparatory dimensionality/convergence, prep-to-movement prediction, rotational dynamics, or experimental neural findings.

## Explicit reproducibility seeds

```text
initialization             1729
training task/delay        1730
training noise             1731
validation task            1732
validation noise           1733
deterministic evaluation   1734
noisy evaluation           1735
delay evaluation           1736
noisy delay evaluation     2736
```

## Evaluation and saved outputs

Canonical evaluation includes one deterministic trial per target and 20 noisy trials per target at 550 ms. The complete 500-600-ms range is evaluated in both conditions. Diagnostics are whole-trial PCA, movement-only PCA, an unconstrained-versus-skew-symmetric movement jPCA fit, cerebellar drive magnitude, late-preparation latent derivative/change, reach behavior, speed, delay robustness, and plant safety/kinematics.

These diagnostics are post hoc and do not affect training.

The current saved outputs are:

```text
results/intact_model.mat
results/intact_training_history.mat
results/intact_numerical_summary.mat
results/intact_evaluation.mat
plots/v1_intact/behavior/*.fig and *.png
plots/v1_intact/neural/*.fig and *.png
plots/v1_intact/cerebellar/*.fig and *.png
plots/v1_intact/plant/*.fig and *.png
```

## Implemented-scope boundary

Only the intact V1 described above is implemented. There is no cerebellar lesion, full block, preparation-only block, movement-only block, scaling experiment, retraining after removal, state-dependent cerebellar feedback, V2 pathway, Hennequin-style cortical backbone, or ISN implementation.
