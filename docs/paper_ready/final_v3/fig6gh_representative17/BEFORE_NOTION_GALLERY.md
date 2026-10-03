<callout icon="✅" color="green_bg">
	**Fig. 6h diffuse-spread correction — complete; scientific review pending.** h now uses **network8,target6**, chosen after inspecting all30-success clouds to avoid the previous two-cluster example. g remains **network8,target1**, with the task15 selected-ten median unchanged. h still shows the ten highest-pathRMS successful paths/circles and an all30-success inset in the empirical Fig1e style. No simulation or manuscript aggregate/inferential result changed. Task15 and this h-only review remain uncommitted; latest checkpoint remains04cd2b2a0be5b9b8fa2d57791d46e9f951e6b4f0.
</callout>
## Current frozen-model and statistical conventions
eta=0, lambda=10, V=1, shared alpha=.5 / beta_norm=1.25; ten frozen 200-unit networks, eight targets, 30 trials/target in quantitative datasets. Primary noise .10/.10. No post-GO noise. Effective Intact=b+L and Block removes b,L; no generic residual kappa stabilization. The decomposition is functional, not anatomical.
Calibration used only empirical paired ΔPR and alignment deficit. Prediction and movement are downstream outcomes. The separate success-conditioned network-8 visualization pool is never a quantitative statistical unit.
Unless stated otherwise, descriptive summaries are network medians ± the saved 10,000 whole-network bootstrap SE. Current paired tests use Anderson–Darling on paired differences to choose a two-sided paired t-test or Wilcoxon signed-rank. Separate eight-comparison BH families apply to a and b; no multiplicity correction to d/e/g/h. Current i/j use exactly four levels \[.05,.10,.15,.20\], matched n=10, Friedman df=3, raw p only, no post-hoc tests. ED7b uses its corrected three-contrast BH family at .20/.20. All existing values below are preserved.
## Fig. 6a — prospective feedback alone
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/100e9ac9-5930-4e32-999c-28f63ee04783/Fig6a.png)
Native pair: `plots/paper_ready/final_v3/fig/Fig6a.fig` and `png/Fig6a.png`.
Source: exact current `prospective_variability/summary.mat` mainA and legacyIndices; finite points also match `final_v2/figure_sources.mat` Stage-2 arrays. Existing Main A/B graphic objects are extracted without scientific alteration; pale individual-network traces are added from these same arrays. The separated FF-only endpoint is exact K=0, not a large finite penalty; feedback effort is exactly zero.
Caption: preparatory participation-ratio change relative to lambda=0.1 anticipatory control across the finite lambda sweep and an exact feedforward-only category. All ten networks and median ± bootstrap SE; the empirical Block−Control effect is context only. This is not the final Block model, and the ordinate must not be called Block−Control.
Manuscript-ready statistics — Fig6a exact feedforward-only endpoint: median paired effect -0.210124 ± 0.0824815, n=10. Corrected two-sided paired t-test versus lambda=0.1: t(9)=-4.8257021300603613, raw p=0.00093949903536209823; BH q=0.0075159922828967858 (eight comparisons within this panel). Anderson–Darling h=0 (normality not rejected), AD p=0.088188387608298474.
<table fit-page-width="true" header-row="true">
<tr>
<td>median paired effect</td>
<td>bootstrapSE</td>
<td>rawP versus lambda=0.1</td>
<td>BHq (8-test family)</td>
<td>significant q\<.05</td>
</tr>
<tr>
<td>-0.21012358309761869</td>
<td>0.082481503094238601</td>
<td>0.00093949903536209823</td>
<td>0.0075159922828967858</td>
<td>1</td>
</tr>
</table>
All eight matched-network comparisons versus lambda=0.1; n=10 each. AD alpha=0.05 and critical value=0.68574700000000000; h=1 rejects normality and h=0 does not reject it. Paired t tests have df=9; the Wilcoxon test uses the exact n=10 distribution. BH q is calculated within this panel only.
<table fit-page-width="true" header-row="true">
<tr>
<td>level versus 0.1</td>
<td>n</td>
<td>AD h</td>
<td>AD p</td>
<td>AD statistic</td>
<td>selected two-sided test</td>
<td>t or signed-rank statistic</td>
<td>raw p</td>
<td>BH q (8 comparisons)</td>
</tr>
<tr>
<td>0.2</td>
<td>10</td>
<td>0</td>
<td>0.13315580877178670</td>
<td>0.53385818523090300</td>
<td>two-sided paired t-test</td>
<td>-0.80315762393459933</td>
<td>0.44257712111518177</td>
<td>0.44257712111518177</td>
</tr>
<tr>
<td>0.5</td>
<td>10</td>
<td>1</td>
<td>0.010089097102452991</td>
<td>0.93254643922806757</td>
<td>two-sided Wilcoxon signed-rank</td>
<td>18.000000000000000</td>
<td>0.37500000000000000</td>
<td>0.42857142857142855</td>
</tr>
<tr>
<td>1</td>
<td>10</td>
<td>0</td>
<td>0.064979384233335269</td>
<td>0.64518759621341637</td>
<td>two-sided paired t-test</td>
<td>-1.5978242593584393</td>
<td>0.14454650900399971</td>
<td>0.19272867867199961</td>
</tr>
<tr>
<td>2</td>
<td>10</td>
<td>0</td>
<td>0.35055554807107092</td>
<td>0.37821486841194307</td>
<td>two-sided paired t-test</td>
<td>-1.9903716856698697</td>
<td>0.077750020073747206</td>
<td>0.12440003211799552</td>
</tr>
<tr>
<td>5</td>
<td>10</td>
<td>0</td>
<td>0.55249875366392731</td>
<td>0.29868803986800785</td>
<td>two-sided paired t-test</td>
<td>-2.6535995992100476</td>
<td>0.026320449844953422</td>
<td>0.052640899689906845</td>
</tr>
<tr>
<td>10</td>
<td>10</td>
<td>0</td>
<td>0.31607457668744887</td>
<td>0.39553119853451335</td>
<td>two-sided paired t-test</td>
<td>-3.1999247782450491</td>
<td>0.010832610140882866</td>
<td>0.028886960375687640</td>
</tr>
<tr>
<td>100</td>
<td>10</td>
<td>0</td>
<td>0.30756050194493256</td>
<td>0.40006075061333313</td>
<td>two-sided paired t-test</td>
<td>-3.6319151662841547</td>
<td>0.0054692859682338489</td>
<td>0.021877143872935396</td>
</tr>
<tr>
<td>FF-only</td>
<td>10</td>
<td>0</td>
<td>0.088188387608298474</td>
<td>0.59793208106616191</td>
<td>two-sided paired t-test</td>
<td>-4.8257021300603613</td>
<td>0.00093949903536209823</td>
<td>0.0075159922828967858</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>point (9=FF only)</td>
<td>lambda (Inf=exact FF)</td>
<td>median</td>
<td>bootstrapSE</td>
</tr>
<tr>
<td>1</td>
<td>0.10000000000000001</td>
<td>0</td>
<td>0</td>
</tr>
<tr>
<td>2</td>
<td>0.20000000000000001</td>
<td>-0.00075939792709989185</td>
<td>0.0030970936136074001</td>
</tr>
<tr>
<td>3</td>
<td>0.5</td>
<td>-0.0030652578644057016</td>
<td>0.0080968566292467653</td>
</tr>
<tr>
<td>4</td>
<td>1</td>
<td>-0.021262669436801884</td>
<td>0.017396148862563257</td>
</tr>
<tr>
<td>5</td>
<td>2</td>
<td>-0.048796434972354197</td>
<td>0.027330716250353111</td>
</tr>
<tr>
<td>6</td>
<td>5</td>
<td>-0.072099673859636226</td>
<td>0.045648015037886791</td>
</tr>
<tr>
<td>7</td>
<td>10</td>
<td>-0.084056233855158924</td>
<td>0.056672847738792602</td>
</tr>
<tr>
<td>8</td>
<td>100</td>
<td>-0.16139544139065132</td>
<td>0.030395655429300547</td>
</tr>
<tr>
<td>9</td>
<td>Inf</td>
<td>-0.21012358309761869</td>
<td>0.082481503094238601</td>
</tr>
</table>
[Full matched-network source values](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/results/paper_ready/final_v3/Fig6ab_network_values.csv).
## Fig. 6b — prospective feedback alone
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/e325de4a-7415-4681-8113-b42bee2e8efb/Fig6b.png)
Native pair: `plots/paper_ready/final_v3/fig/Fig6b.fig` and `png/Fig6b.png`.
Source: exact current `prospective_variability/summary.mat` mainB and legacyIndices; finite points also match `final_v2/figure_sources.mat` Stage-2 arrays. Existing Main A/B graphic objects are extracted without scientific alteration; pale individual-network traces are added from these same arrays. The separated FF-only endpoint is exact K=0, not a large finite penalty; feedback effort is exactly zero.
Caption: expected minus observed alignment, in percentage points, for the same sweep. Positive values imply below-null reorientation; negative values imply observed alignment above the covariance-matched null. All ten networks and median ± bootstrap SE, with the empirical effect shown only as context.
Manuscript-ready statistics — Fig6b exact feedforward-only endpoint: plotted endpoint deficit -14.0722 ± 1.74431 pp (unchanged), n=10. Corrected two-sided paired t-test versus lambda=0.1: t(9)=27.168801444877825, raw p=6.0076320676610320e-10; BH q=4.8061056541288256e-9 (eight comparisons within this panel). Anderson–Darling h=0 (normality not rejected), AD p=0.57399641683549474.
<table fit-page-width="true" header-row="true">
<tr>
<td>plotted endpoint deficit (pp; unchanged)</td>
<td>bootstrapSE</td>
<td>rawP versus lambda=0.1</td>
<td>BHq (8-test family)</td>
<td>significant q\<.05</td>
</tr>
<tr>
<td>-14.072180833928755</td>
<td>1.7443059088064921</td>
<td>6.0076320676610320e-10</td>
<td>4.8061056541288256e-9</td>
<td>1</td>
</tr>
</table>
All eight matched-network comparisons versus lambda=0.1; n=10 each. AD alpha=0.05 and critical value=0.68574700000000000; h=1 rejects normality and h=0 does not reject it. Paired t tests have df=9; the Wilcoxon test uses the exact n=10 distribution. BH q is calculated within this panel only.
<table fit-page-width="true" header-row="true">
<tr>
<td>level versus 0.1</td>
<td>n</td>
<td>AD h</td>
<td>AD p</td>
<td>AD statistic</td>
<td>selected two-sided test</td>
<td>t or signed-rank statistic</td>
<td>raw p</td>
<td>BH q (8 comparisons)</td>
</tr>
<tr>
<td>0.2</td>
<td>10</td>
<td>0</td>
<td>0.064688578845585903</td>
<td>0.64588112395195196</td>
<td>two-sided paired t-test</td>
<td>7.4354093067883182</td>
<td>0.000039525394647509142</td>
<td>0.000056157277653286469</td>
</tr>
<tr>
<td>0.5</td>
<td>10</td>
<td>0</td>
<td>0.050486586077910935</td>
<td>0.68424545110498869</td>
<td>two-sided paired t-test</td>
<td>6.4949876511459266</td>
<td>0.00011210251581308729</td>
<td>0.00012811716092924261</td>
</tr>
<tr>
<td>1</td>
<td>10</td>
<td>0</td>
<td>0.060551077465921622</td>
<td>0.65610240252705054</td>
<td>two-sided paired t-test</td>
<td>5.9499006314429348</td>
<td>0.00021536680721101313</td>
<td>0.00021536680721101313</td>
</tr>
<tr>
<td>2</td>
<td>10</td>
<td>0</td>
<td>0.13721966167562666</td>
<td>0.52915776390199731</td>
<td>two-sided paired t-test</td>
<td>7.3754310296236349</td>
<td>0.000042117958239964851</td>
<td>0.000056157277653286469</td>
</tr>
<tr>
<td>5</td>
<td>10</td>
<td>0</td>
<td>0.72185667214195304</td>
<td>0.24506753225150746</td>
<td>two-sided paired t-test</td>
<td>9.1144131457366253</td>
<td>0.0000076988800515892451</td>
<td>0.000015397760103178490</td>
</tr>
<tr>
<td>10</td>
<td>10</td>
<td>0</td>
<td>0.66367120176970062</td>
<td>0.26290198039554191</td>
<td>two-sided paired t-test</td>
<td>10.804105224530877</td>
<td>0.0000018730218725016996</td>
<td>0.0000049947249933378655</td>
</tr>
<tr>
<td>100</td>
<td>10</td>
<td>0</td>
<td>0.78740566414534385</td>
<td>0.22478123973568565</td>
<td>two-sided paired t-test</td>
<td>18.983687626592275</td>
<td>1.4375184217663900e-8</td>
<td>5.7500736870655599e-8</td>
</tr>
<tr>
<td>FF-only</td>
<td>10</td>
<td>0</td>
<td>0.57399641683549474</td>
<td>0.29153171771440611</td>
<td>two-sided paired t-test</td>
<td>27.168801444877825</td>
<td>6.0076320676610320e-10</td>
<td>4.8061056541288256e-9</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>point (9=FF only)</td>
<td>lambda (Inf=exact FF)</td>
<td>median</td>
<td>bootstrapSE</td>
</tr>
<tr>
<td>1</td>
<td>0.10000000000000001</td>
<td>-52.645911587299167</td>
<td>0.95574600201741</td>
</tr>
<tr>
<td>2</td>
<td>0.20000000000000001</td>
<td>-52.44516943995724</td>
<td>0.96003287046397645</td>
</tr>
<tr>
<td>3</td>
<td>0.5</td>
<td>-51.394481441572594</td>
<td>0.91881576025661482</td>
</tr>
<tr>
<td>4</td>
<td>1</td>
<td>-49.195029140135311</td>
<td>0.74581110367468395</td>
</tr>
<tr>
<td>5</td>
<td>2</td>
<td>-46.568848750075162</td>
<td>0.52226541290208239</td>
</tr>
<tr>
<td>6</td>
<td>5</td>
<td>-41.70733613162129</td>
<td>1.2886707296916253</td>
</tr>
<tr>
<td>7</td>
<td>10</td>
<td>-37.180096699794134</td>
<td>1.3712705935980203</td>
</tr>
<tr>
<td>8</td>
<td>100</td>
<td>-23.246962577873589</td>
<td>2.1001428119971486</td>
</tr>
<tr>
<td>9</td>
<td>Inf</td>
<td>-14.072180833928755</td>
<td>1.7443059088064921</td>
</tr>
</table>
[Full matched-network source values](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/results/paper_ready/final_v3/Fig6ab_network_values.csv).
## Fig. 6c — final effective model schematic
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/1e92011e-9fff-4160-829b-5ec5c1568187/Fig6c.png)
Native pair: `plots/paper_ready/final_v3/fig/Fig6c.fig` and `png/Fig6c.png`.
Source: unchanged final eta=0 equations and released Main C concept, redrawn for standalone legibility. Common base u_base=-f(x_B), state-setting b=f(x_B)-f(x*), prospective feedback -L(x-x*), recurrent cortical dynamics, fixed downstream movement generator/readout and two-link arm. Intact retains b+L; Block removes both and retains the base. No residual kappa loop and no anatomically segregated-pathway claim.
Manuscript-ready statistics: not applicable (schematic, not numerical evidence).
<table fit-page-width="true" header-row="true">
<tr>
<td>Policy</td>
<td>Preparation input</td>
</tr>
<tr>
<td>Intact (b+L)</td>
<td>u_base + b - L(x-x\*)</td>
</tr>
<tr>
<td>-L (b only)</td>
<td>u_base + b</td>
</tr>
<tr>
<td>-b (L only)</td>
<td>u_base - L(x-x\*)</td>
</tr>
<tr>
<td>Block (-b,-L)</td>
<td>u_base</td>
</tr>
</table>
## Fig. 6d — experiment versus model: calibration disclosure
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/6315580b-8db2-41c7-a7f4-81816df0a23a/Fig6d.png)
Native pair: `plots/paper_ready/final_v3/fig/Fig6d.fig` and `png/Fig6d.png`.
Source: exact released `final_v2/figure_sources.mat` and corresponding current Main G axes. Shared geometry was selected only from the empirical paired-effect targets; absolute condition means/medians, movement, prediction and QC did not enter calibration. These model comparisons are calibration targets, not independent validation.
Empirical source: `dimensionality_alignment_epochs_raw_data.fig`, Drive ID 1T-3vbgRph1bbm-sl_fK0u9GiNzpwKzUT, SHA256 B2B1381FCFEFABBA5065E8D7617DB0D5A9E5EF08C6A120E539AE980C635A824F; exact Prep bars extracted in `results/paper_ready/empirical/targets.mat`. Model error bars are network-median bootstrap SE; empirical errors remain SD across trial-balanced resamples. The paired calibration target is the difference of exact source bars, not an inferred paired uncertainty.
Manuscript-ready statistics — Fig6d Block-Intact PR: median paired effect 3.23576 ± 0.120591, n=10. Corrected two-sided paired t-test, n=10, t(9)=27.341305543645070, raw p=5.6785006637083963e-10. Anderson–Darling h=0 (normality not rejected), AD p=0.90678379198686387. No multiple-comparison correction.
<table fit-page-width="true" header-row="true">
<tr>
<td>median paired effect</td>
<td>bootstrapSE</td>
<td>rawP (uncorrected)</td>
<td>significant raw p\<.05</td>
</tr>
<tr>
<td>3.2357604186198508</td>
<td>0.12059110855364781</td>
<td>5.6785006637083963e-10</td>
<td>1</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>n</td>
<td>AD h (alpha=0.05)</td>
<td>AD p</td>
<td>AD statistic</td>
<td>AD critical</td>
<td>selected two-sided test</td>
<td>statistic</td>
<td>df</td>
<td>raw p (uncorrected)</td>
</tr>
<tr>
<td>10</td>
<td>0</td>
<td>0.90678379198686387</td>
<td>0.18286964780299364</td>
<td>0.68574700000000000</td>
<td>two-sided paired t-test</td>
<td>t=27.341305543645070</td>
<td>9</td>
<td>5.6785006637083963e-10</td>
</tr>
</table>
Empirical calibration effect: 2.6453333944000001.
Caption: experimental Control/Block and model Intact/Block late-preparatory participation ratio. Model n=10, median ± bootstrap SE; only paired Block−Intact ΔPR entered calibration.
<table fit-page-width="true" header-row="true">
<tr>
<td>condition (1=Intact,2=Block)</td>
<td>model median</td>
<td>model SE</td>
<td>empirical source bar</td>
<td>empirical source error</td>
</tr>
<tr>
<td>1</td>
<td>3.4646663736575589</td>
<td>0.081004622841790858</td>
<td>5.3860834614584618</td>
<td>0.10849353351504434</td>
</tr>
<tr>
<td>2</td>
<td>6.6401482930116185</td>
<td>0.088367783365904812</td>
<td>8.0314168558827177</td>
<td>0.1492166304511115</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>network</td>
<td>IntactPR</td>
<td>BlockPR</td>
<td>Block-Intact</td>
</tr>
<tr>
<td>1</td>
<td>3.4532640112905146</td>
<td>6.7391023256525315</td>
<td>3.2858383143620169</td>
</tr>
<tr>
<td>2</td>
<td>3.400723032724712</td>
<td>6.6220227100820539</td>
<td>3.2212996773573419</td>
</tr>
<tr>
<td>3</td>
<td>3.6499845155618127</td>
<td>6.9002056754441723</td>
<td>3.2502211598823596</td>
</tr>
<tr>
<td>4</td>
<td>2.7674836447298166</td>
<td>6.5649831578140443</td>
<td>3.7974995130842277</td>
</tr>
<tr>
<td>5</td>
<td>4.2122218718244575</td>
<td>6.9112506949980101</td>
<td>2.6990288231735526</td>
</tr>
<tr>
<td>6</td>
<td>3.6990588396880377</td>
<td>6.2677722796431921</td>
<td>2.5687134399551543</td>
</tr>
<tr>
<td>7</td>
<td>3.4224445018362109</td>
<td>6.5248022825960872</td>
<td>3.1023577807598763</td>
</tr>
<tr>
<td>8</td>
<td>3.5725697706038724</td>
<td>6.5427265402639385</td>
<td>2.9701567696600661</td>
</tr>
<tr>
<td>9</td>
<td>3.1452967009699413</td>
<td>6.6582738759411839</td>
<td>3.5129771749712426</td>
</tr>
<tr>
<td>10</td>
<td>3.4760687360246032</td>
<td>6.888434704960491</td>
<td>3.4123659689358878</td>
</tr>
</table>
## Fig. 6e — experiment versus model: calibration disclosure
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/6eaca835-46da-49c5-b95e-5ba69a41c1e9/Fig6e.png)
Native pair: `plots/paper_ready/final_v3/fig/Fig6e.fig` and `png/Fig6e.png`.
Source: exact released `final_v2/figure_sources.mat` and corresponding current Main H axes. Shared geometry was selected only from the empirical paired-effect targets; absolute condition means/medians, movement, prediction and QC did not enter calibration. These model comparisons are calibration targets, not independent validation.
Empirical source: `dimensionality_alignment_epochs_raw_data.fig`, Drive ID 1T-3vbgRph1bbm-sl_fK0u9GiNzpwKzUT, SHA256 B2B1381FCFEFABBA5065E8D7617DB0D5A9E5EF08C6A120E539AE980C635A824F; exact Prep bars extracted in `results/paper_ready/empirical/targets.mat`. Model error bars are network-median bootstrap SE; empirical errors remain SD across trial-balanced resamples. The paired calibration target is the difference of exact source bars, not an inferred paired uncertainty.
Manuscript-ready statistics — Fig6e expected-observed pp: median paired effect 16.4093 ± 1.36338, n=10. Corrected two-sided paired t-test, n=10, t(9)=14.560443948422693, raw p=1.4602014523393009e-7. Anderson–Darling h=0 (normality not rejected), AD p=0.73141328433755393. No multiple-comparison correction.
<table fit-page-width="true" header-row="true">
<tr>
<td>median paired effect</td>
<td>bootstrapSE</td>
<td>rawP (uncorrected)</td>
<td>significant raw p\<.05</td>
</tr>
<tr>
<td>16.409285208138041</td>
<td>1.3633781069230415</td>
<td>1.4602014523393009e-7</td>
<td>1</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>n</td>
<td>AD h (alpha=0.05)</td>
<td>AD p</td>
<td>AD statistic</td>
<td>AD critical</td>
<td>selected two-sided test</td>
<td>statistic</td>
<td>df</td>
<td>raw p (uncorrected)</td>
</tr>
<tr>
<td>10</td>
<td>0</td>
<td>0.73141328433755393</td>
<td>0.24214309005504120</td>
<td>0.68574700000000000</td>
<td>two-sided paired t-test</td>
<td>t=14.560443948422693</td>
<td>9</td>
<td>1.4602014523393009e-7</td>
</tr>
</table>
Empirical calibration effect: 16.802184.
Caption: experimental and model observed/expected alignment (percent). The Intact-derived minimum Control95 K is shared by comparison basis, normalization and covariance-matched null. Only expected−observed deficit entered calibration.
<table fit-page-width="true" header-row="true">
<tr>
<td>condition (1=observed,2=expected)</td>
<td>model medianPct</td>
<td>model SEPct</td>
<td>empirical source barPct</td>
<td>empirical source error</td>
</tr>
<tr>
<td>1</td>
<td>27.82155117418165</td>
<td>1.8200674187977026</td>
<td>32.493121686164521</td>
<td>1.1226239345301614</td>
</tr>
<tr>
<td>2</td>
<td>45.320746816093177</td>
<td>0.62951135941081904</td>
<td>49.295305371483224</td>
<td>3.2987728284040356</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>network</td>
<td>observedPct</td>
<td>expectedPct</td>
<td>deficitPP</td>
</tr>
<tr>
<td>1</td>
<td>33.339455759592809</td>
<td>45.252547718849911</td>
<td>11.913091959257102</td>
</tr>
<tr>
<td>2</td>
<td>33.120068601382499</td>
<td>45.664091959300464</td>
<td>12.544023357917965</td>
</tr>
<tr>
<td>3</td>
<td>25.299518670503662</td>
<td>41.471401625918581</td>
<td>16.171882955414919</td>
</tr>
<tr>
<td>4</td>
<td>31.163082007365052</td>
<td>45.38894591333645</td>
<td>14.225863905971398</td>
</tr>
<tr>
<td>5</td>
<td>22.50118438440418</td>
<td>44.992853331341564</td>
<td>22.491668946937384</td>
</tr>
<tr>
<td>6</td>
<td>31.648265696742701</td>
<td>47.049613543611081</td>
<td>15.401347846868379</td>
</tr>
<tr>
<td>7</td>
<td>25.925968939098563</td>
<td>42.572656399959726</td>
<td>16.646687460861163</td>
</tr>
<tr>
<td>8</td>
<td>27.509320431314944</td>
<td>45.039421375902712</td>
<td>17.530100944587769</td>
</tr>
<tr>
<td>9</td>
<td>26.41651012522015</td>
<td>48.762374631171404</td>
<td>22.345864505951255</td>
</tr>
<tr>
<td>10</td>
<td>28.13378191704836</td>
<td>47.354729679026029</td>
<td>19.220947761977669</td>
</tr>
</table>
## Fig. 6f — illustrative high-pathRMS successful reaches
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/e39f8f94-c429-4606-b25b-5eb446693293/Fig6f.png)
Native pair: `plots/paper_ready/final_v3/fig6fgh_highrms14/fig/Fig6f.fig` and `png/Fig6f.png`.
Frozen network **8**; no simulation. In each target × condition, show the **four highest-pathRMS successful saved trials**, ranked by descending shortest-distance RMS to the ideal closed center-to-center segment with ascending attempt-ID tie-break. Each path ends at first entry into the frozen 1.5-cm target zone. Thick means use **those exact same four** after MO-to-entry linear x/y interpolation onto **101 movement-phase points**.
Exact manuscript eight-target palette, target1 bottom-center and increasing IDs counterclockwise; identical spatial axes/aspect. These are **deliberately selected high-deviation successful examples**, not statistically typical paths or an inferential assay. All failed attempts remain preserved and undisplayed.
[Descending selected IDs, RMS, rank, seeds and entry times](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/results/paper_ready/final_v3/fig6fgh_highrms14/Fig6f_selected_trials.csv) · [Same-four101-point means](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/results/paper_ready/final_v3/fig6fgh_highrms14/Fig6f_four_trial_phase_means.csv) · [Complete report and ID table](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/docs/paper_ready/final_v3/fig6fgh_highrms14/REPORT.md).
## Fig. 6g — illustrative high-pathRMS hand-speed profiles
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/5df3d9bb-388e-471f-98e7-fe692af029b4/Fig6g.png)
Native pair: `plots/paper_ready/final_v3/fig6gh_tweak15/fig/Fig6g.fig` and `png/Fig6g.png`.
**Network 8, target 1; Fig. 6g is unchanged from task15.** Fig. 6h now uses a different target (network8,target6) to illustrate a more distributed Block peak-position cloud. The earlier target1 speed example and all displayed IDs/median arrays below remain unchanged. Both are deliberately outcome-selected illustrations, not inferential or typicality claims.
Displayed ten highest-pathRMS success IDs: Intact **7,22,6,28,3,4,17,13,27,25**; Block **185,49,84,160,54,97,80,137,71,53**.
Thin traces are **unsmoothed, solid**, movement-onset aligned and ended at first target-zone entry. Thick medians use **only these exact ten displayed trials**, with post-entry samples NaN. The complete raw median is smoothed with the existing **50-ms Gaussian** using truncated/renormalized actual boundaries, then displayed through the **last nActive≥5** sample. Full support ends **527/545 ms**; display cutoffs **263/516 ms**, Intact/Block. No zero-padding or smoothing at an artificial cutoff boundary. Intact sky blue \[86,180,233\]/255; Block vermillion \[213,94,0\]/255.
The median population/cutoff is the only speed-display change; raw thin traces and trial IDs are unchanged. Selected high-deviation successes are not statistically typical trials. No aggregate-statistics subplot.
Current selected IDs, raw thin traces, selected-ten raw/smoothed medians, nActive and cutoffs are in the downloadable review source ZIP below, under `results/paper_ready/final_v3/fig6gh_tweak15/`. The original task15 candidate comparison remains preserved locally as provenance.
### Manuscript-ready aggregate statistics — unchanged
These remain the validated all-trial, ten-network native unsmoothed peak-speed analysis, **not** statistics of the successful visualization pool.
Manuscript-ready statistics: Intact 0.420266 ± 0.00095732 m/s; Block 0.293346 ± 0.011121 m/s; within-network percent reduction 29.6207 ± 2.50309%. Verified two-sided paired t-test, n=10, t(9)=-18.944070455588200, raw p=1.4641906487214610e-8. Anderson–Darling h=0 (normality not rejected), AD p=0.63262125699845573. No multiple-comparison correction.
<table fit-page-width="true" header-row="true">
<tr>
<td>n</td>
<td>AD h (alpha=0.05)</td>
<td>AD p</td>
<td>AD statistic</td>
<td>AD critical</td>
<td>selected two-sided test</td>
<td>statistic</td>
<td>df</td>
<td>raw p (uncorrected)</td>
</tr>
<tr>
<td>10</td>
<td>0</td>
<td>0.63262125699845573</td>
<td>0.27261640032784484</td>
<td>0.68574700000000000</td>
<td>two-sided paired t-test</td>
<td>t=-18.944070455588200</td>
<td>9</td>
<td>1.4641906487214610e-8</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>network</td>
<td>IntactMps</td>
<td>BlockMps</td>
<td>reductionPct</td>
</tr>
<tr>
<td>1</td>
<td>0.42329048130783631</td>
<td>0.28412947563948704</td>
<td>32.876006386532701</td>
</tr>
<tr>
<td>2</td>
<td>0.41979476613234956</td>
<td>0.31740196813223859</td>
<td>24.391156408040921</td>
</tr>
<tr>
<td>3</td>
<td>0.42215728654179485</td>
<td>0.32455984518058645</td>
<td>23.118739027508404</td>
</tr>
<tr>
<td>4</td>
<td>0.40723566550606155</td>
<td>0.28347600202813206</td>
<td>30.39018287461057</td>
</tr>
<tr>
<td>5</td>
<td>0.42156647748635162</td>
<td>0.27233062135718894</td>
<td>35.400313852989946</td>
</tr>
<tr>
<td>6</td>
<td>0.41912334794561934</td>
<td>0.32674220795324571</td>
<td>22.041516046574422</td>
</tr>
<tr>
<td>7</td>
<td>0.42058962466681826</td>
<td>0.31312181183188403</td>
<td>25.551703259458158</td>
</tr>
<tr>
<td>8</td>
<td>0.41994305319093717</td>
<td>0.27771062872133895</td>
<td>33.869455248478374</td>
</tr>
<tr>
<td>9</td>
<td>0.42434678864138869</td>
<td>0.28973241928742582</td>
<td>31.722726071511325</td>
</tr>
<tr>
<td>10</td>
<td>0.41737979473131043</td>
<td>0.29696032204081702</td>
<td>28.85129424341536</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>metric (1=Intact,2=Block,3=percent reduction)</td>
<td>median</td>
<td>bootstrapSE</td>
</tr>
<tr>
<td>1</td>
<td>0.42026633892887771</td>
<td>0.00095732016011368989</td>
</tr>
<tr>
<td>2</td>
<td>0.29334637066412139</td>
<td>0.011120979564432407</td>
</tr>
<tr>
<td>3</td>
<td>29.620738559012963</td>
<td>2.5030943906286582</td>
</tr>
</table>
## Fig. 6h — empirical-style distributed peak-position spread
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/2588f021-dbb5-43e9-b1ee-f57b1bd0b19b/Fig6h.png)
Native pair: `plots/paper_ready/final_v3/fig6h_diffuse16/fig/Fig6h.fig` and `png/Fig6h.png`.
**Network8,target6**; different from g's unchanged target1. Target6 was chosen after inspecting the complete30-success clouds and fixed top-ten high-pathRMS subsets for all five eligible saved targets (1,2,3,6,8). It illustrates broader distributed Block peak-position spread without target1's two separated compact groups. This is outcome-selected visualization, not an unbiased representative or formal unimodality claim.
Displayed highest-pathRMS success IDs: Intact **50,45,29,9,10,14,24,31,7,43**; Block **29,56,58,101,88,51,49,9,22,98**. All successes are retained: each condition reached30 by attempts50/105 respectively. No new simulation, jitter, point deletion or target mixing.
**Solid sky-blue/vermillion paths** end at first entry into the1.5-cm target zone; filled circles mark native unsmoothed peak-speed positions. The **black dashed center-to-center line** remains the ideal-path reference. Overlay, hidden axes,1-cm L-scale, target key and lower-right angled overlapping filled histogram follow the visually rechecked live Main_text_v10 Fig1e. Native target6 orientation is retained.
The histogram and each condition's coordinatewise median peak position use **all30 successes**, not the displayed ten. Shared0.5-cm bins span0–2.5cm; Intact counts **13,16,1,0,0**, Block **3,11,12,3,1**. Inset scales indicate1cm and2trials.
Descriptive selection check only: all30 RMS distance is **0.532040/1.178426cm**, Intact/Block. Splitting the Block cloud at its largest minimum-spanning-tree edge attributes **9.121%** of full30 total variation to separation (versus85.755% for target1); all points remain included in the decomposition and final inset. This is not a modality test or new manuscript statistic.
Current full-precision all30 positions/distances, selected IDs/paths, histogram counts, candidate inspection diagnostics and independent validation are in the review source ZIP below under `results/paper_ready/final_v3/fig6h_diffuse16/`.
### Manuscript-ready aggregate statistics — unchanged
Manuscript-ready statistics: Speed-matched hand-position dispersion; 6/10 networks met the prespecified matching criterion. Eligible IDs 1, 2, 3, 6, 7, 10; within-target greedy peak-speed mismatch ≤5%, ≥5 pairs per target, ≥5 eligible targets per network. Intact 0.552672 ± 0.027319 cm; Block 2.684 ± 0.331609 cm; within-network increase 395.374 ± 63.0306%. Verified two-sided Wilcoxon signed-rank, n=6, W_plus=21, raw p=0.031250000000000000. Anderson–Darling h=1 (normality rejected), AD p=0.021789232569363721. No multiple-comparison correction. W_plus is the positive-rank sum for Block−Intact; W_minus=0, and df is not applicable. No values are invented for excluded networks 4, 5, 8, 9.
<table fit-page-width="true" header-row="true">
<tr>
<td>n</td>
<td>AD h (alpha=0.05)</td>
<td>AD p</td>
<td>AD statistic</td>
<td>AD critical</td>
<td>selected two-sided test</td>
<td>statistic</td>
<td>df</td>
<td>raw p (uncorrected)</td>
</tr>
<tr>
<td>6</td>
<td>1</td>
<td>0.021789232569363721</td>
<td>0.74421898504661943</td>
<td>0.63297499999999995</td>
<td>two-sided Wilcoxon signed-rank</td>
<td>W_plus=21.000000000000000</td>
<td>N/A</td>
<td>0.031250000000000000</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>network</td>
<td>matched IntactCM</td>
<td>matched BlockCM</td>
<td>increasePct</td>
</tr>
<tr>
<td>1</td>
<td>0.60922475279291843</td>
<td>4.6699165918572598</td>
<td>666.53428319328509</td>
</tr>
<tr>
<td>2</td>
<td>0.61397347843696037</td>
<td>2.7247764828915972</td>
<td>343.79384103500217</td>
</tr>
<tr>
<td>3</td>
<td>0.55158671367972589</td>
<td>2.371326118767223</td>
<td>329.90994162055057</td>
</tr>
<tr>
<td>6</td>
<td>0.50644073112079813</td>
<td>2.6432256277007573</td>
<td>421.92200691501756</td>
</tr>
<tr>
<td>7</td>
<td>0.51334244483310221</td>
<td>3.1205474566017037</td>
<td>507.88806536662986</td>
</tr>
<tr>
<td>10</td>
<td>0.55375649898351953</td>
<td>2.5961504849143524</td>
<td>368.82528506299599</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>metric (1=IntactCM,2=BlockCM,3=increasePct)</td>
<td>median</td>
<td>bootstrapSE</td>
</tr>
<tr>
<td>1</td>
<td>0.55267160633162271</td>
<td>0.027318985032037599</td>
</tr>
<tr>
<td>2</td>
<td>2.6840010552961773</td>
<td>0.33160946624453685</td>
</tr>
<tr>
<td>3</td>
<td>395.37364598900677</td>
<td>63.030615020997878</td>
</tr>
</table>
Unmatched all-ten-network robustness control (non-primary): Intact 0.538181 ± 0.018179 cm; Block 3.01474 ± 0.203371 cm.
<table fit-page-width="true" header-row="true">
<tr>
<td>network</td>
<td>unmatched IntactCM</td>
<td>unmatched BlockCM</td>
</tr>
<tr>
<td>1</td>
<td>0.59553307840322223</td>
<td>3.5837105512507605</td>
</tr>
<tr>
<td>2</td>
<td>0.53603439814983611</td>
<td>2.6984058094427366</td>
</tr>
<tr>
<td>3</td>
<td>0.51014706425525391</td>
<td>2.8281000678740411</td>
</tr>
<tr>
<td>4</td>
<td>0.56997301427459224</td>
<td>3.4136925635566415</td>
</tr>
<tr>
<td>5</td>
<td>0.58206635037240295</td>
<td>2.7165649594239398</td>
</tr>
<tr>
<td>6</td>
<td>0.49926412767821188</td>
<td>2.9530329171311269</td>
</tr>
<tr>
<td>7</td>
<td>0.5339103168319761</td>
<td>2.7342904546814499</td>
</tr>
<tr>
<td>8</td>
<td>0.54032753693699642</td>
<td>3.0764463566498397</td>
</tr>
<tr>
<td>9</td>
<td>0.51032550967694468</td>
<td>3.3387207521257394</td>
</tr>
<tr>
<td>10</td>
<td>0.5901683786925489</td>
<td>3.9002214783128113</td>
</tr>
</table>
## Fig. 6i — noise-dependent prediction
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/302cda4b-f58b-4077-bcdd-62696845769b/Fig6i_fourlevel.png)
Native pair: `plots/paper_ready/final_v3/fig6ij_fourlevel/fig/Fig6i.fig` and matching `png/Fig6i.png`.
Source: `results/paper_ready/final_v3/fig6ij_fourlevel/summary.mat`, `Fig6ij_network_values.csv` and `Fig6ij_summaries.csv`. Saved values are reused unchanged. Initial sweep (dashed) holds temporal=.10; temporal sweep (solid) holds initial=.10. The .10/.10 anchor is one shared dataset, not independent evidence in the two curves. Other amplitudes remain provenance only and are excluded from current paper-facing plots and inference.
Caption: absolute Intact cross-validated prep→early-movement R². Frozen model, networks, eight targets × 30 trials, neuron scales, standardized stream identities and seeds are unchanged. Boundary-protected Gaussian SD30-ms rate smoothing; GO−100:10:0 and each trial’s kinematic MO+0:10:100; time-aligned condition-invariant subtraction; epoch-specific balanced-ensemble PCA≥75%; unchanged target-matched nested 3-fold ridge with 25 penalties. No post-GO noise. This update reran no simulations, preprocessing, PCA or prediction fits. All four displayed levels \[.05,.10,.15,.20\] enter each Friedman repeated-measures test, n=10 matched networks, df=3. Report raw chi-square-approximate p-values only; no BH across the four Fig. 6i/j omnibus tests and no post-hoc pairwise tests. Error bars are median ± SE of the median from the original fixed 10,000 whole-network bootstrap draws, copied exactly from saved results.
Manuscript-ready statistics — initial-state sweep: Friedman χ²(3)=26.519999999999996, raw p=0.0000074219609234451472, n=10; all four displayed levels. Low→high (.05→.20): 0.931591 ± 0.00459871 → 0.908298 ± 0.00585766.
Manuscript-ready statistics — temporal sweep: Friedman χ²(3)=30.000000000000000, raw p=0.0000013800570312932536, n=10; all four displayed levels. Low→high (.05→.20): 0.989355 ± 0.00200299 → 0.735961 ± 0.00388889.
Both four-point Intact median curves decrease. This describes the medians, not necessarily every individual network.
Full-precision descriptive summaries (sweep 1=initial-state, 2=temporal):
<table fit-page-width="true" header-row="true">
<tr>
<td>Sweep</td>
<td>Noise</td>
<td>Median</td>
<td>Bootstrap SE</td>
</tr>
<tr>
<td>1</td>
<td>0.05</td>
<td>0.93159068732036543</td>
<td>0.004598712469882511</td>
</tr>
<tr>
<td>1</td>
<td>0.10</td>
<td>0.92424551001304156</td>
<td>0.0065456126935907214</td>
</tr>
<tr>
<td>1</td>
<td>0.15</td>
<td>0.91885411830100394</td>
<td>0.0057045215873480874</td>
</tr>
<tr>
<td>1</td>
<td>0.20</td>
<td>0.90829781002994281</td>
<td>0.0058576600763267754</td>
</tr>
<tr>
<td>2</td>
<td>0.05</td>
<td>0.98935506568325238</td>
<td>0.0020029888019608066</td>
</tr>
<tr>
<td>2</td>
<td>0.10</td>
<td>0.92424551001304156</td>
<td>0.0065456126935907214</td>
</tr>
<tr>
<td>2</td>
<td>0.15</td>
<td>0.81340879910837116</td>
<td>0.0036384595563064494</td>
</tr>
<tr>
<td>2</td>
<td>0.20</td>
<td>0.73596133708081368</td>
<td>0.0038888931375109384</td>
</tr>
</table>
[Full-precision matched-network values](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/results/paper_ready/final_v3/fig6ij_fourlevel/Fig6ij_network_values.csv) · [Current four-level report](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/docs/paper_ready/final_v3/fig6ij_fourlevel/REPORT.md).
## Fig. 6j — noise-dependent prediction
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/34a3f580-992c-476a-9a69-05480489a38e/Fig6j_fourlevel.png)
Native pair: `plots/paper_ready/final_v3/fig6ij_fourlevel/fig/Fig6j.fig` and matching `png/Fig6j.png`.
Source: `results/paper_ready/final_v3/fig6ij_fourlevel/summary.mat`, `Fig6ij_network_values.csv` and `Fig6ij_summaries.csv`. Saved values are reused unchanged. Initial sweep (dashed) holds temporal=.10; temporal sweep (solid) holds initial=.10. The .10/.10 anchor is one shared dataset, not independent evidence in the two curves. Other amplitudes remain provenance only and are excluded from current paper-facing plots and inference.
Caption: within-network relative Block prediction deficit = 100\*(R²_Intact−R²_Block)/R²_Intact, summarized across networks only after forming each ratio. Frozen model, networks, eight targets × 30 trials, neuron scales, standardized stream identities and seeds are unchanged. Boundary-protected Gaussian SD30-ms rate smoothing; GO−100:10:0 and each trial’s kinematic MO+0:10:100; time-aligned condition-invariant subtraction; epoch-specific balanced-ensemble PCA≥75%; unchanged target-matched nested 3-fold ridge with 25 penalties. No post-GO noise. This update reran no simulations, preprocessing, PCA or prediction fits. All four displayed levels \[.05,.10,.15,.20\] enter each Friedman repeated-measures test, n=10 matched networks, df=3. Report raw chi-square-approximate p-values only; no BH across the four Fig. 6i/j omnibus tests and no post-hoc pairwise tests. Error bars are median ± SE of the median from the original fixed 10,000 whole-network bootstrap draws, copied exactly from saved results.
Manuscript-ready statistics — initial-state sweep: Friedman χ²(3)=3.2400000000000002, raw p=0.35608120810907057, n=10; all four displayed levels. Low→high (.05→.20): 9.91728 ± 1.51944% → 9.96493 ± 1.63955%.
Manuscript-ready statistics — temporal sweep: Friedman χ²(3)=21.359999999999996, raw p=0.000088621878277531137, n=10; all four displayed levels. Low→high (.05→.20): 6.46166 ± 2.18052% → 14.1247 ± 1.47315%.
Interpretation: the displayed temporal-deficit medians increase from 6.46166 ± 2.18052% at .05 through 9.27158 ± 1.78385% at .10 and 12.9120 ± 1.58780% at .15 to 14.1247 ± 1.47315% at .20. The initial-deficit medians are nonmonotonic. The initial-noise deficit omnibus test is nonsignificant, which does not establish equivalence. The Friedman test does not itself establish a directional trend, and individual-network monotonicity is not claimed.
Full-precision descriptive summaries (sweep 1=initial-state, 2=temporal):
<table fit-page-width="true" header-row="true">
<tr>
<td>Sweep</td>
<td>Noise</td>
<td>Median</td>
<td>Bootstrap SE</td>
</tr>
<tr>
<td>1</td>
<td>0.05</td>
<td>9.9172769087496775</td>
<td>1.5194394541529745</td>
</tr>
<tr>
<td>1</td>
<td>0.10</td>
<td>9.2715846871724388</td>
<td>1.7838513643810987</td>
</tr>
<tr>
<td>1</td>
<td>0.15</td>
<td>10.079421334179804</td>
<td>1.9967495605547554</td>
</tr>
<tr>
<td>1</td>
<td>0.20</td>
<td>9.9649308750730903</td>
<td>1.6395535122622</td>
</tr>
<tr>
<td>2</td>
<td>0.05</td>
<td>6.4616566327871103</td>
<td>2.1805158876975193</td>
</tr>
<tr>
<td>2</td>
<td>0.10</td>
<td>9.2715846871724388</td>
<td>1.7838513643810987</td>
</tr>
<tr>
<td>2</td>
<td>0.15</td>
<td>12.911967259266167</td>
<td>1.5878014544585972</td>
</tr>
<tr>
<td>2</td>
<td>0.20</td>
<td>14.124730605296985</td>
<td>1.4731548149556652</td>
</tr>
</table>
[Full-precision matched-network values](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/results/paper_ready/final_v3/fig6ij_fourlevel/Fig6ij_network_values.csv) · [Current four-level report](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/docs/paper_ready/final_v3/fig6ij_fourlevel/REPORT.md).
## Extended Data Fig. 7a — shared calibration grid
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/90af0562-bcf9-43dd-88e6-aa27fafcb636/ED7a.png)
Native pair: `plots/paper_ready/final_v3/fig/ED7a.fig` and `png/ED7a.png`.
Source: exact current Extended Data Fig. 5a native loss-map axes and `final_v2/geometry.mat` ensemble; no rerun. Loss=((median ΔPR−empirical ΔPR)/empirical ΔPR)\^2+((median alignment deficit−empirical deficit)/empirical deficit)\^2. One shared pair selected across all 10 networks from the fixed 6×6 grid. Only empirical ΔPR 2.6453333944000001 and expected−observed deficit 16.802184 pp entered calibration. Selected alpha=0.5, beta_norm=1.25,grid index 24,loss=0.050363119828606938. Selection was frozen before movement/noise/prediction outcomes; no network-specific fit, QC selection or reselection.
Manuscript-ready statistics: no inferential test; calibration disclosure only.
<table fit-page-width="true" header-row="true">
<tr>
<td>gridIndex</td>
<td>alpha</td>
<td>betaNormalized</td>
<td>deltaPR</td>
<td>deficitPP</td>
<td>loss</td>
</tr>
<tr>
<td>1</td>
<td>0.10000000000000001</td>
<td>0.10000000000000001</td>
<td>3.3756840790055316</td>
<td>2.5132557889861546</td>
<td>0.79944149483803961</td>
</tr>
<tr>
<td>2</td>
<td>0.10000000000000001</td>
<td>0.25</td>
<td>3.5141480065999211</td>
<td>17.834832877375458</td>
<td>0.11164542707279088</td>
</tr>
<tr>
<td>3</td>
<td>0.10000000000000001</td>
<td>0.5</td>
<td>3.4574613078833347</td>
<td>31.212063363399807</td>
<td>0.82976252774838211</td>
</tr>
<tr>
<td>4</td>
<td>0.10000000000000001</td>
<td>0.75</td>
<td>3.4076273176525871</td>
<td>35.482713305982379</td>
<td>1.3191202404820002</td>
</tr>
<tr>
<td>5</td>
<td>0.10000000000000001</td>
<td>1</td>
<td>3.3917594347551598</td>
<td>37.387899529403498</td>
<td>1.5806865970606674</td>
</tr>
<tr>
<td>6</td>
<td>0.10000000000000001</td>
<td>1.25</td>
<td>3.3888312032965637</td>
<td>38.361867480918036</td>
<td>1.7254627878924047</td>
</tr>
<tr>
<td>7</td>
<td>0.20000000000000001</td>
<td>0.10000000000000001</td>
<td>1.6769438745729404</td>
<td>-19.052831446601154</td>
<td>4.6877519628375888</td>
</tr>
<tr>
<td>8</td>
<td>0.20000000000000001</td>
<td>0.25</td>
<td>2.589671860887059</td>
<td>-3.7435204101871342</td>
<td>1.4956816805154021</td>
</tr>
<tr>
<td>9</td>
<td>0.20000000000000001</td>
<td>0.5</td>
<td>3.3033952383155891</td>
<td>15.919101705552713</td>
<td>0.06464547574645621</td>
</tr>
<tr>
<td>10</td>
<td>0.20000000000000001</td>
<td>0.75</td>
<td>3.3968839883894537</td>
<td>26.018709166433574</td>
<td>0.38160192783033237</td>
</tr>
<tr>
<td>11</td>
<td>0.20000000000000001</td>
<td>1</td>
<td>3.3916391726007058</td>
<td>31.246524267321522</td>
<td>0.81862581546662694</td>
</tr>
<tr>
<td>12</td>
<td>0.20000000000000001</td>
<td>1.25</td>
<td>3.3870613943597156</td>
<td>34.477005974460567</td>
<td>1.1851884979228628</td>
</tr>
<tr>
<td>13</td>
<td>0.34999999999999998</td>
<td>0.10000000000000001</td>
<td>0.51640776758189122</td>
<td>-30.803589673909304</td>
<td>8.6753175429123175</td>
</tr>
<tr>
<td>14</td>
<td>0.34999999999999998</td>
<td>0.25</td>
<td>1.199195993477012</td>
<td>-19.577817321409377</td>
<td>4.9869219546807004</td>
</tr>
<tr>
<td>15</td>
<td>0.34999999999999998</td>
<td>0.5</td>
<td>2.4245434266244779</td>
<td>-1.4979280574026588</td>
<td>1.1932156842856634</td>
</tr>
<tr>
<td>16</td>
<td>0.34999999999999998</td>
<td>0.75</td>
<td>3.0945580522582423</td>
<td>11.413030706440264</td>
<td>0.1317130217447971</td>
</tr>
<tr>
<td>17</td>
<td>0.34999999999999998</td>
<td>1</td>
<td>3.3400122710135371</td>
<td>19.93627023272991</td>
<td>0.10375448705804155</td>
</tr>
<tr>
<td>18</td>
<td>0.34999999999999998</td>
<td>1.25</td>
<td>3.3871354081241662</td>
<td>25.432285621230733</td>
<td>0.34245039588474546</td>
</tr>
<tr>
<td>19</td>
<td>0.5</td>
<td>0.10000000000000001</td>
<td>0.13391331918893012</td>
<td>-34.367575146178574</td>
<td>10.175919496193625</td>
</tr>
<tr>
<td>20</td>
<td>0.5</td>
<td>0.25</td>
<td>0.57969369825959505</td>
<td>-26.428887456286709</td>
<td>7.2297837587115419</td>
</tr>
<tr>
<td>21</td>
<td>0.5</td>
<td>0.5</td>
<td>1.5945644891856905</td>
<td>-11.976961016353771</td>
<td>3.0915387027916306</td>
</tr>
<tr>
<td>22</td>
<td>0.5</td>
<td>0.75</td>
<td>2.4181940869258653</td>
<td>-0.051649404688705602</td>
<td>1.0135300412322876</td>
</tr>
<tr>
<td>23</td>
<td>0.5</td>
<td>1</td>
<td>2.9457303767758987</td>
<td>9.392704474087715</td>
<td>0.20736137819237835</td>
</tr>
<tr>
<td>24</td>
<td>0.5</td>
<td>1.25</td>
<td>3.2357604186198508</td>
<td>16.409285208138037</td>
<td>0.050363119828606938</td>
</tr>
<tr>
<td>25</td>
<td>0.75</td>
<td>0.10000000000000001</td>
<td>-0.09148227737128356</td>
<td>-37.164161063551575</td>
<td>11.386437124440656</td>
</tr>
<tr>
<td>26</td>
<td>0.75</td>
<td>0.25</td>
<td>0.14639438109220193</td>
<td>-32.10739666731552</td>
<td>9.3657559399519563</td>
</tr>
<tr>
<td>27</td>
<td>0.75</td>
<td>0.5</td>
<td>0.80338145201828226</td>
<td>-22.136206931289003</td>
<td>5.8554582990732271</td>
</tr>
<tr>
<td>28</td>
<td>0.75</td>
<td>0.75</td>
<td>1.5455956206376313</td>
<td>-12.330763563292997</td>
<td>3.1791643937311957</td>
</tr>
<tr>
<td>29</td>
<td>0.75</td>
<td>1</td>
<td>2.1618191744430995</td>
<td>-3.6078607438233794</td>
<td>1.5089670831192821</td>
</tr>
<tr>
<td>30</td>
<td>0.75</td>
<td>1.25</td>
<td>2.6451078270622705</td>
<td>4.0050609470661822</td>
<td>0.58008712277638985</td>
</tr>
<tr>
<td>31</td>
<td>1</td>
<td>0.10000000000000001</td>
<td>-0.087983479049910995</td>
<td>-38.286264535447422</td>
<td>11.817159305627639</td>
</tr>
<tr>
<td>32</td>
<td>1</td>
<td>0.25</td>
<td>0.041476782712290605</td>
<td>-35.324195509387167</td>
<td>10.593508688909539</td>
</tr>
<tr>
<td>33</td>
<td>1</td>
<td>0.5</td>
<td>0.42317561135079074</td>
<td>-26.616554729987065</td>
<td>7.3832883261137816</td>
</tr>
<tr>
<td>34</td>
<td>1</td>
<td>0.75</td>
<td>0.96193095677202289</td>
<td>-18.238466863893319</td>
<td>4.7541975653250947</td>
</tr>
<tr>
<td>35</td>
<td>1</td>
<td>1</td>
<td>1.5165920029864315</td>
<td>-10.947069751744483</td>
<td>2.909605772282049</td>
</tr>
<tr>
<td>36</td>
<td>1</td>
<td>1.25</td>
<td>2.0183414601334047</td>
<td>-4.4310674551063522</td>
<td>1.6531651468479722</td>
</tr>
</table>
## Extended Data Fig. 7b — component-removal prediction
![](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/183ff665-7089-4ffe-bf0f-81c5e3dfd522/ED7b.png)
Native pair: `plots/paper_ready/final_v3/fig/ED7b.fig` and `png/ED7b.png`.
Source: exactly .20/.20 new matched-noise trajectories and the unchanged final PCA75→ridge pipeline, all 10 networks and 240 trials/policy. Intact (b+L), −L (b only), −b (L only), Block (−b,−L), all with common base and eta0. Thin paired network connectors, individual values and median ± bootstrap SE. No alternative stress point, excluded trial/network, prediction-driven selection or RRR.
<table fit-page-width="true" header-row="true">
<tr>
<td>policy (1=Intact,2=b only,3=L only,4=Block)</td>
<td>R2 median</td>
<td>bootstrapSE</td>
</tr>
<tr>
<td>1</td>
<td>0.73355966811454643</td>
<td>0.0054865551791814689</td>
</tr>
<tr>
<td>2</td>
<td>0.70947655536491672</td>
<td>0.0072478995047690542</td>
</tr>
<tr>
<td>3</td>
<td>0.77262490262388361</td>
<td>0.005184560550353122</td>
</tr>
<tr>
<td>4</td>
<td>0.62737692519395216</td>
<td>0.0084965204803371351</td>
</tr>
</table>
Manuscript-ready statistics — -L (b only): median paired effect -0.0157582 ± 0.00491159, n=10; two-sided paired t-test, t(9)=-5.4614390426854174, raw p=0.00039967833698102191; BH q=0.00039967833698102191 (3-test family). Anderson–Darling h=0 (normality not rejected), AD p=0.74406165341849784, A²=0.23825700882047762, critical=0.68574700000000000 at alpha=0.05. Paired ΔR² is condition minus Intact; descriptive values unchanged.
<table fit-page-width="true" header-row="true">
<tr>
<td>median paired effect</td>
<td>bootstrapSE</td>
<td>rawP</td>
<td>BHq</td>
<td>significant q\<.05</td>
</tr>
<tr>
<td>-0.015758179219899304</td>
<td>0.0049115859571122024</td>
<td>0.00039967833698102191</td>
<td>0.00039967833698102191</td>
<td>1</td>
</tr>
</table>
Manuscript-ready statistics — -b (L only): median paired effect 0.0400258 ± 0.00597259, n=10; two-sided paired t-test, t(9)=7.6443762373194923, raw p=0.000031771222378114002; BH q=0.000047656833567171003 (3-test family). Anderson–Darling h=0 (normality not rejected), AD p=0.32499875105580456, A²=0.39089211152848158, critical=0.68574700000000000 at alpha=0.05. Paired ΔR² is condition minus Intact; descriptive values unchanged.
<table fit-page-width="true" header-row="true">
<tr>
<td>median paired effect</td>
<td>bootstrapSE</td>
<td>rawP</td>
<td>BHq</td>
<td>significant q\<.05</td>
</tr>
<tr>
<td>0.040025801956761253</td>
<td>0.0059725859638296245</td>
<td>0.000031771222378114002</td>
<td>0.000047656833567171003</td>
<td>1</td>
</tr>
</table>
Manuscript-ready statistics — Block (-b,-L): median paired effect -0.111963 ± 0.0120011, n=10; two-sided paired t-test, t(9)=-12.873452330535788, raw p=4.2230383030285037e-7; BH q=0.0000012669114909085511 (3-test family). Anderson–Darling h=0 (normality not rejected), AD p=0.46227027370388662, A²=0.33097407754075903, critical=0.68574700000000000 at alpha=0.05. Paired ΔR² is condition minus Intact; descriptive values unchanged.
<table fit-page-width="true" header-row="true">
<tr>
<td>median paired effect</td>
<td>bootstrapSE</td>
<td>rawP</td>
<td>BHq</td>
<td>significant q\<.05</td>
</tr>
<tr>
<td>-0.1119632323212697</td>
<td>0.012001078868776256</td>
<td>4.2230383030285037e-7</td>
<td>0.0000012669114909085511</td>
<td>1</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>network</td>
<td>IntactR2</td>
<td>bOnlyR2</td>
<td>LOnlyR2</td>
<td>BlockR2</td>
<td>delta_bOnly</td>
<td>delta_LOnly</td>
<td>delta_Block</td>
</tr>
<tr>
<td>1</td>
<td>0.73132960651878398</td>
<td>0.72756503399311412</td>
<td>0.7827823678851924</td>
<td>0.63745307300832332</td>
<td>-0.0037645725256698626</td>
<td>0.051452761366408417</td>
<td>-0.093876533510460658</td>
</tr>
<tr>
<td>2</td>
<td>0.70825674746539347</td>
<td>0.69531021815642102</td>
<td>0.77023879652641858</td>
<td>0.62713790661615754</td>
<td>-0.012946529308972443</td>
<td>0.061982049061025113</td>
<td>-0.081118840849235929</td>
</tr>
<tr>
<td>3</td>
<td>0.74004780251917524</td>
<td>0.71548485613084689</td>
<td>0.78087812742165785</td>
<td>0.59197441665906503</td>
<td>-0.024562946388328344</td>
<td>0.040830324902482618</td>
<td>-0.14807338586011021</td>
</tr>
<tr>
<td>4</td>
<td>0.75476068238542893</td>
<td>0.74732907619959821</td>
<td>0.75894699746070515</td>
<td>0.60458418012159387</td>
<td>-0.0074316061858307192</td>
<td>0.0041863150752762257</td>
<td>-0.15017650226383505</td>
</tr>
<tr>
<td>5</td>
<td>0.73657115497857295</td>
<td>0.70113591767773831</td>
<td>0.76685903300018787</td>
<td>0.62761594377174679</td>
<td>-0.035435237300834643</td>
<td>0.030287878021614922</td>
<td>-0.10895521120682616</td>
</tr>
<tr>
<td>6</td>
<td>0.73578972971030876</td>
<td>0.70997840177405536</td>
<td>0.77501100872134865</td>
<td>0.61909224145910757</td>
<td>-0.025811327936253403</td>
<td>0.039221279011039889</td>
<td>-0.11669748825120119</td>
</tr>
<tr>
<td>7</td>
<td>0.7282339243097713</td>
<td>0.7004572685532211</td>
<td>0.76611943681169936</td>
<td>0.64926320084872247</td>
<td>-0.027776655756550195</td>
<td>0.037885512501928065</td>
<td>-0.078970723461048831</td>
</tr>
<tr>
<td>8</td>
<td>0.72378411767451889</td>
<td>0.70897470895577797</td>
<td>0.7799538707439887</td>
<td>0.64757535887436068</td>
<td>-0.014809408718740924</td>
<td>0.056169753069469808</td>
<td>-0.076208758800158205</td>
</tr>
<tr>
<td>9</td>
<td>0.75176502899013808</td>
<td>0.7350580792690804</td>
<td>0.8159208357138783</td>
<td>0.63009843148032441</td>
<td>-0.016706949721057684</td>
<td>0.064155806723740216</td>
<td>-0.12166659750981368</td>
</tr>
<tr>
<td>10</td>
<td>0.70180525700008234</td>
<td>0.69358169442751982</td>
<td>0.74058761229316494</td>
<td>0.5868340035643691</td>
<td>-0.008223562572562515</td>
<td>0.038782355293082604</td>
<td>-0.11497125343571324</td>
</tr>
</table>
Outcome: -L (b only): significant reduction (raw p=0.00039967833698102191, BH q=0.00039967833698102191); -b (L only): significant increase (raw p=0.000031771222378114002, BH q=0.000047656833567171003); Block (-b,-L): significant reduction (raw p=4.2230383030285037e-7, BH q=0.0000012669114909085511). Removing L alone significantly lowers prediction; removing b alone significantly raises it. Full Block also lowers prediction. A deficit therefore does not require full Block at this fixed .20/.20 setting. No manuscript edit or model tuning performed.
Interpretive limit: a nonsignificant contrast is not an equivalence result. This fixed stress-point comparison does not establish anatomical necessity or identify separable anatomical pathways. No result was used to select noise, geometry or another policy.
All stress-test QC flags remain retained without exclusions: [full source and QC tables](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/tree/main/results/paper_ready/final_v3).
## Final copy/paste manuscript placeholder table
<table fit-page-width="true" header-row="true">
<tr>
<td>Panel</td>
<td>Copy/paste values (median ± bootstrap SE; full precision above)</td>
</tr>
<tr>
<td>6a</td>
<td>FF-only ΔPR -0.210124 ± 0.0824815; paired t-test versus lambda=0.1, n=10, p=0.00093949903536209823; q=0.0075159922828967858 (8-test BH family); AD h=0, AD p=0.088188387608298474.</td>
</tr>
<tr>
<td>6b</td>
<td>FF-only deficit -14.0722 ± 1.74431 pp; paired t-test versus lambda=0.1, n=10, p=6.0076320676610320e-10; q=4.8061056541288256e-9 (8-test BH family); AD h=0, AD p=0.57399641683549474. Displayed deficit unchanged; inference tests its change from reference, not deficit versus zero.</td>
</tr>
<tr>
<td>6d</td>
<td>ΔPR 3.23576 ± 0.120591; two-sided paired t-test, n=10, t(9)=27.341305543645070, raw p=5.6785006637083963e-10. Anderson–Darling h=0 (normality not rejected), AD p=0.90678379198686387. No multiple-comparison correction; empirical target 2.645333394</td>
</tr>
<tr>
<td>6e</td>
<td>Deficit 16.4093 ± 1.36338 pp; two-sided paired t-test, n=10, t(9)=14.560443948422693, raw p=1.4602014523393009e-7. Anderson–Darling h=0 (normality not rejected), AD p=0.73141328433755393. No multiple-comparison correction; empirical target 16.802184 pp</td>
</tr>
<tr>
<td>6g</td>
<td>Intact 0.420266 ± 0.00095732, Block 0.293346 ± 0.011121 m/s; reduction 29.6207 ± 2.50309%; two-sided paired t-test, n=10, t(9)=-18.944070455588200, raw p=1.4641906487214610e-8. Anderson–Darling h=0 (normality not rejected), AD p=0.63262125699845573. No multiple-comparison correction.</td>
</tr>
<tr>
<td>6h</td>
<td>Intact 0.552672 ± 0.027319, Block 2.684 ± 0.331609 cm; increase 395.374 ± 63.0306%; two-sided Wilcoxon signed-rank, n=6, W_plus=21, raw p=0.031250000000000000. Anderson–Darling h=1 (normality rejected), AD p=0.021789232569363721. No multiple-comparison correction. Eligible IDs 1,2,3,6,7,10; W_plus uses Block−Intact.</td>
</tr>
<tr>
<td>6i</td>
<td>Initial-state \[.05,.10,.15,.20\]: 0.931591 ± 0.00459871; 0.924246 ± 0.00654561; 0.918854 ± 0.00570452; 0.908298 ± 0.00585766; Friedman χ²(3)=26.519999999999996, raw p=0.0000074219609234451472, n=10 / Temporal \[.05,.10,.15,.20\]: 0.989355 ± 0.00200299; 0.924246 ± 0.00654561; 0.813409 ± 0.00363846; 0.735961 ± 0.00388889; Friedman χ²(3)=30.000000000000000, raw p=0.0000013800570312932536, n=10. No BH or post-hoc tests. Both four-point Intact median curves decrease.</td>
</tr>
<tr>
<td>6j</td>
<td>Initial-state \[.05,.10,.15,.20\]: 9.91728 ± 1.51944; 9.27158 ± 1.78385; 10.0794 ± 1.99675; 9.96493 ± 1.63955 (%); Friedman χ²(3)=3.2400000000000002, raw p=0.35608120810907057, n=10 / Temporal \[.05,.10,.15,.20\]: 6.46166 ± 2.18052; 9.27158 ± 1.78385; 12.9120 ± 1.58780; 14.1247 ± 1.47315 (%); Friedman χ²(3)=21.359999999999996, raw p=0.000088621878277531137, n=10. No BH or post-hoc tests. Temporal-deficit medians increase across the four displayed points; initial-deficit medians are nonmonotonic. No directional trend test was performed.</td>
</tr>
<tr>
<td>ED7b</td>
<td>Intact (b+L) R2 0.73356 ± 0.00548656; -L (b only) R2 0.709477 ± 0.0072479; -b (L only) R2 0.772625 ± 0.00518456; Block (-b,-L) R2 0.627377 ± 0.00849652; -L (b only) minus Intact ΔR2 -0.0157582 ± 0.00491159; two-sided paired t(9)=-5.4614390426854174; AD h=0, AD p=0.74406165341849784; raw p=0.00039967833698102191; BH q=0.00039967833698102191; -b (L only) minus Intact ΔR2 0.0400258 ± 0.00597259; two-sided paired t(9)=7.6443762373194923; AD h=0, AD p=0.32499875105580456; raw p=0.000031771222378114002; BH q=0.000047656833567171003; Block (-b,-L) minus Intact ΔR2 -0.111963 ± 0.0120011; two-sided paired t(9)=-12.873452330535788; AD h=0, AD p=0.46227027370388662; raw p=4.2230383030285037e-7; BH q=0.0000012669114909085511. All contrasts use n=10; BH family of three. -L (b only): significant reduction (raw p=0.00039967833698102191, BH q=0.00039967833698102191); -b (L only): significant increase (raw p=0.000031771222378114002, BH q=0.000047656833567171003); Block (-b,-L): significant reduction (raw p=4.2230383030285037e-7, BH q=0.0000012669114909085511). Removing L alone significantly lowers prediction; removing b alone significantly raises it. Full Block also lowers prediction. A deficit therefore does not require full Block at this fixed .20/.20 setting. No manuscript edit or model tuning performed.</td>
</tr>
</table>
## Current sources and validation
<file src="https://prod-files-secure.s3.us-west-2.amazonaws.com/f9326c94-be30-81f8-aee2-000380dda06e/556a8e24-3735-44f8-9ebb-40a4bd87adff/Current_manuscript_source_tables_REVIEW.zip"></file>
Current37-file review source bundle: unchanged manuscript quantitative tables, f sources and all-attempt ledger, unchanged task15 g sources, and new h target6 sources/candidate diagnostics/selection/validation/report/caption. Prior h target1 and prior g all30-median displays remain historical, not current.
Current h report/caption: `docs/paper_ready/final_v3/fig6h_diffuse16/REPORT.md` and `LEGENDS.md`, included in the ZIP. Current h native pair is local under `plots/paper_ready/final_v3/fig6h_diffuse16/`. g remains `fig6gh_tweak15/`; f remains `fig6fgh_highrms14/`.
Independent events/pathRMS/peak positions/all30 distances/histogram/source-object checks PASS; custom candidate gap calculations independently checked using a separate graph implementation. New h reopened and visually inspected; existing g reopened read-only. Four new MATLAB files pass Code Analyzer. All manuscript statistics, placeholder values and unrelated images remain unchanged. No simulation, scientific inference, broad cleanup or dependency deletion.
Latest committed checkpoint remains **04cd2b2a0be5b9b8fa2d57791d46e9f951e6b4f0**; [task14 report and prior h provenance](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/04cd2b2a0be5b9b8fa2d57791d46e9f951e6b4f0/docs/paper_ready/final_v3/fig6fgh_highrms14/REPORT.md). Tasks15/16 remain **uncommitted for review**, with no staging or push. All prior raw dependencies, failures and untracked work remain preserved.
## Archive / superseded checkpoints
Historical provenance only, not current display-selection instructions:
- [Previous low-RMS saved-success display,20ad6be](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/20ad6be8c52f8a88693fb07807aed259d8db3fdf/docs/paper_ready/final_v3/fig6fgh_final13/REPORT.md).
- [Completed dependency-aware bulk cleanup,54c965d](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/54c965d8083dd51b30b4b67894d2a5ec6a62e439/docs/paper_ready/final_v3/fig6fgh_cleanup09/REPORT.md).
- [Historical v3 reports/statistical revisions](https://github.com/NirvikNU/cerebellar-preparatory-dynamics-model/blob/main/docs/paper_ready/final_v3/) retain prior figures, seven/five-level i/j and superseded inference. All underlying files remain preserved.
