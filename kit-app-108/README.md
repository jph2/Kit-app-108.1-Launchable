# Omniverse Kit App 108.1 Launchable

This launchable packages Omniverse Kit App 108.1 inside the Isaac Sim 5.0.0 container so it can be streamed remotely through the NVIDIA Brev "launchable" workflow.

## Features

- **Omniverse Kit App 108.1** with USD Composer configuration `jph2_company.jph2_usd_composer`
- **WebRTC streaming** via the Isaac Sim livestream service and bundled web viewer
- **Automatic TLS proxy** using the same OpenResty stack as the official Isaac Sim launchable
- **GPU reservations** for the entire host to ensure RTX rendering performance

## Quick Start

```bash
git clone https://github.com/jph2/Kit-app-108.1-Launchable.git
cd Kit-app-108.1-Launchable/kit-app-108
docker compose up -d
./start-kit-app.sh
```

Once the Kit app is running, open `http://<instance-ip>/viewer` (or the Brev secure link you created) to access the WebRTC stream.

## Ports

- **80 / 443** – HTTPS-enabled reverse proxy that fronts the Vite dev server
- **49100** – Kit App WebRTC signaling
- **47998** – WebRTC media stream

## Configuration

The compose file forwards the standard Isaac Sim cache and data directories to named volumes and sets:

- `OMNIVERSE_KIT_APP=jph2_company.jph2_usd_composer`
- `KIT_EXTENSIONS_PATH=/workspace/extensions`
- `ACCEPT_EULA=Y`

Update these environment variables in `docker-compose.yml` if you need to point at a different Kit App package or extension set.

## Troubleshooting

1. Confirm all containers are running:
   ```bash
   docker compose ps
   ```
2. Inspect the Kit container logs if the stream does not start:
   ```bash
   docker compose logs isaac-sim
   ```
3. Restart the stack:
   ```bash
   docker compose down
   docker compose up -d
   ```
4. Re-run `./start-kit-app.sh` to restart the Kit process inside the container.

For deeper debugging reference the upstream [isaac-sim/isaac-launchable](https://github.com/isaac-sim/isaac-launchable) repository.
