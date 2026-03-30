# Research: Verify Preflight Side-Effect Cross-Check

## 1. Current State

**Verify skill** ([skills/verify/SKILL.md](skills/verify/SKILL.md)):
- Checks three dimensions: Completeness, Correctness, Coherence
- Loads: `research.md`, `proposal.md`, `specs/*/spec.md`, `design.md`, `tasks.md`
- Does **not** read `preflight.md` at all
- Completeness checks task checkboxes and requirement keyword search
- Correctness maps requirements to code and checks scenario coverage
- Coherence checks design adherence and code pattern consistency

**Preflight template** ([openspec/templates/preflight.md](openspec/templates/preflight.md)):
- Section C = Side-Effect Analysis: assesses impact on existing systems and regression risks
- Outputs a table of risks (regression, breaking workflows, schema changes, constitution changes) with assessments
- Other sections: Traceability (A), Gap Analysis (B), Constitution Check (D), Duplication (E), Assumption Audit (F), Review Marker Audit (G)

**Quality-gates spec** ([openspec/specs/quality-gates/spec.md](openspec/specs/quality-gates/spec.md)):
- Defines preflight and verify as separate gates (pre- and post-implementation)
- Verify spec mentions only three dimensions; no mention of preflight cross-check
- Side-effects are expected to flow into tasks.md — but this is implicit, not enforced

**The gap**: If a side-effect is documented in preflight Section C but never captured as a task in tasks.md, verify will not catch it. The side-effect silently falls through.

## 2. External Research

N/A — this is an internal workflow enhancement with no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A. Add preflight.md to verify's artifact loading** — parse Section C, cross-check each side-effect against tasks.md and/or codebase | Directly closes the gap; keeps verify as the single post-implementation gate; low complexity | Adds one more file read and a parsing step to verify |
| **B. Enforce side-effects → tasks at preflight/tasks boundary** — make the tasks template require that every Section C item appears as a task | Catches the gap earlier (before implementation); no verify changes needed | Changes the tasks template contract; doesn't help if someone manually edits tasks.md; doesn't catch side-effects addressed in code but not as tasks |
| **C. Both A + B** — enforce at tasks creation AND verify after implementation | Defense in depth | More changes; may feel redundant for simple changes |

**Recommended: Approach A** — add to verify only. This is the lightest touch and matches the issue request. The tasks template already implicitly covers this; verify is the right place for a safety net.

## 4. Risks & Constraints

- **Parsing heuristic**: Preflight Section C is free-form markdown (table or list). Parsing needs to be flexible enough to handle different formats.
- **False positives**: A side-effect might be addressed in code without appearing as a named task. The keyword heuristic approach (already used by verify) should handle this — search codebase for side-effect keywords.
- **Always present**: preflight.md is a mandatory pipeline artifact (required before tasks). Verify can assume it exists — no graceful-skip logic needed for the side-effect check.
- **Low severity default**: Consistent with verify's heuristic philosophy, unmatched side-effects should default to WARNING (not CRITICAL) since the keyword search isn't perfect.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add Section C cross-check to verify; optional if preflight.md absent |
| Behavior | Clear | Parse side-effects from preflight.md Section C, check against tasks.md + codebase |
| Data Model | Clear | No data model changes — preflight.md is read-only, no new artifacts |
| UX | Clear | New section in verify report output, consistent with existing format |
| Integration | Clear | Fits into existing verify step 3 (load artifacts) and adds a sub-step |
| Edge Cases | Clear | Empty Section C (no risks) → skip; side-effect in code but not task → pass |
| Constraints | Clear | Must not break graceful degradation; must follow existing severity heuristics |
| Terminology | Clear | "Side-effect" is already defined in preflight template |
| Non-Functional | Clear | One additional file read; negligible performance impact |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Approach A: add preflight.md reading to verify only | Lightest touch, matches issue request, verify is the right safety-net location | B (enforce at tasks boundary), C (both) |
| 2 | Default severity: WARNING for unmatched side-effects | Consistent with verify's false-positive-avoidance philosophy | CRITICAL (too aggressive for heuristic search) |
| 3 | Always read preflight.md (no graceful skip) | preflight.md is mandatory in the pipeline — it's always present when verify runs | Graceful skip (unnecessary since artifact is guaranteed) |
