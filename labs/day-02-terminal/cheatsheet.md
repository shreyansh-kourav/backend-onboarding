# Command cheatsheet — my own words

Rules: no copy-paste from docs. "When I'd use it" must be a real situation from this week.
Mark anything destructive with **⚠️**.

## Navigation & files

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `pwd` | | | |
| `ls -la` | | | |
| `cd` | | | |
| `mkdir -p` | | | |
| `touch` | | | |
| `cp -r` | | | |
| `mv` | | | |
| `rm` | | | |
| `rm -rf` | | | ⚠️ |
| `cat` / `less` | | | |
| `head` / `tail -f` | | | |
| `find` | | | |
| `grep -r` | | | |
| `wc -l` | | | |

## Permissions

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `chmod 644` | | | |
| `chmod 755` | | | |
| `chmod +x` | | | |
| `chown` | | | ⚠️ |
| `sudo` | | | ⚠️ |

## Processes & ports

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `ps aux` | | | |
| `top` / `htop` | | | |
| `kill` | | | |
| `kill -9` | | | ⚠️ |
| `ss -tulpn` | | | |
| `lsof -i :3000` | | | |

## Environment

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `echo $VAR` | | | |
| `export` | | | |
| `env` | | | |
| `which` | | | |
| `source .venv/bin/activate` | | | |

## Packages & Python

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `python -m venv .venv` | | | |
| `pip install` | | | |
| `pip freeze` | | | |
| `uv sync` / `uv add` | | | |

## Git

| Command | What it does | When I'd use it | Watch out |
|---|---|---|---|
| `git status` | | | |
| `git add .` | | | |
| `git commit -m` | | | |
| `git log --oneline` | | | |
| `git diff` | | | |
| `git switch -c` | | | |
| `git restore` | | | |
| `git reset --hard` | | | ⚠️ |
| `git revert` | | | |
| `git push` | | | |
