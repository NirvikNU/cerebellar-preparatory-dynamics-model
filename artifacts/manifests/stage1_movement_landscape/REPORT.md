# Stage-1 movement landscape and launch-state sensitivity

Task: STAGE1-MOVEMENT-LANDSCAPE-DIAGNOSTIC-01.
Starting checkpoint: `2d98681ba83be063ffdcae3a661d12bff9f8b0b9`.
Active repository: `E:/PROJECTS/Nirvik_Sinha_Data/cerebellar-preparatory-dynamics-model`.

## Status

DIAGNOSTIC, INDEPENDENT VALIDATION, FIGURES AND NATIVE PUBLICATION COMPLETE.
All 16,000 nonzero perturbation movements completed. Stage 1 remains
ACCEPTED/FROZEN. The actual final commit SHA and verified synchronization
receipt are recorded in Notion Agent Log/Handoff/START HERE after pushing;
this report does not claim Git success before that verification. Stop for
scientific review; computational completion is not a new scientific approval.

## Frozen plan and preservation boundary

The Notion contract was read at revision 2026-09-15T10:02:44.077Z. PLAN.md
was written before inspecting diagnostic outcomes. The fixed search, seeds,
direction classes, amplitudes, example and aggregation rules are unchanged.
Saved 1-ms states use time x neuron x target/trial; full native baseline
states use neuron x native-time x target. Native perturbation norms use
native-time x trial. No neuron/state identity is inferred from a reshape.

The initial SHA-256 inventory contains 1,154 pre-existing scientific,
implementation, configuration, workflow and figure files, including hidden
and ignored assets (72.13 GiB). INPUTS_BEFORE.csv is the byte-preservation
baseline. Newly added diagnostic files are not baseline assets. The separate
pinned benchmark check verified all 167 source/native-reference entries.

Inventory by area: analysis 93, configuration 6, figures code 13, plots 48,
results 969, source 21 and workflows 4. Protected plot files comprise 20
Stage-1, 12 Stage-2 and 16 Stage-3 files. No file with the new landscape
diagnostic name is included in the before-manifest.

Initial Git fetch and integrity preflight passed on v3-romano-hennequin.
HEAD, both local branches, both tracking refs and direct remote main/v3
equaled the starting checkpoint. The worktree/index started clean; no lock
was present. Existing dangling Git objects were informational, not repaired.
Existing line-ending checkout warnings do not authorize configuration changes.

## Baseline validation

PREFLIGHT.json records:

- 10 accepted networks, all 80 target rows passed, 10 batched QC forward calls.
- Maximum audit difference: 5.1159076974727213e-13, below the existing 1e-12
  deterministic tolerance. Saved member-bundle metric difference: zero.
- Primary saved rates, torques, final states and hand trajectories: exactly
  reproduced in both accepted primary bundles (maximum difference zero).
- New state-saving wrapper versus frozen cortex/arm for all ten networks:
  maximum difference zero. Baseline spontaneous residual: zero.
- Existing endpoint/angular/radial maxima: 0.003637309718883566 m,
  1.806437782142325 degrees, 0.0026702134364093161 m.
- Native benchmark: 167/167 hashes and pinned source HEAD matched.
- Bounded source smoke: short-segment error 2.2204460492503131e-16;
  Q relative residual 7.3452314146709592e-14.
- Original eight canonical FIG/PNG pairs matched by inventory; no canonical
  result writer was called.
- Fixed N1/T3 projection plane: second-axis norm 6.7983379799889505;
  peak hand-speed sample 202 ms. No alternative example/plane was selected.

## Implementation-only pre-production corrections

An initial invocation stopped at the missing preservation-manifest guard,
before numerical work. A subsequent queued invocation stopped at Code
Analyzer before numerical work. Its flags were nested-loop alignment and
logical-count style in new helpers. These were corrected without altering
any calculation, seed, tolerance or accepted file. The resumed workflow
passed the preflight above; no completed scientific cache was replaced.

The new figure directory is additive rather than the original canonical
directory, preserving the frozen public validator's exact eight-pair
contract. Only five PNG/FIG-specific .gitignore exceptions were added;
generated Stage-1 numerical evidence remains local-only as before.

The cache-only neural-norm companion summarizes the already-declared metric
at all 599 saved movement times. It introduces no new replays, conditions,
seeds, window or inferential family; 180 fixed-time bootstrap spot checks
independently verify its uncertainty. Norms use native state differences,
not rates or a preprocessing normalization.

