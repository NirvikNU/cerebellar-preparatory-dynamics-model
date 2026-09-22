# Binding Notion contract snapshot

Source: Agent Instructions — Current Task (3c826c94be30817d8f51d9f6c8c2bc19).
Read 22 September 2026. The user's latest resume instruction additionally prohibits repeating the completed preservation, equation/Jacobian and eta=1 reproduction checks.
This snapshot records the current binding resolution and task, not historical stop sections.

<callout icon="✅" color="green_bg">
	**BINDING PANEL-D RESOLUTION — resume PAPER-MODELLING-STABILIZATION-ETA-01.** The remaining preflight choices are fixed prospectively, before any lower-eta convergence or prediction outcome. Use **reference-only 95%-variance PCA**, the existing fixed **three target-stratified folds (20 same-target reference trials / 10 held-out trials)**, and Euclidean distances between **window-mean projected states**. Resume from the completed eta=1 baseline; do not repeat passed preflight work.
</callout>
## Panel D — final binding implementation
The manuscript source specifies reference-only PCA and held-out distance-to-reference logic, but it does not specify a PCA variance-retention threshold for the convergence analysis. Therefore the following is an explicit **model-analysis choice**, not a claim that the empirical analysis used this exact threshold.
For each network, eta, condition (Intact/Block), target and fixed fold:
- Use the same fixed three-fold target-stratified partition already available for the prediction pipeline. Each fold has **20 same-target reference trials and 10 held-out trials**. Use identical fold identities across eta and conditions. Across the three folds, every trial is held out exactly once.
- From the **20 reference trials only**, build the preparatory PCA using the normalized neural/rate trajectories sampled at **GO−500:10:0 ms**.
- Retain the **minimum number of PCs reaching at least 95% of reference variance**. The 75% rule is specific to the PCA→ridge prediction assay and must not be reused here. Do not use all PCs; this convergence metric is intended to measure distance within a reference-supported preparatory subspace rather than reduce to full-space Euclidean distance.
- Project both reference and held-out trajectories into that reference-derived PCA basis.
- Define the reference cue state as the mean projected state of the 20 reference trials after first averaging each reference trial over **GO−500:−400 ms**; define the reference pre-go state analogously over **GO−100:0 ms**.
- For each held-out trial, first average its projected state within the same cue and pre-go windows, then compute Euclidean distances to the corresponding reference window-mean states:
	`d_cue = ||heldout_cue_mean - reference_cue_mean||`
	`d_prego = ||heldout_prego_mean - reference_prego_mean||`
- Define model-native convergence as `C = 1 - d_prego/d_cue`. Positive C means contraction toward the target-specific reference state; C=0 means no net contraction; negative C means divergence.
- If `d_cue` is numerically zero/nonfinite, mark that held-out value undefined and report/count it; do not clamp or add an arbitrary denominator constant.
- Average C across the ten held-out trials within fold, then across the three folds for target, then summarize targets within network using the same aggregation convention as the other stabilization panels. Preserve fold/target-level values in source tables.
This panel is explicitly a **model-native cue→pre-go analogue**, not the exact empirical pre-cue GO−900:−800 analysis.
Everything else in PAPER-MODELLING-STABILIZATION-ETA-01 remains unchanged: eta grid, panels A–C/E–F, movement/QC, no RRR, no eta selection from R², no new noise or retuning.

