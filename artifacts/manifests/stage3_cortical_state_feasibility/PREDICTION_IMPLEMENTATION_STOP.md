# Prediction validation: implementation-preflight stop

STAGE3-PREDICTION-VALIDATION-01, 2026-09-10. Resumed from checkpoint
c40e0eb74679a0122cb1e54c784c2e56946a5e14 plus the unchanged earlier
PREDICTION_PREFLIGHT_STOP.md. The Notion binding resolution dated
2026-09-10T20:29:09.453Z resolves the previous methodological questions.
This is a new coding failure, not an unresolved manuscript choice, a model
failure, or a prediction result. Binding resolution D requires stopping on
an implementation failure; production and checkpointing did not proceed.

## Completed before the stop

- Git preflight passed: integrity check and normal fetch succeeded. Existing
  dangling-object notices were nonfatal; no unrelated repairs were attempted.
  HEAD, both local branches, both tracking refs and direct remote main/v3
  were the required checkpoint. No Git locks were present.
- Read current Notion task and current Main_text_v8 (Drive modified
  2026-09-10T15:57:38.963Z), including prediction Methods and Results.
- Locked PREDICTION_PLAN.md before simulation. Its full-ensemble feature
  definitions follow the binding resolution, not the rejected historical
  fold-wise proposal. No parameters were selected from R2.
- PREDICTION_INPUTS_BEFORE.csv records SHA256 for 866 pre-existing assets,
  including ignored Stage1/2/3 scientific caches and all current figures.
- Implemented four new isolated prediction-preflight MATLAB helpers only;
  no pre-existing controller, analysis, runner or plotting file was edited.
- Ran the prescribed isolated-leak test, identical-draw checks and bounded
  deterministic-limit replay. The first stochastic coarse trajectory batch
  ran for network1, targets1/5, trial1, Intact, s=.05; no regression or
  prediction outcome was computed. The paired fine run failed before its
  integration began. No other stochastic policy/level/network ran.

## Measurements that passed

Isolated leak: 20,000 independent paths, tau=.15 s, dt=.0002 s, s=.10,
stationary EM initialization and 2 seconds of evolution.

| Check | Measured | Expected / criterion |
| --- | ---: | ---: |
| Final sample SD | 0.10028689768957419 | EM SD 0.10003335000926468; within 2% |
| Lag-10-ms correlation | 0.93609933017448876 | 0.9354653708736862; within .02 |
| Per-step diffusion variance | 2.6666666666666673e-5 | 2*s^2*dt/tau, floating-point identity |
| Repeated trial noise across four policy calls | bit-identical | same initial/process arrays |
| Distinct trial seed | different initial vector | independent trial identity |
| Brownian bridge coarse/fine increment identity | passed <1e-14 assertion | same Brownian path |

s=0 replay: network1, all eight targets, all four frozen policies, whole
preparation and movement, compared with saved prep evidence and unchanged
source movement/readout/arm routines. These are implementation checks, not
a repeat of the ten-network scientific validation.

| Policy | Prep state max error | GO max error | Movement rate max error | Torque max error | Hand max error |
| --- | ---: | ---: | ---: | ---: | ---: |
| Intact | 1.5543122345e-15 | 1.3322676296e-15 | 5.3290705182e-15 | 3.3133218391e-15 | 1.3843093338e-15 |
| Remove feedback | 1.5543122345e-15 | 1.1102230246e-15 | 6.2172489379e-15 | 2.8588242884e-15 | 1.7624790516e-15 |
| Remove b | 1.5543122345e-15 | 1.1102230246e-15 | 5.1070259133e-15 | 2.4667767828e-15 | 1.5334955528e-15 |
| Block | 0 | 0 | 0 | 0 | 0 |

Every error is below the predeclared 1e-10 tolerance. This does not certify
stochastic convergence: that check remains incomplete.

## Exact failure and required repair