## Landscape result and interpretation

All ten networks had one identified smooth locally stable root at every
one of the 51 grid values: 510 grid roots, no identified unstable root.
This is a result of the fixed search, not proof of global uniqueness or
complete enumeration. Across 83,090 root-search attempts, 36 did not
converge (20 in network 3; 16 in network 6). All attempts are preserved;
settings were not relaxed. Other starts identified a valid stable root at
every grid point. Maximum converged-attempt residual was
7.37188088351104e-14; maximum independently recomputed retained-root
residual was 6.4837024638109142e-14. There were zero unmatched forward
links, zero nonreciprocal links and zero active-set link gaps.

Stable-root coverage was complete at all 599 saved times for all 80
network/target trajectories (47,920 distances). None entered the
predeclared <=1% launch-scale proximity range. Target-specific minimum
distances ranged 1.55787767658634 to 3.24996226672166 state units, or
0.388682971189031 to 0.750841077770126 of launch scale. Minimum field speeds
across target trajectories ranged 16.7538281360512 to 32.7913000104129
state units/s. The movement is a driven transient rather than rapid
settling at an instantaneous movement equilibrium over this finite horizon.
That statement does not deny that stable frozen-input equilibria exist or
that trajectories can decrease their distance to them as movement proceeds.
The common input changes with time, so there is no single time-invariant
movement fixed point. x* remains a calibrated launch state, not an attractor.

The dominant root eigenvalues span -1.2831168407346918 to
-1.2710792391529244 per second. At GO and 598 ms respectively, the
ten-network median target-mean distance is 2.8125697307643103 +/-
0.0040740068207280261 and 2.366086756487185 +/- 0.10325940369466809 state
units; corresponding field speeds are 71.315916550959855 +/-
3.5461375242593514 and 24.984497522243586 +/- 1.4744980900024329 state
units/s. Thus distances can decrease without movement becoming stationary.
The individual launch-state field speeds are all nonzero, spanning
44.740140810742766 to 100.14062311872787 state units/s. Launch scales span
3.9502149872777359 to 4.3284289617897773 state units.

For N1/T3 the roots' orthogonal distances from the fixed plotted plane are
0, 3.8484286759503208 and 2.4796597867356964 state units at GO, drive peak
and 400 ms. A projected off-plane equilibrium is not an equilibrium of the
plane slice; its marker need not coincide with an arrow zero. The flow
panels use common limits, common arrow scaling and equal state-space axis
units. No trajectory, root or arrow was adjusted for presentation.

## Perturbation result and interpretation

At fraction .01, potent-direction early hand error is approximately
0.5694 mm for either sign, random-direction error approximately 0.1043 mm,
and the null-class median approximately 8.8e-9 mm. The latter is a median,
not a claim that every network/target has exactly zero null-direction error;
nonzero uncertainty and all individual network values are retained.
Potent maximum neural amplification is approximately 1.93686, random
approximately 1.01452 and null exactly 1 at the ensemble median.

At fraction .20, potent early hand error rises to 11.388/11.393 mm for
negative/positive perturbations; random error is 2.086/2.084 mm and null
0.001964/0.001685 mm. Potent final-position deviation is 77.166/77.433 mm,
whereas absolute intended-target endpoint error is 77.137/77.520 mm. These
are distinct quantities and are not substituted for one another. The
unperturbed network-median absolute endpoint error is 1.610596 mm.

Signed speed changes are not forced into a deficit interpretation. For
example, .01 potent perturbations give +0.0002881/-0.0001691 m/s for the
negative/positive signs; at .20 both medians increase, by 0.034229/0.019210
m/s. Full signs, amplitudes and uncertainty appear below. These outcomes
support direction-dependent prospective motor sensitivity around x*; they
do not establish an optimum, a lesion effect or a globally null nonlinear
subspace. Q is the frozen diagnostic basis, not a modified generator.

## Independent numerical audit

| Check | Maximum discrepancy / result |
| --- | --- |
| Grid-root residual, 510 roots | 6.4837024638109142e-14 |
| Independent active-set linear root solve | 8.6435391659028947e-13 |
| Finite-difference Jacobian columns | 1.7125469931045245e-9 |
| Representative independent metrics, 1,200 cases | 3.5527136788005009e-15 |
| Native integration increments | 4.4408920985006262e-16 |
| Independently recomputed bootstrap SE | 2.886579864025407e-14 |
| Projected full-vector-field arrows | 5.6843418860808015e-14 |
| Direction normalization, Q eigensystem, amplitude and seeds | PASS |
| Root deduplication, reciprocal same-mask continuation and midpoints | PASS |
| Exact-drive nearest stable-root distances for every trajectory | PASS |
| Independent arm kinematics and 2x2 dynamic updates | PASS |

