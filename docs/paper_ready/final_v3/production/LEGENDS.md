# Final manuscript panel definitions and statistics

All panels use the final Fig6a–h / ED7a–c numbering. Numerical values below are copied from the frozen source records, not recomputed inference. Native FIG/PNG masters: `plots/paper_ready/final_v3/production/{fig,png}/`. Statistical full precision: `data/paper_ready/final_v3/tables/statistics.json`.

## Fig6a — Weakening anticipatory control: PR

Preparatory PR change relative to lambda=0.1 across the fixed anticipatory-control sweep. Feedback alone does not reproduce the calibrated PR effect. The exact feedforward-only categorical endpoint has K=0 and feedback effort exactly0; tonic input remains. No very-large finite-lambda approximation.

Ten matched networks; medians±whole-network-bootstrap SE. AD tests paired differences at alpha=.05; t-test if normality not rejected, otherwise Wilcoxon. BH separately across eight comparisons for each panel.

| lambda | Median | Bootstrap SE |
| --- | --- | --- |
| 0.1 | 0 | 0 |
| 0.2 | -0.0007593979270998918 | 0.0030970936136074 |
| 0.5 | -0.0030652578644057016 | 0.008096856629246765 |
| 1 | -0.021262669436801884 | 0.017396148862563257 |
| 2 | -0.0487964349723542 | 0.02733071625035311 |
| 5 | -0.07209967385963623 | 0.04564801503788679 |
| 10 | -0.08405623385515892 | 0.0566728477387926 |
| 100 | -0.16139544139065132 | 0.030395655429300547 |
| Feedforward only (exact K=0) | -0.2101235830976187 | 0.0824815030942386 |

| Panel / contrast | AD reject; p; A² | Selected two-sided test | Statistic; df | Raw p | BH q | n |
| --- | --- | --- | --- | --- | --- | --- |
| Fig6a | false; 0.1331558087717867; 0.533858185230903 | two-sided paired t-test | -0.8031576239345993; 9 | 0.44257712111518177 | 0.44257712111518177 | 10 |
| Fig6a | true; 0.01008909710245299; 0.9325464392280676 | two-sided Wilcoxon signed-rank | 18; — | 0.375 | 0.42857142857142855 | 10 |
| Fig6a | false; 0.06497938423333527; 0.6451875962134164 | two-sided paired t-test | -1.5978242593584393; 9 | 0.1445465090039997 | 0.1927286786719996 | 10 |
| Fig6a | false; 0.3505555480710709; 0.3782148684119431 | two-sided paired t-test | -1.9903716856698697; 9 | 0.0777500200737472 | 0.12440003211799552 | 10 |
| Fig6a | false; 0.5524987536639273; 0.29868803986800785 | two-sided paired t-test | -2.6535995992100476; 9 | 0.026320449844953422 | 0.052640899689906845 | 10 |
| Fig6a | false; 0.31607457668744887; 0.39553119853451335 | two-sided paired t-test | -3.199924778245049; 9 | 0.010832610140882866 | 0.02888696037568764 | 10 |
| Fig6a | false; 0.30756050194493256; 0.4000607506133331 | two-sided paired t-test | -3.6319151662841547; 9 | 0.005469285968233849 | 0.021877143872935396 | 10 |
| Fig6a | false; 0.08818838760829847; 0.5979320810661619 | two-sided paired t-test | -4.825702130060361; 9 | 0.0009394990353620982 | 0.007515992282896786 | 10 |

Sources: [Fig6ab_network_values.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6ab_network_values.csv); [Fig6ab_tests.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6ab_tests.csv).


Canonical files: `Fig6a.fig`, `Fig6a.png`.

## Fig6b — Weakening anticipatory control: alignment

Expected−observed preparatory alignment deficit across the same sweep. Source-faithful common strictly>95%-variance PC count and fixed covariance-shaped null. Values are percentage points. Inferential comparisons test within-network changes from lambda=0.1, not deficit versus zero. The manuscript shorthand “No input” means no feedback, with tonic retained.

Ten matched networks; medians±whole-network-bootstrap SE. AD tests paired differences at alpha=.05; t-test if normality not rejected, otherwise Wilcoxon. BH separately across eight comparisons for each panel.

