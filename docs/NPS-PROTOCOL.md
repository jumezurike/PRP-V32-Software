================================================================================
NPS-PROTOCOL — Non-Markovian Property Startup
LokDon AISM · PRP v3.1 §30 — Codified 2026-04-26
================================================================================

Document ID   : NPS-PROTOCOL
Version       : 1.0
Date Adopted  : 2026-04-26
Authority     : Josiah Umezurike, Protocol Owner, LokDon / CyberLockX
PRP Reference : Section 30 (added 2026-04-26 per §27.2 Change Proposal)
Status        : MANDATORY — No exceptions permitted

--------------------------------------------------------------------------------

## WHY THIS PROTOCOL EXISTS

An AI agent has no persistent memory between sessions. Every session starts blank.
Without a structural enforcement mechanism, the agent operates on incomplete
context — unaware of prior violations, open items, active invariants, accepted
security risks, and architectural decisions made in previous sessions.

Honor-based startup (relying on the agent to "choose" to read docs) has been
proven insufficient. Violation 3 (2026-04-17) occurred because the agent began
work without reading session history.

The Non-Markovian Property Startup (NPS) codifies the solution: the agent is
structurally locked until a specific callsign is received, at which point it
must read every specified document and code file before declaring ready.

The system carries its own history forward. The agent cannot begin work in
ignorance of that history.

--------------------------------------------------------------------------------

## THE CALLSIGN — EXACT TEXT (NON-NEGOTIABLE)

    Non-Markovian Property Startup

This is the only valid callsign. Case-sensitive. Three words. Exactly as shown.

The following are NOT valid callsigns and must NOT trigger NPS:
  - "NPS"
  - "start NPS"
  - "non-markovian startup"
  - "begin"
  - "proceed"
  - Any abbreviation or variation

Before the callsign is received, the agent's only permitted response is:

    "Awaiting Non-Markovian Property Startup callsign."

No analysis. No code. No suggestions. No review. No exceptions.

--------------------------------------------------------------------------------

## NPS EXECUTION SEQUENCE (MANDATORY ORDER)

On receiving "Non-Markovian Property Startup":

  STEP 1 — Read all Tier 1 files (Governance) in listed order
  STEP 2 — Read all Tier 2 files (Technical Reference) in listed order
  STEP 3 — Read all Tier 3 files (Session History) newest → oldest
  STEP 4 — Read all Tier 4 files (Security Baseline) in listed order
  STEP 5 — Read all Tier 5 files (Live Code) in listed order
  STEP 6 — Write NPS audit file: docs/nps-audits/NPS_AUDIT_YYYYMMDD_HHMM.md
  STEP 7 — Run: bash scripts/nps-gate.sh --accept
           (writes scripts/.nps_sentinel — required for git commits to pass)
  STEP 8 — Declare: "NPS COMPLETE — [date] [time] — ready for work"

The agent may not declare NPS COMPLETE until Steps 1–7 are fully done.
The audit file must be written and the gate script run before the declaration.
Steps 6 and 7 are not optional. Step 8 is the gate that authorises all work.

--------------------------------------------------------------------------------

## TIER 1 — GOVERNANCE (read first, no exceptions)

  T1-01  replit.md
  T1-02  docs/PRP-v3.1-Consolidated.md
  T1-03  docs/SESSION_CLOSE_PROTOCOL.md
  T1-04  docs/NPS-PROTOCOL.md  (this file)

--------------------------------------------------------------------------------

## TIER 2 — TECHNICAL REFERENCE

  T2-01  docs/GPA-001-7WAY-HANDSHAKE-20260331.md
  T2-02  docs/SIEVVE-Protocol-Reference.md
  T2-03  docs/TECHNICAL_REFERENCE.md
  T2-04  docs/API_REFERENCE.md
  T2-05  docs/DEVELOPER_GUIDE.md
  T2-06  docs/LOKDON-AISM-PRODUCTION-IMPLEMENTATION-GUIDE.md
  T2-07  docs/WHITE_PAPER.md

--------------------------------------------------------------------------------

