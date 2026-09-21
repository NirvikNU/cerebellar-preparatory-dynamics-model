# PAPER-MODELLING-ALIGNMENT95-01

**Corrected checkpoint validated and published — scientific review pending.**
Starting checkpoint: aebd5fdfd300c19eca85548315357f11ecfd44ac.
The final verified Git SHA is recorded in Notion after the normal push; this
report does not embed its own containing commit. No panel e or prediction.

## Corrected calibration

The fixed 36-point grid was rescored from preserved trajectories. All 360
network/candidate classifications are retained: 237 evaluated feasible cases,
123 physical rejects, and 20 points jointly feasible in all ten networks.
No PR or feasibility value changed. No grid simulation, intact reference,
timing calibration, model fit or candidate extension was run.

The shared selection changes from alpha=.5, beta_norm=.5 to **alpha=.5,
beta_norm=1**, retaining lambda10, frozen kappa0 and V1. Corrected loss is
0.119768578538109; the old selected geometry has corrected loss
2.373817745274396. The old K15 loss .194592559767047 is a different metric
and must not be compared as though it were the same objective.

| Geometry | Analysis rule | Paired DeltaPR | Paired deficit (pp) | Loss |
|---|---|---:|---:|---:|
|alpha=.5,beta=.5 historical selection|Historical K15|2.184919637|23.612770450|.194592560|
|alpha=.5,beta=.5 same old point|Corrected Control95|2.184919637|-8.919568054|2.373817745|
|alpha=.5,beta=1 new selection|Corrected Control95|3.290888852|20.925236084|.119768579|

This is the authorized full-grid correction, not tuning from movement or
prediction. The historical common-K7 sensitivity is not substituted for
the Control95 row. Only losses under the same rule are directly comparable.

Selected paired network-median effects: DeltaPR=3.290888851555555 versus
empirical2.645333394424256; Expected-minus-Observed alignment=
20.925236083846388 percentage points versus empirical16.802183685318703.
Uncertainty and dependent-policy tables below passed independent validation.
The selected fit is calibrated, not an independent prediction, and both
absolute values and effect-size errors must be reported.

## Exact K evidence

K is independently selected from each Intact spectrum as the first cumulative
fraction >=.95. Block uses that same number even if its captured variance is
below95%; maximizing with Block K would violate the empirical rule.

| Network | K | Control at K-1 (%) | Control at K (%) | Block at Control K (%) |
|---|---:|---:|---:|---:|
|1|6|93.090155|97.105188|87.660183|
|2|6|94.456844|97.873164|88.278826|
|3|5|91.038888|95.221875|76.036651|
|4|5|90.705883|95.112424|76.585858|
|5|6|94.816634|97.753230|88.105429|
|6|6|92.568146|96.707359|88.006100|
|7|6|94.785668|97.779010|88.092749|
|8|6|94.159301|97.087394|87.950401|
|9|6|93.382137|96.673612|87.874229|
|10|5|92.198169|95.728659|76.571514|

The reference is analytically identical across geometry candidates within a
network; IMPLEMENTATION_NOTES.md proves the cancellation. K is not forced
equal across different networks. PR still uses all eigenvalues. The same K
governs comparison width, Control top-K denominator and 10,000-draw null.

Independent grid audit: 2,137 checks PASS. Maximum metric discrepancy
8.881784197001252e-15, denominator discrepancy8.526512829121202e-14,
null discrepancy4.440892098500626e-16. Explicit threshold and Control-only
sentinels pass. The covariance/eigendecomposition audit is separate from
the production SVD path; projected sample variances and QR projectors verify
the alignment/null calculations.

## Preservation and scope

Initial inventory includes1,763 pre-existing files,110,393,731,485 bytes,
including hidden, ignored and untracked evidence. No old paper scientific
file, figure or source helper is overwritten. The only permitted existing
file change is AGENTS.md navigation. The complete follow-up SHA256 comparison
passed: all1,762 protected files are unchanged. New paths and all four new
figure basenames include alignment95. The final full SHA256 comparison after
the numerical run also passes; its receipt is PRESERVATION.json.

