# Stage-3 pre-GO noise causal diagnostic

Task: STAGE3-PREGO-NOISE-CAUSAL-DIAGNOSTIC-01. Binding Notion revision
2026-09-12T21:10:03.780Z. Starting checkpoint
326832944924378f52efe5e2d66f90d9e6d448c2; active repository E:/PROJECTS/
Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model.

## Locked execution plan (before replay outcomes)

Use s=.10 only, all ten networks, eight targets, 30 existing trial identities,
and all four frozen policies. Reuse the completed Full-noise caches and saved
preparatory features. Never rewrite that baseline. Reconstruct only the exact
previous standardized noise stream with the unchanged seed helper; no new
random identities, amplitudes, folds or permutations are introduced.

For each network/policy, Prep-only starts from each saved noisy GO state and
sets post-GO increments to zero. Post-only starts from each target's saved
deterministic GO state and uses the matching original post-GO increments.
Deterministic starts from that deterministic GO state with zero increments;
compute eight unique target movements, not 30 redundant copies. Validate all
deterministic replays against the frozen cortex/arm functions and available
saved Intact/Block movement evidence. No preparation replay, controller refit,
new parameter point or sensitivity-level rerun is authorized.

The stream is split after exactly 2500 preparation increments at dt=.0002 s.
Independent regeneration of each original trial stream must match the helper
bitwise. Check saved Full native-step intervals against those same increments
before counterfactual analysis. Save stream hashes and exact GO-state identity.
The full saved movement horizon, 1-ms saved sampling, own-trial onset (20% of
own peak), peak time and physical hand coordinates remain unchanged. Enforce
the current state/rate and event-window checks; retain and report failures.

Full-versus-Prep-only behavior uses the identical saved preparatory features,
target-mean >=95%-variance task-plane rule, nested 3-fold ridge objective/grid,
folds, pooled R2 and full-condition speed-axis refit rule. Only responses and
the required response-dependent fits differ. Pre-peak controls recompute own
event-aligned features with the unchanged boundary-protected preprocessing.
Use existing ridge/OLS helpers unchanged. Recompute Full estimates and compare
with the saved baseline before interpreting paired changes. No extra neural
prediction, null/permutation, amplitude sweep or model fit is added.

Variance is the unbiased within-target sample variance of peak speed and the
trace of the x/y sample covariance, then the mean over eight targets. Report
network-wise Prep-only/Full, Post-only/Full and Full-minus-Prep-only changes,
plus matched Full-minus-Prep-only output differences. These are counterfactual
effects, not an additive variance decomposition. No current dispersion helper
was found in the initial reference search; do not invent an extra paper-like
dispersion definition. Deterministic repeated-trial variance is exactly zero.

Networks n=10 remain independent. Reuse the frozen 10000 whole-network bootstrap
indices for medians and SE, including paired R2 changes and variance ratios.
This diagnostic is descriptive, with no new exact-test family or acceptance
threshold based on effect direction. Negative R2 and mixed outcomes remain.

One new 2x3 figure: four Full/Prep-only prediction panels and two three-condition
variance panels, all four policies, network values plus median/bootstrap SE.
Pre-peak controls and all detailed values go in the report/tables. Save and
reopen matching FIG/PNG without replacing the existing seven Stage-3 pairs.

## Validation and cleanup sequence

1. Git fetch/integrity/preflight and all local/tracking/direct remote refs:
   PASS at the required checkpoint; clean worktree/index, no locks. Dangling
   object notices are informational; no Git repair or object pruning.
2. Inventory/hash the checkpoint and ignored scientific assets before replay.
3. Validate GO/stream/deterministic identities, then replay and independently
   audit events, rates, arm steps, regressions, target averaging and bootstrap.
4. Classify each existing Stage-3 file against current references before any
   deletion. Remove only demonstrably superseded/failed/scratch material whose
   substantive evidence is preserved in current reports/Git; retain ambiguous
   historical dependencies and all meaningful current raw evidence.
5. Reconcile active documentation and runners, broken-reference checks,
   relevant Code Analyzer/smoke/audits; preserve all Stage-1/2 scientific assets.
