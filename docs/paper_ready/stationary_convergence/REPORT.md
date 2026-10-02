# Stationary spontaneous-baseline convergence — scientific review pending

Review only. Release aa63c7914fadf6f7c96c634617e797eac3772246 and all TASK-01 outputs remain unchanged.

## Exact protocol

Contiguous GO-6000:-1000 burn-in, GO-1000:-500 analyzed intrinsic spontaneous activity, then GO-500:0 preparation. No target/base/b/L before cue; no gap, reset or second kick. Initial scale .10 once. Temporal .05/.10/.20, constant throughout. New pre-cue mt19937ar seeds510000000+10000*network+slot; released initial/cue-GO draws retained.

Reference-only PCA95 and fixed same-target20/10 folds, GO-600:10:0 PCA; window means GO-600:10:-500 and GO-100:10:0. C=1-d_prego/d_precue; unchanged guards/aggregation. Network n=10, median +/- bootstrap SE from released10000 whole-network resamples. No new inferential tests.

## Convergence versus temporal noise

| Temporal | Intact C | Block C | Paired Block-Intact C |
|---:|---:|---:|---:|
| 0.05 | 0.0708798447693 +/- 0.00365369504813 | -0.0191645122845 +/- 0.00455377728942 | -0.0856470067039 +/- 0.00553331148787 |
| 0.10 | 0.0817897106411 +/- 0.00245929022824 | 0.00081875172624 +/- 0.00293066412993 | -0.0763023680786 +/- 0.00475402497044 |
| 0.20 | 0.0817766176623 +/- 0.00246102869255 | 0.015697339338 +/- 0.00427897811837 | -0.0620887629386 +/- 0.0043967867312 |

## Primary component comparison

| Policy | Median C | Bootstrap SE |
|---|---:|---:|
| Intact (b+L) | 0.0817897106411 | 0.00245929022824 |
| -L (b only) | -0.0122902731076 | 0.00395310809106 |
| -b (L only) | 0.0920296750276 | 0.00231259388103 |
| Block (-b,-L) | 0.00081875172624 | 0.00293066412993 |

Qualitative median checks only (1=true,0=false): C_Intact>0: 1; C_Block>0: 1; C_Intact>C_Block: 1.
Network-level counts out of10, same order: 10 / 6 / 10. No parameter or duration selected from these booleans.

## Five-window stationarity QC

Nonoverlapping analyzed-spontaneous samples0..99,100..199,200..299,300..399,400..499ms. Dispersion is pooled-trial RMS per neuron, averaged within window. Means below are network medians of the named QC values; full30-row table retained. No outcome-based threshold.

| Temporal | D1 | D2 | D3 | D4 | D5 | Normalized slope (1/s) | Last/preceding | Mean drift RMS |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0.05 | 0.138455023176 | 0.138491279526 | 0.138029328486 | 0.137953800203 | 0.138062626149 | -0.0107224637528 | 1.00010701012 | 0.0118590991393 |
| 0.10 | 0.276541600707 | 0.276602014659 | 0.27565485218 | 0.275463758094 | 0.275675833111 | -0.0116833835279 | 1.00000657681 | 0.0235361535252 |
| 0.20 | 0.521056272147 | 0.522312110838 | 0.521262047002 | 0.521562066415 | 0.521211070783 | -0.0144707411988 | 0.999832199518 | 0.0439713983959 |

| Temporal | Shift1-2 | Shift2-3 | Shift3-4 | Shift4-5 | NormShift1-2 | NormShift2-3 | NormShift3-4 | NormShift4-5 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0.05 | 0.00623415001401 | 0.00635227054457 | 0.00648277840263 | 0.00694181322774 | 0.0447600164844 | 0.0448666078135 | 0.0475494222455 | 0.0512921233589 |
| 0.10 | 0.0124604793248 | 0.0126388680213 | 0.013034532471 | 0.0138385707279 | 0.0447519587283 | 0.0451055764265 | 0.0476407634361 | 0.051267360689 |
| 0.20 | 0.0236836168902 | 0.0246642875755 | 0.0253199898536 | 0.0259945842773 | 0.0450761185974 | 0.045979839912 | 0.0485231609091 | 0.0508019273004 |

## Initialization dependence

Trial-centered Pearson correlations with original z_init, not extra counterfactual simulations; correlation does not establish causal independence. Absolute per-neuron correlations include finite-sample variation. Residual from xsp is descriptive drift, not an initialization-only causal effect.

| Temporal | Pooled corr at burn-in end | Pooled corr at cue | Median abs neuron corr | Mean residual norm at cue | Mean residual RMS at cue |
|---:|---:|---:|---:|---:|---:|
| 0.05 | 0.000713732010864 | -0.000792345866387 | 0.045032938688 | 0.125718957503 | 0.00888967273739 |
| 0.10 | 0.000790968507294 | -0.000635379952695 | 0.0450670791712 | 0.251823391851 | 0.0178066028039 |
| 0.20 | 0.000458265529108 | -0.000880499780008 | 0.0444336879031 | 0.554556957318 | 0.0392130985074 |

Finite analyzed spontaneous/preparation: 30/30 and 120/120; bounded burn-in/analyzed spontaneous/preparation: 30/30, 30/30, 120/120. Undefined C: 0/28800. No trial/network exclusion.

## Independent audit

All330 intrinsic chunks and120 preparations checked with three native transition probes each; not a second full replay. Every C case independently recomputed via covariance/eigen instead of production SVD; all stationarity/correlation calculations independently checked.

- drawError: 0
- transitionError: 0
- continuityError: 0
- convergenceError: 6.4304117586289067e-13
- qcError: 1.9651706477386011e-15

Stationarity is not established merely by a5-s duration or boundedness. Inspect drift before biological interpretation; if clear drift persists, stop interpretation. If convincingly settled but Intact C remains negative, convergence is not supported for paper-facing use and omission is recommended. Review-only arithmetic and all negatives remain unchanged. No fits, movement, prediction or RRR were run.
