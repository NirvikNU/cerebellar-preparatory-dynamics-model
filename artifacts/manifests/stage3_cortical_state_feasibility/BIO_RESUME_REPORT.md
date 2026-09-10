# Stage-3 biological-controller resume: scientific review report

Task **STAGE3-BIOLOGICAL-CONTROLLER-RESUME-02**, authoritative Notion revision
2026-09-10T13:09:46.581Z. Active repository is
E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model.
Starting checkpoint:166d2bbc15cb6a9f0b4d9b7c061e48b180b9b68b.
Scientific acceptance remains a user-review decision.

## Authorized change, not a parameter rescue

RESUME-02 explicitly retires only the old requirement that Block reach xB
within relative distance1e-4 at500 ms. A minimal local leak-timescale
stabilizer is not a near-instantaneous full-state settling controller.
No new terminal-distance threshold replaces that rule. The earlier stop
report, original native cache and all recorded values remain unchanged.

All ten network-specific kappa0 values, frozen Q, exact saved Stage-2 P/L at
lambda=.1, alpha=.1, normalized beta=1, direction1/grid5, constructed states,
normalization, seeds, initial conditions,500-ms duration, integration and
movement model remain fixed. No state or gain is selected from these outcomes.
Intact=u0+b-L(x-x*); Block=u0. Partial removals use the same u0 and remove
only the indicated cerebellar-dependent contribution.

## Reuse and new work

- Reused the ten saved candidate controllers and their coordinate/algebra/
  local-spectrum audits, all frozen target geometries and primary registry.
- Reused network1 Intact/Block native trajectories byte-for-byte; computed
  only the38 missing eight-target preparations for the four policies.
- Reused validated controller-free baseline, frozen Stage-3 neuron SD and
  full-reference null covariance/projectors. New expected values are evaluated
  with the actual revised intact covariance, not old expected scalars.
- Computed primary Intact/Block movement consequences for160 target rollouts
  using actual GO states and unchanged movement dynamics/readout/arm.
- Reused all1080 stored map definitions. Recomputed controller-dependent
  endpoint/dynamic/population classifications without selecting a new point.
  There are696 nonlinear-tested points; the10 existing primary Block cases
  are reused, so686 new grid protocols were needed. Screen-rejected points
  remain explicitly nonlinear-untested.
- Old isotropic figures, numerical summaries, sampled-solution movements and
  sensitivities remain historical. They are not relabeled as revised results.

## Primary numerical results

Network n=10; median ± SE from the original10000 whole-network bootstrap
resamples. Primary geometry is actual GO -100:10:0-ms activity, not equilibrium
covariance. K is the common larger minimum strictly exceeding95% variance.

| Metric | Intact / Observed | Block / Expected |
| --- | ---: | ---: |
| Preparatory PR | 3.402364610 ±0.123927549 | 7.002450563 ±0.000351575 |
| Intact-to-Block alignment (%) | 1.993511150 ±0.049184802 | 58.712852199 ±0.519782348 |
| Early hand-trajectory RMS discrepancy (mm) | 0.000341131 ±0.000245045 | 32.181383283 ±0.652086345 |

The paired PR increase is3.599440654 ±0.123958859. The paired observed-minus-
expected alignment is−56.840877522 ±0.493394104 percentage points. The paired
Block-minus-Intact early movement discrepancy is32.181063376 ±0.652881266 mm.
All three exact paired sign-flip p values are0.001953125; both geometry-family
BH q values are0.001953125. The movement test remains its separate family.
Tests retain the established mean-difference sign-flip statistic; reported
central estimates are network medians. No extra tests were selected.

Every network has larger Block PR and below-null alignment, with positive
predeclared conservative null margins0.512777-0.576659. Primary common K=7,
Intact minimum K=5-6, Block minimum K=7. Monte Carlo draw SE and half-sample
differences are saved separately from network-bootstrap uncertainty. PR slightly
above7 is not a rank violation: the rank<=7 theorem applies to settled target
means, whereas the measured time-by-target trajectories include finite
transients and can have additional variance directions.

All40 primary policy preparations pass the retained native rate/state and
separate delivered-component input limits. Incomplete Block convergence is
reported in preparation_bounds.csv and target_readiness.csv, never hidden.
Intact movement discrepancy is very small but not substituted by zero; no
post-GO reset or correction was introduced to produce that fidelity.

## Fixed-grid generality

The1080-point map has696 nonlinear-tested/physically admissible points and
384 screen-rejected/nonlinear-untested points. There are335 analytically
sufficient + physically admissible + empirical-phenotype intersections,
plus78 admissible empirical successes outside the conservative sufficient
bound (413 empirical successes total). These counts happen to equal the
predecessor counts; numerical metrics were recomputed, not copied. The same
primary point passes every retained criterion in all ten networks. The map
uses fixed denominators of30 nested network/direction realizations, with
networks—not directions or points—as the independent replication unit.

