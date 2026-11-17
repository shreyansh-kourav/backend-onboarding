# DevTools observations

**Site tested:** <!-- e.g. github.com -->
**Request observed:** <!-- the document request -->
**Cache disabled:** yes / no

## 1. Timing waterfall vs my Journey note

| DevTools phase | ms | Hop in `01. Journey of a Request` |
|---|---|---|
| Queueing / Stalled | | — |
| DNS lookup | | stub resolver → recursive resolver → root → TLD → authoritative |
| Initial connection (TCP) | | 3-way handshake |
| SSL / TLS | | ClientHello → ServerHello → certificate → Finished |
| Request sent / Waiting (TTFB) | | HTTP request → server processing |
| Content download | | HTTP response |

What surprised me:

## 2. Browser vs `curl` timings

```bash
curl -sS -o /dev/null \
  -w 'dns=%{time_namelookup}s connect=%{time_connect}s tls=%{time_appconnect}s ttfb=%{time_starttransfer}s total=%{time_total}s\n' \
  https://api.github.com
```

```text
TODO
```

Where DNS caching showed up:

## 3. One Fetch/XHR call

- URL:
- Status:
- Request headers that mattered:
- Response headers that mattered:
  - `Content-Type`:
  - `Cache-Control`:
  - `ETag` / `Link` / rate-limit headers:
- Why this status code:

## 4. What the DevTools view corrected in my notes

<!-- If nothing: say "nothing contradicted my notes; here's what confirmed them" -->
