# PAPER-MODELLING-STABILIZATION-ETA-01 — evidence stop

22 September 2026. Status: STOPPED BEFORE MODEL EXECUTION, not completed.
Authority: Agent Instructions — Current Task, revision
2026-09-22T08:50:07.122Z, page 3c826c94be30817d8f51d9f6c8c2bc19.
Starting HEAD: 70fff703f8fd3074bef62ca9954a03bef50e4d99;
branch v3-romano-hennequin. No staging, commit or push is authorized.

## Locked scope recovered

Only Intact and full Block; eta=[1,.75,.5,.25,0]. The earlier proposed
equilibrium-location by feedback factorial is expressly superseded.
Lambda10, alpha.5, beta_norm1, V1, L, kappa0, all accepted networks,
30 trials/target, seeds, initial/process preparation noise .10/.10,
native .2-ms integration, 1-ms saved sampling, normalization and movement
generator remain frozen. No post-GO noise, new RRR, eta selection or tuning.
Six panels: local stability; mean GO bias; within-target GO dispersion;
empirical convergence; PR/Control95 alignment; PCA75/nested-ridge R-squared.
Movement/QC is supporting evidence, not a seventh panel.

## Binding stop: panel D implementation not recovered

The current task explicitly requires the exact prior held-out, target-matched
pre-cue-to-pre-go convergence implementation, and explicitly requires a stop
if it cannot be recovered unambiguously. That dependency has not been met.

Read-only evidence checked:

- Active repository source/configuration, paper-ready documentation and
  Stage-3 manifests were searched for convergence, pre-cue/pre-go and
  held-out/reference definitions. There is no identified empirical
  convergence helper in the active implementation.
- `analysis/stage_3/stage3_bio_summary.m` and
  `artifacts/manifests/stage3_cortical_state_feasibility/BIO_RESUME_REPORT.md`
  describe distances to known x*/xB, cue-normalized prospective error and
  threshold crossings. These do not implement held-out reference-trial PCA
  convergence and cannot substitute for panel D.
- `analysis/paper_ready/paper_prepare.m` stores 501 preparation samples,
  cue through GO. `analysis/paper_ready/prediction/pe_features.m` explicitly
  assigns preparation time -500:0 ms. `pe_recover.m` writes these preparation
  series. `analysis/stage_3/stage3_prediction_replay.m` likewise begins at
  GO-500 ms. These stochastic caches do not contain the required empirical
  pre-cue window.
- Current Stage-3 Notion Technical Specification was checked. Its convergence
  descriptions concern equilibrium distance/readiness, not the required
  held-out empirical metric. Notion content search did not locate a helper.
- Main_text_v8 was read through the connected Drive source, file ID
  1ZMY8I_aalyKtAfdE4Sz_uoO4zE8v3W_E0d-_s0T09gI, last modified
  2026-09-13T18:12:41.246Z. Its convergence Methods specify target-matched
  held-out early/late trials, reference-only PCA on GO-900:10:0 ms, and
  distances in GO-900:-800 and GO-100:0 ms windows. This is a different
  implementation from the model's saved equilibrium-distance summaries.
  The native text response omits the displayed equation; it has not been
  guessed or represented as an independently recovered formula.
- A bounded connected-Drive filename search for convergence-related names
  and for a combined_analyses folder returned no source candidate. This is
  not a claim that no such file exists anywhere in the user's storage.

Unresolved details include the actual helper/dependencies, retained PCA
dimension, exact distance aggregation/formula, reference splits for all 30
model trials, and an approved mapping of the empirical pre-cue window onto
the frozen model evidence. No early/late adaptation analysis is proposed.
Do not invent stochastic pre-cue activity, silently pad deterministic
baseline, shift the pre-cue window to cue, or replace panel D with panel B/C.

## Analytical review only (no numerical validation claimed)

With f(x)=-x+W*ReLU(x)+h, define

    u0_eta = -f(xB) - eta*kappa0*(x-xB)
    b_eta  = f(xB) - f(x*) + eta*kappa0*(x*-xB)

Adding b_eta and -L*(x-x*) to u0_eta gives exactly the prescribed Intact
field. Removing both leaves the prescribed full Block field. Substitution
of x* and xB respectively makes each deterministic field zero for any eta;
this establishes intended equilibria, not their stability.
Away from ReLU kinks the physical-time Jacobians are

    J_Intact = (-I + W*diag(x*>0) - eta*kappa0*I - L)/tau
    J_Block  = (-I + W*diag(xB>0) - eta*kappa0*I)/tau.

No eigenspectra, eta=1 reproduction, trajectories, geometry, movement/QC,
prediction fits, uncertainty estimates or diagnostic figure were generated.
Those remain pending, not failed scientific results.

## Preservation and resumption

The existing prediction/RRR inventory passed the read-only check against all
203 recorded SHA256 hashes (20,435,636,045 bytes), including the 130 ignored
raw evidence files. Zero mismatches. The three inventory/final-Git self-receipts
were separately hashed. Actual evidence is recorded in
`artifacts/manifests/paper_ready/stabilization_eta/PRESERVATION_PREFLIGHT.json`.
No existing code, results, figures or documentation were edited or removed.
Only this new stop report and a new preservation receipt are intended local
additions. Management-page stop notes preserve the current task and all
previous scientific publication unchanged.

To resume: supply the exact convergence MATLAB helper and dependencies (path
or attachment), or add a binding resolution explicitly defining its missing
details and the model pre-cue mapping. Then lock the execution plan, reproduce
eta=1 from preserved evidence, and proceed only if the required audits pass.
No model or analysis parameter should be chosen from diagnostic outcomes.
