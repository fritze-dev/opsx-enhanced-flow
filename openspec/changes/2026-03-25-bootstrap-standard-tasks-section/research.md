# Research: Bootstrap Standard Tasks Section

## 1. Current State

The bootstrap skill (`skills/bootstrap/SKILL.md`) generates the constitution during First Run (Step 2) with a hardcoded markdown template containing five sections:

- `## Tech Stack`
- `## Architecture Rules`
- `## Code Style`
- `## Constraints`
- `## Conventions`

The `## Standard Tasks` section is **missing** from this template (lines 47–64 of SKILL.md).

The standard-tasks feature (merged via #12, archived at `openspec/changes/archive/2026-03-24-standard-tasks/`) introduced a two-layer design:
1. **Schema layer** — universal post-implementation steps in `openspec/schemas/opsx-enhanced/templates/tasks.md` (section 4)
2. **Constitution layer** — project-specific extras appended after universal steps

The task generation instruction in `schema.yaml` (line ~200) already checks the constitution for a `## Standard Tasks` section and appends items. But new projects bootstrapped via `/opsx:bootstrap` won't have this section unless they know to add it manually.

**Affected files:**
- `skills/bootstrap/SKILL.md` — constitution template in Step 2 (primary change)
- `openspec/specs/constitution-management/spec.md` — lists retained sections (Tech Stack, Architecture Rules, Code Style, Constraints, Conventions) but does not mention Standard Tasks

## 2. External Research

Not applicable — this is an internal template change.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Add `## Standard Tasks` section to the SKILL.md template in Step 2 | Minimal change, new projects get the section automatically, matches issue request exactly | None significant |
| B: Auto-detect standard tasks from codebase during scan | More intelligent | Over-engineered — standard tasks are user-defined, not observable from code |

**Recommendation:** Approach A — add the section with an HTML comment explaining its purpose, matching the format requested in the issue.

## 4. Risks & Constraints

- **No breaking change** — existing constitutions are unaffected (only First Run generates from this template)
- **Spec alignment** — `constitution-management/spec.md` lists retained sections; should be updated to mention Standard Tasks for completeness
- **Re-run mode** — Re-run (Steps 7–9) doesn't regenerate the constitution, so existing projects without the section won't get it automatically. This is acceptable — the section can be added manually or via a design-phase constitution update.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add one section to the bootstrap template in SKILL.md |
| Behavior | Clear | Empty section with explanatory comment, filled by user |
| Data Model | Clear | No data model changes |
| UX | Clear | Section visible in generated constitution, comment explains usage |
| Integration | Clear | Schema task instruction already reads this section from constitution |
| Edge Cases | Clear | Bootstrap on empty project still gets the section; re-run doesn't touch it |
| Constraints | Clear | No redundancy — section is project-specific, not schema-defined |
| Terminology | Clear | "Standard Tasks" is established terminology from #12 |
| Non-Functional | Clear | No performance or security implications |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Add `## Standard Tasks` to SKILL.md template | Direct fix, minimal scope, matches issue request | Auto-detection (rejected: over-engineered) |
| 2 | Update constitution-management spec to list Standard Tasks as a retained section | Keeps spec accurate and complete | Skip spec update (rejected: creates spec drift) |
