## Why

`/opsx:verify` checks Completeness, Correctness, and Coherence but does not read `preflight.md`. Side-effects documented in preflight Section C are only covered indirectly — they should appear as tasks in `tasks.md`. If a side-effect is never captured as a task, it silently falls through verification.

## What Changes

- Verify skill gains a new sub-step: read `preflight.md` Section C and cross-check each identified side-effect against `tasks.md` entries and/or codebase keyword evidence.
- Quality-gates spec gets an additional scenario covering the side-effect cross-check.
- Unmatched side-effects produce WARNING-level issues (consistent with verify's heuristic philosophy).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `quality-gates`: Add a requirement for verify to cross-check preflight Section C side-effects against tasks and implementation. Add scenarios for matched/unmatched side-effects and empty Section C.

### Consolidation Check

1. Existing specs reviewed: `quality-gates` (covers both preflight and verify), `artifact-pipeline`, `task-implementation`
2. Overlap assessment: This change extends the existing verify requirement in `quality-gates` — no new spec needed.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- **Files modified**: `skills/verify/SKILL.md`, `openspec/specs/quality-gates/spec.md`
- **No breaking changes**: preflight.md is always present when verify runs; adding it to the read set is additive.
- **No new dependencies**: uses existing keyword-search heuristics already in verify.

## Scope & Boundaries

**In scope:**
- Add `preflight.md` to verify's artifact loading (step 3)
- Add side-effect cross-check sub-step after existing dimensions
- Update quality-gates spec with new requirement and scenarios
- WARNING severity for unmatched side-effects

**Out of scope:**
- Changes to the preflight skill or template
- Enforcing side-effects → tasks at the tasks-creation boundary
- Changes to other verify dimensions (Completeness, Correctness, Coherence)
