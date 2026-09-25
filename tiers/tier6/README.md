# Tier 6 — BC/DR and Verified Recovery (read sixth — before any consequential action)
#
# List your business-continuity / disaster-recovery runbooks and verified
# recovery references here. The NPS gate reads these last, after Tier 5 live
# code, so the agent has recovery and rollback context before doing anything
# that could require it.
#
# Typical contents:
#   - Disaster-recovery runbook (roles, steps, escalation)
#   - Credential / token recovery procedures
#   - Recovery-hash or backup-verification cheat sheets
#   - Release-integrity / release-governance policy (if separate from Tier 1)
#   - Any compliance-evidence document that must stay current with recovery posture
#
# Example (rename to match your project):
#   T6-01  docs/DR-RUNBOOK.md
#   T6-02  docs/DR-CREDENTIAL-RECOVERY.md
#   T6-03  docs/RECOVERY-HASH-CHEATSHEET.md