## TIER 3 — SESSION HISTORY (newest → oldest)

  T3-01  docs/session-reports/JU_DEV_20260722_1135_PR.txt
  T3-02  docs/session-reports/JU_DEV_20260719_0200_PR.txt
  T3-03  docs/session-reports/JU_DEV_20260719_0139_PR.txt
  T3-04  docs/session-reports/JU_DEV_20260719_0045_PR.txt
  T3-05  docs/session-reports/JU_DEV_20260718_1750_PR.txt
  T3-06  docs/session-reports/JU_DEV_20260718_1740_PR.txt
  T3-07  docs/session-reports/JU_DEV_20260718_1735_PR.txt
  T3-08  docs/session-reports/JU_DEV_20260718_1638_PR.txt
  T3-09  docs/session-reports/JU_DEV_20260718_1435_PR.txt
  T3-10  docs/session-reports/JU_DEV_20260717_0410_PR.txt
  T3-11  docs/session-reports/JU_DEV_20260717_0305_PR.txt
  T3-12  docs/session-reports/JU_DEV_20260709_0050_PR.txt
  T3-13  docs/session-reports/JU_DEV_20260709_0015_PR.txt
  T3-14  docs/session-reports/JU_DEV_20260708_2359_PR.txt
  T3-15  docs/session-reports/JU_DEV_20260708_2345_PR.txt
  T3-16  docs/session-reports/JU_DEV_20260708_2315_PR.txt
  T3-17  docs/session-reports/JU_DEV_20260708_1917_PR.txt
  T3-18  docs/session-reports/JU_DEV_20260707_1435_PR.txt
  T3-19  docs/session-reports/JU_DEV_20260705_1848_PR.txt
  T3-20  docs/session-reports/JU_DEV_20260701_1118_PR.txt
  T3-21  docs/session-reports/JU_DEV_20260624_0130_PR.txt
  T3-22  docs/session-reports/JU_DEV_20260624_0000_PR.txt
  T3-23  docs/session-reports/JU_DEV_20260623_2359_PR.txt
  T3-24  docs/session-reports/JU_DEV_20260623_2330_PR.txt
  T3-25  docs/session-reports/JU_DEV_20260623_2300_PR.txt
  T3-26  docs/session-reports/JU_DEV_20260623_2200_PR.txt
  T3-27  docs/session-reports/JU_DEV_20260623_2130_PR.txt
  T3-28  docs/session-reports/JU_DEV_20260623_2030_PR.txt
  T3-29  docs/session-reports/JU_DEV_20260623_1930_PR.txt
  T3-30  docs/session-reports/JU_DEV_20260623_1800_PR.txt
  T3-31  docs/session-reports/JU_DEV_20260623_1330_PR.txt
  T3-32  docs/session-reports/JU_DEV_20260623_1230_PR.txt
  T3-33  docs/session-reports/JU_DEV_20260623_1100_PR.txt
  T3-34  docs/session-reports/JU_DEV_20260622_2300_PR.txt
  T3-35  docs/session-reports/JU_DEV_20260622_2230_PR.txt
  T3-36  docs/session-reports/JU_DEV_20260622_2200_PR.txt
  T3-37  docs/session-reports/JU_DEV_20260622_2130_PR.txt
  T3-38  docs/session-reports/JU_DEV_20260622_2100_PR.txt
  T3-39  docs/session-reports/JU_DEV_20260622_2030_PR.txt
  T3-40  docs/session-reports/JU_DEV_20260622_2000_PR.txt
  T3-41  docs/session-reports/JU_DEV_20260622_1930_PR.txt
  T3-42  docs/session-reports/JU_DEV_20260622_1600_PR.txt
  T3-43  docs/session-reports/JU_DEV_20260622_1530_PR.txt
  T3-44  docs/session-reports/JU_DEV_20260622_1510_PR.txt
  T3-45  docs/session-reports/JU_DEV_20260622_1430_PR.txt
  T3-46  docs/session-reports/JU_DEV_20260622_1400_PR.txt
  T3-47  docs/session-reports/JU_DEV_20260622_1215_PR.txt
  T3-48  docs/session-reports/JU_DEV_20260622_1200_PR.txt
  T3-49  docs/session-reports/JU_DEV_20260622_1145_PR.txt
  T3-50  docs/session-reports/JU_DEV_20260622_1130_PR.txt
  T3-51  docs/session-reports/JU_DEV_20260622_0630_PR.txt
  T3-52  docs/session-reports/JU_DEV_20260621_2100_PR.txt
  T3-53  docs/session-reports/JU_DEV_20260621_0600_PR.txt
  T3-54  docs/session-reports/JU_DEV_20260620_2300_PR.txt
  T3-55  docs/session-reports/JU_DEV_20260620_2200_PR.txt
  T3-56  docs/session-reports/JU_DEV_20260620_2100_PR.txt
  T3-57  docs/session-reports/JU_DEV_20260620_2000_PR.txt
  T3-58  docs/session-reports/JU_DEV_20260619_1430_PR.txt
  T3-59  docs/session-reports/JU_DEV_20260615_2200_PR.txt
  T3-60  docs/session-reports/JU_DEV_20260612_2309_PR.txt
  T3-61  docs/session-reports/JU_DEV_20260610_2146_PR.txt
  T3-62  docs/session-reports/JU_DEV_20260602_A_PR.txt
  T3-63  docs/session-reports/JU_DEV_20260601_A_PR.txt
  T3-64  docs/session-reports/JU_DEV_20260512_0314_PR.txt
  T3-65  docs/session-reports/JU_DEV_20260511_1300_PR.txt
  T3-66  docs/session-reports/JU_DEV_20260511_0000_PR.txt
  T3-67  docs/session-reports/JU_DEV_20260505_0000_PR.txt
  T3-68  docs/session-reports/JU_DEV_20260428_B_PR.txt
  T3-69  docs/session-reports/JU_DEV_20260428_0000_PR.txt
  T3-70  docs/session-reports/JU_DEV_20260426_1502_PR.txt
  T3-71  docs/session-reports/JU_DEV_20260420_0041_PR.txt
  T3-72  docs/session-reports/JU_DEV_20260420_0040_PR.txt
  T3-73  docs/session-reports/JU_DEV_20260420_0039_PR.txt
  T3-74  docs/session-reports/JU_DEV_20260420_0038_PR.txt
  T3-75  docs/session-reports/JU_DEV_20260419_A_PR.txt
  T3-76  docs/session-reports/JU_DEV_20260417_A_PR.txt
  T3-77  docs/session-reports/JU_DEV_20260416_A_PR.txt
  T3-78  docs/session-reports/JU_DEV_20260413_A_PR.txt
  T3-79  docs/session-reports/JU_DEV_20260412_C_PR.txt
  T3-80  docs/session-reports/JU_DEV_20260412_B_PR.txt
  T3-81  docs/session-reports/JU_DEV_20260412_A_PR.txt
  T3-82  docs/session-reports/JU_DEV_20260411_C_PR.txt
  T3-83  docs/session-reports/JU_DEV_20260411_B_PR.txt
  T3-84  docs/session-reports/JU_DEV_20260411_A_PR.txt
  T3-85  docs/session-reports/JU_DEV_20260410_2359_PR.txt
  T3-86  docs/session-reports/JU_DEV_20260410_2200_PR.txt
  T3-87  docs/session-reports/JU-DEV-20260405-TEKPC-360-BROADCAST.txt
  T3-88  docs/session-reports/JU_DEV_20260407_0300_PR.txt
  T3-89  docs/session-reports/JU_DEV_20260406_1600_PR.txt
  T3-90  docs/JU_DEV_20260401_0040_PR.txt
  T3-91  docs/JU_DEV_20260331_2351_PR.txt
  T3-92  docs/JU_DEV_20260331_2250_PR.txt
  T3-93  docs/JU_DEV_20260331_2241_PR.txt
  T3-94  docs/JU_DEV_20260331_2214_PR.txt
  T3-95  docs/JU_DEV_20260331_2146_PR.txt

  NOTE: When new session reports are filed (Step 4 of session close), they must
  be added to the TOP of this Tier 3 list before the session is closed.
  This is a mandatory part of Step 5 of the session close protocol.

  VALIDATION: After updating Tier 3 (or any Tier), run:
    bash scripts/validate-nps-labels.sh
  The script exits non-zero and prints a clear error if any duplicate or
  skipped label is found.  The session must NOT be closed until the script
  exits 0 (all clear).

