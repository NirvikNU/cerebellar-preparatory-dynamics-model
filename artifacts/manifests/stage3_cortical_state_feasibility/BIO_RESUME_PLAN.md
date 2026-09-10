# STAGE3-BIOLOGICAL-CONTROLLER-RESUME-02

Resume the preserved REVISION-01 candidate from checkpoint
166d2bbc15cb6a9f0b4d9b7c061e48b180b9b68b under the updated top Notion contract.
Only the old 500-ms Block relative-settling <=1e-4 criterion is retired by
explicit user scientific authorization. No replacement distance threshold.
Distances to xB and x*, including incomplete finite-time convergence, are
reported outcomes. Preserve the old stop report and raw evidence unchanged.

## Fixed implementation and execution order

Reuse controllers.mat exactly (all ten P/Q/L/kappa0), primary registry and
network1 Intact/Block native evidence. Use the unchanged
stage3_biological_prepare for only 38 missing eight-target preparations:
network1 partial removals and all four policies for networks2-10. Policy order:
Intact [1,1], remove prospective feedback [1,0], remove b [0,1], Block [0,0].
Flags specify delivered b/feedback. All four share identical u0. The original
negative subthreshold x* coordinates are valid states; ReLU firing rates and
constructed positive xB retain their established convention, without clipping
proposed geometry or imposing a new nonnegative-internal-state condition.

Keep 500 ms, native dt=.0002 s, saved dt=.001 s, tau=.15 s. Preserve all
controller matrices, geometry, seed, normalization and movement parameters.
Enforce frozen rate/state/variance and new-component input limits from
BIO_PLAN.md; exact stable primary equilibria and native Euler stability.
No finite-time settlement test or outcome-selected gain/duration. Stop if a
retained primary criterion fails. Save raw states/components and all target
readiness/error measurements before population or movement interpretation.

Use frozen Stage-3 per-neuron SD and full-reference covariance/null bias.
Prep GO -100:10:0; target-center each time and flatten time/target into rows,
one neuron per column. PR uses every covariance eigenvalue; common K is the
larger minimum count strictly >95% variance. Intact projected onto policy
top-K basis, normalized by intact top-K eigenvalue sum. Reuse existing
10000-draw projectors (including independently QR-audited projectors) by
network/K; generate only missing K with the same seed2026090900+network.
Evaluate each actual revised intact window covariance, never reuse an old
terminal expected scalar. Save new primary null draws/SE for uncertainty audit.
Population failure is reported without changing parameters or selecting states.

Movement: only after primary retained-bound/population checks, pass actual
achieved Intact/Block GO into unchanged cortical generator/readout/arm. Compare
to the saved frozen comparator over its target-specific MO+[0:200] ms, RMS
Euclidean hand error in mm, target mean then networks. No GO reset or time warp.
Network median +10000 whole-network bootstrap SE, reuse frozen bootstrap
indices (seed2026091000); exact paired sign flips and existing two-test
geometry BH family, movement separately. Diagnostics are descriptive.

## Map and figures after primary checks

Existing6x6 alpha/beta grid,3 directions,10 networks; reuse all1080 stored
state definitions and unchanged analytical/nonnegativity/variance quantities.
Recompute new endpoint input screen, actual dynamic bounds and finite-window
metrics. No new direction or selection. Reuse primary Block where it occurs;
batch remaining block preparations where useful, retaining required raw late
activity, GO, native bounds and component evidence. Local stability uses the
new fixed kappa0, not the old global contraction rule. Old additional samples
and old gain/nonorthogonality sensitivity outcomes remain explicitly historical
unless recalculated under separately applicable current scope; never display
their old movement numbers as revised results.

Four current FIG/PNG pairs retain canonical names. Results1 preparation,
member1 reaches and ensemble early-error comparison; Results2 actual prep
spectrum/PR/observed-expected alignment. Diagnostic1 updated same map and
network/direction fractions (denominator30). Diagnostic2 five line panels:
distance x*, distance xB, cue-normalized E_Q, trailing100-ms PR, expected-minus-
observed alignment. Common GO axis -600:0 ms, cue-500, validated baseline
reused from -700:-500. Population endpoints every10 ms; zero-covariance cells
through cue remain undefined/masked. Network medians with bootstrap SE;
no fitted time constants, no new inferential diagnostic tests.

## Audit, publication and checkpoint

Independently audit saved native increments, equations/components, population
indexing/covariance/PR/K/activity projection/null, bootstrap/sign-flip/BH and
movement errors, frozen-controller identity and preservation. Code Analyzer
on changed/new MATLAB. Reopen all FIGs and visually inspect every PNG before
native Notion publication. Update existing scientific/management pages in
place, clearly preserve historical predecessor and old stop. No task-page
duplication. Keep unique caches/manifests; cleanup only proven redundant
temporary outputs. Review intended diff, normal v3 commit/push, safe main
fast-forward only if no unique commits, verify all refs/remote+clean status.
No prediction, noise, learning, retuning, adaptation or further model.
