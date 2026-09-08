# SSH Tunnel Setup for VNC + ChromeDriver

## Overview

- **Server:** `192.168.178.75` (trapapa)
- **Purpose:** Tunnel local VNC (`5900`) and ChromeDriver (`9515`) from local machine to remote server.
- **Tools:** `sshpass`, `vncviewer`, `curl`, `selenium`

---

## 1. Establish Tunnel

Open a persistent terminal on your local machine:

```bash
sshpass -p 'trapapa' ssh -L 5901:127.0.0.1:5900 -L 9515:127.0.0.1:9515 trapapa@192.168.178.75
```

**What it does:**

- `5901` on localhost -> `5900` on remote server (VNC)
- `9515` on localhost -> `9515` on remote server (ChromeDriver WebDriver API)

> **Keep this terminal open** while you need the tunnel.

---

## 2. Connect Locally

### VNC Viewer

```bash
vncviewer localhost:5901
# Password: hermes123
```

### ChromeDriver (Selenium/WebDriver)

```bash
curl -s http://localhost:9515/status
```

You can now use `http://localhost:9515/wd/hub` for Selenium sessions.

---

## 3. Check Tunnel Status

### On the Remote Server (while SSH tunnel is active)

```bash
sshpass -p 'trapapa' ssh trapapa@192.168.178.75 'ss -tlnp | grep -E "5900|6080|9515"'
```

### Locally (on your machine)

```bash
ss -tlnp | grep -E '5901|9515'
```

---

## 4. Terminate Tunnel

### Option A - Kill the sshpass process

Press `Ctrl+C` or run:

```bash
kill %1   # if started with `sshpass ...`
```

### Option B - Use a ControlMaster socket (cleaner)

Start with a named socket:

```bash
sshpass -p 'trapapa' ssh -M -S ~/.ssh/tunnel_sock -L 5901:127.0.0.1:5900 -L 9515:127.0.0.1:9515 trapapa@192.168.178.75 &
```

Check status:

```bash
ssh -S ~/.ssh/tunnel_sock -O check trapapa@192.168.178.75
```

Terminate:

```bash
ssh -S ~/.ssh/tunnel_sock -O exit trapapa@192.168.178.75
```

---

## 5. Additional Tips

- **Auto-restart on disconnect:** Use `ServerAliveInterval=60` and `ServerAliveCountMax=3` in ssh options.
- **Screen orientation:** VNC resolution defaults to `1929x1080` (`VNC_RESOLUTION` env var). Change it in `debian.dockerfile_1` if needed.
- **Password change:** VNC password can be changed via `vncpasswd` inside the container.
- **Running Selenium tests:** In your Python script:
  ```python
  from selenium import webdriver
  driver = webdriver.Remote('http://localhost:9515/wd/hub', desired_capabilities={})
  ```
- **Monitoring logs:** `docker logs vnc-browser`

---

## 6. Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `vncviewer: Connection refused` | Tunnel not active or server port closed | Restart tunnel, ensure container is running (`docker ps`) |
| `curl: Failed to connect to localhost:9515` | ChromeDriver not started or port blocked | Check `docker logs vnc-browser`, restart container |
| No local `ss` output for 5901/9515 | Tunnel process died | Re-open the SSH tunnel |

---

## 7. Cleanup

If the container or image are no longer needed:

```bash
sshpass -p 'trapapa' ssh trapapa@192.168.178.75 'docker rm -f vnc-browser'
sshpass -p 'trapapa' ssh trapapa@192.168.178.75 'docker rmi vnc-browser:latest'
```
