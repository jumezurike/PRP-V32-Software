#!/usr/bin/env bash
# uchu-identity.sh — UCHU Agent Identity Constants
# Universal Codified Hypervisor Unit  v1.0.0
# Source this file in any UCHU enforcement script to get agent identity.
#
# Usage (in another script):
#   source "$(dirname "${BASH_SOURCE[0]}")/uchu-identity.sh"
#   echo "$UCHU_FULL_NAME v$UCHU_VERSION"

UCHU_NAME="UCHU"
UCHU_FULL_NAME="Universal Codified Hypervisor Unit"
UCHU_VERSION="1.0.0"
UCHU_AGENT_NAME="UCHUEnforcer-00"
UCHU_AGENT_NUMBER="000"
UCHU_AGENT_ROLE="AI Governance Enforcer — NPS Gate · CR Lifecycle · Security Compliance · Session Audit"
# Deterministic UWA — business-owner formula (UWAGenerator):
#   8DOB=20260101  EIN-last5=86239  Initials=L0A  ServerIP=34111179208  City=COLUUS  Addr=COLUUS
#   LokDon EIN: 83-2086239  |  Server IP: 34.111.179.208  |  Address: 711 Saluda Ave, Columbia SC
# Validated: LCN + 42 alphanumeric chars = 45 total. /^LCN[A-Z0-9]{42}$/ → PASS.
UCHU_UWA="LCN2026010186239L0A34111179208COLUUSCOLUUS000"
UCHU_MISSION="AI Development Governance Enforcement Agent — codified policy enforcement, runtime validation, compliance verification, and trusted audit evidence throughout the AI software development lifecycle."
UCHU_CALLSIGN_FILE="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/.uchu/config"

uchu_get_callsign() {
  if [[ -f "$UCHU_CALLSIGN_FILE" ]]; then
    grep -E "^CALLSIGN=" "$UCHU_CALLSIGN_FILE" 2>/dev/null | cut -d= -f2- | tr -d '[:space:]'
  fi
}

uchu_get_uwa() {
  # Returns the registered UWA if available; otherwise returns the hardcoded deterministic value.
  # With LokDon IDP: full ECSMID-secured identity in DB.
  # Without LokDon IDP: script-only mode — UCHU_UWA constant still uniquely identifies this agent.
  local cfg_uwa
  cfg_uwa="$(grep -E "^UCHU_UWA=" "$UCHU_CALLSIGN_FILE" 2>/dev/null | cut -d= -f2- | tr -d '[:space:]')"
  echo "${cfg_uwa:-$UCHU_UWA}"
}

uchu_banner() {
  local width=62
  printf '╔%s╗\n' "$(printf '═%.0s' $(seq 1 $width))"
  printf '║  %-*s  ║\n' "$((width-4))" "U C H U  —  Universal Codified Hypervisor Unit"
  printf '║  %-*s  ║\n' "$((width-4))" "Version $UCHU_VERSION  |  PRP v3.1 Structural Enforcement"
  printf '║  %-*s  ║\n' "$((width-4))" "UWA: $UCHU_UWA"
  printf '╚%s╝\n' "$(printf '═%.0s' $(seq 1 $width))"
}
