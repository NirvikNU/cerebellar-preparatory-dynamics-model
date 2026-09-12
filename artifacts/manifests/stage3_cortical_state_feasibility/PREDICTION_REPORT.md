# Stage-3 fixed-controller prediction validation

Starting checkpoint: c40e0eb74679a0122cb1e54c784c2e56946a5e14. STAGE3-PREDICTION-VALIDATION-01, binding repair 2026-09-11.

The original locked plan and binding analysis choices were unchanged. The only repair to the existing stochastic wrapper was nargin<9 to nargin<8. Required passed preflight/raw dependencies remain preserved. Resolved stop prose and interim static receipts were later consolidated and retired under STAGE3-PREGO-NOISE-CAUSAL-DIAGNOSTIC-01; see POSTGO_REPORT.md and its explicit inventory. All baseline prediction numbers below remain unchanged.

Ten networks x eight targets x 30 trials x four policies x three fixed noise scales = 28,800 task trials. Primary s=.10; .05 and .20 are non-selected sensitivities. Native .2-ms integration, saved1-ms activity, analysis10-ms samples. No controller, geometry, movement, noise or inference parameter was tuned.

All values below are network median +/- SE of the median from the original10,000 whole-network bootstrap draws, n=10, unless explicitly labeled ranges. Trials/targets are nested, not independent inferential units. Negative R2 is retained.

## Primary metrics and fixed noise sensitivities

| s | Policy | Prep-to-early neural R2 | Prep-to-hand R2 | Prep-to-speed R2 |
| --- | --- | --- | --- | --- |
| 0.05 | Intact | 0.9953787264 +/- 0.0007689361277 | 0.9913031486 +/- 0.0009327444873 | -0.01652709342 +/- 0.005012584736 |
| 0.05 | Remove feedback | 0.9947560308 +/- 0.0005063265369 | 0.9863238803 +/- 0.001327289569 | -0.01216328755 +/- 0.01044647184 |
| 0.05 | Remove b | 0.9948064819 +/- 0.001819184757 | 0.9870827764 +/- 0.002286467226 | 0.134370233 +/- 0.06407374502 |
| 0.05 | Block | 0.7736678142 +/- 0.01049655522 | 0.1441573991 +/- 0.02962222079 | 0.4088220474 +/- 0.05380379358 |
| 0.10 | Intact | 0.9727720452 +/- 0.002831635336 | 0.951288757 +/- 0.02066370664 | -0.01754360872 +/- 0.008231490116 |
| 0.10 | Remove feedback | 0.9696944578 +/- 0.006837098575 | 0.9176655807 +/- 0.01449438185 | -0.008735520919 +/- 0.006634578185 |
| 0.10 | Remove b | 0.9766889981 +/- 0.003709009813 | 0.9489138574 +/- 0.01964105688 | -0.01136807607 +/- 0.01282360416 |
| 0.10 | Block | 0.5085025356 +/- 0.01100636474 | 0.0722281761 +/- 0.02031228288 | 0.06698894779 +/- 0.02120038683 |
| 0.20 | Intact | 0.6546839858 +/- 0.01018333605 | 0.5428882535 +/- 0.03054982178 | -0.01968197622 +/- 0.004912864823 |
| 0.20 | Remove feedback | 0.6101316729 +/- 0.0102693601 | 0.4303937229 +/- 0.02873856625 | -0.006627874912 +/- 0.004179571191 |
| 0.20 | Remove b | 0.7533208697 +/- 0.008416824453 | 0.5552637878 +/- 0.0252409016 | -0.01930150368 +/- 0.003867005225 |
| 0.20 | Block | 0.1801327124 +/- 0.006320756813 | 0.01273737027 +/- 0.01148943546 | -0.01260504467 +/- 0.004914880325 |

## Nine primary paired contrasts: s=.10 only

Lesion minus Intact; exact paired mean-difference sign flips over all1,024 signs, two-sided, one nine-test BH family.

