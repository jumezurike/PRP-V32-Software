#!/usr/bin/env bash
# setup_nps_tiers.sh — UCHU One-Time Project Setup
# Universal Codified Hypervisor Unit  v1.0.0
# PRP v3.1 §30 — Protocol Owner: Josiah Umezurike
#
# Run once after cloning to wire structural enforcement into the project:
#
#   1. Creates tier directories (tiers/tier1-5) for your knowledge base
#   2. Creates docs/nps-audits/ and docs/session-reports/ directories
#   3. Creates .local/ directory for approval and sentinel files
#   4. Installs git hooks (pre-commit + pre-push) via core.hooksPath
#   5. Creates sample files so the NPS gate can read each tier
#   6. Runs uchu-init.sh — UCHU introduces itself and configures callsign
#
# Usage: bash scripts/setup_nps_tiers.sh
#
# After running this script, populate the tier directories:
#   tiers/tier1/  — Governance docs (PRP_v31.md, ROLES.md, VIOLATION_TABLE.md)
#   tiers/tier2/  — Technical Reference (ARCHITECTURE.md, STRIDE.md, NFR.md)
#   tiers/tier3/  — Session History (newest first, YYYYMMDD_PR.txt files)
#   tiers/tier4/  — Security Baseline (ACCEPTED_FINDINGS.md, OPEN_CVES.md)
#   tiers/tier5/  — Live Code (key current source files)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

echo ""
echo -e "${BOLD}UCHU — Project Setup${RESET}"
echo "  Universal Codified Hypervisor Unit  v1.0.0"
echo "  Protocol Owner: Josiah Umezurike"
echo ""

# ── 1. Tier directories ────────────────────────────────────────────────────────
echo "Creating tier directories..."
for tier in tier1 tier2 tier3 tier4 tier5; do
  mkdir -p "$REPO_ROOT/tiers/$tier"
  echo -e "  ${GREEN}✓${RESET}  tiers/$tier"
done

# ── 2. Docs directories ───────────────────────────────────────────────────────
mkdir -p "$REPO_ROOT/docs/nps-audits"
mkdir -p "$REPO_ROOT/docs/session-reports"
echo -e "  ${GREEN}✓${RESET}  docs/nps-audits"
echo -e "  ${GREEN}✓${RESET}  docs/session-reports"

# ── 3. .local directory ───────────────────────────────────────────────────────
mkdir -p "$REPO_ROOT/.local"
# .local/ must be in .gitignore (sentinels are session state, not source)
if [[ -f "$REPO_ROOT/.gitignore" ]]; then
  if ! grep -q "^\.local/" "$REPO_ROOT/.gitignore"; then
    echo ".local/" >> "$REPO_ROOT/.gitignore"
    echo -e "  ${GREEN}✓${RESET}  .local/ added to .gitignore"
  fi
else
  echo ".local/" > "$REPO_ROOT/.gitignore"
  echo -e "  ${GREEN}✓${RESET}  .gitignore created with .local/"
fi

# ── 4. Git hooks ──────────────────────────────────────────────────────────────
# UCHU's structural enforcement — hooks replace honor-based compliance.
echo ""
echo "Installing git hooks..."
if [[ -d "$REPO_ROOT/.git" ]]; then
  git -C "$REPO_ROOT" config core.hooksPath scripts/.githooks
  chmod +x "$REPO_ROOT/scripts/.githooks/pre-commit" 2>/dev/null || true
  chmod +x "$REPO_ROOT/scripts/.githooks/pre-push" 2>/dev/null || true
  echo -e "  ${GREEN}✓${RESET}  core.hooksPath set to scripts/.githooks"
  echo -e "  ${GREEN}✓${RESET}  pre-commit hook: active — blocks commits without callsign + approval"
  echo -e "  ${GREEN}✓${RESET}  pre-push hook:   active — blocks pushes without session close"
  echo ""
  echo -e "  ${BOLD}Git hooks are now ACTIVE.${RESET}"