6. Update the nine specified Notion pages in place, removing redundant failed-
   attempt chronology while preserving current baseline science and figures.
7. One normal commit/v3 push, safe main fast-forward/push, verified SHA equality
   and clean worktree/index; then stop for scientific review.

## Execution outcome

Computational diagnostic and independent validation complete. The pre-run
preservation manifest covers1209 existing files.
All 40 network/policy replay sets passed in 2137.879925 seconds. Maximum
saved-Full native-interval error, deterministic source-function discrepancy
and discrepancy against the available saved deterministic movements were
all exactly zero. Reused noisy GO states and independently reconstructed
original standardized streams passed exact equality checks. Native safety
and own-event windows passed in all replay conditions. This includes 9600
Prep-only movements, 9600 Post-only movements and 320 unique Deterministic
movements, plus independent source-function deterministic cross-checks.
The Full-noise baseline was not regenerated. The deterministic synthetic
behavioral-dispatch test matched the frozen actual-response branch exactly.
Analysis and independent audit now PASS for all40 cases and2880 fits. Maximum
Full baseline discrepancy is3.191891195797325e-15; preparatory feature
discrepancy is exactly zero. No counterfactual prediction outcome was inspected
when the plan was written. Publication/final preservation/Git follow below.
## Full numerical summaries

All entries are network median ± bootstrap SE of the median (n=10; fixed
10000 whole-network resamples). Paired-change medians are medians of the
network-wise changes, not differences of the two condition medians.

### Preparatory prediction

| Metric | Policy | Full | Prep-only | Paired Prep-only−Full |
| --- | --- | --- | --- | --- |
| Prep pooled hand R² | Intact | 0.951288757 ± 0.02066370664 | 0.9943638827 ± 0.001023105605 | 0.04166356645 ± 0.01985090762 |
| Prep pooled hand R² | Remove feedback | 0.9176655807 ± 0.01449438185 | 0.9740468077 ± 0.001945303858 | 0.05578208513 ± 0.01472069525 |
| Prep pooled hand R² | Remove b | 0.9489138574 ± 0.01964105688 | 0.9893154896 ± 0.002184559937 | 0.04191643952 ± 0.01976773715 |
| Prep pooled hand R² | Block | 0.0722281761 ± 0.02031228288 | 0.1437841398 ± 0.03193840648 | 0.06479359626 ± 0.01451554268 |
| Prep pooled speed R² | Intact | -0.01754360872 ± 0.008231490116 | 0.001822712803 ± 0.02459497229 | 0.03395185658 ± 0.02488063378 |
| Prep pooled speed R² | Remove feedback | -0.008735520919 ± 0.006634578185 | -0.01475915011 ± 0.004308930684 | 0.001698341534 ± 0.006500627335 |
| Prep pooled speed R² | Remove b | -0.01136807607 ± 0.01282360416 | 0.4004278724 ± 0.08599863224 | 0.4254245471 ± 0.07439337884 |
| Prep pooled speed R² | Block | 0.06698894779 ± 0.02120038683 | 0.4213126524 ± 0.08254192749 | 0.3185370042 ± 0.06373972912 |
| Prep within-target hand R² | Intact | -0.1225890645 ± 0.007405911217 | -0.1582486176 ± 0.007729660377 | -0.04145891752 ± 0.008236266971 |
| Prep within-target hand R² | Remove feedback | -0.07219845754 ± 0.01945474131 | 0.03026292522 ± 0.04171789374 | 0.09269696424 ± 0.01682790641 |
| Prep within-target hand R² | Remove b | -0.1783880865 ± 0.01388931523 | -0.1779445607 ± 0.01085427285 | 0.004515068289 ± 0.01484941236 |
| Prep within-target hand R² | Block | -0.1739049184 ± 0.00978432799 | -0.1442027107 ± 0.007469902835 | 0.02891351168 ± 0.01098823882 |
| Prep within-target speed R² | Intact | 0.05115097185 ± 0.01529270342 | 0.03399975498 ± 0.03324879653 | 0.02113502252 ± 0.03262042075 |
| Prep within-target speed R² | Remove feedback | 0.03404198333 ± 0.02987178619 | 0.05177733031 ± 0.02264393352 | 0.009575234728 ± 0.01745326513 |
| Prep within-target speed R² | Remove b | -0.06882463126 ± 0.01960571164 | 0.01668201266 ± 0.02681158409 | 0.1045400149 ± 0.04603429105 |
| Prep within-target speed R² | Block | 0.06209655183 ± 0.03167881774 | 0.1214270908 ± 0.01432154175 | 0.04794418782 ± 0.02034666865 |

