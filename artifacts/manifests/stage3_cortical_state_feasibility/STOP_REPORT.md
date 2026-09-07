# STAGE3-CORTICAL-STATE-FEASIBILITY-01 — partial completion / figure stop

Recorded 2026-09-07 21:42 UTC (2026-09-08 Asia/Jerusalem).
Status: numerical computation complete; overall task incomplete. No scientific
acceptance, staging, commit or push. Stop for review under the task's explicit
computation-failure rule. Preserve this dirty worktree and all caches.

## Exact stop

The figure batch exited 1 in `figures/stage_3/stage3_figures.m:23`:
`Array indices must be positive integers or logical values.` The expression
`a.alpha(a.analytical)` uses numeric 0/1 CSV fields read by `readtable` as
indices rather than converting them to logical masks. This is a renderer
implementation defect, not an observed scientific constraint failure.
It has not been repaired in this stopped run. Do not rerun model simulations
to address it. A subsequent authorized continuation should repair the plotting
mask types and complete figure/independent validation/publication first.

The failed batch reached and saved the two Results figure pairs, then failed
on Diagnostic Figure 1. Diagnostic Figure 2 was not reached. The registry
compact-index exporter, report exporter and final independent audit were later
commands in that batch and did not execute. No `FINAL_AUDIT.json` exists.
The full 10.5-MB JSON registry and matching complete 3.3-MB MAT registry are
preserved; the optional compact-index helper is written but has not replaced
them. The 17-MB consequences bundle is also preserved, not silently discarded.

## Preflight and predeclaration

Starting HEAD/tracking/direct remote all matched
`302138aacac1c81132f57c2da3578e5b29494ffb`; branch/upstream
`v3-romano-hennequin` / `origin/v3-romano-hennequin`; clean initial worktree
and index, no Git locks. Existing ignored local caches/logs/OS metadata were
inventoried and left untouched. No legacy archive was read or restored.

Read current Notion instruction revision 2026-09-07T20:57:42.493Z, repo
guidelines, accepted Stage-1 and completed Stage-2 scientific hierarchy.
Created Stage 3 under Models and exactly four native child pages. The complete
derivation, plan, source-unit conventions, admissibility limits, seeded
sampling/selection rules and Mermaid architecture were written and read back
before the sweep. See `NOTION_PAGES.json`, `PLAN.md`, `DERIVATION.md` and
`PREDECLARED_CONFIG.json`. The reference receipt records the frozen new
normalization/null before any block construction.

Fixed grid: alpha=[.1,.2,.35,.5,.75,1], normalized beta=[.1,.25,.5,.75,1,1.25],
three seeded distributed directions/network, all ten networks/eight targets.
No grid expansion, redraw, limit relaxation, behavioral selection or tuning.

## Completed numerical work

- Independent pre-run derivation: 126 synthetic cases, ranks 1..7 and flat/
  nonuniform spectra. PR error <=7.994e-15, alignment error <=1.777e-15.
  Arbitrary-state policy identity error <=6.751e-14 across ten frozen W.
- New intact references: all ten frozen with source-unit per-neuron SD from
  GO -500:10:0 plus kinematic-MO -50:10:450, overlap retained, no floor.
  Native integration .2 ms, saved 1 ms, analyzed 10 ms; tau150 ms. Settled
  target-centered rank 7 in all members. Relative GO-state error <=1.278e-15;
  maximum full hand-state discrepancy <=2.443e-15 against the unchanged
  x*-initialized frozen movement comparator.
- Full 1080-point analytical screen; all 696 endpoint-screen-passing protocols
  simulated nonlinearly. 384 screen failures remain marked nonlinear-untested.
  Negative rates:108; modulation failures:318 (overlapping classes); no
  endpoint input/rate/state-limit failures. All success/failure rows retained.
- 335 points meet analytical, physical/dynamic and measured finite-window
  criteria. Each of the 30 network/direction sets has feasible points:
  11 for each set in networks1..9; network10 has13/12/13. Another78 physical
  points reproduce measured geometry outside the sufficient bound. This
  demonstrates sufficiency is not necessity within the explored family.
- Common primary: grid index5, alpha=.1, normalized beta=1, direction1,
  all ten networks. Complete registry saved 21:34:48..51 UTC, before block
  movement evaluation. Thirty additional nested solutions selected without
  movement outcomes. Additional directions span the fixed grid by the
  predeclared farthest-point rule, not effect or behavioral maxima.
