# Kao optimal-preparation dependency

This directory records the provenance and local acquisition contract for the
Kao, Sadabadi, and Hennequin motor-preparation implementation.

- Authoritative repository: <https://github.com/hennequin-lab/optimal-preparation>
- Pinned commit: `40077d2da16e68ab2ab2cff59ec692b97315980b`
- Runtime cache: `local_cache/` (ignored by Git)
- Upstream checkout: `local_cache/kao_optimal_preparation/`
- Native numerical reference:
  `local_cache/kao_optimal_preparation/native_reference_40077d2/`

The upstream source, generated numerical export, paper PDF, and local OCaml
toolchain are deliberately not vendored. The upstream repository did not
contain an identified software-license grant at the pinned revision. See
`LICENSE_STATUS.md` and `NATIVE_REFERENCE_REPRODUCTION.md`.

Run `setup_local_cache.ps1` to restore a cache from an existing authorized
local copy or to clone the pinned upstream source and unpack a separately
provided verified native-reference archive. Run `verify_local_cache.ps1` to
verify the commit, required source files, and all 167 native-reference files.

The accepted MATLAB workflows fail with an actionable message when this cache
is absent; they never fall back to historical result bundles.
