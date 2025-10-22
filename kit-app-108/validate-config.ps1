# Kit App 108.1 Launchable Validation Script (PowerShell)
# This script validates the configuration before BREV deployment

Write-Host "=== Kit App 108.1 Launchable Validation ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the correct directory
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "❌ ERROR: docker-compose.yml not found. Run this script from kit-app-108 directory." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found docker-compose.yml" -ForegroundColor Green

# Validate Docker Compose syntax
Write-Host "🔍 Validating Docker Compose configuration..." -ForegroundColor Yellow
try {
    docker-compose config | Out-Null
    Write-Host "✅ Docker Compose syntax is valid" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Docker Compose syntax is invalid" -ForegroundColor Red
    docker-compose config
    exit 1
}

# Check required files
Write-Host "🔍 Checking required files..." -ForegroundColor Yellow
$requiredFiles = @(
    "docker-compose.yml",
    "docker-compose.override.yml", 
    "start-kit-app.sh",
    "deployment.yml",
    "README.md",
    "nginx\Dockerfile",
    "nginx\nginx.conf",
    "web-viewer-sample\Dockerfile"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found $file" -ForegroundColor Green
    } else {
        Write-Host "❌ ERROR: Missing $file" -ForegroundColor Red
        exit 1
    }
}

# Validate environment variables
Write-Host "🔍 Validating environment variables..." -ForegroundColor Yellow
$dockerComposeContent = Get-Content "docker-compose.yml" -Raw

if ($dockerComposeContent -match "OMNIVERSE_KIT_APP=jph2_company\.jph2_usd_composer") {
    Write-Host "✅ Kit App configuration found" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: Kit App configuration missing" -ForegroundColor Red
    exit 1
}

if ($dockerComposeContent -match "ACCEPT_EULA=Y") {
    Write-Host "✅ EULA acceptance configured" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: EULA acceptance missing" -ForegroundColor Red
    exit 1
}

# Check WebRTC streaming configuration
Write-Host "🔍 Validating WebRTC streaming configuration..." -ForegroundColor Yellow
$startupScriptContent = Get-Content "start-kit-app.sh" -Raw

if ($startupScriptContent -match "omni\.kit\.livestream\.webrtc") {
    Write-Host "✅ WebRTC streaming enabled in startup script" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: WebRTC streaming not configured in startup script" -ForegroundColor Red
    exit 1
}

# Check port configuration
Write-Host "🔍 Validating port configuration..." -ForegroundColor Yellow
$ports = @("49100", "47998")
foreach ($port in $ports) {
    if ($startupScriptContent -match $port) {
        Write-Host "✅ Port $port configured" -ForegroundColor Green
    } else {
        Write-Host "❌ ERROR: Port $port not configured" -ForegroundColor Red
        exit 1
    }
}

# Check container image
Write-Host "🔍 Validating container image..." -ForegroundColor Yellow
if ($dockerComposeContent -match "nvcr\.io/nvidia/omniverse/kit:2025\.1\.0") {
    Write-Host "✅ Correct Omniverse Kit container image" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: Incorrect container image" -ForegroundColor Red
    exit 1
}

# Check GPU configuration
Write-Host "🔍 Validating GPU configuration..." -ForegroundColor Yellow
if ($dockerComposeContent -match "runtime: nvidia") {
    Write-Host "✅ NVIDIA runtime configured" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: NVIDIA runtime not configured" -ForegroundColor Red
    exit 1
}

if ($dockerComposeContent -match "capabilities: \[gpu\]") {
    Write-Host "✅ GPU capabilities configured" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: GPU capabilities not configured" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Validation Complete ===" -ForegroundColor Green
Write-Host "✅ All configuration checks passed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Push this repository to GitHub" -ForegroundColor White
Write-Host "2. Create BREV Launchable using this repository" -ForegroundColor White
Write-Host "3. Configure GPU instance (L40S recommended)" -ForegroundColor White
Write-Host "4. Deploy and test USD streaming functionality" -ForegroundColor White
Write-Host ""
Write-Host "BREV Setup Script:" -ForegroundColor Cyan
Write-Host "git clone https://github.com/your-username/Kit_APP_108_1_Lnchbl.git" -ForegroundColor White
Write-Host "cd Kit_APP_108_1_Lnchbl/kit-app-108" -ForegroundColor White
Write-Host "chmod +x start-kit-app.sh" -ForegroundColor White
Write-Host "docker-compose up -d" -ForegroundColor White