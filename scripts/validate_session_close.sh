#!/usr/bin/env bash
# validate_session_close.sh — PRP v3.1 Session-Close Gate
# PRP v3.1 §30.6 + §10 — LokDon Development Framework
# Protocol Owner: Josiah Umezurike
#
# Checks three required conditions before a session may be closed:
#
#   1. A session report dated today (UTC) exists in docs/session-reports/
#      1b. The report's NPS LABEL CHECK section is valid
#          — delegated to: bash scripts/validate_nps_labels.sh --report <file>
#   2. Project metadata file carries today's date (UTC)
#      Default file: replit.md  |  Override: PROJECT_METADATA_FILE=<path>
#      Default pattern: "Last Updated:.*<date>"  |  Override: PROJECT_DATE_PATTERN=<regex>
#   3. Security gate sentinel (.local/.security_gate_passed) exists,
#      is dated today, and has GATE=PASSED
#      — written by: bash scripts/security_gate.sh --accept <results.json>
#
# Usage:
#   bash scripts/validate_session_close.sh
#
# Environment overrides (emergency only — Protocol Owner must be notified):
#   SKIP_SESSION_CLOSE=1            bypass all checks
#   SKIP_SESSION_CLOSE_REPORT=1    bypass check 1 only
#   SKIP_SESSION_CLOSE_METADATA=1  bypass check 2 only
#
# Exit: 0 = gate clear  |  1 = one or more checks failed

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY="$(date -u +%Y%m%d)"
TODAY_HUMAN="$(date -u +%Y-%m-%d)"

SESSION_REPORTS_DIR="$REPO_ROOT/docs/session-reports"
METADATA_FILE="${PROJECT_METADATA_FILE:-$REPO_ROOT/replit.md}"
DATE_PATTERN="${PROJECT_DATE_PATTERN:-Last Updated:.*$TODAY_HUMAN}"
SENTINEL_FILE="$REPO_ROOT/.local/.security_gate_passed"

SKIP_ALL="${SKIP_SESSION_CLOSE:-0}"
SKIP_REPORT="${SKIP_SESSION_CLOSE_REPORT:-0}"
SKIP_METADATA="${SKIP_SESSION_CLOSE_METADATA:-0}"

FAILED=0

# ── Master bypass ─────────────────────────────────────────────────────────────
if [[ "$SKIP_ALL" == "1" ]]; then
  echo "" >&2
  echo "⚠⚠⚠  WARNING: SKIP_SESSION_CLOSE=1 — session-close gate BYPASSED  ⚠⚠⚠" >&2
  echo "      Emergency override active. Protocol Owner must be notified." >&2
  echo "      Complete docs/SESSION_CLOSE_PROTOCOL.md steps before next session." >&2
  echo "" >&2
  exit 0
fi

# ── CHECK 1: Session report dated today ───────────────────────────────────────
if [[ "$SKIP_REPORT" == "1" ]]; then
  echo "⚠  SKIP_SESSION_CLOSE_REPORT=1 — session report check bypassed." >&2
else
  REPORT_FOUND=0
  REPORT_FILE=""
  if [[ -d "$SESSION_REPORTS_DIR" ]]; then
    while IFS= read -r -d '' f; do
      BASENAME="$(basename "$f")"
      if [[ "$BASENAME" == *"$TODAY"*_PR.txt ]]; then
        REPORT_FOUND=1
        REPORT_FILE="$f"
        break
      fi
    done < <(find "$SESSION_REPORTS_DIR" -maxdepth 1 -type f -name "*_PR.txt" -print0 2>/dev/null)
  fi

  if [[ "$REPORT_FOUND" -eq 0 ]]; then
    echo "" >&2
    echo "⛔  SESSION-CLOSE GATE — FAILED (no session report for today)" >&2
    echo "" >&2
    echo "    No session report dated $TODAY_HUMAN found in:" >&2
    echo "      docs/session-reports/" >&2
    echo "" >&2
    echo "    Required filename:" >&2
    echo "      <INITIALS>_<ENV>_${TODAY}_<HHMM>_PR.txt" >&2
    echo "" >&2
    echo "    Complete session-close steps in order:" >&2
    echo "      Step 1 — Security gate (dep + SAST + HoundDog all zero)" >&2
    echo "      Step 2 — Write session report to docs/session-reports/" >&2
    echo "      Step 3 — Update project metadata 'Last Updated' line" >&2
    echo "      Step 4 — Close CR: bash scripts/approval_gate.sh --deploy" >&2
    echo "" >&2
    echo "    Emergency bypass (Protocol Owner must be notified):" >&2
    echo "      SKIP_SESSION_CLOSE=1 bash scripts/validate_session_close.sh" >&2
    echo "" >&2
    FAILED=1
  else
    echo "✓  Session report dated $TODAY_HUMAN: found."

    # ── CHECK 1b: NPS LABEL CHECK section ──────────────────────────────────────
    NPS_LABEL_SCRIPT="$REPO_ROOT/scripts/validate_nps_labels.sh"
    if [[ -f "$NPS_LABEL_SCRIPT" ]]; then
      if bash "$NPS_LABEL_SCRIPT" --report "$REPORT_FILE"; then
        echo "✓  NPS LABEL CHECK section: valid."
      else
        echo "" >&2
        echo "⛔  SESSION-CLOSE GATE — FAILED (NPS LABEL CHECK section invalid)" >&2
        echo "" >&2
        echo "    Required fields in NPS LABEL CHECK section:" >&2
        echo "      • Exit code: 0" >&2
        echo "      • Timestamp: <UTC ISO-8601 ending in Z>" >&2
        echo "      • Summary:   <paste output of validate_nps_labels.sh>" >&2
        echo "" >&2
        FAILED=1
      fi
    else
      echo "⚠  validate_nps_labels.sh not found — skipping NPS LABEL CHECK validation." >&2
    fi
  fi