The analytical boundary/variance geometry is unchanged. Dynamic/input checks
use the new fixed controller; the retired settling cutoff is excluded and
all terminal distances remain saved. No wider grid, new directions or
replacement primary were searched. A sufficient boundary is not a proof
that points outside it are impossible.

## Comparison with the isotropic predecessor

| Network-median quantity | Preserved predecessor | Revised controller |
| --- | ---: | ---: |
| Intact PR | 3.392271 | 3.402365 |
| Block PR | 6.999270 | 7.002451 |
| Observed alignment (%) | 2.008356 | 1.993511 |
| Expected alignment (%) | 58.715249 | 58.712852 |
| Block early error (mm) | 32.019098 | 32.181383 |

The hypothesis remains a constructed sufficient mechanism, not an independent
prediction of its designed geometry or an anatomical localization result.
Movement consequences are independent of controller/geometry selection.
The interpretation distinguishes sustained state setting, prospective-cost-
weighted correction and generic minimal residual stabilization.

## Reproduction and review artifacts

Current compact outputs:
results/stage_3/current/biological_revision/resume_02/.
Native evidence (ignored/local):
results/stage_3/current/cache/biological_revision/resume_02/.
The original network1 pair remains in the parent cache's primary_01.mat.
BIO_RESUME_PLAN.md records the locked continuation plan. BIO_RESUME_BEFORE.csv
and BIO_RESUME_PRESERVATION.json record the preservation audit. The original
BIO_PLAN/BIO_STOP_REPORT and all old scientific evidence are retained.

Current figure pairs, each FIG+PNG in plots/stage_3/{fig,png}:

1. result_1_preparation_and_movement
2. result_2_preparatory_geometry
3. diagnostic_1_feasible_solution_map
4. diagnostic_2_component_removal

The public runner routes current validate/figures actions to the biological
outputs after their independent audit. Historical isotropic renderers cannot
overwrite current figures. No new top-level model or broad folder cleanup.

## Functional readiness and finite convergence

Policies below are Intact, remove feedback, remove b, and full Block, always
with identical residual u0. All values are measured from the fixed native
trajectories. Network summaries use n=10; target crossing ranges are descriptive.

| Policy | Distance x* | Distance xB | E_Q/cue | PR | Expected−Observed (pp) |
| --- | --- | --- | --- | --- | --- |
| Intact | 0.07484854 ± 0.0051130 | 3.466692 ± 0.012431 | 1.987149e-8 ± 4.5022e-9 | 3.402365 ± 0.12393 | -49.66970 ± 1.7853 |
| Remove feedback | 0.1776896 ± 0.0097806 | 3.472428 ± 0.012981 | 0.0001185338 ± 0.000023015 | 3.439914 ± 0.12003 | -47.59002 ± 1.6036 |
| Remove b | 3.601677 ± 0.045247 | 2.754321 ± 0.055241 | 0.03586546 ± 0.0014725 | 4.075422 ± 0.14997 | 44.15506 ± 1.3207 |
| Block | 3.465303 ± 0.012460 | 0.1138077 ± 0.0056276 | 0.8650272 ± 0.022780 | 7.002451 ± 0.00035157 | 56.84088 ± 0.49339 |


Block relative distance to xB at GO spans 0.0267414303–0.0595735475 across network/target cases; median across network maxima is 0.0530371536. Relative distance uses the original denominator max(1,||xB−cue||), not a revised favorable scaling. All distances and component time courses remain saved.

### Readiness at predeclared times

| Policy | After cue (ms) | E_Q/cue, median±SE | State-distance/cue, median±SE |
| --- | --- | --- | --- |
| Intact | 50 | 0.0009685852 ± 0.000082323 | 0.4749941 ± 0.012764 |
| Intact | 100 | 0.00009744586 ± 0.000012030 | 0.3654645 ± 0.0097027 |
| Intact | 200 | 0.000005876803 ± 7.9043e-7 | 0.2043364 ± 0.0069727 |
| Remove feedback | 50 | 0.5421492 ± 0.0068708 | 0.8638441 ± 0.0045990 |
| Remove feedback | 100 | 0.2246855 ± 0.0055670 | 0.7852599 ± 0.0086991 |
| Remove feedback | 200 | 0.04107268 ± 0.0017786 | 0.4614808 ± 0.016189 |
| Remove b | 50 | 0.02952159 ± 0.0011493 | 0.9244367 ± 0.0085667 |
| Remove b | 100 | 0.03506735 ± 0.0013923 | 1.099357 ± 0.012948 |
| Remove b | 200 | 0.03591177 ± 0.0014736 | 1.237880 ± 0.014379 |
| Block | 50 | 0.9342727 ± 0.032691 | 1.095919 ± 0.010950 |
| Block | 100 | 0.8936667 ± 0.043152 | 1.196141 ± 0.012426 |
| Block | 200 | 0.8520532 ± 0.021011 | 1.249386 ± 0.0063818 |


EQ first normalizes each target by its cue value, then averages within network. Normalized state summaries divide the target-mean distance by its target-mean cue distance. These summaries do not replace the per-target first-crossing records.

