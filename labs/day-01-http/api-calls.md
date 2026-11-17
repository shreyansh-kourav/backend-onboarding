# Day 1 — three documented API calls

Reproducible from this file alone: endpoint · `curl` · request headers · status · body excerpt · what each header means.

All output below was captured on **2026-11-17** with `curl 8.x` from this machine. Reproduce any call by copy-pasting the command.

---

## Call A — public, read-only, paginated

- **Endpoint:** `GET https://api.github.com/users/octocat/repos?per_page=3`
- **Why I picked it:** public, requires no credential, and it returns a paginated collection — so the response headers carry something worth reading (`Link`, `ETag`, rate limits).
- **curl:**
  ```bash
  curl -sS -D headers.txt \
    "https://api.github.com/users/octocat/repos?per_page=3" \
    -H "Accept: application/vnd.github+json" \
    -o body.json
  ```
- **Request headers:**

  | Header | Value | Why |
  |---|---|---|
  | `Accept` | `application/vnd.github+json` | Asks for the vendor's JSON media type instead of the default |
  | `User-Agent` | `curl/8.x` (sent automatically) | GitHub rejects requests with no User-Agent |

- **Status:** `HTTP/2 200`

- **Response headers, explained:**

  | Header | Value (observed) | What it means |
  |---|---|---|
  | `content-type` | `application/json; charset=utf-8` | Body is JSON, UTF-8 encoded — this is a *representation*, not the resource itself |
  | `cache-control` | `public, max-age=60, s-maxage=60` | Cacheable for 60s; `s-maxage` overrides for shared caches (CDN) |
  | `etag` | `W/"f5259fdd…d938"` | Weak validator: send it back in `If-None-Match` to get `304` instead of the body |
  | `link` | `<…/repos?per_page=3&page=2>; rel="next", <…&page=3>; rel="last"` | **Pagination discovered from the response, not the URL** — this is HATEOAS in practice |
  | `x-ratelimit-limit` / `-remaining` / `-used` | `60` / `58` / `2` | 60 unauthenticated requests/hour; I had already spent 2 |
  | `x-ratelimit-reset` | `1794940519` | Unix timestamp when the window resets |
  | `x-github-api-version-selected` | `2022-11-28` | Server-side version pinning — API versioning visible in a header |
  | `strict-transport-security` | `max-age=31536000; includeSubdomains; preload` | HSTS: the browser must only talk HTTPS to this domain |
  | `x-content-type-options` | `nosniff` | Stop the browser guessing content type |
  | `access-control-allow-origin` | `*` | CORS allows any origin to read this response (public data) |

- **Response body excerpt** (2 of the 3 items, trimmed):
  ```json
  {
    "id": 132935648,
    "name": "boysenberry-repo-1",
    "full_name": "octocat/boysenberry-repo-1",
    "private": false,
    "html_url": "https://github.com/octocat/boysenberry-repo-1",
    "language": null,
    "stargazers_count": 491
  }
  {
    "id": 18221276,
    "name": "git-consortium",
    "full_name": "octocat/git-consortium",
    "private": false,
    "html_url": "https://github.com/octocat/git-consortium",
    "language": null,
    "stargazers_count": 629
  }
  ```

**What this proves:** one request → one page of a collection + the links to the other pages. The client doesn't construct page URLs; it follows `rel="next"`.

---

## Call B — authenticated

- **Endpoint:** `GET https://api.github.com/user`
- **curl:**
  ```bash
  # without a credential
  curl -sS -i https://api.github.com/user

  # with a token (not run here — no token in this environment)
  curl -sS -i -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user
  ```
- **How auth is passed:** `Authorization: Bearer <token>` — a header on **every** request, which is what statelessness requires.
- **Status without a token:** `HTTP/2 401`
  ```json
  {
    "message": "Requires authentication",
    "documentation_url": "https://docs.github.com/rest",
    "status": "401"
  }
  ```
- **Status with a token:** expected `200` with the caller's profile — **not reproduced**, because no token exists in this environment. Left explicit rather than invented.
- **What the difference proves:** `401` means *identity was not established*. Not `403` — the server isn't saying "you're the wrong user", it's saying "I don't know who you are." `403` would mean your identity is known but lacks permission. The response also shows the API returning a **machine-readable error body**, not an HTML page — a design choice worth copying.

---

## Call C — the failure case

### C1 — resource does not exist

- **Endpoint:** `GET https://api.github.com/users/definitely-not-a-real-user-xyz`
- **curl:**
  ```bash
  curl -sS -i https://api.github.com/users/definitely-not-a-real-user-xyz
  ```
- **Status returned:** `HTTP/2 404`
  ```json
  {
    "message": "Not Found",
    "documentation_url": "https://docs.github.com/rest",
    "status": "404"
  }
  ```
- **Why 404 and not 400:** the request was perfectly well-formed — the path was valid syntax, the method was allowed. The *resource* simply isn't there. Note also that GitHub won't tell you whether the account is private or never existed — concealing existence is deliberate, to stop username enumeration.

### C2 — understood but unprocessable

- **Endpoint:** `POST https://httpbin.org/status/422`
- **curl:**
  ```bash
  curl -sS -i -X POST https://httpbin.org/status/422
  ```
- **Status returned:** `HTTP/2 422` with `content-length: 0` and `content-type: text/html`
- **Why the server chose 422:** httpbin's `/status` endpoint exists only to echo a status code, so this 422 tests the *client's* handling, not a real validation failure. A real 422 carries a machine-readable explanation of which field failed. **FastAPI does this by default** — its validation errors return `422` with a `detail[]` array naming the exact field and reason, which is why the 400-vs-422 distinction matters on Day 3.
- **What the body tells the client to fix:** nothing, here — and that's the lesson. A status code alone is not an error contract; the body must name the offending field. A bare 422 is a design failure.

---

## Postman

Collection exported to this folder as: [`day-01.postman_collection.json`](day-01.postman_collection.json), environment as [`day-01.postman_environment.json`](day-01.postman_environment.json).

- **Requests in it:** A (paginated, with a `Link` header assertion), B (token from `{{github_token}}`), C (422 via httpbin)
- **Environment variables used:** `base_url`, `httpbin_url`, `github_token`
- **One thing Postman showed that `curl` hid:** the response rendered as a collapsible tree, so the *shape* of the collection is visible without scrolling raw JSON — and the assertion panel turns "I eyeballed a 200" into "the test passed".
