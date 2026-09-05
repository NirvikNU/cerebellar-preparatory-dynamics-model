# Historical Gate-4B cache-generation provenance

This directory is **historical and non-executing**, not an alternative
Stage-2B-Cerebellum implementation. The `.m.txt` file preserves the interrupted
Antigravity network-analysis source with only trailing spaces and an extra EOF
blank line removed to pass the staged whitespace check. Its non-whitespace
content is identical; the exact original is retained in the Gate-4E recovery
folder and its SHA-256 is recorded in the cleanup inventory. It is not on
the MATLAB path and is not a current entry point.

Its valid dense movement/error time courses were recovered in Gate 4B-C.
Its controller-summary call described Kao, not Cerebellum; other inherited
Kao analysis branches and extra configuration dependencies are not part of
the accepted Cerebellum audit. Do not execute the snapshot as a current
workflow or infer new phenotype results from it. The superseded ensemble
wrapper and summary helper were removed in Gate 4E.

The sole active controller derivation is
`src/stage_2b_cerebellum/derive_stage2b_cerebellum_controller.m`; the accepted
audit is `analysis/stage_2b_shared/audit_stage2b_cerebellum_gate4b.m`, called by
`run_stage_2b_cerebellum.m` only when a scientific audit replay is authorized.
The final plotting function is
`figures/stage_2b_shared/create_stage2b_cerebellum_gate4b_figures.m`.

Keep the original valid local cache:
`results/stage_2b_cerebellum_gate4a_work/current/per_network/network_01_gate3_result.mat`
through `network_10_gate3_result.mat`. Despite historical filenames, the
accepted audit reads their labeled three-controller performance rows, never
their superseded controller summary. Their Stage-1/Stage-2A cache hashes and
the accepted output hashes are recorded in the saved audit and Gate-4E
manifest. The aggregate `gate4b_ensemble_results.mat` is retained only as
historical provenance; it is not a current accepted result or controller save.

All accepted controllers and summaries are in
`results/stage_2b_cerebellum/current/`. Numerical payloads remain local and
ignored. The original `network_01_gate3_result.mat` exceeds 50 MiB and must
not be staged. Gate-4E classification and recovery reasons are in
`artifacts/manifests/gate4e/cleanup_inventory.csv`.
