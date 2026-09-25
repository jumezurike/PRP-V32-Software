#!/usr/bin/env bash
# approval_gate.sh — UCHU Change Approval Gate
# Universal Codified Hypervisor Unit  v1.0.0
# PRP v3.1 §2 + §4 — Protocol Owner: Josiah Umezurike
#
# Enforces the Protocol Owner approval gate for every change.
# No file may be edited, no commit made, without passing through this gate.
#
# ── UCHU APPROVAL RULE ────────────────────────────────────────────────────────
# The ONLY words the Protocol Owner may use to authorize a change are:
#
#     "approved"   OR   "proceed"
#
# Any other word ("yes", "ok", "sure", "go ahead", "continue", etc.)
# is NOT a valid authorization. The agent must stop and ask again.
# This is not a convention — it is a structural requirement of PRP v3.1 §2.
# ─────────────────────────────────────────────────────────────────────────────
#
# Usage:
#   bash scripts/approval_gate.sh --request "description of proposed change"
#   bash scripts/approval_gate.sh --grant   "description of approved change"
#   bash scripts/approval_gate.sh --deploy  "files changed" "rollback plan"
#   bash scripts/approval_gate.sh --status
#   bash scripts/approval_gate.sh --log
#   bash scripts/approval_gate.sh --clear
#
# CR Lifecycle:
#   1. Agent proposes change    → runs --request (logs request, STOPS)
#   2. Protocol Owner types "approved" or "proceed" in chat
#   3. Agent runs --grant       (writes single-use sentinel, logs grant)
#   4. Agent makes file edits + commits
#   5. Agent runs --deploy      (closes CR, writes deployment record)
#   6. Agent declares: "I am ready for deployment."
#   7. Human declares: "I am ready to publish." → clicks Deploy

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SENTINEL="$REPO_ROOT/scripts/.approval_granted"
CR_ID_FILE="$REPO_ROOT/scripts/.approval_cr_id"
LOG_FILE="$REPO_ROOT/scripts/.approval_log"
DEPLOY_LOG="$REPO_ROOT/docs/deployment-record.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

usage() {
  echo ""
  echo "UCHU — Change Approval Gate"
  echo "Usage: bash scripts/approval_gate.sh [OPTION]"
  echo ""
  echo "  --request <desc>           Log a change request and print AWAITING banner"
  echo "  --grant   <desc>           Write approval sentinel (run after owner approves)"
  echo "  --deploy  <files> <plan>   Close the CR and write deployment record"
  echo "  --status                   Show whether a valid approval sentinel exists"
  echo "  --log                      Print the full approval audit log"
  echo "  --clear                    Remove the sentinel manually (emergency reset)"
  echo ""
  echo "UCHU APPROVAL RULE:"
  echo "  Protocol Owner must type exactly: 'approved'  OR  'proceed'"
  echo "  No other word is valid. Per PRP v3.1 §2."
  echo ""
  exit 1
}

