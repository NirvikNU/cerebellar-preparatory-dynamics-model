# STAGE3-DIAGNOSTIC-FIG2-REFINE-01

## Authority and preservation boundary

Current Notion contract revision 2026-09-10T08:11:06.791Z; active repository
E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model.
Starting checkpoint 823798ca7dbbdeee14ecb473f1bd7c6fb9ced206 on both local,
tracking and direct remote main/v3-romano-hennequin. Status/index clean;
desktop.ini and Git locks absent; full fsck and normal fetch passed. Dangling
objects were retained. No repair, old G: path or external-archive operation.

The prior 687-file inventory is hashed in FIG2_REFINE_BEFORE.csv, including
ignored caches and prior evidence. No accepted model, controller, reference,
feasibility grid, selected solution, movement, parameter or previous analysis
definition is changed. The bounded plan precedes computation in
FIG2_REFINE_PLAN.md. Completion is not scientific acceptance.

## Baseline support and indexing

Source: src/published_generator/calibrate_source_faithful_generator.m defines
h = xsp - W*ReLU(xsp), and src/stage_3/stage3_prepare.m initializes every target
at that same frozen spontaneous state. This makes xsp an exact reproducible
controller-free equilibrium, rather than an invented pre-cue state.

Ten controller-free segments were integrated from GO -700 to -500 ms with
frozen h/W, .2-ms Euler integration, 1-ms saved sampling, no preparatory term,
no process noise. All baseline identities, cue-state discrepancies and
frozen-reference initial discrepancies are exactly zero for all ten networks.
Native/saved baseline evidence is local-only in cache/gain_time/refined/;
FIG2_REFINE_BASELINE.json records the numerical check.

The 200 pre-cue saved samples (-700:-501) are prepended to the unchanged 501
cached preparation samples (-500:0). Thus array row = 701 + GO milliseconds.
The displayed endpoints are -600:10:0; a population window has indices
row + (-100:10:0), always 11 time samples, all eight targets and 200 neurons.
Rates are [time, neuron, target]. Normalization remains frozen per-neuron SD;
target centering is per time; permute [1 3 2] before reshape gives
[time*target, neuron], one neuron per column. The baseline is NOT added to
the frozen normalization/fullCov reference window.

State error is instantaneous target-mean full-200D Euclidean distance to xstar.
Before and at cue, rates are identical across targets. True target-centered
covariance is zero: PR (0/0), PCs and normalized alignment are undefined.
These population cells are NaN and visibly masked gray, never assigned zero
or computed from roundoff. The first valid population endpoint is -490 ms.

The expanded result has 15,860 full-state cells and 13,000 defined population
cells; 2,860 population cells per metric are masked (all 260 gain/policy/network
combinations at the eleven endpoints through cue). All 173,150 numerical
comparisons pass, maximum absolute discrepancy 8.881784197001252e-15.
The 240 original-policy state/GO/metric checks pass. Every old -400:0 value
is bit-for-bit retained. K remains 5-7; no new null draws were needed.
The single cache-analysis batch took 230.3766 seconds before serialization.

At cue the median state error is 2.812570. At +10 ms, b-present errors at
nu=0/3/6 are 0.149086/0.120550/0.097388; at +20 ms they are
0.008168/0.005341/0.003486. In contrast b-absent error at +10 ms is
3.393284/3.192059/3.011123, approaching displaced endpoints. The added interval
therefore exposes rapid convergence, but not restoration without sustained b.
No new fit, selected time constant, significance or anatomical claim is made.

Across all finite displayed median cells, panel ranges (linear) are:

| Metric | b present | b absent |
|---|---|---|
| Full-state error | 1.6871e-14 to 2.812570 | 2.812570 to 3.465835 |
| PR | 3.392270946 to 3.392920155 | 6.979005938 to 6.999671297 |
| Expected-observed alignment fraction | -0.496232272 to -0.495531648 | 0.488548538 to 0.568495587 |

Thus b-present PR spans only 0.00064921 and alignment deficit 0.0700625
percentage points. Its color structure is finite and reproducible, but small
in magnitude. Late state error is numerical zero; the full b-present state
panel also contains a real pre-cue/early transient, so its colorbar is not
rescaled to amplify roundoff. GO values and interpretation remain unchanged.

## Analysis and figure acceptance

