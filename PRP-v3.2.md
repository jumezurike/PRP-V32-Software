# Problem Resolution Protocol — PRP v3.2

**Protocol Owner:** Josiah Umezurike (CyberLockX / JU)  
**Adopted By:** LokDon ECSMID  
**Status:** MANDATORY — No exceptions.  
**Supersedes:** [PRP v3.1](../PRP-v3.1.md)

---

## Purpose and Continuity

PRP v3.2 incorporates the Release Integrity, Branch Isolation & Truthful
Deployment Records amendment as a mandatory extension of PRP v3.1. It is one
protocol, not a second framework.

All PRP v3.1 requirements remain in force unless this document explicitly
extends them. In particular, the v3.1 core mandate remains:

> No implementation without explicit SCOPED approval.  
> No work without a verified backup.  
> No sensitive data handled without controlled protection.

This protocol governs all development activity on this codebase — human
developers, AI agents, and invited collaborators alike. Governance records
must describe what actually happened, not what was intended to happen.

## Portable Adoption and Identity Profiles

PRP v3.2 is portable and does not require the adopting organization to run
AINISG. The identity boundary is defined by the organization's registered
OAuth policy:

| Adoption profile | Required approval identity |
|---|---|
| **AINISG organization** | Verified organization OAuth **plus** an active UWA session |
| **PRP-only organization** | Verified organization OAuth subject |

An AINISG organization may never downgrade to OAuth-only approval. Its
`requires_uwa` policy is permanent for the organization record. A PRP-only
organization must be explicitly registered with its OAuth provider, issuer, and
allowed email domains before an OAuth approval can be accepted.

Claude Code, Copilot, GPT shell agents, and other shell-capable runners are
supported execution clients. They may unpack the PRP software ZIP, read these
instructions, run the checks, and submit server-verified requests. A runner
name, email typed into a command, or self-declared agent identity is never an
approval credential. The server resolves the authenticated organization
identity and compares it with the submitted identity.

## Preserved PRP v3.1 Core Phases

The following seven phases are retained in their original order. No phase may
be skipped. The release controls in this document extend Phase 6 (Delivery)
and Phase 7 (Documentation); they do not replace any phase.

1. **ANALYSIS** — Document the Problem Genesis, Root Cause, and an ordered
   Roadmap. Do not proceed until the full analysis is written and presented.
2. **APPROVAL** — Obtain written, scoped approval from the Protocol Owner for
   the plan. Generic consent is not approval; changed scope returns to Phase 2.
3. **PREPARATION** — Verify and document the working-tree state, create and
   verify named backups, confirm required secrets, and establish a baseline.
   If a backup cannot be verified, stop.
4. **IMPLEMENTATION** — Perform only approved work, create milestone backups,
   and return to Phase 2 when a changed approach or scope is required.
5. **REVIEW** — Perform an AI/developer pre-check and obtain mandatory human
   confirmation. AI self-review alone does not authorize delivery.
6. **DELIVERY** — Push, deploy, or merge only after Phase 5 confirmation and
   explicit post-review authorization. Document what was delivered, where, and
   when. The v3.2 clean-release controls below apply before publication.
7. **DOCUMENTATION** — Create and retain the permanent session record required
   by PRP v3.1. The v3.2 release manifest, ledger, and evidence requirements
   are additional records; they do not remove this phase.

---

## 24. Release Integrity Principle

> **The approved release, tested release, published release, and recorded
> release must represent the same governed artifact.**

A mixed development branch must never be made releasable by invoking an
additional emergency or break-glass mechanism. When approved release work is
mixed with unrelated, experimental, generated, unreviewed, or undecided
material, the required response is:

> **FREEZE → INVENTORY → ISOLATE → CORRECT → VALIDATE → HUMAN RELEASE → VERIFY**

The objective is a truthful, reproducible, attributable, and auditable release.

## 25. Freeze the Mixed Branch

On identifying a mixed branch, do **not** reset, force-push, publish, deploy,
rewrite history to make it releasable, invoke break-glass, allow AI to push it,
or delete evidence of how the mixed state occurred. Freeze the branch as a
preserved working/evidence state until classified. Record:

