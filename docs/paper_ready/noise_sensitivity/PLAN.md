# PAPER-MODELLING-NOISE-SENSITIVITY-01 — locked plan

Authorized 23 September 2026, starting release
93e9d517d47b48579ef9d5bda6adacc44bf039d7. This plan precedes new outcomes.
Only this bounded task supersedes the released stop. No staging, commit, push,
deletion, RRR, parameter selection, or modification of released assay helpers.

## Coverage and reuse

Ten networks, Intact/full Block, eta=[0,1], noise pairs in this fixed order:
[.05,.10]; [.10,.10]; [.20,.10]; [.10,.05]; [.10,.20]. Each case has eight
targets and 30 trials/target. Forty anchors are loaded from released eta
analysis/raw caches (eta indices 5 and 1). The anchor is used once, including
in both sweep displays. Exactly 160 new cases, at most 38,400 new trajectories.
Eta=1 controls are reused from prediction primary/matched caches. Eta=0 has
primary fits but lacks shuffle/matched controls; only those missing controls
are computed, retaining and verifying its original observed fit.

## Frozen implementation

Invoke paper_noise, paper_prepare, eta_move, eta_case/eta_convergence,
pe_features, stage3_prediction_ridge, paper95_geometry/paper95_compare and
stage2_bootstrap without modification. Scale the controller's kappa0 by eta
before paper_prepare, which recomputes b_eta. All other frozen network,
controller, geometry, timing, movement/arm and normalization settings remain.
Native dt=.0002 s; tau=.15 s; save1 ms; prep GO-500:0 ms; no post-GO noise.
Seed=310000000+10000*network+100*target+trial. The initial 200 normal draws and
subsequent 200-by-2500 process draws retain the original indexing. Same draws
are scaled, not regenerated with different seeds, across all comparisons.
Folds: original 320000000/321000000 families. Shuffle seed
322000000+10000*network+100*rep, reps1:100. Use frozen 10000 bootstrap rows.

Convergence uses reference-only centered PCA95, three same-target20/10 folds,
window-mean distances GO-500:10:-400 and -100:10:0, original denominator guard,
and trial/fold/target averaging. Preserve every distance, ratio, K, capture,
negative C and undefined result. This is a model-native analogue, not the
empirical pre-cue assay or a fixed-equilibrium contraction measure.
Prediction uses released protected30-ms smoothing, frozen neuron scales,
aligned invariant removal, prep-100:10:0 and ownMO0:10:100 means, full-ensemble
epoch-specific PCA75, original nested3-fold mean-SSE ridge25 penalties,
unpenalized intercept/ties, pooled held-out R2. Full-ensemble feature estimation
is disclosed. Matched-PC and100 correspondence shuffles are supporting controls.

All bounds and QC remain unchanged. A safety/bounds or required-window failure
is retained and affected estimates are marked unevaluable, never rescued by
selectively discarding trials. Pair effects are computed within network first:
Block-minus-Intact C/R2 and100*(IntactR2-BlockR2)/IntactR2. Percent loss is undefined
for nonpositive/numerically zero Intact R2 (<=eps(max(1,abs(R2)))); raw R2 remains.
Report available n. No new inferential family or outcome-selected parameter.

## Paths and independent validation

New analysis, figures, results, docs and manifests use dedicated
paper_ready/noise_sensitivity roots. Large raw cases/fits stay ignored under
results/paper_ready/cache/noise_sensitivity. Writers refuse existing files;
resume reuses completed case receipts. All prior files are protected by hashes.

Independently audit all new cases using saved states: standardized initial draws
and three saved process/transition sentinels against the original seeded stream;
eta equations and no-reset GO; every target/fold covariance-eigen PCA95,
distances and aggregation; direct geometry eigenspectra/projectors; independent
feature summations for fixed trials1,120,240 and all neurons/centers; all observed
and matched-PC nested fits using normal equations; all shuffle permutations,
chosen-penalty minima, held-out R2 and summary arrays. Independently refit shuffle
rep1 for network1 for each new noise/eta/condition plus missing eta0 anchors
(18 cases). This is bounded shuffle refit coverage, not a full independent refit.
Reuse completed anchor audits, verify loaded anchor summaries exactly.
Check movement/arm transitions and all trial QC, paired summaries and bootstrap.
Run Code Analyzer on new MATLAB files and bounded existing assay unit checks.

## Deliverables and interpretation

Two new four-panel FIG/PNG bundles: absolute R2/C and paired percentR2loss/deltaC,
columns initial/temporal sweeps. Intact sky blue, Block vermillion; eta0 solid,
eta1 dashed. Fixed .10 anchor markers, zero lines, network medians+/-bootstrap SE,
all levels and negative ranges; individual networks where legible. Supporting
network/target/trial tables include geometry, distances, controls and movementQC.
Reopen FIGs, verify plotted source arrays, inspect PNGs and native Notion hashes.
Append one Final preparation-noise sensitivity gallery section; preserve all
ten prior figures/archive. Concise methods/results/status and chronological log.
No quantitative empirical matching, no eta/noise selection, no C-to-R2 causal
mediation claim. Conclusions limited to these one-factor sweeps/two endpoints.
Stop for scientific review, leaving all work uncommitted.
