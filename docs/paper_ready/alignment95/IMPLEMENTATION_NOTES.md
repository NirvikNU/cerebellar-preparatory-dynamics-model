# Exact rule and reuse proof

## Alignment, with a Control-derived dimension

Let C_I be the sample covariance of normalized, target-centered Intact
target-mean late-prep activity, with ordered eigenvalues e_I. Let B_B contain
the Block eigenvectors. The primary dimension is

K = min { k : sum(e_I(1:k))/sum(e_I) >= 0.95 }.

Observed = trace(B_B(:,1:K)' C_I B_B(:,1:K)) / sum(e_I(1:K)).
Expected is the mean of the same normalized expression with the K-dimensional
covariance-shaped random basis in place of B_B. The frozen full-reference
covariance shapes the draw; C_I and its top-K denominator evaluate alignment.
The null is not evaluated on a different epoch covariance or normalized with
a K15 denominator. PR is (sum eigenvalues)^2/sum(eigenvalues^2), using all PCs.

The direct audit builds one neuron per column explicitly, uses covariance
eigenvectors rather than the production data SVD, computes observed alignment
from projected sample variances, and compares orth-based random projectors
with independently accumulated QR projectors and 10,000 scalar null draws.
Boundary sentinels distinguish >=95% from >95% and Control-only from common K.

## Why one Intact spectrum can be reused across candidates

For f(x)=-x+W ReLU(x)+h, the frozen decomposition gives

u0+b-L(x-x*) = -f(x*) - kappa0(x-x*) - L(x-x*).

Thus the complete Intact vector field is independent of xB, alpha and beta.
With fixed initial state, fixed draws and fixed numerical sampling, the Intact
reference is the same for all candidates within a network. Reusing this saved
reference does not impose a common dimension on different spectra: identical
candidate references have identical K, while different networks are free to
have different K. All candidates retain their own Block basis and projection.
The full 360-row table records K explicitly, including physical rejects whose
metric remains unevaluated rather than inventing a simulated value.

Geometry-dependent component magnitudes do not share that cancellation.
If selection changes, the stored candidate-specific intact component maxima
and saved native/grid evidence are reused. Varied-noise Intact cases lacking
native states are replayed only to refresh those component bounds, with their
mean activity and GO states checked against the preserved identical Intact
trajectory. Required partial removals and new-policy movements use unchanged
helpers, seeds, gains, initial conditions and timing. Intact movement is reused.

## Data order and uncertainty

Saved late trial rates are [time=11, neuron=200, trialColumn=240], where
trialColumn is target-major with 30 trials per target. Reshape to
[11,200,30,8] and average dimension 3 gives [time,neuron,target]. Normalize
with scale(neuron), center across targets at each time, permute to
[time,target,neuron], then reshape to [observation=88,neuron=200]. No reshape
mixes neuron identities. Observations are centered before sample covariance.

Ten networks are the resampling units, with the unchanged 10,000 whole-network
bootstrap index rows. Paired differences are formed within network before
the network median and bootstrap SE. Median differences need not equal the
difference between marginal medians. Null Monte Carlo SE is a separate
quantity, not the figure's network-bootstrap error bar. Fixed half-trial
reliability uses the first half as reference and derives K from that half.
Each supporting time window derives K from its matching Intact reference.
Noise-only controls always retain the standard (.10,.10) Intact reference.

No new inferential test family, prediction fit, training or adaptive selection
is introduced. Frozen Stage-2 a/b retain their original pairwise common-K
methods and tests; their reuse is explicitly distinguished in the legends.

## Reused numerical preflight

The preserved results/paper_ready/preflight.json and preflight.mat validate
the unchanged preparation/movement wrappers, zero-noise biological reference,
noise draw identity, neuron sentinel and coupled .1-ms fine-step comparison.
That preflight was run at the frozen biological primary definition, before
the original paper geometry selection, with timing-selected lambda10. It is
not represented as a fresh fine-step test of the corrected selected geometry.
The present task changes no wrapper, dt, arm step, noise process or controller
gain; those checks remain applicable unchanged. New selected-policy saved
increments, arm updates, extrema, event and metric audits are separate.