| Metric | Lesion | Median difference +/- SE | Mean difference | Exact p | BH q |
| --- | --- | --- | --- | --- | --- |
| neuralR2 | Remove feedback | -0.01099547686 +/- 0.004461436548 | -0.01097946646 | 0.013671875 | 0.028125 |
| neuralR2 | Remove b | 0.00176351018 +/- 0.004205714571 | 0.0007850610931 | 0.876953125 | 0.876953125 |
| neuralR2 | Block | -0.4692578496 +/- 0.01211436151 | -0.4647247774 | 0.001953125 | 0.005859375 |
| handR2 | Remove feedback | -0.03307939411 +/- 0.01223213706 | -0.03286664317 | 0.01953125 | 0.029296875 |
| handR2 | Remove b | -0.006061780294 +/- 0.002359133945 | -0.005414146878 | 0.015625 | 0.028125 |
| handR2 | Block | -0.8755880559 +/- 0.03522174516 | -0.8590851287 | 0.001953125 | 0.005859375 |
| speedR2 | Remove feedback | -0.003601362291 +/- 0.008294770732 | 0.006889908664 | 0.4296875 | 0.4833984375 |
| speedR2 | Remove b | 0.006240274136 +/- 0.01417454344 | 0.02590189823 | 0.06640625 | 0.08537946429 |
| speedR2 | Block | 0.08158421895 +/- 0.02284886223 | 0.09187342577 | 0.001953125 | 0.005859375 |

## Within-target prediction (supporting)

Fixed full-ensemble hand plane/speed axis; only the per-target OLS relationship is leave-one-out. Eight target-specific R2 values are averaged within network. These are not strict fold-wise feature-learning estimates.

| s | Policy | withinHandR2 | withinSpeedR2 | prepeakWithinHandR2 | prepeakWithinSpeedR2 |
| --- | --- | --- | --- | --- | --- |
| 0.05 | Intact | -0.1310523772 +/- 0.009358569446 | -0.0304599798 +/- 0.02169379866 | 0.3177004508 +/- 0.01874526155 | 0.3281142539 +/- 0.04162720159 |
| 0.05 | Remove feedback | -0.06529700528 +/- 0.02582490151 | -0.03138136874 +/- 0.02556625421 | 0.423458596 +/- 0.02117493025 | 0.2210278882 +/- 0.06616335099 |
| 0.05 | Remove b | -0.1667342322 +/- 0.01149490341 | -0.07208492651 +/- 0.01565375672 | 0.1702756641 +/- 0.02417359818 | 0.3841408722 +/- 0.05502124159 |
| 0.05 | Block | -0.1741735534 +/- 0.01039641067 | 0.01611833875 +/- 0.03165404489 | 0.00439866042 +/- 0.02722577379 | 0.08885628931 +/- 0.05845397695 |
| 0.10 | Intact | -0.1225890645 +/- 0.007405911217 | 0.05115097185 +/- 0.01529270342 | 0.2511162354 +/- 0.05612847335 | 0.27725472 +/- 0.04743669435 |
| 0.10 | Remove feedback | -0.07219845754 +/- 0.01945474131 | 0.03404198333 +/- 0.02987178619 | 0.2430013241 +/- 0.04283595957 | 0.1604703942 +/- 0.03218898407 |
| 0.10 | Remove b | -0.1783880865 +/- 0.01388931523 | -0.06882463126 +/- 0.01960571164 | 0.05381702432 +/- 0.05517562066 | 0.3384585681 +/- 0.04717152178 |
| 0.10 | Block | -0.1739049184 +/- 0.00978432799 | 0.06209655183 +/- 0.03167881774 | -0.07523360919 +/- 0.02700185936 | 0.09086414404 +/- 0.04375983463 |
| 0.20 | Intact | -0.1404517963 +/- 0.006713840402 | 0.07755248612 +/- 0.02188338536 | -0.05057811523 +/- 0.03689119285 | 0.07734183763 +/- 0.03695547377 |
| 0.20 | Remove feedback | -0.1341575075 +/- 0.01153686642 | 0.09097634971 +/- 0.02409721573 | 0.02607693916 +/- 0.02598849213 | 0.04364809244 +/- 0.02250097939 |
| 0.20 | Remove b | -0.1491117068 +/- 0.007697052693 | -0.03384524664 +/- 0.01174885026 | -0.1047107635 +/- 0.04665179059 | 0.08584603593 +/- 0.03056589867 |
| 0.20 | Block | -0.170074589 +/- 0.007146685341 | 0.05437176823 +/- 0.0228887931 | -0.09342908807 +/- 0.02220531966 | 0.1032378716 +/- 0.01643562547 |