Old K15-selected results and common-K sensitivity remain historical evidence,
not the current primary benchmark. Accepted Stage-1/2/3 science, empirical
targets, timing, seeds, noise, feasibility, controller gains and sampling are
unchanged. Main a/b reuse frozen Stage-2 arrays and statistics. No new test
family is introduced for fitted effects. No panel e, prediction, regression,
learning/adaptation, new noise family or new parameter point is authorized.

## Corrected primary result

Model summaries are network medians ± bootstrap SE (10 networks, 10,000
frozen whole-network resamples). Empirical errors are resample SD and are
not directly the same uncertainty estimator.

| Quantity | Corrected model | Empirical target |
|---|---:|---:|
|Intact / Control PR|3.463191 ± .128573|5.386083 ± .108494|
|Block PR|6.754080 ± .018892|8.031417 ± .149217|
|Observed alignment (%)|31.995182 ± .757277|32.493122 ± 1.122624|
|Expected alignment (%)|52.340264 ± .717838|49.295305 ± 3.298773|
|Paired model DeltaPR / empirical marginal difference|3.290889 ± .112229|2.645333; paired uncertainty unavailable|
|Paired model deficit (pp) / empirical marginal difference|20.925236 ± 1.246532|16.802184; paired uncertainty unavailable|

Relative fitted-effect errors are +24.4036% for DeltaPR and +24.5388% for
deficit. Absolute model PR remains too low. The model matches the joint
direction of the empirical population effects under the corrected rule, but
does not exactly reproduce their absolute values or contrasts. This is
calibration on those effects, not an independent prediction or anatomical
identification. Median paired effects need not equal differences of marginal
medians. No new inferential family or fitted-effect p-values were introduced.

Across the 20 common-feasible points, DeltaPR spans .117677–3.591828;
deficit spans −45.800365–51.163436 pp. These separate ranges do not imply every
combination is jointly attainable. All rejected/unselected rows are retained.

At the SAME corrected selected point, K15 sensitivity gives observed
35.210829 ± .505507%, expected87.032437 ± .386441%, and paired deficit
51.690389 ± .588203 pp. The historical common-K sensitivity gives observed
31.414858 ± .649912%, expected58.262624 ± .547595%, deficit26.702757 ± .679364 pp.
Both remain below-null at this new selected point, unlike the sign reversal
at the old K15-selected geometry. The substantial quantitative dependence on
the PC rule must still be disclosed. Neither sensitivity selected geometry.
Null Monte Carlo SE ranges .072818–.096123 pp for Control95, separate from
network-bootstrap uncertainty.

## Component removals and movement

|Policy|PR|Observed (%)|Deficit (pp)|Residual variance|Endpoint RMS (mm)|MO (ms)|Peak time (ms)|Peak speed (m/s)|Separation/scatter|
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|Intact|3.463191 ± 0.128573|100.000000 ± 0.000000|-47.659736 ± 0.717838|0.125294 ± 0.002518|19.753315 ± 0.520405|55.750000 ± 0.373818|200.750000 ± 0.371641|0.416579 ± 0.000737|7.357279 ± 0.215065|
|Remove feedback|3.486054 ± 0.124720|99.688829 ± 0.040711|-47.348566 ± 0.730851|0.136886 ± 0.002990|29.273236 ± 0.904731|55.000000 ± 0.254196|200.000000 ± 0.248224|0.417082 ± 0.000673|4.887959 ± 0.124002|
|Remove b|5.903385 ± 0.044694|32.034039 ± 0.787478|21.047231 ± 1.479314|0.125329 ± 0.002506|19.540083 ± 0.491955|42.500000 ± 0.882636|190.750000 ± 2.071969|0.290408 ± 0.006040|4.997560 ± 0.222023|
|Block|6.754080 ± 0.018892|31.995182 ± 0.757277|20.925236 ± 1.246532|0.136887 ± 0.002957|28.633554 ± 0.875728|55.000000 ± 1.397890|211.500000 ± 2.961700|0.219752 ± 0.009155|2.993140 ± 0.176242|

Expected alignment is52.340264 ± .717838% for every policy because the
standard Intact reference and null are shared. Residual variance is in frozen
normalized units. MO/peak times are target/trial medians within each network,
then the network median. Endpoint RMS averages target-specific dispersion
about each target mean; it is not error from the nominal target.

Removing the state-setting term changes the late geometry much more than
removing feedback alone in this selected effective model. These interventions
are not pure manipulations of PR versus orientation, do not establish two
anatomical pathways, and do not imply a neural-prediction deficit.

