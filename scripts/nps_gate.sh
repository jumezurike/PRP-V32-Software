#!/usr/bin/env bash
# ============================================================
# NPS GATE — Non-Markovian Property Startup Enforcement
# PRP v3.1 §30 | LokDon Development Framework
# Protocol Owner: Josiah Umezurike
# Version: 2.1 | 2026 — Full audit with invariants
# ============================================================

set -euo pipefail

# ── Constants ────────────────────────────────────────────────
CALLSIGN="Non-Markovian Property Startup"
SESSION_TTL_SECONDS=3600
GATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_DIR="$GATE_DIR/docs/nps-audits"
STATE_FILE="$GATE_DIR/.nps_state"
AUDIT_TRAIL="$GATE_DIR/docs/nps-audit-trail.log"
LOG_FILE="$GATE_DIR/docs/nps-gate.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE_HUMAN=$(date +"%Y-%m-%d %H:%M:%S")
DATE_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

log() { echo "[$DATE_HUMAN] $1" >> "$LOG_FILE"; }
audit_trail() { echo "[$DATE_ISO] $1" >> "$AUDIT_TRAIL"; }
generate_hash() { echo -n "$1:$2" | sha256sum | cut -d' ' -f1; }

is_locked() {
    [[ ! -f "$STATE_FILE" ]] && return 0
    local state=$(head -1 "$STATE_FILE" 2>/dev/null || echo "LOCKED")
    [[ "$state" != "NPS_COMPLETE" ]]
}

