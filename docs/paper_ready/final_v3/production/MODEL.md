# Frozen manuscript model

The final effective model has ten independently instantiated 200-unit recurrent ReLU networks, eight targets, eta=0, lambda=10, V=1 and **one shared alpha=0.5 / beta_norm=1.25**. The accepted recurrent weights, movement launch states, rank-two readouts, movement drive and two-link arm are immutable. Integration is 0.2 ms, stored activity/kinematics are sampled every 1 ms, and analysis epochs are sampled every 10 ms. Cortical tau is 150 ms. Native rates are source units, not automatically Hz.

For `f(x)=-x+W*ReLU(x)+h`, the target-specific cortical base is `u_base=-f(xB)` and the state-setting contribution is `b=f(xB)-f(x*)`. Preparation uses:

| Condition | Input |
|---|---|
| Control / Intact | `u_base + b - L*(x-x*)` |
| Target-specific only / remove L | `u_base + b` |
| Anticipatory-control only / remove b | `u_base - L*(x-x*)` |
| Cerebellar block | `u_base` |

There is **no generic residual kappa feedback** in the final dynamics. This is a functional/effective decomposition, not an assertion of separate anatomical pathways. Target-specific preparation runs from GO−500 ms to GO. At GO the frozen autonomous movement generator and common time-dependent movement drive take over. No post-GO or observation noise is added.

## Noise, geometry and prediction

Each condition has eight targets × 30 trials per network. The primary stochastic setting is 0.10 initial-state / 0.10 temporal noise. Each one-factor prediction sweep uses 0.05, 0.10, 0.15 and 0.20, with the other source held at 0.10. The shared 0.10/0.10 anchor is one dataset, not two independent samples. The component-removal comparison uses 0.20/0.20.

Standardized trial draws use `mt19937ar`, seed `310000000 + 10000*network + 100*target + trial`: 200 initial Gaussian values followed by a 200×2500 temporal Gaussian array. Temporal increments are multiplied by `s_temporal*sqrt(2*dt/tau)`. Conditions and amplitudes reuse the same standardized streams.

Geometry was selected only against the empirical paired PR change and expected−observed alignment deficit, over the fixed 6×6 alpha/beta grid. Index 24 was frozen before downstream results. No per-network fit or movement/prediction/QC-based geometry selection is made. ED7b/c disclose calibration, not independent validation. The 95% Control-derived alignment rule is distinct from the common strictly-greater-than-95% rule of the source-faithful anticipatory-control sweep in Fig.6a/b.

Prediction retains the released per-neuron reference scale, boundary-protected Gaussian rate averaging (SD30 ms; support±150 ms), condition-invariant subtraction, GO−100:10:0 preparatory features and kinematic-MO+0:10:100 movement features. Separate epoch/condition PCA retains at least 75% variance. Target-matched nested three-fold ridge uses 25 penalties `logspace(-8,4,25)` and the original first-minimum rule; R² uses pooled held-out residual sums of squares. Outer-fold seeds are `320000000+10000*network+target`; inner-fold seeds are `321000000+10000*network+100*outer+target`.

The versioned reference scale/covariance is a frozen upstream preprocessing asset, not an additional feedback term. Its historical normalization-reference recipe is retained as provenance. The runtime controller is always eta=0.

## Illustrations versus inference

Fig.6d is exactly Option3/seed18003, network8: four successful trials per target/condition, with arithmetic means of those same four paths on a 101-point movement-phase grid. Fig.6e/f share the frozen fifteen network8/target6 trials. These success-conditioned examples are not statistical units and are not used to recompute manuscript effects.

Fig.6e thin speeds are unsmoothed and movement-onset aligned. The selected-fifteen median is computed across active samples only, smoothed with the original 50-ms Gaussian over its complete available support with boundary renormalization, and then displayed through the last sample with at least eight active trials. Fig.6f uses each trial's unsmoothed own peak-speed position; its distance histogram uses all thirty successful trials per condition, centered on each condition's coordinate-wise median position. Paths stop at first entry into the 1.5-cm target zone. The illustrative replay seed is `610000000+1000000*condition+10000*target+attemptID`.

Peak-speed statistics retain all trials and all ten networks. The primary dispersion assay retains the exact within-target greedy matcher `abs(vI-vB)/abs(vB)<=0.05`, at least five pairs per target and five eligible targets per network. Eligible networks remain 1,2,3,6,7,10. The unmatched all-ten-network control is separate.

## Frozen inference

The network is the statistical unit. Descriptives are network medians ± sample SD of 10,000 whole-network bootstrap medians, with within-network percentage changes summarized separately. Paired tests use Anderson–Darling on network differences, then two-sided paired t or Wilcoxon as prescribed. Fig.6a/b each have their own eight-comparison BH family. Behaviour and calibration comparisons have no shared multiplicity correction. Four noise omnibus tests use Friedman df3, n10, raw p without cross-test BH or post-hoc tests. ED7d has three paired component-removal contrasts with BH across that family. The promoted `statistics.json` contains the unchanged full-precision values; regeneration never replaces them.

The exact K=0 categorical endpoint in Fig.6a/b retains tonic input `x*-h-W*ReLU(x*)`, with precisely zero feedback effort. The manuscript shorthand “No input” therefore means no anticipatory-feedback input, not no cortical input.
