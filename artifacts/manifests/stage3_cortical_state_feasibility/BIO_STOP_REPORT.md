# Stage-3 biological-controller revision: scientific stop

Task STAGE3-BIOLOGICAL-CONTROLLER-REVISION-01. Notion contract revision
2026-09-10T10:27:49.301Z. The candidate is NOT validated or promoted.
Checkpoint 166d2bbc15cb6a9f0b4d9b7c061e48b180b9b68b remains unchanged.

## Stop reason

The first fixed primary network fails the retained finite-time Block settling
criterion after 500 ms. All eight target residual ratios exceed 1e-4:

| Target | ||xGO-xB|| / max(1,||xB-xsp||) |
| --- | ---: |
| 1 | 0.0428846357061 |
| 2 | 0.0349778766988 |
| 3 | 0.0299691332826 |
| 4 | 0.0537171993829 |
| 5 | 0.0386810609809 |
| 6 | 0.0422905853483 |
| 7 | 0.0360108242792 |
| 8 | 0.0448563089639 |

Worst residual is 537.172 times the limit. The 2.997%-5.372% remaining error
does not imply instability: both laws are locally stable, and the simulated
pair is finite and bounded. It does invalidate the original near-equilibrium
500-ms admissibility claim under the revised minimal residual gain. Local
stability with a 150-ms leak-timescale margin is not a guarantee of 1e-4
finite-time settling, especially for nonnormal nonlinear dynamics.

Per sections B/G/I of the current contract, execution stopped before networks
2-10 preparation, partial removals, finite-window PR/alignment/null tests,
movements, full grid, figures or canonical replacement. There is no new
ensemble phenotype conclusion, p value, movement-deficit claim or empty-grid
claim. Relaxing the settling criterion, lengthening preparation or increasing
the residual gain would require a new scientific decision; none was done.

## Algebra and controller preflight (all ten networks)

The state-coordinate rationale and preregistered audit order are in BIO_PLAN.md.
Frozen Stage-2 P/Q are reused exactly at lambda=.1. Its CARE design is in the
same internal x coordinates, although its nonlinear implementation feeds back
ReLU(x). Four networks have inactive x* entries, so those laws are not globally
identical. No rate/state identity was assumed across the ReLU nonlinearity.
No new CARE solution, cost penalty, coordinate rescaling or lambda was selected.

The minimum analytic kappa0 values are:
0.869118800159, 0.829667226060, 0.923558270062, 0.807979458724,
0.807817410233, 0.911058626784, 0.808851889020, 0.808130563333,
0.808080561591, 0.808012510836.
Predecessor kappa range: 42.3870000351-42.7198785709.

Across the primary xB/x* equilibria, the residual worst pole is -6.6666666667/s
in every network. Revised intact worst poles range from -7.603896837/s to
-6.768774890/s; native Euler spectral radii are below .998667136. These are
local, not global contraction certificates. Saved CARE relative residuals
are <=1.829e-14; arbitrary-state controller-identity errors <=1.777e-14;
finite-difference Jacobian relative errors <=9.930e-10.

L numerical rank is102-106 under N*eps(max eigenvalue), not a biological
channel count. Its leading12-14 eigenvectors account for >95% of squared
gain and capture93.793%-94.927% of trace(Q), compared with6%-7% for the
same-dimensional isotropic expectation. This demonstrates prospective-cost
concentration for those strong directions; it does not label every tiny
nonzero direction prospective-potent. Full eigenvalues/bases, directional
Q loadings and spectra are saved in controllers.mat.

## Native primary-pair checks (network1 only)

No change to alpha=.1, betaNormalized=1, direction1/grid5, xB, x*, W, h,
spontaneous state, normalization, integration or500-ms duration. Intact and
Block share precisely the same u0; Block removes b and structured feedback.
Native integration .2 ms, saved states1 ms, all8 targets. Two preparations
(16 target trajectories), zero movement rollouts and zero new null draws.

| Bound or measurement | Intact | Block | Limit |
| --- | ---: | ---: | ---: |
| Maximum firing rate, source units | 2.282682204 | 1.898741374 | 7.802872965 |
| Maximum state norm | 14.898789843 | 15.336454304 | 43.764328197 |
| Maximum u0 norm | 18.082605261 | 17.943545307 | 230.227630519 |
| Maximum delivered b norm | 20.009573928 | 0 | 230.227630519 |
| Maximum delivered feedback norm | 42.909155106 | 0 | 230.227630519 |
| Maximum delivered total CB norm | 48.024495372 | 0 | 230.227630519 |
| Maximum total input norm | 46.045526104 | 17.943545307 | 230.227630519 |

Input limit=5*Iref with Iref=max(1,new intact total-input maximum), prescribed
before simulation; component cancellation never exempts an individual term.
Intact GO distance to x* ranges .0528598303-.0805086348 state units. Block GO
distance to xB ranges .0728448132-.1283764833, and to x*3.2005776034-3.8339631040.
All actual normalized prospective-error traces, full-state traces, crossing
times and50/100/200-ms diagnostics are retained per target, not interpreted
as a ten-network result or used to change any parameter.

## Evidence and completion scope