--------------------------------------------------------------------------------

## TIER 4 — SECURITY BASELINE (accepted findings — must know what is accepted)

  T4-01  .local/potential_vulnerabilities/hounddog-critical-wrap-api-key-stdout.md
  T4-02  .local/potential_vulnerabilities/hounddog-dev-script-stdout.md
  T4-03  .local/potential_vulnerabilities/sast-agent-routes-known-baseline.md
  T4-04  .local/potential_vulnerabilities/sast-false-positives-uwa-strings.md
  T4-05  .local/potential_vulnerabilities/sast-high-gcm-no-tag-length.md
  T4-06  .local/potential_vulnerabilities/dep-high-lodash-prototype-pollution.md
  T4-07  .local/potential_vulnerabilities/dep-high-path-to-regexp-redos.md
  T4-08  .local/potential_vulnerabilities/dep-high-picomatch-redos.md
  T4-09  .local/potential_vulnerabilities/dep-high-rollup-rce.md
  T4-10  .local/potential_vulnerabilities/dep-vite-dev-server-high.md
  T4-11  .local/potential_vulnerabilities/sast-high-bootstrap-invite-token-replit-config.md
  T4-12  .local/potential_vulnerabilities/hounddog-medium-auth-rl-ip-stdout.md

  NOTE: When a new accepted finding is added, it must be added to this list
  and to the Tier 4 reading order in NPS-PROTOCOL.md before session close.

