# V3 deterministic intact training report

## Scope and immutable boundary

This report records Step 3C on branch `v3-romano-hennequin`, starting from
commit `0056e6845c34ac4b8533d6c7b6ef6fb814f0d058`. The run used the committed V3
architecture, single fixed Romano–Hennequin recurrent operator, structural
bases, task timing, trainable/fixed policy, and behavioral loss unchanged.
There was no trial noise, cerebellar block, lesion, adaptation, parameter
sweep, objective tuning, or architecture change.

Exactly 3,373 scalar parameters were optimized: `Wtarg`, `Wgo`, `WcbHidden`,
`bcbHidden`, `WcbLatent`, `bcbLatent`, `Ucb`, and `Wout`. `Wrec`, baseline
rates/background drive, structural bases, recurrence construction, time
constants, time step, and task geometry remained fixed.

## Run configuration

- GPU: NVIDIA RTX 6000 Ada Generation
- maximum updates: 2,000
- completed updates: 2,000
- stop reason: maximum updates
- optimizer: Adam, learning rate `1e-3`, beta values `0.9/0.999`, epsilon
  `1e-8`
- global gradient clipping threshold: 1
- batches: 64 trials/update, exactly 8 trials per each of 8 targets, shuffled
- delays: independently sampled from `500:10:700` ms
- fixed deterministic validation set: 8 trials per target
- validation/progress interval: 25 updates
- recoverable checkpoint interval: 250 updates
- early-stopping patience: 400 updates
- learning-rate plateau patience: 200 updates; factor 0.5; minimum 1% of base
- accelerated gradient path: enabled, with 6 warm-up calls
- deterministic noise state: initial-state and ongoing neural noise disabled

The run took 124.676 minutes, or 3.740 seconds/update including the complete
training loop. It started from validation loss 209.995819 and reached its best
validation loss 19.6958599 at update 1,975. The final update had training loss
19.5388031 and validation loss 19.8292732. The best checkpoint was therefore
used for all evaluation. The learning rate remained `1e-3`; validation was
still making small, intermittent improvements near update 2,000 rather than
meeting the early-stopping rule.

## Best-validation loss components

| Component | Raw | Weight | Weighted contribution |
|---|---:|---:|---:|
| pre-go position | 0.02227597 | 200 | 4.455195 |
| full pre-go velocity | 0.02225315 | 100 | 2.225315 |
| late pre-go velocity | 0.04752969 | 50 | 2.376484 |
| endpoint urgency | 0.08875002 | 10 | 0.887500 |
| terminal position | 0.02427739 | 100 | 2.427739 |
| terminal velocity | 0.06533509 | 50 | 3.266755 |
| hold position | 0.008527945 | 100 | 0.852794 |
| hold velocity | 0.06408060 | 50 | 3.204030 |
| velocity effort | 0.04699755 | 0.001 | 0.0000470 |
| activity | 0.05775172 | 0.00001 | 0.00000058 |
| trainable weights | 0.14984301 | 0.000001 | 0.00000015 |

The dominant residual terms were pre-go position, terminal velocity, hold
velocity, terminal position, and both pre-go velocity terms.

## Deterministic canonical evaluation at 600 ms

| Target (degrees) | Endpoint error (mm) | Terminal speed (m/s) | Pre-go RMS speed (m/s) | Hold error (mm) | Hold speed (m/s) |
|---:|---:|---:|---:|---:|---:|
| -90 | 8.781 | 0.06360 | 0.03716 | 3.686 | 0.06284 |
| -45 | 7.858 | 0.06790 | 0.03697 | 3.509 | 0.06824 |
| 0 | 8.752 | 0.06562 | 0.03583 | 3.628 | 0.06518 |
| 45 | 9.030 | 0.06138 | 0.03682 | 3.658 | 0.05979 |
| 90 | 8.165 | 0.06414 | 0.03683 | 3.407 | 0.06326 |
| 135 | 9.576 | 0.06510 | 0.03533 | 3.905 | 0.06519 |
| 180 | 8.995 | 0.06400 | 0.03663 | 3.657 | 0.06357 |
| 225 | 9.042 | 0.06031 | 0.03768 | 3.765 | 0.05850 |

Aggregate canonical metrics and frozen criteria:

| Metric | Observed | Criterion | Result |
|---|---:|---:|---|
| mean endpoint error | 8.775 mm | <= 3 mm | fail |
| worst target endpoint error | 9.576 mm | <= 5 mm | fail |
| terminal speed | 0.06401 m/s | <= 0.02 m/s | fail |
| pre-go RMS speed | 0.03666 m/s | <= 0.002 m/s | fail |
| mean hold error | 3.652 mm | <= 5 mm | pass |
| mean hold speed | 0.06332 m/s | <= 0.02 m/s | fail |

