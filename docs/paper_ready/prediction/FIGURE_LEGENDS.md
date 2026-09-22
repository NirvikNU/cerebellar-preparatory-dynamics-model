# Prediction figure legends — validated arrays, scientific review pending

## Panel e — PCA-to-ridge neural prediction

Trial-by-trial preparatory-to-early-movement neural prediction in ten frozen
networks under Intact, remove-feedback, remove-b and full Block policies.
Each colored point is one independent network and thin gray lines connect
the same network; black-edged squares show the network median with SE of
that median from the frozen10000 whole-network bootstrap index rows.
Each network contributes eight targets and30 balanced trials/target.
Preparation rates are averaged over GO−100:10:0ms; response rates over
MO0:10:100ms using each trial's own20%-of-own-positive-peak kinematic onset.
Analysis-only Gaussian smoothing SD30ms uses1-ms samples, five-SD support
renormalized at protected boundaries (no post-GO contribution to Prep and
no pre-MO contribution to the early-movement response). Frozen Intact
per-neuron normalization and removal of the across-target invariant at each
aligned time precede time averaging. Full-balanced-ensemble PCA retains
the minimum75%-variance count separately per epoch and policy.

Nested target-stratified three-fold ridge selects the penalty on inner
training/validation data, then pools outer held-out predictions for
multivariate R2. Full-ensemble PCA is manuscript-matched, not strictly
inductive fold-wise feature learning. Negative values are retained.
Exactly three policy-minus-Intact exact paired sign-flip tests are corrected
together by BH. Empirical reductions43.6% (monkey N) and29.6% (monkey T)
are descriptive context only; the displayed model relative change is the
median of paired network ratios, not a fitted or rescaled empirical effect.
Parameters lambda10, alpha.5, beta_norm1, V1, saved kappa0 and both.10 noise
amplitudes were frozen before prediction. All noise and preparation inputs
end at GO; no model/noise/geometry change or trial selection used R2.

## Panel-e supporting controls

Top panels match Prep and movement PC counts separately to the smaller
count in each Intact/comparator pair and repeat the complete regression.
Bottom panels show the100-fixed-global-shuffle median floor per network
and policy, and the policy-specific retained Prep and movement PC counts.
Shuffle regression repeats nested penalty selection with fixed seeds and
folds; shuffles are not independent network observations. Points, paired
lines and network-median bootstrap SE follow panel e. Captured variance
and every network's primary, matched and shuffled values are in compact
source outputs, without an extra trial-balancing resampling layer.

## Extended Data — full-space ridge-regularized RRR

(a) Predeclared network1. RRR uses the same preprocessed240-by-200 Prep and
early-movement vectors directly, with no PCA dimensionality reduction.
Each integer rank1:200 is evaluated with target-stratified nested3-fold CV,
repeated10 times with prespecified fold seeds shared across policies/ranks.
Curves show the mean pooled held-out R2 and shading the SE across repeats,
not the bootstrap SE across networks. Circular markers indicate the peak
mean; dotted horizontal lines mark peak mean minus its repeat-SE; squares
and dashed verticals mark the first linearly interpolated crossing, bounded
below by rank1. The rank axis is logarithmic to display the entire fixed
range. RRR minimizes summed SSE plus lambda times squared coefficient norm
subject to the rank bound, as in the manuscript equation. Panel e retains
the distinct validated mean-SSE ridge convention. Penalty grid and tie rules
were locked before results; there is no outcome-dependent rank expansion.

(b) Predictive dimensionality and (c) peak mean CV R2 across all ten
networks/policies. Gray paired lines connect each network; squares/error
bars show network medians and frozen10000 whole-network-bootstrap SE.
Open triangles and their error bars in(c) give the median100-shuffle peak
floor, after independently repeating the full10-repeat nested RRR process
for each fixed global correspondence permutation. Rank and peak R2 each
have a separate three-contrast policy-versus-Intact exact sign-flip/BH
family. No shuffles, folds or trials are treated as independent networks.
The already balanced30trials/target are used directly, not pseudo-resampled
1000times. Neither rank nor R2 drives model selection or retuning.

## Interpretation boundaries

All prior movement-QC flags remain included. Target-pooled prediction is
not a within-target-only estimand; model networks are not empirical sessions.
Neural rates use frozen model-unit scales, not an empirical Hz floor.
Panel e scores the policy-specific retained movement PCs; RRR scores all
200 response neurons. Their absolute R2 values therefore refer to different
response spaces and should not be treated as interchangeable estimates.
No behavioral prediction, speed-axis analysis, movement-end prediction,
adaptation, target-jump or additional RRR variant is included. Scientific
claims await review and must preserve negative/mixed results unchanged.
