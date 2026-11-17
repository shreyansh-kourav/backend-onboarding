# Day 1 — hands-on evidence

Theory notes for this day live in [`docs/day_01/`](../../docs/day_01/):

| Note | Covers |
|---|---|
| [01. Journey of a Request](../../docs/day_01/01.%20Journey%20of%20a%20Request.md) | client → DNS → TCP → TLS → HTTP → server |
| [02. HTTP](../../docs/day_01/02.%20HTTP.md) | message anatomy, 17 status codes |
| [03. REST APIs](../../docs/day_01/03.%20REST%20APIs.md) | resources, methods, statelessness, idempotency, versioning |
| [04. Request Validation](../../docs/day_01/04.%20Request%20Validation.md) | trust boundaries, 5 untrusted inputs |

This folder is the proof: what I observed, measured, and can reproduce.

---

## Checklist

- [x] **Request path** — each phase measured against a live connection → [`request-path-observations.md`](request-path-observations.md)
- [x] **Postman** — 3 requests in a collection with an environment → exported JSON here
- [x] **Three documented calls** — reproducible from the doc alone → [`api-calls.md`](api-calls.md)
- [x] **Self-test** — answered in [`interview-qa.md`](../../interview-qa.md) Day 1

## Files

| File | What's in it |
|---|---|
| [`api-calls.md`](api-calls.md) | Three calls: paginated public, authenticated, failure — with real headers and bodies |
| [`request-path-observations.md`](request-path-observations.md) | DNS/TCP/TLS/HTTP timings, the TLS 1.3 trace, and which headers expose which layer |
| [`day-01.postman_collection.json`](day-01.postman_collection.json) | Collection with assertions (status, `Link` header, rate-limit headers) |
| [`day-01.postman_environment.json`](day-01.postman_environment.json) | `base_url`, `httpbin_url`, `github_token` |

## What the evidence establishes

1. A request costs four setups before any payload moves — DNS 5 ms, TCP 38 ms, TLS 49 ms, then 44 ms to first byte.
2. Pagination is discovered from `Link: …rel="next"`, not constructed by the client.
3. 401 (identity not established) and 404 (existence concealed) are separate decisions, and the error body is what makes either usable.

## Self-test

Answered in [`interview-qa.md`](../../interview-qa.md), Day 1 — trace a `GET` end to end · POST-retry vs GET-retry · 422 vs 400 vs 401 vs 403 · five untrusted inputs · where the version goes.
