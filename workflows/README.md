# Stage-1 workflows

- `stage_1/construction/`: the successful target-layer and first-ten-passing
  construction procedures. Retained for reproducibility; do not execute
  without separate authorization. Guards prevent overwriting accepted target
  or ensemble data.
- `diagnostics/stage_1/`: bounded deterministic validation of the accepted
  ensemble. The historical filename is a preserved entry-point identifier,
  not permission to reopen an old gate.

Use explicit Stage-1 paths. Do not add the whole project or the external
archive with `genpath`. The root `run_all.m` is smoke-only; `run_stage_1.m`
performs one frozen 10-by-8 forward regression without canonical writes or
figure regeneration.

Canonical plotting code and the separated active-set diagnostic source remain
under `figures/published_generator/` and `analysis/published_generator/`.
Long analyses, construction and diagnostic bootstrap calculations are not
invoked by the validation runners. Their execution requires separate scope.

`src/published_generator/source_target_torque_objective.m` remains as a
source-equivalence helper even though the successful optimizer uses the
adjoint implementation. The native benchmark, source files, exporter and
toolchain remain the pinned dependency documented in
`THIRD_PARTY_PROVENANCE.md`.
