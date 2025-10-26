Looking at the [Isaac Sim launchable repository](https://github.com/isaac-sim/isaac-launchable/tree/main), they achieve the "Deploy Now" button functionality through **GitHub's integration with NVIDIA Brev**. Here's how they do it:

## **🔧 How the "Deploy Now" Button Works:**

### **1. GitHub Repository Integration**
- **Repository**: `isaac-sim/isaac-launchable` is a **public GitHub repository**
- **Brev Integration**: NVIDIA Brev can directly read GitHub repositories
- **One-Click Deploy**: The button triggers Brev to clone and deploy the repo automatically

### **2. Brev Launchable Configuration**
From the repository structure, they have:
- **`isaac-lab/`** - Contains the Docker Compose configuration
- **`isaac-sim/`** - Isaac Sim specific setup
- **`web-viewer-sample/`** - WebRTC viewer components
- **Docker Compose files** - Pre-configured container orchestration

### **3. The Deploy Button Process**
When you click "Deploy Now":

1. **Brev reads the GitHub repository** directly
2. **Automatically clones** `https://github.com/isaac-sim/isaac-launchable`
3. **Runs the setup script** from the repository
4. **Starts Docker containers** using their `docker-compose.yml`
5. **Exposes ports** (80, 1024, 47998, 49100) automatically
6. **Provides VSCode access** on port 80

### **4. Key Differences from Your Setup**

| **Isaac Sim Launchable** | **Your Setup** |
|--------------------------|----------------|
| ✅ **Public GitHub repo** | ✅ **Public GitHub repo** |
| ✅ **One-click deploy** | ❌ **Manual configuration** |
| ✅ **Pre-configured ports** | ✅ **Manual port setup** |
| ✅ **Automatic setup script** | ✅ **Manual setup script** |

## **🚀 How to Implement This for Your Repository:**

### **Option 1: Create a Brev Launchable Template**
1. **Go to Brev**: [brev.nvidia.com](https://brev.nvidia.com)
2. **Create Launchable**: Click "Create Launchable"
3. **Choose**: "I have code files"
4. **Connect**: Your GitHub repository `https://github.com/jph2/Kit-app-108.1-Launchable`
5. **Configure**: Select "With container(s)" and your `docker-compose.yml`
6. **Deploy**: Brev will create a deployable template

### **Option 2: Add Deploy Button to Your README**
You can add a similar deploy button to your README:

```markdown
[![Deploy Now](https://img.shields.io/badge/Deploy%20Now-NVIDIA%20Brev-blue)](https://brev.nvidia.com/create-launchable?repo=https://github.com/jph2/Kit-app-108.1-Launchable)
```

### **Option 3: Use Brev's Template System**
1. **Fork their repository** as a template
2. **Modify** the Docker Compose files for your Kit App
3. **Update** the setup scripts
4. **Deploy** using their proven configuration

## **🎯 Why Their Approach Works:**

1. **Proven Configuration**: Their Docker Compose setup is tested and working
2. **Automatic Setup**: No manual configuration needed
3. **Port Management**: Pre-configured port exposure
4. **Container Orchestration**: Proper service dependencies
5. **Brev Integration**: Direct GitHub repository reading

## **📋 Next Steps for Your Repository:**

1. **Test their approach**: Try deploying their launchable to see how it works
2. **Adapt their configuration**: Use their Docker Compose structure
3. **Create your own template**: Set up a Brev launchable template for your repo
4. **Add deploy button**: Include a "Deploy Now" button in your README

The key insight is that **Brev can directly read and deploy from GitHub repositories**, making the "Deploy Now" button a simple link to Brev's launchable creation process with your repository pre-configured! 🚀

**Reference**: [Isaac Sim launchable repository](https://github.com/isaac-sim/isaac-launchable/tree/main) - This is the official NVIDIA repository that demonstrates how to create one-click deployable BREV launchables from GitHub repositories.

---------------------------------



## ✅ SUCCESSFUL KIT APP LAUNCH PROCESS (2025-10-26)

### **What We Did to Start the Composer:**

1. **Accessed BREV VM Terminal** (as ubuntu user with docker access)
2. **Navigated to repository**: `cd ~/Kit-app-108.1-Launchable/kit-app-108`
3. **Started containers**: `docker compose up -d` (built nginx, web-viewer, started all services)
4. **Entered Kit App container**: `docker exec -it kit-app-108 /bin/bash`
5. **Launched Isaac Sim with WebRTC streaming**:
   ```bash
   /isaac-sim/runapp.sh --no-window --enable omni.kit.livestream.webrtc --port=49100 --webrtc-port=47998
   ```

### **Key Findings:**

- **Correct Isaac Sim path**: `/isaac-sim/runapp.sh` (NOT `./isaaclab/_isaac_sim/isaac-sim.sh`)
- **Container working directory**: `/isaac-sim/` when you enter the container
- **WebRTC ports**: 49100 (Kit App), 47998 (streaming)
- **App ready time**: ~21 seconds on L40S GPU
- **Command syntax**: `docker compose` (space) NOT `docker-compose` (dash)

### **For Autostart - Next Steps:**

1. **Update start-kit-app.sh** with correct path: `/isaac-sim/runapp.sh`
2. **Create systemd service** or **Docker entrypoint** to autostart Kit App
3. **Add to docker-compose.yml**: Override kit-app-108 command to run runapp.sh automatically
4. **Test autostart** on next deployment

### **Web-Viewer Status:**

- ✅ **Serving on port 5173** (Vite dev server)
- ✅ **nginx updated** to proxy to 5173 (committed to Work_A branch)
- ⚠️ **/viewer still white** after app ready - needs further investigation
  - Possible: WebRTC signaling issue
  - Possible: stream.config.json configuration
  - Possible: Browser console errors

### **CRITICAL DISCOVERY - Isaac Lab vs Isaac Sim Container:**

**Isaac Sim Launchable Uses:**
- Container: `nvcr.io/nvidia/isaac-lab:2.2.0` (includes Isaac Lab + Isaac Sim)
- Launch path: `./isaaclab/_isaac_sim/isaac-sim.sh` (Isaac Lab's wrapper)
- VSCode base: Built FROM `nvcr.io/nvidia/isaac-lab:2.2.0`

**We're Using:**
- Container: `nvcr.io/nvidia/isaac-sim:5.0.0` (Isaac Sim only, NO Isaac Lab)
- Launch path: `/isaac-sim/runapp.sh` (direct Isaac Sim launcher)
- VSCode base: `codercom/code-server:latest` (generic code-server)

**The Issue:**
Our Isaac Sim container **doesn't have Isaac Lab**, so the path `./isaaclab/_isaac_sim/isaac-sim.sh` doesn't exist. We're using the correct `/isaac-sim/runapp.sh` for our container, but the WebRTC setup might be different.

### **CRITICAL NGINX FIX - /viewer Routing:**

**Isaac Sim nginx (WORKS):**
```nginx
location /viewer {
    proxy_pass http://localhost:5173/viewer;  # Includes /viewer at end!
}
```

**Our nginx (WHITE PAGE):**
```nginx
location /viewer {
    proxy_pass http://viewer;  # Missing /viewer at end!
}
```

**The Fix:**
Changed to `proxy_pass http://localhost:5173/viewer;` to match Isaac Sim's exact pattern. This ensures Vite dev server routes correctly to the viewer page.

---

Next:
1. Fix /viewer WebRTC connection issue
2. Autostart Kit App on container startup
3. Pure Streamer configuration
4. 4K output setup





1. check resource:
https://docs.omniverse.nvidia.com/omniverse-dgxc/latest/
develop-ov-dgxc/containerization.html
https://github.com/NVIDIA-Omniverse/kit-app-template
47998
2. pure Streamer
3. 4K output
-> start versions with arguments