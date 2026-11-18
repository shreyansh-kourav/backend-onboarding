# Git workflow — commands and real output

Run in a throwaway directory (`/tmp/git-lab`) so the exercise never touched this repo's history. Output is abridged where Git is verbose; commands and results are untouched.

---

## 1. Init and first commit

```console
$ git init -b main -q
$ printf 'def greet():\n    return "hello"\n' > app.py
$ git add app.py
$ git commit -m 'feat: add greet'
[main (root-commit) 0203c01] feat: add greet
 1 file changed, 2 insertions(+)
 create mode 100644 app.py
$ git log --oneline
0203c01 feat: add greet
```

`-b main` names the branch at creation instead of renaming after. `-q` only silences the "Initialized empty repository" banner.

---

## 2. Branch, change, commit

```console
$ git switch -c feat/timeout
Switched to a new branch 'feat/timeout'
$ printf '\nTIMEOUT = 30\n' >> app.py
$ git commit -am 'feat: add 30s timeout'
[feat/timeout e50ea90] feat: add 30s timeout
 1 file changed, 2 insertions(+)
```

Then on `main`, a **conflicting** change to the same lines:

```console
$ git switch main
Switched to branch 'main'
$ printf '\nTIMEOUT = 60\n' >> app.py
$ git commit -am 'fix: raise timeout to 60'
[main 5b2730f] fix: raise timeout to 60
 1 file changed, 2 insertions(+)
```

`-a` stages already-tracked files only — it never adds a new untracked file.

---

## 3. Deliberate merge conflict, then resolve

```console
$ git merge feat/timeout
Auto-merging app.py
CONFLICT (content): Merge conflict in app.py
Automatic merge failed; fix conflicts and then commit the result.
$ git status --short
UU app.py
```

`UU` = "both modified". The file on disk now contains both sides:

```console
$ cat app.py
def greet():
    return "hello"

<<<<<<< HEAD
TIMEOUT = 60
=======
TIMEOUT = 30
>>>>>>> feat/timeout
```

`HEAD` is the branch I'm on (`main`, 60). The other side is what I'm merging in (`feat/timeout`, 30). Resolution:

```console
$ git add app.py          # after editing the file and deleting all three markers
$ git commit -m 'merge: resolve timeout conflict in favour of 30s'
[main 4fb061e] merge: resolve timeout conflict in favour of 30s
$ git log --oneline --graph
*   4fb061e merge: resolve timeout conflict in favour of 30s
|\
| * e50ea90 feat: add 30s timeout
* | 5b2730f fix: raise timeout to 60
|/
* 0203c01 feat: add greet
```

The merge commit has **two parents**, which is why the graph forks. Resolving was not a Git action — Git only asked me to produce a file with no markers; the decision about which value survives was mine.

---

## 4. Undo three ways

### `restore` — discard working-tree changes (safe, local)

```console
$ echo '# scratch' >> app.py
$ git status --short
 M app.py
$ git restore app.py
$ git status --short
```

Output is empty → back to `HEAD`. Nothing was committed, nothing rewritten.

### `revert` — undo a published commit (safe on a shared branch)

```console
$ git commit -am 'feat: enable debug flag'
[main ecbb8e4] feat: enable debug flag
$ git revert --no-edit HEAD
[main d42bd09] Revert "feat: enable debug flag"
 1 file changed, 2 deletions(-)
$ git log --oneline -3
d42bd09 Revert "feat: enable debug flag"
ecbb8e4 feat: enable debug flag
4fb061e merge: resolve timeout conflict in favour of 30s
```

`revert` didn't delete history — it appended a commit that reverses the change. That's the only option that's safe once others have your commits.

### `reset --hard` — discard a commit and its contents (local only)

```console
$ git commit -am 'chore: add scratch file (to be discarded)'
[main 4a32bde] chore: add scratch file (to be discarded)
$ git reset --hard HEAD~1
HEAD is now at d42bd09 Revert "feat: enable debug flag"
```

The `scratch.txt` commit is gone from the branch and the file is gone from disk. `HEAD~1` = "one commit before HEAD". This is the command to be scared of; `git reflog` is the recovery path while the commit is still referenced there.

---

## 5. What I'd actually use when

| Situation | Command | Why |
|---|---|---|
| Edited a file and want it back | `git restore <file>` | Never touched history |
| Staged something by mistake | `git restore --staged <file>` | Keeps the edits, unstages |
| Bad commit already pushed | `git revert <sha>` | Doesn't rewrite shared history |
| Bad local commit, not pushed | `git reset --soft HEAD~1` | Keeps the changes staged to re-commit |
| Wrong commit message | `git commit --amend` | Only if it isn't pushed |
| Lost a commit after a reset | `git reflog` | Finds the old `HEAD` position |
