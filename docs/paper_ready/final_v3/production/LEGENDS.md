# Final manuscript panel definitions and unchanged statistics

All panels use the final Fig6a–h / ED7a–d numbering. Numerical values below are copied from the frozen source records, not recomputed inference. Native FIG/PNG masters: `plots/paper_ready/final_v3/production/{fig,png}/`. Statistical full precision: `data/paper_ready/final_v3/tables/statistics.json`.

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

Exact current Main_text_v10 functional-model schematic, preserved as a static version-controlled asset. No editable source was available. Ten200-unit networks; eta0, lambda10, V1, global alpha.5/beta_norm1.25. Base preparation + target-dependent state setting b + anticipatory feedback L; full Block removes b and L. No generic residual kappa feedback. Effective decomposition only, not anatomically separate pathways.

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

Absolute Control preparatory→early-movement R² from the frozen epoch-specific PCA75→nested-ridge pipeline.

Exactly four displayed/analyzed amplitudes .05,.10,.15,.20; other noise source fixed at.10; shared.10/.10 anchor. Same standardized streams, eight targets×30 trials and ten frozen networks. No post-GO or observation noise. Medians±whole-network bootstrap SE. Separate Friedman tests across four levels, df3,n10; raw p, no cross-test BH or post-hoc comparisons.

| Sweep | Noise | Median | Bootstrap SE |
| --- | --- | --- | --- |
| Initial-state | 0.05 | 0.9315906873203654 | 0.004598712469882511 |
| Initial-state | 0.1 | 0.9242455100130416 | 0.0065456126935907214 |
| Initial-state | 0.15 | 0.9188541183010039 | 0.005704521587348087 |
| Initial-state | 0.2 | 0.9082978100299428 | 0.005857660076326775 |
| Temporal | 0.05 | 0.9893550656832524 | 0.0020029888019608066 |
| Temporal | 0.1 | 0.9242455100130416 | 0.0065456126935907214 |
| Temporal | 0.15 | 0.8134087991083712 | 0.0036384595563064494 |
| Temporal | 0.2 | 0.7359613370808137 | 0.0038888931375109384 |

| Sweep | Friedman chi² | df | Raw p | n |
| --- | --- | --- | --- | --- |
| Initial-state | 26.519999999999996 | 3 | 0.000007421960923445147 | 10 |
| Temporal | 30 | 3 | 0.0000013800570312932536 | 10 |

Both four-point median curves decrease.
Sources: [Fig6gh_network_values.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_network_values.csv); [Fig6gh_summaries.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_summaries.csv); [Fig6gh_values.json](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_values.json).


Canonical files: `Fig6g.fig`, `Fig6g.png`.

## Fig6h — Relative Block prediction deficit versus noise

Relative Block prediction deficit, 100×(R²Control−R²Block)/R²Control, calculated within network before summary.

Exactly four displayed/analyzed amplitudes .05,.10,.15,.20; other noise source fixed at.10; shared.10/.10 anchor. Same standardized streams, eight targets×30 trials and ten frozen networks. No post-GO or observation noise. Medians±whole-network bootstrap SE. Separate Friedman tests across four levels, df3,n10; raw p, no cross-test BH or post-hoc comparisons.

| Sweep | Noise | Median | Bootstrap SE |
| --- | --- | --- | --- |
| Initial-state | 0.05 | 9.917276908749677 | 1.5194394541529745 |
| Initial-state | 0.1 | 9.271584687172439 | 1.7838513643810987 |
| Initial-state | 0.15 | 10.079421334179804 | 1.9967495605547554 |
| Initial-state | 0.2 | 9.96493087507309 | 1.6395535122622 |
| Temporal | 0.05 | 6.46165663278711 | 2.1805158876975193 |
| Temporal | 0.1 | 9.271584687172439 | 1.7838513643810987 |
| Temporal | 0.15 | 12.911967259266167 | 1.5878014544585972 |
| Temporal | 0.2 | 14.124730605296985 | 1.4731548149556652 |

| Sweep | Friedman chi² | df | Raw p | n |
| --- | --- | --- | --- | --- |
| Initial-state | 3.24 | 3 | 0.35608120810907057 | 10 |
| Temporal | 21.359999999999996 | 3 | 0.00008862187827753114 | 10 |

Temporal-loss medians increase across these four points; initial-loss medians are nonmonotonic. No directional trend test.
Sources: [Fig6gh_network_values.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_network_values.csv); [Fig6gh_summaries.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_summaries.csv); [Fig6gh_values.json](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/Fig6gh_values.json).


Canonical files: `Fig6h.fig`, `Fig6h.png`.

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

## ED7d — Component-removal prediction

Four-policy PCA75→ridge prediction at the fixed high-noise.20/.20 setting, ten matched networks, eight targets×30 trials/policy. Policies: Control(b+L), target-specific only(b;−L), anticipatory-control only(L;−b), Block(−b,−L), all with cortical base and eta0. Median±whole-network bootstrap SE; all trials/QC retained. Three paired contrasts against Control use AD-selected tests and BH across this three-test family.

| Value | Median | Bootstrap SE | n |
| --- | --- | --- | --- |
| Control | 0.7335596681145464 | 0.005486555179181469 | 10 |
| Target-specific only | 0.7094765553649167 | 0.007247899504769054 | 10 |
| Anticipatory-control only | 0.7726249026238836 | 0.005184560550353122 | 10 |
| Block | 0.6273769251939522 | 0.008496520480337135 | 10 |

| Removal | Paired condition−Control ΔR² | Bootstrap SE |
| --- | --- | --- |
| -L (b only) | -0.015758179219899304 | 0.004911585957112202 |
| -b (L only) | 0.04002580195676125 | 0.0059725859638296245 |
| Block (-b,-L) | -0.1119632323212697 | 0.012001078868776256 |

| Panel / contrast | AD reject; p; A² | Selected two-sided test | Statistic; df | Raw p | BH q | n |
| --- | --- | --- | --- | --- | --- | --- |
| -L (b only) | false; 0.7440616534184978; 0.23825700882047762 | two-sided paired t-test | -5.461439042685417; 9 | 0.0003996783369810219 | 0.0003996783369810219 | 10 |
| -b (L only) | false; 0.32499875105580456; 0.3908921115284816 | two-sided paired t-test | 7.644376237319492; 9 | 0.000031771222378114 | 0.000047656833567171 | 10 |
| Block (-b,-L) | false; 0.4622702737038866; 0.330974077540759 | two-sided paired t-test | -12.873452330535788; 9 | 4.2230383030285037e-7 | 0.0000012669114909085511 | 10 |

Removing L alone significantly lowers prediction; removing b alone significantly raises it; full Block significantly lowers it. These fixed-condition results do not establish anatomical separability and were not used for tuning.

Sources: [ED7d_network_values.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/ED7d_network_values.csv); [ED7d_tests.csv](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/ED7d_tests.csv); [statistics.json](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/data/paper_ready/final_v3/tables/statistics.json).


Canonical files: `ED7d.fig`, `ED7d.png`.
