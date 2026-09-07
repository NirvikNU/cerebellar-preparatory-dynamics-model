# STAGE3-EVIDENCE-RECOVERY-01 — validated completion

2026-09-08 Asia/Jerusalem / 2026-09-07 UTC. Scientific review pending.
Recovery, independent numerical audit, figure QA and native publication PASS.
The final commit/push receipt and actual SHA are recorded in Agent Log,
Agent Handoff and START HERE after remote verification; this report is part
of that single intended checkpoint, not a self-referential SHA amendment.

## Reused and recovered evidence

Resumed the complete dirty Stage-3 worktree at
302138aacac1c81132f57c2da3578e5b29494ffb. Reused all original references,
1080-row grid, selected states/definitions, primary movements, duplicate
primary additional records, original consequences/statistics and prior stop
receipts unchanged. No reference/sweep/primary/selection replay occurred.

The exact whitelist is in RECOVERY_CASES.mat/JSON and RECOVERY_PLAN.md:
20 unique non-primary movement sets, 20 partial-removal network/policy sets,
4 original sensitivities, and one fine-step preparation. Total 45 cases:
29 eight-target preparation protocols and 192 target movement rollouts.
The sensitivity paired trajectories are their original prespecified cases,
not new intact reference generation. Frozen IDs, xB, gains, initial states,
native/saved/analysis steps, drive, arm, seed and windows were reused.

Raw evidence: results/stage_3/current/cache/evidence_recovery/, 45 MAT files,
572,885,104 bytes, ignored/local. Rates, native preparation states, GO states,
hand/arm/torque trajectories, covariance and null identities are retained.
The recovery runner refuses repeat integration or overwrite. Sensitivity
definition structs retain primary template b/corticalConstant fields; their
effective coefficients are explicitly recomputed from the frozen variant xB
and gains and saved in raw.intact/raw.block.b and corticalConstant. Do not
interpret inherited template fields as the variant's delivered coefficients.

Recovery completed in 275.0920 seconds. All 266 case-level comparisons pass;
largest absolute discrepancy 2.842170943040401e-14 (endpoint millimetres).
Declared comparison tolerance was 1e-9 absolute + 1e-10 relative, with no
scientific threshold change. Original statistics were never overwritten.

## Independent audit and results

RECOVERY_INDEPENDENT_AUDIT.json contains 56,963 passing comparisons:
explicit per-neuron reference SD/centering and sentinel indexing; independent
covariance/eigen PR and minimum strictly >95% K; activity projection and
trace alignment; 10,000-draw QR null comparisons; map identities, screen,
physical/finite/analytic intersections; saved selection ordering predicates;
primary/additional hand RMS and endpoint errors; exact bootstrap indices,
sorted bootstrap medians/SEs, all 1024 signs and declared BH families;
native recovered states/activity/components; fine-step comparison.
Maximum absolute comparison residual is 5.115907697472721e-13.

Confirmed map: 1080 rows; 696 tested; 384 nonlinear-untested; 453 analytically
sufficient; 335 certified intersections; 78 further physical/empirical
successes outside the sufficient bound. All 30 network/direction sets contain
certified points. Forty primary/additional records represent 30 unique
identities and ten duplicates, nested within independent n=10 networks.

Original network medians +/- bootstrap SE remain:

| Metric | Intact / observed | Block / expected |
| --- | --- | --- |
| PR | 3.392271361999529 +/- 0.129254618356150 | 6.999270100155348 +/- 0.000049346483274 |
| Alignment (%) | 2.008356409064790 +/- 0.068267143452948 | 58.71524869940925 +/- 0.541532982430642 |
| Early trajectory RMS (mm) | 1.248073456299161e-13 +/- 7.836397679997575e-15 | 32.01909796116527 +/- 0.639354937563911 |

Primary common K=7. PR difference median 3.606998738155818 +/-
0.129205322512393; observed-minus-expected alignment -56.84955871332159
+/- 0.463347350738455 percentage points. Both geometry exact p and BH q
are 0.001953125; the separate movement exact p is 0.001953125.
Intact numerical-zero discrepancy validates its comparator fidelity, not
empirical reach accuracy. All 30 unique selected sets have larger movement
discrepancy than intact; nested early RMS range 14.5888–33.8891 mm. The 20
non-primary sets span 14.5888–24.1581 mm. No behavioural reselection/test added.