## Pre-peak controls and held-out speed-axis variance

Movement-period features: own peak-speed -150:10:-50 ms, same preprocessing/CV. Captured variance uses outer-training axes applied to held-out activity; the pooled projection variance is divided by pooled full-population variance.

| s | Policy | prepeakHandR2 | prepeakSpeedR2 | speedCapturedVariance | prepeakSpeedCapturedVariance |
| --- | --- | --- | --- | --- | --- |
| 0.05 | Intact | 0.9839688206 +/- 0.003303802719 | 0.0978104795 +/- 0.02563324395 | 0.1650358176 +/- 0.02798006516 | 0.003108973478 +/- 0.02590855895 |
| 0.05 | Remove feedback | 0.9818109241 +/- 0.003372346709 | 0.02060320376 +/- 0.03065043516 | 0.1662826747 +/- 0.03098174235 | 0.07514783674 +/- 0.04864568925 |
| 0.05 | Remove b | 0.9820332149 +/- 0.006154958224 | 0.3424533045 +/- 0.03211713397 | 0.08356932166 +/- 0.01100003899 | 0.002638956894 +/- 0.0009424983347 |
| 0.05 | Block | 0.1178216049 +/- 0.02754080821 | 0.3665093595 +/- 0.03402342027 | 0.07946254021 +/- 0.01437387426 | 0.02283208998 +/- 0.006510492589 |
| 0.10 | Intact | 0.9441789198 +/- 0.02885019746 | 0.05335389164 +/- 0.02476126304 | 0.1402772224 +/- 0.02248902693 | 0.01058015987 +/- 0.002916461328 |
| 0.10 | Remove feedback | 0.9232777633 +/- 0.02681778098 | 0.022937031 +/- 0.01518710403 | 0.1352047107 +/- 0.02090182581 | 0.0330076199 +/- 0.01772940276 |
| 0.10 | Remove b | 0.9409660105 +/- 0.02566187407 | 0.1699338251 +/- 0.02149934417 | 0.1135949569 +/- 0.0130486135 | 0.006851118326 +/- 0.001459194974 |
| 0.10 | Block | 0.06350674781 +/- 0.03254962259 | 0.03484612571 +/- 0.02742753048 | 0.07730543726 +/- 0.006504248551 | 0.02537119067 +/- 0.004182220321 |
| 0.20 | Intact | 0.4369300783 +/- 0.02862012037 | -0.004619106847 +/- 0.005691739405 | 0.05647188387 +/- 0.01621745394 | 0.02797985384 +/- 0.005697637224 |
| 0.20 | Remove feedback | 0.3746403309 +/- 0.02128654484 | -0.00419773889 +/- 0.005236374496 | 0.04329380232 +/- 0.00905857887 | 0.0320376152 +/- 0.004244749889 |
| 0.20 | Remove b | 0.4131457643 +/- 0.02801640749 | -0.01629108755 +/- 0.01755186601 | 0.09887067134 +/- 0.01159055945 | 0.02893424908 +/- 0.006140699998 |
| 0.20 | Block | 0.02437835925 +/- 0.02994331879 | -0.01793769562 +/- 0.003361625416 | 0.03883777178 +/- 0.002054707036 | 0.01832876282 +/- 0.001606784615 |

## Matched-PC control