`BRANCH`, `HEAD_COMMIT`, `BASE_COMMIT`, `FREEZE_TIMESTAMP`, `NPS_SESSION`,
`RELATED_CR`, `REASON_FOR_FREEZE`, `RESPONSIBLE_HUMAN`, and `EVIDENCE_ID`.

## 26. Inventory Since Authoritative Main

Use approved GitHub `main` as the authoritative comparison point. Inventory all
relevant commits and changed files since that point and classify every item:

| Group | Classification | Treatment |
|---|---|---|
| A | Approved release material | Only material demonstrably within the approved CR scope. |
| B | Non-release material | Remains outside the release; includes uploaded ZIPs, generated mockups, unapproved images, agent memory, research, temporary files, experiments, local artifacts, generated outputs, and unrelated development. |
| C | Human decision required | Release status cannot be established from existing governance evidence. |

The system must not guess. AI must not silently classify ambiguous material as
approved; Group C requires a human decision before entry into a governed release.

## 27. Build a Clean Release Branch

Create a clean release branch from authoritative GitHub `main`. Bring forward
only approved CR material, required approved configuration, required governance
records, and explicitly authorized release dependencies. It must not inherit
unrelated material merely because it existed in the mixed branch. Preserve the
mixed branch.

## 28. Release Manifest

Every governed release must generate a **Release Manifest (RM)** defining what
the organization believes it released. It contains:

`RELEASE_ID`, `CR_ID`, `SOURCE_MAIN_COMMIT`, `RELEASE_BRANCH`,
`RELEASE_HEAD_COMMIT`, `APPROVED_FILES`, `EXCLUDED_FILES`, `SECURITY_SCAN_ID`,
`NPS_PROOF_ID`, `RECOVERY_POINT_ID`, `HUMAN_APPROVAL_ID`, `FIM_BASELINE_ID`,
`DEPLOYMENT_STATUS`, `PUBLISHED_AT`, `PUBLISHED_BY`,
`POST_PUBLISH_VALIDATION`, `POST_PUBLISH_FIM_ID`, and `EVIDENCE_ID`.

## 29. Truthful CR Ledger

The Change Request ledger must state only what actually happened. It must not
state `DEPLOYED` or `PUBLISHED` before the governed artifact is actually
deployed or published. Standard release states are:

| Point in lifecycle | Allowed state |
|---|---|
| Before release | `APPROVED`, `RELEASE_PREPARED`, `GATES_PENDING`, or `READY FOR HUMAN RELEASE` |
| After successful publication | `DEPLOYED` or `PUBLISHED` |
| After verification | `DEPLOYMENT VERIFIED` |

## 30. Ledger Correction

Do not silently overwrite a CR record that incorrectly claims deployment.
Create a correction record containing `ORIGINAL_RECORD`, `INCORRECT_STATE`,
`CORRECTED_STATE`, `CORRECTION_REASON`, `CORRECTED_BY`, `CORRECTION_TIME`,
`APPROVER`, and `EVIDENCE_ID`. Correct the record without destroying history.

## 31. Gates Must Run Against the Exact Release Artifact

A gate performed against one branch does not authorize another. Final required
gates must operate on the exact commit intended for publication. The governed
release candidate binds:

`CR` · `BRANCH` · `COMMIT` · `RECOVERY POINT` · `SECURITY EVIDENCE` ·
`HUMAN APPROVAL`

If the candidate changes after validation, invalidate and rerun affected gates
according to policy.

## 32. Required Clean-Release Gates

For the exact clean branch and commit, verify:

- **NPS:** valid governed-session evidence;
- **CR:** approved Change Request matching release scope;
- **Release Manifest:** exact approved files identified;
- **TypeScript Correctness:** the exact release artifact passes
  `bash scripts/typescript-gate.sh` with zero compiler errors;
- **Security Scan:** required security validation passed;
- **Recovery Point:** verified Tier 6 recovery point available;
- **FIM:** pre-release integrity state established;
- **Human Approval:** authorized person approves the exact candidate; and
- **UCHU:** governance conditions satisfied.

