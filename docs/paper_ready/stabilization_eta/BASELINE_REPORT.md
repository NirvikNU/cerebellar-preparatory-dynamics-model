# Stabilization-eta: baseline and equation preflight passed

22 September 2026. Partial completion only; the six-panel diagnostic is not
yet complete. The user's model-native panel-D replacement is incorporated
in history/RESUME_PLAN.md and the then-current Notion task. No empirical pre-cue
window is required or synthesized. The old history/PREFLIGHT_STOP.md remains
provenance. This dated phase receipt is superseded for execution status by
REPORT.md and COMPLETION.md; its scientific evidence is unchanged.

## Preservation

RESUME_INPUTS.csv records 2,050 pre-existing files (133,483,473,874 bytes),
including hidden, ignored and untracked evidence, excluding Git internals.
The pre-execution hash check matched all 2,045 prior manifest hashes and
recorded five additional existing files. PASS at 2026-09-22T10:46:52.7974249Z.
This is a pre-execution whole-worktree check, not a second post-execution
whole-worktree rehash. New code loads old outputs read-only and writes only
stabilization_eta paths. No existing scientific arrays or files were edited.
The original 76 untracked prediction/RRR review files and 130 ignored raw
prediction files remain preserved and un-staged.

## eta=1 reproduction: PASS

All ten networks, both policies, eight targets and 30 trials/target were
replayed with the frozen preparation helper and original standardized draws.
Twenty network/policy replays; 4,800 preparation trajectories. Compared all
501 saved internal-state samples per trial, not only the GO endpoint.
Also checked initial/GO states, late-window rates, target-mean rate curves,
native state/rate maxima, delivered-component maxima, trial seeds and all
preserved native transition records.

- Intact maximum internal-state discrepancy: 2.4424906541753444e-15.
- Block maximum discrepancy over all checked quantities: exactly zero.
- Largest discrepancy over any checked quantity: 1.4210854715202004e-14,
  in a delivered-component maximum (squared-norm expansion versus direct norm).
- All comparisons pass the predeclared 1e-10 tolerance; no tolerance change.
- Baseline/Jacobian computation elapsed 115.4065131 seconds, excluding the
  preservation pass and MATLAB startup. Owned ten-thread pool shut down.
- No post-GO movement rerun, new prediction fit or RRR fit was performed.

Full arrays: results/paper_ready/stabilization_eta/baseline.mat and
baseline.json. Existing raw eta=1 evidence remains the authoritative cache;
identical replayed trajectories were not duplicated on disk.

## Equations and local stability: PASS

Evaluated all five eta values, both policies and all 80 target equilibria
(800 equilibrium/policy/eta combinations). Recomputed b_eta from frozen
states; independently checked the decomposed versus direct vector fields,
equilibrium substitution, central finite-difference Jacobians and the exact
spectral shift induced by subtracting eta*kappa0/tau times identity.

Maximum decomposition error 5.329070518200751e-15; equilibrium error zero;
relative finite-difference Jacobian error 1.0249610173064953e-9; spectral
shift discrepancy 5.3290705182007514e-14. Minimum absolute equilibrium
coordinate 0.0099605200165777674: no equilibrium lies at a ReLU kink.

Every examined equilibrium is locally asymptotically stable, including eta=0.
The table reports the RANGE of target spectral abscissae across all networks,
in s^-1, not network medians or bootstrap error bars.

| eta | Intact range (s^-1) | Block range (s^-1) |
| --- | --- | --- |
| 1 | -7.583661 to -6.667088 | -7.428134 to -6.666667 |
| .75 | -6.044397 to -5.257989 | -5.888871 to -5.318580 |
| .5 | -4.505133 to -3.718725 | -4.349607 to -3.970494 |
| .25 | -2.965869 to -2.179461 | -2.810343 to -2.622407 |
| 0 | -1.530916 to -.640197 | -1.283117 to -1.271079 |

Local stability does not establish finite-time stochastic convergence,
movement admissibility, geometry or predictability. No eta is nominated.

## Static and execution review

All three new MATLAB files pass Code Analyzer. Two intentional broadcasts
of five eta values/four policy flags were explicitly annotated; their
original analyzer messages are retained in STATIC_MESSAGES.json. No
scientific repair, changed numerical setting or retry of a model run occurred.
All v7.3 MAT inputs were loaded on the client, outside thread workers.
Preservation completion used a single native Wait-Process dependency, not
a log/file polling loop; the inventory was not restarted.

## Remaining decision and work

Panel D's windows/formula are resolved. Before evaluating convergence,
the PCA retention rule is still unspecified. The existing >=75% threshold
belongs to prediction, whereas Control95 belongs to geometry. Neither
automatically specifies the model-native convergence subspace.

The clarification asks which reference-variance threshold/all-PC convention
to use and proposes the existing fixed three-fold assignments (20 same-target
reference trials, 10 held-out per fold), with distances between window-mean
held-out and reference states. No choice has been inferred from outcomes.
No panel-D scores or new-eta R-squared values have been calculated.

After resolution, reuse the passed baseline/equation evidence. Do not rerun
eta_baseline or its inventory. Remaining: four lower-eta trajectory sets,
panels B-F, supporting movement/QC, independent uncertainty/geometry/ridge
audits, figures and publication. No RRR or tuning. No staging/commit/push.

HEAD remains 70fff703f8fd3074bef62ca9954a03bef50e4d99 on v3-romano-hennequin.
Tracked/index diffs are empty; the worktree is intentionally dirty with
preserved prediction review artifacts plus the new stabilization preflight.