| s | Pair | Intact R2 | Lesion R2 | Prep K range | Early K range |
| --- | --- | --- | --- | --- | --- |
| 0.05 | Intact vs Remove feedback | 0.9953787264 +/- 0.0007689361277 | 0.9947560308 +/- 0.0005063265369 | 3-4 | 2-2 |
| 0.05 | Intact vs Remove b | 0.9953787264 +/- 0.0007689361277 | 0.9948064096 +/- 0.000529542878 | 3-4 | 2-2 |
| 0.05 | Intact vs Block | 0.9953787264 +/- 0.0007689361277 | 0.4890011041 +/- 0.0633950019 | 3-4 | 2-2 |
| 0.10 | Intact vs Remove feedback | 0.9727720452 +/- 0.002831635336 | 0.9687705184 +/- 0.003636465082 | 4-4 | 3-4 |
| 0.10 | Intact vs Remove b | 0.9727720452 +/- 0.002831635336 | 0.9773405736 +/- 0.006265820438 | 4-4 | 3-4 |
| 0.10 | Intact vs Block | 0.9727720452 +/- 0.002831635336 | 0.4493557801 +/- 0.04755746262 | 4-4 | 3-4 |
| 0.20 | Intact vs Remove feedback | 0.6546839858 +/- 0.01018333605 | 0.6132952451 +/- 0.01001227141 | 18-22 | 22-26 |
| 0.20 | Intact vs Remove b | 0.6607800037 +/- 0.009221234218 | 0.7533208697 +/- 0.008416824453 | 7-8 | 15-21 |
| 0.20 | Intact vs Block | 0.6546839858 +/- 0.01018333605 | 0.2077437535 +/- 0.006342508013 | 18-22 | 22-26 |

## Neural chance and original 75-percent PCA counts

Chance: median over100 fixed response-correspondence permutations per network, followed by network median/SE. Permutations preserve complete-ensemble target counts.

| s | Policy | Chance R2 | Prep K range | Early K range |
| --- | --- | --- | --- | --- |
| 0.05 | Intact | -0.01139941309 +/- 0.0006635196632 | 3-4 | 2-2 |
| 0.05 | Remove feedback | -0.01124756925 +/- 0.0006745086756 | 3-4 | 2-2 |
| 0.05 | Remove b | -0.01105904548 +/- 0.0005738922251 | 4-4 | 2-3 |
| 0.05 | Block | -0.01064040023 +/- 0.0001454736 | 6-6 | 7-8 |
| 0.10 | Intact | -0.01145617559 +/- 0.0005814658525 | 4-4 | 3-4 |
| 0.10 | Remove feedback | -0.01122168288 +/- 0.0006037165804 | 4-5 | 4-5 |
| 0.10 | Remove b | -0.01110833309 +/- 0.0004184281031 | 4-5 | 3-5 |
| 0.10 | Block | -0.01061855798 +/- 0.0001581618398 | 7-7 | 21-24 |
| 0.20 | Intact | -0.01035952392 +/- 0.0003621805097 | 18-22 | 22-26 |
| 0.20 | Remove feedback | -0.01035614916 +/- 0.0003032767838 | 23-27 | 23-27 |
| 0.20 | Remove b | -0.01053461214 +/- 0.0001876406348 | 7-8 | 15-21 |
| 0.20 | Block | -0.0105868535 +/- 0.0001419014799 | 24-28 | 33-36 |

## Speed-axis orientation (supporting)

Squared cosine between the single full-condition axes. Expected alignment averages100 within-target speed-shuffle refits. Observed and expected alignments are percentages; expected-minus-observed differences are percentage points and may be negative. No additional primary tests.

