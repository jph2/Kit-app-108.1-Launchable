#!/bin/bash
set -euo pipefail

# Kit App 108.1 Launchable Startup Script
# Launches Omniverse Kit App 108.1 inside the running Isaac Sim container with WebRTC streaming enabled.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${SCRIPT_DIR}"

OMNIVERSE_KIT_APP=${OMNIVERSE_KIT_APP:-jph2_company.jph2_usd_composer}

echo "Starting Omniverse Kit App 108.1 (app: ${OMNIVERSE_KIT_APP})..."

docker compose up -d isaac-sim

docker compose exec isaac-sim bash -lc "\
  export OMNIVERSE_KIT_APP=${OMNIVERSE_KIT_APP} && \
  cd /isaac-sim && \
  ./isaac-sim.sh \
    --allow-root \
    --no-window \
    --enable omni.kit.livestream.webrtc \
    --/app/livestream/websocket_port=49100 \
    --webrtc-port=47998"

echo "Kit App 108.1 is launching. Use the WebRTC viewer to connect."
