# Day 2 — Terminal, OS & developer environment

**Date:** 2026-11-18
**Time spent:** ~7h

## What I did

- Wrote six reference notes in `docs/day_02/`: terminal and file operations, Linux permissions, signals and process/port inspection, env vars and `PATH`, the Python ecosystem, and Git fundamentals.
- Built `scripts/backup.sh` — timestamped tar with `set -euo pipefail`, argument validation, source/destination checks — and tested the three failure paths plus a successful run on a tree containing a filename with a space.
- Ran the signal experiment: started a server, found its PID four ways (`ss`, `lsof`, `fuser`, `ps`), stopped it with SIGTERM (exit 143), then repeated with SIGKILL (exit 137), and reproduced `EADDRINUSE` by binding the same port twice.
- Ran the full Git exercise in a throwaway repo: init, branch, conflicting commits, merge conflict with markers, resolution, `revert`, `restore`, `reset --hard`, and read the `--graph` output.
- Filled the command cheatsheet (~50 commands) with the situations I actually hit.

## What I learned (own words)

- **Exit codes encode the signal:** a process killed by signal *N* reports `128 + N`. 143 is SIGTERM, 137 is SIGKILL, 130 is Ctrl+C. That's how a supervisor knows "it was signalled" rather than "it chose to exit".
- **Permissions on a directory are not the same as on a file.** `x` on a directory means *traverse*, and `w` on the directory is what allows deleting a file inside it — which is why a read-only file is still deletable in a writable directory.
- **`revert` and `reset` answer different questions.** `revert` asks "how do I undo this for everyone else" (new commit, history intact). `reset` asks "how do I pretend this never happened" (moves the branch, local only, `reflog` is the net).
- **Environment variables are inherited by copy.** A child cannot change its parent's environment, which is exactly why `export` is needed before launching a process and why activation is per-shell.
- **A manifest and a lockfile are different artefacts.** `pyproject.toml` says what I want within a range; `uv.lock` says exactly what I got. One is written by hand, the other generated, and both get committed.

## What broke and how I fixed it

- `git commit -am` didn't pick up `scratch.txt` — `-a` only stages **already-tracked** files. Had to `git add scratch.txt` first. Good demonstration of why `-a` is not a substitute for `add`.
- `git mv` on the day-02 notes failed until every path was quoted (`docs/day_02/day 2/...`) because of the space in the folder name. Fixed by quoting, then removed the redundant nested folder.
- `lsof -i :8765` returned nothing for a process owned by another user until I thought about privileges — the same reason `ss -p` hides other users' PIDs without `sudo`.
- The `ls -al` sample in my permissions note and the column explanation described two different listings. Rewrote it around one consistent example.

## Decisions I made and why

- **Destructive experiments stay out of this repo.** The Git conflict/revert/reset work and the port experiments ran in `/tmp`, so the real history has no throwaway branches and the repo has no test commits.
- **Used ports 87xx for the experiment**, not 8000 — 8000 is where a dev server will live on Day 3, and I didn't want the demonstration to collide with real work.
- **`backup.sh` validates before it archives** rather than after: a script that fails halfway leaves a misleading `.tar.gz` that looks like a backup.
- **Notes in `docs/day_02/`, evidence in `labs/day-02-terminal/`.** Same split as Day 1 — theory vs what I observed.

## Open questions

- `python3 -m http.server` has no shutdown handler, so SIGTERM and SIGKILL looked identical apart from the exit code. What does uvicorn actually do differently on SIGTERM — which requests get to finish, and what happens to the ones still queued?
- When a process is killed while holding port 8765, `ss` shows the socket free immediately. When does `TIME_WAIT` actually appear, and does it ever block a restart?
- Does `git pull --rebase` rewrite my commits' hashes even when there's nothing to rebase?
- If `umask` is `022`, is there any case where a *directory* should be `755` but a file inside it needs `600`? (Secrets, probably — which is why `.env` files are chmod'd explicitly.)

## Tomorrow's first task

Day 3: stand up the `api/` skeleton with routers, one middleware chain, validation, and a JWT-protected route — then run the blocking/non-blocking A/B/C experiment and record real numbers.

---

## Artifact status — [`labs/day-02-terminal`](../labs/day-02-terminal/README.md)

- [x] `cheatsheet.md` (~50 commands, own words, destructive flags marked)
- [x] `scripts/backup.sh` implemented and tested on three paths
- [x] `git-workflow.md` with real console output
- [x] `process-port-demo.md` with real console output
- [x] Self-test answered ([`interview-qa.md`](../interview-qa.md))