### Pre-peak supporting controls

| Metric | Policy | Full | Prep-only | Paired Prep-only−Full |
| --- | --- | --- | --- | --- |
| Prepeak pooled hand R² | Intact | 0.9441789198 ± 0.02885019746 | 0.9842198146 ± 0.003514504775 | 0.03792154966 ± 0.03148112248 |
| Prepeak pooled hand R² | Remove feedback | 0.9232777633 ± 0.02681778098 | 0.9758893938 ± 0.003841797249 | 0.06187336836 ± 0.02497448161 |
| Prepeak pooled hand R² | Remove b | 0.9409660105 ± 0.02566187407 | 0.9832054534 ± 0.006708923037 | 0.04334317538 ± 0.02964162836 |
| Prepeak pooled hand R² | Block | 0.06350674781 ± 0.03254962259 | 0.1152521043 ± 0.03073097105 | 0.03434089834 ± 0.02372247104 |
| Prepeak pooled speed R² | Intact | 0.05335389164 ± 0.02476126304 | 0.001078410357 ± 0.02432579367 | -0.04204885082 ± 0.03950224166 |
| Prepeak pooled speed R² | Remove feedback | 0.022937031 ± 0.01518710403 | -0.008520795463 ± 0.01153695608 | -0.006467704809 ± 0.01480766965 |
| Prepeak pooled speed R² | Remove b | 0.1699338251 ± 0.02149934417 | 0.3986189145 ± 0.08486599974 | 0.2459026512 ± 0.08534865928 |
| Prepeak pooled speed R² | Block | 0.03484612571 ± 0.02742753048 | 0.3959926818 ± 0.05907230163 | 0.3752854579 ± 0.04890862545 |
| Prepeak within-target hand R² | Intact | 0.2511162354 ± 0.05612847335 | -0.03747153544 ± 0.0217957175 | -0.2461542198 ± 0.05093544655 |
| Prepeak within-target hand R² | Remove feedback | 0.2430013241 ± 0.04283595957 | 0.4273427981 ± 0.03519731429 | 0.2252558091 ± 0.04485795998 |
| Prepeak within-target hand R² | Remove b | 0.05381702432 ± 0.05517562066 | -0.1129521914 ± 0.01515720481 | -0.1551318488 ± 0.06365304467 |
| Prepeak within-target hand R² | Block | -0.07523360919 ± 0.02700185936 | 0.06630748695 ± 0.03335496092 | 0.1436403892 ± 0.04211270128 |
| Prepeak within-target speed R² | Intact | 0.27725472 ± 0.04743669435 | 0.01192292926 ± 0.01953642326 | -0.2781334888 ± 0.04271813093 |
| Prepeak within-target speed R² | Remove feedback | 0.1604703942 ± 0.03218898407 | 0.126466295 ± 0.03570269941 | -0.026274576 ± 0.03954542281 |
| Prepeak within-target speed R² | Remove b | 0.3384585681 ± 0.04717152178 | 0.003073112855 ± 0.01454422001 | -0.3525677913 ± 0.02558294065 |
| Prepeak within-target speed R² | Block | 0.09086414404 ± 0.04375983463 | 0.07592321148 ± 0.04014216228 | -0.07270006926 ± 0.03178697836 |

### Within-target behavioral variance

Unbiased 30-trial target estimates are averaged over eight targets per network.
Physical SI units below; figure variances are multiplied by 1e6 for mm units.

