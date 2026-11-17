# Backend Onboarding — 5 Days

Python · FastAPI · PostgreSQL · Redis · Docker

This repo is both the **learning journal** and the **working code**. One commit minimum per day, pushed before the day ends.

Plan lives in [`docs/plan.md`](docs/plan.md).

---

## Progress

| Day | Topic | Journal | Artifact | Status |
|:--:|---|---|---|:--:|
| 1 | Backend fundamentals, web & API basics | [day-01](journal/day-01.md) | [labs/day-01-http](labs/day-01-http/README.md) | ✅ |
| 2 | Terminal, OS & developer environment | [day-02](journal/day-02.md) | [labs/day-02-terminal](labs/day-02-terminal/README.md) | ☐ |
| 3 | Server, async & API design | [day-03](journal/day-03.md) | `api/` + `docs/api-design.md` | ☐ |
| 4 | Database, performance & background jobs | [day-04](journal/day-04.md) | `docs/database.md` + `docs/performance.md` | ☐ |
| 5 | Security, testing & production readiness | [day-05](journal/day-05.md) | `docs/security.md` + CI + Docker | ☐ |

Update `☐` → `✅` at the end of each day, in the same commit as that day's artifacts.
Legend: `☐` not started · `🟡` in progress · `✅` done

---

## What's here

| Path | Purpose |
|---|---|
| `journal/` | Daily log — six fixed headings, 15 min, every day |
| `labs/` | Hands-on evidence: Postman exports, scripts, terminal transcripts |
| `docs/` | Design and reasoning artifacts (api-design, database, performance, security, testing, operations) |
| `api/` | The FastAPI project — starts Day 3, grows through Day 5 |
| `interview-qa.md` | 5 questions/day, answered in my own words, out loud in 60s |
| `docs/plan.md` | The full 5-day plan and artifact spec |

---

## How to run

Not yet — `api/` starts on Day 3. When it exists, this section becomes:

```bash
cd api
cp .env.example .env        # fill in values
docker compose up -d        # postgres + redis
uv sync                     # or: python -m venv .venv && pip install -e .
alembic upgrade head
uvicorn app.main:app --reload
```

---

## Conventions

- Commit messages: `docs(day-N): …`, `lab(day-N): …`, `feat(api): …`, `test(api): …`, `ci: …`
- Never commit: `.env`, `.venv/`, `__pycache__/`, database files. Use `.env.example` instead.
- Never end the day uncommitted or unpushed.