All thresholds are the predeclared values in PLAN.md. No numerical
discrepancy required a scientific change or tolerance relaxation.

The cache-only neural norm time-course summary passed all 180 independent
bootstrap spot checks (maximum SE difference 3.6082248300317588e-16).
It contains 599 saved times for all ten networks, three direction classes,
both signs and six amplitudes, with no additional model replay.

Post-computation preservation PASS at 2026-09-15T11:19:50.4098096Z:
all 1,154 pre-existing protected files remained byte-identical. The earlier
in-run preservation receipt is retained separately. Final display-only
edits touch exclusively the two new figure pairs, not protected inputs.

## Figure and file organization

Two new pairs only:

- `plots/stage_1/diagnostics/movement_landscape/fig/diagnostic_9_movement_landscape.fig`
- `plots/stage_1/diagnostics/movement_landscape/png/diagnostic_9_movement_landscape.png`
- `plots/stage_1/diagnostics/movement_landscape/fig/diagnostic_10_launch_sensitivity.fig`
- `plots/stage_1/diagnostics/movement_landscape/png/diagnostic_10_launch_sensitivity.png`

The first rendered pair set was reopened and its 24 sensitivity error-bar
series, distance summaries and field arrows matched saved arrays exactly.
Visual inspection prompted only a display refinement: darker/longer arrows
using one common scale, moving the flow-symbol legend away from the neural
path, and consistent amplitude bounds/ticks and grouped legend columns.
Equal axis units preserve the geometry of the orthonormal flow plane.
No numerical output changed. The renderer's explicit `replaceNewPairs=true`
option replaces only these two new pairs from independently audited caches;
the default refuses existing outputs. It is not authority to overwrite
accepted figures after review.

New analysis implementation: twelve `landscape_*.m` helpers under
`analysis/published_generator/`; one renderer under
`figures/published_generator/`. All thirteen passed Code Analyzer before
initial rendering; the final changed renderer is checked again. Existing
Stage-1 implementation, public runners and all Stage-2/3 code stay unchanged.
README.md, AGENTS.md and MODEL_SPEC.md receive additive diagnostic
documentation; .gitignore only admits the four new figure assets.

Compact current evidence is local/ignored in
`results/stage_1/current/movement_landscape_diagnostic/`: ten network
metric/eigenvector bundles, full summary MAT, three CSV tables, native-norm
time-course summary MAT and validation/production receipts. All raw evidence
is retained in `results/stage_1/cache/movement_landscape_diagnostic/`:
ten baseline bundles, ten equilibrium-search bundles and fifty perturbation
bundles. No existing file was deleted or moved. No cleanup of another model
or historical evidence was performed. Reports, preservation manifests,
validation receipts, new code and the two figure pairs are checkpoint content;
large numerical payloads retain the existing local-only policy.

Final rendering PASS: both revised FIGs reopened; all 24 sensitivity
error-bar series, the distance-summary errors, common-scale field arrows and
equal flow-axis units exactly matched their saved definitions. Both final
PNGs were visually inspected. FIGURES_FINAL.json and VISUAL.json are the
current figure receipts; FIGURES.json retains the first cache-only render
check, not a competing figure set. STATIC_FINAL.json verifies the final
renderer after its display-only changes. No old figure was replaced.

Native Notion publication/readback PASS: Stage-1 parent retains all four
children, Results retains all eight old images, and Diagnostics retains its
two old images plus the two new uploads (four total). All 252 formatted
sensitivity summaries matched their saved values in the published tables;
the seven metric tables are in one disclosure section. Captions include
the non-autonomous/launch-state framing and off-plane-root caveat. Parent,
Technical Specification, Presentation-ready Summary and the Results
cross-reference were updated in place. No Stage-2/3 scientific page changed.

The first image transfer was explicitly rejected for an incorrect multipart
MIME type; a fresh upload with the correct image/png part succeeded. Final
readback confirmed exactly two new native images, without duplicate figures.

## Git checkpoint boundary

