# Reproduction

Use MATLAB R2025b from the repository root. Statistics and Machine Learning Toolbox is required for statistical reproduction. The full effort-penalty replay also requires Control System Toolbox. Parallel Computing Toolbox is optional.

## Figures

```matlab
restoredefaultpath
run_paper_figures
```

The accepted native FIGs contain the editable manuscript presentation. Figure export uses independent readback instances and preserves the native files. Numerical graphics specifications provide a separate source-array and annotation check. Fig. 6c is the supplied static hand-drawn schematic. Both assemblies are rebuilt from the exported panels. All 26 source tables are copied byte-for-byte, and independent arithmetic checks verify trial identities, median support, speed smoothing, inset distances and prediction statistics.

Reference and regenerated native files undergo the same getter initialization, normal viewing mode and temporary viewport setup before complete accessible properties are compared. Scientific snapshot stability and unchanged canonical FIG bytes are required throughout. Viewer initialization does not resave the native files or change their editable content.

The [native validation rule](../../../../data/paper_ready/final_v3/graphics_validation/native_editor_rule.json) distinguishes MATLAB-generated label-editing metadata from saved native content. For eleven explicitly hash-pinned panel FIGs, the regenerated native file must be byte-identical to its canonical source. Only the Interactions field of the canonical axes Title, Subtitle, XLabel, YLabel or ZLabel may differ between empty double0×0 and a fieldless EditInteraction object. Every occurrence and both original typed values are recorded. All scientific arrays, labels, axes, fonts, styles, layout and every other accessible property remain exact. Nonempty editing objects and other classes/roles are rejected. Assembly handling is limited to the separate extension below. Neither rule can expand automatically.

The [assembly extension](../../../../data/paper_ready/final_v3/graphics_validation/assembly_editor_rule.json) permits only the same two runtime editing values on unused standard labels of the two pinned assemblies. Both parent axes must be invisible, both label strings empty and identical, and every other native property and scientific snapshot exact. Canonical assembly bytes remain hash-pinned; regenerated serialization may differ while its semantic content remains exact. Panel textures/order, annotations, fonts, layout and every assembly PNG pixel/dimension remain exact. Visible/nonempty labels, annotation text, other objects, nonempty editing properties and additional raster differences are rejected. All original values and roles are recorded.

PNG export uses MATLAB `print` with vector rendering at 160 DPI. Physical output dimensions come from the saved numerical canvas and screen PPI, with explicit manual paper dimensions. The native FIG supplies all plotted objects, styles and labels. The exporter verifies the source FIG bytes after rendering. The graphical validator independently reopens the FIGs and compares their complete native content.

Image dimensions and decoded RGBA pixels must match exactly, subject only to ten fixed ED5b edge sites in MATLAB R2025b Update 1 (25.2.0.3042426), 96 screen PPI and the documented print settings. In its 1750 × 1167 PNG, each zero-based site may use only its two complete RGBA values below.

| x,y | Reference RGBA | Allowed alternative RGBA |
|---|---|---|
| 1228,367 | [165,102,51,255] | [176,107,51,255] |
| 1228,369 | [185,124,76,255] | [183,123,76,255] |
| 1092,647 | [58,120,156,255] | [57,120,156,255] |
| 1093,647 | [112,150,172,255] | [112,151,174,255] |
| 1093,649 | [86,150,187,255] | [85,149,186,255] |
| 1095,649 | [189,201,208,255] | [188,197,203,255] |
| 1093,650 | [108,169,205,255] | [106,165,199,255] |
| 1228,359 | [142,100,67,255] | [142,99,66,255] |
| 1228,361 | [184,161,143,255] | [174,151,133,255] |
| 1229,361 | [124,64,16,255] | [124,63,15,255] |

Every other pixel is exact; no other location, colour or dimension is tolerated. Both independent exports must satisfy this rule. To retain exact native assembly textures and avoid spreading these rendering variants through resampling, the ED5 assembly uses the canonical ED5b PNG after checking the newly exported panel against this rule. The individual exported PNG is retained unchanged. Assembly scientific native content, all other properties and output PNGs remain exact. The validator never learns or expands the allowed sites or colours.

Outputs are written under `generated/paper_figures/`. Supply a new output directory as an argument for repeated exports. The figure writers protect existing evidence from overwrite.

## Numerical model

```matlab
restoredefaultpath
run_paper_model('check')
```

This performs the actual primary Control/Block preparation, movement, arm and prediction calculations for network 1, totaling 480 trials. Numerical predictions and behavior must match the supplied references.

Additional modes reproduce the manuscript's complete components from the accepted networks.

```matlab
run_paper_model('lambda')
run_paper_model('geometry')
run_paper_model('stochastic')
run_paper_model('illustrations')
```

The stochastic mode covers the fifteen unique noise pairs, ten networks and two conditions, totaling 72,000 trials. These full component replays are computationally expensive. The accepted weights, parameters, normalization, selected illustration trials and random streams are fixed.

## Validation

```matlab
restoredefaultpath
addpath('workflows')
validate_publication(fullfile(pwd,'generated','publication_validation'))
addpath('workflows')
validate_submission_graphics(fullfile(pwd,'generated','publication_validation'), ...
    fullfile(pwd,'generated','graphics_validation.json'))
```

Validation checks all eleven panels and both assemblies, native numerical content, complete accessible native properties, axes, labels, styles, layout, exact raster dimensions and decoded pixels subject only to the fixed ED5b rule. It also verifies the source tables, accepted-source hashes, loaded dependencies, MATLAB Code Analyzer and bounded 480-trial numerical check. Rendering uses the recorded MATLAB environment. Any unapproved image difference or native-property difference causes validation to fail.

## Paired statistics and shuffled controls

```matlab
restoredefaultpath
addpath('workflows')
reproduce_submission_statistics
```

This reconstructs the eight paired comparisons and all 460,000 nested shuffled fits from the committed features and deterministic seeds. It verifies complete original null structures, paired tests, three summaries and source tables. The `validate` phase audits supplied permutation results without rerunning the null fits, as described in the [statistical methods](SUBMISSION_STATISTICS.md).
