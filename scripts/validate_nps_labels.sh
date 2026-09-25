#!/usr/bin/env bash
# validate_nps_labels.sh
# PRP v3.1 §30 — LokDon Development Framework
# Protocol Owner: Josiah Umezurike
#
# Validates that every Tier in docs/NPS-PROTOCOL.md has a gapless,
# non-duplicate, sequentially-numbered label column (T1-01, T1-02, …).
# Also validates that session reports contain the required NPS LABEL CHECK
# section with the correct fields.
#
# Usage:
#   bash scripts/validate_nps_labels.sh [path-to-NPS-PROTOCOL.md]
#       Validates tier label sequences (default: docs/NPS-PROTOCOL.md).
#
#   bash scripts/validate_nps_labels.sh --report <path-to-session-report>
#       Checks that the session report contains a valid "NPS LABEL CHECK" section.
#
# Exit: 0 = all clear  |  1 = one or more problems found

# ── Known placeholder timestamps ──────────────────────────────────────────────
# Update this array when adding new placeholder values.
PLACEHOLDER_VALUES=(
  "2026-01-01T00:00:00Z"
  "2026-06-30T00:00:00Z"
  "YYYY-MM-DDTHH:MM:SSZ"
)

# ── --report mode ─────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--report" ]]; then
  REPORT_FILE="${2:-}"
  if [[ -z "$REPORT_FILE" ]]; then
    echo "ERROR: --report requires a file path argument." >&2
    echo "Usage: bash scripts/validate_nps_labels.sh --report <path-to-session-report>" >&2
    exit 1
  fi
  if [[ ! -f "$REPORT_FILE" ]]; then
    echo "ERROR: session report not found: $REPORT_FILE" >&2
    exit 1
  fi

  REPORT_ERRORS=0

  # ── 1. Section header present ────────────────────────────────────────────────
  if ! grep -q "NPS LABEL CHECK" "$REPORT_FILE"; then
    echo "ERROR: session report is missing the mandatory 'NPS LABEL CHECK' section." >&2
    echo "  File: $REPORT_FILE" >&2
    echo "  Add the 'NPS LABEL CHECK' section before committing this report." >&2
    exit 1
  fi

  # ── Extract NPS LABEL CHECK section block ────────────────────────────────────
  NPS_SECTION=$(awk '
    /NPS LABEL CHECK/ { in_section = 1; print; next }
    in_section && /^[A-Z][A-Z0-9 \/:_-]+$/ { exit }
    in_section { print }
  ' "$REPORT_FILE")

  # ── 2a. Reject explicit non-zero exit code ────────────────────────────────────
  NONZERO_LINE=$(echo "$NPS_SECTION" | grep -iE \
    "(exit[[:space:]]+code[[:space:]]*:[[:space:]]*[1-9][0-9]*([^0-9]|$)|exit[[:space:]]+[1-9][0-9]*([^0-9]|$))" \
    | head -1 | tr -d '\r')
  if [[ -n "$NONZERO_LINE" ]]; then
    echo "ERROR: NPS LABEL CHECK section records a failed NPS gate." >&2
    echo "  File: $REPORT_FILE" >&2
    printf "  Found: %s\n" "$NONZERO_LINE" >&2
    echo "  Re-run 'bash scripts/nps_gate.sh --accept' and update the report." >&2
    REPORT_ERRORS=$(( REPORT_ERRORS + 1 ))
  fi

  # ── 2b. Exit code 0 must be present ──────────────────────────────────────────
  if ! echo "$NPS_SECTION" | grep -qiE \
    "(exit[[:space:]]+code[[:space:]]*:[[:space:]]*0([^0-9]|$)|exit[[:space:]]+0([^0-9]|$))"; then
    echo "ERROR: NPS LABEL CHECK section is missing 'Exit code: 0'." >&2
    echo "  File: $REPORT_FILE" >&2
    echo "  Required: 'Exit code: 0' — a non-zero or absent line means the NPS gate failed." >&2
    REPORT_ERRORS=$(( REPORT_ERRORS + 1 ))
  fi

  # ── 3. UTC timestamp (ISO-8601 with Z suffix) ─────────────────────────────────
  if ! echo "$NPS_SECTION" | grep -qE \
    "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?Z"; then
    echo "ERROR: NPS LABEL CHECK section is missing a UTC timestamp." >&2
    echo "  File: $REPORT_FILE" >&2
    echo "  Required: ISO-8601 UTC timestamp ending in Z, e.g. '2026-06-30T14:32:00Z'" >&2
    REPORT_ERRORS=$(( REPORT_ERRORS + 1 ))
  fi

  # ── 3b. Reject known placeholder timestamps ──────────────────────────────────
  for _ph in "${PLACEHOLDER_VALUES[@]}"; do
    if echo "$NPS_SECTION" | grep -qF "$_ph"; then
      echo "ERROR: NPS LABEL CHECK section contains a placeholder timestamp ('$_ph')." >&2
      echo "  File: $REPORT_FILE" >&2
      echo "  Replace '$_ph' with the actual UTC timestamp from your terminal." >&2
      REPORT_ERRORS=$(( REPORT_ERRORS + 1 ))
    fi
  done

  # ── 4. Summary line (OK: or ERROR:) ──────────────────────────────────────────
  if echo "$NPS_SECTION" | grep -qE "^[[:space:]]*Summary:[[:space:]]*$"; then
    echo "ERROR: NPS LABEL CHECK section has a blank Summary value." >&2
    echo "  File: $REPORT_FILE" >&2
    echo "  Paste the actual output line from validate_nps_labels.sh." >&2
    REPORT_ERRORS=$(( REPORT_ERRORS + 1 ))
  elif ! echo "$NPS_SECTION" | grep -qE "(OK|ERROR):"; then
    echo "ERROR: NPS LABEL CHECK section is missing a summary line (OK: or ERROR:)." >&2
    echo "  File: $REPORT_FILE" >&2
    echo "  Required: paste the output line from validate_nps_labels.sh, e.g.:" >&2
    echo "  'Summary: OK: all NPS tier labels in docs/NPS-PROTOCOL.md are gapless and non-duplicate.'" >&2
    REPORT_ERRORS=$(( REPORT_ERRORS + 1 ))
  fi

  # ── 5. Cross-validate exit code against summary polarity ──────────────────────
  RECORDED_EXIT=""
  if echo "$NPS_SECTION" | grep -qiE \
    "(exit[[:space:]]+(code[[:space:]]*:)[[:space:]]*0([^0-9]|$)|exit[[:space:]]+0([^0-9]|$))"; then
    RECORDED_EXIT="0"
  elif echo "$NPS_SECTION" | grep -qiE \
    "(exit[[:space:]]+(code[[:space:]]*:)[[:space:]]*[1-9][0-9]*|exit[[:space:]]+[1-9][0-9]*)"; then
    RECORDED_EXIT="nonzero"
  fi

  _summary_lines=$(echo "$NPS_SECTION" | grep -viE \
    "(exit[[:space:]]+(code[[:space:]]*:)|[[:space:]]*exit[[:space:]]+[0-9])")
  SUMMARY_POLARITY=""
  if echo "$_summary_lines" | grep -qE "\bOK:"; then
    SUMMARY_POLARITY="OK"
  elif echo "$_summary_lines" | grep -qE "\bERROR:"; then
    SUMMARY_POLARITY="ERROR"
  fi

  if [[ "$RECORDED_EXIT" == "0" && "$SUMMARY_POLARITY" == "ERROR" ]]; then
    echo "ERROR: NPS LABEL CHECK is contradictory: exit 0 but summary says ERROR:." >&2
    REPORT_ERRORS=$(( REPORT_ERRORS + 1 ))
  elif [[ "$RECORDED_EXIT" == "nonzero" && "$SUMMARY_POLARITY" == "OK" ]]; then
    echo "ERROR: NPS LABEL CHECK is contradictory: non-zero exit but summary says OK:." >&2
    REPORT_ERRORS=$(( REPORT_ERRORS + 1 ))
  fi

  if [[ $REPORT_ERRORS -eq 0 ]]; then
    echo "OK: 'NPS LABEL CHECK' section found with exit code, UTC timestamp, and summary in $REPORT_FILE"
    exit 0
  else
    echo "" >&2
    echo "FAIL: $REPORT_ERRORS missing required field(s) in NPS LABEL CHECK section." >&2
    exit 1
  fi
fi

# ── Label-sequence mode (default) ─────────────────────────────────────────────
NPS_FILE="${1:-docs/NPS-PROTOCOL.md}"
ERRORS=0

if [[ ! -f "$NPS_FILE" ]]; then
  echo "ERROR: $NPS_FILE not found." >&2
  exit 1
fi

mapfile -t TIERS < <(
  grep -Eo 'T[1-9][0-9]*-[0-9]+' "$NPS_FILE" \
    | grep -Eo 'T[1-9][0-9]*' \
    | sort -uV
)

for TIER in "${TIERS[@]}"; do
  mapfile -t TIER_LABELS < <(grep -Eo "${TIER}-[0-9]+" "$NPS_FILE")
  [[ ${#TIER_LABELS[@]} -eq 0 ]] && continue

  DUPES=$(printf '%s\n' "${TIER_LABELS[@]}" | sort | uniq -d)
  if [[ -n "$DUPES" ]]; then
    echo "ERROR [$TIER]: duplicate label(s) found:" >&2
    while IFS= read -r d; do echo "  - $d" >&2; done <<< "$DUPES"
    ERRORS=$(( ERRORS + 1 ))
  fi

  mapfile -t UNIQUE_LABELS < <(printf '%s\n' "${TIER_LABELS[@]}" | awk '!seen[$0]++')
  EXPECTED=1
  for LABEL in "${UNIQUE_LABELS[@]}"; do
    NUM="${LABEL##*-}"
    NUM=$(( 10#$NUM ))
    if [[ $NUM -ne $EXPECTED ]]; then
      EXPECTED_LABEL="${TIER}-$(printf '%02d' "$EXPECTED")"
      echo "ERROR [$TIER]: expected $EXPECTED_LABEL but found $LABEL (gap or out-of-order)" >&2
      ERRORS=$(( ERRORS + 1 ))
      EXPECTED=$(( NUM + 1 ))
    else
      EXPECTED=$(( EXPECTED + 1 ))
    fi
  done
done

if [[ $ERRORS -eq 0 ]]; then
  echo "OK: all NPS tier labels in $NPS_FILE are gapless and non-duplicate."
  echo ""
  echo "  Session close checklist (run in order before deploy):"
  echo "    1. Security gate  — bash scripts/security_gate.sh --accept <results.json>"
  echo "    2. Session report — write docs/session-reports/<INITIALS>_<ENV>_YYYYMMDD_HHMM_PR.txt"
  echo "       NPS LABEL CHECK section must include:"
  echo "         Exit code: 0"
  echo "         Timestamp: <UTC ISO-8601 ending in Z>"
  echo "         Summary:   <paste the OK: line printed above>"
  echo "    3. Docs update    — update your project metadata 'Last Updated' line"
  echo "    4. Close CR       — bash scripts/approval_gate.sh --deploy \"<files>\" \"<rollback>\""
  echo ""
  echo "  Deploy handoff (two-phrase protocol — no exceptions):"
  echo "    Agent  -> \"I am ready for deployment.\""
  echo "    Human  -> \"I am ready to deploy.\" -> on Replit: clicks Publish button"
  echo "                                          -> on other platforms: equivalent deploy action"
  echo "    Note: \"I am ready to publish.\" is the prior equivalent phrase (historical records)."
  echo ""
  exit 0
else
  echo "" >&2
  echo "FAIL: $ERRORS problem(s) in $NPS_FILE — fix labels before closing the session." >&2
  exit 1
fi
