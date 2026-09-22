# Stabilization-eta diagnostic: binding cue-window revision

22 September 2026. The user's binding chat resolution replaces the earlier
panel-D pre-cue requirement. Preserve PREFLIGHT_STOP.md and its receipt as
historical execution evidence; do not reinterpret that stop as a model failure.

Panel D is now a model-native held-out cue-to-pre-go analogue, not the exact
manuscript analysis. Reference-only normalized preparatory PCA uses
GO-500:10:0 ms; held-out target-matched trials are projected into it.
C=1-d_prego/d_cue, using cue -500:-400 and pre-go -100:0 ms. Average over
held-out trials/targets within each network/condition. Do not create pre-cue
data. PCA retention and precise reference/window aggregation remain pending
the two clarification questions sent before any convergence outcome.

All other task definitions remain fixed: eta=[1,.75,.5,.25,0], only Intact
and full Block; lambda10, alpha.5, beta_norm1, V1, frozen kappa0/L/Q/P,
accepted networks, 30 trials per target, preparation noise .10/.10 and
original streams. Preparation ends at GO, then unchanged deterministic
movement with no reset/noise/correction. No eta selection, RRR, new noise,
new parameters, staging, commit or push.

## Ordered plan and current boundaries

Current outcome: preservation, equations/Jacobians and all eta=1 replays
passed. See BASELINE_REPORT.md and baseline.mat/json. Do not restart these
completed checks. Lower-eta trajectories and panels B-F remain pending the
panel-D choices; no new prediction fit or RRR was run.

1. Record all pre-existing files (including hidden/ignored/untracked files,
   excluding Git administrative internals) and hash the prior prediction/RRR
   inventory plus baseline source dependencies. Preserve all old evidence.
2. Independently check decomposition, intended equilibria and actual active-set
   Jacobians for all ten networks/eight targets at all five eta values. Use
   physical-time spectral abscissa (s^-1); report instability, never repair it.
   Algebra/finite-difference tolerances are 1e-10/1e-7. Test finite differences
   within each equilibrium's active set, record minimum distance to ReLU kinks.
3. Reproduce eta=1 preparation for Intact and full Block in every network,
   using the unchanged paper_prepare helper with a local controller copy.
   Compare every saved 1-ms internal state against the validated prediction
   cache, plus GO, target-mean/late rates, seeds, native maxima/components and
   transition evidence against alignment95 outputs. State/rate tolerance
   1e-10. Stop on any material mismatch. Do not rewrite old arrays.
4. After panel-D details are fixed, run only the other four eta values through
   preparation and movement. New roots use stabilization_eta under analysis,
   results/paper_ready, results/paper_ready/cache, docs/paper_ready,
   figures/paper_ready, plots/paper_ready and artifacts/manifests/paper_ready.
   Reuse validated eta=1 evidence rather than duplicate full raw trajectories.
5. Independently audit panels A-F and supporting movement QC; preserve each
   case, flag inadmissible outcomes rather than omit them. Network n=10 and
   the frozen 10,000 bootstrap index rows supply median +/- bootstrap SE.
   No new inferential-test family or eta ranking is introduced.
6. Generate/reopen/inspect the six-panel FIG/PNG and supporting QC; update
   Notion methods/results and management status with exact outcomes, then stop.

The current bounded preflight does not depend on panel D's outstanding
choices. It is not permission to choose those scientific settings after
examining convergence or R-squared outcomes.