| lambda | Median | Bootstrap SE |
| --- | --- | --- |
| 0.1 | -52.64591158729917 | 0.95574600201741 |
| 0.2 | -52.44516943995724 | 0.9600328704639765 |
| 0.5 | -51.394481441572594 | 0.9188157602566148 |
| 1 | -49.19502914013531 | 0.745811103674684 |
| 2 | -46.56884875007516 | 0.5222654129020824 |
| 5 | -41.70733613162129 | 1.2886707296916253 |
| 10 | -37.180096699794134 | 1.3712705935980203 |
| 100 | -23.24696257787359 | 2.1001428119971486 |
| Feedforward only (exact K=0) | -14.072180833928755 | 1.744305908806492 |

| Panel / contrast | AD reject; p; A² | Selected two-sided test | Statistic; df | Raw p | BH q | n |
| --- | --- | --- | --- | --- | --- | --- |
| Fig6b | false; 0.0646885788455859; 0.645881123951952 | two-sided paired t-test | 7.435409306788318; 9 | 0.00003952539464750914 | 0.00005615727765328647 | 10 |
| Fig6b | false; 0.050486586077910935; 0.6842454511049887 | two-sided paired t-test | 6.494987651145927; 9 | 0.00011210251581308729 | 0.0001281171609292426 | 10 |
| Fig6b | false; 0.06055107746592162; 0.6561024025270505 | two-sided paired t-test | 5.949900631442935; 9 | 0.00021536680721101313 | 0.00021536680721101313 | 10 |
| Fig6b | false; 0.13721966167562666; 0.5291577639019973 | two-sided paired t-test | 7.375431029623635; 9 | 0.00004211795823996485 | 0.00005615727765328647 | 10 |
| Fig6b | false; 0.721856672141953; 0.24506753225150746 | two-sided paired t-test | 9.114413145736625; 9 | 0.000007698880051589245 | 0.00001539776010317849 | 10 |
| Fig6b | false; 0.6636712017697006; 0.2629019803955419 | two-sided paired t-test | 10.804105224530877; 9 | 0.0000018730218725016996 | 0.0000049947249933378655 | 10 |
| Fig6b | false; 0.7874056641453439; 0.22478123973568565 | two-sided paired t-test | 18.983687626592275; 9 | 1.43751842176639e-8 | 5.75007368706556e-8 | 10 |
| Fig6b | false; 0.5739964168354947; 0.2915317177144061 | two-sided paired t-test | 27.168801444877825; 9 | 6.007632067661032e-10 | 4.806105654128826e-9 | 10 |

Sources: [Fig6ab_network_values.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6ab_network_values.csv); [Fig6ab_tests.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6ab_tests.csv).


Canonical files: `Fig6b.fig`, `Fig6b.png`.

## Fig6c — Final functional-model schematic

Hand-drawn functional-model schematic (static asset originally extracted from Main_text_v10), preserved as a static version-controlled asset. No editable source was available. Ten200-unit networks; eta0, lambda10, V1, global alpha.5/beta_norm1.25. Base preparation + target-dependent state setting b + anticipatory feedback L; full Block removes b and L. No generic residual kappa feedback. Effective decomposition only, not anatomically separate pathways.

Static asset: `data/paper_ready/final_v3/Fig6c_schematic.png`; provenance: live manuscript image kix.4bx8biipim5o, exact pixels rows1:1000/columns1110:2048 of the captured2048×1567 image.

Canonical files: `Fig6c.fig`, `Fig6c.png`.

## Fig6d — Frozen all-target random-success illustration

**Frozen Option3 / seed18003, network8.** The user selected this option from five previously generated fixed-seed random candidates. Four successful saved trials were sampled uniformly without replacement per target×condition. No reroll, ranking or substitution in production. Control pools have30 successes per target; Block pools have30,30,30,4,29,30,30,30. Thin paths stop at first entry into a1.5-cm target zone; the thick trajectory is the arithmetic mean of those exact same four paths after MO→entry interpolation to101 movement-phase points. Target colormap and common spatial limits retained. This is a success-conditioned illustration, not the all-trial behavioral assay.

| Target | Control IDs | Block IDs |
| --- | --- | --- |
| 1 | 20,7,28,32 | 55,185,94,49 |
| 2 | 27,4,41,32 | 187,56,136,178 |
| 3 | 38,8,17,16 | 388,110,342,379 |
| 4 | 15,14,7,3 | 2867,518,4931,1860 |
| 5 | 6,30,29,23 | 2361,2002,681,2360 |
| 6 | 41,10,23,31 | 26,67,61,8 |
| 7 | 39,20,13,8 | 2237,1043,2136,2765 |
| 8 | 8,38,25,28 | 95,129,272,39 |