Four-policy median state error: intact ~1.79e-14, remove b 3.241699,
remove feedback ~1.92e-14, remove both 3.465835. PR respectively 3.392271,
6.994415, 3.392271, 6.999270. Below-null alignment differences respectively
-49.553165, 53.516757, -49.553165, 56.849559 percentage points. The intact-like
policies use common K=5–6; block-like policies K=7, each with its matched null.
Full SEs, component maxima, sensitivity and nested tables are exported under
results/stage_3/current/recovery_audit/ and published natively in Notion.

Independent local endpoint Jacobians agree within 4.5475e-13. Native versus
fine preparation relative curve difference 0.001769380418879 <0.01; GO
relative difference 1.441490335783283e-15 <1e-4. Separate settled/finite
PR difference <=2.0428e-14 and alignment difference <=0.01051332 (fraction)
are retained, not forced equal. Maximum map null MC SE 0.0009672573;
maximum half-draw difference 0.002736182; unchanged Hoeffding radius
0.0269338613 plus 0.005 margin.

Limitation: full native grid trajectories were deliberately not retained.
Their recorded native extrema are checked against stored values/thresholds;
they were not independently reconstructed by an unauthorized grid replay.
Recovered partial/sensitivity/fine native states support direct extrema checks.
Recorded component envelopes include defined off-term magnitudes before mode
gating; removed components are not actually delivered. Actual total is gated.
Admissibility limits are modelling assumptions, not physiological calibration.

## Figures and publication

Exactly four reviewed FIG/PNG pairs in plots/stage_3/{fig,png}/:

- result_1_preparation_and_movement — original pair retained byte-for-byte.
- result_2_preparatory_geometry — explicit actual-line condition legend and
  marker headroom. The initial PNG already showed the legend; explicit handles
  make regenerated output robust rather than claiming an absent observed legend.
- diagnostic_1_feasible_solution_map — finite 0/1 logical-mask ingestion,
  CSV round-trip/invalid-value rejection tests; actual grid and fixed 30-set
  denominator; sample d1–d3 parameter positions and primary star; overlapping
  rejection masks and outside-bound measured successes remain visible.
- diagnostic_2_component_removal — actual four-policy comparison; a targeted
  final presentation-only rerender added PR marker headroom after visual QA.

All four FIGs reopened; all PNGs inspected, including the final D2 correction.
58 exported figure-object/independent-bootstrap comparisons pass with zero
error, including PR/alignment error bars and the preparation/spectrum bands.
All new Stage-3 MATLAB code passed Code Analyzer; CSV mask tests passed.
Early analyzer warnings in new completion code were fixed before execution;
no science was changed. All existing supplemental stage3_validate checks pass
in FINAL_AUDIT.json, including protected hashes and four-bundle reopening.

Results/Diagnostics each have two native uploaded images with full native
captions, summary tables and methods/limitations. Parent/specification/summary
status updated; four child memberships and equations/Mermaid preserved.
Initial generic-MIME upload attempts were rejected; explicit image/png with
fresh slots succeeded. Signed-URL caption search edits were rejected without
mutation; replacing only the two authorized scientific-page bodies preserved
their tables and produced the four verified native image captions. No open
publication error remains. See RECOVERY_NOTION_PUBLICATION.json.

## Preservation, file scope and checkpoint boundary

Before/after manifests audit all 292 starting files. All 233 Stage-1/Stage-2
protected files (1,225,280,632 bytes) and every original Stage-3 numerical,
registry/statistics/configuration/model-source file are unchanged. Only four
starting paths changed intentionally: README.md, stage3_figures.m, and the
Results-2 FIG/PNG pair. Zero unexpected hash differences. The final targeted
D2 rerender touched only a newly completed figure pair, not a starting asset.

New files are dedicated recovery/audit/finalization helpers and runners,
strict mask tests/helper, recovery-case/provenance/audit receipts, numerical
summary exports, and both diagnostics pairs. Accumulated Stage-3 implementation,
original outcomes, root scope documentation and both historical stops are
included in the intended checkpoint. Large original/recovered caches, console
logs and OS/Drive metadata remain ignored/local; none is force-added or deleted.
No cleanup, training, tuning, prediction, noise, learning, adaptation or new
model occurred. No protected scientific asset or prior result was changed.

One normal commit/push to the existing v3-romano-hennequin upstream is the
authorized final checkpoint. No force push/history rewrite. The exact final
SHA/equality/clean-status receipt belongs to Agent Log/Handoff/START HERE after
the actual push. Stop for scientific review; completion is not acceptance.
