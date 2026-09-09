# STAGE3-DIAGNOSTIC-GAIN-TIME-01: fixed gain-by-time diagnostic

Current task revision 2026-09-09T16:52:05.275Z. Active repository is
E:\PROJECTS\Nirvik_Sinha_Data\cerebellar-preparatory-dynamics-model. The old
Drive paths and relocated preservation-only archive are not read or modified.
Git status/show-ref/fsck --full and one fetch --prune origin succeeded.
No desktop.ini or Git locks were found. Dangling objects were left untouched.
Local/tracking/direct remote main=f3c85bf5bfea06868a7360e2370d4d29a5ab62c5;
v3=65816fa4052f55982ba92cc7d9f9cea2a916eaa8. Default main is ancestor of v3
with 0 main-only and 16 v3-only commits. Main remains untouched until success.
The prior untracked GAIN_TIME_GIT_REPAIR.md is preserved as historical evidence.

## Fixed plan, declared before integration

Ten frozen primary definitions, direction 1/grid 5, alpha=.1, betaNormalized=1.
No state selection, parameter fitting or model changes. Sweep only nu=0:.5:6,
two families b present/absent, fixed uC/kappa/xB/xstar/spontaneous initial state.
500-ms preparation; native Euler .2 ms, save 1 ms, analyze 10 ms. No movement.
Reuse original intact reference at nu=3 and recovered partial-removal full
trajectories at (b present,nu=0) and (b absent,nu=3). All other cells integrate
once for all eight targets. The original block has late rates only, so its
nu=0 trajectory is one authorized gain-grid protocol, checked against its
preserved endpoint/late data. Maximum 230 new eight-target preparations;
no intact reference regeneration, feasibility map, movement or reselection.

Displayed endpoints GO=-400:10:0. State error is instantaneous eight-target
mean Euclidean distance in full 200D. PR and alignment use 11 samples in
each inclusive trailing 100-ms window. Normalization uses the frozen intact
full-reference SD with per-time target centering and [time*target,neuron]
columns. No new normalization, neuron removal, floor or reference window.
Common K=max(Kref,Kpolicy), minimum strictly >95%. Alignment projects the
matched-window frozen intact covariance onto policy top-K basis, divided by
intact top-K eigenvalue sum. Bias is the frozen intact full-window covariance.

Null draws retain the existing 10000-draw mt19937ar seed 2026090900+network,
Gaussian-column normalization and covariance-SVD square-root/orth algorithm.
Cache by network/K the average random-subspace projector. Linearity of trace
makes trace(Cwindow*meanProjector)/denominator identical to averaging the
same 10000 per-window draws; windows do not receive reused terminal scalars.
Independent QR projectors check the orth result for every null draw. No
new p values or bootstrap analysis is authorized. Save raw network metrics,
K/captures, projector evidence and all new prep rates/states separately.

## Acceptance and execution order

1. Snapshot root inventory and hashes before science. All existing numerical
   outputs/caches/registry/statistics and Stage-1/2 files must remain unchanged.
2. Read-only cache endpoint precheck, explicit identity/schema checks, Code
   Analyzer and synthetic indexing test before integration.
3. Fixed run with per-case cache checkpoints; refuse output overwrite.
   For every network/four original policies compare t=0 state error, PR,
   observed, expected and K against consequences.mat. Compare original block
   late rates/distance/GO and recovered policy definitions. Absolute tolerance
   1e-9 + relative 1e-10*max(abs(preserved)) declared here; material mismatch
   stops immediately with evidence, without replacing the published figure.
4. Independent explicit-loop neuron covariance/eigen PR/K and projection
   audit at every displayed cell; QR null audit; frozen endpoint equivalence.
5. Six heatmaps in the existing Diagnostic-2 FIG/PNG only, paired row color
   limits, nu=3/GO markers and four original-cell labels. Inspect/reopen both.
6. Inventory/classify every root item. Retain canonical runners/documentation;
   move provenance logs to existing Stage-3 manifests, remove only verified
   empty scratch logs. No provenance-critical deletion or protected edit.
   Check moved-path references and changed-file Code Analyzer/smoke checks.
7. Update existing scientific Notion pages in place; preserve child pages,
   other figures and historical log entries. Publish native PNG with caption.
8. Review diff, one normal v3 commit/push, safely fast-forward main without
   loss if ancestry still permits, push main and verify both local/tracking/
   direct remote refs and clean status. Record actual outcome and stop.

No polling loops, new model, noise, prediction, learning, adaptation, tuning
or scientific acceptance is implied. The existing task/spec hold the plan;
no duplicate Notion task hierarchy is created.