## Current task — PAPER-MODELLING-STABILIZATION-ETA-01
### Scientific question
Test whether the current paper model's generic residual stabilizer is masking a cerebellar-dependent difference in preparatory-state convergence. The hypothesis is that generic cortical/residual stabilization may be modest, while the intact condition has additional structured prospective feedback that stabilizes movement-relevant preparatory deviations. Full Block lacks that structured feedback.
This is a **diagnostic sweep**, not a request to tune prediction. Show what happens as stabilization is weakened and stop for scientific review.
### Two conditions only
Do **not** run the previously proposed (x\^B+L) counterfactual or a 2×2 equilibrium-location × feedback design.
For each network and target, use the existing corrected paper geometry and define one shared residual-stabilization multiplier:
`kappa_n(eta) = eta * kappa0_n`, with `eta = [1, 0.75, 0.5, 0.25, 0]`.
Use the same `eta` in both conditions:
- **Intact:** `tau*dx/dt = f(x) - f(x*) - [eta*kappa0*I + L]*(x - x*)`
- **Block:** `tau*dx/dt = f(x) - f(xB) - eta*kappa0*(x - xB)`
Intact retains the existing structured prospective feedback `L`; full Block has no `L`. The point is to ask whether reducing the common nonspecific stabilizer exposes a selective convergence deficit when cerebellar-dependent prospective feedback is absent.
Recompute the state-setting term consistently at every `eta`:
`b_eta = f(xB) - f(x*) + eta*kappa0*(x* - xB)`.
This keeps `x*` as the intended Intact equilibrium and `xB` as the intended Block equilibrium whenever locally stable. Do not retain the old `b` after changing `kappa0`.
### Everything else frozen
Keep the corrected paper calibration fixed: `lambda=10`, `alpha=0.5`, `beta_norm=1`, V realization 1, the same ten networks, eight targets, 30 trials/target, model dynamics, movement generator, readout, arm, integration/sampling, normalization, seeds and common standardized draws. Keep preparation noise exactly at (s_\{init\}=0.10) and (s_\{temporal\}=0.10), both ending at GO. **No post-GO process noise, no observation noise, no new noise sweep, no reset, no post-GO correction.**
Do not expand the `eta` grid. Do not alter `L`, `Q/P`, `lambda`, `alpha/beta`, V, the noise amplitude, or any movement parameter after inspecting results.
### Six-panel diagnostic figure
Generate one compact paper-review figure with (eta) on the x-axis and Intact and Block shown throughout. Network is the independent unit; show individual network values where legible and network median ± the existing fixed whole-network-bootstrap SE.
**A — Local stability.** For every target equilibrium, compute the actual closed-loop Jacobian and spectral abscissa (largest real eigenvalue). Summarize the worst target within network. Show the zero boundary explicitly. Retain marginal/unstable cases rather than silently repairing them.
**B — Systematic failure to reach the intended equilibrium.** For each target, compute the Euclidean distance between the **trial-mean GO internal state** and that condition's own equilibrium ((x\^\*) for Intact; (x\^B) for Block). Normalize by that target's cue-to-equilibrium distance for comparability and summarize targets within network. Also retain raw distances in source tables.
**C — Trial-to-trial GO dispersion.** Separately from panel B's mean bias, quantify the width of the GO-state cloud within each target as the RMS Euclidean distance of individual GO states from that target's **trial-mean GO state**. Use the same frozen state coordinates/normalization across (eta); summarize targets within network. This panel measures variability, not distance of the mean from equilibrium.
**D — Model-native held-out cue→pre-go convergence (binding user resolution, 22 September 2026).** This is a model-appropriate analogue, not the exact manuscript pre-cue analysis. Use only target-matched reference/held-out trials. Fit preparatory PCA using reference trials only on normalized activity at GO−500:10:0 ms and project held-out trials into that subspace. Compute each held-out trial’s Euclidean distance from its target-specific reference mean in GO−500:−400 ms (d_cue) and GO−100:0 ms (d_prego). Define `C = 1 - d_prego / d_cue`; positive values indicate contraction. Average held-out trials/targets within network and condition. Do not recreate the experimental GO−900:−800 window or introduce pre-cue noise. The final binding resolution at the top fixes reference-only PCA retaining the minimum ≥95%-variance count, the existing three same-target folds (20 reference / 10 held-out), and distances between window-mean projected states. Other panels are unchanged.
**E — Achieved preparatory geometry.** Recompute late-preparatory PR and Intact→Block alignment at every (eta) using the corrected paper rule: Control/Intact supplies the minimum K reaching ≥95% variance separately for each network/(eta); the same K defines the Block basis width, Control denominator and covariance-shaped null. PR uses all eigenvalues. Present PR and alignment as two compact mini-axes within panel E if necessary; preserve absolute values and the alignment deficit in source tables.
**F — Held-out prep→early-movement prediction.** At every (eta), run the already validated **PCA→ridge** neural prediction analysis only: manuscript preprocessing, Prep and early-movement epoch-specific PCA retaining ≥75% variance, target-stratified nested three-fold ridge and pooled held-out R². Plot Intact and Block R² versus (eta), and tabulate the paired Block-relative reduction. **Do not use R² to choose, reject or refine (eta).** No RRR in this task.
### Supporting movement/QC gate
Movement QC is required but is **supporting, not one of the six main panels**. Launch the unchanged deterministic post-GO movement from every achieved GO state and report the existing QC metrics versus (eta): finite-state/input/arm checks, near-zero/missing windows, boundary peaks, multiple-large-peak flags, MO/peak-time/peak-speed distributions, endpoint dispersion and target separation/scatter. Do not exclude flagged trials and do not retune from movement appearance. Mark any (eta) for which preparation or movement becomes numerically/physically inadmissible.
### Interpretation/selection rule
This run may reveal that lower (eta) leaves Intact well controlled by (L) while Block becomes less convergent, or it may not. Record either result unchanged.
**No automatic (eta) selection in this task.** In particular, do not choose an (eta) because panel F resembles the experimental R² loss. The six curves are diagnostic evidence to be reviewed jointly. Any later decision to nominate a stabilization regime must be made explicitly after review and should be based on the non-prediction dynamical/convergence evidence and admissibility, with prediction treated as an outcome.
### Preservation and stopping rule
The completed alignment95, panel-e and RRR outputs are scientific provenance and must not be overwritten, removed, relabeled or silently replaced. The current prediction-review artifacts are untracked; inventory/hash them before new work and preserve them. Put all new code/results/docs/figures under a new stabilization-eta-specific root. Do not stage, commit or push unless separately authorized.
Independently audit the equations, (b_eta), Jacobians, state-distance/dispersion calculations, exact convergence implementation, Control95 geometry, PCA→ridge folds/R² and movement QC. Reopen/check editable FIG objects and matching PNG.
**STOP FOR SCIENTIFIC REVIEW after the six-panel stabilization figure and supporting QC. No RRR, behavioral prediction, movement-end prediction, adaptation, target-jump analysis, new parameter family or further model revision.**