### First-crossing diagnostics

Entries are achieved targets/80; range and pooled target median in milliseconds after cue. These are descriptive, not n=80 inferential estimates; no interpolation or response-driven threshold.

| Policy | EQ 50% | EQ 90% | State 50% | State 90% |
| --- | --- | --- | --- | --- |
| Intact | 80/80; 3–5 ms (median 3) | 80/80; 8–17 ms (median 10) | 80/80; 17–110 ms (median 46) | 80/80; 248–403 ms (median 305) |
| Remove feedback | 80/80; 49–60 ms (median 55) | 80/80; 125–162 ms (median 138) | 80/80; 139–228 ms (median 186) | 80/80; 362–496 ms (median 434) |
| Remove b | 80/80; 3–5 ms (median 3) | 80/80; 8–21 ms (median 10) | 0/80; not reached | 0/80; not reached |
| Block | 2/80; 125–192 ms (median 158.5) | 0/80; not reached | 0/80; not reached | 0/80; not reached |


Intact prospective-error reduction is much faster than full-state convergence without a fitted time constant. Remove-feedback slows both. Remove-b leaves substantial destination error despite rapid prospective correction. Full block achieves EQ50 in only 2/80 cases and EQ90 in none; no failed crossing is replaced by 500 ms.


## Completed validation and publication

- Independent saved-output audit: PASS 23,002 checks; maximum absolute error
  4.831690603168681e-13; 800,000 native transitions verified without replay.
  It independently recomputes native controller components/equations, neuron-
  preserving geometry, PR/K, projected activity, QR nulls, bootstrap SE,
  exact sign-flip/BH tests, movement readout/errors and map classifications.
- Additional arm-step/figure audit: PASS 204 checks; maximum error
  1.4210854715202004e-14. It checks the independent closed-form 2x2 arm mass
  matrix step across all 160 targets and reopened FIG curves/error bars/map.
- Code Analyzer: PASS all 21 added/changed MATLAB files. Rendering-only
  warnings were corrected before the final run; scientific arrays untouched.
- Public current validate action: PASS; all four FIGs reopened and all four
  PNGs inspected. Final R1 reach limits were padded and D2 GO labels placed
  inside panels; R1/D2 were rerendered from cache only and inspected again.
- Bounded Stage-1 smoke: PASS, short-segment discrepancy 2.220e-16 and
  Q residual 7.345e-14; no full replay/recalibration or canonical overwrite.
- Preservation: PASS 739 baseline files accounted for, 724 byte-unchanged,
  exactly 15 authorized changes, zero baseline deletions. All 233 protected
  Stage-1/Stage-2 files remain unchanged. Original n1 Intact/Block evidence
  SHA256 remains 57B2F657D8E30DA703E4429D03DCFE1147755933482BA05F7632C18868C3543C.
- Updated existing Notion Technical Specification, Presentation-ready Summary,
  Results, Diagnostics & Sensitivity and Stage-3 parent in place. Four current
  PNGs are native uploaded images with full captions; the previous four
  native images remain clearly historical. Mermaid, methods, numeric tables,
  uncertainty, all crossing failures and the retained four-child hierarchy
  were read back. A multipart MIME mismatch was corrected with fresh uploads
  using image/png; no failed upload was treated as published.

## Focused cleanup inventory

| Material | Action and reason |
| --- | --- |
| Original 16 untracked REVISION-01 source/controller/audit/stop files | Retained in this checkpoint; unique candidate and stop provenance |
| Original ignored primary_01 native cache | Retained byte-for-byte; reused n1 pair |
| New preparation/movement/grid/null native caches | Retained under existing ignored cache path; never force-added |
| New compact CSV/JSON/MAT summaries and independent audits | Retained as current reviewed reproducibility content |
| Four current Stage-3 FIG/PNG pairs | Replaced with audited biological-controller outputs; predecessor remains in Git and historical Notion sections |
| Old isotropic code, registry, reference, sampled and sensitivity evidence | Retained historical; current routing prevents renderer overwrites |
| AGENTS, README, MODEL_SPEC and public Stage-3 runners | Reconciled to one current biological-controller path; no broad root reorganization |
| Temporary/scratch files | No unique disposable artifacts identified; zero files deleted |

No archive or old G: path was accessed. No prediction/noise/learning/adaptation,
retuning, new geometry, new seed or later model was introduced. Reused old
geometry/normalization/null-bias evidence is an explicit frozen dependency,
not an old-controller result fallback.

## Git checkpoint boundary

All scientific, preservation and native-publication checks above passed before
staging. The authorized checkpoint is one normal commit on v3-romano-hennequin,
followed by normal push and a no-loss fast-forward of main if still safe.
The exact self-referential final commit SHA and verified local/tracking/direct-
remote equality are recorded after synchronization in Agent Log, Agent Handoff,
START HERE and the Agent Instructions execution status. This report does not
claim a push before it occurs. Scientific review, not another model, is next.
