# Publication cleanup — Main_text_v12, 13 October 2026

## Scope and preservation

Authority: the complete updated Notion Agent Instructions — Current Task, read13 October2026. Starting main/local/tracking/direct-remote checkpoint: **04a65d78d4901a8350473aa3b93ba1673d87fdd4**, clean tracked/index/untracked state. Existing ignored Stage1 assets, pinned source and generated evidence were inventoried and left intact. No manuscript or Google Drive file was read as a computational input or modified.

Current panels: **Fig6a,b,d,e,f,g,h and ED7a,b,c** are the ten model-derived panels. **Fig6c is hand-drawn static artwork**, included without claiming numerical generation. Both assemblies contain only current panels. ED7b/c remain disclosed calibration targets, not independent validation.

ED7d originals are preserved under [archive/paper_ready/ED7d_retired_20261013](../../../../archive/paper_ready/ED7d_retired_20261013/README.md), with exact original paths, checkpoint, byte counts and SHA256 manifest. Original computation and all dependencies remain recoverable at the starting checkpoint. Its native figure, data, tests and mixed interpretation are preserved, not reanalyzed. The seven retired active files were copied and hash-verified before removal. Shared statistics lost only three ED7d-specific fields; every retained value is unchanged. No other historical material or external archive was deleted.

The active renderer/assembly stops at ED7c. The stochastic replay excludes only the old high-noise four-policy case: seven unique noise pairs × Control/Block × ten networks =140 cases. Numerical helpers, model bundles, graphics recipes and all eleven retained panel masters are unchanged. Fig6d remains Option3/seed18003/network8; Fig6e/f retain exactly the approved fifteen network8/target6 IDs. The ED7 assembly alone is replaced to remove its fourth panel.

## Reproduction

From a new clone of the final public main commit, in MATLAB R2025b Update1 (25.2.0.3042426):

```matlab
restoredefaultpath
run_paper_figures
run_paper_model('check')
```

Or run the combined validation in a new output directory:

```matlab
restoredefaultpath
addpath('workflows')
validate_publication
```

The combined check regenerates panels, reopens native FIGs, compares complete native data/style/annotation snapshots with masters, copies and compares24 full-precision tables, runs the real480-trial primary network1 model/prediction/behavior replay, runs Code Analyzer and verifies loaded M/MEX paths remain inside the clone or MathWorks installation. Inspect the resulting PNGs as well; native equality is not a visual-inspection substitute.

Outputs: `generated/paper_figures/{fig,png,source}` and `generated/paper_model/check`; combined validation uses `generated/publication_validation/`. Panel names are Fig6a–h and ED7a–c; assembly names are Figure_6 and Extended_Data_Figure_7. Each has matching FIG/PNG. The separate ten model-panel FIGs contain editable graphical data; Fig6c and assembly images are intentionally raster assets within FIG containers.

Full numerical modes are documented in [REPRODUCTION.md](REPRODUCTION.md): `lambda`, `geometry`, `stochastic`, `illustrations`, or `all`. Rapid graphics reconstruction uses versioned frozen numerical recipes; it is not a claim of fresh full-ten-network recomputation. MATLAB is required; finite-lambda CARE replay also requires Control System Toolbox25.2. No parallel toolbox, third-party checkout, ignored cache, Drive attachment or archive is required. Other installed products are listed in the actual execution receipt, not claimed as prerequisites.

Streams remain mt19937ar: main stochastic seed310000000+10000×network+100×target+trial; outer-fold320000000+10000×network+target; inner-fold321000000+10000×network+100×outer+target. Illustration seed610000000+1000000×condition+10000×target+attemptID, with frozen IDs rather than any success search. Lambda null seed20260908+network; geometry null2026090900+network. All accepted normalization/covariance/gains are versioned. Native dt0.2ms, saved1ms, analysis10ms; parameters and inference remain frozen.

## Executed checks and boundaries

Pre-commit receipts are in `publication_receipts/`. Actual final remote-clone evidence is written only after push, in ignored generated output and the chronological Notion Agent Log; placing that later evidence in the tested commit would change its SHA. No claim of final-clone success is made by a pre-commit report.

- Regeneration:11 panels,2 assemblies,261 native graphical data objects and independent source-arithmetic checks passed.
- Primary numerical replay: network1 Control/Block R² and all-trial peak-speed/matched/unmatched-dispersion errors0;480 trials, all retained.
- Full ten-network lambda replay:90 network/penalty points, maximum discrepancy2.984279490192421e−13; exact K=0 effort0. No new grid or selection.
- Full illustrative replay:116 unique frozen required trials; native path and peak-position errors0; no search/reselection.
- Full ten-network stochastic140-case replay and full360-cell geometry replay were **not repeated in this cleanup**. The unchanged full modes remain available; historical bounded geometry checks are not represented as newly executed.
- Production Code Analyzer27files: zero findings. The new acceptance harness is checked separately.

Raster exports are not claimed byte/pixel identical across graphics environments. An initial stricter PNG-size test detected a one-pixel crop-size difference in Fig6a,b,g,h, ED7a and Figure_6, despite unchanged native scientific objects. Original masters were not modified to chase raster equality. Exact native-snapshot comparison and visual inspection distinguish this export warning from a scientific discrepancy; source-array/inference or annotation mismatches remain stop conditions. Original failed diagnostic logs are retained under generated/publication_cleanup_20261013/.

Current Notion gallery retains11 original panel image assets and229 decimal-value occurrences, with ED7d moved to a clearly historical page. Previous START/Handoff content was archived before updating current navigation. Pages01–03 are explicitly historical; Agent Log chronology remains intact.