Immediately before staging, normal origin fetch succeeded. Current branch
and upstream remained v3-romano-hennequin / origin/v3-romano-hennequin;
local main, HEAD and both direct remote main/v3 refs remained at the starting
checkpoint. Only this v3 worktree was present; main was not checked out
elsewhere. No Git lock was present. The only existing-file changes were
the three documentation files and five additive .gitignore lines. No old
scientific/code/result/figure file was modified or removed. Diff whitespace
checks passed; ordinary LF-to-CRLF notices were informational.

Stage only the reviewed new diagnostic code, manifest/report receipts and
four figure files plus those four existing-file edits. Use one normal v3
commit/push, then fast-forward main only if it has no unique commits and
push it normally. No force, reset, amend, rebase or history rewrite. The
verified post-push SHA, all-ref equality and clean status belong in the
external final handoff/log receipt, avoiding a self-referential second
documentation commit. No later model or analysis is authorized.

## Complete sensitivity summaries

All values are network median +/- bootstrap SE of the network median (10
networks; 10,000 fixed resamples). Columns are fractions of median pairwise
launch-state separation. Signs refer to the predeclared eigenvector/random
orientation. Values are printed to seven significant digits; the 252-row
local CSV and SUMMARY.json preserve full saved precision. Zero-amplitude
amplification is undefined, not one. No inferential tests were added.

### Native maximum neural amplification

| Class / sign | 0 | .01 | .025 | .05 | .10 | .20 |
| --- | --- | --- | --- | --- | --- | --- |
| Potent - | undefined | 1.936861 +/- 0.06461326 | 1.936861 +/- 0.06461906 | 1.936861 +/- 0.06464093 | 1.936861 +/- 0.06467507 | 1.936822 +/- 0.06470143 |
| Potent + | undefined | 1.936861 +/- 0.06460598 | 1.936861 +/- 0.06460078 | 1.936855 +/- 0.06459791 | 1.936828 +/- 0.06458653 | 1.936663 +/- 0.06408621 |
| Null - | undefined | 1.000000 +/- 0 | 1.000000 +/- 0 | 1.000000 +/- 0 | 1.000000 +/- 0 | 1.000000 +/- 0 |
| Null + | undefined | 1.000000 +/- 0 | 1.000000 +/- 0 | 1.000000 +/- 0 | 1.000000 +/- 0 | 1.000000 +/- 0 |
| Random - | undefined | 1.014523 +/- 0.006350477 | 1.014523 +/- 0.006350078 | 1.014523 +/- 0.006349433 | 1.014523 +/- 0.006348547 | 1.014523 +/- 0.006347082 |
| Random + | undefined | 1.014523 +/- 0.006351139 | 1.014523 +/- 0.006351588 | 1.014523 +/- 0.006352310 | 1.014523 +/- 0.006353610 | 1.014521 +/- 0.006355988 |

### Early hand RMS (mm)

| Class / sign | 0 | .01 | .025 | .05 | .10 | .20 |
| --- | --- | --- | --- | --- | --- | --- |
| Potent - | 0 +/- 0 | 0.5694072 +/- 0.01928590 | 1.423499 +/- 0.04827225 | 2.846948 +/- 0.09683322 | 5.693819 +/- 0.1941146 | 11.38772 +/- 0.3894200 |
| Potent + | 0 +/- 0 | 0.5694202 +/- 0.01926032 | 1.423579 +/- 0.04810297 | 2.847273 +/- 0.09602242 | 5.695198 +/- 0.1914175 | 11.39323 +/- 0.3807880 |
| Null - | 0 +/- 0 | 8.803336e-9 +/- 0.00006207533 | 2.200358e-8 +/- 0.0001570729 | 4.398545e-8 +/- 0.0003335353 | 0.0002180860 +/- 0.0007253330 | 0.001964284 +/- 0.001784391 |
| Null + | 0 +/- 0 | 8.807018e-9 +/- 0.00006104763 | 2.376133e-8 +/- 0.0001578686 | 5.771442e-8 +/- 0.0003334722 | 0.0002410481 +/- 0.0007059071 | 0.001684532 +/- 0.001636154 |
| Random - | 0 +/- 0 | 0.1042555 +/- 0.009994765 | 0.2606471 +/- 0.02498645 | 0.5213189 +/- 0.04997084 | 1.042727 +/- 0.09999052 | 2.085822 +/- 0.2001880 |
| Random + | 0 +/- 0 | 0.1042511 +/- 0.009994995 | 0.2606194 +/- 0.02498794 | 0.5212110 +/- 0.04997743 | 1.042311 +/- 0.09996780 | 2.084176 +/- 0.1999932 |

