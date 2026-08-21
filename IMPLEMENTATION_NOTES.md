# Retrained Intact V1 Implementation Notes

These notes document technical choices that are not additional scientific hypotheses.

- Training delays are sampled uniformly from `500:5:600` ms so every go transition lies on the integration grid.
- Every optimizer update contains 64 complete trials: eight trials for each target, with order shuffled from a dedicated training-task RNG stream.
- Training-task/delay sampling, training noise, fixed validation task, fixed validation noise, deterministic evaluation, noisy evaluation, and delay evaluation use documented independent seeds.
- All batched trials use a common 1100-ms tensor duration. Losses are masked to each trial's own pre-go, movement, and terminal samples.
- Elapsed cue time supplied to the cerebellar generator is mapped linearly from 0-1100 ms to `[-1, 1]`. It contains no go timing.
- `U_cb` remains a constant `dlarray` used in the forward computation but is excluded from `dlgradient`, optimizer state, and Adam updates.
- Adam is called separately for each trainable parameter with `baseLearnRate * parameterMultiplier`. This implements a true 0.1 effective rate for `W_rec`; gradients are not merely rescaled before Adam.
- Stage A uses zero noise for deterministic task acquisition. Stage B uses the finalized initial and dynamical noise scales of 0.05. The fixed checkpointing set always uses the finalized noisy condition.
- The configured loss weights are position 5, velocity 3, terminal position 25, terminal velocity 10, and pre-go speed 50. Joint/torque and activity/weight regularization remain modest. These weights target intact behavior only.
- Position errors are normalized by reach radius; velocity and speed errors are normalized by the specified minimum-jerk peak speed. Reported metrics remain in SI units.
- The plant equations and parameters are unchanged. The arm uses semi-implicit Euler at 5 ms, and hard clipping remains a reported numerical safety guard only.
- The ordinary GPU `dlfeval` path is used. A full 64-trial benchmark completed correctly, whereas `dlaccelerate` spent several minutes compiling and retraced when the curriculum changed noise settings; it was therefore slower and was interrupted.
- Best-checkpoint selection uses fixed noisy validation behavioral loss and begins only in Stage B. Training history retains the complete component losses, schedule, target/delay batches, seeds, and initial `W_rec`/`U_cb` arrays.
- Whole-trial PCA, movement PCA, jPCA, cerebellar settling, and delay trends are descriptive diagnostics only and do not affect optimization.
- The jPCA diagnostic fits derivatives in the leading movement-PCA subspace, compares unconstrained and skew-symmetric linear dynamics, and plots the dominant skew-symmetric plane. Weak or negative rotational fit is reported without tuning the model toward rotation.
- The code contains no lesion, cerebellar scaling, preparation-only block, movement-only block, retraining-after-removal, or V2 feedback pathway.
