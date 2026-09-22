# Validated primary panel-e results

PAPER-MODELLING-PANEL-E-PREDICTION-01. Primary analysis and controls are numerically validated; the full-space RRR stage and overall task completion are recorded separately. No scientific acceptance is implied.

Frozen checkpoint: 70fff703f8fd3074bef62ca9954a03bef50e4d99. Lambda10, alpha.5, beta_norm1, V1, original kappa0 and noise streams unchanged. Thirty trials/target, eight targets, ten networks. No trial exclusions or additional balancing resamples.

## Main result

| Policy | Median R2 | Bootstrap SE | Median shuffle floor | Floor SE |
|---|---:|---:|---:|---:|
| Intact | 0.9946804069 | 0.0006283056817 | -0.01157413292 | 0.0006900465854 |
| Remove feedback | 0.9932256690 | 0.001231803109 | -0.01185899182 | 0.0007847704397 |
| Remove b | 0.9632760369 | 0.01154552091 | -0.01059059585 | 0.0004340715806 |
| Block | 0.9655442804 | 0.01158292455 | -0.01024682164 | 0.0004158849120 |

Paired relative Block-minus-Intact R2 change: -2.951654939% +/- 1.172088137% SE. Thus the reduction is only2.95%, versus empirical43.6% N and29.6% T. Directional agreement does not constitute quantitative reproduction. All policies remain highly predictable; full Block is not uniformly the least-predictable removal condition. These outcomes do not change any model or pending RRR setting.

## Three prespecified paired contrasts

| Comparator minus Intact | Mean difference | Median difference | Median-difference SE | Exact p | BH q |
|---|---:|---:|---:|---:|---:|
| Remove feedback | -0.002414916625 | -0.001249581276 | 0.0006711553788 | 0.001953125000 | 0.001953125000 |
| Remove b | -0.03804974399 | -0.03183092458 | 0.01134168083 | 0.001953125000 | 0.001953125000 |
| Block | -0.04510228081 | -0.02936569282 | 0.01165859695 | 0.001953125000 | 0.001953125000 |

Two-sided exact1024 sign flips of the mean paired difference, BH across these three contrasts only. All SEs use the frozen10000 whole-network bootstrap rows. No trial-level inference.

## Every network and policy

