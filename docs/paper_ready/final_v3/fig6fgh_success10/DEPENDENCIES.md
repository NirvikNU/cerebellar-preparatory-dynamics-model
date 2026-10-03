# Retained source dependencies

This revision reads frozen movement arrays only. It neither simulates a model nor fits or recomputes any manuscript statistic. All dependencies retained by the previous cleanup remain in place; see [the existing dependency inventory](../fig6fgh_cleanup09/DEPENDENCIES.md).

## Direct display inputs

- Target coordinates: `results/paper_ready/final_v3/summary.mat`, `s.targetXY`.
- Intact: `results/paper_ready/cache/stabilization_eta/raw_n01_e5_p1.mat` through `raw_n10_e5_p1.mat`.
- Block: `results/paper_ready/cache/final_v2/raw_n01_v2_p4.mat` through `raw_n10_v2_p4.mat`.
- From each source, read only movement hand positions/velocities, native speed, frozen `moMs`, and identity metadata. Arrays are 600 saved milliseconds by four hand coordinates by 240 target-major trials; no large cortical array is loaded.
- Saved kinematic onset is the first native sample reaching 20% of that trial's frozen full-horizon peak speed, as defined in the existing movement implementation. This event is not redefined for display selection. The independent audit verifies the saved events. Only positions from that onset through the display end enter ideal-segment RMS.
- The accepted final-v2 loader already reuses the eta0 Intact cache: its vector field is independent of the Block equilibrium geometry. This revision preserves that validated source identity.

## Required helpers and outputs

The nine `sp10_*.m` files form the new display pipeline. They reuse only the prior read-only `mv09_load.m` source reader, `v2_csv.m`, `paper_json.m`, and read-only `pv_figure_check.m`. The old representative-selection implementation is not called. No whole-project path recursion, archived controller, or alternative scientific source is used.

`display_sources.mat` is a local derived convenience file, not a new scientific cache and not included in the checkpoint. Compact CSV/JSON tables, code, documentation and the six native FIG/PNG artifacts are the durable intended checkpoint content. The original raw caches remain local/non-versioned; the recorded primary-source hashes identify them. The existing local review/source bundles are also needed to reopen and verify the nine unrelated current panels; they are preserved, not swept into this commit.

## Preservation and storage boundary

`preserved_before.json` records every original non-Git file's size and modification time, SHA256 for non-cache evidence and all twenty primary movement inputs, and initial Git inventory. `preservation_after.json` verifies originals remain unchanged except the explicitly authorized navigation-only `CURRENT_PANEL_INDEX.md` update. No pre-existing file, historical result or retained dependency is deleted. No broad cleanup is performed. Initial/diagnostic logs remain local and are not staged.
