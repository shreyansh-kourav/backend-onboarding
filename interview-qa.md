# Interview Q&A — 5 per day, my own words

**Rule:** answer out loud in ~60 seconds *before* writing. Then write only the 3-line version.
**Test:** if an answer needs a diagram to make sense, you don't know it yet.

Format: tick the box, replace the `↳` line with your answer.

---

## Day 1 — Web & API basics

- [ ] **What happens between typing a URL and seeing a response?**
      ↳
- [ ] **Which HTTP methods are idempotent, and why does it matter for retries?**
      ↳
- [ ] **401 vs 403 — what's the difference and why is it a security distinction?**
      ↳
- [ ] **What is a trust boundary in a backend?**
      ↳
- [ ] **Difference between REST and "an HTTP API"? When would you not use REST?**
      ↳

## Day 2 — Terminal, OS, environment, Git

- [ ] **SIGTERM vs SIGKILL — why try the polite one first?**
      ↳
- [ ] **What does `.gitignore` prevent, and what can it not undo?**
      ↳
- [ ] **What is `PATH`, and why does a command "not found" sometimes mean "not on PATH"?**
      ↳
- [ ] **`git revert` vs `git reset --hard` — which is safe on a shared branch?**
      ↳
- [ ] **Why do secrets belong in env vars instead of source code?**
      ↳

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
