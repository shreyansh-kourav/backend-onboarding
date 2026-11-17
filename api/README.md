# api/ — the FastAPI project

**Empty on purpose.** Code starts Day 3 and grows through Day 5 — one project, not three labs.

Planned layout (mirrors the org's `routes / controllers / services / models / config / tests` template):

```text
api/
├── app/
│   ├── main.py
│   ├── core/        # config.py (pydantic-settings), security.py, logging.py, errors.py
│   ├── api/v1/      # routers: health.py, items.py, auth.py  ← "routes"
│   ├── models/      # SQLAlchemy models
│   ├── schemas/     # Pydantic request/response models
│   ├── services/    # business logic, cache-aside, jobs
│   ├── db/          # session.py, base.py
│   └── workers/     # ARQ / background jobs
├── alembic/         # migrations
├── scripts/         # seed.py, loadtest.py
├── tests/           # conftest.py + test_*.py
├── pyproject.toml
├── .env.example
├── Dockerfile
├── docker-compose.yml
└── .dockerignore
```

## Day 3 target

`GET /v1/health` · `POST /v1/items` (validated, 422 on bad input) · `POST /v1/auth/token` · `GET /v1/items/me` (JWT-protected)

Plus the experiment in `docs/async-notes.md`:

| Variant | Handler | Expected under 10 concurrent requests |
|---|---|---|
| A | `async def` + `time.sleep(1)` | ~10s — blocks the event loop |
| B | `async def` + `await asyncio.sleep(1)` | ~1s |
| C | `def` + `time.sleep(1)` | ~1s — threadpool |

Don't copy the numbers. Measure them and record what you actually got.