Historical source identity only: `fig6f_random5_18/fig/Fig6f_option3_seed18003.fig`, pre-production checkpoint16aed212496647858770733919fb34c628dac85f. The historical name is not an active dependency.

Sources: [Fig6d_selected_trials.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6d_selected_trials.csv); [Fig6d_same_four_phase_means.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6d_same_four_phase_means.csv); [Fig6d_displayed_native_paths.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6d_displayed_native_paths.csv).


Canonical files: `Fig6d.fig`, `Fig6d.png`.

## Fig6e — Representative hand-speed profiles

Fifteen successful movement-onset-aligned speed traces per condition; all solid, Control sky blue and Block vermillion. Thin traces are unsmoothed and terminate at first target entry. Thick trace: raw active-trial median of exactly the displayed fifteen, post-entry NaNs, original50-ms Gaussian over complete temporal support with truncated/renormalized true boundaries, then display cutoff at last nActive≥8. Cutoffs:270ms Control/321ms Block; full available support305/523ms.

Network8, target6. Control IDs: **10,3,41,33,38,20,7,15,19,9,31,42,14,28,29**. Block IDs: **67,102,28,78,22,88,96,49,9,29,2,56,47,58,61**. Fixed spatially stratified streams170801/170802; no reselection or speed/contrast screening. Illustrations only.

The following unchanged manuscript behavioral effect is the **all-trial ten-network** unsmoothed target-averaged peak-speed assay, not an inference from these fifteen examples.

| Value | Median | Bootstrap SE | n |
| --- | --- | --- | --- |
| Control peak m/s | 0.4202663389288777 | 0.0009573201601136899 | 10 |
| Block peak m/s | 0.2933463706641214 | 0.011120979564432407 | 10 |
| Within-network decrease % | 29.620738559012963 | 2.5030943906286582 | 10 |

| Panel / contrast | AD reject; p; A² | Selected two-sided test | Statistic; df | Raw p | n |
| --- | --- | --- | --- | --- | --- |
| Fig6e | false; 0.6326212569984557; 0.27261640032784484 | two-sided paired t-test | -18.9440704555882; 9 | 1.464190648721461e-8 | 10 |

Sources: [Fig6ef_selected_trials.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6ef_selected_trials.csv); [Fig6e_median_support.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6e_median_support.csv); [Fig6e_raw_thin_traces.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6e_raw_thin_traces.csv); [Fig6e_alltrial_peak_speed.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6e_alltrial_peak_speed.csv).


Canonical files: `Fig6e.fig`, `Fig6e.png`.

## Fig6f — Representative peak-position dispersion

Same fifteen successful trajectories as Fig6e. Solid condition paths; filled circles mark each trial’s own unsmoothed peak-speed position; black dashed center-to-center ideal path. Empirical-style overlay, scale bars and distribution inset. The inset uses **all30 successful trials per condition**, with distances from each condition-specific coordinate-wise median peak position.

Network8, target6. Control IDs: **10,3,41,33,38,20,7,15,19,9,31,42,14,28,29**. Block IDs: **67,102,28,78,22,88,96,49,9,29,2,56,47,58,61**. Fixed spatially stratified streams170801/170802; no reselection or speed/contrast screening. Illustrations only.

The following unchanged manuscript result is the **speed-matched all-trial assay; 6/10 networks met the prespecified criterion** (IDs1,2,3,6,7,10), not inference from this success pool. Within-target greedy abs(vControl−vBlock)/abs(vBlock)≤5%; at least five matched pairs/target, at least five eligible targets/network. The unmatched all-ten-network control is separately retained.

| Value | Median | Bootstrap SE | n |
| --- | --- | --- | --- |
| Control dispersion cm | 0.5526716063316227 | 0.0273189850320376 | 6 |
| Block dispersion cm | 2.6840010552961773 | 0.33160946624453685 | 6 |
| Within-network increase % | 395.3736459890068 | 63.03061502099788 | 6 |

