# Current versus preserved Stage-2 outputs

`neural_geometry_r2/` is the sole current source for Results Figure 3,
Diagnostic Figure 1 and Diagnostic Figure 2, subject to its validation receipt.
It uses detected kinematic MO, reference sample SD without a source-unit floor,
correct epoch-specific target centering, and the common strictly >95%-variance
PC-count rule. `run_stage_2('analyze')`, `figures` and `validate` route here.

The original `analysis.mat`, `summary.json`, `network_metrics.csv`,
`network_paired_metrics.csv`, `planned_tests.csv` and original analysis audit
are preserved from commit4938fe927b59a04322f018d5e8742d9047213c02.
Their floor/K15/GO=MO PR/alignment fields are historical and superseded by R2.
Do not mix their neural metrics with current R2 values. The original
controller/error/effort/perturbation values, simulation configuration,
protected hashes and cache manifests remain valid and unchanged, as do
Results Figures1-2. R2 does not recompute their motor-error statistical family.

No scientific acceptance is implied. Large caches remain local-only;
R2 can regenerate its three figure pairs from its compact saved analysis.