[[ $# -lt 1 ]] && usage

case "$1" in

  --request)
    DESC="${2:-unspecified change}"
    echo "[$TIMESTAMP] REQUEST: $DESC" >> "$LOG_FILE"
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  UCHU — APPROVAL GATE                                       ║"
    echo "║  Change Request Logged                                      ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    printf  "║  %-60s  ║\n" "$DESC"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                              ║"
    echo "║  Agent is STOPPED. Awaiting Protocol Owner approval.        ║"
    echo "║                                                              ║"
    echo "║  ┌──────────────────────────────────────────────────────┐   ║"
    echo "║  │  PROTOCOL OWNER — to authorize this change:          │   ║"
    echo "║  │                                                      │   ║"
    echo "║  │  Type exactly ONE of these two words in chat:        │   ║"
    echo "║  │                                                      │   ║"
    echo "║  │      approved                                        │   ║"
    echo "║  │      proceed                                         │   ║"
    echo "║  │                                                      │   ║"
    echo "║  │  NO OTHER WORD IS VALID. (PRP v3.1 §2)               │   ║"
    echo "║  │  'yes', 'ok', 'sure', 'go ahead' = NOT authorized.   │   ║"
    echo "║  └──────────────────────────────────────────────────────┘   ║"
    echo "║                                                              ║"
    echo "║  After owner approves:                                      ║"
    echo "║    bash scripts/approval_gate.sh --grant 'description'      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    ;;

  --grant)
    DESC="${2:-unspecified change}"
    echo "$TIMESTAMP:$DESC" > "$SENTINEL"
    echo "[$TIMESTAMP] GRANTED: $DESC" >> "$LOG_FILE"
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  UCHU — APPROVAL GATE                                       ║"
    echo "║  Change Approved ✓                                          ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    printf  "║  %-60s  ║\n" "$DESC"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  Sentinel written. One commit permitted.                    ║"
    echo "║  Sentinel clears automatically after commit.                ║"
    echo "║                                                              ║"
    echo "║  After edits + commit, close the CR:                        ║"
    echo "║    bash scripts/approval_gate.sh --deploy                   ║"
    echo "║      \"<files affected>\" \"<rollback plan>\"                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    ;;

  --deploy)
    FILES="${2:-unspecified files}"
    ROLLBACK="${3:-no rollback plan provided}"
    echo "[$TIMESTAMP] DEPLOYED: $FILES | rollback: $ROLLBACK" >> "$LOG_FILE"
    mkdir -p "$(dirname "$DEPLOY_LOG")"
    cat >> "$DEPLOY_LOG" << ENTRY

────────────────────────────────────────────────────────────
DEPLOYED: $TIMESTAMP
FILES:    $FILES
ROLLBACK: $ROLLBACK
ENTRY
    rm -f "$SENTINEL" "$CR_ID_FILE"
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  UCHU — APPROVAL GATE                                       ║"
    echo "║  CR Closed — Deployment Record Written                      ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    printf  "║  Files:    %-48s  ║\n" "$FILES"
    printf  "║  Rollback: %-48s  ║\n" "$ROLLBACK"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                              ║"
    echo "║  DEPLOY HANDOFF — two-phrase protocol (no exceptions):      ║"
    echo "║                                                              ║"
    echo "║    Agent  → \"I am ready for deployment.\"                   ║"
    echo "║    Human  → \"I am ready to publish.\" → clicks Deploy        ║"
    echo "║                                                              ║"
    echo "║  Human owns the deployment decision. Always.                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    ;;

  --status)
    echo ""
    if [[ -f "$SENTINEL" ]]; then
      CONTENT=$(cat "$SENTINEL")
      echo "╔══════════════════════════════════════════════════════════════╗"
      echo "║  UCHU — APPROVAL GATE ACTIVE (commit permitted)             ║"
      echo "╠══════════════════════════════════════════════════════════════╣"
      printf  "║  %-60s  ║\n" "$CONTENT"
      echo "╚══════════════════════════════════════════════════════════════╝"
    else
      echo "╔══════════════════════════════════════════════════════════════╗"
      echo "║  UCHU — APPROVAL GATE LOCKED (no approval on record)        ║"
      echo "╠══════════════════════════════════════════════════════════════╣"
      echo "║  Run --request, get Protocol Owner to type:                 ║"
      echo "║    'approved'  or  'proceed'                                ║"
      echo "║  Then run --grant before committing.                        ║"
      echo "╚══════════════════════════════════════════════════════════════╝"
    fi
    echo ""
    ;;

  --log)
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo " UCHU — APPROVAL GATE AUDIT LOG"
    echo "═══════════════════════════════════════════════════════════"
    if [[ -f "$LOG_FILE" ]]; then
      cat "$LOG_FILE"
    else
      echo " (no entries yet)"
    fi
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    ;;

  --clear)
    rm -f "$SENTINEL"
    echo "[$TIMESTAMP] CLEARED: sentinel removed manually" >> "$LOG_FILE"
    echo "UCHU: Approval sentinel cleared."
    ;;

  *)
    usage
    ;;

esac
