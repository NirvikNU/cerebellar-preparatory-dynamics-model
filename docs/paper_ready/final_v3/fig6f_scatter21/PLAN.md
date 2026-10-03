# Fig6f peak-position scatter-matched review candidate

Authority: user's 3 October2026 request to add one four-trial-per-target/condition example to the existing review page, selected to resemble the full saved successful-trial peak-speed hand-position scatter. Normal scoped commit/push main is authorized after validation. Starting checkpoint4a88f5e3034e34e9c2136172f0dc6b2514271f0b.

## Fixed objective before subset evaluation

Network8 remains fixed. Reuse the validated highrms14 display cache and its complete successful11 provenance, all453 saved successes. Availability: Intact30 per target, Block30,30,30,4,29,30,30,30. No simulation, new attempts, model/controller/noise change or scientific inference. Do not change any previous figure/source object or manuscript-facing quantitative result.

For each condition and target separately let x_i be the native unsmoothed hand position at that trial's maximum unsmoothed speed before first target entry, exactly as in the existing successful-trial display cache. No coordinate rotation, neuron normalization, speed-based criterion or pathRMS ranking is used for selection.

Define m=coordinatewise median(x), S=(1/N) sum_i (x_i-m)(x_i-m)', and D=sqrt(trace(S)), the RMS Euclidean distance to that cloud's own coordinatewise median. S is a median-centered second-moment/scatter matrix, not a sample covariance estimator. The same population denominator N (or4) applies to full/subset clouds.

Enumerate every four-trial subset without replacement. Minimize exactly

J = ||m_4-m_N||_2^2 / D_N^2 + ||S_4-S_N||_F^2 / ||S_N||_F^2.

Both normalized terms have fixed unit weights. This matches center plus overall dispersion/orientation/anisotropy without choosing a condition contrast. Trace(S) is D^2. No weight changes, score switching, appearance-based rerolls, target omission or paired-condition optimization after inspecting outcomes. Candidate trial tuples are sorted by ascending attemptID; exact-score ties choose the lexicographically first tuple. Degenerate D_N=0 implies identical positions: select the first four IDs with zero discrepancy. Report actual errors; do not require or optimize a prespecified Block-vs-Control effect.

The best match is defined only by this explicit center/second-moment criterion. Four points cannot reproduce the entire empirical distribution or establish an unbiased statistical sample. Label as scatter-matched, not random and not contrast-selected; do not claim full distributional representativeness.

## Figure and saved evidence

One new paired Intact/Block Fig6f review example, exact8-target colors,1.5-cm zones, native paths to first target entry, identical axes/aspect. Show four selected thin trajectories per target/condition with filled circles at their own peak-speed positions. Thick paths are arithmetic means of those same four after101-point MO-to-entry phase normalization, not medians. Common limits derive from all453 paths and target zones with5% padding, as in contrast20.

Save all453 peak points/membership, selected64 IDs/seeds/peaks/events, full versus selected centers/scatter matrices/D/J and exhaustive candidate counts, selected native paths, phase means, compact MAT, native FIG/PNG and validation receipts. Exhaustively validate the optimum independently from native hand evidence, including all candidate scores; do not use another search objective. Reopen native FIG, inspect PNG, Code Analyzer only new files.

## Preservation, organization, checkpoint and stop

Use dedicated fig6f_scatter21 roots. Preserve ignored/hidden/untracked dependencies, all five random alternatives, the contrast20 example, current manuscript Fig6f/g/h and12-panel statistics. No broad cleanup or old-file deletion. Add one clearly labelled example on the same Notion review page, with concise main-gallery navigation. Stage only this new compact bundle and navigation after preservation/Notion checks. Normal main commit/push; verify HEAD=tracking=direct remote and clean tracked/index; update Agent Log/Handoff/START HERE after verification. Stop for scientific review, without selecting a canonical winner.