--------------------------------------------------------------------------------

## TIER 5 — LIVE CODE (core architecture — read in full, not skimmed)

  T5-01  shared/schema.ts
  T5-02  shared/spu-schema.ts
  T5-03  server/index.ts
  T5-04  server/routes.ts
  T5-05  server/storage.ts
  T5-06  server/agent-knowledge.ts
  T5-07  server/agent-002-knowledge.ts
  T5-08  server/agent-003-knowledge.ts
  T5-09  server/lib/lwe-logger.ts
  T5-10  server/lib/ecsmid-api.ts
  T5-11  server/lib/tekpc-light.ts
  T5-12  server/lib/tekpc-full.ts
  T5-13  server/lib/gate-clearance.ts
  T5-14  server/lib/chain-utils.ts
  T5-15  server/ghost-apt-engine.ts
  T5-16  server/ghost-wire-monitor.ts
  T5-17  server/immune-hunt-engine.ts
  T5-18  server/uwa-session.ts
  T5-19  server/ir-chain.ts
  T5-20  server/uwa-generator.ts

  NOTE: When a new core file is added, it must be added to this list at session
  close. Peripheral files (email.ts, payment.ts, static.ts, vite.ts) are
  read on demand when the work touches them — not required for NPS.

--------------------------------------------------------------------------------

## AUDIT FILE FORMAT

File path   : docs/nps-audits/NPS_AUDIT_YYYYMMDD_HHMM.md
Naming rule : NPS_AUDIT_ + date (YYYYMMDD) + _ + time (HHMM) + .md
Example     : docs/nps-audits/NPS_AUDIT_20260426_1455.md

The audit file must contain:

  Section 1 — HEADER
    Session date, time, agent ID, supervisor UWA

  Section 2 — READING DECLARATION
    One row per file read. Status (✓ read / ✗ missing). One-sentence summary.
    Tier 1 through Tier 5 in order.

  Section 3 — OPEN ITEMS CARRIED FORWARD
    All open items from prior sessions that are still unresolved.
    Format: OI-NNN : [description] — [owner / status]

  Section 4 — INVARIANTS CONFIRMED
    The non-overridable architectural rules. Checkbox per rule.
    Agent confirms understanding of each one.

  Section 5 — CURRENT PROJECT STATE
    Last session report filed, last deploy, last schema push, active agents,
    trusted IPs, admin UWA, JIRA status, WASM status.

  Section 6 — DECLARATION
    Agent signs. Timestamp. Session report reference (to be filed at close).

