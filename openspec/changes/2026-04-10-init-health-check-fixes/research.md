# Research: Init Health Check Fixes

## 1. Current State

Three issues identified by `/opsx:workflow init` re-sync health check:

**A. Spec drift — three-layer-architecture**
- `openspec/specs/three-layer-architecture/spec.md` line 30: "define the 6-stage artifact pipeline" — actual pipeline is 7-stage (review added in prior change)
- Same file line 37: scenario lists "exactly 6 artifact IDs: research, proposal, specs, design, preflight, and tasks" — missing "review"
- All other sources (WORKFLOW.md, artifact-pipeline spec, capability docs) correctly say 7-stage

**B. Template upstream — tasks.md and specs/spec.md**
- `openspec/templates/tasks.md` has expanded Standard Tasks instruction (Pre-Merge/Post-Merge subsection handling, Section 5 for post-merge reminders) not yet in `src/templates/tasks.md`
- `openspec/templates/specs/spec.md` has an implementation-detail prohibition paragraph ("Specs describe behavior, not implementation...") not in `src/templates/specs/spec.md`
- Both local templates still at `template-version: 1` — need v2 bump in `src/templates/` to propagate to consumers

**C. WORKFLOW.md comment sync**
- `src/templates/workflow.md` lines 7-8 have custom action hint comments after `actions:` array
- `openspec/WORKFLOW.md` is missing these comments
- This is a documentation/discoverability gap — consumers who copy from the plugin template get the hints, but the project's own WORKFLOW.md lacks them

## 2. External Research

N/A — all changes are internal to the plugin, no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Fix all three items in one change | Minimal overhead, all are small fixups from same init report | Slightly broader scope |
| Separate changes per item | Cleaner git history | Overkill for trivial fixes, 3x the pipeline overhead |

**Selected:** Single change — all items are trivial corrections found in one health check run.

## 4. Risks & Constraints

- Template version bump (v1 → v2) will cause `init` to offer silent update on consumer projects whose templates haven't been customized. This is the intended behavior per the Template Merge on Re-Init spec.
- No breaking changes — only additive content and a number correction.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three specific file-level fixes |
| Behavior | Clear | No behavior changes — spec text correction + template upstream |
| Data Model | Clear | N/A |
| UX | Clear | N/A |
| Integration | Clear | Template merge on re-init handles consumer propagation |
| Edge Cases | Clear | Version bump edge cases handled by existing merge spec |
| Constraints | Clear | Must not break existing template customizations |
| Terminology | Clear | "7-stage" is already used everywhere except the one spec |
| Non-Functional | Clear | N/A |

## 6. Open Questions

All categories Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Bundle all three fixes in one change | All trivial, all from same init run | Separate changes (rejected: too much overhead) |
| 2 | Bump template-version to 2 for tasks.md and specs/spec.md | Signals content change to consumer init merge logic | Keep at v1 (rejected: would prevent propagation) |
