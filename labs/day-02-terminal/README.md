# Day 2 — Terminal, OS & developer environment

**Done when:** you can do a full day of work without leaving the terminal, and you know which of your own muscle-memory commands are destructive.

Files to complete in this folder:

| File | What it is |
|---|---|
| [`cheatsheet.md`](cheatsheet.md) | ~30 commands in your own words |
| [`scripts/backup.sh`](scripts/backup.sh) | A small script that actually works and fails safely |
| `git-workflow.md` | The exact command sequence + real output |
| `process-port-demo.md` | Transcript of finding and killing a process on a port |

---

## `git-workflow.md`

Run each of these and paste the real output (abbreviated where long). The point is that you've *done* it, not that you've copied docs.

### 1. Init and first commit
```bash
# TODO
```

### 2. Branch, change, commit
```bash
# TODO
```

### 3. Deliberate merge conflict, then resolve
```bash
# TODO
```
What conflicted, and why:

### 4. Undo three ways
```bash
git restore <file>          # discard working changes
git reset --hard <commit>   # move branch back, destroy work
git revert <commit>         # make a new commit that undoes it
```
Which of these is safe on a shared branch, and why:

---

## `process-port-demo.md`

1. Start something on a port:
2. Find it:
   ```bash
   ss -tulpn | grep 3000
   lsof -i :3000
   ```
3. Kill politely: `kill <PID>` — what did the process do?
4. Kill rudely: `kill -9 <PID>` — what was different?

Transcript:

```text
TODO
```

Why SIGTERM first:

---

## Self-test (answer out loud)

- [ ] SIGTERM vs SIGKILL — why the order matters
- [ ] What `.gitignore` prevents, and what it cannot undo
- [ ] What `PATH` is and what a "command not found" often means
