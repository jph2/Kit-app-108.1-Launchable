#!/bin/bash

# Kit App 108.1 Launchable Startup Script
# This script launches Omniverse Kit App 108.1 with WebRTC streaming enabled

echo "Starting Omniverse Kit App 108.1 with WebRTC streaming..."

# Set environment variables
export ACCEPT_EULA=Y
export OMNIVERSE_KIT_APP=jph2_company.jph2_usd_composer

# Launch Kit App with streaming enabled
# Isaac Sim includes Omniverse Kit, so we can run Kit Apps directly
./isaaclab/_isaac_sim/isaac-sim.sh \
    --no-window \
    --enable omni.kit.livestream.webrtc \
    --port=49100 \
    --webrtc-port=47998

echo "Kit App 108.1 startup complete. Access via WebRTC streaming."
