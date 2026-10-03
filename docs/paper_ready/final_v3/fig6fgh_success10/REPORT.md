# Success-first representative movement display revision

PAPER-MODELLING-FIG6FGH-SUCCESS-PATH-10, 3 October 2026. The UPDATED 3 Oct section of Agent Instructions supersedes the 2 Oct mean-trajectory-RMS display selection. This revision changes only representative f–h displays and their documentation. No model, simulation, parameter, aggregate behavior, inference, manuscript, unrelated figure or existing source file is changed. The single existing-file edit is the authorized current-panel navigation pointer.

## Selection outcome

Network **8**, Intact-only network score **0.0007875659342411926 m** (0.7875659342411926 mm). Network 8 is ranked first among all ten by the mean of eight five-selected-trial Intact target scores. Full-precision ranking and all eighty Intact target scores are saved.

Target **6**. No target has at least ten successes in both conditions. The mandatory fallback chooses target 6 because min(18 Intact,7 Block)=7 uniquely exceeds every other target's minimum. Its ten-selected-Intact score is **0.0019923392754508775 m**. Intact quality/target-ID tie-breaks were not needed. Block is used only for target availability, not network selection or quality scoring.

| Target | Success Intact / Block | f Intact IDs | f Block IDs |
|---|---|---|---|
| 1 | 24 / 5 | 19, 9, 18, 7, 10 | 30, 28, 11, 10, 4 |
| 2 | 20 / 5 | 7, 18, 24, 16, 12 | 17, 19, 1, 18, 11 |
| 3 | 22 / 1 | 2, 22, 3, 20, 9 | 12, 19, 28, 16, 18 |
| 4 | 21 / 0 | 3, 11, 1, 8, 4 | 25, 22, 4, 13, 1 |
| 5 | 22 / 0 | 14, 1, 15, 11, 24 | 28, 9, 27, 16, 25 |
| 6 | 18 / 7 | 23, 27, 22, 5, 1 | 13, 23, 24, 17, 30 |
| 7 | 18 / 0 | 25, 8, 6, 1, 23 | 20, 22, 12, 11, 10 |
| 8 | 20 / 3 | 4, 17, 14, 15, 25 | 13, 21, 7, 3, 24 |

For g/h, the same ordered local IDs are used: Intact **23,27,22,5,1,17,11,4,18,7**; Block **13,23,24,17,30,12,18,22,7,3**. All ten Intact trials succeed; Block uses seven successes then three unsuccessful fill-ins (22,7,3). Global target-6 IDs are local ID+150. This is an outcome-selected illustration, not typicality or an inferential claim.

## Files and source definitions

Current native pairs are in `plots/paper_ready/final_v3/fig6fgh_success10/{fig,png}/`: **Fig6f**, **Fig6g**, **Fig6h**. [Full legends](LEGENDS.md) distinguish selected examples from all-30 terminated summaries and the unchanged n=10 peak-speed/n=6 speed-matched dispersion assays.

Compact evidence under `results/paper_ready/final_v3/fig6fgh_success10/`:

- `network_ranking.csv`, `all_intact_target_scores.csv`, `target_eligibility.csv`.
- `all_trial_rankings.csv`: all 4,800 network/condition/target/trial rows, success, rank, local/global ID, ideal-segment path RMS, saved onset, display end/index and unsmoothed peak time.
- `Fig6f_selected_trials.csv`, `Fig6gh_selected_trials.csv`, `Fig6h_all30_inset.csv`, `selection.json`.
- `validation.json`, `render_validation_final.json`.

Nine new MATLAB files implement frozen-array loading, success-first ideal-segment selection, rendering and independent audits. Existing read-only loader/CSV/JSON/FIG-check helpers are reused; old mean-trajectory-RMS selection is never called. The locally retained `display_sources.mat` is a derived display convenience file, excluded from the checkpoint. [Retained dependencies](DEPENDENCIES.md) document non-versioned inputs and the reuse of validated primary Intact sources.

## Validation outcome

PASS:

- Separate scalar cross-product/endpoint distance implementation checked all **4,800** trial rankings; maximum path-RMS discrepancy **5.5511151231257827e-17 m**. Network ranking and selected target reproduced independently.
- All **4,800** saved kinematic movement-onset events matched their frozen native definition; none produced an undefined ranking interval.
- Independent all-30 mean/median/inset checks passed; maximum mean discrepancy **0**. Selected peaks are unsmoothed and within the retained prefix. Poisoning every discarded source sample leaves every derived selected-network display field exactly unchanged.
- Six endpoint/tie/eligibility/fallback fixtures passed.
- **142** plotted source objects checked; all **12** current FIGs reopened, with source/error-bar checks. Five current compact scientific/statistical MAT bundles remained readable.
- Exact target palette, exact sky-blue/vermillion condition colors, common f axes/aspect, matching g/h IDs, all-30 inset and no automatic legend entries verified.
- Every final PNG visually inspected: clear titles/units/legend/scale bars, no label clipping, no aggregate-statistics subplot. The initial long subtitles were shortened using saved display sources only; selection and plotted arrays did not change. Final FIGs were reopened after this repair.
- Code Analyzer: **9 files, zero findings**. An initial indentation-only warning was repaired before any source calculation; its receipt and ignored logs remain provenance.
- Preservation: **3,895** original files retain metadata and **2,222** retain audited SHA256. The sole exempt original is the navigation-only current-panel index. All twenty primary raw inputs are SHA256 protected; no retained dependency was deleted.
- Native Notion PNG downloads are byte-identical to local outputs. New source-table cell strings match saved full-precision CSVs. Unrelated Notion sections, current g/h aggregate-statistics blocks and all historical f–h content remain unchanged; only explicit historical labels were added.

The current four-level i/j, corrected inference, geometry, prediction, movement and n=6 eligibility remain unchanged. No inferential calculation was invoked.

## Storage and publication

No broad cleanup was repeated. Only the six preliminary title-layout files created by this revision were removed after final source-identical figures passed validation; exact paths/hashes are in `temporary_deletions.json`. These uncommitted drafts are not Git-recoverable, but contain no unique scientific arrays or evidence. All pre-existing files and dependencies remain intact.

The final-v3 Notion gallery contains the current three native panels, full captions, network/target ranking and selected-trial/inset tables. Prior 2 Oct and original displays are explicitly historical; aggregate manuscript values remain current.

## Checkpoint boundary

Start: main = origin/main = direct remote main = **54c965d8083dd51b30b4b67894d2a5ec6a62e439**. Only this revision's code/docs/compact CSV/JSON/native FIG-PNG files and the current-panel pointer are eligible for staging. Do not include raw/derived MAT caches, signed URLs, ignored logs or unrelated pre-existing untracked review bundles.

After reviewed staging, make one normal main commit and push. The actual containing commit SHA, final folder-size measurement, ref equality and tracked worktree/index state are recorded in the post-push Notion log/handoffs and local `git_final.json`; this document does not predict an unverified SHA. STOP FOR SCIENTIFIC REVIEW. No release/tag replacement or v3-branch synchronization.