All9,600 movements are included (2,400/policy). Near-zero peaks, missing
MO+0:100-ms windows and nonfinite arm/state cases are all zero.

|Policy|Boundary peaks|Multiple large peaks|Trials excluded|
|---|---:|---:|---:|
|Intact|0|0|0|
|Remove feedback|0|9|0|
|Remove b|0|200|0|
|Block|125|699|0|

All40 primary network/policy preparation bounds and all100 noise-control
network/condition bounds pass. Kinematic irregularity is nevertheless a
substantive limitation: a detected onset and an available neural window do
not guarantee a naturalistic movement. No QC outcome entered selection.

## Separate noise controls

|Source varied|Amplitude|PR|Observed (%)|Deficit (pp)|Normalized residual variance|Raw residual variance|
|---|---:|---:|---:|---:|---:|---:|
|Cue state|0|3.463461 ± 0.128596|99.997268 ± 0.000303|-47.656713 ± 0.718008|0.124822 ± 0.002479|0.009331 ± 0.000161|
|Cue state|0.05|3.463297 ± 0.128586|99.999314 ± 0.000076|-47.658979 ± 0.717880|0.124929 ± 0.002485|0.009342 ± 0.000162|
|Cue state|0.1|3.463191 ± 0.128573|100.000000 ± 0.000000|-47.659736 ± 0.717838|0.125294 ± 0.002518|0.009370 ± 0.000164|
|Cue state|0.2|3.463140 ± 0.128529|99.997213 ± 0.000303|-47.656695 ± 0.717995|0.126796 ± 0.002665|0.009476 ± 0.000173|
|Cue state|0.4|3.463721 ± 0.128405|99.974618 ± 0.002804|-47.631968 ± 0.719217|0.132859 ± 0.003323|0.009893 ± 0.000209|
|Temporal|0|3.412333 ± 0.124878|99.459325 ± 0.046387|-47.060966 ± 0.739502|0.000482 ± 0.000046|0.000034 ± 0.000003|
|Temporal|0.05|3.428014 ± 0.126857|99.863652 ± 0.011212|-47.509648 ± 0.721699|0.031701 ± 0.000665|0.002370 ± 0.000043|
|Temporal|0.1|3.463191 ± 0.128573|100.000000 ± 0.000000|-47.659736 ± 0.717838|0.125294 ± 0.002518|0.009370 ± 0.000164|
|Temporal|0.2|3.592917 ± 0.131938|99.476129 ± 0.039421|-47.073537 ± 0.723340|0.499018 ± 0.010048|0.037291 ± 0.000656|
|Temporal|0.4|4.053427 ± 0.139556|95.653906 ± 0.244202|-43.246185 ± 0.771672|1.921888 ± 0.036075|0.143897 ± 0.002440|

Expected alignment is52.340264 ± .717838% at every level. The other noise
source stays at.10; no amplitude or seed was adjusted. Neither tested
one-factor isotropic family reproduces the selected Block PR/alignment pair.
Even temporal amplitude.40 reaches PR4.053427 while retaining95.653906%
observed alignment, compared with Block PR6.754080 and31.995182%. This does
not rule out all structured noise mechanisms or say anything about new
prediction R-squared. No residual-variance-selected amplitude is introduced.

## Reuse and bounded replay

- Reused all frozen networks/controllers, empirical extraction, timing
  calibration, normalization/null bias, seeds, bootstrap indices and saved
  grid trajectories. No reference, timing or grid simulation was rerun.
- Reused primary Intact and newly selected Block preparation for all networks,
  and all2,400 Intact movement trials.
- Replayed20 network/partial-removal preparation sets and80 nonbaseline
  Intact noise preparation sets only to refresh geometry-dependent component
  evidence. The latter's mean-rate and GO-state agreement with preserved
  Intact noise outputs was asserted below1e−9. These100 sets contain24,000
  preparation trials; all draws and model settings are frozen.
- Replayed30 changed network/policy movement sets,7,200 trials, from the
  corrected selected geometry. No behavior-based selection or retuning.
- Reused the passed wrapper/draw/indexing/fine-step preflight at its explicitly
  documented original definition; did not mislabel it a new geometry fine-step
  test. Current raw transitions and arm updates were audited separately.