| s | Epoch | Intact vs | Observed | Expected | Expected-observed |
| --- | --- | --- | --- | --- | --- |
| 0.05 | Prep | Remove feedback | 58.00645258 +/- 11.58420436 | 61.12362021 +/- 10.73264179 | -0.6629112341 +/- 1.578921318 |
| 0.05 | Prep | Remove b | 1.571636838 +/- 0.9627033877 | 3.921204791 +/- 0.9453607988 | 1.683839692 +/- 0.6136681518 |
| 0.05 | Prep | Block | 0.4027594347 +/- 0.3026325506 | 0.3221330318 +/- 0.07923476201 | -0.06695758133 +/- 0.1846839158 |
| 0.05 | Prepeak | Remove feedback | 65.73434448 +/- 11.51526125 | 52.42886497 +/- 10.78681163 | -9.777151732 +/- 11.73997853 |
| 0.05 | Prepeak | Remove b | 69.83534001 +/- 3.825984631 | 7.54544952 +/- 2.17746264 | -61.84740037 +/- 3.438659281 |
| 0.05 | Prepeak | Block | 1.135968538 +/- 0.7888923608 | 0.8809862066 +/- 0.2190990808 | -0.537430819 +/- 0.9371668256 |
| 0.10 | Prep | Remove feedback | 49.12765613 +/- 9.54480143 | 48.90446343 +/- 9.353173286 | 1.758531174 +/- 1.586233992 |
| 0.10 | Prep | Remove b | 6.431658127 +/- 2.055365914 | 8.917961757 +/- 0.8027105424 | 3.022506169 +/- 1.420979984 |
| 0.10 | Prep | Block | 0.4964687881 +/- 0.3194349461 | 0.4714604739 +/- 0.06137270985 | 0.2036732951 +/- 0.3323008594 |
| 0.10 | Prepeak | Remove feedback | 67.34418107 +/- 4.373164681 | 45.18461498 +/- 10.87638735 | -12.51037821 +/- 7.287431321 |
| 0.10 | Prepeak | Remove b | 74.15852861 +/- 3.610758806 | 20.69841797 +/- 4.770519037 | -50.3254767 +/- 3.732806052 |
| 0.10 | Prepeak | Block | 0.4663234202 +/- 1.116100842 | 1.368430935 +/- 0.1789552877 | 1.10323213 +/- 1.261072853 |
| 0.20 | Prep | Remove feedback | 44.04770972 +/- 7.112731456 | 50.09995631 +/- 6.403994945 | 6.443298553 +/- 2.092634684 |
| 0.20 | Prep | Remove b | 28.62606223 +/- 2.920878885 | 30.22665261 +/- 1.80486891 | 3.759279185 +/- 2.644538047 |
| 0.20 | Prep | Block | 6.462140511 +/- 2.616037077 | 5.906094892 +/- 1.837925361 | 0.4387935971 +/- 1.612393516 |
| 0.20 | Prepeak | Remove feedback | 46.19408493 +/- 8.521196303 | 34.46378246 +/- 3.296465396 | -13.08568637 +/- 5.8100987 |
| 0.20 | Prepeak | Remove b | 81.1914634 +/- 2.370948913 | 70.32095438 +/- 1.429838352 | -10.11127426 +/- 2.746930286 |
| 0.20 | Prepeak | Block | 11.08214341 +/- 7.447166952 | 4.401353899 +/- 0.9180026665 | -6.806534454 +/- 6.438044956 |

## Validation evidence

Independent saved-output audit PASS: 120 cases, 5820 counted regression/case checks plus all trial events, preprocessing and state/arm spot checks.

- maxIncrementError: 2.22044604925e-16
- maxArmError: 2.22044604925e-16
- maxFeatureError: 2.6645352591e-14
- maxRidgeResidual: 9.88344057297e-15
- maxR2Error: 1.79412040779e-13
- maxBootstrapError: 2.08166817117e-16
- maxInnerLossRelativeError: 5.67694701226e-08

Reopened FIG/errorbar audit: 3 figures, 60 errorbar series, maximum discrepancy 0. Visual PNG review and final preservation/Git receipts are recorded in the completion section after they occur.

## Figure paths

- plots/stage_3/fig/result_3_prediction_validation.fig and plots/stage_3/png/result_3_prediction_validation.png
- plots/stage_3/fig/diagnostic_3_prediction_noise.fig and plots/stage_3/png/diagnostic_3_prediction_noise.png
- plots/stage_3/fig/diagnostic_4_prediction_specificity.fig and plots/stage_3/png/diagnostic_4_prediction_specificity.png

The four pre-existing Stage3 figure pairs are preserved unchanged.

## Data and reproduction

Compact summary/CSV/audits: results/stage_3/current/prediction_validation/. Full trial states/arm trajectories, feature arrays, PCA bases, folds, inner losses, coefficients, actual/held-out predictions and permutations: results/stage_3/current/cache/prediction_validation/ (ignored). The old preflight and its raw evidence are preserved.

Entry points in analysis/stage_3: stage3_prediction_preflight_repair, stage3_prediction_production, stage3_prediction_analysis_test, stage3_prediction_pipeline_test, stage3_prediction_analyze, stage3_prediction_audit, stage3_prediction_figure_audit, stage3_prediction_report. Renderer: figures/stage_3/stage3_prediction_figures. Production and canonical result writers refuse overwriting existing evidence.

## Interpretation and checkpoint

### Scientific interpretation: mixed support, no tuning

