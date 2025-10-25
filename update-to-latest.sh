#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ROOT_DIR}"

if [ ! -d .git ]; then
  echo "Error: run this script from the root of the Kit-app-108.1-Launchable repository." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is not installed. Install git and rerun this script." >&2
  exit 1
fi

STASH_CREATED=0
STASH_MESSAGE=""

if [ -n "$(git status --porcelain)" ]; then
  STASH_CREATED=1
  STASH_MESSAGE="pre-update-$(date +%Y%m%d-%H%M%S)"
  echo "Saving your local edits to a temporary stash (${STASH_MESSAGE})..."
  git stash push -u -m "${STASH_MESSAGE}" >/dev/null
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "${CURRENT_BRANCH}" != "work" ]; then
  echo "Switching from ${CURRENT_BRANCH} to work..."
  git checkout work >/dev/null
fi

echo "Fetching latest commits from origin..."
git fetch origin >/dev/null

echo "Fast-forwarding work to origin/work..."
if ! git pull --ff-only origin work; then
  echo "\nThe automatic update failed because your local branch has diverged." >&2
  echo "Run 'git status' for details." >&2
  if [ ${STASH_CREATED} -eq 1 ]; then
    echo "Your previous edits are still stored in the stash list (label: ${STASH_MESSAGE})." >&2
    echo "Replay them with: git stash pop" >&2
  fi
  exit 1
fi

if [ ${STASH_CREATED} -eq 1 ]; then
  echo "Restoring your saved edits..."
  if ! git stash pop >/dev/null; then
    echo "\nYour local edits conflicted with the latest files." >&2
    echo "Resolve the conflicts shown by 'git status', then stage and commit the fixes." >&2
    echo "The conflicting files contain conflict markers (<<<<<<<, =======, >>>>>>>)." >&2
    exit 1
  fi
fi

echo "Repository is now up to date with origin/work." 
if [ ${STASH_CREATED} -eq 1 ]; then
  echo "Your previous edits have been restored on top of the update."
fi

echo "\nNext steps:"
echo "  cd kit-app-108"
echo "  docker compose up -d"
echo "  ./start-kit-app.sh"
