# BREV Deployment Debug Log

## 🐛 Known Issues and Solutions

### **Issue 1: nginx Welcome Page Instead of VSCode**
**Symptom**: Accessing port 80 shows nginx welcome page instead of VSCode Server
**Root Cause**: VSCode Server container not running or not properly configured
**Solution**: 
- Added VSCode Server container (`codercom/code-server`) on port 8080
- Configured nginx to proxy to VSCode Server
- Added proper container dependencies and startup order

### **Issue 2: BREV Build Context Error**
**Symptom**: `Error: rpc error: code = Internal desc = service web-viewer has build context`
**Root Cause**: BREV doesn't support Docker build contexts for services provided via URL
**Solution**:
- Removed all `build:` contexts from docker-compose.yml
- Replaced with pre-built images (`nginx:alpine`)
- Used volume mounts for configuration files

### **Issue 3: Volume Mount Errors**
**Symptom**: `error mounting "/home/ubuntu/workspace/nginx/nginx.conf" to rootfs at "/etc/nginx/nginx.conf": create mountpoint for /etc/nginx/nginx.conf mount: cannot create subdirectories`
**Root Cause**: BREV environment doesn't have the mounted files in the expected locations
**Solution**:
- **Added setup script** (like Isaac Sim launchable) to create necessary files
- **Setup script creates**: nginx.conf, web-viewer-sample/index.html, start-kit-app.sh
- **Files created at runtime** in BREV workspace before container startup
- **No more volume mount errors** - files exist when containers start

### **Issue 4: Port Access Blocked**
**Symptom**: 403 Forbidden when accessing services directly via IP
**Root Cause**: BREV security blocks direct IP access
**Solution**:
- Use BREV "Secure Links" for authenticated access
- Create secure links for each required port (80, 1024, 49100, 47998)
- Access services via secure URLs instead of direct IP

### **Issue 5: GPU Driver Issues**
**Symptom**: T4/L4 GPUs don't allow port access
**Root Cause**: T4/L4 GPUs lack proper drivers for port access
**Solution**:
- Use L40S GPU minimum (has proper drivers)
- Use AWS cloud provider (other providers often block ports)
- Updated specifications: 44GiB VRAM, 32GB RAM

### **Issue 6: Container Startup Order**
**Symptom**: Services starting in wrong order causing failures
**Root Cause**: Missing container dependencies
**Solution**:
- Added `depends_on` clauses in docker-compose.yml
- nginx depends on vscode-server
- web-viewer depends on kit-app-108
- Proper startup sequence: kit-app-108 → vscode-server → nginx → web-viewer

## 🔧 Debugging Commands

### **Check Container Status**
```bash
docker ps
# Should show: kit-app-108, kit-app-vscode, nginx, web-viewer
```

### **Check Container Logs**
```bash
docker-compose logs vscode-server
docker-compose logs nginx
docker-compose logs kit-app-108
```

### **Restart Containers**
```bash
docker-compose down
docker-compose up -d
```

### **Check Port Accessibility**
```bash
curl -I http://localhost:80    # nginx/VSCode
curl -I http://localhost:8080  # VSCode Server direct
curl -I http://localhost:3000  # WebRTC viewer
```

### **Run Troubleshooting Script**
```bash
./troubleshoot.sh
```

## 🔧 Setup Script Solution