The analysis reuses all 260 eight-target preparation trajectories. No new
preparation/movement/reference/sweep/selection execution is used. New early
window values use the unchanged geometry and covariance-constrained null.
Every old -400:0 value is independently recomputed within abs 1e-9 + rel 1e-10
tolerance, then the original value is retained bit-for-bit. The original
four-policy GO states and metrics are separately compared against consequences.

Independent checks use explicit neuron loops/eigenvalues, direct projected
activity versus covariance trace, QR null projectors, and sorted network
medians. The old numerical outputs and original audit receipts are retained.
Expanded current outputs are results/stage_3/current/gain_time/refined/;
the parent gain_time outputs are prior provenance, not a second active renderer.

Only plots/stage_3/{fig,png}/diagnostic_2_component_removal is replaced.
All six axes span exactly [-600,0], with cue=-500, GO=0, gain nu=3 markers
and the original four-policy GO squares. Linear color limits use each panel's
own finite values, with six labeled colorbars. Colors are not quantitatively
comparable across panels. NaN masks do not contribute to color limits or
become zero-valued data. Late numerical-zero state error is not a biological
signal. No new statistical tests, bootstrap changes or mechanistic claims.

Final numerical and visual receipts accompany this report:
FIG2_REFINE_AUDIT.json, FIG2_REFINE_REVIEW.json, FIG2_REFINE_FIGURE.json and
FIG2_REFINE_ALL_FIGURES_AUDIT.json. See the current numerical receipt and
review_anchors.csv for the expanded early-time values and exact checks.

## Focused cleanup and documentation

The root stays at 22 items. No new root files, broad reorganization or
scientific-evidence deletion is needed. Nonempty baseline/analysis/render
console logs are execution provenance in the existing manifest folder, not
scratch. Ten new redundant null serializations were identified by exact MATLAB
struct equality to the preserved original evidence (no new K/draws). Their
exact paths and both source/destination hashes are recorded in the review and
cleanup receipts; only these redundant new files are removed. The exporter
now saves new null evidence only if a new K was actually needed; no analysis
rerun was performed. Original null evidence remains fully recoverable.
No alternate PNG/FIG copies or temporary renders are retained as
current outputs. Prior caches, manifests, audit/recovery files and historical
run records remain available; the old canonical rendering is preserved in Git.

Visual inspection caught a footer/axis-label overlap in the first export.
Reserved footer space corrected it by a rendering-only re-export; values and
all six scales were unchanged. The reopened-FIG audit checks masks, medians,
axes, cue/GO/gain markers, and six colorbars. The combined independent
saved-figure audit passes 28 comparisons with zero plotted-value error.

Changes are confined to the gain-time diagnostic entry point, extension and
review helpers, its renderer/figure validator, the receipt-name dispatch,
the two Figure-2 files, README/MODEL_SPEC, compact new results and task receipts.
Existing Stage-3 Technical Specification and Diagnostics are updated in place;
Summary/Results are inspected and left unchanged where not stale. Management
pages receive one new completion entry and the actual continuation state.

Preservation passed: 679 of 687 baseline files unchanged; exactly eight
authorized existing files changed (README, MODEL_SPEC, four diagnostic
entry/renderer/validator files, and the FIG/PNG pair). All 233 protected
Stage-1/Stage-2 files and every prior numerical/cache/audit file are unchanged.
Only the ten newly generated duplicate serializations (15,285,843 bytes) were
removed after semantic equality and exact path/hash checks; original copies
are preserved. FIG2_REFINE_PRESERVATION.json counts zero removed baseline
files, whereas FIG2_REFINE_CLEANUP.json records the ten removed new duplicates.

Native Notion image upload 3d726c94-be30-8161-bed2-00b22f460ab8 is 343,434 bytes.
Technical Specification and Diagnostics readback passed; existing Diagnostic
Figure 1, all anchor/sensitivity tables and unrelated scientific text remain.
The targeted image replacement failed to match a temporary signed URL without
changing the page; a full-body in-place update using stable upload references
resolved it and complete readback matched the intended content. No child page
or database was moved/deleted. See FIG2_REFINE_NOTION_PUBLICATION.json.

## Git checkpoint and review stop

The final commit SHA and verified two-branch synchronization outcome are
recorded after normal push in Agent Log, Agent Handoff, START HERE and the
final user handoff (avoiding a self-referential commit hash in this file).
No force push, reset, amend or history rewrite is permitted. Stop after
publication, preservation/figure checks, one normal commit, safe branch
synchronization and clean-status verification. No next model is authorized.