| Metric | Policy | Full | Prep-only | Post-only | Deterministic |
| --- | --- | --- | --- | --- | --- |
| Peak-speed variance ((m/s)²) | Intact | 0.001457818785 ± 0.00005510014119 | 0.0001002900998 ± 0.000005828221644 | 0.001314268262 ± 0.00005242291639 | 0 ± 0 |
| Peak-speed variance ((m/s)²) | Remove feedback | 0.002987666366 ± 0.000225993719 | 0.001733421281 ± 0.0001318751791 | 0.001298841509 ± 0.00005363916033 | 0 ± 0 |
| Peak-speed variance ((m/s)²) | Remove b | 0.001292944132 ± 0.00006262381207 | 0.00009324427378 ± 0.000005021810255 | 0.001174750371 ± 0.0000574883873 | 0 ± 0 |
| Peak-speed variance ((m/s)²) | Block | 0.007083165861 ± 0.0004553785059 | 0.001874450879 ± 0.0001202580552 | 0.005933862999 ± 0.0003473375754 | 0 ± 0 |
| Hand-position covariance trace (m²) | Intact | 0.00009017274048 ± 0.00004489549999 | 0.00000305717075 ± 1.086670986e-7 | 0.00008255243824 ± 0.00004790325428 | 0 ± 0 |
| Hand-position covariance trace (m²) | Remove feedback | 0.000166578824 ± 0.0000388464318 | 0.00005028545626 ± 0.00000403785192 | 0.00008343644436 ± 0.00004679191247 | 0 ± 0 |
| Hand-position covariance trace (m²) | Remove b | 0.00009586383251 ± 0.00004643648383 | 0.000002943357485 ± 1.07776862e-7 | 0.0001048932895 ± 0.00004931545569 | 0 ± 0 |
| Hand-position covariance trace (m²) | Block | 0.001555982141 ± 0.0001385176839 | 0.0004540360367 ± 0.00002741420959 | 0.001053165682 ± 0.00008027822106 | 0 ± 0 |

### Paired variance changes and ratios

Ratios are computed within network before network summarization. These are
counterfactual comparisons, not additive variance components or fractions
of variance explained.

| Metric | Policy | Prep-only / Full | Post-only / Full | Paired Full−Prep-only |
| --- | --- | --- | --- | --- |
| Peak-speed variance ((m/s)²) | Intact | 0.06928651978 ± 0.004737779297 | 0.939988091 ± 0.01693541697 | 0.00134163608 ± 0.00005057861541 |
| Peak-speed variance ((m/s)²) | Remove feedback | 0.5644926943 ± 0.02836480454 | 0.4664973634 ± 0.01920075675 | 0.001195652547 ± 0.0001230835557 |
| Peak-speed variance ((m/s)²) | Remove b | 0.07111461428 ± 0.005343993887 | 0.9383825724 ± 0.01757017622 | 0.001183717165 ± 0.00006074752293 |
| Peak-speed variance ((m/s)²) | Block | 0.2565884361 ± 0.02179336394 | 0.8313737401 ± 0.02116016934 | 0.005231545681 ± 0.0004300983804 |
| Hand-position covariance trace (m²) | Intact | 0.03803774812 ± 0.01843533099 | 0.93027447 ± 0.02057677628 | 0.00008726379062 ± 0.00004485615358 |
| Hand-position covariance trace (m²) | Remove feedback | 0.2852801879 ± 0.04653391403 | 0.4721378222 ± 0.1050572298 | 0.0001177627326 ± 0.00003719571464 |
| Hand-position covariance trace (m²) | Remove b | 0.03648088409 ± 0.01374076147 | 0.9496768659 ± 0.06332792023 | 0.00009261591902 ± 0.00004641354493 |
| Hand-position covariance trace (m²) | Block | 0.306409902 ± 0.01538506828 | 0.6761016067 ± 0.02189328129 | 0.001047754581 ± 0.0001171056052 |


## Consolidated provenance for authorized cleanup

