# Fig6f: five balanced random success/failure review versions

## Scope

Display-only successor requested on 4 October 2026. Starting main checkpoint: 4df75056637d43e70b6c0e7c25b3f9410ee0210d. Preserve all seven prior review examples, the current manuscript Fig6f/g/h and every scientific result. No simulation, fitting, model changes, success reclassification or inferential analysis.

## Fixed sampling

Exactly the original five selection seeds, 18001-18005, each resetting mt19937ar. Visit Intact then Block and targets 1-8. For each cell, use one uniform randperm draw of three successes followed by one uniform draw of three failures, without replacement within each subset. Pool members are ordered by ascending attempt ID. No ranking, contrast/dispersion screening, seed search, rejection, reroll or preferred version. Across-version overlap is allowed. The new draws need not share successful trial IDs with the old four-success-only draws because sample size and RNG call sequence are different.

The 3+3 display is intentionally balanced; it must not be read as a 50% success probability or as an unbiased sample of all movement attempts. All trials are from frozen network 8's pre-existing visualization reservoir. The complete 12,674-attempt ledger contains 453 successes and 12,221 failures.

| Target | Intact successes | Intact failures | Block successes | Block failures |
|---|---:|---:|---:|---:|
| 1 | 30 | 5 | 30 | 155 |
| 2 | 30 | 11 | 30 | 165 |
| 3 | 30 | 19 | 30 | 360 |
| 4 | 30 | 8 | 4 | 4996 |
| 5 | 30 | 7 | 29 | 3023 |
| 6 | 30 | 20 | 30 | 75 |
| 7 | 30 | 16 | 30 | 2904 |
| 8 | 30 | 11 | 30 | 446 |

## Preserved and extended display conventions

Same eight-target palette, target zones of radius 1.5 cm, all-solid target-colored native trajectories, side-by-side conditions, equal aspect and common bounds across all five pairs. Native successful paths stop at first target entry. Native failed paths stop at the last existing sample (GO+599 ms); no new target-entry event is imputed.

The thick curve is the arithmetic mean of those exact same six displayed trajectories on the 101-point 0-1 movement-phase grid, not a median. Each successful trajectory is normalized from its existing movement onset to target entry; each failed trajectory from its existing onset to GO+599 ms. This necessary failed-trial extension is disclosed explicitly: a mixed-endpoint phase mean is not a real-time mean and is not evidence that the average trajectory reaches the target. No smoothing, failed-path omission or outcome-based axis adjustment is allowed. Shared limits derive once from the union of all five displayed draws and target zones, plus 5% padding.

## Files and reproducibility

All new paths use the isolated fig6f_balanced5_22 stem under analysis, docs, results and plots/paper_ready/final_v3. Each option has a matching native FIG and PNG named Fig6f_balanced_option{1-5}_seed{18001-18005}. Existing outputs are not overwritten.

The compact sources contain selected IDs, selection/simulation seeds, saved success flags, movement onset, actual entry time (NaN for failures), display end time and source batch; all selected native paths; all same-six phase means; true pool counts; and compact MAT records. Native hand evidence is retained in the ignored successful11 reservoir; no raw cache is staged. Existing MATLAB R2025b, paper_json.m and final_v2/v2_csv.m helpers are used unchanged. See CLEANUP_INVENTORY.md for exact dependencies.

## Validation and publication

The run's independent numerical and reopened-FIG results are recorded in results/paper_ready/final_v3/fig6f_balanced5_22/validation.json. Code Analyzer findings are in code_analyzer.json; original-file identity is in preservation_before.json and preservation_after.json. Visual and native-publication receipts accompany this report. These receipts, not the execution of a command alone, establish successful completion.

All five candidates are published in seed order on the existing Fig6f review page, with their balanced-sampling caption and source links. Current manuscript gallery content remains intact; only review navigation/status is updated. Notion Agent Log chronology is preserved, and Handoff/START receive verified outcome notes after normal main push. The exact resulting SHA is recorded there and in local Git receipts to avoid a self-referential second commit.

## Cleanup and stop

Completed numerical/object/visual audits: PASS. The 480 displayed records comprise 240 successes and 240 failures, using 370 unique existing native trials from 170 saved batches. Independent draw replay and native-hand event checks pass. Maximum independently reconstructed phase-mean difference is 4.163336342344337e-17 m. All five native FIGs reopened; 560 trajectory/mean objects verified. All five PNGs inspected without clipping/overlap. Code Analyzer: three new files, zero findings. Preservation: 9,420 old file metadata identities and 7,720 applicable SHA256 identities unchanged; only CURRENT_PANEL_INDEX.md navigation is modified among pre-existing files. All 895 unrelated untracked files remain unchanged. The shared plotted bounds are x=[-15.82179769708943,21.243273612001385] cm and y=[-19.186459664527895,15.049596355441363] cm.

No prior files, models, data, figures, negative results or ignored dependencies are removed. Keep all 895 unrelated pre-existing untracked files outside the scoped commit. No new scratch deletion is required. Normal main commit/push is authorized after validation, with local/tracking/direct remote equality and clean tracked/index state. Stop for scientific review; no candidate is automatically selected for the manuscript.
