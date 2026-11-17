# Day 1 — Web & API basics

**Artifact:** how a request actually reaches a backend and comes back. Fill every section; leave nothing as a placeholder.

**Done when:** someone who has never seen this repo can reproduce all three API calls from this document alone and explain every status code you chose.

---

## 1. Request lifecycle

> One diagram from "user types a URL" to "response rendered". Label DNS, TCP, TLS, HTTP request, server, response. ASCII or an image — both fine.

```text
TODO
```

**In one paragraph, what each hop does:**

<!-- TODO -->

---

## 2. HTTP methods

| Method | Safe? | Idempotent? | Typical status | When I'd use it |
|---|---|---|---|---|
| GET | | | | |
| POST | | | | |
| PUT | | | | |
| PATCH | | | | |
| DELETE | | | | |
| HEAD / OPTIONS | | | | |

**Why PUT is idempotent but POST isn't:**

<!-- TODO -->

---

## 3. Status codes

| Code | Name | Use when |
|---|---|---|
| 200 | | |
| 201 | | |
| 204 | | |
| 301 / 302 | | |
| 304 | | |
| 400 | | |
| 401 | | |
| 403 | | |
| 404 | | |
| 405 | | |
| 409 | | |
| 422 | | |
| 429 | | |
| 500 | | |
| 502 / 503 | | |

**One of these I triggered myself, and how:** <!-- TODO -->

---

## 4. Three documented calls

### Call A — public, read-only, paginated
- Endpoint:
- Why I picked it:
- `curl` command:
- Request headers:
- Response status + headers worth explaining:
- Response body excerpt:
- What each response header means:

### Call B — authenticated
- Endpoint:
- `curl` command:
- Request headers (how auth is passed):
- Response status:
- What happens without the token:

### Call C — the failure case
- Endpoint:
- `curl` command:
- Status returned:
- Why the server chose that status:
- What the body tells the client to fix:

> Postman collection exported to this folder as `*.postman_collection.json`.

---

## 5. Trust boundaries

Five things a backend must never trust, and where each is validated:

| # | Input | Where it's validated | What happens if trusted blindly |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

**Why client-side validation is UX, not security:**

<!-- TODO -->

---

## 6. Open questions

-
-
-

---

## Self-test (answer out loud, no notes)

- [ ] Trace a real `GET` from DNS to response
- [ ] Why is POST retry after a timeout dangerous, but GET retry safe?
- [ ] 422 vs 400 vs 401 vs 403