Late pre-go RMS speed was 0.05438 m/s and maximum pre-go speed was
0.06138 m/s. All simulations were finite, with no NaNs or Infs.

## Delay-range evaluation and diagnosis

The complete `500:10:700`-ms sweep evaluated all eight targets separately.
Mean endpoint error fell monotonically from 15.164 mm at 500 ms to 8.775 mm
at 600 ms and 2.528 mm at 700 ms. Pre-go RMS speed rose from 0.03143 to
0.03666 and 0.04079 m/s at those delays. Mean terminal speed remained almost
constant at 0.06419, 0.06401, and 0.06374 m/s. Mean hold error was 8.631,
3.652, and 4.532 mm at 500, 600, and 700 ms, respectively; mean hold speed
remained approximately 0.0631-0.0636 m/s throughout.

The eight trajectory directions are correct, but output speed ramps during
the instructed delay, is already about 0.06 m/s at go, and remains near that
level through the movement and hold epochs. The nearly constant terminal and
hold speeds across delay, together with the monotonic endpoint shift, show a
systematic pre-go drift/incomplete-braking solution rather than a single bad
target. The intact scaffold therefore did not learn stationary reach-and-hold
behavior under the frozen objective within 2,000 updates. Because the best
validation result occurred at update 1,975, convergence was slow but not
formally exhausted. No corrective change was made after observing this
failure.

## Neural and pathway diagnostics

- cortical mean firing rate: 5.1009 Hz
- cortical maximum firing rate: 38.3531 Hz
- active cortical fraction: 0.9124
- cerebellar latent RMS: 0.78635
- cerebellar drive RMS: 0.88973
- trainable parameter norms: `Wtarg` 11.2081, `Wgo` 16.2783,
  `WcbHidden` 5.1461, `bcbHidden` 0.36662, `WcbLatent` 2.1016,
  `bcbLatent` 0.06846, `Ucb` 9.1530, `Wout` 0.0044112

Cortical activity remained finite and numerically plausible, without an
explosion. The target-conditioned five-dimensional cerebellar latent relaxed
smoothly to distinct target states and was independent of go, as specified.

## Fixed-recurrence verification

The best saved model was independently compared with a fresh reconstruction
from the committed V3 configuration after training:

- trainable scalar count: 3,373
- `isequal` result for `Wrec`: true
- maximum absolute `Wrec` difference: 0
- `Wrec` array SHA-256:
  `631CE20F4AD7F3D9A93CC2D0D04ECA44327A911D6C83B6E4EFACE9B4EA5C7997`

MATLAB Code Analyzer reported zero issues across 37 MATLAB files after the
run-support implementation was complete.

## Reproducible artifacts

Generated numerical artifacts are intentionally ignored under
`results/v3_hybrid/`:

| File | Bytes | SHA-256 |
|---|---:|---|
| `deterministic_best_model.mat` | 267390 | `0C45685C22AF2173160A7758D5FBEFFC97361BDF629157AB6652912179C8E725` |
| `deterministic_canonical_by_target.csv` | 1285 | `5C6EDE8510514C1945B301209CC3E5537D3AE362192B2C4909DB443D9F5ABE2C` |
| `deterministic_canonical_evaluation.mat` | 5036440 | `9C4A5A7EE74EDFA73355870C48E4041363E60478572DA174B1283EA899D8CC87` |
| `deterministic_checkpoint_latest.mat` | 712170 | `B64D305775049B09E1D1BEABBD33B0F89AAB8D09FAF96C96C320BDFEED267463` |
| `deterministic_delay_by_target.csv` | 23493 | `81413AF2838FAB20B26FFAC51FF4D25CF4E0941E9B46B649E8F371D99CDF028E` |
| `deterministic_delay_evaluation.mat` | 70064 | `E92EDAB15E63643FF589B69835034160F8BF80E848031A500C8EF870BADB1773` |
| `deterministic_summary.mat` | 271311 | `8218D34A0857DDBC52E52CBF2008C3651E910C04363F7F57A3467B52E3F5179E` |
| `deterministic_training_history.mat` | 209783 | `C0E50018F53DC1784A9A5E7F9DD1C1A579FD16980E660C95807BD4AD226D2F73` |

The checkpoint contains current and best parameters, Adam moments, packed
optimizer state, update and scheduler state, training history, validation
task/noise tensors, and all four RNG stream states needed for reproducible
continuation.

Seven editable FIG files and matching PNG files are ignored under
`plots/v3_hybrid/intact/`: hand trajectories, velocity profiles, pre-go
stationarity, output across delay, cortical activity, cerebellar activity,
and training diagnostics.

## Outcome

Step 3C is complete but the deterministic intact behavioral gate fails.
Recommended next action: stop and review the documented failure before any
additional training or scientifically meaningful change. Do not begin noise
training or cerebellar-block experiments from this checkpoint.
