#!/bin/bash

# Kit App 108.1 Launchable Validation Script
# This script validates the configuration before BREV deployment

echo "=== Kit App 108.1 Launchable Validation ==="
echo "Date: $(date)"
echo ""

# Check if we're in the correct directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ ERROR: docker-compose.yml not found. Run this script from kit-app-108 directory."
    exit 1
fi

echo "✅ Found docker-compose.yml"

# Validate Docker Compose syntax
echo "🔍 Validating Docker Compose configuration..."
if docker-compose config > /dev/null 2>&1; then
    echo "✅ Docker Compose syntax is valid"
else
    echo "❌ ERROR: Docker Compose syntax is invalid"
    docker-compose config
    exit 1
fi

# Check required files
echo "🔍 Checking required files..."
required_files=(
    "docker-compose.yml"
    "docker-compose.override.yml"
    "start-kit-app.sh"
    "deployment.yml"
    "README.md"
    "nginx/Dockerfile"
    "nginx/nginx.conf"
    "web-viewer-sample/Dockerfile"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Found $file"
    else
        echo "❌ ERROR: Missing $file"
        exit 1
    fi
done

# Check startup script permissions
echo "🔍 Checking startup script..."
if [ -x "start-kit-app.sh" ]; then
    echo "✅ start-kit-app.sh is executable"
else
    echo "⚠️  WARNING: start-kit-app.sh is not executable. Run: chmod +x start-kit-app.sh"
fi

# Validate environment variables
echo "🔍 Validating environment variables..."
if grep -q "OMNIVERSE_KIT_APP=jph2_company.jph2_usd_composer" docker-compose.yml; then
    echo "✅ Kit App configuration found"
else
    echo "❌ ERROR: Kit App configuration missing"
    exit 1
fi

if grep -q "ACCEPT_EULA=Y" docker-compose.yml; then
    echo "✅ EULA acceptance configured"
else
    echo "❌ ERROR: EULA acceptance missing"
    exit 1
fi

# Check WebRTC streaming configuration
echo "🔍 Validating WebRTC streaming configuration..."
if grep -q "omni.kit.livestream.webrtc" start-kit-app.sh; then
    echo "✅ WebRTC streaming enabled in startup script"
else
    echo "❌ ERROR: WebRTC streaming not configured in startup script"
    exit 1
fi

# Check port configuration
echo "🔍 Validating port configuration..."
ports=("49100" "47998")
for port in "${ports[@]}"; do
    if grep -q "$port" start-kit-app.sh; then
        echo "✅ Port $port configured"
    else
        echo "❌ ERROR: Port $port not configured"
        exit 1
    fi
done

# Check container image
echo "🔍 Validating container image..."
if grep -q "nvcr.io/nvidia/omniverse/kit:2025.1.0" docker-compose.yml; then
    echo "✅ Correct Omniverse Kit container image"
else
    echo "❌ ERROR: Incorrect container image"
    exit 1
fi

# Check GPU configuration
echo "🔍 Validating GPU configuration..."
if grep -q "runtime: nvidia" docker-compose.yml; then
    echo "✅ NVIDIA runtime configured"
else
    echo "❌ ERROR: NVIDIA runtime not configured"
    exit 1
fi

if grep -q "capabilities: \[gpu\]" docker-compose.yml; then
    echo "✅ GPU capabilities configured"
else
    echo "❌ ERROR: GPU capabilities not configured"
    exit 1
fi

echo ""
echo "=== Validation Complete ==="
echo "✅ All configuration checks passed!"
echo ""
echo "Next steps:"
echo "1. Push this repository to GitHub"
echo "2. Create BREV Launchable using this repository"
echo "3. Configure GPU instance (L40S recommended)"
echo "4. Deploy and test USD streaming functionality"
echo ""
echo "BREV Setup Script:"
echo "git clone https://github.com/your-username/Kit_APP_108_1_Lnchbl.git"
echo "cd Kit_APP_108_1_Lnchbl/kit-app-108"
echo "chmod +x start-kit-app.sh"
echo "docker-compose up -d"
