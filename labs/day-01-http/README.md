# Day 1 — hands-on evidence

Theory notes for this day live in [`docs/day_01/`](../../docs/day_01/):

| Note | Covers |
|---|---|
| [01. Journey of a Request](../../docs/day_01/01.%20Journey%20of%20a%20Request.md) | client → DNS → TCP → TLS → HTTP → server |
| [02. HTTP](../../docs/day_01/02.%20HTTP.md) | message anatomy, 17 status codes |
| [03. REST APIs](../../docs/day_01/03.%20REST%20APIs.md) | resources, methods, statelessness, idempotency, versioning |
| [04. Request Validation](../../docs/day_01/04.%20Request%20Validation.md) | trust boundaries, 5 untrusted inputs |

This folder holds the **proof**: what I observed, measured, and reproduced.

---

## Remaining checklist

- [ ] **A. DevTools** — **terminal half done** (DNS/TCP/TLS timings + handshake trace); browser pass on Timing and Fetch/XHR still pending → `devtools-observations.md`
- [x] **B. Postman** — collection + environment exported to this folder
- [x] **C. Three documented calls** — captured from real responses → `api-calls.md`
- [ ] **D. Self-test** — answered out loud, no notes

**Done when:** a stranger can reproduce all three calls from `api-calls.md` and explain every header and status code you show.

---

## A. `devtools-observations.md`

The Timing tab breaks a single request into Queueing · DNS · TCP · TLS · Request · Response. Your Journey note describes exactly those hops — so measure them.

Must contain:

1. The waterfall numbers for one page load, next to the matching section of your Journey note.
2. A `curl` timing line for the same host (`-w '%{time_namelookup} %{time_connect} %{time_appconnect}'`), compared to the browser's numbers. Do they agree? Where does DNS caching show up?
3. One **Fetch/XHR** call observed in the Network tab: full request headers, response headers worth explaining (`Content-Type`, `Cache-Control`, `ETag`, `Set-Cookie`, rate-limit headers), and the status.
4. One thing the DevTools view **contradicted or corrected** in your notes. If nothing did, say that explicitly — that's a result too.

## B. Postman

- Collection `Backend Onboarding — Day 1`, three requests, one **environment** with a `base_url` variable.
- Show one request using `{{base_url}}`, one with a header, one with a JSON body.
- Export the collection JSON into this folder and commit it.

## C. `api-calls.md` — the core artifact

Three calls, each with: endpoint, why you picked it, the `curl` command, request headers, response status, response body excerpt, and what each notable response header means.

| # | Kind | Suggested target | Expect |
|---|---|---|---|
| A | public, read-only, **paginated** | `GET https://api.github.com/users/octocat/repos?per_page=3` | 200, `Link` header for pages, rate-limit headers |
| B | **authenticated** | `GET https://api.github.com/user` (token) vs anonymous | 200 with token, 401/403 without |
| C | **failure** | `https://api.github.com/users/<made-up-user>` · `https://httpbin.org/status/422` | 404 · 422 |

Deliberately trigger a 401, a 404 and a 422 if B doesn't naturally produce one — httpbin makes it one command each.

## D. Self-test (out loud, no notes)

- [ ] Trace a real `GET` from DNS to response, naming each hop
- [ ] Why is POST retry after a timeout dangerous, but GET retry safe? What header fixes POST?
- [ ] 422 vs 400 vs 401 vs 403
- [ ] Name 5 inputs a backend must never trust, and where each is validated
- [ ] Where does version go, and why is `/v1/` the common choice?
