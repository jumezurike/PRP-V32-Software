# PRP v3.1 — Software Adoption Package
### Full NPS Enforcement Suite · LokDon Open Enforcement Licence
**LokDon Development Framework · Lancaster University**
*Protocol Owner: Josiah Umezurike*

[![PRP Version](https://img.shields.io/badge/PRP-v3.1%20Final-blue?style=flat-square)](https://github.com/jumezurike/PRP-V31-Software)
[![Licence](https://img.shields.io/badge/Licence-LokDon%20Open%20Enforcement-green?style=flat-square)](#licence)
[![NPS Gate](https://img.shields.io/badge/NPS%20Gate-Enforced-red?style=flat-square)](#quick-start)
[![OWASP LLM](https://img.shields.io/badge/OWASP%20LLM%20Top%2010-Aligned-orange?style=flat-square)](#framework-alignment)

---

## What This Is

This repository is the **complete software adoption package** for teams
implementing PRP v3.1 (Problem Resolution Protocol) under the
LokDon Open Enforcement Licence.

Clone this repo, run the setup script, and your AI development environment
is fully governed by PRP v3.1 — structurally, not on an honour system.

For the full PRP v3.1 specification and scientific reference:
**[github.com/jumezurike/PRP-V31-Software](https://github.com/jumezurike/PRP-V31-Software)**

---

## PRP v3.2 Release Integrity Extension

PRP v3.2 extends this PRP v3.1 adoption package; it is **not** a second
framework or a replacement for the seven required PRP phases. It adds
release-integrity controls to the existing Delivery and Documentation phases:

- freeze and preserve a mixed branch rather than bypassing governance;
- inventory and classify changes from authoritative `main`;
- isolate approved scope on a clean release branch;
- bind the Release Manifest and all final gates to the exact release commit;
- keep CR ledger states truthful until publication and verification;
- require human-controlled publication; and
- verify production, run post-publish FIM, and establish the approved baseline
  before closing the release.

Use the canonical policy at
**[PRP-v3.2.md](PRP-v3.2.md)**. Existing v3.1 NPS, approval,
security, UCHU, session-record, and human-confirmation controls remain in
force. For the canonical `origin` remote
`https://github.com/jumezurike/B2B-Lokdon.git` (or its SSH form), the
installed pre-push hook runs `release_integrity_gate.sh` after a successful
session close. It fails closed unless the push is a non-force update to
`main`, `HUMAN_PUSH=1` is set, no session-close skip is active, and
`RELEASE_PUSH_AUTHORIZATION` is a valid, unconsumed, unexpired authorization
for the exact `HEAD` candidate verified through `psql` and `DATABASE_URL`.

---

## The Problem This Solves

> **Honour-based AI compliance has already failed.**

Every major AI coding assistant — Claude, GPT-4, Gemini, Copilot — operates
on a trust model: the agent follows documentation by choice.

**Violation 3 (2026-04-17):** An agent began work without reading session
history. The response was not to write better instructions. The response was
to make non-compliance **structurally impossible.**

```
WITHOUT PRP v3.1                    WITH PRP v3.1
─────────────────────────────────   ─────────────────────────────────
Agent reads docs if it feels        Agent CANNOT BEGIN until callsign
like it                             received and all tiers read

"Go ahead" = approval               ONLY "approved" or "proceed" counts

No audit trail                      Every CR tracked from creation to deploy

Security scan = best practice       Pre-deployment scan NON-OVERRIDABLE

AI reviews its own work             AI CANNOT self-approve. Period.
```

---

## What Is Included

```
PRP-V32-Software/
├── scripts/                         ← Full enforcement script suite
│   ├── nps_gate.sh                  ← Callsign gate: accepts NPS, writes .nps_state
│   ├── nps_work_gate.sh             ← Command wrapper: blocks work until NPS done
│   ├── approval_gate.sh             ← CR lifecycle: --request → --grant → --deploy
│   ├── security_gate.sh             ← Security scan sentinel (dep + SAST + HoundDog)
│   ├── setup_nps_tiers.sh           ← Creates tier directory structure
│   ├── stage_for_approval.sh        ← Generates approval.txt before commit
│   ├── validate_nps_labels.sh       ← Validates NPS tier labels in session reports
│   ├── validate_session_close.sh    ← Validates session report before push
│   ├── release_integrity_gate.sh    ← Verifies canonical B2B release candidate before push
│   ├── uchu-identity.sh             ← UCHU governance identity (sourced by others)
│   ├── uchu-init.sh                 ← UCHU initialisation
│   └── .githooks/
│       ├── pre-commit               ← Blocks commit without NPS + approval sentinels
│       └── pre-push                 ← Blocks push without session report + security gate
├── tiers/                           ← NPS reading order scaffold
│   ├── tier1/                       ← Governance (read first)
│   ├── tier2/                       ← Technical reference (read second)
│   ├── tier3/                       ← Session history (read third, newest first)
│   ├── tier4/                       ← Security baseline (read fourth)
│   ├── tier5/                       ← Live code — up to 20 key files (read fifth)
│   └── tier6/                       ← BC/DR and verified recovery (read sixth)
├── docs/
│   ├── NPS-PROTOCOL.md              ← Full NPS specification and tier manifest
│   ├── templates/
│   │   └── SESSION_REPORT_TEMPLATE.txt  ← Session report template
│   └── nps-audits/                  ← NPS audit files written per session
├── .github/workflows/
│   └── prp-compliance.yml           ← GitHub Actions PRP compliance check
├── PRP-v3.2.md                      ← PRP v3.2 Release Integrity Extension (canonical policy)
├── push-to-github-prp-v32-software.sh ← Syncs this export folder to its own GitHub repo
├── LICENCE.md                       ← LokDon Open Enforcement Licence
└── README.md                        ← This file
```

---

## Quick Start

### Step 1 — Clone this repo into your project

```bash
git clone https://github.com/jumezurike/PRP-V32-Software.git prp-enforcement
```

### Step 2 — Copy the enforcement scripts into your project

```bash
cp -r prp-enforcement/scripts your-project/scripts
cp -r prp-enforcement/tiers  your-project/tiers
cp -r prp-enforcement/docs   your-project/docs
cp    prp-enforcement/LICENCE.md your-project/LICENCE-PRP.md
```

### Step 3 — Activate Git hooks

```bash
cd your-project
git config core.hooksPath scripts/.githooks
```

### Step 4 — Set up NPS tiers

```bash
bash scripts/setup_nps_tiers.sh
```

This creates the tier directory structure and registers it in `docs/NPS-PROTOCOL.md`.

### Step 5 — Populate your tiers

Add your project's governance, technical reference, and session history
files to the appropriate tier directories, including Tier 6 (BC/DR and
verified recovery). See each `tiers/tierN/README.md` for guidance on what
belongs there.

### Step 6 — Wrap your work commands

```bash
# Replace direct invocations with the work gate
bash scripts/nps_work_gate.sh npm run dev
bash scripts/nps_work_gate.sh python manage.py runserver
bash scripts/nps_work_gate.sh cargo run
```

---

## Daily Workflow

```
Every session:
  1. bash scripts/nps_gate.sh "Non-Markovian Property Startup"
     → reads all tiers, writes .nps_state (valid for 1 hour)
  2. bash scripts/nps_work_gate.sh <your command>
     → gate checks .nps_state — blocked if NPS not done

Every change:
  1. bash scripts/approval_gate.sh --request "CR title"
     → creates Change Request, agent STOPS
  2. Protocol Owner approves in chat ("approved" / "proceed")
  3. bash scripts/approval_gate.sh --grant "CR title"
     → writes approval sentinel
  4. Implement the change
  5. git add <files> && git commit -m "..."
     → pre-commit hook validates NPS + approval sentinels
  6. bash scripts/approval_gate.sh --deploy "<files>" "<rollback>"
     → closes CR, marks deployed

Before push:
  1. bash scripts/security_gate.sh --accept
     → dep audit + SAST + HoundDog (zero critical/high required)
  2. Write session report to docs/session-reports/
  3. git push
     → pre-push hook validates session report + security gate sentinel
```

---

## Script Reference

| Script | Purpose | Key flags |
|---|---|---|
| `nps_gate.sh` | Accepts the NPS callsign, writes `.nps_state` | `"Non-Markovian Property Startup"` · `status` · `reset` · `force-lock` |
| `nps_work_gate.sh` | Wraps any command — blocks if NPS not done | `--log-only` for dry-run |
| `approval_gate.sh` | Full CR lifecycle management | `--request` · `--grant` · `--deploy` |
| `security_gate.sh` | Runs security scans and writes sentinel | `--accept` |
| `setup_nps_tiers.sh` | Creates tier directories, registers in NPS-PROTOCOL | — |
| `stage_for_approval.sh` | Generates `approval.txt` before commit | — |
| `validate_nps_labels.sh` | Validates NPS tier labels; prints session-close checklist | `--report <file>` |
| `validate_session_close.sh` | Validates session report before push | — |
| `uchu-identity.sh` | UCHU governance identity (sourced by other scripts) | — |
| `uchu-init.sh` | UCHU initialisation | — |
| `release_integrity_gate.sh` | Verifies canonical B2B release candidate before push (PRP v3.2) | — |
| `push-to-github-prp-v32-software.sh` | Syncs this export folder to its own GitHub repo | — |

---

## Configuration

### NPS gate script name

If your project uses a hyphen-named gate (`nps-gate.sh` instead of `nps_gate.sh`),
set the environment variable:

```bash
export NPS_GATE_SCRIPT=scripts/nps-gate.sh
```

### Session TTL

Default session duration is 1 hour. Override:

```bash
export NPS_TTL_SECONDS=7200   # 2 hours
bash scripts/nps_gate.sh "Non-Markovian Property Startup"
```

### Docs directory

Override where gate logs are written:

```bash
export NPS_DOCS_DIR=/var/log/nps
```

---

## Integration Examples

### Replit workflow

```
command = "bash scripts/nps_work_gate.sh npm run dev"
```

### Makefile

```makefile
dev:
        bash scripts/nps_work_gate.sh npm run dev

build:
        bash scripts/nps_work_gate.sh npm run build
```

### package.json

```json
{
  "scripts": {
    "dev":   "bash scripts/nps_work_gate.sh vite",
    "build": "bash scripts/nps_work_gate.sh vite build"
  }
}
```

### GitHub Actions (audit mode)

```yaml
- name: NPS compliance audit
  run: bash scripts/validate_nps_labels.sh
```

---

## Agent Work-State Vocabulary

All agents operating under PRP v3.1 must use only these exact terms:

| Term | Meaning |
|---|---|
| **"Saved"** | File written to disk. No git operation run. |
| **"Saved and ready for approval"** | Work complete. Awaiting "approved" or "proceed". |
| **"Checkpoint created"** | Only when the platform confirms an automatic snapshot. |
| **"I am ready for the next task"** | Agent is idle, sensing a pause between tasks. |
| **"I am ready for deployment"** | Milestone complete — work is production-ready. |

**Banned terms:** "Committed" · "Ready for commit" · "Deployed" (before `--deploy` confirmed)

**Two-way deployment handoff:**
```
Agent          →  "I am ready for deployment."
Protocol Owner →  "I am ready to deploy."
                  On Replit:          clicks the Publish button
                  Other platforms:    equivalent deployment action
```

---

## Framework Alignment

| Standard | Alignment |
|---|---|
| **OWASP LLM Top 10** | LLM01 (Prompt Injection), LLM06 (Sensitive Info Disclosure), LLM08 (Excessive Agency) |
| **NIST AI RMF** | GOVERN, MAP, MEASURE, MANAGE functions |
| **ISO/IEC 42001** | AI management system controls |
| **NCSC Secure AI** | Secure development lifecycle, supply chain |

---

## Licence

**LokDon Open Enforcement Licence v1.0**
See [LICENCE.md](LICENCE.md) for full terms.

Summary:
- ✅ Free to use in any software development workflow
- ✅ Commercial use permitted
- ✅ Modifications permitted with disclosure
- ❌ Cannot sell or sublicense the scripts as a standalone product
- ❌ Cannot remove attribution to LokDon, PRP v3.1, or Josiah Umezurike

*LokDon AISM · © 2026 Josiah Umezurike · Lancaster University*
*Canonical specification: [github.com/jumezurike/PRP-V31-Software](https://github.com/jumezurike/PRP-V31-Software)*
