#!/usr/bin/env bash
# ============================================================
# NPS WORK GATE — PRP v3.1 §30
# LokDon Development Framework · LokDon Open Enforcement Licence
# Protocol Owner: Josiah Umezurike
# Version: 1.1 — Fixed for external adoption (2026-07-22)
#
# Wraps any work command — refuses execution if NPS is not complete.
# Place this script in your project's scripts/ directory alongside
# nps_gate.sh. Activate NPS first, then wrap any command:
#
#   bash scripts/nps_gate.sh "Non-Markovian Property Startup"
#   bash scripts/nps_work_gate.sh npm run dev
#   bash scripts/nps_work_gate.sh git commit -m "..."
#
# Flags:
#   --log-only   Record the block/permit decision but do not
#                block execution. Useful for dry-run audits.
#
# Environment variables (all optional):
#   NPS_GATE_SCRIPT   Path to nps_gate.sh relative to repo root.
#                     Default: scripts/nps_gate.sh
#   NPS_DOCS_DIR      Directory for gate log files.
#                     Default: <repo-root>/docs
#
# For adoption instructions see: README.md
# Full PRP v3.1 specification:   https://github.com/jumezurike/PRP-V31
# ============================================================

set -euo pipefail

# ── Resolve repo root ─────────────────────────────────────────
GATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# BUG-4 FIX: Validate that GATE_DIR resolved to a real project root.
# The script must live inside a scripts/ subdirectory at the repo root.
if [[ ! -d "$GATE_DIR/scripts" ]]; then
    echo "" >&2
    echo "ERROR: nps_work_gate.sh must live inside a 'scripts/' directory at the repo root." >&2
    echo "       Current resolved root: $GATE_DIR" >&2
    echo "       Move the script to <repo-root>/scripts/nps_work_gate.sh and retry." >&2
    echo "" >&2
    exit 2
fi

# ── Configuration ─────────────────────────────────────────────
# BUG-3 FIX: Gate script name is a variable — override via env if your
# project uses a different name (e.g. nps-gate.sh with a hyphen).
NPS_GATE_SCRIPT="${NPS_GATE_SCRIPT:-scripts/nps_gate.sh}"

STATE_FILE="$GATE_DIR/.nps_state"

# BUG-1 FIX: Ensure docs directory exists before any log write attempt.
NPS_DOCS_DIR="${NPS_DOCS_DIR:-$GATE_DIR/docs}"
mkdir -p "$NPS_DOCS_DIR"

LOG_FILE="$NPS_DOCS_DIR/nps-gate.log"
WORK_LOG="$NPS_DOCS_DIR/work-execution.log"

DATE_HUMAN=$(date +"%Y-%m-%d %H:%M:%S")
DATE_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Flag parsing ──────────────────────────────────────────────
LOG_ONLY=false
if [[ "${1:-}" == "--log-only" ]]; then
    LOG_ONLY=true
    shift
fi

# ── Logging helpers ───────────────────────────────────────────
# BUG-2 FIX: Both helpers use || true so a write failure (permissions,
# read-only filesystem, etc.) never crashes the gate script itself.
# The gate decision is always shown in the terminal regardless.
log() {
    echo "[$DATE_HUMAN] $1" >> "$LOG_FILE" || true
}

work_log() {
    echo "[$DATE_ISO] $1" >> "$WORK_LOG" || true
}

# ── State helpers ─────────────────────────────────────────────
is_nps_complete() {
    if [[ ! -f "$STATE_FILE" ]]; then return 1; fi
    local state
    state=$(head -1 "$STATE_FILE" 2>/dev/null || echo "LOCKED")
    [[ "$state" == "NPS_COMPLETE" ]]
}

is_expired() {
    if [[ ! -f "$STATE_FILE" ]]; then return 0; fi
    local expiry
    expiry=$(grep "^EXPIRY=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2)
    if [[ -z "$expiry" ]]; then return 0; fi
    local now
    now=$(date +%s)
    [[ $now -gt $expiry ]]
}

get_session_id() {
    grep "^SESSION_ID=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2 || echo "unknown"
}

# ── Gate check: NPS not complete ──────────────────────────────
if ! is_nps_complete; then
    if [[ "$LOG_ONLY" == false ]]; then
        echo ""
        echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${RED}${BOLD}║  WORK BLOCKED — PRP v3.1 §30 VIOLATION                   ║${RESET}"
        echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "  ${BOLD}No work may be performed before NPS is complete.${RESET}"
        echo ""
        echo -e "  Awaiting Non-Markovian Property Startup callsign."
        echo ""
        echo -e "  To unlock:"
        echo -e "    ${BOLD}bash $NPS_GATE_SCRIPT \"Non-Markovian Property Startup\"${RESET}"
        echo ""
        echo -e "  ${YELLOW}Per §11: All work performed before NPS COMPLETE is invalid.${RESET}"
        echo -e "  ${YELLOW}Per §30: Agent cannot work in ignorance of session history.${RESET}"
        echo ""
        log "WORK BLOCKED — NPS not complete — attempted command: ${*:-none} at $DATE_HUMAN"
        work_log "BLOCKED|no_session|${*:-none}"
        exit 1
    else
        # BUG-5 FIX: Use ${*:-<no command>} so --log-only with no trailing
        # command produces a readable message instead of a trailing blank.
        echo -e "${YELLOW}[LOG-ONLY] Would block: ${*:-<no command>}${RESET}" >&2
        work_log "LOG_ONLY_BLOCKED|no_session|${*:-<no command>}"
        exit 0
    fi
fi

# ── Gate check: NPS session expired ──────────────────────────
if is_expired; then
    if [[ "$LOG_ONLY" == false ]]; then
        echo ""
        echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${RED}${BOLD}║  WORK BLOCKED — NPS SESSION EXPIRED                      ║${RESET}"
        echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "  ${BOLD}Your NPS session has expired. Run NPS again to continue.${RESET}"
        echo ""
        echo -e "  To continue working:"
        echo -e "    ${BOLD}bash $NPS_GATE_SCRIPT reset${RESET}"
        echo -e "    ${BOLD}bash $NPS_GATE_SCRIPT \"Non-Markovian Property Startup\"${RESET}"
        echo ""
        log "WORK BLOCKED — NPS expired — attempted command: ${*:-none}"
        work_log "BLOCKED|expired|$(get_session_id)|${*:-none}"
        exit 1
    else
        echo -e "${YELLOW}[LOG-ONLY] Would block (expired): ${*:-<no command>}${RESET}" >&2
        work_log "LOG_ONLY_BLOCKED|expired|$(get_session_id)|${*:-<no command>}"
        exit 0
    fi
fi

# ── NPS complete and session valid — permit work ──────────────
SESSION_ID=$(get_session_id)
echo -e "${GREEN}✓  NPS gate: UNLOCKED (session: ${SESSION_ID:0:8}...) — proceeding${RESET}"
log "Work permitted — NPS complete — session $SESSION_ID — running: ${*:-none}"
work_log "PERMITTED|$SESSION_ID|${*:-none}"

if [[ $# -gt 0 ]]; then
    exec "$@"
else
    echo -e "${YELLOW}No command provided. Specify a command to wrap, e.g.:${RESET}"
    echo -e "  bash scripts/nps_work_gate.sh npm run dev"
    exit 0
fi