| Panel / contrast | AD reject; p; A² | Selected two-sided test | Statistic; df | Raw p | n |
| --- | --- | --- | --- | --- | --- |
| Fig6f | true; 0.02178923256936372; 0.7442189850466194 | two-sided Wilcoxon signed-rank | 21; — | 0.03125 | 6 |

Sources: [Fig6f_display_paths.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6f_display_paths.csv); [Fig6f_all30_inset.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6f_all30_inset.csv); [Fig6f_histogram_counts.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6f_histogram_counts.csv); [Fig6f_alltrial_matched_dispersion.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6f_alltrial_matched_dispersion.csv); [Fig6f_alltrial_unmatched_control.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6f_alltrial_unmatched_control.csv).


Canonical files: `Fig6f.fig`, `Fig6f.png`.

## Fig6g — Absolute Control prediction versus noise

Absolute Control preparatory-to-early-movement cross-validated R², computed as 1−SSE/SST. Initial-state noise is dashed; temporal noise is solid; original colors and error-bar styling are retained.

Eight predeclared amplitudes 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35 and 0.40; the other noise source is fixed at 0.05. The shared 0.05/0.05 Control and Block cases are computed once per network and reused exactly, including the bootstrap stream. Fifteen unique pairs, ten frozen networks, two policies, eight targets × 30 trials: 300 cases / 72,000 canonical trials. Primary simulations and illustrations remain at 0.10/0.10. The original neural preprocessing, condition/epoch PCA75, movement-onset alignment and 3×3 nested ridge remain unchanged. No post-GO or observation noise. Statistical unit is the network (n=10); uncertainty is the sample SD of 10,000 whole-network bootstrap medians using the original saved draws.

| Sweep | Noise | Control R² median ± SE | Block R² median ± SE | Relative Block loss (%) median ± SE | n |
|---|---:|---:|---:|---:|---:|
| Initial-state | 0.05 | 0.9918963588 ± 0.001254361609 | 0.9247129848 ± 0.02558105989 | 6.320889519 ± 2.666333263 | 10 |
| Initial-state | 0.10 | 0.9893550657 ± 0.002002988802 | 0.9257463823 ± 0.02163971494 | 6.461656633 ± 2.180515888 | 10 |
| Initial-state | 0.15 | 0.9852250373 ± 0.001439270407 | 0.9691477556 ± 0.01245573844 | 1.696929915 ± 1.328555151 | 10 |
| Initial-state | 0.20 | 0.9800618691 ± 0.001721640993 | 0.960006298 ± 0.01013477488 | 2.050616217 ± 0.9589746161 | 10 |
| Initial-state | 0.25 | 0.9691465933 ± 0.003228984939 | 0.9362583977 ± 0.01453459617 | 3.776466366 ± 1.48199302 | 10 |
| Initial-state | 0.30 | 0.9524291261 ± 0.004923068761 | 0.9044934049 ± 0.01548107311 | 4.849887051 ± 1.570354685 | 10 |
| Initial-state | 0.35 | 0.9406930023 ± 0.003599681189 | 0.8809739477 ± 0.01251339454 | 6.68675272 ± 1.388503891 | 10 |
| Initial-state | 0.40 | 0.926746421 ± 0.005956182271 | 0.8574308939 ± 0.009876148734 | 7.000875652 ± 1.226355037 | 10 |
| Temporal | 0.05 | 0.9918963588 ± 0.001254361609 | 0.9247129848 ± 0.02558105989 | 6.320889519 ± 2.666333263 | 10 |
| Temporal | 0.10 | 0.9315906873 ± 0.00459871247 | 0.8434960856 ± 0.01164738656 | 9.917276909 ± 1.519439454 | 10 |
| Temporal | 0.15 | 0.8152285757 ± 0.004451786223 | 0.7176454858 ± 0.01242573057 | 12.11028666 ± 1.481750303 | 10 |
| Temporal | 0.20 | 0.7371942188 ± 0.004891086644 | 0.6301206094 ± 0.01429838958 | 13.96952429 ± 1.230811105 | 10 |
| Temporal | 0.25 | 0.6703718666 ± 0.006606146026 | 0.5840813502 ± 0.009832280297 | 15.01622962 ± 2.245269443 | 10 |
| Temporal | 0.30 | 0.6335957588 ± 0.005238121399 | 0.5541455673 ± 0.006658778568 | 13.25825463 ± 1.489004123 | 10 |
| Temporal | 0.35 | 0.6035444622 ± 0.005273508786 | 0.530460751 ± 0.01027401057 | 13.13515751 ± 2.14862734 | 10 |
| Temporal | 0.40 | 0.5761916597 ± 0.003974048523 | 0.4971671016 ± 0.006515305617 | 13.65533174 ± 1.244165915 | 10 |

