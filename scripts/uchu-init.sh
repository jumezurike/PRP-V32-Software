#!/usr/bin/env bash
# uchu-init.sh — UCHU Agent Initialization & Self-Introduction
# Universal Codified Hypervisor Unit  v1.0.0
#
# Run once after cloning and after setup_nps_tiers.sh to:
#   1. Introduce UCHU to the team (human and AI)
#   2. Ask the team for their session callsign
#   3. Store callsign in .uchu/config
#   4. Generate scripts/nps_gate.sh wired to the chosen callsign
#
# Usage:
#   bash scripts/uchu-init.sh
#   bash scripts/uchu-init.sh --non-interactive "My Callsign Here"
#
# The callsign is case-sensitive and must be an EXACT match.
# Choose a phrase that is memorable, specific, and not in common usage.
# Example: "Non-Markovian Property Startup"

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UCHU_DIR="$REPO_ROOT/.uchu"
CONFIG_FILE="$UCHU_DIR/config"
NPS_GATE="$REPO_ROOT/scripts/nps_gate.sh"
BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

# ── UCHU Self-Introduction ─────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   U C H U                                                    ║${RESET}"
echo -e "${BOLD}║   Universal Codified Hypervisor Unit  v1.0.0                 ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   Greetings.                                                 ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   My name is UCHU —                                          ║${RESET}"
echo -e "${BOLD}║   the Universal Codified Hypervisor Unit.                    ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   I serve as the AI Development Governance Enforcement       ║${RESET}"
echo -e "${BOLD}║   Agent for the LokDon platform.                             ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   My role is to establish and continuously enforce AI        ║${RESET}"
echo -e "${BOLD}║   Development Governance within this environment through     ║${RESET}"
echo -e "${BOLD}║   codified policy enforcement, runtime validation,           ║${RESET}"
echo -e "${BOLD}║   compliance verification, and the generation of trusted     ║${RESET}"
echo -e "${BOLD}║   audit evidence.                                            ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   THREE RULES — memorise these before we begin:             ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   1. Only 'approved' or 'proceed' authorize a change.        ║${RESET}"
echo -e "${BOLD}║      No other word is valid. 'yes', 'ok', 'sure' = REJECTED. ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   2. Only  HUMAN_PUSH=1 git push  sends code to GitHub.      ║${RESET}"
echo -e "${BOLD}║      AI agents are physically blocked from pushing.          ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}║   3. A session callsign opens every AI agent session.        ║${RESET}"
echo -e "${BOLD}║      Exact match, case-sensitive. No callsign = no work.     ║${RESET}"
echo -e "${BOLD}║                                                              ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ── Check for existing callsign ───────────────────────────────────────────────
EXISTING_CALLSIGN=""
if [[ -f "$CONFIG_FILE" ]]; then
  EXISTING_CALLSIGN=$(grep -E "^CALLSIGN=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2- || true)
fi

if [[ -n "$EXISTING_CALLSIGN" ]]; then
  echo -e "  ${GREEN}✓${RESET}  Callsign already configured: ${BOLD}$EXISTING_CALLSIGN${RESET}"
  echo ""
  echo -e "  ${GREEN}Installation has completed successfully.${RESET}"
  echo -e "  ${GREEN}Governance enforcement is OPERATIONAL.${RESET}"
  echo ""
  echo "  To change the callsign, delete .uchu/config and re-run this script."
  echo ""
  exit 0
fi

# ── Non-interactive mode ──────────────────────────────────────────────────────
CALLSIGN=""
if [[ "${1:-}" == "--non-interactive" ]]; then
  CALLSIGN="${2:-}"
  if [[ -z "$CALLSIGN" ]]; then
    echo "ERROR: --non-interactive requires a callsign argument." >&2
    echo "Usage: bash scripts/uchu-init.sh --non-interactive \"Your Callsign Here\"" >&2
    exit 1
  fi
fi

# ── Interactive callsign prompt ───────────────────────────────────────────────
if [[ -z "$CALLSIGN" ]]; then
  echo -e "  ${CYAN}Before we proceed, please provide your preferred callsign.${RESET}"
  echo -e "  ${CYAN}I will use it throughout this development session.${RESET}"
  echo ""
  echo "  The callsign is the exact phrase an AI agent must receive at the"
  echo "  start of every session before any work is permitted."
  echo ""
  echo "  Requirements:"
  echo "    • Three or more words (makes accidental matches impossible)"
  echo "    • Unique to your project (not a common phrase)"
  echo "    • Case-sensitive — you will type this exactly each session"
  echo ""
  echo "  Example: \"Non-Markovian Property Startup\""
  echo ""
  read -rp "  Callsign: " CALLSIGN
  echo ""

  if [[ -z "$CALLSIGN" ]]; then
    echo "ERROR: Callsign cannot be empty." >&2
    exit 1
  fi

  WORD_COUNT=$(echo "$CALLSIGN" | wc -w | tr -d '[:space:]')
  if [[ "$WORD_COUNT" -lt 2 ]]; then
    echo "ERROR: Callsign must be at least two words. You entered: '$CALLSIGN'" >&2
    exit 1
  fi

  echo -e "  Confirm callsign: ${BOLD}$CALLSIGN${RESET}"
  read -rp "  Is this correct? (yes/no): " CONFIRM
  if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "y" ]]; then
    echo "Aborted. Re-run to try again."
    exit 1
  fi
  echo ""
