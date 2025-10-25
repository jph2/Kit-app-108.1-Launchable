# Upgrade Guide: 1.3.0 → 2.0.0 Launchable

This walkthrough is for anyone who previously cloned the **1.3.0** version of `Kit-app-108.1-Launchable` and now wants the refreshed **2.0.0** stack (updated Docker Compose layout, TLS proxy, and dynamic viewer).

The steps are written for non-developers. Follow **Option A** if you are comfortable deleting and recloning the repository. Use **Option B** if you already have local edits that you want to keep.

---

## Option A – Start Fresh (No Local Edits to Keep)

1. **Backup anything important**
   * If you saved USD files, scripts, or notes inside the repo folder, copy them somewhere safe first.

2. **Delete the old folder**
   ```bash
   rm -rf Kit-app-108.1-Launchable
   ```

3. **Clone the new version**
   ```bash
   git clone https://github.com/jph2/Kit-app-108.1-Launchable.git
   cd Kit-app-108.1-Launchable
   ```

4. **Launch the updated stack**
   ```bash
   cd kit-app-108
   docker compose up -d
   ./start-kit-app.sh
   ```

5. **Open the viewer** at `http://<instance-ip>/viewer` (or the Brev secure HTTPS link).

This guarantees you have the exact files described in the new documentation.

---

## Option B – Update an Existing Clone (Keep Local Edits)

These steps pull the new commits into your existing repository and replay your changes on top.

1. **Open a terminal inside your existing repo**
   ```bash
   cd path/to/Kit-app-108.1-Launchable
   ```

2. **Check for local edits**
   ```bash
   git status
   ```
   *If you see “nothing to commit, working tree clean,” skip to step 4.*

3. **Save your edits temporarily**
   ```bash
   git add .
   git stash push -m "my local changes before 2.0.0 upgrade"
   ```
   This hides your edits so the new files can be downloaded cleanly.

4. **Pull the latest commits from GitHub**
```bash
git fetch origin
git checkout work
git pull origin work
```
This updates your local `work` branch to match GitHub.

> 💡 **Shortcut:** you can run `./update-to-latest.sh` from the repo root to perform steps 2–5 automatically. The script saves
> any local edits, fast-forwards to `origin/work`, and restores your changes.

5. **Bring your changes back (if you stashed anything)**
   ```bash
   git stash pop
   ```
   If Git reports conflicts, open the listed files and follow the inline instructions (`<<<<<<<`, `=======`, `>>>>>>>`). Choose the lines you want to keep, then run:
   ```bash
   git add <file>
   git commit
   ```
   *Tip: add a message like "Merge my edits after 2.0.0 upgrade" when prompted.*

6. **Confirm the key files exist**
   ```bash
   ls kit-app-108
   ```
   You should see `docker-compose.yml`, `docker-compose.override.yml`, `start-kit-app.sh`, and the `nginx/` folder.

7. **Start the containers**
   ```bash
   cd kit-app-108
   docker compose up -d
   ./start-kit-app.sh
   ```

8. **Open the viewer** at `http://<instance-ip>/viewer` or `https://<instance-ip>/viewer`.

---

## Troubleshooting Tips

| Issue | Fix |
| --- | --- |
| `git: command not found` | Install Git (`sudo apt-get install git -y`) or download the ZIP from GitHub and follow Option A. |
| `docker compose: command not found` | Install Docker Desktop (Windows/macOS) or Docker Engine + Compose Plugin (Linux). |
| Ports 80/443 already in use | Stop other web servers (`sudo systemctl stop nginx apache2`). |
| Viewer page loads but no stream | Ensure ports 49100 and 47998 are open on your firewall/Brev settings. |

Still stuck? Open an issue on GitHub or reach out with the exact command and error message you see.
