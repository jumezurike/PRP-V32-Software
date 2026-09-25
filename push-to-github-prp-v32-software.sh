#!/usr/bin/env bash
# ============================================================
# PUSH TO GITHUB — PRP-V32-Software repo
# Syncs docs/github-export/prp-v32-software/ → jumezurike/PRP-V32-Software
#
# Usage (from Replit terminal):
#   bash scripts/push-to-github-prp-v32-software.sh
#
# Requirements:
#   - GITHUB_TOKEN secret set in Replit environment
#   - git available in PATH
# ============================================================

set -euo pipefail

REPO_OWNER="jumezurike"
REPO_NAME="PRP-V32-Software"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${REPO_OWNER}/${REPO_NAME}.git"
EXPORT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../docs/github-export/prp-v32-software" && pwd)"
WORK_DIR="/tmp/prp-v32-software-push-$$"
DATE_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║  PRP-V32-Software — GitHub Sync                          ║${RESET}"
echo -e "${BOLD}${CYAN}║  Target: github.com/${REPO_OWNER}/${REPO_NAME}          ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ── Validate token ────────────────────────────────────────────
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo -e "${RED}ERROR: GITHUB_TOKEN is not set.${RESET}" >&2
    echo "       Add it to Replit Secrets and retry." >&2
    exit 1
fi

# ── Check export dir ──────────────────────────────────────────
if [[ ! -d "$EXPORT_DIR" ]]; then
    echo -e "${RED}ERROR: Export directory not found: $EXPORT_DIR${RESET}" >&2
    exit 1
fi

echo -e "  Export source : ${CYAN}$EXPORT_DIR${RESET}"
echo -e "  Target repo   : ${CYAN}https://github.com/${REPO_OWNER}/${REPO_NAME}${RESET}"
echo ""

# ── Create repo if it does not exist ─────────────────────────
echo "  Checking if repo exists..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}")

if [[ "$HTTP_STATUS" == "404" ]]; then
    echo -e "  ${YELLOW}Repo not found — creating ${REPO_OWNER}/${REPO_NAME}...${RESET}"
    CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        "https://api.github.com/user/repos" \
        -d "{
            \"name\": \"${REPO_NAME}\",
            \"description\": \"PRP v3.1 NPS Work Gate + PRP v3.2 Release Integrity Extension — Software adoption package under LokDon Open Enforcement Licence\",
            \"private\": false,
            \"auto_init\": false,
            \"has_issues\": true,
            \"has_wiki\": false
        }")
    CREATE_STATUS=$(echo "$CREATE_RESPONSE" | tail -1)
    if [[ "$CREATE_STATUS" != "201" ]]; then
        echo -e "${RED}ERROR: Failed to create repo (HTTP $CREATE_STATUS)${RESET}" >&2
        echo "$CREATE_RESPONSE" | head -5 >&2
        exit 1
    fi
    echo -e "  ${GREEN}✓  Repo created: https://github.com/${REPO_OWNER}/${REPO_NAME}${RESET}"
    sleep 2
elif [[ "$HTTP_STATUS" == "200" ]]; then
    echo -e "  ${GREEN}✓  Repo exists: https://github.com/${REPO_OWNER}/${REPO_NAME}${RESET}"
else
    echo -e "${RED}ERROR: Unexpected GitHub API response: HTTP $HTTP_STATUS${RESET}" >&2
    exit 1
fi

# ── Clone or init working copy ────────────────────────────────
echo ""
echo "  Preparing working copy..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

git config --global user.email "nps-sync@lokdon.com" 2>/dev/null || true
git config --global user.name "LokDon NPS Sync" 2>/dev/null || true

# Try to clone; if repo is empty (new), init fresh
if git clone "$REPO_URL" repo 2>/dev/null; then
    cd repo
else
    mkdir repo && cd repo
    git init
    git remote add origin "$REPO_URL"
fi

# ── Sync files ────────────────────────────────────────────────
echo "  Syncing files from export directory..."

# Clear everything except .git
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} + 2>/dev/null || true

# Copy export contents
cp -r "$EXPORT_DIR"/. .

# Copy this push script itself into the repo root
cp "$EXPORT_DIR/push-to-github-prp-v32-software.sh" .

echo ""
echo "  Files to be pushed:"
find . -not -path './.git/*' -not -name '.git' -type f | sort | while read -r f; do
    echo "    ${f#./}"
done
echo ""

# ── Commit and push ───────────────────────────────────────────
git add -A

if git diff --cached --quiet; then
    echo -e "  ${YELLOW}No changes detected — repo is already up to date.${RESET}"
else
    COMMIT_MSG="sync: PRP-V32-Software update ${DATE_ISO}

PRP v3.1 NPS Work Gate (unchanged core) + PRP v3.2 Release Integrity
Extension (PRP-v3.2.md) bundled together
- Base package: same v3.1 NPS/approval/security/UCHU enforcement suite
  as PRP-V31-Software (this repo does not fork or replace that spec)
- Adds PRP-v3.2.md: release-integrity controls layered onto the existing
  Delivery and Documentation phases (freeze/inventory/isolate/bind/verify)
- LokDon Open Enforcement Licence applied"

    git commit -m "$COMMIT_MSG"

    # Push — handle both new (no upstream) and existing repos
    if git push origin main 2>/dev/null || git push origin HEAD:main 2>/dev/null || \
       git push --set-upstream origin main 2>/dev/null; then
        echo -e ""
        echo -e "  ${GREEN}${BOLD}✓  Push complete.${RESET}"
        echo -e "  ${GREEN}    https://github.com/${REPO_OWNER}/${REPO_NAME}${RESET}"
    else
        echo -e "${RED}ERROR: Push failed. Check GITHUB_TOKEN permissions.${RESET}" >&2
        exit 1
    fi
fi

echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║  SYNC COMPLETE — PRP-V32-Software                        ║${RESET}"
echo -e "${BOLD}${GREEN}║  https://github.com/${REPO_OWNER}/${REPO_NAME}          ║${RESET}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
