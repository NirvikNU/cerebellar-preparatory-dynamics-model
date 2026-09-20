# Implementation and independent-audit notes

These notes describe the implementation, not a passed production result.
Actual status comes from the saved receipts. Scientific settings are those
locked in PLAN.md before calibration.

## Trial, target and neuron indexing

Preparation state matrices are `[neuron, independent trial column]`.
The 240 columns are target-major: T1 trials 1–30, T2 trials 1–30, …,
T8 trials 1–30. A batch appends another 240 columns for each geometry.
Standardized noise is `[neuron, trial column, native step]`; the same draw
columns are reused across geometries and policies without drawing again.

Saved `meanRates` is `[saved time, neuron, target]` (501 × 200 × 8).
Saved `lateRates` is `[analysis time, neuron, trial column]`
(11 × 200 × 240). Its trial-preserving reshape is therefore
`[analysis time, neuron, trial, target]`, not a neuron-mixing flattening.
The physical data concept is time × neuron × target × trial; the actual
storage puts trial before target because trials vary fastest in the
target-major column layout. The mean is taken over dimension 3 after the
reshape to 11 × 200 × 30 × 8.

For population analysis, divide each neuron's target-averaged rates by
its own frozen scale; subtract the target mean independently at each time.
Permute `[time, neuron, target]` to `[time, target, neuron]`, then reshape
to 88 observations × 200 neurons. Each column contains one neuron only.
Finally center each neuron column over observations before covariance/SVD.
The independent audit builds each neuron's column explicitly in a loop,
using target-specific trial means and a covariance eigendecomposition
instead of the production SVD. Residual variance uses the 30 individual
trials, sample divisor 29, averaged over 11 times, 200 neurons and 8 targets.

## Intact reuse does not reuse a geometry-dependent input decomposition

For every α/β definition, algebra gives the same Intact vector field:

`f(x) − f(x*) − (κ₀I + L)(x − x*)`.

Thus one Intact trajectory per network supplies all geometry candidates.
However, the residual input u₀, state-setting term b, combined cerebellar
input and distance to xB do depend on geometry. Their component maxima are
recomputed for every candidate from the complete native Intact trajectory;
the selected-point distance to xB is recomputed from its saved states.
No geometry-specific bound is replaced by the original geometry's value.
Squared-norm matrix expansions are independently checked by direct sums.
Every Block candidate is simulated from the same noisy cue states with
its own frozen xB and the same residual policy used in its Intact pair.

## Timing and geometry are different ordered calibrations

The timing sweep reuses the exact saved P(λ), Q and per-network κ₀.
It does not solve CARE again. The λ=0.1 native trajectory is compared with
the saved biological Intact trajectory, and native increments are checked
against the reduced vector field. Readiness uses all native samples to
enforce sustained crossing, reported on the saved 1-ms grid. The selected
λ=10 has ensemble median readiness 74.25 ms. Full-state settling is not
substituted for Q-weighted readiness.

Geometry is evaluated from the noisy final-100-ms target means. The loss
uses the median of within-network PR differences and alignment deficits;
it is not the difference of separately pooled model medians. The empirical
target, by explicit contract, is the difference of exact pooled FIG bars.
The common admissible point is selected only after all 10 networks finish.
Lexicographic order is ascending α, then ascending normalized β.

## Alignment and uncertainty checks

Observed alignment projects Intact covariance onto the comparison's first
K=15 PCs, divided by the sum of the top 15 Intact eigenvalues. Null
projectors are covariance-shaped using the frozen full-reference covariance
and 10,000 fixed random draws. The expected scalar is evaluated on the new
Intact covariance, not copied from previous results. A separate QR basis
and direct draw-based scalar calculation check the production orthogonal
projector mean. The adaptive common count strictly exceeding 95% variance
is only sensitivity; a primary rank below 15 is infeasible.

Bootstrap units are whole networks. Shared frozen resample indices produce
10,000 network-median draws; their sample SD is the reported bootstrap SE.
The independent audit explicitly recomputes each median and the centered
sum of squares with divisor 9,999. Within-target trial IQR, empirical
resample SD and null Monte Carlo variability are not network-bootstrap SE.

## Movement and event validation

Each policy's achieved GO state enters the unchanged deterministic cortex,
movement drive, readout and arm. The wrapper retains native state/rate
extrema, torque and complete saved arm evidence, plus representative native
transitions. Independent checks recompute cortical transitions, closed-form
two-joint arm updates, own-peak movement onset and endpoint scatter.
`hypot(vx,vy)` and `sqrt(vx^2+vy^2)` are compared with a 1e-12 numerical
tolerance, not bitwise identity; event indices must agree exactly.

All abnormal trials remain in the data and figures. A missing neural
MO+0:100-ms window is judged against the frozen neural saved horizon
(0–598 ms), although the arm update includes the terminal 599-ms point.
No new prediction feature, fit, cross-validation fold or panel e is run.

## Operational-only repairs

The first production attempt stopped at Code Analyzer before simulations
because a compact nested loop in the report writer triggered alignment
warnings. Expanding that loop changed no equations or arrays. An unused
array-growth warning in the independent audit was removed by assigning
its complete output vector once. All such checks must pass again before
release. The initial preservation manifest is never replaced; the final
check separately identifies authorized AGENTS.md navigation and the new
paper-cache `.gitignore` entry, while all scientific assets remain protected.
