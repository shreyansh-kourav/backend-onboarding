# Day 1 — Web & API basics

**Date:** 2026-11-17
**Time spent:** ~6h

## What I did

- Wrote four concept notes in `docs/day_01/`: request journey (DNS → TCP → TLS → HTTP), HTTP message anatomy + 17 status codes, REST (resources, methods, statelessness, idempotency, versioning, deprecation), and trust boundaries (5 untrusted inputs).
- Reproduced three real API calls against `api.github.com` and `httpbin.org` with `curl`, and recorded the actual request/response headers in `labs/day-01-http/api-calls.md`.
- Built the Postman collection + environment for those same three calls, with assertions on the paginated one.
- Measured DNS / TCP / TLS / TTFB timings and captured a full `curl -v` TLS 1.3 handshake trace.

## What I learned (own words)

- A request is four layers of setup before a single byte of my JSON moves: DNS resolves a name to an IP, TCP gets a reliable connection to a port, TLS authenticates the server and agrees on symmetric keys, and only then does HTTP send a method + path + headers. The timings made this concrete: TLS cost more than the TCP connect.
- Pagination is a **response** concern, not a URL guess — `Link: <…page=2>; rel="next"` tells the client where to go next.
- Status codes carry meaning about *whose fault / which stage*: 401 means identity wasn't established, 403 means it was and permission is missing, 404 hides existence on purpose, 422 means "understood but the content is wrong". A bare status code with no body is a broken error contract.
- Idempotency is what makes retries safe, and it's a property of the *method's effect*, not of the response — `DELETE` twice still returns a 404 the second time, but the state is the same.

## What broke and how I fixed it

- The HTTP request/response examples in the Journey note collapsed onto one line (`GET /products HTTP/1.1Host: …`) because the newlines were lost inside the code fence. Fixed by putting each header on its own line.
- Hitting `/user` without a credential lands on the 401 path, which is exactly the one that shows the 401-vs-403 distinction — so that's the case written up in `api-calls.md`. The same request with a bearer token returns 200 and the caller's profile; the header is the only difference.
- `httpbin`'s `/status/422` returns an empty body, so it demonstrates the code but not the error contract. Noted that FastAPI's default 422 — with a `detail[]` array naming the field — is the real-world version, which I'll see on Day 3.

## Decisions I made and why

- Kept **concept notes in `docs/day_01/`** and **evidence in `labs/day-01-http/`**. Notes are what I understood; labs are what I observed. Mixing them made the artifact unreadable.
- Used `curl` for the calls and `-D` to dump headers rather than relying on a GUI, so every claim in `api-calls.md` is reproducible from a terminal — which is also Day 2's whole point.
- Chose `api.github.com` over a toy API because it exercises the things I need to see: pagination headers, rate limits, a real 401, HSTS, and version pinning in `x-github-api-version-selected`.

## Open questions

- If `Link` gives me the next page, is following links the *expected* client behaviour, or do most clients still construct `page=2` themselves?
- How does a server decide between 400 and 422 in practice when the JSON parses but the types are wrong?
- Where does `ETag` / `304` actually save time — is the win the bytes, or the round trip?

## Tomorrow's first task

Start Day 2's terminal block: processes, signals, and finding what owns a port.

---

## Artifact status — [`labs/day-01-http`](../labs/day-01-http/README.md)

- [x] Request lifecycle diagram
- [x] HTTP methods table
- [x] Status code table
- [x] 3 documented API calls + Postman export
- [x] Trust boundaries
- [x] Request path observed: DNS/TCP/TLS timings + handshake trace
- [x] Self-test answered ([`interview-qa.md`](../interview-qa.md))
