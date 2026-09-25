#!/usr/bin/env bash
# stage_for_approval.sh — PRP v3.1 Stage-for-Approval Gate
# PRP v3.1 §2 — LokDon Development Framework
# Protocol Owner: Josiah Umezurike
#
# Generates .local/approval.txt listing every staged file.
# The agent MUST run this, then STOP — no commit until the Protocol Owner
# has reviewed the list and typed "approved" or "proceed" in the chat.
#
# ── APPROVAL WORDS ────────────────────────────────────────────────────────────
# The ONLY words the Protocol Owner may use to authorize a change are:
#
#     "approved"   OR   "proceed"
#
# Any other word is NOT a valid authorization. Per PRP v3.1 §2.
# ─────────────────────────────────────────────────────────────────────────────
#
# Usage: bash scripts/stage_for_approval.sh

set -e

APPROVAL_FILE=".local/approval.txt"
DATE=$(date -u +"%Y-%m-%d %H:%M UTC")

STAGED=$(git diff --cached --name-only)
if [[ -z "$STAGED" ]]; then
  echo "ERROR: No staged files found. Run 'git add <files>' first." >&2
  exit 1
fi

STAGED_TREE=$(git write-tree)
STAGED_BRANCH=$(git branch --show-current)
SOURCE_MAIN=$(git rev-parse origin/main 2>/dev/null || git rev-parse main)

mkdir -p .local
{
  echo "STATUS: AWAITING_APPROVAL"
  echo "Date: $DATE"
  echo "BRANCH: $STAGED_BRANCH"
  echo "SOURCE-MAIN: $SOURCE_MAIN"
  echo "STAGED-TREE: $STAGED_TREE"
  echo ""
  echo "Files staged for commit (Protocol Owner must review each one):"
  echo "$STAGED" | while IFS= read -r f; do
    echo "  $f"
  done
  echo ""
  echo "───────────────────────────────────────────────────────────────"
  echo "PROTOCOL OWNER INSTRUCTIONS"
  echo "───────────────────────────────────────────────────────────────"
  echo ""
  echo "  1. Review every file listed above."
  echo "  2. Change 'STATUS: AWAITING_APPROVAL' to 'STATUS: APPROVED'."
  echo "  3. Add your UWA on the line below."
  echo "  4. Type exactly one of these two words in the chat:"
  echo ""
  echo "         approved"
  echo "         proceed"
  echo ""
  echo "  NO OTHER WORD IS VALID. (PRP v3.1 §2)"
  echo "  'yes', 'ok', 'sure', 'go ahead' are NOT authorizations."
  echo ""
  echo "UWA: "
} > "$APPROVAL_FILE"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✋  HUMAN APPROVAL REQUIRED — PRP v3.1 §2 Gate          ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Approval file written to: .local/approval.txt           ║"
echo "║                                                          ║"
echo "║  Agent is STOPPED. Protocol Owner must:                  ║"
echo "║    1. Open .local/approval.txt                           ║"
echo "║    2. Review ALL staged files                            ║"
echo "║    3. Change STATUS to APPROVED                          ║"
echo "║    4. Sign with UWA                                      ║"
echo "║    5. Type 'approved' or 'proceed' in the chat           ║"
echo "║                                                          ║"
echo "║  ⚠  ONLY 'approved' or 'proceed' counts. (PRP v3.1 §2)  ║"
echo "║     'yes', 'ok', 'sure' are NOT valid approvals.         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "--- Contents of .local/approval.txt ---"
cat "$APPROVAL_FILE"
