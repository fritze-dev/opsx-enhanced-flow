# Research: Smart Workflow Checkpoints

## 1. Current State

The workflow has two enforcement mechanisms:
- **Hard gates** (schema/CLI): artifact dependencies, apply gates, approval gates
- **Soft gates** (constitution + agent): design review checkpoint (ADR-006)

**Where pausing currently happens:**

| Checkpoint | Mechanism | Works? |
|---|---|---|
| After each artifact (`/opsx:continue`) | Skill design (one-at-a-time) | Yes but too often |
| After design (`/opsx:ff`) | Constitution convention | Yes, soft gate |
| Before archive (approval gate) | Skill logic | Yes, hard gate |
| Apply on blockers/ambiguity | Skill logic | Yes, hard gate |

**Where pausing is broken:**

| Issue | Problem | Source |
|---|---|---|
| Preflight WITH WARNINGS | Verdict printed but not enforced — user can proceed immediately | #16 |
| Routine transitions | `/opsx:continue` pauses after every artifact, ff pauses only at design | #40 |
| Verify/sync ordering | No guard prevents sync before verify | #26 |

**Affected files:**

- `skills/continue/SKILL.md` — pauses after every artifact (too much)
- `skills/ff/SKILL.md` — has design checkpoint but no preflight-warnings checkpoint
- `openspec/schemas/opsx-enhanced/schema.yaml` — apply instruction defines post-apply order but doesn't enforce it
- `openspec/constitution.md` — design review checkpoint convention
- `openspec/specs/quality-gates/spec.md` — defines verdicts but no mandatory pause for warnings
- `openspec/specs/artifact-generation/spec.md` — documents design checkpoint
- `openspec/specs/human-approval-gate/spec.md` — approval gate, final verify

## 2. External Research

N/A — internal workflow concern.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Constitution-only (soft checkpoints) | Consistent with ADR-006, no skill code changes | Agents may still ignore warnings |
| B: Skill instruction updates (medium) | Clear instructions in each skill, defense in depth | Multiple files to update |
| C: B + spec requirements (full) | Formal traceability, testable requirements | More files, but all are text edits |

**Recommendation: Approach C** — same defense-in-depth pattern as #43.

## 4. Risks & Constraints

- **Low risk:** All changes are text instructions and spec requirements. No CLI code changes.
- **Skill immutability (ADR-006):** Skills are generic plugin code. Checkpoint behavior should be expressed as instructions/guardrails within skills, not project-specific logic. The constitution defines the checkpoint model, skills follow it.
- **Backward compatibility:** No breaking changes. Existing changes in progress are unaffected.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Checkpoint model definition + skill/spec updates |
| Behavior | Clear | Three fixes: preflight warnings, transition pausing, verify-before-sync |
| Data Model | Clear | No data model changes |
| UX | Clear | Less friction at routine transitions, more friction at critical ones |
| Integration | Clear | Constitution + schema + skills + specs |
| Edge Cases | Clear | Discovery Q&A already pauses (input needed), design already has checkpoint |
| Constraints | Clear | Must respect skill immutability (ADR-006) |
| Terminology | Clear | "auto-continue" vs "mandatory-pause" |
| Non-Functional | Clear | No performance implications |

## 7. Decisions

All categories are Clear — no open questions.

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Define checkpoint model in constitution | Constitution is injected into every prompt — authoritative for agent behavior | Schema-level enforcement (too rigid), skill-only (scattered) |
| 2 | Mandatory pause for preflight WITH WARNINGS | Warnings were auto-accepted (#16), causing issues downstream | Auto-continue with warnings (current broken state) |
| 3 | Auto-continue for routine transitions | Reduces friction at obvious steps (#40) | Pause at every step (current behavior of continue) |
| 4 | Enforce verify-before-sync in apply instruction and constitution | Prevents baseline spec modification before validation (#26) | Hard gate in sync skill (violates skill immutability) |
| 5 | Use Approach C (constitution + skills + specs) | Defense in depth, formal traceability | Constitution-only, skills-only |