| Network | Policy | R2 | Prep K | Prep captured fraction | Move K | Move captured fraction | Shuffle floor |
|---|---|---:|---:|---:|---:|---:|---:|
| 1 | Intact | 0.9959566578 | 5 | 0.7777988027 | 2 | 0.7609147507 | -0.01361447008 |
| 1 | Remove feedback | 0.9876176486 | 5 | 0.7636843144 | 3 | 0.8130186426 | -0.01336248675 |
| 1 | Remove b | 0.9632280482 | 6 | 0.7849194283 | 5 | 0.7852497838 | -0.01168776093 |
| 1 | Block | 0.9671461212 | 7 | 0.8488447868 | 6 | 0.7819082019 | -0.01149995730 |
| 2 | Intact | 0.9939838339 | 5 | 0.7921975467 | 2 | 0.7582734554 | -0.008840416357 |
| 2 | Remove feedback | 0.9873212889 | 5 | 0.7804457456 | 3 | 0.8165785061 | -0.008994139970 |
| 2 | Remove b | 0.9388288080 | 6 | 0.7941373262 | 5 | 0.7860552726 | -0.009687100097 |
| 2 | Block | 0.8893828022 | 6 | 0.7544937462 | 6 | 0.7655071064 | -0.01001948785 |
| 3 | Intact | 0.9964947857 | 4 | 0.7633265145 | 2 | 0.7845781096 | -0.01167831612 |
| 3 | Remove feedback | 0.9951738662 | 4 | 0.7514471737 | 2 | 0.7744789968 | -0.01179649755 |
| 3 | Remove b | 0.9859907828 | 6 | 0.8005199663 | 5 | 0.8006991050 | -0.01099247952 |
| 3 | Block | 0.8770300192 | 6 | 0.7553304357 | 6 | 0.7737559015 | -0.01107367142 |
| 4 | Intact | 0.9951035487 | 5 | 0.7848113966 | 2 | 0.7949644184 | -0.01308807609 |
| 4 | Remove feedback | 0.9945250798 | 5 | 0.7714190638 | 2 | 0.7815735716 | -0.01347880639 |
| 4 | Remove b | 0.9235540081 | 6 | 0.7799395239 | 5 | 0.7596388865 | -0.01095890256 |
| 4 | Block | 0.9608210112 | 7 | 0.8385494672 | 7 | 0.8034516423 | -0.01165328404 |
| 5 | Intact | 0.9918854240 | 5 | 0.7821092168 | 3 | 0.8161659257 | -0.01026389557 |
| 5 | Remove feedback | 0.9902879058 | 5 | 0.7668475238 | 3 | 0.8062126590 | -0.01002068014 |
| 5 | Remove b | 0.9750711981 | 6 | 0.7812241736 | 5 | 0.7840584927 | -0.01004832241 |
| 5 | Block | 0.9749827298 | 7 | 0.8387303883 | 6 | 0.7758283789 | -0.009709854379 |
| 6 | Intact | 0.9954993682 | 5 | 0.7862830358 | 2 | 0.7598004529 | -0.009590816984 |
| 6 | Remove feedback | 0.9943592806 | 5 | 0.7773000672 | 2 | 0.7509303934 | -0.009842160467 |
| 6 | Remove b | 0.9712431382 | 6 | 0.7964802646 | 5 | 0.7945261593 | -0.01022228913 |
| 6 | Block | 0.9421841458 | 6 | 0.7622955480 | 6 | 0.7830556571 | -0.01031877928 |
| 7 | Intact | 0.9942572651 | 5 | 0.7813268789 | 2 | 0.7620860000 | -0.01196616732 |
| 7 | Remove feedback | 0.9932817950 | 5 | 0.7671953225 | 2 | 0.7525218332 | -0.01192148610 |
| 7 | Remove b | 0.9633240255 | 6 | 0.7806748569 | 5 | 0.7795273719 | -0.01000565979 |
| 7 | Block | 0.9737719121 | 7 | 0.8389290423 | 6 | 0.7626641970 | -0.01017486399 |
| 8 | Intact | 0.9958552583 | 5 | 0.7763829169 | 2 | 0.7916165687 | -0.01079553398 |
| 8 | Remove feedback | 0.9946770152 | 5 | 0.7625107490 | 2 | 0.7804934180 | -0.01066161369 |
| 8 | Remove b | 0.9352763189 | 6 | 0.7846083368 | 5 | 0.7875810285 | -0.01009255568 |
| 8 | Block | 0.9746907124 | 7 | 0.8419561175 | 6 | 0.7795757899 | -0.01015785970 |
| 9 | Intact | 0.9937070564 | 5 | 0.7715023457 | 2 | 0.7976109143 | -0.01383684420 |
| 9 | Remove feedback | 0.9920438974 | 5 | 0.7575168963 | 2 | 0.7882009863 | -0.01441169807 |
| 9 | Remove b | 0.9367219602 | 6 | 0.7894671118 | 5 | 0.8007179526 | -0.01167442936 |
| 9 | Block | 0.9716317851 | 7 | 0.8408809379 | 6 | 0.7757022453 | -0.01153065187 |
| 10 | Intact | 0.9938632887 | 4 | 0.7611229608 | 2 | 0.7652638287 | -0.01146994972 |
| 10 | Remove feedback | 0.9931695431 | 5 | 0.7790137404 | 2 | 0.7536595267 | -0.01209291837 |
| 10 | Remove b | 0.9728707590 | 6 | 0.7803923831 | 5 | 0.7604309189 | -0.01141720149 |
| 10 | Block | 0.9639424396 | 7 | 0.8427961751 | 6 | 0.7612392019 | -0.01013041287 |

## Matched-PC fits