The audit file is immutable once written. Corrections go into the next session's
audit file, not as edits to a prior one.

--------------------------------------------------------------------------------

## MAINTENANCE RULES

This document must be updated (with scoped principal approval) when:

  1. A new permanent doc is added to the project → add to correct Tier
  2. A new core server file is created → add to Tier 5
  3. A new accepted security finding is documented → add to Tier 4
  4. A new session report is filed → add to top of Tier 3 list

Maintenance is part of Step 5 of the session close protocol.
A session is NOT closed until NPS-PROTOCOL.md reflects the new session report.

--------------------------------------------------------------------------------

## INVARIANTS THE AGENT MUST CONFIRM DURING NPS

These are confirmed in the audit file (Section 4). Each must be checked:

  [ ] Sealing rule: seal with RECIPIENT's identity material.
      C→S sealed with SM3_stripped. S→C sealed with CM3_stripped.

  [ ] M1/M2/M3 chain: generated ONCE at enrollment. Stored permanently.
      7-way HS is verification only. Changing M1/M2/M3 = identity destruction.

  [ ] SIEVVE is the framework. PAKAPT is the protocol inside it.
      Never write "SIEVVE DDNA" or "PAKAPT framework."

  [ ] ECSMID WASM: browser-side encrypt-only. Server-side decrypt PARKED (OI-004).
      No action on WASM server decrypt without written principal approval.

  [ ] device_id in uwa_records: plain text. Do NOT decrypt.

  [ ] req.uwaPrincipal is set by session middleware — NOT req.uwaSession.
      Getting this wrong breaks all auth-gated routes.

  [ ] sealedPrompt and sealedResponse must never be null in any agent pipeline.

  [ ] PRP §22.6: security scan gate is non-overridable before any deploy.
      Three scanners in parallel. CRITICAL or HIGH blocks delivery.

  [ ] 5-step session close is mandatory before any deploy is suggested.
      Steps: (1) security gate, (2) PRP CRs, (3) LWE broadcast,
      (4) session report, (5) replit.md + NPS-PROTOCOL.md update.

  [ ] RPL: John Hooder's email and all PII are not disclosed in chat.
      Admin panel only. No exceptions.

  [ ] GPA-001 Asset Protection Directive is permanent and non-overridable.
      Agent cannot be used against LokDon/CyberLockX assets under any framing.

  [ ] APPROVAL GATE (PRP §2 — codified 2026-06-20, approved by Protocol Owner):
      A problem report ("X is broken", "fix Y") is NOT an authorization to act.
      Agent must present full analysis + proposed fix and ask "Do you approve this
      change?" before modifying any file. No exceptions, even for obvious fixes.

  [ ] CR BEFORE WORK (PRP §4 — codified 2026-06-20, approved by Protocol Owner):
      A Change Request MUST be created at Analysis phase before any file is touched.
      Sequence: Create CR → phaseApproval → approval_gate.sh --grant → implement
      → phaseImplementation → status:deployed. Retroactive CRs are a violation.
      Never skip or defer CR creation to end of session.

--------------------------------------------------------------------------------

## AGENT WORK-STATE VOCABULARY  (mandatory — PRP v3.1 §2 + §30)

