# Gate 3A validation report

Validation date: 2026-09-03 (Asia/Jerusalem).

## Repository and dependency integrity

- Relocated local cache: 241/241 files match the pre-change path/size/SHA-256
  set; embedded upstream HEAD remains
  `40077d2da16e68ab2ab2cff59ec692b97315980b`.
- Native package: 167/167 manifest entries and 32,508,468 bytes verified.
- `git fsck --full`: exit 0; only harmless dangling blobs, trees, and commits.
- MATLAB Code Analyzer before scientific validation: 111 files, 0 findings.
- Final code/provenance manifest: 125 files; SHA-256
  `31071252074BC980FAB36CDFCE501803B92BB8B56F3394DD5D54BF29B433C927`.

## Stage 1

- Status: PASS.
- Accepted networks: 10/10; accepted target rows: 80/80.
- Maximum difference from the saved acceptance audit: `4.8849813e-15`.
- Native five-sample maximum absolute difference: `2.2204460e-16`.
- Q/Lyapunov relative residual: `7.3452314e-14`.
- Canonical FIG files reopened: 8/8.

The revalidator's stale construction-work-tree lookup was corrected to the
accepted `results/stage_1/current/` tree before this check.

## Stage 2A

- Status: PASS.
- Networks: 10/10; locally stable fixed points: 80/80.
- Analytical tonic-input maximum difference: `0`.
- Complete 5-second normalized state-error trajectory maximum difference: `0`.
- Complete 5-second prospective-Q trajectory maximum difference: `0`.
- Maximum difference from saved network audit: `3.8163916e-17`.
- Worst accepted 5-second endpoint error: `0.001342707962174 m`.
- Canonical FIG files reopened: 5/5.

## Stage 2B-Kao

- Status: PASS.
- Independently rederived/reloaded controllers: 10/10.
- Maximum gain reload difference: `0`.
- Maximum CARE residual: `1.4886307e-14`.
- Maximum fixed-point residual: `1.9472717e-15`.
- Maximum directional Jacobian relative error: `6.2267008e-9`.
- Worst target-specific spectral abscissa: `-0.74881646 s^-1`.
- Median observed/expected alignment: `0.35608885 / 0.70068751`.
- BH-significant alignment networks: 10/10.
- Canonical figure pairs: 9.

## Current diagnostics

- Gate-2 exact frozen-regime rows: 72/80.
- Gate-2 switching rows: 8/80.
- Target-union Jaccard equal to one: 280/280 pairs.
- Saved lambda grid: five values across ten networks.
- Saved lambda=0.1 gain/prospective/endpoint maximum differences:
  `0 / 4.9960036e-16 / 4.7184479e-16`.
- Independent network-1 component lambda=0.1 gain/prospective/endpoint
  maximum differences: `0 / 4.9960036e-16 / 4.3368087e-18`.

## Figures and frozen payloads

- Every current canonical/diagnostic FIG reopened with a matching PNG:
  36/36 total (Stage 1: 10, Stage 2A: 5, Stage 2B-Kao: 11,
  frozen Stage 2B-Cerebellum: 10).
- Pre/post scientific payload comparison: 528/528 files; zero path, size, or
  SHA-256 differences.
- Pre/post scientific manifest SHA-256:
  `C5B9B0CABD3D97B645E8B699AD80B5750C89F036488E8277A8E2718DB0A540D9`.

Stage 2B-Cerebellum was not executed or recomputed. Opening its frozen FIG
files for integrity verification did not alter the frozen payload.

## Git-checkpoint readiness

- Branch/HEAD/upstream remain
  `v3-romano-hennequin` /
  `22b183c8ddcfed8fca41aee9fdbe45c13aa17d2f` /
  `origin/v3-romano-hennequin`.
- Final unstaged inventory: 48 tracked change entries and 203 untracked files
  proposed for addition. Nothing was staged, committed, pushed, tagged, or
  moved to another branch.
- `git diff --check`: PASS. The working tree contains no `desktop.ini` files
  and no ignored files under active code roots.
- Ignored local files: 480. These include the project-local Kao cache and
  generated numerical results; they are excluded from the proposed checkpoint.
- Proposed files larger than 50 MiB: 0. Eight ignored numerical artifacts are
  larger than 50 MiB (five exceed 100 MiB), with the complete list recorded in
  `ignored_large_artifacts.csv`.
- Credential/secret-pattern scan of proposed project content: 0 findings.
