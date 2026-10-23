# Production reproduction interface

## Paper regeneration

From the repository root in MATLAB R2025b:

```matlab
restoredefaultpath
run_paper_figures
```

Outputs go to `generated/paper_figures/{fig,png,source}`. The eleven panels are Fig6a–h and ED5a–c; the two assemblies are Figure_6 and Extended_Data_Figure_5. An optional output-directory argument changes only where the outputs are written. No original cache or absolute project path is consulted.

Use a new empty output folder. The renderer refuses to merge with an older output set, preventing historical panels/tables from silently surviving in a current export. All existing evidence is preserved; for a repeat use `run_paper_figures(fullfile(pwd,'generated','another_check'))`.

The numerical graphics specifications in `data/paper_ready/final_v3/*_graphics.mat` are plain MATLAB structures containing arrays and display properties, not hidden figure handles or calls to historical renderers. `pf_draw` constructs native lines, error bars, scatter, bars, surfaces, patches, text, images and axes. Every data object is checked after reopening its saved FIG. Assembly FIGs embed the current eleven panel images; the separate panel FIGs retain native data objects. Fig6c is intentionally the hand-drawn static manuscript schematic, not numerical model output, with the source extraction recorded in the provenance receipt.

Full-precision CSV/JSON tables are under `data/paper_ready/final_v3/tables`. Regeneration exports byte-identical copies and independently verifies the selected trials, 101-point means, active-trial medians, Gaussian boundaries, inset distances/counts and prediction-loss arithmetic. It does not refit statistics.

## Full-model reproduction

```matlab
restoredefaultpath
run_paper_model('check')         % network1, primary Intact/Block, 480 trials
run_paper_model('lambda')        % frozen anticipatory-control sweep + exact K=0
run_paper_model('geometry')      % fixed grid evidence; never reselects index24
run_paper_model('stochastic')    % fifteen unique noise pairs, Control/Block, all ten networks (300 cases / 72,000 trials)
run_paper_model('illustrations') % frozen displayed/inset IDs only; no success search
% run_paper_model('all') executes the four complete reproduction components.
```

Outputs default to `generated/paper_model/<mode>`. Model replay writers refuse to overwrite an existing case; use an empty output directory for a new verification. Complete numerical replay is computationally expensive. The bounded `check` mode genuinely runs native preparation, movement, the arm, preprocessing and nested PCA75/ridge, and compares predictions to the frozen sources. It is not a file-existence test. Full replay modes compare to the frozen current source tables and stop on mismatches rather than replacing them.

The ten accepted network/controller/geometry bundles are versioned. They preserve all scientific arrays; original model metadata is separately retained in `model_provenance_*.mat`. The movement and arm code is in `src/published_generator`. Production helpers are exclusively under `analysis/paper_ready/final_v3/production`; neither entry point adds the project recursively to MATLAB's path.

CARE-derived finite-lambda gains are verified against the accepted gains before replay uses those exact accepted gains. This prevents a different CARE roundoff representation from changing the fixed finite random-subspace sample. It is not a refit or tolerance change. The exact zero-gain endpoint is constructed literally.

Paper rendering requires MATLAB graphics and the built-in `smoothdata` used by its independent audit. Full lambda reproduction additionally requires Control System Toolbox (`care`). Committed inferential values are included; the source audit independently verifies the new noise ranks, chi-square probabilities and original saved bootstrap draws using base MATLAB arithmetic. It does not refit prediction models or create new bootstrap draws. Parallel Computing Toolbox is not required by these serial canonical entry points.

No licensed third-party checkout, cloud attachment, drive letter, local ignored MAT file or original workspace is a production input. The accepted networks remain frozen; from-scratch retraining or recalibration is outside this interface and is not authorized by a reproduction command.

## Historical production-final24 validation

The following tests describe checkpoint04a65d78d4901a8350473aa3b93ba1673d87fdd4, not the current panel count. For the current acceptance gate see [PUBLICATION_CLEANUP.md](PUBLICATION_CLEANUP.md).

See the actual receipts in this directory and `REPORT.md`. A documented command is not evidence of its execution. In particular, the final remote-clone result must be recorded only after it has actually run at the pushed commit.

The executed pre-checkpoint isolated-input test regenerated all twelve panels and both assemblies, verified279 native objects, copied source tables exactly, and ran the480-trial primary network1 Control/Block numerical replay. Prediction and all-trial peak-speed/matched/unmatched-dispersion errors were zero. All loaded user code was inside the isolated tree; only MATLAB code came from outside it. The fixed network1 nine-point lambda replay, all36 network1 geometry-grid cells, and116 frozen illustrative trial replays also passed without reselection.

To repeat the post-push test, clone GitHub main into a new directory, verify its SHA, start MATLAB in that directory with `restoredefaultpath`, then call `run_paper_figures` and `run_paper_model('check')`. Do not copy any source, MAT cache or figure from a prior checkout into that clone. Final post-push receipts are local generated outputs plus the chronological Notion Agent Log, because adding them to the tested commit would change its SHA.

The full replay produces network/case evidence and compares it against immutable manuscript sources; it does not replace frozen inference, select geometry or retrain networks. For all-trial behavior it applies the unchanged matching implementation to primary Intact/Block evidence. Original preprocessing scales/covariances, accepted network arrays and accepted controller gains are explicitly versioned inputs. The historical metadata MAT files are provenance, never load paths.

The [19 October presentation revision](PRESENTATION_UPDATE.md) keeps Fig6g unchanged and displays absolute Control/Block temporal-noise R² in Fig6h. All numerical model inputs remain byte-identical to release 6391528. The 23 October ED5 migration changes only explicitly mapped panel-label strings in source tables; every numerical token is unchanged and inverse naming conversion reproduces the original committed bytes. The source validator also checks all eight Fig6h Control values and SEs directly against the Fig6g temporal series. Local reviewer success QC and exploratory caches are not publication dependencies.

## Submission statistical supplement

See [SUBMISSION_STATISTICS.md](SUBMISSION_STATISTICS.md) for committed frozen features, all paired/null statistics, exact seeds and full independent reproduction. `workflows/reproduce_submission_statistics.m` reproduces the eight paired tests and all 460,000 nested null fits, without simulating new trials. Statistics and Machine Learning Toolbox is required for Anderson–Darling/t tests. Outputs use new folders and are compared to immutable committed results. Original source-table and model validation remains separate and unchanged.

After `validate_publication`, add `workflows` again and call `validate_submission_graphics(publicationFolder,newReceiptFile)`. This verifies the consolidated policy approved on 22 October 2026: exact dimensions and complete native content, exact pixels outside fixed sites, and only documented complete RGBA tuples at each approved site. It checks the measured rendering environment, pinned source blobs, and separate PNG export with unchanged canonical FIG bytes. Sites and palettes never expand automatically; the older exact-image rule is retained only as historical provenance. Full original sources and canonical masters are preserved.