### **What We Were Missing**
The [Isaac Sim launchable](https://github.com/isaac-sim/isaac-launchable) has a **setup script** that creates necessary files at runtime, but our project was missing this!

### **Our Setup Script (`setup.sh`)**
```bash
#!/bin/bash
# Creates nginx.conf, web-viewer-sample/index.html, start-kit-app.sh
# Runs before docker-compose up -d
```

### **Files Created by Setup Script**
- **`/home/ubuntu/workspace/nginx/nginx.conf`** - Nginx configuration with VSCode proxy
- **`/home/ubuntu/workspace/web-viewer-sample/index.html`** - WebRTC viewer interface
- **`/home/ubuntu/workspace/start-kit-app.sh`** - Kit App startup script

### **Why This Fixes the Volume Mount Error**
1. **Files exist** when containers start (created by setup script)
2. **No more "file not found"** errors
3. **Volume mounts work** because target files exist
4. **Same pattern** as Isaac Sim launchable

## 🔥 BUILD CONTEXTS vs VOLUME MOUNTS (v1.4.0) - ROOT CAUSE IDENTIFIED

### **THE CRITICAL DIFFERENCE**

After line-by-line analysis of Isaac Sim launchable, I discovered the fundamental difference:

**Isaac Sim Approach:**
```yaml
services:
  nginx:
    build:
      context: ./nginx  # Builds from Dockerfile
      network: host
  # Dockerfile copies nginx.conf into image at BUILD time
```

**Our Previous Approach:**
```yaml
services:
  nginx:
    image: nginx:alpine  # Pre-built image
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro  # Runtime mount
```

### **Why Volume Mounts Failed**
1. **Setup script clones repository** to `/home/ubuntu/Kit-app-108.1-Launchable/kit-app-108`
2. **docker-compose looks for** `./nginx/nginx.conf` relative to working directory
3. **Volume mount tries to mount** the file from the filesystem
4. **If files are missing or inaccessible** → container fails to start

###  **Why Build Contexts Work**
1. **Dockerfile COPIES files into image** at build time: `COPY nginx.conf /etc/nginx/nginx.conf`
2. **Config files are BAKED INTO the image** - no external dependencies
3. **No volume mount failures** - everything is self-contained
4. **Works identically locally and on BREV** - no environment differences

### **The Fix**
Changed `docker-compose.yml` to use `build:` contexts instead of `image:` + volume mounts:
- nginx: Uses `build: context: ./nginx` → builds from Dockerfile
- web-viewer: Uses `build: context: ./web-viewer-sample` → builds from Dockerfile

## 🎯 Isaac Sim Pattern Implementation (v1.3.0)

### **The Real Solution**
After studying the [Isaac Sim launchable](https://github.com/isaac-sim/isaac-launchable), we discovered they use a **simple 3-line setup script**:

```bash
#!/bin/bash
git clone https://github.com/isaac-sim/isaac-launchable
cd isaac-launchable/isaac-lab
docker compose up -d
```

### **Why This Works Better**
1. **Simple 3 lines** - Fits within BREV's character limits
2. **All files in repository** - No runtime file creation needed
3. **Docker Compose handles everything** - Containers, volumes, networking
4. **Proven pattern** - Same approach as working Isaac Sim launchable
5. **No volume mount errors** - Files exist because they're in the repo

### **Our Updated Approach**
```bash
#!/bin/bash
git clone https://github.com/jph2/Kit-app-108.1-Launchable.git
cd Kit-app-108.1-Launchable/kit-app-108
docker-compose up -d
```

## 📋 Current Configuration

### **Container Architecture**
- **kit-app-108**: Isaac Sim 5.0.0 with Kit 108.1
- **kit-app-vscode**: VSCode Server on port 8080
- **nginx**: Reverse proxy on port 80 (proxies to VSCode)
- **web-viewer**: WebRTC viewer on port 3000

### **Port Configuration**
- **80**: nginx (VSCode Server proxy)
- **8080**: VSCode Server (internal)
- **1024**: WebRTC signaling
- **3000**: WebRTC viewer
- **49100**: Kit App WebRTC
- **47998**: WebRTC streaming

### **BREV Requirements**
- **GPU**: L40S minimum (T4/L4 lacks drivers)
- **Cloud Provider**: AWS (other providers often block ports)
- **Runtime**: "With container(s)" (not VM Mode)
- **Port Access**: "Allow All IPs" required

## 🚀 Next Steps

1. **Test Updated Configuration**: Deploy with L40S + AWS
2. **Verify VSCode Access**: Should work via port 80 (no nginx welcome page)
3. **Test WebRTC Streaming**: Launch Kit App and access via `/viewer`
4. **Monitor Container Health**: Use troubleshooting script regularly

## 📝 Notes

- **Isaac Sim 5.0.0** includes Kit 108.1 built-in (no separate Kit installation needed)
- **BREV Secure Links** required for authenticated access (not direct IP)
- **Container dependencies** critical for proper startup order
- **L40S + AWS** combination proven to work for port access
- **Troubleshooting script** based on Isaac Sim launchable approach

## 🔗 References

- [Isaac Sim launchable repository](https://github.com/isaac-sim/isaac-launchable) - Reference implementation
- [BREV Documentation](https://developer.nvidia.com/brev) - Official BREV docs
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/) - GPU container support
