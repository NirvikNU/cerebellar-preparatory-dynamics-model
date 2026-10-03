# Retained display and manuscript dependencies

No previously retained dependency was deleted. The prior [bulk-cleanup inventory](../fig6fgh_cleanup09/DEPENDENCIES.md) remains authoritative for local non-versioned quantitative inputs.

## Direct inputs to this revision

- `results/paper_ready/final_v3/summary.mat`: read only `s.targetXY`.
- `results/paper_ready/cache/fig6fgh_successful11/reservoir/p{1,2}_t{1..8}/batch_*.mat`: saved network-8 visualization-only attempts, including failed attempts, with hand positions/velocities, native speed, success/event/RMS and seed metadata. Corresponding per-batch audit JSONs must pass.
- Existing `results/paper_ready/final_v3/fig6fgh_successful11/attempts_p*_t*.csv` (target-5 Block uses `partial_p2_t5_attempts.csv`): exact ledger cross-check.
- Visualization seed family, inherited and independently verified: `610000000 + 1000000*condition + 10000*target + attemptID`. No random number generator or model was invoked.
- Frozen MO is the first saved sample reaching 20% of that trial's full-horizon native speed maximum. Trajectories have 600 saved 1-ms movement samples; RMS ranking uses MO through first target entry. The h peak event uses native GO-through-entry speeds. No event/scientific definition was changed.

## New code and local-only derived cache

The seven `fd13_*.m` files use only `v2_csv.m`, `paper_json.m`, and read-only `pv_figure_check.m`. No recursive model-path setup or archived controller is called. `fd13_run` is the fresh-directory builder; `fd13_finish` is the documented cache-only audit/render continuation after a syntax-only audit fix. Existing output protection prevents accidental overwrite of finished native figures.

`results/paper_ready/cache/fig6fgh_final13/display_sources.mat` is an ignored/local derived display cache, not a scientific simulation and not staged. Durable CSVs, JSON receipts, code, captions and FIG/PNG pairs are included in the intended checkpoint. A fresh Git checkout alone is insufficient to reproduce all figures: the named non-versioned raw attempts and existing model/controller/reference/stochastic dependencies must be restored separately. All are preserved locally. The prior task11 untracked code/evidence is left untouched and not swept into this commit.

## Quantitative sources protected but not recomputed

All original final-v3 panel sources/statistical corrections and four-level i/j outputs are retained. SHA256 preservation covers all non-cache files, every task11 reservoir artifact, and twenty primary all-trial Intact/Block movement caches (stabilization_eta raw_n01..10_e5_p1 and final_v2 raw_n01..10_v2_p4). Other large ignored caches are inventoried and checked by size/mtime. Their status is not misrepresented as a full content-hash audit.

All twelve current FIGs reopen from their existing paths. The current ZIP copies existing scientific source tables unchanged and adds only display-selection/provenance tables. No canceled request is assigned a scientific outcome.
