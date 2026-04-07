# Research: Post-Merge Reminder Format

## 1. Current State

Post-merge tasks in the constitution use `- [ ]` checkbox format, identical to pre-merge tasks. This creates two problems:
1. They count toward progress totals (e.g., "23/24 tasks complete") even though they can't be completed until after the PR is merged
2. The spec requires special handling to "remain unchecked" — an awkward contract when the format invites checking

**Affected files:**
- `openspec/CONSTITUTION.md` — Post-Merge section uses `- [ ]`
- `openspec/specs/task-implementation/spec.md` — multiple references to post-merge tasks "remaining as `- [ ]`"
- `openspec/templates/tasks.md` — instruction says "Copy constitution items verbatim" (works automatically once constitution changes)

## 2. External Research

N/A — internal formatting decision.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Plain bullet `- ` for post-merge items | Visually distinct from actionable tasks; not counted in progress; no special handling needed | Minor breaking change to existing tasks.md format |
| Keep `- [ ]` but exclude from count | No format change | Requires parsing logic to distinguish pre/post-merge; spec already complex |

## 4. Risks & Constraints

- Template instruction "Copy constitution items verbatim" means the format change propagates automatically — no template edit needed.
- Existing completed changes with old-format tasks.md are immutable — no migration needed.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Constitution + task-implementation spec |
| Behavior | Clear | Plain bullets excluded from checkbox count by definition |
| Data Model | Clear | N/A |
| UX | Clear | Cleaner progress reporting |
| Integration | Clear | Template verbatim copy handles propagation |
| Edge Cases | Clear | Existing tasks.md files unaffected |
| Constraints | Clear | No code changes |
| Terminology | Clear | "reminder" vs "task" |
| Non-Functional | Clear | N/A |

## 6. Open Questions

All categories are Clear. No questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use plain bullet `- ` for post-merge items | Visually distinct, not counted in progress, no special handling | Keep `- [ ]` with counting exclusion (more complex) |
