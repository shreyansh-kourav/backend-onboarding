# Day 2 — hands-on evidence

Notes for this day live in [`docs/day_02/`](../../docs/day_02/):

| Note | Covers |
|---|---|
| [00. Terminal and File Operations](../../docs/day_02/00.%20Terminal%20and%20File%20Operations.md) | navigation, file ops, `rm -rf` failure modes, pipes, globs |
| [01. Permissions in Linux](../../docs/day_02/01.%20Permissions%20in%20Linux.md) | `rwx` on files vs directories, octal/symbolic `chmod`, `chown`, `umask` |
| [02. Signals and Processes](../../docs/day_02/02.%20Signals%20and%20Processes.md) | signal table, graceful shutdown, `ps`/`ss`/`lsof` |
| [03. ENVs and PATH](../../docs/day_02/03.%20ENVs%20and%20PATH.md) | inheritance, `PATH`, `export`, `.env` |
| [04. Python Ecosystem](../../docs/day_02/04.%20Python%20Ecosystem.md) | venv, pip, `pyproject.toml`, lockfiles, uv |
| [05. Git Fundamentals](../../docs/day_02/05.%20Git%20Fundamentals.md) | staging areas, undo, `.gitignore`, merge conflicts, remotes |

This folder is the evidence: the script, the transcripts, the cheatsheet.

---

## Checklist

- [x] **Command cheatsheet** — ~50 commands, own words, destructive ones marked → [`cheatsheet.md`](cheatsheet.md)
- [x] **Working script** — `scripts/backup.sh`, safe by construction → tested below
- [x] **Git transcript** — init, branch, conflict, revert, restore, reset, real output → [`git-workflow.md`](git-workflow.md)
- [x] **Process/port transcript** — SIGTERM vs SIGKILL, four ways to find a PID → [`process-port-demo.md`](process-port-demo.md)
- [x] **Self-test** — answered in [`interview-qa.md`](../../interview-qa.md) Day 2

## Files

| File | What's in it |
|---|---|
| [`cheatsheet.md`](cheatsheet.md) | Every command from the plan, with "when I'd use it" and the dangerous flags called out |
| [`scripts/backup.sh`](scripts/backup.sh) | Timestamped tar of a directory; `set -euo pipefail`, argument count check, existence/readability checks, usage text |
| [`git-workflow.md`](git-workflow.md) | Real console output for the full Git exercise |
| [`process-port-demo.md`](process-port-demo.md) | Real console output for the signal/port exercise |

## The script

```bash
./scripts/backup.sh <source-dir> [dest-dir]
# dest-dir defaults to <parent-of-source>/backups
```

Guards: `set -euo pipefail`; rejects wrong argument count (exit 2); rejects a missing or unreadable source and an unwritable destination (exit 1); `${1%/}` strips a trailing slash so `dirname`/`basename` behave; every expansion is quoted, so paths with spaces survive.

Test runs:

```console
$ ./scripts/backup.sh
usage: backup.sh <source-dir> [dest-dir]
  dest-dir defaults to <parent-of-source>/backups
exit=2

$ ./scripts/backup.sh /tmp/demo/does-not-exist
error: source directory not found: /tmp/demo/does-not-exist
exit=1

$ ./scripts/backup.sh /tmp/demo/project /tmp/demo/backups
created /tmp/demo/backups/backup-20261118-230410-project.tar.gz (4.0K)

$ tar -tzf /tmp/demo/backups/backup-20261118-230410-project.tar.gz
project/
project/read me.txt
project/src/
project/src/app.py
```

The `read me.txt` entry is the point: a file with a space in its name survives because nothing is unquoted.

## What the evidence establishes

1. **`rm -rf` has no undo** — the cheatsheet's guards (`:?`, `--`, quote everything) exist because the failure mode is silent until it isn't.
2. **SIGTERM and SIGKILL both kill; only one lets you clean up** — exit `143` vs `137`, both `128 + signal`.
3. **Ports are owned, not shared** — `ss`, `lsof` and `fuser` all agreed on PID 9509, and "Address already in use" is always a stale owner.
4. **`revert` is the shared-branch undo** — `reset --hard` rewrote local history and destroyed a commit; `revert` appended one.

## Self-test

Answered in [`interview-qa.md`](../../interview-qa.md), Day 2 — SIGTERM vs SIGKILL · what `.gitignore` can't undo · what `PATH` is · `revert` vs `reset --hard` · why secrets are env vars and not source.