Only then may the candidate be `READY FOR HUMAN RELEASE`.

### 32.1 TypeScript Correctness Is a Blocking Release Control

TypeScript correctness is part of the PRP release and pre-deployment ceremony,
not an optional developer convenience. Every build, security-scan acceptance,
session close, release-candidate validation, and deployment path must run the
canonical TypeScript gate against the exact artifact under review:

```bash
bash scripts/typescript-gate.sh
```

Any compiler error blocks delivery. The dated
`.local/.typescript_gate_passed` sentinel is evidence of the check and is
invalidated whenever the source changes. It does not replace the required
security scanners, human approval, FIM, recovery-point, or UCHU controls.

## 33. Human-Controlled B2B-LokDon Push

Final publication remains human-controlled through the Dashboard's
**B2B-LokDon Push Control**. It must show the CR, release branch, commit,
approved files, excluded material, security gate result, verified recovery
point, valid NPS, UCHU authorization, FIM baseline status, destination, and
that human authorization is required. AI must not autonomously perform this
final push where PRP requires human execution.

### 33.1 Terminal Candidate Contingency

When the Dashboard is unavailable, the Protocol Owner may use the terminal
candidate ceremony to collect server-verified candidate facts, inspect the
ledger, build the same immutable release manifest, and mint the same
short-lived, one-use preflight authorization. Collection may produce a
non-secret evidence draft from human-supplied receipt references, but it does
not create an approval, recovery point, FIM baseline, or UCHU authorization.
This is a candidate-preparation contingency, not an alternate deployment
channel.

The terminal ceremony sends the active authenticated UWA session only to the
local protected release API; it does not accept a text approval record or a
self-declared identity as authorization.

The terminal ceremony has no operation for choosing a repository or branch,
exporting a vault credential, force-pushing, pushing to GitHub, publishing to
Replit, or recording a production FIM receipt. The only destination remains
`jumezurike/B2B-Lokdon` on `main`; the later GitHub push, Publish, and FIM
verification continue to require their normal human-controlled evidence.

## 34. Post-Publish FIM Re-Baseline

Publication does not complete governance. After publication:

> **VERIFY DEPLOYMENT → VERIFY EXPECTED FILE STATE → RUN FIM → COMPARE RELEASE
> MANIFEST → INVESTIGATE UNEXPECTED DRIFT → ESTABLISH NEW APPROVED BASELINE →
> RECORD FIM BASELINE ID → CLOSE RELEASE**

The new baseline must correspond to the verified deployed release.

## 35. Release Completion

A CR reaches `CLOSED — DEPLOYMENT VERIFIED` only after human publication
succeeds; the deployed artifact matches the Release Manifest; application or
service validation passes; FIM verification passes; a post-publish baseline is
established; and required evidence is retained.

When development and production use separate databases, the closed ceremony is
mirrored to production through the authenticated closed-release mirror
endpoint. The mirror is digest-verified, idempotent, append-only, and read-only
in the production Dashboard. It does not repeat candidate preparation, push,
Publish, or FIM.

`PUSH SUCCESSFUL` does not mean `RELEASE VERIFIED`.

## 36. Failure After Publication

Do not create another bypass if post-publish validation fails. Use Tier 6:

> **POST-PUBLISH FAILURE → GHOST / VALIDATION DETECTS → UCHU PREVENTS NORMAL
> CLOSURE → SELECT VERIFIED RECOVERY POINT → RESTORE / FAILOVER → VERIFY → FIM
> → RE-LOCK → INCIDENT / CR EVIDENCE → NORMAL GOVERNANCE RESUMES**

This connects release governance directly to BC/DR.

## 37. Relationship to Emergency Governance

Break-glass is for genuine emergency containment and restoration. It must not
be used because a branch is messy, unrelated files were committed, the ledger
is inaccurate, gates are incomplete, deadlines approach, AI generated extra
material, or rebuilding a release candidate is inconvenient. Those conditions
require governance correction.

> **A mixed branch is a release-integrity problem, not a break-glass event.**

## 38. CR-971 Immediate Release Procedure

For the current CR-971 mixed-branch situation, perform:

1. **FREEZE** — Preserve the branch; do not reset, publish, push, or destroy it.
2. **INVENTORY** — Classify changes since GitHub `main` as release,
   non-release, or human decision required.
3. **ISOLATE** — Create a clean branch from `main` and bring only approved
   material and required records forward.
4. **CORRECT** — Correct premature ledger claims while preserving history.
5. **VALIDATE** — Run applicable NPS, CR authorization, security scan,
   Recovery Point Manifest, FIM, UCHU, and human-approval gates against the
   exact clean branch/commit.
6. **HUMAN RELEASE** — An authorized human uses B2B-LokDon Push Control.
7. **VERIFY** — Verify deployed state, run post-publish FIM, and compare it
   with the Release Manifest.
8. **RE-BASELINE** — Establish the approved FIM production baseline.
9. **CLOSE** — Record `DEPLOYMENT VERIFIED / CLOSED` only after verification.

## 39. SOC 2 Evidence Value

For a sampled production release, retained evidence must support this trace:

> **CR → Approved scope → Source baseline → Commit inventory → Release
> isolation → Exact Release Manifest → NPS evidence → Security scan → Verified
> recovery point → Human approval → UCHU authorization → Human push →
> Deployment record → Post-deployment FIM → Production baseline → CR closure**

This provides: **INTENT → AUTHORIZATION → ARTIFACT → VALIDATION → RELEASE →
PRODUCTION STATE**.

## 40. Final Release Governance Rule

> **Never make an untruthful release releasable by adding another bypass.
> Isolate the approved work, validate the exact artifact, require human release
> authorization, verify what reached production, and preserve the evidence.**

The operating sequence is:

> **FREEZE → INVENTORY → ISOLATE → CORRECT → GATE → HUMAN RELEASE → VERIFY →
> FIM RE-BASELINE → CLOSE**

Combined with Tier 6 BC/DR:

> **If the release is wrong before publication, isolate it. If the release
> fails after publication, recover it. Neither condition justifies weakening
> governance.**

## 41. LokDon Principal Attestation and SOC 2 Readiness Evidence

The historical PRP v3.1 record remains part of the `/prp` reference. PRP v3.2
and the LokDon / CyberLockX evidence-readiness record are appended; they do not
erase or rewrite the prior protocol text.

The canonical principal attestation must display all seven governance phases:
**Analysis, Approval, Preparation, Implementation, Review, Delivery, and
Documentation**. Review and Documentation are independent evidence classes and
must not be inferred from another phase. Dedicated Security Scan results are
reported separately from the Delivery phase.

The production snapshot captured on 2026-08-28 records **329/329** for each of
the seven phases. The production ledger directly records **313/329** scan
passes, **16 not recorded**, and **0 failed**. Governed read-only reconciliation
matched 15 of the 16 gaps to retained session reports that explicitly identify
the covered CRs and record a clean Security Gate. The exact CR-545 artifact was
then reconstructed at its governed commit and scanned against its exact parent,
yielding **329/329 verified evidence**. Future attestations must capture a fresh
population and must not infer a scan result from Delivery.

The dedicated scan population is complete for this captured snapshot. The
readiness outcome may display `PASSED` or `ATTESTED`, but it must remain
qualified as **EVIDENCE READY — NOT CERTIFIED**. It is not a SOC 2 report,
certification, management assertion, or independent auditor opinion.

The linked SOC 2 readiness package normalizes the evidence inventory to **230
control statements across 37 control families**, mapped to Security,
Availability, Confidentiality, Processing Integrity, and Privacy. The package
is evidence preparation only. It is not a SOC 2 report, certification,
management assertion, or independent auditor opinion.

Canonical evidence:

- `docs/compliance/LOKDON_PRP_V3_2_SOC2_READINESS_ATTESTATION.json`
- `docs/compliance/LOKDON_PRP_V3_2_SOC2_READINESS_EVIDENCE.md`
- `docs/compliance/LOKDON_PRP_V3_2_SCAN_RECONCILIATION.json`
- `docs/compliance/CR545_EXACT_ARTIFACT_SCAN_EVIDENCE.json`