else
  echo -e "  ${YELLOW}⚠  Not a git repository — hooks not installed.${RESET}"
  echo "     Run 'git init' first, then re-run this script."
fi

# ── 5. Sample tier files ──────────────────────────────────────────────────────
echo ""
echo "Creating sample tier files (replace with your actual content)..."

if [[ ! -f "$REPO_ROOT/tiers/tier1/PRP_v31.md" ]]; then
  cat > "$REPO_ROOT/tiers/tier1/PRP_v31.md" << 'EOF'
# PRP v3.1 — Problem Resolution Protocol
# TIER 1 — Governance
# Replace this file with your actual PRP_v31_Final.md
# from docs/PRP_v31_Final.md or download from:
# https://github.com/jumezurike/PRP-V31
EOF
  echo -e "  ${GREEN}✓${RESET}  tiers/tier1/PRP_v31.md (sample)"
fi

if [[ ! -f "$REPO_ROOT/tiers/tier2/ARCHITECTURE.md" ]]; then
  echo "# Architecture — TIER 2 — Technical Reference" > "$REPO_ROOT/tiers/tier2/ARCHITECTURE.md"
  echo "# Replace with your actual architecture document." >> "$REPO_ROOT/tiers/tier2/ARCHITECTURE.md"
  echo -e "  ${GREEN}✓${RESET}  tiers/tier2/ARCHITECTURE.md (sample)"
fi

if [[ ! -f "$REPO_ROOT/tiers/tier4/ACCEPTED_FINDINGS.md" ]]; then
  echo "# Accepted Security Findings — TIER 4 — Security Baseline" > "$REPO_ROOT/tiers/tier4/ACCEPTED_FINDINGS.md"
  echo "# Document all accepted security findings here." >> "$REPO_ROOT/tiers/tier4/ACCEPTED_FINDINGS.md"
  echo -e "  ${GREEN}✓${RESET}  tiers/tier4/ACCEPTED_FINDINGS.md (sample)"
fi

# ── 6. Make all scripts executable ────────────────────────────────────────────
echo ""
echo "Setting script permissions..."
for script in \
  nps_gate.sh nps_work_gate.sh approval_gate.sh stage_for_approval.sh \
  validate_nps_labels.sh validate_session_close.sh release_integrity_gate.sh security_gate.sh \
  uchu-init.sh uchu-identity.sh; do
  if [[ -f "$REPO_ROOT/scripts/$script" ]]; then
    chmod +x "$REPO_ROOT/scripts/$script"
    echo -e "  ${GREEN}✓${RESET}  scripts/$script"
  fi
done

# ── 7. UCHU introduction — callsign setup ─────────────────────────────────────
echo ""
echo "──────────────────────────────────────────────────────────────────"
echo ""
UCHU_INIT="$REPO_ROOT/scripts/uchu-init.sh"
if [[ -f "$UCHU_INIT" ]]; then
  bash "$UCHU_INIT"
else
  echo -e "${YELLOW}  ⚠  uchu-init.sh not found — skipping callsign setup.${RESET}"
  echo "     Copy uchu-init.sh to scripts/ and re-run to configure your callsign."
  echo ""
  echo "  To start a session (once callsign is configured):"
  echo "    bash scripts/nps_gate.sh \"[your callsign]\""
fi

echo ""
echo "  To propose a change (approval gate):"
echo "    bash scripts/approval_gate.sh --request 'description'"
echo "    → Protocol Owner types 'approved' or 'proceed' in chat"
echo "    bash scripts/approval_gate.sh --grant 'description'"
echo ""
echo "  Enforcement is now STRUCTURAL (not honor-based):"
echo "    git commit  → blocked without callsign + Protocol Owner approval"
echo "    git push    → blocked without session report + security gate"
echo "    GitHub push → HUMAN_PUSH=1 git push  (agent cannot push)"
echo ""
