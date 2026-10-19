# Fig. 6g,h common-baseline noise update — 19 October 2026

> Historical numerical-release report for commit 6391528be9f30f7c5ec88511606133a625bc0509. The scientific results remain current. The later [presentation revision](PRESENTATION_UPDATE.md) replaces the percentage-deficit Fig6h with absolute Control and Block R² versus temporal noise. Cleanup and release receipts below describe that earlier run, not the later cleanup.

This authorized publication update changes Fig6g,h and the Figure6 assembly. Fig6a–f, including the hand-drawn Fig6c, and ED7a–c plus its assembly retain their original canonical files. The accepted networks, generators, illustrative trial IDs, primary 0.10/0.10 setting, model parameters and original prediction estimator are unchanged. Neither Google Doc was modified.

## Scientific scope and results

Eight noise levels 0.05–0.40 at increments of 0.05; the other noise source stays at 0.05. One exact 0.05/0.05 baseline is reused across sweeps. Fifteen unique pairs × ten networks × two policies × eight targets × thirty trials = **300 cases / 72,000 canonical trials**. All windows, folds, PCA ranks and SSE/SST passed; no trial was excluded, no R² was negative and no percentage denominator was ill-conditioned. The forty old/new-grid intersection cases reproduced the frozen source R² bit-for-bit.

Initial-state noise 0.05→0.40: Control R² changed from 0.9918963588 ± 0.001254361609 to 0.926746421 ± 0.005956182271; temporal noise 0.05→0.40: Control R² changed from the same 0.9918963588 ± 0.001254361609 to 0.5761916597 ± 0.003974048523. Relative Block deficit changed from the same 6.320889519 ± 2.666333263% to 7.000875652 ± 1.226355037% for initial-state noise and 13.65533174 ± 1.244165915% for temporal noise. Values are medians ± bootstrap SE across ten networks (10,000 whole-network resamples). Control R², initial-state sweep: Friedman χ²(7)=67.63333333, p=4.437900838963797e-12. Control R², temporal sweep: Friedman χ²(7)=70, p=1.4774294932825119e-12. relative Block deficit, initial-state sweep: Friedman χ²(7)=31.36666667, p=5.3200756808134443e-05. relative Block deficit, temporal sweep: Friedman χ²(7)=28.1, p=0.00021090367511048577. These omnibus tests do not establish a monotonic trend; no post-hoc contrasts were performed.


Both Control median curves decrease across the eight displayed levels. Relative Block loss is nonmonotonic in each sweep: the initial-state curve has its lowest median at 0.15, and the temporal curve reaches its highest median at 0.25 before lower medians at later levels. These are descriptions of the complete displayed series, not post-hoc contrasts or directional trend tests.

All sixteen summary rows, network-level values, SSE/SST and four tests are in the current full-precision `data/paper_ready/final_v3/tables/Fig6gh_*` CSV/JSON files and [panel legends](LEGENDS.md). The statistical unit is the network; the original 10,000 whole-network bootstrap draws were reused. Friedman p values are full-precision chi-square approximations, not exact randomization probabilities. No post-hoc tests, new behavioral investigation, retuning or additional noise condition was added.

## Executed pre-push validation

The original frozen publication reference and the isolated updated candidate both ran the complete publication gate. The candidate produced **11 panels, two assemblies, 26 byte-identical source tables and 261 native numerical objects**, passed Code Analyzer, and ran the actual primary 480-trial check with zero prediction error. Its complete primary numerical evidence exactly matched the original reference. An additional 1,440-trial network1 replay checked the shared baseline and both 0.40 endpoints, with zero R² error. These are verification replays of existing conditions, separate from the 72,000 canonical trials.

New editable g/h FIGs were saved before PNG export. Separate native readback/export instances matched persisted scientific, label, legend, style and layout snapshots, preserved canonical FIG bytes and generated pixel-identical repeated PNGs. Direct inspection confirmed visible data, error bars, labels and annotations. The unchanged nine panels and ED7 assembly reproduced the original reference native content, annotations and decoded PNG pixels exactly. Fig6a, Fig6b and ED7a retain the same pre-existing one-pixel regenerated-versus-stored PNG dimension warnings seen before this task; their canonical files remain untouched. No scientific validation was relaxed.

## Preservation, cleanup and historical provenance

All 12,051 preexisting files / 98,581,096,681 bytes, including all 646 tracked files, were rehashed unchanged before promotion. This includes the 200-file **45,143,035,201-byte** historical component-removal dataset, all geometry results and all original scientific seals. Prior seven-pair g/h sources and masters are preserved under `data/paper_ready/final_v3/noise_sensitivity_20261019/historical_480753/`; the executable parent checkpoint is `480753f3be0134a843ffbc350d6baa162a85aa7e`. The final release whitelist separately identifies intended publication changes.

The new canonical record retains 300 raw files / **122,393,637,813 bytes** and all saved fits, summaries and validation records (1,057 sealed scientific files / 125,495,762,565 bytes). Cleanup removed only 0 independently verified byte-identical, unreferenced repeat-export files, totaling **0 logical bytes**. Metadata-distinct images and all unique data, scripts and provenance were retained. Every deletion and retained-source hash is recorded in the ignored task cleanup ledger. No original project file was deleted.

## Reproduce

```matlab
restoredefaultpath
run_paper_figures
restoredefaultpath
addpath('workflows')
validate_publication
restoredefaultpath
run_paper_model('check')
% Complete 15-pair numerical replay, 300 cases / 72,000 trials:
% run_paper_model('stochastic')
```

Use new empty output folders for repeat checks. The publication code uses only versioned inputs; no ignored raw data or historical archive is a runtime dependency. Full stochastic replay is available through the documented command. The release protocol separately requires a fresh clone from GitHub and complete post-cleanup publication acceptance plus all-ten-network anchor/endpoint checks. The exact pushed SHA and those subsequently executed results are recorded in the existing [Notion Agent Log](https://app.notion.com/p/3d326c94be3081e897a2e5e0c855c4c0) and [Final Paper Figures v3](https://app.notion.com/p/3e826c94be308179870cda177f0b75af). This versioned report certifies the pre-push candidate; it does not claim that a later remote-clone check had already run when the report was written.
