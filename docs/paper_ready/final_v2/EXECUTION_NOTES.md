# Execution notes — final v2

25 September 2026: initial full preservation PASS,2,871 files,
241,162,031,279 bytes; all2,327 prior protected hashes verified.

The first geometry launch stopped before numerical computation, at the first
V7.3 load inside a MATLAB thread worker: this runtime does not support that
I/O operation on thread workers. No geometry output/selection receipt existed;
the dependent completion wrapper therefore stopped without downstream work.
Logs are retained in artifacts/manifests/paper_ready/final_v2/.

Bounded implementation-only repair: load the identical frozen model,
reference, definitions, Intact preparation and null arrays in the client;
pass them as immutable inputs to the same numerical worker. Existing-cache
resume loading also moves to the client. No equation, grid, parameter, seed,
target, timing, sampling or selection rule changes. Do not repeat preservation
or the passed synthetic checks. Recheck changed-source Code Analyzer and retry
only the incomplete geometry stage after confirming no prior numerical files.

Resumption: all saved-output/static/preservation receipts completed PASS.
The user authorized Main E as a six-network conditional subset and a separate
unmatched all-ten-network source-report control. Both use saved peak positions;
no geometry selection, model replay or prediction fit was repeated. Initial
cache-only FIG repair revealed that openfig clamps large invisible canvases
to screen dimensions. Explicit original pixel dimensions restored exports;
all source-object UserData was unchanged. Final FIGs were reopened, all revised
PNGs visually reinspected, and five stray automatic legend entries removed.
The original draft FIG/PNGs remain local/ignored render provenance. All six
native Notion PNGs were read back in memory and SHA256-matched to local files.

Final preservation passed all2,871 protected files at 15:53:27 UTC. The first
inventory stopped after recording deletion of20 new zero-byte logs: git
ls-files omits nested pinned-source .git administration even under an ignored
parent, so the classifier incorrectly called that metadata untracked.
Read-only git check-ignore verified the existing local_cache ignore rule.
An inventory-only resume recognizes that verified ignored scope, retains and
verifies the existing deletion ledger, and performs no further deletion.
No Git metadata, ignore rule, scientific asset or accepted model was changed.
