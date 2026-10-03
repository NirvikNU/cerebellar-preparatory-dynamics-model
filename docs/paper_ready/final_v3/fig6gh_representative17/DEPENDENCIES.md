# Retained dependencies and cleanup scope
This successor changes Fig6g/h presentation only. Inputs are read-only:
- results/paper_ready/cache/fig6fgh_highrms14/display_sources.mat: native successful hands, events, speed, phase paths, peak positions, seeds and IDs. Derived reproducibility cache, ignored/local.
- results/paper_ready/cache/fig6fgh_successful11/reservoir/: original attempts, including all failures and the separate canceled-request record. Retained, ignored/local.
- results/paper_ready/final_v3/fig6h_diffuse16/Fig6h_all30_inset.csv: previous uncommitted target6 all30 source used as an additional audit identity check; preserved.
- analysis/paper_ready/paper_json.m and analysis/paper_ready/final_v2/v2_csv.m: committed serialization helpers.
- MATLAB R2025b: native figure export, smoothdata Gaussian50, mt19937ar selection stream.
The new compact CSVs record the complete all30 peak positions, selection strata/IDs, displayed native paths/raw speed traces and all median/support arrays. The raw saved-hand cache is not uploaded or staged. Existing scientific/quantitative source tables are copied byte-identically into the downloadable current source ZIP, not recomputed. Full raw scientific reproducibility still requires the pre-existing local caches documented in prior dependency ledgers.
No broad storage cleanup is authorized by the current Notion section. Keep every original file and earlier uncommitted review bundle. The only existing file allowed to change is CURRENT_PANEL_INDEX.md; its starting dirty version is preserved in BEFORE_CURRENT_PANEL_INDEX.md. No deletions are currently planned. All new artifacts are classified as code, compact display source, audit, documentation or native figure; only the derived MAT stays ignored.