### Final position deviation (mm)

| Class / sign | 0 | .01 | .025 | .05 | .10 | .20 |
| --- | --- | --- | --- | --- | --- | --- |
| Potent - | 0 +/- 0 | 3.873489 +/- 0.2034819 | 9.682603 +/- 0.5046701 | 19.36029 +/- 0.9969392 | 38.69099 +/- 1.953833 | 77.16642 +/- 3.844916 |
| Potent + | 0 +/- 0 | 3.873935 +/- 0.2057547 | 9.685410 +/- 0.5187035 | 19.37181 +/- 1.047283 | 38.74011 +/- 2.140126 | 77.43333 +/- 4.496040 |
| Null - | 0 +/- 0 | 0.00007531395 +/- 0.0003247538 | 0.0001891708 +/- 0.0008125622 | 0.0004550504 +/- 0.001622880 | 0.002666904 +/- 0.003087286 | 0.01126324 +/- 0.006773506 |
| Null + | 0 +/- 0 | 0.00007483315 +/- 0.0003240530 | 0.0001860772 +/- 0.0008154618 | 0.0003674320 +/- 0.001656139 | 0.001602084 +/- 0.003341549 | 0.007152275 +/- 0.007064159 |
| Random - | 0 +/- 0 | 0.7544323 +/- 0.05941531 | 1.885294 +/- 0.1486933 | 3.767998 +/- 0.2979014 | 7.525266 +/- 0.5978549 | 15.00742 +/- 1.203191 |
| Random + | 0 +/- 0 | 0.7548521 +/- 0.05933222 | 1.887929 +/- 0.1481745 | 3.778480 +/- 0.2958193 | 7.567137 +/- 0.5895024 | 15.17464 +/- 1.170423 |

### Signed peak-speed change (m/s)

| Class / sign | 0 | .01 | .025 | .05 | .10 | .20 |
| --- | --- | --- | --- | --- | --- | --- |
| Potent - | 0 +/- 0 | 0.0002880690 +/- 0.0001280704 | 0.0009455490 +/- 0.0003255820 | 0.002636099 +/- 0.0006695605 | 0.008623768 +/- 0.001239594 | 0.03422901 +/- 0.003884160 |
| Potent + | 0 +/- 0 | -0.0001691431 +/- 0.0001278228 | -0.0002280324 +/- 0.0003258127 | 0.0001760832 +/- 0.0006993608 | 0.003280802 +/- 0.001722304 | 0.01920984 +/- 0.005449603 |
| Null - | 0 +/- 0 | -2.060921e-14 +/- 1.534525e-8 | -5.165660e-14 +/- 4.779864e-8 | -1.030905e-13 +/- 1.680603e-7 | -2.063356e-13 +/- 8.733265e-7 | -6.232744e-7 +/- 0.000004504996 |
| Null + | 0 +/- 0 | -1.523781e-14 +/- 1.672438e-8 | -3.852196e-14 +/- 7.108540e-8 | -7.710499e-14 +/- 2.725916e-7 | -2.556268e-13 +/- 9.936197e-7 | -5.111418e-13 +/- 0.000004049310 |
| Random - | 0 +/- 0 | -0.00003277423 +/- 0.00002207489 | -0.00007587748 +/- 0.00005499674 | -0.0001311863 +/- 0.0001079279 | -0.0001779861 +/- 0.0002096716 | 0.0001139769 +/- 0.0003976439 |
| Random + | 0 +/- 0 | 0.00003666415 +/- 0.00002211376 | 0.00009821836 +/- 0.00005564773 | 0.0002170114 +/- 0.0001130351 | 0.0005188550 +/- 0.0002333060 | 0.001381223 +/- 0.0004953738 |

### Intended-target endpoint error (mm)