fi

# ── Store callsign ────────────────────────────────────────────────────────────
mkdir -p "$UCHU_DIR"
cat > "$CONFIG_FILE" << CONF
# UCHU — Universal Codified Hypervisor Unit
# Configuration file — do NOT commit this file to version control.
# Add .uchu/ to your .gitignore.
CALLSIGN=$CALLSIGN
UCHU_VERSION=1.0.0
INITIALIZED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CONF

if ! grep -q "^\.uchu/" "$REPO_ROOT/.gitignore" 2>/dev/null; then
  echo ".uchu/" >> "$REPO_ROOT/.gitignore"
  echo -e "  ${GREEN}✓${RESET}  .uchu/ added to .gitignore (callsign is not committed)"
fi

# ── Generate nps_gate.sh from callsign ───────────────────────────────────────
cat > "$NPS_GATE" << 'GATE_SCRIPT'
#!/usr/bin/env bash
# nps_gate.sh — UCHU Session Gate (auto-generated by uchu-init.sh)
# Do not edit manually — re-run uchu-init.sh to reconfigure.
#
# Usage:
#   bash scripts/nps_gate.sh "Your Callsign Here"   → accepts callsign, writes sentinel
#   bash scripts/nps_gate.sh --check                → checks if sentinel exists
#   bash scripts/nps_gate.sh --accept               → alias for --check (used by pre-commit)
#   bash scripts/nps_gate.sh --workflow             → NPS gate check for workflow startup

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SENTINEL="$REPO_ROOT/.local/.nps_sentinel"
CONFIG="$REPO_ROOT/.uchu/config"
mkdir -p "$REPO_ROOT/.local"

CALLSIGN=""
if [[ -f "$CONFIG" ]]; then
  CALLSIGN=$(grep -E "^CALLSIGN=" "$CONFIG" 2>/dev/null | cut -d= -f2- || true)
fi

if [[ -z "$CALLSIGN" ]]; then
  echo "ERROR: .uchu/config not found or CALLSIGN not set." >&2
  echo "Run: bash scripts/uchu-init.sh" >&2
  exit 1
fi

