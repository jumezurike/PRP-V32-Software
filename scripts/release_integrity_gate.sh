#!/usr/bin/env bash
# PRP v3.2 release-integrity gate. This gate intentionally fails closed.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
REMOTE="${1:-origin}"
CANONICAL_HTTPS="https://github.com/jumezurike/B2B-Lokdon.git"
CANONICAL_SSH="git@github.com:jumezurike/B2B-Lokdon.git"
REMOTE_URL="$(git remote get-url "$REMOTE" 2>/dev/null || true)"

is_b2b=false
case "$REMOTE_URL" in
  "$CANONICAL_HTTPS"|"$CANONICAL_SSH") is_b2b=true ;;
esac

# Only govern the canonical B2B remote; all other remotes retain existing gates.
if [[ "$is_b2b" != true ]]; then
  exit 0
fi

if [[ "$REMOTE" != "origin" ]]; then
  echo "⛔ RELEASE INTEGRITY BLOCKED — B2B releases must use origin." >&2
  exit 1
fi
if [[ "${HUMAN_PUSH:-0}" != "1" ]]; then
  echo "⛔ RELEASE INTEGRITY BLOCKED — canonical B2B releases require HUMAN_PUSH=1." >&2
  exit 1
fi
if [[ "${SKIP_SESSION_CLOSE:-0}" == "1" || "${SKIP_SESSION_CLOSE_REPORT:-0}" == "1" || "${SKIP_SESSION_CLOSE_METADATA:-0}" == "1" || "${SKIP_SESSION_CLOSE_REPLIT:-0}" == "1" ]]; then
  echo "⛔ RELEASE INTEGRITY BLOCKED — session-close skips invalidate a B2B release." >&2
  exit 1
fi
if [[ -z "${RELEASE_PUSH_AUTHORIZATION:-}" || ! "${RELEASE_PUSH_AUTHORIZATION}" =~ ^[A-Fa-f0-9]{64}$ ]]; then
  echo "⛔ RELEASE INTEGRITY BLOCKED — RELEASE_PUSH_AUTHORIZATION is required." >&2
  exit 1
fi
if [[ -z "${DATABASE_URL:-}" ]] || ! command -v psql >/dev/null || ! command -v sha256sum >/dev/null; then
  echo "⛔ RELEASE INTEGRITY BLOCKED — candidate verification requires DATABASE_URL, psql, and sha256sum." >&2
  exit 1
fi

head_sha="$(git rev-parse HEAD)"
auth_hash="$(printf %s "$RELEASE_PUSH_AUTHORIZATION" | sha256sum | awk '{print $1}')"
main_target=false
force=false
while read -r local_ref local_sha remote_ref remote_sha; do
  [[ "$remote_ref" == "refs/heads/main" ]] || continue
  main_target=true
  # A non-fast-forward update is a force-style main update and is prohibited.
  if [[ "$remote_sha" != "0000000000000000000000000000000000000000" ]] &&
     ! git merge-base --is-ancestor "$remote_sha" "$local_sha"; then
    force=true
  fi
done
if [[ "$main_target" != true || "$force" == true ]]; then
  echo "⛔ RELEASE INTEGRITY BLOCKED — canonical B2B pushes must be non-force pushes to main." >&2
  exit 1
fi

candidate_count="$(psql "$DATABASE_URL" -t -A -v ON_ERROR_STOP=1 -c \
  "SELECT count(*) FROM release_candidates WHERE release_head_commit = '$head_sha' AND state = 'READY_FOR_HUMAN_RELEASE' AND authorization_nonce_hash = '$auth_hash' AND authorization_used_at IS NULL AND authorization_expires_at > NOW();" 2>/dev/null || true)"
if [[ "$candidate_count" != "1" ]]; then
  echo "⛔ RELEASE INTEGRITY BLOCKED — HEAD has no valid, unconsumed Dashboard release candidate." >&2
  exit 1
fi
echo "✓ PRP v3.2 release integrity candidate verified." >&2