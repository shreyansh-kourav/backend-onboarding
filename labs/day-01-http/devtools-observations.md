# DevTools observations

**Site tested:** api.github.com (and github.com for the page load)
**Cache disabled:** to be recorded when I run the browser pass

> **Status:** the terminal half of this file is measured and complete. The two browser-only sections (1 and 3) are marked `TODO` — they need DevTools open, which can't be done from a shell.

---

## 1. Timing waterfall vs my Journey note

<!-- TODO (browser): github.com → Network → Disable cache → Ctrl+Shift+R → click the document request → Timing -->

| DevTools phase | ms | Hop in `01. Journey of a Request` |
|---|---|---|
| Queueing / Stalled | | — |
| DNS lookup | | stub resolver → recursive resolver → root → TLD → authoritative |
| Initial connection (TCP) | | 3-way handshake |
| SSL / TLS | | ClientHello → ServerHello → certificate → Finished |
| Request sent / Waiting (TTFB) | | HTTP request → server processing |
| Content download | | HTTP response |

What surprised me:

---

## 2. Browser vs `curl` timings — measured

```bash
curl -sS -o /dev/null \
  -w 'dns=%{time_namelookup}s connect=%{time_connect}s tls=%{time_appconnect}s ttfb=%{time_starttransfer}s total=%{time_total}s\n' \
  https://api.github.com
```

| Run | dns | connect (TCP) | tls (handshake done) | ttfb | total |
|---|---|---|---|---|---|
| 1 | 0.0048s | 0.0426s | 0.0920s | 0.1363s | 0.1385s |
| 2 | 0.0054s | 0.0471s | 0.0970s | 0.1436s | 0.1439s |

**Reading the numbers:**

- `dns` ≈ 5 ms on both runs. Small because the OS resolver is answering from its own cache — `curl` performs a fresh lookup each process, but the *resolver* remembers. That is the "caching at multiple levels" line in my note, observed rather than assumed.
- `connect − dns` ≈ 38 ms for one TCP round trip. `tls − connect` ≈ 49 ms for the TLS handshake — **the handshake costs more than the TCP connection it sits on**, which is the practical argument for TLS session resumption and keep-alive.
- `ttfb − tls` ≈ 44 ms: the actual HTTP request + server processing. On a real page load there are dozens of these, which is why connection reuse matters more than raw bandwidth.
- Run 2 is *slightly slower*, not faster — there is no HTTP connection cache across separate `curl` processes. Same reason the second run can't show a warm TLS session.

### TLS handshake, observed (`curl -v`)

The trace matches the shape in `01. Journey of a Request` exactly:

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

1. **TLS 1.3 is in use**, and everything after ServerHello is *encrypted* — including the certificate, which is why "Encrypted Extensions" and the certificate lines appear as one block. My note said "in TLS 1.3, later handshake messages are encrypted"; this is that.
2. **`X25519` key exchange + `TLS_AES_128_GCM_SHA256`** — an ephemeral key agreement, then a fast symmetric cipher for the data. Exactly the "public key to set up, symmetric key for the payload" split in my note.
3. **`ALPN: server accepted h2`** — the protocol version is negotiated *during* the TLS handshake, before any HTTP is sent. So "HTTP/2" is not chosen by the URL; it's negotiated at the TLS layer.

---

## 3. One Fetch/XHR call

<!-- TODO (browser): Network → Fetch/XHR → pick a JSON call → Headers tab -->

- URL:
- Status:
- Request headers that mattered:
- Response headers that mattered:
  - `Content-Type`:
  - `Cache-Control`:
  - `ETag` / `Link` / rate-limit headers:
- Why this status code:

---

## 4. What the evidence corrected in my notes

The terminal half confirmed the mechanics but flattened one thing I had written casually:

- I described DNS caching as "client, recursive resolvers, etc." Running the same `curl` twice showed the split more precisely: **curl itself caches nothing between processes** — the saving comes entirely from the OS stub resolver / recursive resolver. So "client-side cache" is really the resolver cache on the machine, not the application.
- I had also treated the TLS handshake as one step. The timings show it is roughly **1.3× the cost of the TCP connect** on a fresh connection — which is the concrete reason `https` is not "free" and why keep-alive exists.

`TODO` once the browser pass is done: add whether DevTools reports the same phase split, and whether the browser's DNS phase is visibly faster on reload than `curl`'s.
