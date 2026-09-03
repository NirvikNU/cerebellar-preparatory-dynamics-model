# Third-Party Provenance

## Published source

Stage 1 is grounded in Kao, Sadabadi & Hennequin, *Neuron* 2021, "Optimal
anticipatory control as a theory of motor preparation: A thalamo-cortical
circuit model," and the official repository:

`https://github.com/hennequin-lab/optimal-preparation`

The source of truth is pinned at commit
`40077d2da16e68ab2ab2cff59ec692b97315980b`. The upstream repository did not
contain a software license file or license declaration when audited; the
paper itself is available under CC BY 4.0. Preserve attribution and do not
assume an unexpressed software license.

## License-safe project-local cache

The repository tracks only attribution, pinned identifiers, checksums, and
acquisition/verification instructions under
`third_party/kao_optimal_preparation/`. The upstream checkout, generated
native export, paper PDF, exporter working copy, and local toolchain are kept
under the Git-ignored `third_party/kao_optimal_preparation/local_cache/` and
must not be added to ordinary Git history.

The pinned upstream checkout is at:

`third_party/kao_optimal_preparation/local_cache/kao_optimal_preparation`

The setup and verification entry points are
`third_party/kao_optimal_preparation/setup_local_cache.ps1` and
`third_party/kao_optimal_preparation/verify_local_cache.ps1`.

## Native reference realization

The official reach, ISN, and setup programs were executed once in a clean
two-core GitHub Codespace using OCaml 4.10.0 and the upstream dependencies.
The first successful default-RNG realization was retained; there was no seed
hunting.

The verified reference package's canonical project-local ignored location is:

`third_party/kao_optimal_preparation/local_cache/kao_optimal_preparation/native_reference_40077d2`

It contains 167 files totaling 32,508,468 bytes. Transfer and manifest checks
reported zero mismatches. The transferred archive SHA-256 was
`339172D55FF2B3395673E8605859553A3A55C6C61A7C8B32A2B4850EC53EC6B7`.

The folder was restored and reverified on 2026-08-26 and relocated without
content change on 2026-09-03: all 167 manifest entries and 32,508,468 payload
bytes matched their recorded SHA-256 values. Smoke validation uses this
project-local ignored native reference directly.

The package contains full-precision recurrent weights, spontaneous state,
baseline drive, eight optimal initial states, motor readout, movement input,
arm parameters, native trajectories, costs, and prospective Gramian.

## MATLAB translation boundary

The active MATLAB implementation imports the verified package and reproduces
the published forward dynamics. It does not construct, optimize, retrain, or
replace the cortical generator. Native-to-MATLAB equivalence must remain a
hard Stage 1 requirement.
