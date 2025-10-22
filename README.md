# Omniverse Kit App 108.1 Launchable

A cloud-based USD authoring environment using Isaac Sim 5.0.0 (which includes Omniverse Kit) with WebRTC streaming capabilities, designed for NVIDIA BREV deployment.

## 🚀 Features

- **Isaac Sim 5.0.0**: Includes Omniverse Kit with USD Composer functionality
- **WebRTC Streaming**: Browser-based access to the 3D viewport
- **Cloud GPU**: T4 GPU minimum for RTX rendering
- **Custom Configuration**: Includes jph2_company.jph2_usd_composer setup
- **Docker Containerized**: Complete containerization for easy deployment

## 📋 Prerequisites

- NVIDIA BREV account
- GPU instance with RT cores (T4 minimum)
- Docker and Docker Compose (for local testing)

## 🚀 Quick Start

### Deploy on BREV

1. **Create BREV Launchable**:
   - Go to [brev.nvidia.com](https://brev.nvidia.com)
   - Select "Create Launchable"
   - Choose "I have code files" option
   - Connect this GitHub repository

2. **Configure Instance**:
   - **GPU Type**: T4 (minimum for RTX rendering)
   - **CPU Cores**: 4
   - **Memory**: 16GB
   - **Disk**: 100GB

3. **Expose Ports**:
   - Port 80 (VSCode Server)
   - Port 1024 (WebRTC signaling - required for viewer)
   - Port 49100 (Kit App WebRTC)
   - Port 47998 (WebRTC streaming)

4. **Deploy and Access**:
   - Wait for containers to start (first launch may take several minutes)
   - Access VSCode via port 80 (HTTP)
   - Run Kit App: `./start-kit-app.sh`
   - Access 3D viewport via `/viewer` endpoint

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

- [ ] **Ports exposed**: 80, 1024, 49100, 47998 (critical: 1024 for WebRTC signaling)
- [ ] **GPU instance**: T4 minimum with RT cores (avoid Crusoe, use AWS)
- [ ] **Container image**: Uses `nvcr.io/nvidia/isaac-sim:5.0.0` (includes Omniverse Kit)
- [ ] **EULA accepted**: `ACCEPT_EULA=Y` environment variable set
- [ ] **WebRTC enabled**: `--no-window --enable omni.kit.livestream.webrtc` in startup
- [ ] **NVIDIA runtime**: GPU capabilities properly configured in docker-compose.yml
- [ ] **Viewer access**: Use `/viewer` endpoint after Kit App starts

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

### Validation
Run the validation script to check configuration:
```bash
powershell -ExecutionPolicy Bypass -File validate-config.ps1
```

## 📚 Resources

- [NVIDIA BREV Documentation](https://developer.nvidia.com/brev)
- [Omniverse Kit Documentation](https://docs.omniverse.nvidia.com/kit/)
- [WebRTC Streaming Guide](https://docs.omniverse.nvidia.com/kit/latest/streaming.html)

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