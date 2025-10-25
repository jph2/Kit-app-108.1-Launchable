# Omniverse Kit App 108.1 Launchable

**Version**: 2.0.0  
**Last Updated**: 2025-10-25  
**GitHub**: [jph2/Kit-app-108.1-Launchable](https://github.com/jph2/Kit-app-108.1-Launchable)

This repository adapts NVIDIA's [isaac-sim/isaac-launchable](https://github.com/isaac-sim/isaac-launchable) pattern for Omniverse Kit App 108.1. It packages the Kit App inside the Isaac Sim 5.0.0 container, adds the upstream TLS-enabled reverse proxy, and reuses the dynamic WebRTC viewer so Brev deployments behave identically to the working Isaac Sim launchable.

> ⚠️ **Coming from version 1.3.0?** Follow the [upgrade guide](UPGRADE_FROM_1.3.0.md) for step-by-step instructions on replacing your old checkout with the new 2.0.0 files or merging them with your local edits.

## 🚀 What's Included

- **Isaac Sim 5.0.0 container** with `OMNIVERSE_KIT_APP=jph2_company.jph2_usd_composer`
- **OpenResty reverse proxy** that auto-generates TLS certificates and proxies ports 80/443 to the viewer dev server
- **Dynamic WebRTC viewer** rebuilt from `web-viewer-sample/Dockerfile`, ensuring the correct Brev/IP detection logic runs at startup
- **Startup script** (`start-kit-app.sh`) that launches the Kit App inside the running Isaac Sim container with WebRTC streaming enabled

## 📋 Prerequisites

- NVIDIA Brev account
- GPU instance with RTX cores (L40S recommended)
- Docker and Docker Compose (for local validation)
- Access to `nvcr.io` Isaac Sim images

## ⚡ Quick Start (Local or Brev Shell)

```bash
git clone https://github.com/jph2/Kit-app-108.1-Launchable.git
cd Kit-app-108.1-Launchable/kit-app-108
docker compose up -d
./start-kit-app.sh
```

After the Kit App begins streaming, open `http://<instance-ip>/viewer` (or the Brev secure link) to launch the WebRTC client.

### Updating an Existing Clone

If you already cloned this repository and just want the newest files, run the helper script from the repo root:

```bash
./update-to-latest.sh
```

The script safely stashes any local edits, fast-forwards the `work` branch to `origin/work`, restores your edits, and prints the
commands needed to restart the containers. When you're ready to publish your own edits, push them back to GitHub with `git push
origin work` (or replace `work` with your active branch name).

If this session doesn't already know about your GitHub remote, add it first and confirm it's wired up before pushing:

```bash
git remote add origin git@github.com:jph2/Kit-app-108.1-Launchable.git  # or your fork URL
git remote -v
```

> ℹ️ **Need to publish these updates back to GitHub?** Follow the step-by-step guide in [PUSHING_CHANGES_WITH_GITHUB_DESKTOP.md](PUSHING_CHANGES_WITH_GITHUB_DESKTOP.md) for GitHub Desktop instructions.

## ☁️ Deploying on Brev

1. **Create Launchable** using the "I don't have any code files" flow and select **VM Mode - Basic VM with Python installed**.
2. **Setup Script** – paste the 3-line script:
   ```bash
   #!/bin/bash
   git clone https://github.com/jph2/Kit-app-108.1-Launchable.git
   cd Kit-app-108.1-Launchable/kit-app-108
   docker compose up -d
   ```
3. **Service Exposure** – share these TCP ports: 80, 443, 49100, 47998.
4. **Compute** – choose an AWS L40S instance (other providers often block WebRTC ports).
5. When the VM is ready, SSH in (or open a terminal) and run `./start-kit-app.sh` from `kit-app-108` to begin streaming.

## 🔧 Configuration Details

- All reverse proxy assets (`nginx/Dockerfile`, `entrypoint.sh`, `nginx.conf`) are identical to the Isaac Sim launchable and build automatically via `docker-compose.override.yml`.
- The viewer container rebuilds the Vite project and rewrites `stream.config.json` using the provided `ENV` (defaults to `brev`).
- Isaac Sim caches, data, logs, and user documents are persisted through named volumes defined in `docker-compose.yml`.

### Environment Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `ACCEPT_EULA` | `Y` | Required by the Isaac Sim image |
| `OMNIVERSE_KIT_APP` | `jph2_company.jph2_usd_composer` | Selects the Kit App bundle |
| `KIT_EXTENSIONS_PATH` | `/workspace/extensions` | Optional extensions directory |

Update these values in `kit-app-108/docker-compose.yml` to point at a different Kit App or extension path.

## 🧪 Validation & Troubleshooting

- Check container status: `docker compose ps`
- Tail Kit logs: `docker compose logs isaac-sim`
- Restart the stack: `docker compose down && docker compose up -d`
- Relaunch the Kit App process: `./start-kit-app.sh`

If the viewer cannot connect, ensure ports 49100 and 47998 are exposed and that the Brev secure link forwards 80/443.

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make and test your changes
4. Submit a pull request

---

**Built with ❤️ for the Omniverse community**
