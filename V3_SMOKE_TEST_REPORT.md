# V3 Romano–Hennequin hybrid scaffold smoke-test report

**Date:** 2026-08-22
**Branch:** `v3-romano-hennequin`
**Starting SHA:** `7f8463976c0faaaebe5af653aebb12c2796ff44a`

## Architecture

- Cortex: 200 ReLU units; `dt = 5 ms`; `tau = 150 ms`.
- Baseline: deterministic lognormal-quantile rates with 5-Hz mean and
  5-Hz standard deviation; `h = r0 - Wrec*r0`.
- One fixed 200-by-200 `Wrec` throughout every trial.
- Cortical inputs: persistent 8-D one-hot target identity and one
  target-independent 75-ms go pulse.
- Cerebellum: target identity only through a trainable 8→12 tanh→5
  generator; `tau_cb = 150 ms`; no go, clock, state, coordinate, angle,
  desired-trajectory, or future-kinematics input.
- Output: `[vx,vy] = Wout*r` and `p(t+dt)=p(t)+dt*v(t)`; no plant.
- Task: eight 6-cm targets in the established ordering; delay grid
  `500:10:700 ms`; canonical delay 600 ms; 500-ms movement and 200-ms hold.
- Smoke dynamics: `sigmaInitial = 0` and `sigmaDynamic = 0`.

## Hybrid recurrent construction

The seeded orthonormal basis is
`Q = [Qprep Qmove Qbackground]` with dimensions 10, 10, and 180.
One block operator contains:

- preparation scale 0.55 with diagonal profile `linspace(0.70,1.00,10)`;
- movement diagonal scale 0.45;
- movement non-normal rank-one feedforward scale 3.0;
- fixed preparation-to-movement coupling scale 0.75;
- background scale 0.20 with spectrum `linspace(-1,1,180)`;
- hybrid-basis RNG seed 31831.

The global normalization is the minimum of a 90%-of-reference spectral-
abscissa rule and a 25%-of-reference Frobenius-norm cap. Realized values:

- global normalization: **0.890154796**;
- spectral abscissa: **0.489585138**;
- Frobenius norm: **4.10728143**;
- non-normal commutator metric: **0.627518272**;
- `||Qprep'Qmove||_F`: **9.75e-08**.

The official Hennequin matrix is hash-verified and used only for these scale
references; it is not the V3 recurrent matrix.

## Fixed and trainable parameters

Fixed: `Wrec`, `Qprep`, `Qmove`, `Qbackground`, block architecture,
baseline rates/drive, `dt`, `tau`, `tau_cb`, task geometry, and timing.

Trainable: `Wtarg`, `Wgo`, `WcbHidden`, `bcbHidden`, `WcbLatent`,
`bcbLatent`, `Ucb`, and `Wout`. The packed trainable vector contains
**3,373 parameters**. `Wrec` is absent from the trainable list, packed vector,
and in-memory Adam state.

Initialization scales are target 0.05, go 0.55, cerebellar projection 0.05,
cerebellar hidden 1.0, cerebellar latent 0.1, and readout `1e-4`. The go
initializer was set to 0.55 after a forward-only threshold-margin diagnostic:
0.50 left the smallest post-go state at +0.0112 Hz, while the scaffold must
exercise the explicitly requested ReLU active-set mechanism.

## Inherited behavioral objective

| Component | Weight |
|---|---:|
| Pre-go position | 200 |
| Full pre-go velocity energy | 100 |
| Final-150-ms pre-go velocity energy | 50 |
| Movement endpoint urgency | 10 |
| Terminal position | 100 |
| Terminal velocity | 50 |
| Hold position | 100 |
| Hold velocity | 50 |
| Velocity effort | 0.001 |
| Activity regularization | 0.00001 |
| Trainable-weight regularization | 0.000001 |

No neural-state, PCA, alignment, covariance, subspace, empirical-trajectory,
lesion, or cerebellar-removal term is present.

## Smoke-test results

| Test | Result | Evidence |
|---|---|---|
| Forward simulation | PASS | All eight targets at 500, 600, and 700 ms; finite state, rates, cerebellar latent/drive, velocity, and position; expected 281-sample dimensions. |
| Input leakage | PASS | Cerebellar generator has exactly two function arguments and an 8-D target-identity input; forbidden inputs absent; one-column target-independent go; go exactly zero pre-go. |
| Fixed recurrence | PASS | Exactly one `Wrec`; absent from trainable fields and optimizer vector; discarded Adam plumbing step changed `Wrec` by exactly zero. |
| Gradient plumbing | PASS | Total loss 210.014633; finite, nonzero gradients reached all eight intended trainable arrays on NVIDIA RTX 6000 Ada Generation. |
| Effective dynamics | PASS | One actual prep/post-go ReLU unit changed active state; `A_eff` changed through `D(t)` while `Wrec` remained identical. |
| Checkpoint round-trip | PASS | Reloaded deterministic forward outputs matched exactly; maximum absolute difference 0. |
| Neural geometry pipeline | PASS | Per-neuron normalization, timewise target-mean subtraction, common `k=max(k95prep,k95move)`, bidirectional alignment, variance curves, and five-sample null plumbing all returned finite values. |
| Behavioral objective/masks | PASS | Every component finite; full and final-150-ms masks exclude go correctly at 500, 600, and 700 ms. |
| Code quality | PASS | MATLAB Code Analyzer: 0 issues across 25 MATLAB files; 0 section breaks; 0 active V2 executable/output-path references. |

For pipeline execution only, the untrained geometry calculation returned
`k95prep=7`, `k95move=7`, and common `k=7`. These values and the untrained
alignment values are not scientific model results and must not be interpreted
as evidence for or against the V3 hypothesis.

## Unresolved issues and boundary

No mathematical inconsistency or numerical instability was found in the
requested fixed-matrix construction. Behavioral acquisition and scientific
neural geometry remain entirely unevaluated because the scaffold is
untrained.

**No deterministic V3 training has been run.**