## Independent numerical validation

|Check|Outcome|
|---|---|
|Grid K/projection/denominator/null/selection|PASS,2,137 checks; max metric error8.88e−15|
|Native prep/arm/events and bootstrap uncertainty|PASS,49,360 checks; max prep4.44e−16, arm2.22e−16, SE1.91e−14|
|Raw-trial covariance/PR/alignment, all time windows, fixed-half reliability, residuals, movements|PASS,9,520 checks; max metric1.33e−14, residual5.11e−15, movement increment0, endpoint6.94e−18|
|Six selected-primary bootstrap error bars|PASS,independent discrepancy0|
|K95 threshold and non-common-K sentinels|PASS|
|Old-file preservation|PASS,1,762 protected files, including final full comparison|
|Code Analyzer|PASS,all12 new MATLAB files, no warnings|

Full precision: results/paper_ready/alignment95/REPORT.json,
geometry_map.csv, selected_K_audit.csv, policy_source.csv, noise_controls.csv,
movement_trial_qc.csv and movement_target_qc.csv. Controls MAT/JSON also
retain every window-specific K and each fixed-half reference K. Raw evidence
is in the ignored results/paper_ready/cache/alignment95 directory.

The bounded smoke/pinned-reference check passes: short-segment discrepancy
2.220446049250313e−16; Q relative residual7.345231414670959e−14. No full Stage-1
ensemble replay, model construction, prediction or accepted-result overwrite.

## Fixed split reliability

Descriptive medians across networks for fixed first15 versus last15 trials
per target; these halves are not selected for fit. Each first-half spectrum
defines its own Control95 K. This is within-policy split reliability, not
Control-to-Block alignment or prediction.

|Policy|Half 1 PR|Half 2 PR|Half 1 onto half 2 (%)|Half null (%)|
|---|---:|---:|---:|---:|
|Intact|3.498086|3.502626|97.822646|52.689611|
|Remove feedback|3.528978|3.523834|97.591503|52.690335|
|Remove b|5.932921|5.928863|98.258476|18.477596|
|Block|6.779736|6.779943|97.805571|13.428497|


## Figures, publication and cleanup

All four new editable FIGs were reopened and checked against tagged source
arrays and both error-bar directions (11/26/10/16 checks,63 total). Every PNG
was visually inspected. The main title had an unescaped literal percent in
sprintf; the corrected renderer uses %% and the saved FIG was repaired
without recomputing data. openfig reduced the canvas on this workstation,
so its original1800×1080 canvas was explicitly restored before export.
The title verifier was corrected to inspect TiledChartLayout.Title; the
initial descendant-string lookup and a diagnostic scalar-string condition
were operational-only failures. Final title and11 source-series checks pass.
No numerical mismatch occurred and no scientific simulation was repeated.

Current pairs in plots/paper_ready/{fig,png}/:

- main_modelling_alignment95
- support_calibration_alignment95
- support_noise_controls_alignment95
- support_movement_qc_alignment95

All four PNGs are native attachments with full legends in the existing
Notion figure page. Each was downloaded after publication and SHA256-matched
to its reviewed local PNG. Readback contains8 native images:4 corrected and
4 preserved historical images. Old K15/common-K scientific evidence is
explicitly historical, not deleted or relabeled as the primary analysis.

New active source is in analysis/paper_ready/alignment95 and
figures/paper_ready/alignment95. Documentation, compact outputs and manifests
use corresponding alignment95 subdirectories. Valid unchanged shared helpers
remain dependencies; no archive, new accepted-model tree or old-result fallback
was introduced. Required new raw caches remain local/ignored. The final
INVENTORY.csv classifies each new file, and INPUTS_BEFORE.csv preserves the
complete old-file inventory. No redundant scratch artifact or unambiguous
deletion candidate was identified; zero files were deleted. Intermediate
per-file static receipts retain their distinct preflight/provenance evidence.

Normal v3 checkpoint/push and safe main fast-forward/push remain conditioned
on final Git checks. Verified SHA/equal refs/clean status are recorded in
Agent Log, Agent Handoff and START HERE after success, not preclaimed here.
No force push, history rewrite, accepted-science change, new model or panel e.
STOP FOR SCIENTIFIC REVIEW.
