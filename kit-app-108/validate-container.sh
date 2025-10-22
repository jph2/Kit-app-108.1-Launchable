#!/bin/bash
# Kit App 108.1 Container Validation Script
# This script validates the container image and Kit App configuration

echo "=== Kit App 108.1 Container Validation ==="
echo "Date: $(date)"
echo ""

# Check if we're in the correct directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ ERROR: docker-compose.yml not found. Run this script from kit-app-108 directory."
    exit 1
fi

echo "✅ Found docker-compose.yml"

# Extract container image from docker-compose.yml
CONTAINER_IMAGE=$(grep "image:" docker-compose.yml | awk '{print $2}' | tr -d '"')
echo "🔍 Container image: $CONTAINER_IMAGE"

# Check if the image exists (this will fail if image doesn't exist)
echo "🔍 Validating container image exists..."
if docker pull "$CONTAINER_IMAGE" > /dev/null 2>&1; then
    echo "✅ Container image exists and is accessible"
else
    echo "❌ ERROR: Container image '$CONTAINER_IMAGE' does not exist or is not accessible"
    echo "💡 Suggestion: Use a known working image like 'nvcr.io/nvidia/isaac-sim:5.0.0'"
    exit 1
fi

# Check Kit App configuration
echo "🔍 Validating Kit App configuration..."
if grep -q "OMNIVERSE_KIT_APP=jph2_company.jph2_usd_composer" docker-compose.yml; then
    echo "✅ Kit App configuration found"
else
    echo "❌ ERROR: Kit App configuration missing"
    exit 1
fi

# Check WebRTC configuration
echo "🔍 Validating WebRTC configuration..."
if grep -q "omni.kit.livestream.webrtc" start-kit-app.sh; then
    echo "✅ WebRTC streaming configured"
else
    echo "❌ ERROR: WebRTC streaming not configured"
    exit 1
fi

# Check port configuration
echo "🔍 Validating port configuration..."
REQUIRED_PORTS=(80 1024 49100 47998)
for port in "${REQUIRED_PORTS[@]}"; do
    if grep -q "$port" docker-compose.yml || grep -q "$port" deployment.yml; then
        echo "✅ Port $port configured"
    else
        echo "❌ ERROR: Port $port not configured"
        exit 1
    fi
done

echo ""
echo "=== Validation Complete ==="
echo "✅ Container image validation passed!"
echo ""
echo "⚠️  IMPORTANT: After deployment, verify inside the container:"
echo "   1. Run: /opt/omniverse/kit/kit --version"
echo "   2. Check: ls /opt/omniverse/kit/apps/"
echo "   3. Verify: echo \$OMNIVERSE_KIT_APP"
echo ""
echo "If Kit version is wrong or app is missing, the container image needs to be fixed."