| Sweep | Friedman χ² | df | Full-precision p | n |
|---|---:|---:|---:|---:|
| Initial-state | 67.633333333333326 | 7 | 4.437900838963797e-12 | 10 |
| Temporal | 70 | 7 | 1.4774294932825119e-12 | 10 |

Four separate repeated-measures Friedman omnibus tests use all eight levels (df=7). P values use the original MATLAB chi-square approximation, reported at full precision; they are not exact randomization probabilities. No cross-test correction, post-hoc comparisons or directional trend tests were added.

All 300 cases retained all 240 required neural response windows, with finite states/features, valid folds and PCA ranks, positive SST and valid SSE. Minimum absolute Control denominator was 0.55178957543108276; the prespecified numerical guard is sqrt(machine epsilon). Negative Control R² cases: 0; negative Block R² cases: 0; negative relative-loss pairs: 0. No clipping, imputation, exclusion or retuning was used. Movement onset was checked only for the neural estimand; no new behavioral-performance analysis was performed.

Sources: [network values and SSE/SST](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_network_values.csv), [summaries](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_summaries.csv), [full-precision JSON](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_values.json), [four tests](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_tests.csv), [300-case QC](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_case_qc.csv).

Canonical files: `Fig6g.fig`, `Fig6g.png`.

## Fig6h — Absolute Control and Block prediction versus temporal noise

Control (blue) and full cerebellar Block (orange) cross-validated preparatory-to-early-movement R² versus the eight temporal-noise amplitudes, with initial-state noise fixed at 0.05. Each point is the original median across ten networks; error bars are the original SE from 10,000 whole-network bootstrap medians. The Control series and error bars are exactly the temporal-Control series in Fig6g. The table above retains every original Control/Block R² and SE, with full-precision values in the unchanged source CSV/JSON files. No simulation, prediction fit, bootstrap draw, numerical result or inferential test changed for this presentation revision.

At temporal noise 0.05, Control R² is 0.99189635882084692 ± 0.0012543616092981459 and Block R² is 0.92471298480604514 ± 0.025581059888178336. At 0.40, Control is 0.5761916597000617 ± 0.0039740485227988936 and Block is 0.49716710160111244 ± 0.0065153056165257765. Both condition medians decline across these displayed temporal levels. At matched temporal-noise levels, Block further reduces predictive R². This gap does not establish a progressively growing noise-specific interaction or a causal explanation of saturation. No new test of absolute Block R² is presented.

Manuscript-ready reporting: Initial-state noise caused only modest loss of intact predictability, whereas ongoing temporal noise caused a much larger decline. At matched temporal-noise levels, cerebellar Block further reduced predictive R². The network is the statistical unit (n=10); uncertainty is median ± network-bootstrap SE. The existing Control omnibus tests are reported above. These descriptive results do not establish monotonic noise-specific interaction or mediation by behavioral success.

Canonical files: `Fig6h.fig`, `Fig6h.png`. All original statistical tables are unchanged.

### Historical percentage-deficit presentation (release 6391528; not the current panel)

Relative Block deficit is 100×(R²Control−R²Block)/R²Control, computed within each network before the median and bootstrap SE. It is not the percentage difference between pooled medians. All sixteen rows, including Block absolute R², appear in the table above. The two sweeps use the same 0.05/0.05 baseline.

| Sweep | Friedman χ² | df | Full-precision p | n |
|---|---:|---:|---:|---:|
| Initial-state | 31.366666666666674 | 7 | 5.3200756808134443e-05 | 10 |
| Temporal | 28.100000000000023 | 7 | 0.00021090367511048577 | 10 |

Four separate repeated-measures Friedman omnibus tests use all eight levels (df=7). P values use the original MATLAB chi-square approximation, reported at full precision; they are not exact randomization probabilities. No cross-test correction, post-hoc comparisons or directional trend tests were added.

