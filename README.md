# Omniverse Kit App 108.1 Launchable

**Version**: 1.4.0  
**Last Updated**: 2025-10-26  
**GitHub**: [jph2/Kit-app-108.1-Launchable](https://github.com/jph2/Kit-app-108.1-Launchable)  
**Branch**: Work_A  
**Status**: ✅ Build Contexts Pattern - Ready for BREV Deployment

A cloud-based USD authoring environment using Isaac Sim 5.0.0 (which includes Omniverse Kit) with WebRTC streaming capabilities, designed for NVIDIA BREV deployment.

## 🚀 Features

- **Isaac Sim 5.0.0**: Includes Omniverse Kit with USD Composer functionality
- **WebRTC Streaming**: Browser-based access to the 3D viewport
- **Cloud GPU**: L40S GPU minimum with AWS (T4/L4 lacks drivers)
- **Custom Configuration**: Includes jph2_company.jph2_usd_composer setup
- **Docker Containerized**: Complete containerization for easy deployment

## 📋 Prerequisites

- NVIDIA BREV account
- GPU instance with RT cores (L40S minimum with AWS, other providers often block ports)
- Docker and Docker Compose (for local testing)

## 🚀 Quick Start

### Deploy on BREV

1. **Create BREV Launchable**:
   - Go to [brev.nvidia.com](https://brev.nvidia.com)
   - Select "Create Launchable"
   - Choose **"I don't have any code files"** option
   - Select **"VM Mode - Basic VM with Python installed"**
   - Click "Next"

2. **Configure Setup Script**:
   - **Paste Script**: Copy and paste this simple 3-line script (Isaac Sim pattern):
   ```bash
   #!/bin/bash
   git clone -b Work_A https://github.com/jph2/Kit-app-108.1-Launchable.git
   cd Kit-app-108.1-Launchable/kit-app-108
   docker-compose up -d
   ```
   - **What it does**: Clones `Work_A` branch and starts containers (all config files are already in repo)
   - Click "Next"

3. **Configure Services**:
   - **Jupyter Notebook**: Select "No, I don't want Jupyter"
   - **Service Exposure**: Select "TCP/UDP Ports" tab
   - **Add Required Ports**:
     - Port 80 (VSCode Server)
     - Port 1024 (WebRTC signaling - required for viewer)
     - Port 49100 (Kit App WebRTC)
     - Port 47998 (WebRTC streaming)
   - **IP Access**: Select "Allow All IPs" (required for WebRTC streaming and web access)
   - Click "Next"

4. **Configure Compute Resources**:
   - **GPU Selection**: Select "L40S" (scroll in carousel to find it)
   - **Cloud Provider**: AWS (required for port access), other providers often block ports
   - **Expected Configuration**:
     - 1x NVIDIA L40S
     - 44GiB VRAM
     - 32GB RAM
     - 4 CPUs
     - Flexible Storage
     - Cost: ~$2.50/hr
   - **Why L40S**: Minimum GPU that allows port access, T4/L4 lacks drivers

5. **Deploy and Access**:
   - Wait for setup script to complete (first launch may take several minutes)
   - **Set up Secure Links** (see section below)
   - Access VSCode via secure link
   - Run Kit App: `./start-kit-app.sh`
   - Access 3D viewport via WebRTC streaming

## 🔗 Setting Up Secure Links for BREV Access

### **Why You Need Secure Links:**
- BREV protects HTTP services with authentication
- Direct IP access (like `http://35.202.104.93:80`) is blocked for security
- Secure links provide authenticated access to your services

### **How to Create Secure Links:**

1. **Click "Share a Service"** button in the BREV interface
2. **Configure the service**:
   - **Port**: `80` (for VSCode Server)
   - **Service Name**: `vscode-server` (or any name you prefer)
   - **Description**: `VSCode development environment`
3. **Create additional secure links for other services**:
   - **Port 1024**: For WebRTC signaling/viewer
   - **Port 49100**: For Kit App WebRTC
   - **Port 47998**: For WebRTC streaming

### **Step-by-Step Process:**
1. **In BREV interface**: Click the green "Share a Service" button
2. **Fill in the details**:
   - Port: `80`
   - Name: `Kit App VSCode`
   - Description: `Development environment for Kit App 108.1`
3. **Click "Create"** or "Share"
4. **Copy the generated secure URL** (it will look like `https://brev.dev/...`)

### **Expected Result:**
You'll get secure URLs like:
- `https://vscode-server-s6qw18j1s.brevlab.com` (for VSCode)
- `https://webrtc-viewer-s6qw18j1s.brevlab.com` (for WebRTC streaming)

These URLs will:
- ✅ **Authenticate you** automatically
- ✅ **Provide access** to your services
- ✅ **Allow sharing** with team members
- ✅ **Work from anywhere** (no VPN needed)

## 🛠️ Local Development

### Setup
```bash
git clone https://github.com/jph2/Kit-app-108.1-Launchable.git
cd Kit-app-108.1-Launchable/kit-app-108
chmod +x start-kit-app.sh
```

### Run Locally
```bash
# Build and start containers
docker-compose up -d

# Launch Kit App with streaming
./start-kit-app.sh
```

### Validate Configuration
```bash
# Run validation script
powershell -ExecutionPolicy Bypass -File validate-config.ps1
```

## 📁 Repository Structure

```
Kit-app-108.1-Launchable/
├── kit-app-108/                 # Main launchable configuration
│   ├── docker-compose.yml       # Container orchestration
│   ├── docker-compose.override.yml
│   ├── start-kit-app.sh         # Startup script with WebRTC
│   ├── deployment.yml           # BREV deployment config
│   ├── validate-config.ps1      # PowerShell validation
│   ├── validate-config.sh       # Bash validation
│   ├── README.md               # Usage documentation
│   ├── nginx/                  # Reverse proxy configuration
│   └── web-viewer-sample/      # Web streaming interface
├── isaac-sim/                  # Original Isaac Sim configuration
├── isaac-lab/                  # Original Isaac Lab configuration
└── README.md                   # This file
```

## ⚙️ Configuration

### Environment Variables
- `OMNIVERSE_KIT_APP=jph2_company.jph2_usd_composer`
- `ACCEPT_EULA=Y`
- `KIT_EXTENSIONS_PATH=/workspace/extensions`

### Ports
- **80**: VSCode Server
- **1024**: WebRTC signaling (required for viewer)
- **49100**: Kit App WebRTC server
- **47998**: WebRTC streaming endpoint

### GPU Requirements
- NVIDIA GPU with RT cores
- CUDA 12.9+ compatible driver
- T4 minimum for RTX rendering

## 🔧 Customization

### Modify Kit App Configuration
Edit `kit-app-108/docker-compose.yml`:
```yaml
environment:
  - OMNIVERSE_KIT_APP=your_custom_app
  - KIT_EXTENSIONS_PATH=/workspace/extensions
```

### Add Custom Extensions
Mount your extensions in the `shared` volume:
```yaml
volumes:
  - shared:/workspace:rw
```

### Modify Streaming Configuration
Edit `kit-app-108/start-kit-app.sh`:
```bash
/opt/omniverse/kit/kit \
    --app=${OMNIVERSE_KIT_APP} \
    --no-window \
    --enable omni.kit.livestream.webrtc \
    --port=49100 \
    --webrtc-port=47998
```

## ✅ BREV Deployment Checklist

Before deploying to BREV, ensure:

- [ ] **Runtime environment**: Select "VM Mode - Basic VM with Python installed"
- [ ] **Setup script**: Use simple 3-line script (Isaac Sim pattern)
- [ ] **Ports exposed**: 80, 1024, 49100, 47998 (critical: 1024 for WebRTC signaling)
- [ ] **GPU instance**: L40S minimum with AWS (T4/L4 lacks drivers)
- [ ] **Jupyter Notebook**: Select "No, I don't want Jupyter"
- [ ] **IP Access**: Select "Allow All IPs" for WebRTC streaming
- [ ] **All config files**: Already in repository (nginx.conf, web-viewer-sample, etc.)
- [ ] **Script clones**: Repository and starts docker-compose
- [ ] **No file creation**: All files pre-existing in repo

### Why Isaac Sim Pattern Works:
- **Simple 3-line script**: Fits within BREV's character limits
- **All files in repository**: No need to create files at runtime
- **Docker Compose handles everything**: Containers, volumes, networking
- **Proven pattern**: Same approach used by Isaac Sim launchable repository
- **BREV compatibility**: Avoids build context and volume mount issues

## 🐛 Troubleshooting

### Common Issues

**Containers not starting**:
```bash
docker-compose ps
docker-compose logs
```

**WebRTC streaming not working**:
- Check ports 49100 and 47998 are exposed
- Verify GPU is available: `nvidia-smi`
- Check Kit App logs for startup errors

**Authentication issues**:
- BREV handles authentication automatically
- For local testing, ensure Docker is logged in to NVIDIA NGC

### Isaac Sim Launchable Troubleshooting

Based on the [Isaac Sim launchable repository](https://github.com/isaac-sim/isaac-launchable), use the included troubleshooting script:

```bash
# Run the comprehensive troubleshooting script
./troubleshoot.sh

# Check container status
docker ps

# Restart containers if needed
docker-compose down
docker-compose up -d

# Check specific container logs
docker-compose logs vscode-server
docker-compose logs nginx
```

### Expected Container Status

- ✅ **kit-app-108**: Isaac Sim with Kit 108.1
- ✅ **kit-app-vscode**: VSCode Server on port 8080
- ✅ **nginx**: Reverse proxy on port 80
- ✅ **web-viewer**: WebRTC viewer on port 3000

### nginx Welcome Page Issue

If you see the nginx welcome page instead of VSCode:

1. **Check VSCode Server**: `docker ps | grep vscode`
2. **Restart containers**: `docker-compose down && docker-compose up -d`
3. **Wait 2-3 minutes** for VSCode Server to initialize
4. **Check logs**: `docker-compose logs vscode-server`

### Port Access Issues

**Problem**: Ports not accessible or blocked
**Solution**: 
- **Use L40S GPU**: T4/L4 lacks drivers for port access
- **Use AWS provider**: Other providers often block ports
- **Check BREV settings**: Ensure "Allow All IPs" is selected
- **Verify port exposure**: All required ports (80, 8080, 1024, 3000, 49100, 47998) must be exposed

### Validation
Run the validation script to check configuration:
```bash
powershell -ExecutionPolicy Bypass -File validate-config.ps1
```

## 📚 Resources

- [NVIDIA BREV Documentation](https://developer.nvidia.com/brev)
- [Omniverse Kit Documentation](https://docs.omniverse.nvidia.com/kit/)
- [WebRTC Streaming Guide](https://docs.omniverse.nvidia.com/kit/latest/streaming.html)

## 📋 Version History

### v1.4.0 (2025-10-26) - Build Contexts Pattern (CRITICAL FIX)
- ✅ **Root cause identified**: Volume mounts vs build contexts
- ✅ **Changed nginx to use `build:` context** instead of volume mounts
- ✅ **Changed web-viewer to use `build:` context** instead of volume mounts
- ✅ **Config files baked into images** at build time (like Isaac Sim)
- ✅ **No volume mount dependencies** - containers are self-contained
- ✅ **Matches Isaac Sim pattern exactly** - proven to work on BREV

### v1.3.0 (2025-10-25) - Isaac Sim Pattern Implementation
- ✅ **Simplified setup script** to 3 lines (Isaac Sim pattern)
- ✅ **All config files in repository** (no runtime file creation needed)
- ✅ **Updated README** with Isaac Sim approach
- ✅ **Fixed BREV character limits** by using simple script
- ✅ **Proven pattern** from working Isaac Sim launchable

### v1.2.0 (2025-10-25) - Setup Script Added
- ✅ **Added setup.sh script** (like Isaac Sim launchable) to create necessary files at runtime
- ✅ **Fixed volume mount errors** by ensuring files exist before container startup
- ✅ **Updated deployment.yml** to run setup script before docker-compose
- ✅ **Added comprehensive DEBUG_LOG.md** with troubleshooting guide
- ✅ **Updated GPU requirements** to L40S + AWS (T4/L4 lacks drivers)
- ✅ **Added versioning** to README for easy comparison

### v1.1.0 (2025-10-24) - BREV Compatibility Fixes
- ✅ **Fixed BREV build context errors** by removing build contexts
- ✅ **Added VSCode Server container** to resolve nginx welcome page issue
- ✅ **Updated port configuration** with all required ports (80, 1024, 49100, 47998)
- ✅ **Added secure links documentation** for BREV access

### v1.0.0 (2025-10-22) - Initial Release
- ✅ **Created Kit App 108.1 launchable** based on Isaac Sim template
- ✅ **Configured WebRTC streaming** for browser-based access
- ✅ **Set up Docker Compose** with Isaac Sim 5.0.0 base image
- ✅ **Added BREV deployment configuration**

## 🔍 Version Comparison

**To check if your local version matches GitHub:**
1. **Local**: Check the "Version" field at the top of this README
2. **GitHub**: Visit [jph2/Kit-app-108.1-Launchable](https://github.com/jph2/Kit-app-108.1-Launchable)
3. **Compare**: Both should show "Version: 1.2.0" and "Last Updated: 2025-10-25"

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with validation script
5. Submit a pull request

## 📞 Support

For issues and questions:
- Create an issue in this repository
- Check the [troubleshooting section](#-troubleshooting)
- Refer to [BREV documentation](https://developer.nvidia.com/brev)

---

**Built with ❤️ for the Omniverse community**