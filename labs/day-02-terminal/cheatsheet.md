# Command cheatsheet — my own words

Rules I set: no copy-paste from docs, and "when I'd use it" has to be a real situation from this week. **⚠️ = destructive or privilege-escalating.**

## Navigation & files

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `pwd` | Prints the absolute path I'm in | Before any `rm`, to confirm exactly where I am | — |
| `ls -la` | Lists everything, long format, hidden included | To see the `.env` and `.git` that `ls` hides | — |
| `cd` | Changes directory | Moving between repo root and `api/` | `cd` alone jumps to `$HOME` |
| `mkdir -p` | Creates a directory chain | Scaffolding `src/app/api/v1` in one go | Succeeds silently even on a typo'd path |
| `touch` | Creates an empty file or bumps mtime | Creating a module before opening the editor | On an existing file it only changes the timestamp |
| `cp -r` | Copies a directory tree | Snapshotting a config dir before editing it | Overwrites the destination with no prompt |
| `mv` | Moves or renames | Renaming the day-02 notes files | Overwrites the destination with no prompt |
| `rm` | Deletes a file | Removing a stray `.part` file | No trash — gone immediately |
| `rm -rf` | Deletes a tree, force, no prompt | Clearing `__pycache__` or `dist/` | **⚠️ No undo.** Unquoted `$VAR` or a bad glob can wipe the wrong tree |
| `cat` / `less` | Prints a file / pages through it | Reading a config or long log | `less` for anything over a screen |
| `head` / `tail -f` | First N lines / follow a growing file | Watching `app.log` while hitting an endpoint | `cmd > app.log` wipes the file you're tailing |
| `grep -r` | Searches file contents recursively | "Where is `DATABASE_URL` read?" | Add `--include='*.py'` or it reads binaries |
| `find` | Locates files by name, type, age | Finding every `__pycache__` before cleanup | Test `-exec` with `-print` first |
| `wc -l` | Counts lines | Sizing a log before reading it | Counts newlines, not records |
| `file` / `stat` | Identifies bytes / shows metadata | Confirming an upload really is a PNG | Trust `file` over the extension |
| `du -h` | Disk usage | Checking an archive or `.venv` size | Directory size ≠ sum of file sizes on all filesystems |

## Permissions

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `chmod 644` | Owner rw, group r, others r | Normal file mode, `.env.example` | Won't make a script runnable |
| `chmod 755` | Owner rwx, group rx, others rx | Directories; executable scripts | On a directory `x` means *traverse*, not execute |
| `chmod +x` | Adds execute for u/g/o | Making `backup.sh` runnable | Affects everyone — `u+x` is tighter |
| `chown` | Changes owner/group | Files created as root by a container | **⚠️** Only root can give a file to another user |
| `sudo` | Runs one command as root | Installing packages, reading another user's logs | **⚠️** `sudo rm -rf` has no safety net at all |
| `umask` | Default permission mask | Making new files private (`umask 077`) | Affects the whole shell session |

## Processes & ports

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `ps aux` | Snapshot of all processes | "What's running, as whom, since when" | `STAT=D` means stuck in I/O; `Z` is already dead |
| `top` / `htop` | Live CPU/memory view | Spotting a runaway worker during a load test | It's live, not history — no post-mortem |
| `kill` | Sends SIGTERM by default | Stopping my own dev server | Without `sudo`, only my own processes |
| `kill -TERM PID` | Requests graceful termination | First attempt, always | Process may ignore it |
| `kill -9 PID` | SIGKILL — kernel destroys it | Only after TERM was ignored | **⚠️** No handler, no flush, no cleanup |
| `kill -0 PID` | Tests existence, sends nothing | Checking if a process is still alive | Needs permission to signal it |
| `ss -tulpn` | Listening sockets with owning PID | "Address already in use" — who has my port? | `-p` hides other users' PIDs without root |
| `lsof -i :8000` | Which process owns a port | Before restarting uvicorn | Same privilege limit; needs `sudo` for others |
| `pkill -f` | Kills by command-line match | Stopping all workers of one script | **⚠️** Can match a colleague's process |
| `pgrep -af` | Finds PIDs by pattern | Locating a process without `grep` plumbing | Same over-matching risk |

## Environment

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `echo $VAR` | Prints a variable | Checking which `DATABASE_URL` is loaded | Empty output = unset *or* empty; `set -u` catches it |
| `export VAR=x` | Puts it in the environment for children | Passing config to a process | Lasts for that shell only |
| `env` | Lists the whole environment | Debugging what a process inherited | Contains secrets — don't paste it into chat |
| `unset VAR` | Removes it | Dropping a stale token in this shell | Child processes already started keep their copy |
| `which python` | Resolves the command that will run | "Is this the venv's python?" | First match on `PATH` wins |
| `source .venv/bin/activate` | Activates the virtualenv | Starting work in a project | Per shell — a new terminal is back to system Python |

## Packages & Python

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `python3 -m venv .venv` | Creates an isolated environment | Start of any project | Never commit `.venv/` |
| `python -m pip install x` | Installs into the active env | Adding a dependency | Bare `pip` may belong to a different interpreter |
| `pip freeze` | Exact versions of everything installed | Reproducing an environment | It's a lockfile, not a manifest |
| `uv sync` | Makes the env match `uv.lock` | Fresh clone, first run | In CI use `uv sync --locked` so it can't silently re-resolve |
| `uv add x` | Adds to `pyproject.toml` + lock + install | Any new dependency | Modifies two files — commit both |
| `uv run pytest` | Runs a command inside the project env | Tests without activating | Slower than a direct call for one-off scripts |
| `uv lock --check` | Verifies lock matches the manifest | Before pushing a dependency change | Fails loudly if they drifted |

## Git

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `git status` | Working tree vs index vs `HEAD` | Before every commit | Doesn't show *unpushed* commits — use `status -sb` |
| `git add .` | Stages everything under cwd | Bulk-adding a note set | Stages `.env` if it isn't ignored |
| `git add -p` | Stages hunk by hunk | Two unrelated edits in one file | Takes longer; worth it |
| `git diff` / `--staged` | Unstaged / staged changes | Reviewing before committing | `--staged` is what the commit will contain |
| `git commit -m` | Records the index as a commit | Every logical unit of work | `-a` skips untracked files |
| `git commit --amend` | Rewrites the last commit | Fixing a message before pushing | **⚠️** Never after pushing |
| `git log --oneline --graph` | History with branch topology | Understanding a merge | Long output — pipe to `head` |
| `git switch -c feat/x` | Creates and switches branch | Starting new work | Forgetting to branch first |
| `git restore file` | Discards working-tree changes | Undoing an experiment | **⚠️** Discarded work is unrecoverable |
| `git restore --staged file` | Unstages, keeps edits | Over-staging with `add .` | — |
| `git reset --hard HEAD~1` | Moves branch back and destroys work | Throwing away a local commit | **⚠️** Local only; use `reflog` to recover |
| `git revert HEAD` | New commit that undoes one | Undoing something already pushed | Creates two commits, which is correct |
| `git push -u origin main` | Pushes and sets upstream | First push of a branch | Without `-u`, later pushes need full args |
| `git reflog` | Every position `HEAD` has held | Recovering a commit after a bad reset | Only local; ~90-day retention |
