# Pre-Flight Check: Visible Assumptions & REVIEW Auto-Resolution

## A. Traceability Matrix

### spec-format: Assumption Marker Format (ADDED)
- [x] Scenario: Pattern A format → schema.yaml instructions, templates/specs/spec.md, templates/design.md
- [x] Scenario: Pattern B flagged → quality-gates preflight (Marker Audit)
- [x] Scenario: Empty assumptions section → templates/specs/spec.md, templates/design.md

### quality-gates: Preflight Quality Check (MODIFIED)
- [x] Scenario: Preflight passes → preflight.md template, schema.yaml preflight instruction
- [x] Scenario: Pattern B found → preflight.md template (Marker Audit)
- [x] Scenario: REVIEW marker found → preflight.md template (Marker Audit)
- [x] Scenario: Constitution contradiction → unchanged from baseline
- [x] Scenario: Warnings require ack → unchanged from baseline
- [x] Scenario: Missing artifacts → unchanged from baseline

### constitution-management: Bootstrap-Generated Constitution (MODIFIED)
- [x] Scenario: Codebase scan → skills/bootstrap/SKILL.md
- [x] Scenario: Uncertain conventions resolved → skills/bootstrap/SKILL.md (REVIEW auto-resolution loop)
- [x] Scenario: No invented rules → unchanged from baseline
- [x] Scenario: Standard sections → unchanged from baseline
- [x] Scenario: No REVIEW markers remain → skills/bootstrap/SKILL.md (post-generation verification)

### constitution-management: Constitution Update (MODIFIED)
- [x] Scenario: New dependency → unchanged from baseline
- [x] Scenario: New pattern → unchanged from baseline
- [x] Scenario: Technology replacement resolved → skills/bootstrap/SKILL.md (direct question instead of REVIEW marker)
- [x] Scenario: Changes documented → unchanged from baseline

### decision-docs: ADR Generation (MODIFIED)
- [x] Scenario: Spec link auto-resolved → skills/docs/SKILL.md (reference validation)
- [x] Scenario: Archive link resolved via user question → skills/docs/SKILL.md (reference validation)
- [x] Scenario: No REVIEW markers in ADRs → skills/docs/SKILL.md (post-generation verification)

### Assumption-only deltas (9 specs)
- [x] artifact-generation: 3 assumptions converted Pattern B → A
- [x] artifact-pipeline: 5 assumptions converted Pattern B → A
- [x] change-workspace: 5 assumptions (3 from section + 2 inline moved to section)
- [x] human-approval-gate: 5 assumptions (3 from section + 2 inline moved to section)
- [x] interactive-discovery: 4 assumptions (3 from section + 1 inline moved to section)
- [x] project-bootstrap: 2 assumptions converted Pattern B → A
- [x] project-setup: 3 assumptions converted Pattern B → A
- [x] task-implementation: 5 assumptions (4 from section + 1 inline moved to section)
- [x] three-layer-architecture: 2 assumptions converted Pattern B → A

## B. Gap Analysis

- **Inline Pattern B removal**: Fixed — MODIFIED requirements added to delta specs for quality-gates (Post-Implementation Verification), task-implementation (Implement Tasks), human-approval-gate (QA Loop, Fix Loop), interactive-discovery (Standalone Research), and change-workspace (Create Workspace, Archive Change). Inline HTML comments removed from requirement text; assumption content captured in Assumptions sections.
- **Docs skill mapping rules table**: `skills/docs/SKILL.md` line 118 references `<!-- ASSUMPTION -->` and `<!-- REVIEW -->` in its mapping rules. Will be updated during implementation (skill file edit, not a spec-level change).

## C. Side-Effect Analysis

- **Preflight skill behavior change**: Existing preflights will now flag Pattern B assumptions as violations. Any in-progress changes (other than this one) using Pattern B would be blocked. **Risk: Low** — git status is clean, no active changes.
- **Bootstrap skill behavior change**: Adding interactive REVIEW resolution loop changes the bootstrap UX — it now pauses for each uncertain item instead of silently marking. **Risk: Low** — improvement in user experience.
- **Docs skill behavior change**: ADR generation now asks the user about broken references instead of silently adding markers. **Risk: Low** — improvement.
- **Sync process**: 13 delta specs will be synced to baselines. Large scope but mechanical. **Risk: Low**.

## D. Constitution Check

- Constitution line 27 defines `<!-- REVIEW -->` as marker convention. This needs updating to document that REVIEW markers are transient and auto-resolved.
- Constitution does not currently mention assumption format (Pattern A) — this is defined in the schema, which is correct per the "Constitution Contains Only Project-Specific Rules" requirement. No constitution update needed for assumption format.
- **No contradictions** with existing constitution rules.

## E. Duplication & Consistency

- **No duplication**: Each delta spec addresses a distinct capability. No overlapping requirements.
- **Consistency check**: All 9 assumption-only deltas use the same Pattern A format (`- Visible text. <!-- ASSUMPTION: tag -->`). Consistent.
- **Cross-spec consistency**: The new spec-format requirement (Pattern A enforcement) aligns with the quality-gates expansion (Marker Audit checks Pattern A compliance). No contradictions.
- **Existing spec consistency**: Checked all 18 baseline specs. The 5 already-compliant specs (roadmap-tracking, architecture-docs, release-workflow, user-docs, spec-sync) are unaffected and consistent with the new rules.

## F. Marker Audit

### Assumptions in delta specs

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | No in-progress changes use old Pattern B format | design.md | Acceptable Risk — verified via git status |
| 2 | OpenSpec CLI does not parse assumption/review markers | design.md | Acceptable Risk — confirmed by CLI behavior |

### Assumptions in change specs (delta Assumptions sections)
All 49 assumption migrations are mechanical format conversions of existing accepted assumptions. No new assumptions introduced by the assumption-only deltas. The 4 requirement-change deltas include inline assumptions within their requirement text — all use Pattern A format correctly.

### REVIEW markers
- Zero `<!-- REVIEW -->` markers found in any change artifact.

## Verdict: PASS

**Warnings: 0**
**Blockers: 0**

All inline Pattern B assumptions resolved via MODIFIED requirements in delta specs. Docs skill mapping table update is an implementation task (skill file, not spec).