- `results/stage_3/current/biological_revision/controller_audit.csv` and
  `controllers.mat`: ten-network frozen-controller algebra/spectra audit.
- `primary_gate.json` / `.mat` in that directory: exact stop and bound values.
- `results/stage_3/current/cache/biological_revision/primary_01.mat`: separate
  ignored native trajectory/controller evidence; does not overwrite a cache.
- `target_readiness.csv`, `frozen_geometry_audit.csv`, `independent_audit.json`:
  cache-only independent audit outputs, with completion reported below.
- Added candidate controller/preparation/runner/auditor are isolated from
  the existing canonical run_stage_3 path. It still invokes the predecessor.

No previous numerical result, figure or scientific source file was replaced.
All four existing Stage-3 FIG/PNG bundles continue to document the validated
isotropic proof-of-principle predecessor; they do NOT validate this candidate.
No gain heatmap was relabeled as evidence for structured prospective feedback.
No new four-policy figure is fabricated after a primary admissibility failure.

## Completion addendum: evidence audit and publication finished

Independent saved-output audit PASS:164 comparisons, maximum absolute error
5.6843418860808015e-14. The auditor checks native Euler increments against
the independently reduced intact/block equations without integrating again,
sampling/neuron order, cue and GO identity, every saved target's distances,
quadratic prospective error, normalization, crossing times, component norms,
native extrema, minimum analytic gain, and unchanged frozen geometry.
The predecessor network1 block settling value was7.9839533827467e-15.
The new failure is therefore a real finite-time dynamic change, not a renderer
or flag/indexing defect. Code Analyzer passed all four added MATLAB files.

Frozen geometry checks pass in all ten networks: normalized trace ratio1.01,
raw trace ratio0.762548922-0.807022171, positive proposed block rates. This is
unchanged geometric evidence, not a new ten-network dynamic feasibility test.

Descriptive network1 intact readiness: E_Q50%-reduction crossings3-4 ms and
90%-reduction10-13 ms; full-state-distance50%-reduction25-91 ms and
90%-reduction280-333 ms. Block meets neither50% nor90% reduction in its
x*-referenced E_Q or distance during500 ms. These are first1-ms saved-sample
crossings, not interpolated estimates, target-selected outcomes, physiological
timescale fits or ensemble conclusions. Exact target values and the50/100/200-ms
measurements are in target_readiness.csv. The rate of prospective correction
does not override the separate failed admissibility criterion.

Preservation PASS at2026-09-10T10:43:07.5663285Z: all718 baseline files and
all233 protected Stage-1/2 files unchanged. No canonical code, accepted
scientific output, existing figure, reference, sweep, selection or cache changed.
The separate new native cache is84,584,864 bytes, SHA256
57B2F657D8E30DA703E4429D03DCFE1147755933482BA05F7632C18868C3543C.

Notion publication/readback completed for all nine pages: current instructions,
Stage-3 parent, Technical Specification, Presentation-ready Summary, Results,
Diagnostics & Sensitivity, Agent Log, Agent Handoff and START HERE. The
current task contract itself is unchanged. Each page explicitly records the
scientific stop and distinguishes the unvalidated candidate from preserved
predecessor material. Results and Diagnostics each retain both native images;
all four child-page memberships and earlier log entries are preserved. One
new log entry was added, not a replacement of the earlier completion history.

Final Git verification: HEAD, local main/v3-romano-hennequin, both tracking
refs and one final direct-remote lookup for both branches all equal
166d2bbc15cb6a9f0b4d9b7c061e48b180b9b68b. Branch/upstream unchanged;
no locks. Tracked worktree diff and index diff are both empty. The worktree
is deliberately NOT clean overall:16 new untracked files plus one ignored
raw cache are retained for review. No staging, commit, push, branch update,
deletion, cleanup, reset, amend or history rewrite was performed.

The16 untracked files are:

```text
analysis/stage_3/run_stage3_biological.m
analysis/stage_3/stage3_biological_audit.m
src/stage_3/stage3_biological_controller.m
src/stage_3/stage3_biological_prepare.m
artifacts/manifests/stage3_cortical_state_feasibility/BIO_INPUTS_BEFORE.csv
artifacts/manifests/stage3_cortical_state_feasibility/BIO_PLAN.md
artifacts/manifests/stage3_cortical_state_feasibility/BIO_PRESERVATION.json
artifacts/manifests/stage3_cortical_state_feasibility/BIO_STOP_REPORT.md
artifacts/manifests/stage3_cortical_state_feasibility/bio_preservation.ps1
results/stage_3/current/biological_revision/controller_audit.csv
results/stage_3/current/biological_revision/controllers.mat
results/stage_3/current/biological_revision/frozen_geometry_audit.csv
results/stage_3/current/biological_revision/independent_audit.json
results/stage_3/current/biological_revision/primary_gate.json
results/stage_3/current/biological_revision/primary_gate.mat
results/stage_3/current/biological_revision/target_readiness.csv
```

Stop for scientific review. The permitted success checkpoint and figure
replacement were not reached; do not treat this audit completion as controller
acceptance or authorization to relax the settling criterion and continue.