All agents operating under this protocol must use only these exact terms.
Ambiguous language has caused false confidence in prior sessions (recorded violations).

  PERMITTED TERMS
  ───────────────────────────────────────────────────────────────────────
  "Saved"                      File written to disk. No git operation run.

  "Saved and ready for         Work complete. Awaiting Protocol Owner's
   approval"                   "approved" or "proceed" before any action.

  "Checkpoint created"         Only when the platform confirms an automatic
                               snapshot (e.g. Replit checkpoint notification).

  "I am ready for the          Agent is idle and sensing a pause between
   next task"                  tasks.

  "I am ready for              A milestone is complete and the work is
   deployment"                 production-ready (e.g. completed page, feature,
                               or CR ready to move from dev to production).

  BANNED TERMS
  ───────────────────────────────────────────────────────────────────────
  "Committed"        NEVER — the agent cannot run git commit in this sandbox.
  "Ready for commit" NEVER — approval comes before any commit.
  "Deployed"         NEVER — only valid after approval_gate.sh --deploy is
                     confirmed by the Protocol Owner.

  TWO-WAY DEPLOYMENT HANDOFF (platform-aware)
  ───────────────────────────────────────────────────────────────────────
  Agent            →  "I am ready for deployment."
  Protocol Owner   →  "I am ready to deploy."
                      On Replit   : clicks the Publish button.
                      Other platforms : equivalent deployment action.

  Note: "I am ready to publish." is the prior equivalent phrase used in
  all historical session reports (pre-2026-07-22). Both phrases are valid;
  "I am ready to deploy." is the canonical phrase from 2026-07-22 onward.

  APPROVAL TRIGGER (unchanged — PRP §2)
  ───────────────────────────────────────────────────────────────────────
  "approved" or "proceed" — exact words only. No other phrase authorises action.

--------------------------------------------------------------------------------

## CHANGE LOG

  2026-04-26 v1.0 — Initial codification. PRP §30 adopted.
                    Approved by: Josiah Umezurike
                    Filed under: Session JU_DEV_20260426_HHMM_PR.txt

  2026-06-14 v2.1 — Gate v2.1 upgrade. Full agent doctrine awareness.
                    Admin dashboard audit traceability. Gate wired to
                    production build and start commands.

                    New capabilities:
                      · Session TTL (1 hour, NPS_TTL_SECONDS override)
                      · UUID session IDs written to .nps_state
                      · SHA-256 audit hash per session (TIMESTAMP:callsign)
                      · Command-level gating: npm run build, npm run start
                        are now physically blocked by nps-work-gate.sh
                      · New gate commands: status, reset, force-lock
                      · scripts/tiers/tier{1-5}.manifest — 78 real codebase
                        paths, 0 missing, verified by setup-nps-tiers.sh

                    Agent doctrine (all three agents updated):
                      · SUPPORT (RAPCDKeyless-001): NPS v2.1 command guide,
                        session TTL explanation, blocked-event response script,
                        tier manifest awareness, audit trail overview
                      · GHOST (RAPCDKeyless-002): 5 NPS threat patterns —
                        UNAUTHORIZED_BUILD_ATTEMPT, GATE_TAMPER,
                        RISK_CONCEALMENT, EXPIRED_SESSION_LOOP,
                        POST_FORCE_LOCK_BUILD — with adversarial response
                        procedures and gate bypass invariant
                      · IMMUNE (RAPCDUchu-003): 5 artifact classification
                        rules — UNTRUSTED_ARTIFACT, WASM_INTEGRITY_UNDER_NPS,
                        POST_FORCE_LOCK_BUILD (ACTIVE_THREAT),
                        TIER4_CONCEALMENT, AUDIT_LOG_INTEGRITY,
                        GATE_BYPASS_DETECTION (CRITICAL)

                    Admin dashboard:
                      · NPS Enforcement Audit panel added to Admin.tsx
                      · Three new API routes: GET /api/admin/nps/status,
                        GET /api/admin/nps/events, GET /api/admin/nps/sessions
                      · Panel: live gate status, event log with filter,
                        session audit history with per-session hash detail

                    LWE broadcast:
                      · broadcastNpsV2Doctrine20260614A() added and wired
                        in server/index.ts startup sequence

                    .gitignore: .nps_state, runtime log files excluded
                    Filed under: Session JU_DEV_20260614_HHMM_PR.txt

================================================================================
END OF NPS-PROTOCOL
================================================================================
