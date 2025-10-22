# Omniverse Kit App 108.1 Launchable

This launchable provides a cloud-based USD authoring environment using Omniverse Kit App 108.1 with WebRTC streaming capabilities.

## Features

- **Omniverse Kit App 108.1**: Full USD Composer functionality
- **WebRTC Streaming**: Browser-based access to the 3D viewport
- **Custom Extensions**: Includes jph2_company.jph2_usd_composer configuration
- **Cloud GPU**: L40S GPU support for RTX rendering

## Quick Start

1. Deploy this launchable on NVIDIA Brev
2. Wait for containers to start (first launch may take several minutes)
3. Access VSCode via port 80 (HTTP)
4. Run the Kit App: `./start-kit-app.sh`
5. Access the 3D viewport via `/viewer` endpoint

## Ports

- **80**: VSCode Server
- **49100**: Kit App WebRTC
- **47998**: WebRTC streaming

## Usage

### Launch Kit App with Streaming
```bash
./start-kit-app.sh
```

### Manual Launch (if needed)
```bash
/opt/omniverse/kit/kit \
    --app=jph2_company.jph2_usd_composer \
    --no-window \
    --enable omni.kit.livestream.webrtc \
    --port=49100 \
    --webrtc-port=47998
```

## Configuration

The launchable uses your custom Kit App 108.1 configuration with:
- 507+ extensions from your local setup
- Custom material libraries
- USD Composer interface
- RTX rendering enabled

## Troubleshooting

- Ensure all containers are running: `docker ps`
- Check Kit App logs for startup issues
- Verify GPU access: `nvidia-smi`
- Restart containers if needed: `docker-compose restart`