| Class / sign | 0 | .01 | .025 | .05 | .10 | .20 |
| --- | --- | --- | --- | --- | --- | --- |
| Potent - | 1.610596 +/- 0.08676261 | 4.241584 +/- 0.1785398 | 9.765645 +/- 0.4608369 | 19.36869 +/- 0.9452078 | 38.68371 +/- 1.903797 | 77.13653 +/- 3.802960 |
| Potent + | 1.610596 +/- 0.08676261 | 4.204089 +/- 0.2582141 | 9.843564 +/- 0.5863011 | 19.47138 +/- 1.122525 | 38.82212 +/- 2.216532 | 77.52011 +/- 4.576726 |
| Null - | 1.610596 +/- 0.08676261 | 1.610581 +/- 0.08684785 | 1.610529 +/- 0.08697154 | 1.610381 +/- 0.08716511 | 1.610334 +/- 0.08751932 | 1.611660 +/- 0.08833854 |
| Null + | 1.610596 +/- 0.08676261 | 1.610594 +/- 0.08667490 | 1.610534 +/- 0.08653654 | 1.610278 +/- 0.08628833 | 1.609552 +/- 0.08576378 | 1.607950 +/- 0.08455013 |
| Random - | 1.610596 +/- 0.08676261 | 1.770290 +/- 0.08522869 | 2.424635 +/- 0.1389037 | 4.061111 +/- 0.2651128 | 7.713210 +/- 0.5852857 | 15.13914 +/- 1.236381 |
| Random + | 1.610596 +/- 0.08676261 | 1.782572 +/- 0.09132361 | 2.416363 +/- 0.1997465 | 3.969563 +/- 0.3057993 | 7.599157 +/- 0.5623157 | 15.15150 +/- 1.132171 |

### Endpoint-error change (mm)

| Class / sign | 0 | .01 | .025 | .05 | .10 | .20 |
| --- | --- | --- | --- | --- | --- | --- |
| Potent - | 0 +/- 0 | 2.509949 +/- 0.1484753 | 8.097555 +/- 0.4184078 | 17.70060 +/- 0.9019217 | 37.01562 +/- 1.860613 | 75.32390 +/- 3.772032 |
| Potent + | 0 +/- 0 | 2.343538 +/- 0.2611063 | 7.981969 +/- 0.5611626 | 17.71155 +/- 1.084461 | 37.15403 +/- 2.176057 | 75.85202 +/- 4.532140 |
| Null - | 0 +/- 0 | -3.863381e-12 +/- 0.00001751456 | -9.929911e-12 +/- 0.00004875909 | -9.060899e-12 +/- 0.0001286213 | -1.799807e-11 +/- 0.0004059260 | 2.491844e-11 +/- 0.001498315 |
| Null + | 0 +/- 0 | 1.541153e-12 +/- 0.00001682692 | 4.442659e-12 +/- 0.00004546116 | 8.894307e-12 +/- 0.0001154022 | 3.854456e-11 +/- 0.0002595116 | 1.358695e-13 +/- 0.0008159968 |
| Random - | 0 +/- 0 | 0.1531683 +/- 0.05672771 | 0.8287118 +/- 0.1795105 | 2.428082 +/- 0.3174459 | 6.054330 +/- 0.5659790 | 13.66674 +/- 1.122377 |
| Random + | 0 +/- 0 | 0.1663112 +/- 0.03190024 | 0.8466851 +/- 0.1162251 | 2.430196 +/- 0.2011113 | 6.158586 +/- 0.4544241 | 13.81488 +/- 1.005588 |

### Torque RMS (source units)

| Class / sign | 0 | .01 | .025 | .05 | .10 | .20 |
| --- | --- | --- | --- | --- | --- | --- |
| Potent - | 0 +/- 0 | 0.008435469 +/- 0.0002369671 | 0.02108834 +/- 0.0005925963 | 0.04217562 +/- 0.001185807 | 0.08434734 +/- 0.002374774 | 0.1686742 +/- 0.004755269 |
| Potent + | 0 +/- 0 | 0.008435656 +/- 0.0002368496 | 0.02108952 +/- 0.0005919206 | 0.04218051 +/- 0.001183336 | 0.08436808 +/- 0.002363452 | 0.1686788 +/- 0.004728788 |
| Null - | 0 +/- 0 | 0.000001666114 +/- 0.000001858090 | 0.000004216551 +/- 0.000004640008 | 0.000008567969 +/- 0.000009348015 | 0.00002046463 +/- 0.00001978987 | 0.00006431798 +/- 0.00004628768 |
| Null + | 0 +/- 0 | 0.000001621930 +/- 0.000001862991 | 0.000004069832 +/- 0.000004648129 | 0.000008229524 +/- 0.000009235339 | 0.00002066425 +/- 0.00001811041 | 0.00005891655 +/- 0.00003522503 |
| Random - | 0 +/- 0 | 0.001426883 +/- 0.00005271578 | 0.003567214 +/- 0.0001317806 | 0.007134417 +/- 0.0002635418 | 0.01426869 +/- 0.0005269824 | 0.02853681 +/- 0.001053893 |
| Random + | 0 +/- 0 | 0.001426879 +/- 0.00005271726 | 0.003567195 +/- 0.0001317927 | 0.007134415 +/- 0.0002635874 | 0.01426896 +/- 0.0005271968 | 0.02853870 +/- 0.001054295 |

