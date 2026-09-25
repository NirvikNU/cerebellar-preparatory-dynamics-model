# Notion authority snapshot — 25 September 2026

Source: https://www.notion.so/3c826c94be30817d8f51d9f6c8c2bc19
The top v2 task supersedes the following release-only science freeze; its packaging rules are incorporated only after v2 validation.

<callout icon="📊" color="green_bg">
	**AUTHORIZED — PAPER-MODELLING-FINAL-FIGURES-V2-01.** This supersedes the pending final-release-only instruction. Build the final manuscript-facing modelling set around the parsimonious **eta=0** model. Recalibrate only the explicitly constructed preparatory geometry with one shared alpha/beta pair, freeze it before evaluating movement/convergence/prediction, publish the validated v2 figures on page 04, then perform the final conservative repository cleanup/release and push. Preserve all prior validated results and archive.
</callout>
## Current task — PAPER-MODELLING-FINAL-FIGURES-V2-01
### Scientific model to present
The final paper-facing model uses **eta=0**, with no added generic residual kappa0 feedback. Preserve the completed eta sweep as supporting provenance rather than deleting it.
At eta=0:
- common/base preparatory input: `u_base = -f(xB)`;
- cerebellar-dependent state-setting term: `b = f(xB)-f(x*)`;
- Intact additionally includes structured prospective feedback `-L(x-x*)`;
- full Block removes both cerebellar-dependent terms and retains only the base input.
Present this as an effective functional decomposition into **state setting + prospective stabilization**, not an anatomical claim.
Keep lambda=10 and the frozen Stage-1 movement/readout/arm assets unchanged. The primary displayed noise setting is fixed at `s_init=0.10`, `s_temporal=0.10`; do not choose another noise point because it gives a larger downstream effect.
### Structural calibration — one shared global alpha/beta
Use the existing fixed grid:
- `alpha=[0.10,0.20,0.35,0.50,0.75,1.00]`
- `beta_norm=[0.10,0.25,0.50,0.75,1.00,1.25]`
- V realization 1, lambda=10, eta=0, primary noise 0.10/0.10.
Select **one shared (alpha,beta_norm) pair for all ten networks**. Do not fit alpha/beta independently per network.
The calibration objective may use only the two experimentally observed preparatory-geometry effects already used as construction targets:
- `DeltaPR_data=2.6453333944`
- `Dalign_data=16.802184` percentage points.
For each grid point compute network-median paired `DeltaPR_model` and expected-minus-observed alignment deficit using the corrected Control-derived \>=95% K rule. Select the grid point minimizing:
`Lgeom=((DeltaPR_model-DeltaPR_data)/DeltaPR_data)^2 + ((Dalign_model-Dalign_data)/Dalign_data)^2`.
If an exact tie occurs, stop and report before inventing a tie-breaker. Movement, peak speed, endpoint variability, convergence, R2, noise sensitivity and QC must not enter calibration. Once selected, freeze the shared pair before downstream analyses. Retain the full 6×6 maps and selected-point receipt.
### Convergence — corrected pre-cue definition
Replace the prior post-cue cue-window baseline in the final v2 convergence assay.
**Do not simulate an artificial 100-ms pre-cue period.** Use the existing single trial state immediately before cue/controller onset.
For each stochastic trial define the pre-cue state as `x_precue=x_sp+s_init*z_init`, using the exact existing standardized trial-specific initial draw. Interpret this offset as spontaneous-state variability present immediately before cue onset. The same state then evolves continuously when cue-dependent inputs/controller turn on. Do not reseed or add another noise source.
“Single/static pre-cue state” means one time sample per trial, not that all trials are identical. If deterministic `x_sp` alone were used for every trial, the held-out pre-cue distance would be zero and the ratio undefined.
Use the existing reference-only held-out logic:
- same three target-stratified folds, 20 same-target reference trials / 10 held-out;
- fit reference-only preparatory PCA using the existing normalized unsmoothed preparation trajectories and retain minimum \>=95% reference variance;
- project the held-out trial's **single pre-cue sample** and pre-go activity into that reference-derived space;
- reference pre-cue state = mean projected single pre-cue state of the 20 reference trials;
- `d_precue` = held-out projected single pre-cue distance from that reference mean;
- reference and held-out pre-go states = unchanged GO−100:10:0-ms window means;
- `C=1-d_prego/d_precue`;
- preserve trial→fold→target→network aggregation and the denominator guard.
**No sample after cue onset may contribute to ****`d_precue`**** or the pre-cue reference state.** PCA estimation may still use the reference preparation trajectory; the prohibition concerns the baseline state/distance itself. Use this corrected definition everywhere in final v2, including primary, noise-sensitivity and component analyses. Retain raw `d_precue`, `d_prego`, ratios, K/capture and undefined counts.
### Final main modelling figure — v2
Create one native editable MATLAB FIG plus matching PNG, with full source tables and paper-ready legend. Network n=10 is the model independent unit; use the frozen whole-network bootstrap for median±SE.
**A — Prospective-feedback restriction alone: dimensionality.** Reuse/re-render the validated controller-effort analysis showing that changing prospective feedback strength alone does not reproduce the empirical PR increase. Include the empirical geometry target as a labeled reference.
**B — Prospective-feedback restriction alone: orientation.** Companion alignment/alignment-deficit panel showing that prospective-feedback restriction alone does not reproduce the below-null reorientation.
**C — Final parsimonious model schematic.** Show base preparatory dynamics plus cerebellar-dependent state-setting `b` and structured prospective feedback `L`; full Block removes the two cerebellar-dependent components. Do not show generic kappa0 feedback in the final schematic.
**D — Representative hand trajectories.** Use predeclared network 1; do not reselect after viewing outcomes. Show all eight targets with established target colors, Intact and Block in matched subaxes. Draw target zones as low-alpha filled circles of **1.5-cm radius**. Show single trials thin/low-alpha and target means thick. For display only, terminate each plotted trajectory at first entry into the 1.5-cm target zone; if never entered, show through 600 ms. This truncation must not alter any analysis/event/prediction arrays.
**E — Hand-position dispersion at peak speed.** Replicate the manuscript behavioral dispersion definition as closely as the model permits. Show paired Intact/Block network values, thin connectors, low-alpha points, median±bootstrap SE. Compute the paired p-value at network level using the same normality/test-decision rule used in the paper; report exact test and n. No trial-level pseudoreplication.
**F — Hand-speed phenotype.** Left: network 1, fixed target 2, all trial speed profiles thin/low-alpha with thick median Intact/Block traces using the paper condition colors and manuscript visualization smoothing convention. Right: paired network summary of peak speed using the same presentation/statistical rule as E.
**G — Preparatory PR: experiment versus model.** Experimental side: Control↔Block pooled empirical estimates with the uncertainty representation actually used in the manuscript/source analysis; do not plot resamples as independent biological observations. Model side: Intact↔Block paired values for ten networks with median±network-bootstrap SE. Label explicitly **geometry calibration target**. The shared alpha/beta is selected using DeltaPR, so model-vs-data proximity is not independent validation.
**H — Preparatory alignment: experiment versus model.** Experimental observed↔expected alignment and model observed↔expected alignment across ten networks using corrected Control95. Report expected−observed deficits in source table/caption. Label explicitly as the second **geometry calibration target**.
**I — Block prediction deficit versus preparation noise.** Final eta=0 model only. x=0.05/0.10/0.20. Plot two black traces: temporal-noise sweep with s_init=0.10 and initial-noise sweep with s_temporal=0.10, one solid and one dashed. y-axis: **Relative reduction in prep→movement R² under Block (%)**, computed within network. Mark 0.10 as primary. Use exact manuscript-matched PCA75→nested-ridge pipeline; no empirical target band and no favorable-noise selection.
**J — Block convergence deficit versus preparation noise.** Same x/trace conventions. y-axis: **Block − Intact convergence score (DeltaC)**, not percent. Use corrected single-sample pre-cue definition and a zero reference line.
### Extended Data / Supplementary v2 set
Publish these under <mention-page url="https://app.notion.com/p/3e626c94be3081db8f7de5e867480800"/>. Preserve page 02 and archive as provenance; do not overwrite/delete old figures.
**Extended Data Fig. 1 — Effect of preparation noise in the intact model.**
Two panels, eta=0 only:
- A: absolute Intact prep→movement R² versus noise amplitude;
- B: absolute Intact convergence C versus noise amplitude.
In each, plot initial-noise and temporal-noise sweeps in the Intact/control sky-blue color, one solid and one dashed trace, with network median±SE and individual network values/lines where legible. This shows that noise itself, especially ongoing temporal noise, can affect prediction/convergence; Main I/J show the larger Block vulnerability.
**Extended Data Fig. 2 — Functional contributions of state setting and prospective feedback.**
At primary noise 0.10/0.10 and final shared alpha/beta, eta=0, evaluate the four existing policies with identical draws:
- Intact = base + b + prospective feedback;
- state-setting only = base + b;
- prospective-feedback only = base + prospective feedback;
- full Block = base.
Show compact panels for PR, corrected alignment/deficit, corrected convergence C and prep→movement R². No component is fit to these downstream outcomes.
**Extended Data Fig. 3 — Controller effort/readiness provenance.**
Reuse or exactly regenerate the validated controller-effort/lambda sweep underlying lambda=10 and the \~75-ms prospective-readiness time. Show readiness metric definition, controller-effort/gain axis and mark lambda=10. Do not reselect lambda from the new outcomes. If the old plot is not numerically compatible with eta=0, regenerate only the bounded provenance sweep with final parameters frozen and document the difference.
**Extended Data Fig. 4 — Movement/event QC.**
Compact final-model QC including endpoint dispersion, target separation/scatter, near-zero/missing-window counts, boundary peaks and multiple-large-peak counts; include primary noise and prespecified noise extremes used in I/J. Keep all flagged trials.
**Extended Data Fig. 5 — Structural calibration and analysis controls.**
Include the full 6×6 alpha/beta geometry-calibration loss/effect maps with selected shared point, corrected Control95 PC-rule/K provenance, and primary prediction matched-PC/shuffle controls. Make explicit what was fit versus predicted.
**Supplementary/repository-only retained diagnostics.**
Preserve the full eta sweep, RRR, historical controller variants, target-resolved kinematics and prior negative/mixed diagnostics in the repository/Notion archive. Do not promote RRR into the final v2 figure set unless explicitly requested later.
### Statistics and source data
Every quantitative panel must state independent unit, n, summary statistic, uncertainty and test where inference is appropriate.
- Model unit: network, n=10.
- Main E/F paired behavioral tests: use the manuscript's paired-session test-selection logic at the network level and report exact test/p.
- G/H are calibration targets: show uncertainty/source values but do not imply calibrated agreement is inferential validation.
- I/J and ED1 are prespecified sensitivity curves; show network-level uncertainty/all points without creating a new post-hoc multiple-p family.
- ED2 may reuse an already predeclared exact paired/sign-flip family only if hypotheses/correction are unchanged; otherwise report descriptive paired effects and uncertainty.
All panels need full-precision CSV/MAT source data and paper-ready legends.
### File organization
Create dedicated final-v2 roots without overwriting prior outputs:
- `analysis/paper_ready/final_v2/`
- `figures/paper_ready/final_v2/`
- `results/paper_ready/final_v2/`
- `docs/paper_ready/final_v2/`
- `artifacts/manifests/paper_ready/final_v2/`
- ignored raw/replay evidence only under `results/paper_ready/cache/final_v2/`.
Organize plot outputs by figure identity:
- `plots/paper_ready/final_v2/main/{fig,png}/MainFig_Modelling_v2.*`
- `plots/paper_ready/final_v2/ED1_noise_intact/{fig,png}/...`
- `ED2_components`, `ED3_readiness`, `ED4_movement_qc`, `ED5_calibration_controls`.
Map all panel-level source tables and legends explicitly to A–J / ED panels.
### Validation, Notion v2 page, cleanup and final release
Before evaluating downstream outcomes, lock/save the geometry-calibration plan and selected shared alpha/beta receipt. Independently audit:
- eta=0 equations and absence of generic kappa feedback;
- selected alpha/beta grid loss and no downstream leakage into calibration;
- standardized noise draw reuse;
- corrected single-sample pre-cue convergence and zero post-cue leakage into d_precue;
- behavioral event/dispersion/peak-speed definitions;
- PCA75 ridge folds/penalties/R²;
- Control95 PR/alignment;
- network/bootstrap/statistics/source tables;
- trajectory display-only truncation versus unchanged analysis arrays;
- FIG source objects and PNG visual integrity.
Publish the final validated figures, legends, methods/results notes, calibration disclosure, statistics and source paths on page 04. Keep pages 01–03 and 99 as supporting provenance. Update START HERE/Handoff/Agent Log compactly.
After scientific/graphics validation succeeds, perform the conservative publication cleanup from the superseded final-release task:
- retain durable code, compact results/source tables, docs, FIG/PNG figures and manifests;
- keep large raw caches ignored/local;
- delete only proven disposable/duplicate files with an inventory;
- update root README and `docs/paper_ready/PAPER_CODE_INDEX.md` so a reviewer can navigate final v2 and sees any non-versioned raw-input limitations;
- preserve all historical negative/mixed results.
Create **one normal final commit** containing final-v2 plus the completed uncommitted noise-sensitivity work and paper-facing cleanup. Suggested subject:
`Finalize parsimonious paper modelling figures and code`.
Push `v3-romano-hennequin` normally. Then, only if `main` is non-divergent and expected-old-SHA guard passes, safely fast-forward/push `main` to the same SHA. No merge/rebase/reset/force/history rewrite. Verify local/tracking/direct-remote v3 and main, clean tracked worktree/index, no durable untracked files, only intentional ignored caches, and no Git locks.
**STOP after final-v2 validation, Notion publication, cleanup, commit/push and verified ref synchronization. Do not add another model mechanism, parameter search, noise fit or figure family without new authorization.**
<callout icon="🚀" color="green_bg">
	**AUTHORIZED — PAPER-MODELLING-FINAL-RELEASE-01.** Final repository cleanup and paper-facing release only. The scientific modelling work is frozen: do not rerun simulations, fit/select eta or noise, alter model parameters, regenerate scientific results, add new analyses, or reinterpret outcomes. Preserve all validated positive, negative and mixed results. Package the completed modelling work into a clean, reviewer-readable GitHub repository, commit the final noise-sensitivity work, synchronize the release to `main` safely, and STOP.
