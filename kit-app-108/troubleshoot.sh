#!/bin/bash

# Kit App 108.1 Troubleshooting Script
# Based on Isaac Sim launchable troubleshooting approach

echo "🔧 Kit App 108.1 Troubleshooting Script"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found. Run this script from the kit-app-108 directory."
    exit 1
fi

echo "✅ Found docker-compose.yml"

# Check Docker status
echo ""
echo "🐳 Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi
echo "✅ Docker is running"

# Check running containers
echo ""
echo "📋 Checking running containers..."
docker ps

echo ""
echo "🔍 Expected containers:"
echo "  - kit-app-108 (Isaac Sim with Kit 108.1)"
echo "  - kit-app-vscode (VSCode Server)"
echo "  - nginx (Reverse proxy)"
echo "  - web-viewer (WebRTC viewer)"

# Check if all expected containers are running
echo ""
echo "🔍 Checking container status..."

KIT_APP=$(docker ps --format "table {{.Names}}" | grep "kit-app-108" | wc -l)
VSCODE=$(docker ps --format "table {{.Names}}" | grep "kit-app-vscode" | wc -l)
NGINX=$(docker ps --format "table {{.Names}}" | grep "nginx" | wc -l)
VIEWER=$(docker ps --format "table {{.Names}}" | grep "web-viewer" | wc -l)

if [ $KIT_APP -eq 0 ]; then
    echo "❌ kit-app-108 container is not running"
else
    echo "✅ kit-app-108 container is running"
fi

if [ $VSCODE -eq 0 ]; then
    echo "❌ kit-app-vscode container is not running"
else
    echo "✅ kit-app-vscode container is running"
fi

if [ $NGINX -eq 0 ]; then
    echo "❌ nginx container is not running"
else
    echo "✅ nginx container is running"
fi

if [ $VIEWER -eq 0 ]; then
    echo "❌ web-viewer container is not running"
else
    echo "✅ web-viewer container is running"
fi

# Check port availability
echo ""
echo "🌐 Checking port availability..."
netstat -tlnp | grep -E ":(80|8080|1024|3000|49100|47998)" || echo "No services listening on expected ports"

# Check nginx configuration
echo ""
echo "⚙️ Checking nginx configuration..."
if [ -f "nginx/nginx.conf" ]; then
    echo "✅ nginx.conf found"
    echo "📄 nginx.conf contents:"
    cat nginx/nginx.conf
else
    echo "❌ nginx.conf not found"
fi

# Check web viewer sample
echo ""
echo "🌐 Checking web viewer sample..."
if [ -f "web-viewer-sample/index.html" ]; then
    echo "✅ web-viewer-sample/index.html found"
else
    echo "❌ web-viewer-sample/index.html not found"
fi

# Restart containers if needed
echo ""
echo "🔄 Container restart options:"
echo "1. Restart all containers: docker-compose down && docker-compose up -d"
echo "2. Restart specific container: docker-compose restart <container-name>"
echo "3. View logs: docker-compose logs <container-name>"

# Check VSCode Server accessibility
echo ""
echo "🔗 Checking VSCode Server accessibility..."
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ VSCode Server is accessible on port 8080"
else
    echo "❌ VSCode Server is not accessible on port 8080"
fi

# Check nginx accessibility
echo ""
echo "🌐 Checking nginx accessibility..."
if curl -s http://localhost:80 > /dev/null 2>&1; then
    echo "✅ nginx is accessible on port 80"
    echo "📄 nginx response:"
    curl -s http://localhost:80 | head -5
else
    echo "❌ nginx is not accessible on port 80"
fi

echo ""
echo "🎯 Next steps:"
echo "1. If containers are not running: docker-compose up -d"
echo "2. If VSCode Server is not accessible: Check port 8080"
echo "3. If nginx shows welcome page: VSCode Server might not be running"
echo "4. Access VSCode via: http://localhost:80 (or your BREV secure link)"
echo "5. Launch Kit App: ./start-kit-app.sh"

echo ""
echo "🔧 Troubleshooting complete!"
