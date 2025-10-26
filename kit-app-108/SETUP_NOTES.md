# Kit App 108.1 Setup Notes

**Date:** 26.10.2025  
**Status:** In Progress - Debugging WebRTC Streaming

---

## ✅ What's Working

1. **Docker Compose** - All 4 containers running successfully:
   - `kit-app-108` - Isaac Sim 5.0.0
   - `web-viewer` - Vite dev server on port 5173
   - `kit-app-vscode` - VSCode Server on port 8080
   - `nginx` - Reverse proxy on port 80

2. **Isaac Sim Startup** - Fully loads in ~8.5 minutes (first run)
   - Extensions loading correctly
   - WebRTC extension detected: `omni.kit.livestream.webrtc-7.0.0`
   - Port 49100 (streaming) is listening

3. **Web Viewer Configuration** - Correctly configured for BREV
   - Public IP detected: `34.229.211.144`
   - Stream config set to `local` mode with correct IP

4. **Nginx Routing** - Proxy working correctly
   - VSCode: `http://ec2-34-229-211-144.compute-1.amazonaws.com/` 
   - Viewer: `http://ec2-34-229-211-144.compute-1.amazonaws.com/viewer`

---

## ❌ Issues Discovered

### 1. Wrong Startup Command
**Problem:** Isaac Sim container uses default entrypoint `/isaac-sim/runheadless.sh` which starts with NVCF streaming, not WebRTC.

**Evidence:**
```bash
root  1  /bin/sh -c /isaac-sim/runheadless.sh
root 42  /isaac-sim/kit/kit /isaac-sim/apps/isaacsim.exp.full.streaming.kit --no-window
```

**Solution:** Override entrypoint in `docker-compose.override.yml` to use `/isaac-sim/runapp.sh` with WebRTC flags.

### 2. Port 8011 Not Accessible Externally
**Problem:** Connection timeout when accessing port 8011 from outside the container.

**Evidence:**
```
curl: (28) Failed to connect to 34.229.211.144 port 8011 after 134789 ms: Connection timed out
```

**Possible Causes:**
- AWS Security Group not exposing port 8011
- BREV firewall rules not configured
- Port should be 1024 for WebRTC signaling (per README)

---

## 🔧 Fixes Applied

### docker-compose.override.yml
Updated to properly override the Isaac Sim entrypoint:

```yaml
services:
  kit-app-108:
    entrypoint: ["/bin/bash", "-c"]
    command: >
      /isaac-sim/runapp.sh
      --no-window
      --enable omni.kit.livestream.webrtc
      --/app/livestream/port=49100
      --/app/livestream/websocket/port=8011
      --/app/livestream/websocket/framerate=60
      --/app/livestream/websocket/encoder=nvenc
```

---

## 📋 Next Steps

### 1. Restart with Fixed Configuration
```bash
cd ~/Kit-app-108.1-Launchable/kit-app-108
docker compose down
docker compose up -d
docker compose logs kit-app-108 -f
```

### 2. Verify WebRTC Startup
Look for these messages in logs:
```
[ext: omni.kit.livestream.webrtc-7.0.0] startup
Livestream WebRTC server started
WebSocket server listening on port 8011
```

### 3. Check Process Command
Verify `runapp.sh` is running:
```bash
docker compose exec kit-app-108 ps aux | grep runapp
```

### 4. Configure AWS/BREV Firewall
Expose required ports in security group:
- **80** - HTTP/Nginx (already working)
- **1024** or **8011** - WebRTC signaling  
- **49100** - WebRTC streaming
- **8080** - VSCode Server
- **5173** - Web Viewer dev server

### 5. Alternative: Use Port 1024
If port 8011 continues to fail, try port 1024 (mentioned in README):

```yaml
--/app/livestream/websocket/port=1024
```

### 6. Test Viewer
After restart and firewall configuration:
```
http://ec2-34-229-211-144.compute-1.amazonaws.com/viewer
```

---

## 📊 Port Reference

| Port | Hex  | Service | Status |
|------|------|---------|--------|
| 80   | 0050 | Nginx | ✅ Listening |
| 1024 | 0400 | WebRTC Signaling (alt) | ❓ Not checked |
| 5173 | 1435 | Web Viewer (Vite) | ✅ Listening (localhost) |
| 8011 | 1F4B | WebRTC WebSocket | ✅ Listening (timeout external) |
| 8080 | 1F90 | VSCode Server | ✅ Listening |
| 47998 | BB7E | WebRTC Streaming (alt) | ❌ Not listening |
| 49100 | BFCC | WebRTC Streaming | ✅ Listening |

---

## 🔍 Useful Debugging Commands

### Check Listening Ports
```bash
docker compose exec kit-app-108 bash -c "cat /proc/net/tcp | grep '0A'" | head -20
```

### Check Running Processes
```bash
docker compose exec kit-app-108 ps aux | grep isaac
```

### Check WebRTC Logs
```bash
docker compose logs kit-app-108 | grep -i "webrtc\|livestream"
```

### Test Port from Web Viewer
```bash
docker compose exec web-viewer curl -v http://34.229.211.144:8011
```

### Monitor All Logs
```bash
docker compose logs -f
```

---

## 📝 Notes

- Isaac Sim first launch takes ~8.5 minutes (cache building)
- Subsequent restarts should be 2-3 minutes
- Network mode is `host` for all containers
- GPU: Requires NVIDIA GPU with RT cores (T4 minimum)
- WebRTC requires proper firewall configuration for external access

---

## 🔗 Resources

- [NVIDIA Isaac Sim Documentation](https://docs.omniverse.nvidia.com/isaacsim/)
- [WebRTC Streaming Guide](https://docs.omniverse.nvidia.com/isaacsim/latest/advanced_tutorials/tutorial_advanced_livestreaming.html)
- [Kit Extension Template](https://github.com/NVIDIA-Omniverse/kit-extension-template)

