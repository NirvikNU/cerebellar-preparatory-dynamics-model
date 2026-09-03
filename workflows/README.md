# Workflow entry points

The repository root contains only normal stage entry points. Noncanonical
operations are grouped here:

- `stage_1/construction/`: one-time target validation, construction, and
  rejection-sampling workflows. These must not be rerun without authorization.
- `diagnostics/`: accepted-stage diagnostics and deterministic presentation
  regeneration workflows.
- `history/`: superseded cross-controller presentation runners retained only
  for provenance.

Every runner discovers the project root from its own location and is therefore
independent of the MATLAB working directory.

`src/published_generator/source_target_torque_objective.m` is deliberately
retained. Static caller search is not sufficient evidence that this historical
source-equivalence helper is unnecessary, so Gate 3A makes no deletion claim
about it.