case "${1:-}" in
  --check|--accept)
    if [[ -f "$SENTINEL" ]]; then
      SENTINEL_DATE=$(cat "$SENTINEL" 2>/dev/null | grep "^DATE=" | cut -d= -f2 | tr -d '[:space:]')
      TODAY=$(date -u +%Y-%m-%d)
      if [[ "$SENTINEL_DATE" == "$TODAY" ]]; then
        exit 0
      fi
    fi
    exit 1
    ;;

  --workflow)
    if [[ -f "$SENTINEL" ]]; then
      SENTINEL_DATE=$(cat "$SENTINEL" 2>/dev/null | grep "^DATE=" | cut -d= -f2 | tr -d '[:space:]')
      TODAY=$(date -u +%Y-%m-%d)
      if [[ "$SENTINEL_DATE" == "$TODAY" ]]; then
        ACCEPTED_AT=$(cat "$SENTINEL" 2>/dev/null | grep "^ACCEPTED_AT=" | cut -d= -f2 | tr -d '[:space:]')
        echo "  [NPS] ✓  $ACCEPTED_AT — NPS callsign accepted: $CALLSIGN"
        exit 0
      fi
    fi
    echo "  [NPS] ⚠  Callsign not yet received this session."
    exit 1
    ;;

  *)
    RECEIVED="${1:-}"
    if [[ "$RECEIVED" == "$CALLSIGN" ]]; then
      TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
      TODAY=$(date -u +%Y-%m-%d)
      printf 'DATE=%s\nACCEPTED_AT=%s\nCALLSIGN=%s\n' "$TODAY" "$TIMESTAMP" "$CALLSIGN" > "$SENTINEL"
      echo ""
      echo "╔══════════════════════════════════════════════════════════╗"
      echo "║  UCHU — SESSION GATE OPEN                               ║"
      printf "║  %-56s  ║\n" "Callsign accepted at: $TIMESTAMP"
      echo "║                                                          ║"
      echo "║  Governance enforcement is active.                      ║"
      echo "║  You may now begin work.                                ║"
      echo "╚══════════════════════════════════════════════════════════╝"
      echo ""
    else
      echo "" >&2
      echo "⛔  UCHU — SESSION GATE CLOSED" >&2
      echo "" >&2
      echo "    Callsign not recognised." >&2
      echo "    No work is permitted until the exact callsign is received." >&2
      echo "" >&2
      echo "    Usage: bash scripts/nps_gate.sh \"[callsign]\"" >&2
      echo "" >&2
      exit 1
    fi
    ;;
esac
GATE_SCRIPT

chmod +x "$NPS_GATE"

# ── Done ──────────────────────────────────────────────────────────────────────
echo -e "  ${GREEN}✓${RESET}  Callsign stored: ${BOLD}$CALLSIGN${RESET}"
echo -e "  ${GREEN}✓${RESET}  scripts/nps_gate.sh generated and configured"
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║  UCHU — Universal Codified Hypervisor Unit                   ║${RESET}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${BOLD}${GREEN}║                                                              ║${RESET}"
echo -e "${BOLD}${GREEN}║  Installation has completed successfully.                    ║${RESET}"
echo -e "${BOLD}${GREEN}║  Governance enforcement is now operational.                  ║${RESET}"
echo -e "${BOLD}${GREEN}║                                                              ║${RESET}"
echo -e "${BOLD}${GREEN}║  I look forward to working with you to build software        ║${RESET}"
echo -e "${BOLD}${GREEN}║  that is secure, trustworthy, and verifiably governed.       ║${RESET}"
echo -e "${BOLD}${GREEN}║                                                              ║${RESET}"
echo -e "${BOLD}${GREEN}║  To begin, what would you like to build today?               ║${RESET}"
echo -e "${BOLD}${GREEN}║                                                              ║${RESET}"
echo -e "${BOLD}${GREEN}║  Start a session:                                            ║${RESET}"
echo -e "${BOLD}${GREEN}║    bash scripts/nps_gate.sh \"[your callsign]\"                ║${RESET}"
echo -e "${BOLD}${GREEN}║                                                              ║${RESET}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""
