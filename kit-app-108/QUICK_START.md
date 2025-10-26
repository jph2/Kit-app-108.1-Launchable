# Quick Start Guide - Kit App 108.1 Launchable

**Last Updated:** 26.10.2025

---

## 🚀 Start Services

```bash
cd ~/Kit-app-108.1-Launchable/kit-app-108
docker compose up -d
```

Wait ~8-10 minutes for Isaac Sim to fully load (first run) or ~2-3 minutes (subsequent runs).

---

## ✅ Verify Startup

### 1. Check Container Status
```bash
docker compose ps
```

All 4 containers should show "Up":
- `kit-app-108`
- `web-viewer`
- `kit-app-vscode`
- `nginx`

### 2. Monitor Isaac Sim Logs
```bash
docker compose logs kit-app-108 -f
```

Wait for:
```
Isaac Sim Full Streaming App is loaded.
```

### 3. Verify WebRTC is Running
```bash
docker compose logs kit-app-108 | grep -i "webrtc\|livestream"
```

Should see:
```
[ext: omni.kit.livestream.webrtc-7.0.0] startup
```

### 4. Check Process
```bash
docker compose exec kit-app-108 ps aux | grep runapp
```

Should see `runapp.sh` (NOT `runheadless.sh`)

---

## 🌐 Access URLs

Replace `YOUR_EC2_IP` with your actual EC2 public IP.

### VSCode Server
```
http://YOUR_EC2_IP/
```
Password: `brev123`

### WebRTC Viewer
```
http://YOUR_EC2_IP/viewer
```

### Health Check
```
http://YOUR_EC2_IP/health
```
Should return: `healthy`

---

## 🔧 Troubleshooting

### Viewer Shows Blank/White Page

**Check web viewer logs:**
```bash
docker compose logs web-viewer
```

**Verify stream config:**
```bash
docker compose exec web-viewer cat /app/wvs/stream.config.json
```

Should show your public IP in `local.server`.

### Connection Timeout to Port 8011

**Check AWS Security Group:**
- Expose port 8011 (or 1024) for WebRTC signaling
- Expose port 49100 for WebRTC streaming

**Check if port is listening:**
```bash
docker compose exec kit-app-108 bash -c "cat /proc/net/tcp | grep '1F4B'"
```

### Isaac Sim Not Starting with WebRTC

**Check if override is being used:**
```bash
docker compose config | grep -A 5 "kit-app-108"
```

Should show `runapp.sh` in command.

**If still using runheadless.sh:**
```bash
docker compose down
docker compose up -d
```

---

## 🛑 Stop Services

```bash
cd ~/Kit-app-108.1-Launchable/kit-app-108
docker compose down
```

---

## 📊 Port Reference

| Port | Service | Required For |
|------|---------|--------------|
| 80 | Nginx | Web access |
| 1024 or 8011 | WebRTC WebSocket | Viewer signaling |
| 49100 | Isaac Sim Streaming | Viewer video stream |
| 5173 | Web Viewer Dev | Internal only |
| 8080 | VSCode Server | Internal only |

---

## 🔍 Quick Diagnostics

### All-in-One Health Check
```bash
echo "=== Container Status ===" && docker compose ps && \
echo -e "\n=== WebRTC Extension ===" && docker compose logs kit-app-108 | grep -i webrtc && \
echo -e "\n=== Listening Ports ===" && docker compose exec kit-app-108 bash -c "cat /proc/net/tcp | grep '0A'" | head -10
```

### Test Viewer Connection
```bash
curl -I http://localhost/viewer
```

Should return `HTTP/1.1 200 OK`

---

## 📝 Common Issues

### Issue: "no configuration file provided: not found"
**Solution:** You're not in the correct directory.
```bash
cd ~/Kit-app-108.1-Launchable/kit-app-108
```

### Issue: Container keeps restarting
**Solution:** Check logs for errors.
```bash
docker compose logs kit-app-108 --tail=50
```

### Issue: VSCode password not working
**Solution:** Password is `brev123` (hardcoded in docker-compose.yml)

---

## 📚 Additional Documentation

- Full debugging notes: `SETUP_NOTES.md`
- Repository README: `../README.md`
- Original research: `OV_USD_Research/research/01_Research_DISCOVERY/Setting up BREV with Launchable_RESEARCH.md`

