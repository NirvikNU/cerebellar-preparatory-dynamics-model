# STAGE3-DIAGNOSTIC-GAIN-TIME-01: bounded Git metadata repair

Authority: current Notion task revision 2026-09-09T16:42:28.165Z.
Inspection: 2026-09-09 16:43 UTC. Starting worktree/index clean.

The previously reported `.git/packed-refs.lock`, `.git/refs/codex/desktop.ini`,
`.git/refs/heads/desktop.ini`, and `.git/refs/remotes/origin/desktop.ini` were
already absent. This agent did not remove them or infer who did. No Git process
was active in the Win32 process inventory. Unrelated SSH processes were not
terminated; the configured origin uses HTTPS. No lock removal is necessary.

Exactly two remaining invalid ref artifacts were inventoried:

1. `.git/refs/codex/turn-diffs/captures/1788972194719/desktop.ini`
2. `.git/refs/codex/turn-diffs/captures/1788972194719/327c45cd-4256-4890-913b-6500087bcdea/desktop.ini`

Each is 246 bytes, creation and modification UTC
`2026-09-04T21:34:49.9553124Z`, SHA-256
`F0EA3329B14D0B0412ACDED346E63C2B3715C4B1082070D7B2BA0BD41A7E1592`.
The exact bytes of each are preserved here as base64:

```text
WwAuAFMAaABlAGwAbABDAGwAYQBzAHMASQBuAGYAbwBdAA0ACgBDAG8AbgBmAGkAcgBtAEYAaQBsAGUATwBwAD0AMAANAAoASQBjAG8AbgBSAGUAcwBvAHUAcgBjAGUAPQBDADoAXABQAHIAbwBnAHIAYQBtACAARgBpAGwAZQBzAFwARwBvAG8AZwBsAGUAXABEAHIAaQB2AGUAIABGAGkAbABlACAAUwB0AHIAZQBhAG0AXAAxADMAMAAuADAALgAyAC4AMABcAEcAbwBvAGcAbABlAEQAcgBpAHYAZQBGAFMALgBlAHgAZQAsADIANwANAAoA
```

Decoded UTF-16LE content:

```ini
[.ShellClassInfo]
ConfirmFileOp=0
IconResource=C:\Program Files\Google\Drive File Stream\130.0.2.0\GoogleDriveFS.exe,27
```

These are filesystem icon metadata, not object IDs or symbolic refs. One direct
`git ls-remote --symref origin` returned only legitimate branches/tags, no
desktop.ini refs. Remote default is main. Before repair local/tracking/direct
remote main is `f3c85bf5bfea06868a7360e2370d4d29a5ab62c5`; local/tracking/direct
remote v3-romano-hennequin is `65816fa4052f55982ba92cc7d9f9cea2a916eaa8`.

Repair is limited to these exact two files after rechecking their hashes and
absence of active Git processes. Valid ref-file hashes and packed-refs/HEAD
will be compared across deletion. No object, reflog, legitimate ref, branch,
tag or repository setting is an authorized deletion target.

## Outcome: execution-permission stop before deletion

The single bounded PowerShell deletion command was rejected before process
creation: `Rejected(... rejected: blocked by policy)` from exec_command.
This is an execution-layer refusal, not a new lack of user authorization and
not a filesystem error observed while deleting. No alternate deletion API,
shell, patch, rename or other bypass was attempted.

A targeted read-only follow-up confirmed both inventoried 246-byte files
remain and packed-refs.lock remains absent. Removed paths: **none**. The
planned in-command protected-ref hash comparison did not execute; no such
validation is claimed. Post-repair show-ref/fsck/fetch were not run because
the prerequisite repair did not occur. No scientific work, rendering,
organization/cleanup, stage, commit, push or branch synchronization occurred.

Final worktree change is only this new untracked report; index and tracked
files are unchanged. Existing branches still match the direct remote SHAs
listed above. The previous run established main has zero unique commits and
is 16 commits behind v3; a new post-repair ancestry acceptance is pending.
The report retains recoverable original artifact bytes and exact targets.
Resume only after the execution restriction is resolved or those invalid
artifacts are manually removed, then complete the authorized integrity/fetch
and branch checks before any diagnostic computation.
