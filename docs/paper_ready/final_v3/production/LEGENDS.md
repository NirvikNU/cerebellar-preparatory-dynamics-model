# Figure 6

Computational model for potential mechanisms of cerebellar contributions to preparatory activity in the motor cortex.

**a,b** Corrective-control effort-penalty sweep. Lambda increases from 0.1 to 100, followed by an exact zero-feedback endpoint displayed as infinity. Participation-ratio changes are relative to lambda = 0.1. Alignment deficit is expected minus observed alignment in percentage points. Thin curves show ten individual networks. Thick curves and error bars show the network median and its bootstrap standard error.

**c** Original hand-drawn schematic of the effective state-setting and corrective-control components. During Block, the movement drive and downstream motor system are retained.

**d** Individual hand trajectories for four successful trials per target and condition from network 8, ending at first entry into the peripheral target boundary.

**e** Speed profiles for fifteen successful target-6 trials per condition from network 8. Thin curves are individual unsmoothed trials. Thick curves are the selected-trial medians, Gaussian-smoothed over a 50-ms window for display. The median display ends when fewer than eight selected trials remain active.

**f** Hand trajectories for the same trials, with filled circles marking each trial's peak-speed position. The inset uses all thirty successful trials per condition and shows distances from the condition's coordinate-wise median peak-speed position. Successful trials enter the peripheral target boundary within 600 ms of GO. The examples in d–f are separate from all-trial behavioral inference.

**g** Control preparatory-to-early-movement R² across eight initial-state-noise amplitudes (dashed) or temporal-noise amplitudes (solid), from 0.05 to 0.40. The other noise source is fixed at 0.05.

**h** Absolute Control and Block R² across the same temporal-noise levels, with initial-state noise fixed at 0.05. Points and error bars in g,h are medians and bootstrap standard errors across ten networks, each with eight targets and thirty trials per target and condition. The Control temporal series is shared exactly between g and h.

Shuffled noise-floor R² is −0.01107 ± 0.00009 for Control initial noise, −0.010470 ± 0.000022 for Control temporal noise, and −0.010468 ± 0.000015 for Block temporal noise. These are mean ± SEM across ten network-specific medians over eight noise levels, after the median of 2,000 trial shuffles within each case. [Full-precision statistics](SUBMISSION_STATISTICS.md) include all eight paired Control–Block tests, bootstrap values and Monte Carlo uncertainty. The mean ± SEM of network medians of Control minus Block R² is 0.087319716383444795 ± 0.0078108922382883073.

# Extended Data Figure 5

Calibration of the state-setting component of cerebello-thalamocortical inputs.

**a** Calibration loss across the fixed six-by-six grid of shared geometry parameters. Alpha controls retention of the Control target geometry. Normalized beta adds target-related variance in an orthogonal population basis. The loss is the sum of squared relative deviations from the experimental Block-minus-Control PR change and expected-minus-observed alignment deficit. The shared minimum is alpha = 0.5 and normalized beta = 1.25.

**b** Experimental and model preparatory participation ratios during Control and Block.

**c** Experimental and model observed and covariance-matched expected alignment. Model points in b,c summarize ten independent networks as median ± bootstrap standard error. Experimental error bars retain the original empirical uncertainty estimates. These experimental geometry effects entered the calibration in a.

Full-precision source arrays, uncertainty estimates and selected-trial identities are supplied in `data/paper_ready/final_v3/tables/`. [Model](MODEL.md) records the exact equations, seeds and analysis conventions.
