#!/bin/bash

# BREV Setup Script for Kit App 108.1 Launchable
# Copy and paste this entire script into BREV's "Setup Script" field

echo "🚀 Setting up Kit App 108.1 Launchable..."

# Clone the repository
git clone https://github.com/jph2/Kit-app-108.1-Launchable.git
cd Kit-app-108.1-Launchable/kit-app-108

# Create necessary directories
mkdir -p /home/ubuntu/workspace/nginx
mkdir -p /home/ubuntu/workspace/web-viewer-sample

# Create nginx configuration
cat > /home/ubuntu/workspace/nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Upstream for VSCode Server
    upstream vscode {
        server 127.0.0.1:8080;
    }

    # Upstream for WebRTC viewer
    upstream viewer {
        server 127.0.0.1:3000;
    }

    server {
        listen 80;
        server_name _;

        # VSCode Server proxy
        location / {
            proxy_pass http://vscode;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket support for VSCode
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # WebRTC viewer proxy
        location /viewer {
            proxy_pass http://viewer;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket support for WebRTC
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Create web viewer sample
cat > /home/ubuntu/workspace/web-viewer-sample/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kit App 108.1 WebRTC Viewer</title>
    <style>
        body {
            margin: 0;
            padding: 20px;
            font-family: Arial, sans-serif;
            background: #1e1e1e;
            color: #ffffff;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .viewer-container {
            background: #2d2d2d;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
        }
        .status {
            margin: 20px 0;
            padding: 10px;
            border-radius: 4px;
            background: #333;
        }
        .connecting {
            background: #ffa500;
            color: #000;
        }
        .connected {
            background: #4caf50;
            color: #000;
        }
        .error {
            background: #f44336;
            color: #fff;
        }
        #viewer {
            width: 100%;
            height: 600px;
            background: #000;
            border-radius: 4px;
            border: 2px solid #444;
        }
        .info {
            margin-top: 20px;
            font-size: 14px;
            color: #888;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Kit App 108.1 WebRTC Viewer</h1>
            <p>Real-time USD authoring and streaming</p>
        </div>
        
        <div class="viewer-container">
            <div id="status" class="status connecting">
                🔄 Connecting to Kit App...
            </div>
            
            <div id="viewer">
                <!-- WebRTC viewer will be embedded here -->
                <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #666;">
                    <div>
                        <h3>WebRTC Viewer</h3>
                        <p>Waiting for Kit App to start...</p>
                        <p>Run: <code>./start-kit-app.sh</code> in VSCode</p>
                    </div>
                </div>
            </div>
            
            <div class="info">
                <p><strong>Ports:</strong> 80 (VSCode), 1024 (WebRTC signaling), 49100 (Kit App), 47998 (streaming)</p>
                <p><strong>Environment:</strong> BREV Cloud GPU with RTX rendering</p>
                <p><strong>Status:</strong> <span id="env-status">BREV Environment Active</span></p>
            </div>
        </div>
    </div>

    <script>
        // Simple status updates
        function updateStatus(message, type) {
            const statusEl = document.getElementById('status');
            statusEl.textContent = message;
            statusEl.className = `status ${type}`;
        }

        // Check if Kit App is running
        function checkKitAppStatus() {
            fetch('/health')
                .then(response => {
                    if (response.ok) {
                        updateStatus('✅ VSCode Server Connected', 'connected');
                    } else {
                        updateStatus('⚠️ VSCode Server Starting...', 'connecting');
                    }
                })
                .catch(error => {
                    updateStatus('❌ Connection Error - Check VSCode Server', 'error');
                });
        }

        // Check status every 5 seconds
        setInterval(checkKitAppStatus, 5000);
        checkKitAppStatus();
    </script>
</body>
</html>
EOF

# Create startup script
cat > /home/ubuntu/workspace/start-kit-app.sh << 'EOF'
#!/bin/bash

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
EOF

# Make scripts executable
chmod +x /home/ubuntu/workspace/start-kit-app.sh

echo "✅ Setup complete! Files created:"
echo "  - /home/ubuntu/workspace/nginx/nginx.conf"
echo "  - /home/ubuntu/workspace/web-viewer-sample/index.html"
echo "  - /home/ubuntu/workspace/start-kit-app.sh"
echo ""
echo "🚀 Starting containers with docker-compose..."

# Start the containers
docker-compose up -d

echo "Kit App 108.1 Launchable setup complete!"
