#!/usr/bin/env bash
# security_gate.sh — PRP v3.1 Pre-Deploy Security Gate
# PRP v3.1 §22.6 — LokDon Development Framework
# Protocol Owner: Josiah Umezurike
#
# Validates security scanner results and writes a dated sentinel file.
# The sentinel is checked by validate_session_close.sh at session close
# and by the pre-push git hook on every push.
#
# Usage:
#   bash scripts/security_gate.sh --accept <results.json>
#
# Results JSON format (produced by your scanner tooling):
#   {
#     "dep_critical": 0,
#     "dep_high": 0,
#     "sast_critical": 0,
#     "sast_high": 0,
#     "hounddog_critical": 0
#   }
#
# Exit: 0 = gate passed and sentinel written
#       1 = findings exceed threshold or JSON invalid
#
# Sentinel location: .local/.security_gate_passed
# Sentinel format:
#   GATE=PASSED
#   DATE=YYYY-MM-DD
#   TIMESTAMP=ISO-8601Z
#   DEP_CRITICAL=0
#   DEP_HIGH=0
#   SAST_CRITICAL=0
#   SAST_HIGH=0
#   HOUNDDOG_CRITICAL=0

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SENTINEL_FILE="$REPO_ROOT/.local/.security_gate_passed"
TODAY_HUMAN="$(date -u +%Y-%m-%d)"
TIMESTAMP_ISO="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

usage() {
  echo ""
  echo "Usage: bash scripts/security_gate.sh --accept <results.json>"
  echo ""
  echo "  --accept <results.json>   Validate scanner results and write sentinel"
  echo ""
  echo "Results JSON must contain:"
  echo "  dep_critical, dep_high, sast_critical, sast_high, hounddog_critical"
  echo ""
  echo "All values must be 0 for the gate to pass."
  echo ""
  exit 1
}

[[ $# -lt 2 ]] && usage
[[ "$1" != "--accept" ]] && usage

RESULTS_FILE="$2"

if [[ ! -f "$RESULTS_FILE" ]]; then
  echo -e "${RED}ERROR: results file not found: $RESULTS_FILE${RESET}" >&2
  exit 1
fi

# ── Parse JSON ────────────────────────────────────────────────────────────────
parse_json_field() {
  local field="$1"
  python3 -c "
import json, sys
try:
    d = json.load(open('$RESULTS_FILE'))
    v = d.get('$field', None)
    if v is None:
        print('MISSING')
    else:
        print(int(v))
except Exception as e:
    print('ERROR:' + str(e))
" 2>/dev/null
}

DEP_CRITICAL=$(parse_json_field "dep_critical")
DEP_HIGH=$(parse_json_field "dep_high")
SAST_CRITICAL=$(parse_json_field "sast_critical")
SAST_HIGH=$(parse_json_field "sast_high")
HOUNDDOG_CRITICAL=$(parse_json_field "hounddog_critical")

FAILED=0
FAIL_REASONS=()

for FIELD_NAME in DEP_CRITICAL DEP_HIGH SAST_CRITICAL SAST_HIGH HOUNDDOG_CRITICAL; do
  VAL="${!FIELD_NAME}"
  if [[ "$VAL" == "MISSING" ]]; then
    echo -e "${RED}ERROR: field '${FIELD_NAME,,}' missing from $RESULTS_FILE${RESET}" >&2
    FAILED=1
  elif [[ "$VAL" == ERROR:* ]]; then
    echo -e "${RED}ERROR: JSON parse failed — ${VAL}${RESET}" >&2
    FAILED=1
  elif [[ "$VAL" -gt 0 ]]; then
    FAIL_REASONS+=("$FIELD_NAME=$VAL (must be 0)")
    FAILED=1
  fi
done

if [[ $FAILED -ne 0 ]]; then
  echo "" >&2
  echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}" >&2
  echo -e "${RED}${BOLD}║  SECURITY GATE — FAILED                                  ║${RESET}" >&2
  echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}" >&2
  echo "" >&2
  for reason in "${FAIL_REASONS[@]}"; do
    echo -e "  ${RED}✗  $reason${RESET}" >&2
  done
  echo "" >&2
  echo -e "  ${YELLOW}All critical and high findings must be zero before deploying.${RESET}" >&2
  echo -e "  ${YELLOW}Resolve findings and re-run scanners before calling --accept.${RESET}" >&2
  echo "" >&2
  exit 1
fi

# ── Write sentinel ────────────────────────────────────────────────────────────
mkdir -p "$(dirname "$SENTINEL_FILE")"
cat > "$SENTINEL_FILE" << EOF
GATE=PASSED
DATE=$TODAY_HUMAN
TIMESTAMP=$TIMESTAMP_ISO
DEP_CRITICAL=$DEP_CRITICAL
DEP_HIGH=$DEP_HIGH
SAST_CRITICAL=$SAST_CRITICAL
SAST_HIGH=$SAST_HIGH
HOUNDDOG_CRITICAL=$HOUNDDOG_CRITICAL
EOF

echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║  SECURITY GATE — PASSED                                  ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${GREEN}✓  dep_critical:      $DEP_CRITICAL${RESET}"
echo -e "  ${GREEN}✓  dep_high:          $DEP_HIGH${RESET}"
echo -e "  ${GREEN}✓  sast_critical:     $SAST_CRITICAL${RESET}"
echo -e "  ${GREEN}✓  sast_high:         $SAST_HIGH${RESET}"
echo -e "  ${GREEN}✓  hounddog_critical: $HOUNDDOG_CRITICAL${RESET}"
echo ""
echo -e "  Sentinel written: .local/.security_gate_passed"
echo -e "  Dated: $TODAY_HUMAN ($TIMESTAMP_ISO)"
echo ""
