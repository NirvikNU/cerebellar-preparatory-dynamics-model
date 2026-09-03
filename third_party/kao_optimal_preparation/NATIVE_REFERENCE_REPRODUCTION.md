# Native numerical-reference reproduction

The accepted native package was generated once from the pinned upstream
revision in a clean two-core GitHub Codespace. The first successful default-RNG
realization was retained; there was no seed search.

The environment used OCaml 4.10.0, the historical opam repository state at
`d5e60ce7f7dc4c2357ae7cf52bdaecd5a747fec0`, `cmdargs` at
`054467255de411996f56a402ee9068facf477abb`, and `owl-opt` components at
`c3b34072dddbce2d70e1698c5f1fd84d783f9cef`. SUNDIALS 3.1.1 was built
separately because Ubuntu 24's SUNDIALS 6 headers are incompatible with the
historical `sundialsml` dependency.

From the pinned checkout, the native programs were run in this order:

```sh
mkdir -p results
dune exec construct/reaches.exe -- -d results
dune exec soc/construct.exe -- -d results
dune exec construct/setup.exe -- -d results
```

The project exporter was then built in a detached worktree and run as:

```sh
dune exec stage1_export/export_stage1.exe -- \
  -d /workspaces/optimal-preparation/results \
  -out /workspaces/optimal-preparation/results/stage1_full_precision
```

The resulting package contains 167 manifest-controlled files and 32,508,468
payload bytes. A local transfer archive, when available, must have SHA-256
`339172D55FF2B3395673E8605859553A3A55C6C61A7C8B32A2B4850EC53EC6B7`.
Every unpacked file is checked against `native_reference_manifest.tsv`.

The export cannot be regenerated from a fresh clone by one command without
reconstructing this historical OCaml dependency environment and using the
project-specific exporter. Because the upstream software has no identified
redistribution license, neither its source nor the generated package is
vendored here. A collaborator must obtain an authorized local native archive
from the project maintainers or reproduce it using the environment above.