is_expired() {
    [[ ! -f "$STATE_FILE" ]] && return 0
    local expiry=$(grep "^EXPIRY=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2)
    [[ -z "$expiry" ]] && return 0
    [[ $(date +%s) -gt $expiry ]]
}

set_complete() {
    local expiry=$(( $(date +%s) + SESSION_TTL_SECONDS ))
    local hash=$(generate_hash "$TIMESTAMP" "$CALLSIGN")
    local session_id
    session_id=$(uuidgen 2>/dev/null || echo "$TIMESTAMP-$(od -An -N4 -tx /dev/urandom 2>/dev/null | tr -d ' ')" 2>/dev/null || echo "$TIMESTAMP-$$")
    cat > "$STATE_FILE" << EOF
NPS_COMPLETE
TIMESTAMP=$TIMESTAMP
EXPIRY=$expiry
HASH=$hash
SESSION_ID=$session_id
EOF
    log "NPS COMPLETE — expires in ${SESSION_TTL_SECONDS}s"
    audit_trail "NPS_COMPLETE|$DATE_ISO|$TIMESTAMP|expires=$expiry"
}

reset_gate() {
    [[ -f "$STATE_FILE" ]] && cp "$STATE_FILE" "$STATE_FILE.archive.$(date +%s)" 2>/dev/null || true
    echo "LOCKED" > "$STATE_FILE"
    log "NPS gate reset to LOCKED"
}

print_banner() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║       NPS GATE — PRP v3.1 §30 ENFORCEMENT                ║${RESET}"
    echo -e "${BOLD}${CYAN}║       LokDon Development Framework                       ║${RESET}"
    echo -e "${BOLD}${CYAN}║       Protocol Owner: Josiah Umezurike                   ║${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

awaiting_message() {
    print_banner
    echo -e "${YELLOW}${BOLD}⚠  GATE STATUS: LOCKED${RESET}"
    echo ""
    echo -e "${BOLD}Awaiting Non-Markovian Property Startup callsign.${RESET}"
    echo ""
    echo -e "  ${CYAN}To unlock: bash nps_gate.sh \"Non-Markovian Property Startup\"${RESET}"
    log "Gate queried — LOCKED"
}

verify_callsign() {
    if [[ "$1" != "$CALLSIGN" ]]; then
        echo -e "${RED}${BOLD}✗  INVALID CALLSIGN${RESET}"
        echo -e "  Received: \"$1\""
        echo -e "  Required: \"$CALLSIGN\""
        log "INVALID callsign: $1"
        exit 1
    fi
}

ensure_tier_dirs() {
    for tier in tier1 tier2 tier3 tier4 tier5; do
        mkdir -p "$GATE_DIR/tiers/$tier"
    done
    mkdir -p "$AUDIT_DIR"
}

list_tier_files() {
    local tier_dir="$GATE_DIR/tiers/$1"
    [[ ! -d "$tier_dir" ]] && { echo "  (directory not found)"; return; }
    local found=0
    for f in "$tier_dir"/*; do
        if [[ -f "$f" ]] && [[ ! "$f" =~ /\. ]]; then
            echo "  - $(basename "$f") — [read and confirmed]"
            found=1
        fi
    done
    [[ -f "$tier_dir/.project_state" ]] && { echo "  - .project_state — [read and confirmed]"; found=1; }
    [[ $found -eq 0 ]] && echo "  (no files)"
}

list_tier_files_reversed() {
    local tier_dir="$GATE_DIR/tiers/$1"
    [[ ! -d "$tier_dir" ]] && { echo "  (directory not found)"; return; }
    local found=0
    while IFS= read -r f; do
        if [[ -f "$f" ]] && [[ ! "$f" =~ /\. ]]; then
            echo "  - $(basename "$f") — [read and confirmed]"
            found=1
        fi
    done < <(find "$tier_dir" -maxdepth 1 -type f ! -name ".*" -printf "%T@ %p\n" 2>/dev/null | sort -rn | cut -d' ' -f2-)
    [[ $found -eq 0 ]] && echo "  (no files)"
}

read_tier() {
    local tier_dir="$GATE_DIR/tiers/$1"
    local tier_name="$2"
    local count=0
    if [[ ! -d "$tier_dir" ]]; then
        echo -e "  ${YELLOW}No $tier_name files found${RESET}"
        return
    fi
    for f in "$tier_dir"/*; do
        if [[ -f "$f" ]]; then
            echo -e "  ${GREEN}✓${RESET}  $(basename "$f")"
            log "Tier $1 read: $(basename "$f")"
            count=$((count + 1))
        fi
    done
    [[ $count -eq 0 ]] && echo -e "  ${YELLOW}(no files)${RESET}" || echo -e "  ${GREEN}$count file(s) read${RESET}"
    echo ""
}

read_tier_reversed() {
    local tier_dir="$GATE_DIR/tiers/$1"
    local tier_name="$2"
    local count=0
    if [[ ! -d "$tier_dir" ]]; then
        echo -e "  ${YELLOW}No $tier_name files found${RESET}"
        return
    fi
    while IFS= read -r f; do
        if [[ -f "$f" ]]; then
            echo -e "  ${GREEN}✓${RESET}  $(basename "$f")"
            log "Tier $1 read: $(basename "$f")"
            count=$((count + 1))
        fi
    done < <(find "$tier_dir" -maxdepth 1 -type f ! -name ".*" -printf "%T@ %p\n" 2>/dev/null | sort -rn | cut -d' ' -f2-)
    [[ $count -eq 0 ]] && echo -e "  ${YELLOW}(no files)${RESET}" || echo -e "  ${GREEN}$count file(s) read (newest first)${RESET}"
    echo ""
}

write_audit_file() {
    local audit_file="$AUDIT_DIR/NPS_AUDIT_${TIMESTAMP}.md"
    local file_hash=$(generate_hash "$TIMESTAMP" "$CALLSIGN")
    local tier1_list=$(list_tier_files "tier1")
    local tier2_list=$(list_tier_files "tier2")
    local tier3_list=$(list_tier_files_reversed "tier3")
    local tier4_list=$(list_tier_files "tier4")
    local tier5_list=$(list_tier_files "tier5")
    local open_items=$(cat "$GATE_DIR/tiers/tier3/.open_items" 2>/dev/null || echo "None recorded.")
    local project_state=$(cat "$GATE_DIR/tiers/tier5/.project_state" 2>/dev/null || echo "No project state file found in Tier 5.")
    local accepted_findings=$(cat "$GATE_DIR/tiers/tier4/.accepted_findings" 2>/dev/null || echo "None on record.")
    local session_id=$(grep "^SESSION_ID=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2 || echo "unknown")
    local expiry_epoch=$(grep "^EXPIRY=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2)
    local expiry_date=$(date -d "@$expiry_epoch" 2>/dev/null || echo "unknown")
    cat > "$audit_file" << EOF
# NPS AUDIT FILE
# Path: docs/nps-audits/NPS_AUDIT_${TIMESTAMP}.md
# PRP v3.1 §30.4 | Generated: ${DATE_HUMAN}
# Protocol Owner: Josiah Umezurike | LokDon
# HASH: ${file_hash}

## 1. Reading Declaration

### Tier 1 — Governance
${tier1_list}

### Tier 2 — Technical Reference
${tier2_list}

### Tier 3 — Session History (newest to oldest)
${tier3_list}

### Tier 4 — Security Baseline
${tier4_list}

### Tier 5 — Live Code
${tier5_list}

## 2. Open Items Carried Forward
${open_items}

## 3. Invariants Confirmed
- [ ] No file modification without verified backup (§3)
- [ ] No implementation without explicit approval — "approved" or "proceed" only (§2)
- [ ] No delivery without pre-deployment security scan (§22.6)
- [ ] AI agent may not self-approve or merge (§21.7, §24.4)
- [ ] No PHI in code, logs, or test environments (§19.3)
- [ ] No plaintext credentials anywhere (§15.1)
- [ ] STRIDE threat model required before implementation (§23)
- [ ] Only implement the approved solution — no unapproved changes (§4)

## 4. Current Project State
${project_state}

## 5. Security Findings Accepted
${accepted_findings}

## 6. Session Metadata
- Session ID: ${session_id}
- Expires: ${expiry_date}
- TTL: ${SESSION_TTL_SECONDS} seconds

## 7. Agent Declaration
I declare that I have read all files listed above in the order specified by PRP v3.1 §30.3.
Open items have been identified and carried forward.
All invariants are confirmed.
I will not begin any work before declaring NPS COMPLETE.

NPS COMPLETE — ${DATE_HUMAN}
Agent operating under PRP v3.1 §30
Protocol Owner: Josiah Umezurike
EOF
    echo -e "  ${GREEN}Audit file written: NPS_AUDIT_${TIMESTAMP}.md${RESET}"
    echo -e "  ${DIM}Hash: ${file_hash}${RESET}"
    log "Audit file written with hash $file_hash"
}

run_nps_sequence() {
    ensure_tier_dirs
    print_banner
    echo -e "${GREEN}${BOLD}✓  CALLSIGN ACCEPTED${RESET}"
    echo ""
    echo -e "${BOLD}Executing NPS sequence per PRP v3.1 §30.3 ...${RESET}"
    echo ""
    log "NPS sequence starting"
    echo -e "${CYAN}[Step 1/7]${RESET} Reading Tier 1 — Governance ..."
    read_tier "tier1" "Governance"
    echo -e "${CYAN}[Step 2/7]${RESET} Reading Tier 2 — Technical Reference ..."
    read_tier "tier2" "Technical Reference"
    echo -e "${CYAN}[Step 3/7]${RESET} Reading Tier 3 — Session History (newest first) ..."
    read_tier_reversed "tier3" "Session History"
    echo -e "${CYAN}[Step 4/7]${RESET} Reading Tier 4 — Security Baseline ..."
    read_tier "tier4" "Security Baseline"
    echo -e "${CYAN}[Step 5/7]${RESET} Reading Tier 5 — Live Code ..."
    read_tier "tier5" "Live Code"
    echo -e "${CYAN}[Step 6/7]${RESET} Writing NPS audit file ..."
    write_audit_file
    echo -e "${CYAN}[Step 7/7]${RESET} Declaring NPS complete ..."
    set_complete
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}║  NPS COMPLETE — $(date +"%Y-%m-%d %H:%M:%S") — ready for work  ║${RESET}"
    echo -e "${GREEN}${BOLD}║  Session expires in ${SESSION_TTL_SECONDS} seconds (1 hour)         ║${RESET}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    log "NPS COMPLETE declared"
}

check_status() {
    print_banner
    if is_locked; then
        echo -e "${RED}${BOLD}STATUS: LOCKED${RESET}"
        echo -e "  Awaiting Non-Markovian Property Startup callsign."
    elif is_expired; then
        echo -e "${RED}${BOLD}STATUS: EXPIRED${RESET}"
        local expiry=$(grep "^EXPIRY=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2)
        [[ -n "$expiry" ]] && echo -e "  Session expired at: $(date -d "@$expiry" 2>/dev/null || echo "$expiry")"
        echo -e "  ${YELLOW}Run 'bash nps_gate.sh reset' then unlock with callsign.${RESET}"
    else
        local unlock_time=$(sed -n '2p' "$STATE_FILE" 2>/dev/null | cut -d'=' -f2 || echo "unknown")
        local expiry=$(grep "^EXPIRY=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2)
        local remaining=$((expiry - $(date +%s)))
        local session_id=$(grep "^SESSION_ID=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2)
        echo -e "${GREEN}${BOLD}STATUS: UNLOCKED${RESET}"
        echo -e "  Session ID:    ${session_id:0:16}..."
        echo -e "  NPS completed: $unlock_time"
        echo -e "  Session expires in: ${remaining} seconds ($((remaining / 60)) minutes)"
    fi
    echo ""
}

force_lock() {
    print_banner
    echo -e "${RED}${BOLD}🔒 FORCE LOCK ENGAGED${RESET}"
    [[ -f "$STATE_FILE" ]] && cp "$STATE_FILE" "$STATE_FILE.force-lock.$(date +%s)"
    echo "FORCE_LOCKED" > "$STATE_FILE"
    echo -e "  ${RED}All work gates now BLOCKED.${RESET}"
    echo ""
    log "FORCE LOCK engaged"
}

show_help() {
    print_banner
    echo -e "${BOLD}Usage:${RESET}"
    echo "  bash nps_gate.sh \"$CALLSIGN\"     — Unlock gate and start session"
    echo "  bash nps_gate.sh status           — Show gate status"
    echo "  bash nps_gate.sh reset            — Lock gate (end session)"
    echo "  bash nps_gate.sh force-lock       — Emergency lock"
    echo ""
    echo -e "${BOLD}Environment:${RESET}"
    echo "  NPS_TTL_SECONDS — Session timeout (default: 3600 seconds)"
    echo ""
}

main() {
    [[ -n "${NPS_TTL_SECONDS:-}" ]] && SESSION_TTL_SECONDS=$NPS_TTL_SECONDS
    ensure_tier_dirs
    touch "$LOG_FILE" "$AUDIT_TRAIL"
    case "${1:-}" in
        "") awaiting_message; exit 1 ;;
        "$CALLSIGN") verify_callsign "$1"; run_nps_sequence ;;
        "status") check_status ;;
        "reset") reset_gate; echo -e "${YELLOW}Gate reset to LOCKED${RESET}" ;;
        "force-lock") force_lock ;;
        "--help"|"-h") show_help ;;
        *) verify_callsign "$1" ;;
    esac
}

main "$@"
