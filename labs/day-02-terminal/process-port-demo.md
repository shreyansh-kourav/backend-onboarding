# Process and port demo — transcript

Goal: start a server, find it by port rather than by guesswork, then terminate it politely and rudely, and observe the difference.

Server used: `python3 -m http.server` (anything that binds a port behaves the same way).

---

## 1. Start something that holds a port

```console
$ python3 -m http.server 8765 --bind 127.0.0.1 &
started PID=9509
$ curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8765/
200
```

The `&` puts it in the background; `$!` is its PID. The `curl` is the proof it's actually serving, not just running.

---

## 2. Find it — four ways, same PID

```console
$ ss -tulpn | grep 8765
tcp   LISTEN 0      5          127.0.0.1:8765       0.0.0.0:*    users:(("python3",pid=9509,fd=3))

$ lsof -i :8765
COMMAND  PID             USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
python3 9509 shreyansh-kourav    3u  IPv4  40122      0t0  TCP localhost:8765 (LISTEN)

$ fuser 8765/tcp
8765/tcp:             9509

$ ps -p 9509 -o pid,ppid,stat,cmd
    PID    PPID STAT CMD
   9509    9508 SN   python3 -m http.server 8765 --bind 127.0.0.1
```

Reading them:

- `ss` flags: `-t` TCP, `-u` UDP, `-l` listening only, `-p` process, `-n` numeric. The `users:(("python3",pid=9509,fd=3))` column is the answer.
- `lsof` shows the **file descriptor** (`3u` = fd 3, open for read/write) — a socket really is a file.
- `fuser` gives the bare PID, which is what you want in a script.
- `ps` says `STAT=SN` — sleeping, low priority. Not `D`, which would mean it's stuck in uninterruptible I/O and would ignore signals until that completes.

---

## 3. SIGTERM — the polite stop

```console
$ kill -0 9509 && echo alive
alive
$ kill -TERM 9509
$ wait 9509; echo "exit code after SIGTERM: $?"
exit code after SIGTERM: 143
$ ss -tulpn | grep 8765 || echo "port released"
port released
```

- `kill -0` signals nothing; it only tests "does this PID exist and can I signal it". Useful as a liveness check.
- Exit code **143 = 128 + 15** (SIGTERM). A process killed by signal *N* reports `128 + N` to its parent, which is how a supervisor knows it was signalled rather than exiting on its own.
- The port was released because the OS closes the socket when the process dies — you don't need to clean up listening sockets.

---

## 4. SIGKILL — the rude stop

```console
$ python3 -m http.server 8766 --bind 127.0.0.1 &
started PID=9560
$ kill -9 9560
$ wait 9560; echo "exit code after SIGKILL: $?"
exit code after SIGKILL: 137
$ ss -tulpn | grep 8766 || echo "port released"
port released
```

**137 = 128 + 9**. From the outside it looks identical to the SIGTERM case: process gone, port free. The difference is what didn't happen — no handler ran, so in a real app there'd be no flushing of buffers, no closing of DB connections, no finishing of in-flight requests.

For `python3 -m http.server` there's nothing to clean up, which is exactly why it's a safe subject for the experiment.

---

## 5. The error that starts this whole investigation

```console
$ python3 -m http.server 8767 --bind 127.0.0.1 &
$ python3 -m http.server 8767 --bind 127.0.0.1
    self.socket.bind(self.server_address)
OSError: [Errno 98] Address already in use
```

"Address already in use" is never about the *new* process — it means an older one still owns the port. The loop that resolves it:

```bash
ss -tulpn | grep :8767     # find the owner
kill -TERM <pid>           # ask it to stop
ss -tulpn | grep :8767     # confirm the port is free before retrying
```

Reaching for a different port instead hides the problem and leaves orphans accumulating.

---

## 6. What this demonstrated

| Claim | Evidence |
|---|---|
| A port belongs to exactly one listening process | `ss`, `lsof`, `fuser` all returned PID 9509 |
| SIGTERM and SIGKILL both end the process | exit 143 vs 137 — both `128 + signal` |
| Only SIGTERM allows cleanup | no handler runs under `kill -9` |
| The OS releases the socket | `ss` empty immediately after both kills |
| "Address already in use" = stale owner | reproduced on 8767 while another process held it |
| `kill -0` is a liveness test | returned success on a running PID without signalling it |