</callout>
## Current task — PAPER-MODELLING-FINAL-RELEASE-01
### Starting point and scientific freeze
Start from the current verified repository state whose last pushed release is `93e9d517d47b48579ef9d5bda6adacc44bf039d7`. The completed **PAPER-MODELLING-NOISE-SENSITIVITY-01** outputs are numerically validated but remain uncommitted. The modelling scientific state is now frozen for manuscript writing.
No new simulation, RRR, decoder, parameter sweep, noise/eta choice, optimization, model-data fitting, figure-value change, or scientific conclusion is authorized. Exact packaging/path/link repairs are allowed; if any repair would change a numerical scientific output, STOP and report instead.
### 1. Conservative project-folder cleanup
Inventory the full repository before changing files. Classify all current new/untracked/ignored files, especially the completed `paper_ready/noise_sensitivity` bundle.
Retain and prepare for commit:
- durable MATLAB source/helpers/renderers required for the final paper modelling analyses;
- compact full-precision source/result tables and summary MAT/JSON files that are reasonable for Git;
- validated FIG + matching PNG paper/reviewer figures;
- locked plans, methods/captions/reports/data dictionaries/completion reports;
- audit/manifests/receipts needed to trace the published outputs;
- current paper-ready navigation and release documentation.
Keep local/ignored, never stage:
- large raw stochastic trajectory caches and replay caches;
- machine-specific scratch/checkpoint/worker files;
- any large input asset already intentionally excluded from Git.
Delete only proven disposable files: zero-byte logs, temporary autosaves, failed-run fragments, and byte-identical duplicates that have a retained canonical copy. Record every deletion/move in a final cleanup inventory with reason and retained replacement. Do not delete negative/mixed results, QC flags, historical provenance, source tables, or any evidence required to understand a published figure.
Do not alter accepted historical Stage-1/2/3, alignment95, prediction/RRR, stabilization-eta, or prior release science.
### 2. Make the repository paper-facing
The GitHub repository should be understandable to a reviewer landing on `main`.
Inspect the current root `README.md`, `AGENTS.md`, and current paper-ready navigation. If the root README still foregrounds obsolete development-stage material, update it so the **current paper modelling release** is the first thing a reader sees, while linking legacy/development history rather than deleting it.
Create or refresh a concise paper-facing code index, preferably:
`docs/paper_ready/PAPER_CODE_INDEX.md`
It should map, without changing nomenclature:
- the current effective model/controller equations and frozen paper parameters;
- corrected preparatory geometry/alignment analysis;
- PCA→ridge prediction and matched-PC/shuffle controls;
- RRR secondary analysis;
- residual-stabilization eta diagnostic;
- final initial/temporal preparation-noise sensitivity;
- movement/QC analyses;
- figure renderers and corresponding committed compact result/source-table locations;
- the exact script/function entry points for reproducing each analysis **from the inputs that are actually available**.
Clearly distinguish:
1. code/results committed in Git;
2. large raw caches intentionally excluded;
3. any external/frozen input assets needed for a complete rerun.
Do not claim a clean-room rerun is possible unless it actually is. If a complete public rerun requires local/non-versioned assets, document that limitation explicitly and point to the committed compact outputs/audits that support figure inspection.
Add a short **Paper code / current release** section near the top of the root README linking this code index, the current paper-ready review, and the final figures/results. Keep the README concise and current.
If a `CITATION.cff` already exists, verify that it is not stale and update only fields whose correct values are already available in the repository. Do not invent author lists, DOI, journal, version, or publication metadata. If none exists, do not create one from guessed metadata.
### 3. Final scientific-artifact verification
Before staging:
- verify every protected-file hash from the prior release;
- verify completed noise-sensitivity anchors and saved audit receipts remain unchanged;
- verify all current FIG/PNG pairs open and their plotted data still match the committed source arrays/tables;
- verify all current Notion-linked file paths correspond to retained repository paths where applicable;
- run MATLAB Code Analyzer on newly committed MATLAB source only as a read-only packaging check;
- run only bounded existing smoke/reference checks needed to ensure file moves/path edits did not break entry points. Do not rerun the scientific experiments.
Verify Git size/staging hygiene: no raw cache, giant trajectory file, machine-local path dump, autosave, lock, unrelated user file, or ignored cache is staged.
### 4. One final release commit
Inspect the complete staged diff explicitly.
Create **one normal commit** containing:
- completed noise-sensitivity durable code/results/docs/figures/manifests;
- final repository cleanup/navigation;
- paper-facing README/code index;
- exact path/link repairs;
- final cleanup/release receipt.
Suggested commit message:
**`Finalize paper modelling code release`**
No amend/squash/rebase/reset/history rewrite. No force push.
### 5. Push v3 and synchronize main
Push the active `v3-romano-hennequin` branch normally first.
Then inspect `main` locally, its tracking ref, and the direct remote ref. **The intended paper-facing state is that ****`main`**** points to the exact same final release commit as v3.**
If and only if `main` has no unique/divergent commits and is a strict ancestor of the new v3 release:
- fast-forward local `main` to the new final release using an expected-old-SHA guard;
- push `main` normally;
- do not merge, rebase, force, or rewrite history.
If `main` diverged, remote refs changed unexpectedly, or the guard fails: STOP and report instead of resolving automatically.
At completion verify:
- HEAD, local v3, tracking v3, and direct remote v3 equal the final SHA;
- local main, tracking main, and direct remote main also equal that same SHA;
- tracked worktree and index are clean;
- no untracked durable release files remain;
- only intentionally ignored caches/assets remain;
- no Git lock remains.
### 6. Final release receipt and Notion
Write a committed final release report/manifest containing:
- final SHA;
- commit subject;
- branch/ref synchronization;
- cleanup inventory summary;
- committed-vs-ignored artifact summary;
- paper code index path;
- validation checks;
- known reproducibility limitations/non-versioned inputs.
After successful Git synchronization, update **Agent Instructions**, **START HERE**, **Agent Handoff**, the paper-ready parent, and page 03 to a compact final state:
- modelling work frozen and ready for manuscript integration;
- final release SHA;
- `main` and `v3-romano-hennequin` synchronized;
- paper code index/README pointers;
- no further modelling analysis authorized.
Append the release event to Agent Log. Preserve the historical archive.
**STOP after final cleanup, one commit, safe main/v3 synchronization, verification and Notion update. Do not begin manuscript writing or another modelling analysis in this Codex run.**