The original Stage-3 renderer stopped because numeric 0/1 CSV flags were used
as array indices. Cache-only finalization then correctly stopped for missing
raw evidence: 20 unique non-primary sampled movement sets, 20 partial-removal
preparation sets, four sensitivities and one fine-step preparation. The
subsequent bounded recovery preserved selection and all summary values;
RECOVERY_REPORT.md records 266 case comparisons and 56963 independent audit
comparisons, with maximum residuals 2.8422e-14 and 5.1159e-13, respectively.
The flag renderer and explicit condition-legend handling were completed.
Those old isotropic numerical values are provenance, not current biological
controller results.

The biological revision stopped on the old 1e-4 terminal Block settling
criterion, despite local stability and bounded trajectories. Network-1
target residuals were .0299691-.0537172 after 500 ms. The explicit RESUME-02
authority retired that cutoff only; it did not retune the controller or
extend preparation. Current BIO_RESUME_REPORT.md and native evidence retain
all ten-network finite-convergence outcomes, controller algebra and audits.
In particular the original network-1 preparation cache is an active loader
dependency and must not be removed.

The prediction clarification stop concerned ridge scaling/grid, feature-fit
scope and pooled R2. The binding resolution selected the current full-balanced-
ensemble manuscript feature scope, not the rejected historical fold-wise
proposal. PREDICTION_PLAN.md remains the immutable locked specification.
The subsequent implementation stop was the eight-argument replay helper's
incorrect nargin<9 guard. Its sole authorized correction was nargin<8;
PREDICTION_REPAIR_PLAN.md and PREDICTION_REPORT.md record the passed supplied-
step/default-step and all 12 coupled coarse/fine checks. Passed leak evidence
was SD .1002868977 versus EM .1000333500 and lag10ms correlation .9360993302
versus .9354653709. The s=0 maximum discrepancy was 6.2172489379e-15; the
completed fine-step comparison maxima were relative state RMS .0005407057162
and hand RMS .05448927181 mm. Completed baseline prediction outcomes, its
full-noise trials, folds, regressions and uncertainty are not superseded.

The reviewed cleanup inventory proposes removing five superseded stop
reports, the resolved finalization evidence-availability receipt, four
interim Code Analyzer receipts (the final 18-file PASS is retained), the
obsolete failed-stop preservation script, 31 closed execution logs, and the
duplicate run_stage_3_finalize.m entry point: 43 individually classified
files. Repository-wide reference search found no executable caller of that
duplicate; run_stage_3 retains identical current figures/validate actions.
The sole outside reference is an earlier preservation-script allowlist,
not a callable dependency. This classification revision was made explicitly
before deletion, without changing any model helper. Tracked originals remain recoverable from
checkpoint 3268329. Temporary logs are redundant console transcripts; their
substantive results/audits remain in final reports and machine-readable
evidence. Removal has not yet occurred and remains gated on the new audit.

Retain ambiguous historical scientific/reproduction dependencies explicitly:
45 recovered evidence files, 251 gain-time cache files, original construction
grid/reference/registry and their reproduction/audit helpers. They are not
current biological/prediction results, but are meaningful frozen provenance,
not demonstrably disposable failed scratch. Retain original and repaired
prediction preflight MAT/JSON/raw evidence because the successful repair and
production chain still relies on the passed checks they contain. No MATLAB
helper is deleted solely because its name belongs to an older task.

The planned surviving run_stage_3 cleanup removes implicit dispatch to
historical reference/sweep/consequence/rendering code if the current evidence
is missing. Current biological figures/validate actions stay identical;
missing current evidence must fail explicitly. This is runner organization,
not a change to any controller, integration or analysis definition.

## Scientific interpretation: mixed, not a general noise-masking rescue

The matched intervention does not provide a general post-GO-noise explanation for the missing Intact behavioral prediction. Intact Prep-only pooled peak-speed R2 remains 0.001822713±0.024594972, within-target hand R2 remains −0.158248618±0.007729660, and within-target speed R2 is only 0.033999755±0.033248797. Own-pre-peak pooled speed prediction also remains near zero (0.001078410±0.02432579). Pooled hand prediction rises from 0.951288757 to 0.994363883, which is not evidence of restored within-target precision.