## All 80 target-level landscape summaries

Distances are native state-space Euclidean norms. Normalized minima divide
by the network's median pairwise launch separation; speed is full-state
units/s. Every row has stable-root coverage 1 and proximity flag false.

| Network | Target | Minimum distance | Minimum / launch scale | Final distance | Minimum field speed |
| --- | --- | --- | --- | --- | --- |
| 1 | T1 | 2.080173 | 0.4805837 | 2.417847 | 20.13311 |
| 1 | T2 | 3.249962 | 0.7508411 | 3.451491 | 30.93175 |
| 1 | T3 | 2.449860 | 0.5659928 | 2.449860 | 24.16771 |
| 1 | T4 | 1.938496 | 0.4478520 | 1.938496 | 17.16987 |
| 1 | T5 | 2.478103 | 0.5725179 | 2.478103 | 22.96289 |
| 1 | T6 | 2.658668 | 0.6142338 | 2.658668 | 27.17893 |
| 1 | T7 | 2.895633 | 0.6689801 | 2.895633 | 31.90370 |
| 1 | T8 | 2.120701 | 0.4899471 | 2.120701 | 23.45334 |
| 2 | T1 | 2.525571 | 0.6119913 | 2.660293 | 21.52579 |
| 2 | T2 | 2.830002 | 0.6857605 | 2.830002 | 25.77983 |
| 2 | T3 | 2.272391 | 0.5506413 | 2.272391 | 22.12351 |
| 2 | T4 | 2.060849 | 0.4993809 | 2.060849 | 19.67043 |
| 2 | T5 | 2.123670 | 0.5146035 | 2.123670 | 19.33694 |
| 2 | T6 | 2.238180 | 0.5423513 | 2.238180 | 22.74182 |
| 2 | T7 | 2.818559 | 0.6829877 | 2.818559 | 25.12624 |
| 2 | T8 | 1.688572 | 0.4091715 | 1.688572 | 19.02982 |
| 3 | T1 | 2.467030 | 0.5886100 | 2.467030 | 22.43174 |
| 3 | T2 | 2.641480 | 0.6302321 | 2.641480 | 31.53436 |
| 3 | T3 | 2.613166 | 0.6234767 | 2.613166 | 30.20589 |
| 3 | T4 | 2.357063 | 0.5623729 | 2.357063 | 23.06770 |
| 3 | T5 | 2.556688 | 0.6100016 | 2.634398 | 23.99157 |
| 3 | T6 | 2.517959 | 0.6007611 | 2.517959 | 28.07451 |
| 3 | T7 | 2.403315 | 0.5734081 | 2.403315 | 28.35031 |
| 3 | T8 | 2.364610 | 0.5641736 | 2.364610 | 23.77630 |
| 4 | T1 | 2.982574 | 0.7071194 | 3.149031 | 30.96482 |
| 4 | T2 | 3.121328 | 0.7400158 | 3.419225 | 32.33688 |
| 4 | T3 | 2.346889 | 0.5564089 | 2.346889 | 24.91654 |
| 4 | T4 | 2.370981 | 0.5621208 | 2.370981 | 23.81090 |
| 4 | T5 | 2.891534 | 0.6855353 | 3.126169 | 28.45281 |
| 4 | T6 | 2.847556 | 0.6751089 | 3.184723 | 29.58054 |
| 4 | T7 | 2.474528 | 0.5866701 | 2.474528 | 24.74218 |
| 4 | T8 | 2.212875 | 0.5246363 | 2.212875 | 27.75285 |
| 5 | T1 | 1.958764 | 0.4958627 | 1.958764 | 18.08722 |
| 5 | T2 | 2.206902 | 0.5586789 | 2.206902 | 22.98323 |
| 5 | T3 | 2.158665 | 0.5464677 | 2.158665 | 22.84637 |
| 5 | T4 | 1.663344 | 0.4210768 | 1.663344 | 18.80953 |
| 5 | T5 | 1.557878 | 0.3943779 | 1.557878 | 16.93227 |
| 5 | T6 | 2.238619 | 0.5667081 | 2.238619 | 22.59803 |
| 5 | T7 | 2.188622 | 0.5540515 | 2.188622 | 21.28829 |
| 5 | T8 | 1.695959 | 0.4293334 | 1.695959 | 19.20040 |
| 6 | T1 | 2.075916 | 0.5166352 | 2.075916 | 17.14152 |
| 6 | T2 | 2.226554 | 0.5541248 | 2.226554 | 22.91057 |
| 6 | T3 | 2.241929 | 0.5579511 | 2.241929 | 23.52592 |
| 6 | T4 | 1.750844 | 0.4357342 | 1.750844 | 19.05736 |
| 6 | T5 | 1.561785 | 0.3886830 | 1.561785 | 16.75383 |
| 6 | T6 | 2.053796 | 0.5111303 | 2.053796 | 22.15173 |
| 6 | T7 | 2.190513 | 0.5451551 | 2.190513 | 22.63725 |
| 6 | T8 | 1.728119 | 0.4300786 | 1.728119 | 18.31025 |
| 7 | T1 | 2.240982 | 0.5569033 | 2.240982 | 20.66460 |
| 7 | T2 | 2.984947 | 0.7417847 | 3.041187 | 32.69915 |
| 7 | T3 | 2.707293 | 0.6727854 | 2.707293 | 30.45282 |
| 7 | T4 | 1.769871 | 0.4398281 | 1.769871 | 20.55604 |
| 7 | T5 | 1.894287 | 0.4707464 | 1.894287 | 18.03081 |
| 7 | T6 | 2.619347 | 0.6509301 | 2.619347 | 27.69055 |
| 7 | T7 | 2.841029 | 0.7060200 | 2.841029 | 28.21880 |
| 7 | T8 | 2.050875 | 0.5096599 | 2.050875 | 23.15558 |
| 8 | T1 | 2.169439 | 0.5095123 | 2.169439 | 22.70547 |
| 8 | T2 | 2.866211 | 0.6731553 | 2.948240 | 28.22799 |
| 8 | T3 | 2.463067 | 0.5784734 | 2.463067 | 30.31549 |
| 8 | T4 | 1.799524 | 0.4226344 | 1.799524 | 23.33024 |
| 8 | T5 | 2.063670 | 0.4846715 | 2.063670 | 20.02260 |
| 8 | T6 | 2.607955 | 0.6125015 | 2.607955 | 28.02268 |
| 8 | T7 | 2.542938 | 0.5972317 | 2.542938 | 29.08941 |
| 8 | T8 | 2.031014 | 0.4770018 | 2.031014 | 23.22154 |
| 9 | T1 | 2.491946 | 0.6076364 | 2.750065 | 24.65891 |
| 9 | T2 | 2.577444 | 0.6284842 | 2.577444 | 30.99399 |
| 9 | T3 | 2.790062 | 0.6803291 | 2.790062 | 32.79130 |
| 9 | T4 | 2.408582 | 0.5873088 | 2.408582 | 22.89616 |
| 9 | T5 | 2.151075 | 0.5245184 | 2.151075 | 20.28230 |
| 9 | T6 | 2.221783 | 0.5417598 | 2.221783 | 25.38803 |
| 9 | T7 | 2.527736 | 0.6163633 | 2.527736 | 25.71943 |
| 9 | T8 | 2.376232 | 0.5794207 | 2.376232 | 21.21348 |
| 10 | T1 | 1.875458 | 0.4588101 | 1.875458 | 17.83532 |
| 10 | T2 | 2.529146 | 0.6187275 | 2.529146 | 24.50469 |
| 10 | T3 | 2.059745 | 0.5038939 | 2.059745 | 22.88886 |
| 10 | T4 | 1.884679 | 0.4610658 | 1.884679 | 19.01232 |
| 10 | T5 | 1.743717 | 0.4265811 | 1.743717 | 17.69143 |
| 10 | T6 | 2.294129 | 0.5612333 | 2.294129 | 22.94232 |
| 10 | T7 | 2.401693 | 0.5875476 | 2.401693 | 23.04932 |
| 10 | T8 | 1.976041 | 0.4834167 | 1.976041 | 20.51914 |
