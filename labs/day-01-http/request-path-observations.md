# Request path — observations

**Host tested:** `api.github.com` · **Date:** 2026-11-17 · **Method:** `curl`, `curl -v`, `-w` timing format

Each phase of `01. Journey of a Request` verified against a live connection, with numbers.

---

## 1. Phase by phase: what I claimed, how I checked it, what I saw

| Phase | Claim in my note | How I checked it | Observed |
|---|---|---|---|
| DNS | stub resolver → recursive resolver → root → TLD → authoritative, with caching at several levels | `curl -w '%{time_namelookup}'` on two consecutive runs | `0.0048s`, `0.0054s` — both cache hits, no authoritative lookup |
| TCP | 3-way handshake, connection identified by IP + port | `curl -v`, read the connect lines | `Trying 20.207.73.85:443` → `Connected to api.github.com (20.207.73.85) port 443`, **38 ms** |
| TLS | ClientHello → ServerHello → certificate + identity check → Finished → symmetric keys | `curl -v`, read the handshake lines | TLSv1.3, `X25519` key exchange, `TLS_AES_128_GCM_SHA256`, **49 ms** |
| HTTP | method + path + headers → status + headers + body | `curl -sS -D headers.txt` | `HTTP/2 200`, JSON body, `Link` / `Cache-Control` / `ETag` present |

Every claim in the note has a measurement next to it. Nothing here is asserted from documentation alone.

---

## 2. Timings

```bash
curl -sS -o /dev/null \
  -w 'dns=%{time_namelookup}s connect=%{time_connect}s tls=%{time_appconnect}s ttfb=%{time_starttransfer}s total=%{time_total}s\n' \
  https://api.github.com
```

| Run | dns | connect (TCP done) | tls (handshake done) | ttfb | total |
|---|---|---|---|---|---|
| 1 | 0.0048s | 0.0426s | 0.0920s | 0.1363s | 0.1385s |
| 2 | 0.0054s | 0.0471s | 0.0970s | 0.1436s | 0.1439s |

Reading the deltas:

- **`dns` ≈ 5 ms both runs.** `curl` is a fresh process each time, so it never caches a name — the speed comes from the OS resolver holding the answer. "Caching at multiple levels" is real, but the useful level here is the resolver, not the application.
- **`connect − dns` ≈ 38 ms** = one TCP round trip to `20.207.73.85:443`.
- **`tls − connect` ≈ 49 ms** = the TLS handshake, *more expensive than the TCP connection it rides on*. That is the concrete argument for keep-alive and TLS session resumption — on a page with 40 requests, paying this 40 times is the whole performance story.
- **`ttfb − tls` ≈ 44 ms** = the actual HTTP request plus server time.
- Run 2 being slightly *slower* is the confirmation: separate processes share no connection, so there is no warm-session win.

---

## 3. The TLS handshake, as it actually appears

```text
* Connected to api.github.com (20.207.73.85) port 443
* ALPN: curl offers h2,http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256 / X25519 / id-ecPublicKey
* ALPN: server accepted h2
* subject: CN=*.github.com
```

Three things this settles:

1. **TLS 1.3 encrypts the handshake after ServerHello** — the certificate and Finished messages arrive inside "Encrypted Extensions". My note said later handshake messages are encrypted in 1.3; here it is.
2. **`X25519` + `AES_128_GCM`** — ephemeral public-key agreement first, then fast symmetric encryption for the payload. Exactly the split the note describes.
3. **`ALPN: server accepted h2`** — the HTTP version is negotiated *inside* the TLS handshake, before a single HTTP byte is sent. So HTTP/2 is not something the URL selects.

---

## 4. Headers that make the layers visible

From the paginated call (`GET /users/octocat/repos?per_page=3`):

| Header | Value | Which layer it belongs to |
|---|---|---|
| `content-type` | `application/json; charset=utf-8` | HTTP — the body is a *representation*, not the resource |
| `cache-control` | `public, max-age=60, s-maxage=60` | HTTP caching; `s-maxage` is for shared caches like a CDN |
| `etag` | `W/"f5259fdd…d938"` | Conditional requests — send back as `If-None-Match` to get `304` |
| `link` | `<…page=2>; rel="next"` | Hypermedia — pagination discovered from the response |
| `x-ratelimit-limit` / `-remaining` / `-reset` | `60` / `58` / `1794940519` | Server-side accounting, visible to the client |
| `x-github-api-version-selected` | `2022-11-28` | API versioning, applied server-side |
| `strict-transport-security` | `max-age=31536000; includeSubdomains; preload` | The server instructing the client to only ever use HTTPS here |
| `access-control-allow-origin` | `*` | CORS — which is a *browser* rule, not authentication |

---

## 5. What the evidence sharpened in my notes

Two statements in my notes were true but loose, and measuring made them precise:

- I wrote that DNS is cached at "client, recursive resolvers, etc." In practice **`curl` caches nothing between runs** — the entire saving is the resolver cache on the machine. "Client-side cache" means the stub resolver, not the application.
- I treated the TLS handshake as a single step. The measurements put it at roughly **1.3× the cost of the TCP connect**, which is the real reason `https` is not free and why connection reuse matters more than bandwidth.

One question this opened rather than closed: `ETag`/`304` clearly saves bytes, but it still costs a round trip — so where is the actual win? Worth measuring properly on Day 4 when caching comes up.