- Same cortical policy in each pair; remove both sustained cerebellar
  correction and feedback for block. Actual GO states, no reset, drive the
  unchanged movement/readout/arm. Four component-removal policies and the
  prespecified small sensitivities were computed into `consequences.mat`.
  Reference and sweep jobs exited0. Sweep elapsed522.069s; references102.928s.

## Provisional numerical summaries — final independent audit not run

Network n=10, median +/- 10,000 whole-network-bootstrap SE. These values are
the completed implementation's outputs, not yet independently audited.

| Metric | Intact / observed | Block / expected |
| --- | --- | --- |
| Prep PR | 3.392271362 +/- .129254618 | 6.999270100 +/- .000049346 |
| Intact-to-block alignment (%) | 2.008356409 +/- .068267143 | 58.715248699 +/- .541532982 |
| Early hand RMS error (mm) | 1.248073e-13 +/- 7.836398e-15 | 32.019097961 +/- .639354938 |

Common K=7 for all primary pairs; intact minimum K5..6, block minimum K7,
each minimum strictly >95% variance. PR uses all covariance eigenvalues.
Alignment uses the new intact full covariance,10,000 covariance-constrained
draws and the intact top-K variance denominator. The conservative Monte Carlo
radius is .0269338613 plus the separate .005 predeclared margin.

Paired PR increase3.606998738 +/-.129205323; observed-minus-expected alignment
-56.849558713 +/-.463347351 percentage points. Both exact paired p and
two-test geometry-family BH q=.001953125. Early-error paired difference
32.019097961 +/-.639354938mm, exact p=.001953125 in a separate family.
Geometry is an inverse-design constraint, not an independent prediction.
Early movement impairment is evaluated afterward, without reselection.
No conclusion about single-trial prediction follows; prediction was not run.

## Figures and validation state

Existing local pairs, both FIGs reopened and PNGs visually inspected:

- `plots/stage_3/{fig,png}/result_1_preparation_and_movement`
- `plots/stage_3/{fig,png}/result_2_preparatory_geometry`

Both require the remaining publication-readiness review. In particular, the
saved Results2 image does not visibly display its intended condition legend;
do not call it a final reviewed figure. No diagnostic pairs were produced.
Four native Notion upload slots were prepared but no binary files were sent
or attached; unused slots expire. No current page claims native figure upload.

Pre-run analytical, policy, contraction/Euler, reference-fidelity and in-sweep
direct PR/projection assertions passed. Code Analyzer passed the implementation
preflight. Later output-code review found an obsolete suppression annotation;
it was removed, but the final whole-change Code Analyzer and independent
saved-output audit did not run after the renderer stopped. Do not inherit
those planned checks as passes. Independent bootstrap/exact/BH audit remains
pending despite the saved implementation-emitted statistics.

## Preservation and Git

Stage-1/2 code, configuration, models, results and figures were never edited.
The before manifest covers233 files /1,225,280,632 bytes. A read-only post-stop
SHA-256 comparison is recorded separately in `STOP_PRESERVATION.json`.

Only new Stage-3 files, cache ignore policy and minimal AGENTS/README/MODEL_SPEC
current-scope additions were changed. Existing Stage-1/2 files and unrelated
ignored work remain untouched. No index changes, staging, commit, push, branch
change, reset, lock deletion or history rewrite. Local HEAD/tracking remain
the starting SHA. Final direct-remote equality is not claimed: no push
occurred and no post-push verification was applicable. The initial direct
remote was verified. Worktree is deliberately dirty, index clean.

## Preserved work and exact continuation boundary

`results/stage_3/current/cache/` contains all ten immutable references and ten
full grid caches. `feasibility_map.csv` retains1080 rows and every mask/margin;
the registry contains full states/bases/scales/inputs/gains; `consequences.mat`,
`statistics.json`, `additional_solution_movements.csv`, `reference_summary.csv`
and `derivation_audit.mat` retain completed computation. No rerun is needed to
recover these results. Logs `stage3_reference.log`, `stage3_sweep.log` and
`stage3_final_validation.log` remain ignored/local execution evidence.

Remaining: repair renderer mask types, finish all four figure pairs and visual
QA, run the written independent audit and complete Code Analyzer, export compact
review tables/index without losing complete definitions, publish verified native
Notion figures/captions and complete validation tables. Only after authorized
continuation and successful validation should normal commit/push be considered.
No prediction, noise, learning, adaptation or another model is authorized.