| Network | Comparator | Matched Prep K | Matched Move K | Intact R2 | Comparator R2 |
|---|---|---:|---:|---:|---:|
| 1 | Remove feedback | 5 | 2 | 0.9959566578 | 0.9947054485 |
| 1 | Remove b | 5 | 2 | 0.9959566578 | 0.9852185310 |
| 1 | Block | 5 | 2 | 0.9959566578 | 0.9566014166 |
| 2 | Remove feedback | 5 | 2 | 0.9939838339 | 0.9927839317 |
| 2 | Remove b | 5 | 2 | 0.9939838339 | 0.9842860100 |
| 2 | Block | 5 | 2 | 0.9939838339 | 0.9653398751 |
| 3 | Remove feedback | 4 | 2 | 0.9964947857 | 0.9951738662 |
| 3 | Remove b | 4 | 2 | 0.9964947857 | 0.9872020184 |
| 3 | Block | 4 | 2 | 0.9964947857 | 0.9622946804 |
| 4 | Remove feedback | 5 | 2 | 0.9951035487 | 0.9945250798 |
| 4 | Remove b | 5 | 2 | 0.9951035487 | 0.9790751213 |
| 4 | Block | 5 | 2 | 0.9951035487 | 0.9353205187 |
| 5 | Remove feedback | 5 | 3 | 0.9918854240 | 0.9902879058 |
| 5 | Remove b | 5 | 3 | 0.9918854240 | 0.9775462696 |
| 5 | Block | 5 | 3 | 0.9918854240 | 0.9466098489 |
| 6 | Remove feedback | 5 | 2 | 0.9954993682 | 0.9943592806 |
| 6 | Remove b | 5 | 2 | 0.9954993682 | 0.9800833454 |
| 6 | Block | 5 | 2 | 0.9954993682 | 0.9620874705 |
| 7 | Remove feedback | 5 | 2 | 0.9942572651 | 0.9932817950 |
| 7 | Remove b | 5 | 2 | 0.9942572651 | 0.9880396332 |
| 7 | Block | 5 | 2 | 0.9942572651 | 0.9775890767 |
| 8 | Remove feedback | 5 | 2 | 0.9958552583 | 0.9946770152 |
| 8 | Remove b | 5 | 2 | 0.9958552583 | 0.9844051639 |
| 8 | Block | 5 | 2 | 0.9958552583 | 0.9597093481 |
| 9 | Remove feedback | 5 | 2 | 0.9937070564 | 0.9920438974 |
| 9 | Remove b | 5 | 2 | 0.9937070564 | 0.9904145289 |
| 9 | Block | 5 | 2 | 0.9937070564 | 0.9206086405 |
| 10 | Remove feedback | 4 | 2 | 0.9938632887 | 0.9920065453 |
| 10 | Remove b | 4 | 2 | 0.9938632887 | 0.9883469805 |
| 10 | Block | 4 | 2 | 0.9938632887 | 0.9249846474 |

Matched comparator medians: .9938205378 (remove-feedback), .9848118475 (remove-b), .9581553824 (Block); matched Intact median.9946804069. Controls remain near ceiling. All100 fixed shuffle fits are retained in the raw fitting evidence and primary.json, not replaced by their displayed medians.

## Validation and figure publication

- Ten Intact preparations reused,30 missing selected-geometry preparation series recovered,40 missing movement-neural series recovered. No arm/event rerun. Maximum absolute discrepancy against every checked saved quantity is exactly0 across all40 cases.
- All40 Prep-GO/movement-start joins, frozen scales, seeds, flags, geometry constants and onset-window identities independently pass.
- Direct covariance/eigen PCA threshold audit: maximum spectral error1.98952e-13. All minimum75%-variance counts agree.
- All observed,4000 shuffled and60 matched fits independently checked by direct normal equations, including every selected penalty and pooled held-out prediction. Maximum prediction error1.21236e-13, loss error1.45519e-11, R2 error1.77636e-15.
- Neuron-wise smoothing/indexing spot-check discrepancy2.30926e-14. Separate synthetic boundary and full-dimensional RRR solver tests passed before outcomes.
- Independent primary medians, all displayed bootstrap SEs, paired summaries and exact p/BH q have zero discrepancy.
- Both FIGs reopened:5 and24 tagged numeric-source checks. Both PNGs visually inspected. Native Notion PNG bytes match local masters by SHA256; prior eight native images preserved.

Main and controls are plots/paper_ready/prediction/{fig,png}/panel_e_pca_ridge and panel_e_controls. Full methods and sources: PLAN.md, FIGURE_LEGENDS.md and PANEL_SOURCES.md in this folder. Native figures are on the existing Paper-ready Modelling figure page. Overall completion and RRR conclusions await the separate final report. No staging, commit, push or further model/behavior/prediction family.