For Intact, Prep-only/Full variance ratios are 0.06928652 for speed and 0.03803775 for hand position, whereas Post-only/Full ratios are 0.93998809 and 0.93027447. Thus future noise supplies much of the behavioral variability, but removing it is insufficient to recover the missing Intact relationships. The frozen model does not reproduce the empirically motivated behaviorally structured within-target preparatory variability under these unchanged manuscript-matched linear assays. This is not a claim that the deterministic GO-to-movement mapping does not exist.

Masking is policy-dependent: removing future noise raises pooled speed R2 to 0.400427872 under remove-b and 0.421312652 under Block, while remove-feedback remains negative (−0.014759150). These mixed outcomes, weak Intact values and all network variation remain unchanged. No model/noise/analysis tuning, outcome threshold or new significance-test family was introduced. Ratios are counterfactual comparisons, not an additive variance decomposition. Scientific review is required.

## Matched realized output differences

RMS across all240 matched trials within network/policy, then network median
and fixed bootstrap SE. Equal trial counts give equal target weighting.
These realized conditional output effects are not additive variance components.

| Matched Full-minus-Prep-only output | Policy | Median +/- bootstrap SE |
| --- | --- | --- |
| Full minus Prep-only peak-speed RMS (m/s) | Intact | 0.03619671337 +/- 0.0008380414116 |
| Full minus Prep-only peak-speed RMS (m/s) | Remove feedback | 0.03671447849 +/- 0.001499989936 |
| Full minus Prep-only peak-speed RMS (m/s) | Remove b | 0.03428043400 +/- 0.0009665004504 |
| Full minus Prep-only peak-speed RMS (m/s) | Block | 0.1047690196 +/- 0.005314641529 |
| Full minus Prep-only hand-position RMS (m) | Intact | 0.009249077828 +/- 0.002282532854 |
| Full minus Prep-only hand-position RMS (m) | Remove feedback | 0.01073303323 +/- 0.001503669338 |
| Full minus Prep-only hand-position RMS (m) | Remove b | 0.009449991518 +/- 0.002237341350 |
| Full minus Prep-only hand-position RMS (m) | Block | 0.03460038685 +/- 0.001138482558 |

## Independent validation and presentation

- Production40/40 PASS, exact GO identities/independent original streams;
  maximum saved Full interval, deterministic source and available saved
  deterministic movement discrepancies all0. No Full ensemble regenerated.
- Full behavioral recomputation maximum discrepancy3.191891195797325e-15;
  maximum preparatory-feature difference0 across all40 cases.
- Independent saved-output audit40 cases/2880 fits PASS. Native increment
  error0; arm-step1.1102230246251565e-16; feature1.7763568394002505e-14;
  held-out prediction6.0507154842071031e-15; R2 3.3839597790574771e-13;
  ridge normal-equation residual1.032431091107671e-15; inner-grid-loss
  relative discrepancy4.9962398689328266e-8; target variance4.3368086899420177e-19;
  bootstrap-SE discrepancy6.106226635438361e-16.
- Matched-output audit80 comparisons PASS; RMS discrepancy1.3877787807814457e-17,
  independently recalculated bootstrap-SE discrepancy0.
- All current eight FIGs reopened. New diagnostic_5_postgo_noise_causal FIG
  reopened and all56 median/error-bar series checked exactly against summary;
  corresponding2785x1661 PNG visually inspected. All10 network points, negative
  R2, legends, condition markers, units and panel labels remain visible.
- All79 Stage-3 MATLAB files pass Code Analyzer. Bounded run_all Stage-1 smoke
  PASS: native short-segment2.220e-16 and Q residual7.345e-14. Public current
  run_stage_3 validate PASS after runner cleanup. No full foundation replay,
  calibration, controller revision or existing figure regeneration occurred.
- Repository-wide reference check PASS:142 project MATLAB files,268 Stage-3
  function references,55 active root-document paths and8 figure pairs.
  Historical manifest path/hash records refer to their original checkpoints,
  not current executable dependencies. Detailed receipts are retained.