At primary s=.10, full Block substantially reduces neural and hand-position
prediction: neural R2 .5085025356 versus .9727720452 Intact, and hand R2
.0722281761 versus .9512887570. Both Block contrasts have BH q=.005859375.
Removing feedback has smaller neural/hand deficits (q=.028125/.029296875).
Removing b has no neural deficit (q=.876953125) and only a small hand deficit
(q=.028125). The matched-PC control retains the large Block neural deficit.

The peak-speed hypothesis is not supported: primary Intact R2 is negative
(-.01754360872), while Block is higher (+.06698894779). Its positive paired
Block-minus-Intact contrast has q=.005859375, opposite the predicted deficit
ordering. The other primary speed contrasts do not pass q<.05. Low/high noise
sensitivities remain non-selected, and all negative R2 values are retained.

General preparation-specific behavioral preservation is also not established.
Pre-peak hand prediction remains low under Block (.06350674781) versus Intact
(.9441789198). Within-target preparatory hand R2 has a negative network median
under every policy. Therefore high pooled-target hand prediction must not be
presented as successful within-target trial-precision prediction. No supporting
analysis rescues an unsupported primary claim. Full-ensemble feature learning
follows the binding manuscript scope, not a strictly inductive prediction
pipeline. These results do not establish anatomical localization or authorize
another model, learning/adaptation, RRR or target-jump analysis.

### Completed validation and publication

The numerical repair passed without changing scientific/analysis settings:
supplied dt=.0001 s is retained; omitted dt=.0002 s is preserved. All12
policy/noise combinations on the two predeclared targets passed the coupled
step check: maximum relative state RMS .0005407057162 (limit .01), maximum
hand RMS .05448927181 mm (limit1 mm). Passed isolated-leak/CRN/s=0 evidence
was reused rather than rerun. All120 production sets/28,800 trials passed
the unchanged native state/rate bounds and required-window checks.

The independent numerical and figure audits above passed. All three new PNGs
were visually inspected and the three corresponding FIGs reopened. Fonts,
condition labels/colors, negative values and fixed-noise spacing were checked;
no accepted figure or numerical result was replaced. All18 prediction MATLAB
files have no Code Analyzer messages in code_analyzer_final.json.

The preservation receipt verifies all866 protected pre-existing assets and
11 prior prediction-evidence files unchanged, and confirms that reversing the
single authorized guard edit reproduces the original wrapper hash. The old
preflight.json/mat and raw evidence remain dependencies of the passed repair;
resolved stop reports and intermediate static receipts were subsequently
retired under the causal diagnostic, with their substance consolidated.
Current success is recorded in preflight_repair.json, production_complete.json,
independent_audit.json and figure_audit.json. The original prediction task
deleted no evidence; the later cleanup is documented separately.

The existing Stage3 Results and Diagnostics pages now contain the three new
native PNGs, captions and full primary/sensitivity/control tables. Readback
confirmed three Results images, four Diagnostics images, no unknown/truncated
blocks, and all four native child pages retained. Technical Specification,
Presentation-ready Summary and the Stage3 parent were updated in place, with
the mixed/negative interpretation explicit. Existing biological-controller
science remains unchanged. Notion URLs:

- Results: https://www.notion.so/3d426c94be30817eab3ffe5f952f1f5c
- Diagnostics: https://www.notion.so/3d426c94be30818988a2f9a409023f0b
- Technical Specification: https://www.notion.so/3d426c94be30813b81b9c6e55861a5b4
- Presentation-ready Summary: https://www.notion.so/3d426c94be308104862cce331a0661e2
- Stage3 parent: https://www.notion.so/3d426c94be3081e4b13bdf8a91d0baf6

### Checkpoint receipt and stop boundary

This report is finalized before its containing commit. The actual normal
commit/push and safe-main-fast-forward receipt, final SHA equality and clean
worktree/index outcome are recorded after verification in Agent Log, Agent
Handoff and START HERE; no self-referential commit SHA is asserted here.
The original checkpoint remains c40e0eb74679a0122cb1e54c784c2e56946a5e14.
Only the intended prediction implementation, preserved preflight provenance,
compact results, new figures and root documentation belong in this checkpoint;
large trial/regression caches and execution logs remain local/ignored.
Scientific review is required; computational validation is not scientific
acceptance of all prediction hypotheses. No additional model is started.