Sources: [network values and SSE/SST](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_network_values.csv), [summaries](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_summaries.csv), [full-precision JSON](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_values.json), [four tests](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_tests.csv), [300-case QC](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_case_qc.csv).

Prior four-level/seven-pair results and masters remain in `data/paper_ready/final_v3/noise_sensitivity_20261019/historical_480753/` and executable Git checkpoint `480753f3be0134a843ffbc350d6baa162a85aa7e`; they are historical provenance only.

Both Control median curves decrease across the eight displayed levels. Relative Block loss is nonmonotonic in each sweep: the initial-state curve has its lowest median at 0.15, and the temporal curve reaches its highest median at 0.25 before lower medians at later levels. These are descriptions of the complete displayed series, not post-hoc contrasts or directional trend tests.


## ED7a — Shared geometry-calibration map

Frozen shared-geometry loss over the existing6×6 alpha/beta grid across allten networks. Only empirical paired ΔPR and expected−observed alignment deficit enter loss; no movement, convergence, R², noise-sensitivity or QC selection. Selected index24: **global alpha=.5, beta_norm=1.25**, V1, eta0, lambda10. Empirical targets ΔPR2.6453333944 and deficit16.802184percentage points; selected loss0.050363119828606938. No per-network geometry fit; selection predates downstream outcomes.

Sources: [ED7a_calibration_grid.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/ED7a_calibration_grid.csv); [ED7a_network_grid.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/ED7a_network_grid.csv); [geometry_selection.json](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/geometry_selection.json).


Canonical files: `ED7a.fig`, `ED7a.png`.

## ED7b — Experimental/model PR calibration

Frozen experimental values (resample SD, not model bootstrap SE): Control5.3860834614584618±0.10849353351504434; Block8.0314168558827177±0.1492166304511115. These are copied exactly from the approved plot, without new empirical analysis; source `ED7bc_experiment.csv`.

Experimental and model Control/Block preparatory PR. **Calibration target, not independent validation.** Experimental resample SD and model network-median bootstrap SE are distinct uncertainties and explicitly labeled. Model n10; preserved paired comparison, no multiplicity correction.

| Value | Median | Bootstrap SE | n |
| --- | --- | --- | --- |
| Control PR | 3.464666373657559 | 0.08100462284179086 | 10 |
| Block PR | 6.6401482930116185 | 0.08836778336590481 | 10 |
| Paired Block−Control PR | 3.2357604186198508 | 0.12059110855364781 | 10 |

| Panel / contrast | AD reject; p; A² | Selected two-sided test | Statistic; df | Raw p | n |
| --- | --- | --- | --- | --- | --- |
| ED7b | false; 0.9067837919868639; 0.18286964780299364 | two-sided paired t-test | 27.34130554364507; 9 | 5.678500663708396e-10 | 10 |

Sources: [ED7bc_network_values.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/ED7bc_network_values.csv); [statistics.json](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/statistics.json).


Canonical files: `ED7b.fig`, `ED7b.png`.

## ED7c — Experimental/model alignment calibration

Frozen experimental values (percent; resample SD, not model bootstrap SE): Observed32.493121686164521±1.1226239345301614; Expected49.295305371483224±3.2987728284040356. These are copied exactly from the approved plot, without new empirical analysis; source `ED7bc_experiment.csv`.

Experimental and model observed/expected alignment. **Calibration target, not independent validation.** Minimum Control-derived K reaching≥95% variance; that same K for comparison subspace, denominator and null. Experimental resample SD and model network-median bootstrap SE are distinct. Model n10; no multiplicity correction.

| Value | Median | Bootstrap SE | n |
| --- | --- | --- | --- |
| Observed % | 27.82155117418165 | 1.8200674187977026 | 10 |
| Expected % | 45.32074681609318 | 0.629511359410819 | 10 |
| Paired expected−observed pp | 16.40928520813804 | 1.3633781069230415 | 10 |

| Panel / contrast | AD reject; p; A² | Selected two-sided test | Statistic; df | Raw p | n |
| --- | --- | --- | --- | --- | --- |
| ED7c | false; 0.7314132843375539; 0.2421430900550412 | two-sided paired t-test | 14.560443948422693; 9 | 1.460201452339301e-7 | 10 |

Sources: [ED7bc_network_values.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/ED7bc_network_values.csv); [statistics.json](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/statistics.json).


Canonical files: `ED7c.fig`, `ED7c.png`.
