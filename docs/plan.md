# Backend Onboarding — 5-Day Plan & Artifact Spec

**Stack:** Python 3.12 + FastAPI · PostgreSQL · Redis · Docker
**Pace:** full ~8-hour days
**Repo:** one repo, both journal and code focused
**Goal:** production mindset + interview readiness by Day 5

---

## The one decision that shapes everything

**Days 3–5 are one project that grows, not three throwaway labs.**

The plan quietly tells you this — Day 5 hands you the final folder layout (`routes/ controllers/ services/ models/ config/ tests/ .env`). If you build a fresh toy each day you finish with 5 disconnected folders and no story. Instead, `api/` gains a router on Day 3, a database on Day 4, and tests/Docker/CI on Day 5, so the final structure appears as a natural end state rather than a copied template. Your commit graph becomes the artifact.

---

## Contents

1. [Repo layout](#1-repo-layout)
2. [Stack lock-in](#2-stack-lock-in)
3. [Daily rhythm, journal, commits](#3-daily-rhythm-journal-commits)
4. [Day 1 — Web & API basics](#day-1--web--api-basics)
5. [Day 2 — Terminal, OS, Git](#day-2--terminal-os-environment-git)
6. [Day 3 — Server, async, API design, auth](#day-3--server-async-api-design-auth)
7. [Day 4 — Database, performance, background jobs](#day-4--database-performance-background-jobs)
8. [Day 5 — Security, testing, production readiness](#day-5--security-testing-production-readiness)
9. [Guardrails & fallbacks](#9-guardrails--fallbacks)
10. [Interview track](#10-interview-track)
11. [Your next 60 minutes](#11-your-next-60-minutes)
12. [Appendix — daily checklists](#appendix--daily-checklists)

---

## 1. Repo layout

```
backend-onboarding/
├── README.md                  # day table + quickstart, updated daily
├── journal/day-01.md … day-05.md, retrospective.md
├── interview-qa.md            # +5 Q/day in your own words
├── labs/day-01-http/          # notes, Postman export, *.http
├── labs/day-02-terminal/      # cheatsheet.md, scripts/
├── docs/                      # api-design, database, performance,
│                              # security, testing, operations, openapi.json
└── api/
    ├── app/{main.py, core/, api/v1/, models/, schemas/, services/, db/, workers/}
    ├── alembic/  scripts/{seed.py, loadtest.py}  tests/{conftest.py, …}
    ├── pyproject.toml  .env.example  Dockerfile  docker-compose.yml  .dockerignore
    └── .github/workflows/ci.yml
```

**Mapping to the org's template** (so you can explain it in review): their `routes/controllers` ≈ FastAPI's `api/routers` + `services/`.

---

## 2. Stack lock-in

Decide once, on Day 2, and don't switch.

| Concern | Pick | Why / note |
|---|---|---|
| Env & deps | `.venv` + **uv** (`uv pip install`) or pip fallback | `pyproject.toml` is the single source of deps |
| Web | `fastapi`, `uvicorn[standard]` | `--reload` in dev only |
| Config | `pydantic-settings` (`BaseSettings` + `.env`) | Makes the `.env` lesson concrete |
| DB | **SQLAlchemy 2.0 (sync) + psycopg3**, `alembic` | Sync avoids async-DB debugging eating Day 4; FastAPI runs `def` endpoints in a threadpool — which becomes your Day 3 experiment |
| Validation | `pydantic` v2 (`BaseModel`, `Field`, `field_validator`) | Returns **422** by default — ties into Day 1's 400-vs-422 |
| Auth | `PyJWT` + `pwdlib[argon2]` (or `bcrypt`) | Avoid `passlib` + bcrypt 4.x friction; avoid `python-jose` |
| Cache | `redis` (async client) | Cache-aside written by hand, not hidden behind a decorator |
| Jobs | **ARQ** (or a 40-line `worker.py` loop) | Celery covered as *concept* in your interview doc; don't burn 2h on broker config |
| Tests | `pytest`, `httpx`, `pytest-asyncio`, `dependency_overrides` | The override trick is the thing to learn |
| Quality | `ruff` (lint + format) | One tool, no config debate |
| Ops | Docker multi-stage, `docker compose`, GitHub Actions, `prometheus-fastapi-instrumentator` | Metrics are cheap to add on an 8h Day 5 |

---

## 3. Daily rhythm, journal, commits

**Journal template** — same six headings every day, so it takes 15 minutes instead of 45:

```
## What I did
## What I learned (own words)
## What broke and how I fixed it
## Decisions I made and why
## Open questions
## Tomorrow's first task
```

**Commit map** — 3–4 commits/day, and never end a day unpushed:

```
docs(day-1): request lifecycle, status codes, trust boundaries
lab(day-1): postman collection + 3 documented calls
feat(api): health router + settings via pydantic-settings
test(api): validation 422 and auth 401 cases
ci: ruff + pytest on push
```

Never use `update`, `final`, `wip` as a message. The commit log is part of what gets reviewed.

---

## Day 1 — Web & API basics

No FastAPI yet; keep the day honest.

| Time | Block |
|---|---|
| 30m | Client vs server, then trace DNS → TCP → TLS → HTTP → response on one real site, hand-drawn |
| 45m | HTTP anatomy + the ~17 status codes you'll actually use (401 vs 403!) |
| 45m | REST: resources, nouns in URLs, verbs in methods, statelessness, **idempotency** |
| 20m | Versioning: URL vs header, deprecation |
| 30m | Trust boundaries: 5 inputs a backend must never trust |
| 75m | DevTools Network tab: 3 real calls — paginated, authenticated, failing |
| 75m | Postman: reproduce all 3; use `httpbin.org` to deliberately trigger 404, 401, 422 |
| 30m | Write artifact + journal + push |

**Status codes to know cold:** 200, 201, 204, 301, 302, 304, 400, 401, 403, 404, 405, 409, 422, 429, 500, 502, 503.
**The distinction that trips everyone:** 401 = not authenticated · 403 = authenticated but not allowed.

### Artifact — `labs/day-01/README.md`

| Section | Must contain |
|---|---|
| Request lifecycle | One diagram (ASCII or image) from URL to rendered response, DNS/TCP/TLS/HTTP labelled — a non-engineer could follow it |
| HTTP methods table | Method · safe? · idempotent? · typical status · when I'd use it |
| Status code table | ~17 codes, one-line "use when" each, plus one example you triggered yourself |
| 3 documented calls | Endpoint, curl, request headers/body, response excerpt, status, meaning of each response header — reproducible from the doc alone |
| Trust boundaries | 5 inputs a backend must not trust + where each is validated; state that client-side validation is UX, not security |
| Open questions | 3–5 things you still can't answer (feed tomorrow's journal) |

Plus the exported Postman collection JSON in `labs/day-01/`.

**Self-test:** why is a POST retry after a timeout dangerous but a GET retry safe? Explain 422 vs 400 vs 401 vs 403 without notes.

---

## Day 2 — Terminal, OS, environment, Git

Also the day you stand up the repo.

| Time | Block |
|---|---|
| 30m | Navigation, file ops, `chmod 644` vs `755`, `chown` |
| 40m | Processes, `SIGTERM` vs `SIGKILL`, `ss -tulpn`, `lsof -i :3000` |
| 40m | Env vars, `PATH`, `export`, `.env`, why secrets never enter git |
| 45m | venv + `pyproject.toml`, `uv`/pip, lockfile, first FastAPI "hello" you never commit |
| 60m | Git: init/add/commit/log/diff, `.gitignore`, branch, merge conflict |
| 45m | Undo: `restore` vs `reset --hard` vs `revert` — run all three deliberately |
| 90m | Build the repo: skeleton, `.gitignore` (`__pycache__`, `.venv`, `.env`), `.env.example`, README day table, first push |
| 30m | Artifact + journal + push |

### Artifact — `labs/day-02/`

| File | Must contain |
|---|---|
| `cheatsheet.md` | ~30 commands in **your own words**: what it does · when I'd use it · dangerous flag warning (`rm -rf`, `kill -9`, `git reset --hard`) |
| `scripts/backup.sh` | Working, executable, `set -euo pipefail`, usage comment, refuses to run with no args |
| `git-workflow.md` | Exact command sequence for init → first commit → branch → conflict → resolve → revert, with real output pasted |
| `process-port-demo.md` | Transcript: process holding :3000, `SIGTERM`, what happened, then `SIGKILL` |

**Self-test:** why SIGTERM before SIGKILL? What does `.gitignore` prevent, and what does it *not* (already-committed history)?

---

## Day 3 — Server, async, API design, auth

The `api/` skeleton is born. Do the flagship experiment first — it's the best 45 minutes of the week.

### Flagship experiment: blocking vs non-blocking

Fire 10 concurrent requests at each variant with `scripts/loadtest.py` (`httpx` + `asyncio.gather`):

| Variant | Code | Expected |
|---|---|---|
| A | `async def` + `time.sleep(1)` | ~10s — blocks the whole event loop |
| B | `async def` + `await asyncio.sleep(1)` | ~1s — concurrent |
| C | plain `def` + `time.sleep(1)` | ~1s — FastAPI offloads sync handlers to a threadpool |

Record measured wall-clock and throughput for all three, then explain *why*.

| Time | Block |
|---|---|
| 30m | What a server process is: bind, listen, accept, handler |
| 60m | Raw `http.server` server, then the FastAPI equivalent — what the framework saved you |
| 70m | The A/B/C experiment above, with real numbers recorded |
| 45m | Event loop, threadpool default size, GIL — why C is not "free scaling" |
| 45m | Routers, path vs query params, 404 & validation handlers, `APIRouter(prefix="/v1")` |
| 45m | Middleware order, request-ID middleware, `CORSMiddleware`, exception handlers last |
| 45m | Pydantic validation: `Field`, `EmailStr`, validators, unknown fields, 422 shape |
| 30m | API design: resource naming, one consistent error envelope, pagination contract |
| 45m | JWT: `OAuth2PasswordBearer`, `POST /auth/token`, signing ≠ encryption, expiry, cookie vs header |
| 30m | Artifact + journal + push |

**Build milestone:** `app/main.py`, `core/config.py` (pydantic-settings), `api/v1/{health,items,auth}.py`, `services/`, `schemas/`, JWT dependency, in-memory store, an `.http` file per endpoint.

### Artifact

| File | Must contain |
|---|---|
| `docs/async-notes.md` | The three variants, measured wall-clock, throughput, and why — **real numbers**; this is the most impressive file in the repo |
| `docs/api-design.md` | Your error envelope (one shape, shown), naming rules, pagination contract, versioning decision + rationale |
| `docs/openapi.json` | Exported from `/openapi.json` — your committed API contract |
| `api/` | Layered structure, validation, auth middleware, no secrets in code; runs from a clean clone with `.env.example` |
| `journal/day-03.md` | What confused you, what you'd do differently — honest, not a doc summary |

**Self-test:** which variant would you never ship and why? Why does middleware order matter concretely? Where does validation live, and why not in the DB? Why doesn't a valid JWT signature mean the user is still authorized?

---

## Day 4 — Database, performance, background jobs

| Time | Block |
|---|---|
| 60m | SQL: SELECT/INSERT/UPDATE/DELETE, JOIN, GROUP BY, transactions (psql against the compose DB) |
| 40m | Schema design: keys, FKs, constraints, timestamps, soft delete, naming |
| 60m | SQLAlchemy 2.0 models + `get_db` dependency + Alembic init/autogenerate/upgrade |
| 45m | Seed ~100k rows (`scripts/seed.py`), then CRUD endpoints on real data |
| 60m | Indexing: `EXPLAIN ANALYZE` before/after, composite index column order, when indexes hurt writes |
| 30m | N+1: lazy vs `selectinload`, count the queries |
| 45m | Pagination: offset vs cursor, filter/sort **allowlists** (never pass raw sort strings to SQL) |
| 60m | Redis cache-aside on one GET: key naming, TTL, invalidation, stampede, what not to cache |
| 45m | Background job: ARQ/worker + retry + idempotency key (mock email) |
| 30m | Artifact + journal + push |

### Artifact

| File | Must contain |
|---|---|
| `docs/database.md` | Mermaid ERD · DDL · why each table/constraint exists · index decision table: query → index → before ms → after ms |
| `docs/performance.md` | Pasted `EXPLAIN` before/after · the N+1 demo · cache-aside diagram + TTL/invalidation policy + "what I won't cache and why" · pagination choice with tradeoff stated |
| Jobs section | Lifecycle, retry policy, why the job must be idempotent, what happens if the worker dies mid-job |
| `migrations/` + `seeds/` | Reproducible from scratch, one command |

**Self-test:** why does `WHERE a=1 AND b=2` care about composite column order? Why is OFFSET pagination bad at page 10,000? Why is invalidating a cache harder than filling it? Why must a retried job be idempotent?

---

## Day 5 — Security, testing, production readiness

8h is enough if you cut monitoring to "instrumented + documented" rather than fully built out.

| Time | Block |
|---|---|
| 40m | Argon2/bcrypt: cost factor, salting, timing — replace any plaintext/fast-hash password |
| 40m | JWT hardening: `alg` pinning, expiry, refresh concept, revocation, cookie flags (`httpOnly`/`Secure`/`SameSite`) |
| 75m | OWASP four: **live SQLi demo then fix** (parameterized), XSS, CSRF (why cookie auth needs it, Bearer doesn't), CORS (browser control, **not** auth; origin allowlist, preflight) |
| 40m | Centralized errors: custom exception classes, `@app.exception_handler`, error envelope, correlation ID, no stack traces to clients |
| 30m | Structured JSON logs (structlog or JSON formatter), levels, never log passwords/tokens/PII |
| 90m | Pytest: `conftest.py`, test DB fixture, `dependency_overrides` for `get_db` and auth; 3 tests — happy path, 422 validation, 401/403 |
| 20m | Environments & 12-factor, dev/staging/prod diff table |
| 80m | Docker: multi-stage, non-root user, `.dockerignore`, compose app+db+redis+worker, healthchecks |
| 40m | CI: GitHub Actions ruff → pytest → docker build; green badge |
| 30m | `/health` (liveness) vs `/ready` (DB `SELECT 1` + Redis ping), Prometheus instrumentation |
| 25m | Artifact + journal + push |

### Artifact

| File | Must contain | Bar for "good" |
|---|---|---|
| `docs/security.md` | Threat → concrete example → mitigation → file:line; include the SQLi before/after | Every row points at a real line of code |
| `docs/testing.md` | Strategy, how to run, what's deliberately uncovered, the 3 tests | Tests actually fail when you break the code |
| `Dockerfile` + `docker-compose.yml` + `.dockerignore` | Multi-stage, non-root, app+db+redis+worker, healthchecks | `docker compose up` works from a clean clone |
| `.github/workflows/ci.yml` | Lint → test → build on push/PR | Green checkmark visible in the repo |
| `docs/operations.md` | Env matrix (dev/staging/prod), health endpoints, log field schema, runbook for 3 failures (DB down, high latency, 5xx spike) | A stranger could triage from it |
| `README.md` (final) | Quickstart, architecture diagram, endpoint table, key decisions | Reads like a real project, not a course |
| `journal/retrospective.md` | What I can now do, what's still shaky, next 30 days | Names specific gaps, not "learn more" |

**Self-test:** why Argon2 over SHA-256? Why does CORS not protect your API? Where does CSRF apply and where doesn't it? Why is 401 vs 403 a security decision, not cosmetics? What does a readiness check tell an orchestrator that a liveness check doesn't?

---

## 9. Guardrails & fallbacks

- **Docker blocked** → SQLite + in-memory cache; write one paragraph in `operations.md` on what changes in prod.
- **Redis unavailable** → in-memory LRU behind the same interface; document the difference.
- **Day 5 overrunning** → keep security + tests + Dockerfile + CI; make monitoring and CORS *documented* rather than implemented. Say so in the journal — that reads as judgement, not failure.
- **Behind by half a day** → cut **depth on one topic**, never cut the journal, the artifact, or the push. Minimum viable day = journal + one working demo + push.
- **Never cut:** the journal, the artifact, the push. Never end a day uncommitted.
- **Over-invest in exactly two things:** the Day 3 async numbers and the Day 5 SQLi demo. Both are what people remember in a review.
- **Ask for 15 minutes of feedback on Day 3.** Mid-week correction beats a Friday surprise, and it signals ownership.

---

## 10. Interview track

`interview-qa.md` grows by **5 questions/day**, answered in your own words, sayable out loud in 60 seconds. By Friday that's 25 questions covering all five days' topics — exactly the "interview readiness" outcome they asked for, and the single most valuable file to show a manager.

Suggested seed questions:

- **Day 1:** What happens between typing a URL and seeing a response? Which HTTP methods are idempotent and why? 401 vs 403? What is a trust boundary?
- **Day 2:** SIGTERM vs SIGKILL? What lives in `.env` and why is it gitignored? What does `PATH` do?
- **Day 3:** Blocking vs non-blocking; what the event loop actually does? Why does middleware order matter? Where do you validate input? Signing vs encrypting a JWT?
- **Day 4:** When does an index hurt? Offset vs cursor pagination? What is N+1? Cache-aside vs write-through? Why must jobs be idempotent?
- **Day 5:** Why Argon2? What does CORS actually protect? CSRF: when does it apply? Why centralize error handling? Liveness vs readiness? What is the test pyramid?

---

## 11. Your next 60 minutes

1. `mkdir backend-onboarding && cd backend-onboarding && git init` — do this today, even though it's Day 2 work, because Day 1's artifact needs somewhere to land.
2. Write the skeleton from §1 with a `README.md` containing the empty day table.
3. `.gitignore` with `__pycache__/`, `.venv/`, `.env`, `*.db`; add `.env.example`; commit `chore: repo skeleton + day table`.
4. Start Day 1's DevTools hour.

---

## Appendix — daily checklists

Tick these before you close the laptop. If you can't tick all four, you're not done for the day.

**Every day**
- [ ] Journal written with all six headings
- [ ] Artifact file(s) exist at the specified path
- [ ] 5 new Q&A in `interview-qa.md`
- [ ] Commits pushed; root `README.md` day table updated
- [ ] Self-test questions answered out loud without notes

**Day 1** — lifecycle diagram · methods table · status table · 3 documented calls · trust boundaries · Postman export

**Day 2** — `cheatsheet.md` · `backup.sh` · `git-workflow.md` · `process-port-demo.md` · repo pushed with `.gitignore` + `.env.example`

**Day 3** — `docs/async-notes.md` with real numbers · `docs/api-design.md` · `docs/openapi.json` · `api/` runs from clean clone · `.http` files

**Day 4** — `docs/database.md` with ERD + index table · `docs/performance.md` with EXPLAIN output · migrations + seeds reproducible · cache + job implemented

**Day 5** — `docs/security.md` · `docs/testing.md` + 3 tests · Dockerfile/compose working · CI green · `docs/operations.md` · final `README.md` · `journal/retrospective.md`