New file analysis/stage_3/stage3_prediction_replay.m has EIGHT arguments,
including optional dt. Line3 incorrectly tests `nargin<9`; therefore it
overwrites an explicitly supplied .0001 step with m.dt=.0002. The fine
noise contains 10,988 steps, but this reset makes the routine expect only
5,494 steps (2,500 preparation +2,994 movement). Its protective assertion
at line7 correctly aborts. This error is in newly written validation code,
not the frozen network/controller/integrator.

Failing call: stage3_prediction_preflight line74; network1, targets[1,5],
trial1, s=.05, Intact, requested dt=.0001. No paired state/hand convergence,
state/rate-bound conclusion or production permission can be claimed.

Required bounded repair for an authorized resume: change the optional-
argument guard to `nargin<8` and add an explicit regression test asserting
that supplied dt=.0001 remains .0001. Preserve this failed attempt's
preflight.mat/json, evidence and log; use a distinct resume audit output
rather than overwriting the stop. Then complete the fixed preflight before
any production. Do not change noise, seeds, controller or analysis settings.
The repair is identified but NOT applied in this stopped run.

## Preserved evidence and unfinished scope

Compact failure evidence: results/stage_3/current/prediction_validation/
preflight.mat and preflight.json. Raw initial/process/coarse-fine bridge
draws: results/stage_3/current/cache/prediction_validation/preflight_evidence.mat
(ignored). The completed coarse stochastic trajectory was transient and
was not saved before the fine-step assertion; it is exactly reproducible
from saved standards and the fixed model. No complete stochastic pair or
production cache is represented as validated. Execution log:
artifacts/manifests/stage3_cortical_state_feasibility/prediction_preflight.log
(ignored). Code Analyzer output is separate from scientific validation.

Outstanding: optional-step repair/test; stochastic fine-step/safety/window
checks; full 10-network x8-target x30-trial x4-policy x3-level production;
all neural/behavioral prediction, chance/matched-PC/within-target/prepeak
and speed-axis controls; independent numerical/statistical audit; new
figures and completed scientific publication; Git checkpoint/synchronization.
No prediction, R2, statistical contrast or scientific interpretation exists.

No staged changes, commit, push, branch change, model tuning, deletion or
cleanup was performed. Existing completed scientific pages and four current
Stage3 figure pairs remain current; management pages record this stop.

## Final preservation, static audit and management receipt

- Final preservation verification PASS: all 866 baseline entries exist with
  their original SHA256. No baseline file was deleted or modified.
- MATLAB Code Analyzer returned zero messages for all four new helpers.
  The runtime optional-argument bug remains present: static analysis did
  not detect it, and this is explicitly not a completed validation claim.
- Updated and read back Agent Log, Agent Handoff, START HERE and the task's
  execution-status section. They distinguish the resolved methodological
  stop from this implementation stop. Existing scientific pages/figures
  were not relabeled or replaced. The prior log entry remains preserved.
- Final Git inspection at 20:40:58 UTC: branch v3-romano-hennequin; HEAD,
  local main/v3, tracking main/v3, and both direct remote refs all equal
  c40e0eb74679a0122cb1e54c784c2e56946a5e14; no locks. Both tracked and staged
  diffs are empty. The worktree is NOT globally clean: 12 untracked files
  are deliberately preserved (11 new plus the earlier preflight report).

Untracked inventory:

1. analysis/stage_3/stage3_prediction_noise.m
2. analysis/stage_3/stage3_prediction_paths.m
3. analysis/stage_3/stage3_prediction_preflight.m
4. analysis/stage_3/stage3_prediction_replay.m
5. artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_INPUTS_BEFORE.csv
6. artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_PLAN.md
7. artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_PREFLIGHT_STOP.md (pre-existing)
8. artifacts/manifests/stage3_cortical_state_feasibility/PREDICTION_IMPLEMENTATION_STOP.md
9. artifacts/manifests/stage3_cortical_state_feasibility/prediction_preserve.ps1
10. results/stage_3/current/prediction_validation/preflight.json
11. results/stage_3/current/prediction_validation/preflight.mat
12. results/stage_3/current/prediction_validation/code_analyzer.json

The ignored raw preflight evidence and execution log are also retained.
No files were staged, no cleanup commit exists, and nothing was pushed.