## Executed cleanup and current organization

Removed44 individually classified files:43 baseline inventory entries plus
one separately hashed/classified closed current production log. These are
12 tracked files and32 ignored logs. Each removal verified the exact source
hash and resolved repository-local individual file path; no recursive folder
removal, Git metadata deletion or broad archive operation occurred. See
POSTGO_CLEANUP_INVENTORY.csv, POSTGO_NEW_LOG_CLASSIFICATION.csv and
POSTGO_REMOVED.csv. Tracked originals are recoverable from3268329; transient
logs are redundant transcripts whose substantive evidence remains current.

Five baseline documentation files were consolidated without changing their
scientific tables. The public runner preserves its current figures/validate
actions, rejects retired construction, and fails explicitly if current audit
evidence is absent. The uncalled duplicate runner was retired. The meaningful
historical dependencies listed above remain; no ambiguous scientific evidence
was guessed disposable. New code is confined to stage3_postgo helpers and
its dedicated renderer; no existing model or analysis helper was edited.

Current compact folder: results/stage_3/current/postgo_noise_diagnostic/.
Raw40 replay and40 analysis caches: results/stage_3/current/cache/postgo_noise_diagnostic/
(local/ignored). New pair: plots/stage_3/fig/diagnostic_5_postgo_noise_causal.fig
and plots/stage_3/png/diagnostic_5_postgo_noise_causal.png. Existing seven pairs
remain current and protected; the prior full-noise baseline is not superseded.

## Publication and checkpoint boundary

Existing Notion Stage-3 parent, Technical Specification, Presentation-ready
Summary, Results, Diagnostics & Sensitivity, START HERE, Agent Handoff, Agent
Log and Agent Instructions updated in place. The diagnostic PNG is uploaded
natively with a full caption; methods, all condition/paired estimates, ratios,
pre-peak controls and independent validation are included. Superseded failed-
attempt chronology is removed from active handoffs/log; baseline biological
and full-noise prediction science remains. No Stage-1/2 Notion scientific page
was altered. Native image/child-page readback and final preservation/Git
verification are recorded below after they occur.

One normal diagnostic/cleanup commit and v3 push followed by a safe no-loss
main fast-forward/push are authorized only after all checks pass. The actual
final SHA and verified local/tracking/direct-remote equality are recorded
externally in Agent Log/Handoff/START HERE after synchronization; this report
does not assert a self-referential containing commit SHA. Stop for scientific
review. No new noise model, covariance learning, adaptation, RRR, target-jump
analysis, retuning or further model was implemented.

## Final pre-commit verification

Preservation PASS at2026-09-12T22:28:53.3767582Z: all1209 baseline files
accounted for,1160 byte-identical retained files (53.85GiB),5 authorized
scientific-table-preserving documentation edits,1 runner-only edit and43
reviewed baseline removals. The separately classified current closed log
makes44 total removals. All accepted Stage-1/Stage-2/Stage-3 scientific assets,
full-noise prediction results and seven original FIG/PNG pairs are unchanged.
Independent text comparison also verifies all33 numeric rows in the biological
report and89 numeric rows in the prediction report unchanged.

Native Notion readback PASS: all9 requested pages updated in place;4 Stage-3
child pages retained,3 Results images and5 Diagnostics images, every old
native image retained plus the single new diagnostic. All cells in the new
main,variance,ratio,pre-peak andpaired-output tables match the computed tables.
No active implementation-stop/no-production claim remains. Completed baseline
science remains current; failed chronology is consolidated into provenance.

Pre-commit normal fetch and direct upstream verification PASS. Both local
branches/tracking refs and direct remote main/v3 remain326832944924378f52efe5e2d66f90d9e6d448c2;
main has zero unique commits, only this v3 worktree exists, no Git locks.
Existing LF-to-CRLF checkout-normalization warnings are informational and were
not addressed by changing Git settings. Main synchronization will not switch
the worktree, preserving exact file bytes. Final commit/push equality and clean
state are recorded in the external handoffs only after actual verification.
