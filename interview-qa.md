# Interview Q&A — 5 per day, my own words

**Rule:** answer out loud in ~60 seconds *before* writing. Then write only the 3-line version.
**Test:** if an answer needs a diagram to make sense, you don't know it yet.

Format: tick the box, replace the `↳` line with your answer.

---

## Day 1 — Web & API basics

- [x] **What happens between typing a URL and seeing a response?**
      ↳ DNS: stub resolver → recursive resolver → root → TLD → authoritative, returns an IP (cached at several levels).
      ↳ TCP 3-way handshake to port 443; TLS 1.3 handshake (ClientHello/ServerHello, certificate check, Finished) derives symmetric keys; ALPN picks h2.
      ↳ HTTP request (method, path, headers, optional body) → server → status line, headers, body → browser parses and renders.
- [x] **Which HTTP methods are idempotent, and why does it matter for retries?**
      ↳ GET, HEAD, PUT, DELETE, OPTIONS repeat without changing state; POST creates a new thing each time.
      ↳ Idempotency is about server *state*, not the response — a second DELETE may return 404 but nothing changed.
      ↳ So a client can safely retry an idempotent call after a timeout; POST needs an `Idempotency-Key` the server remembers.
- [x] **401 vs 403 — what's the difference and why is it a security distinction?**
      ↳ 401 = identity not established or credentials rejected → "authenticate".
      ↳ 403 = identity known, permission missing → "don't retry with the same credentials".
      ↳ Which one you return leaks information: 403 confirms a resource exists, 404 hides it, which is why some APIs return 404 instead.
- [x] **What is a trust boundary in a backend?**
      ↳ Any point where data crosses from a less-trusted zone into a more-trusted one: browser→server, edge→internal, service→service, third party→me.
      ↳ Everything crossing it is untrusted until validated on the server; client-side validation is UX only, since an attacker skips the UI.
      ↳ Validate on every request, because statelessness means each request must prove itself.
- [x] **Difference between REST and "an HTTP API"? When would you not use REST?**
      ↳ REST is a style: resources with URIs, representations (JSON), uniform interface via HTTP methods, statelessness, hypermedia (Link headers).
      ↳ An HTTP API may just tunnel RPC — `POST /createUser`, verbs in URLs, one endpoint per action.
      ↳ Skip REST for non-CRUD commands, chatty screens that need one round trip (GraphQL/BFF), and realtime (WebSocket/SSE).

## Day 2 — Terminal, OS, environment, Git

- [x] **SIGTERM vs SIGKILL — why try the polite one first?**
      ↳ SIGTERM is catchable: the process runs a handler, stops accepting work, drains in-flight requests, closes resources, exits 0 — or exits 143 if it has no handler.
      ↳ SIGKILL cannot be caught: the kernel destroys the process mid-instruction, so nothing is flushed and locks/temp files are left behind.
      ↳ So: SIGTERM, wait a grace period scaled to your slowest request, escalate to SIGKILL only if it's still alive.
- [x] **What does `.gitignore` prevent, and what can it not undo?**
      ↳ It stops **untracked** files from being added — nothing else.
      ↳ Files already committed stay tracked: `git rm --cached <file>` stops tracking but the content stays in history.
      ↳ That's why a committed secret must be rotated, not just deleted.
- [x] **What is `PATH`, and why does a command "not found" sometimes mean "not on PATH"?**
      ↳ A colon-separated list of directories the shell searches **in order**; first match wins.
      ↳ "command not found" means no executable of that name was found in any listed directory — missing install, wrong venv, or a directory that was never added.
      ↳ A venv works by prepending `.venv/bin`, which is why activation is per-shell only.
- [x] **`git revert` vs `git reset --hard` — which is safe on a shared branch?**
      ↳ `revert` creates a **new** commit that undoes the target, leaving history intact — safe after pushing.
      ↳ `reset --hard` moves the branch pointer and discards working-tree changes — local history surgery that erases work from everyone who pulls.
      ↳ Recovery for a bad reset is `git reflog`, while the old position is still referenced.
- [x] **Why do secrets belong in env vars instead of source code?**
      ↳ Source code gets copied, forked, pasted into tickets and captured in logs; git history makes removal impossible without rewriting.
      ↳ Env vars are injected per environment, so the same image runs in dev and prod with different credentials, and rotation doesn't need a code change.
      ↳ They're not a vault though — readable at `/proc/<pid>/environ` and inherited by every child, so production secrets belong in a secret manager.

## Day 3 — Server, async & API design

- [ ] **Blocking vs non-blocking — what does the event loop actually do?**
      ↳
- [ ] **Why does one slow blocking handler hurt unrelated concurrent requests?**
      ↳
- [ ] **Why does middleware order matter? Give a concrete failure.**
      ↳
- [ ] **Where does input validation live, and why not in the database?**
      ↳
- [ ] **Signing a JWT vs encrypting it — which one is it, and what does that imply?**
      ↳

## Day 4 — Database, performance & background jobs

- [ ] **When does adding an index make things slower?**
      ↳
- [ ] **Offset vs cursor pagination — why does offset degrade at page 10,000?**
      ↳
- [ ] **What is the N+1 query problem and how do you fix it?**
      ↳
- [ ] **Cache-aside vs write-through — tradeoffs, and why is invalidation hard?**
      ↳
- [ ] **Why must a background job be idempotent?**
      ↳

## Day 5 — Security, testing & production readiness

- [ ] **Why Argon2/bcrypt instead of SHA-256 for passwords?**
      ↳
- [ ] **What does CORS actually protect, and what doesn't it protect?**
      ↳
- [ ] **When does CSRF apply, and why doesn't it apply to Bearer-token APIs?**
      ↳
- [ ] **Liveness vs readiness — what does an orchestrator do differently with each?**
      ↳
- [ ] **Why centralize error handling, and what must never reach the client?**
      ↳