fi

# ── CHECK 2: Project metadata file carries today's date ───────────────────────
if [[ "$SKIP_METADATA" == "1" ]]; then
  echo "⚠  SKIP_SESSION_CLOSE_METADATA=1 — metadata date check bypassed." >&2
else
  METADATA_DATE_OK=0
  if [[ -f "$METADATA_FILE" ]]; then
    if grep -qE "$DATE_PATTERN" "$METADATA_FILE" 2>/dev/null; then
      METADATA_DATE_OK=1
    fi
  fi

  if [[ "$METADATA_DATE_OK" -eq 0 ]]; then
    echo "" >&2
    echo "⛔  SESSION-CLOSE GATE — FAILED (project metadata not updated today)" >&2
    echo "" >&2
    echo "    File:    $METADATA_FILE" >&2
    echo "    Pattern: $DATE_PATTERN" >&2
    echo "" >&2
    echo "    Update the 'Last Updated' line in $METADATA_FILE to $TODAY_HUMAN." >&2
    echo "" >&2
    echo "    To use a different file or pattern:" >&2
    echo "      PROJECT_METADATA_FILE=<path> PROJECT_DATE_PATTERN=<regex> \\" >&2
    echo "        bash scripts/validate_session_close.sh" >&2
    echo "" >&2
    FAILED=1
  else
    echo "✓  Project metadata: Last Updated $TODAY_HUMAN — current."
  fi
fi

# ── CHECK 3: Security gate sentinel ───────────────────────────────────────────
GATE_OK=0
SENTINEL_TS=""
if [[ -f "$SENTINEL_FILE" ]]; then
  SENTINEL_DATE="$(grep -E '^DATE=' "$SENTINEL_FILE" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')"
  SENTINEL_STATUS="$(grep -E '^GATE=' "$SENTINEL_FILE" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')"
  SENTINEL_TS="$(grep -E '^TIMESTAMP=' "$SENTINEL_FILE" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')"
  if [[ "$SENTINEL_DATE" == "$TODAY_HUMAN" && "$SENTINEL_STATUS" == "PASSED" ]]; then
    GATE_OK=1
  fi
fi

if [[ "$GATE_OK" -eq 0 ]]; then
  echo "" >&2
  echo "⛔  SESSION-CLOSE GATE — FAILED (security gate not run today)" >&2
  echo "" >&2
  if [[ ! -f "$SENTINEL_FILE" ]]; then
    echo "    Sentinel not found: .local/.security_gate_passed" >&2
  else
    if [[ "$SENTINEL_DATE" != "$TODAY_HUMAN" ]]; then
      echo "    Sentinel is stale: dated $SENTINEL_DATE, today is $TODAY_HUMAN." >&2
    elif [[ "$SENTINEL_STATUS" != "PASSED" ]]; then
      echo "    Sentinel GATE status is '$SENTINEL_STATUS' (expected PASSED)." >&2
    fi
  fi
  echo "" >&2
  echo "    Run all three scanners (dep audit + SAST + secret scan)," >&2
  echo "    write results to .local/.security_scan_results.json, then:" >&2
  echo "      bash scripts/security_gate.sh --accept .local/.security_scan_results.json" >&2
  echo "" >&2
  echo "    Emergency bypass (Protocol Owner must be notified — all checks bypassed):" >&2
  echo "      SKIP_SESSION_CLOSE=1 bash scripts/validate_session_close.sh" >&2
  echo "" >&2
  FAILED=1
else
  echo "✓  Security gate: PASSED $SENTINEL_TS — sentinel current."
fi

# ── Result ────────────────────────────────────────────────────────────────────
if [[ "$FAILED" -eq 1 ]]; then
  echo "" >&2
  echo "    Session-close gate FAILED. Complete the checklist and re-run:" >&2
  echo "      bash scripts/validate_session_close.sh" >&2
  echo "" >&2
  exit 1
fi

echo ""
echo "✓  SESSION-CLOSE GATE — CLEAR"
echo "   Session report:   dated $TODAY_HUMAN — OK"
echo "   Project metadata: Last Updated $TODAY_HUMAN — OK"
echo "   Security gate:    PASSED $SENTINEL_TS — OK"
echo ""
exit 0
