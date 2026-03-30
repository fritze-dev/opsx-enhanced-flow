# Research: Fix Standard Tasks Commit Order

## 1. Current State

The post-apply workflow is defined in two places:

- **Schema instruction** (`openspec/schemas/opsx-enhanced/schema.yaml`, lines 239-242): States the sequence as `/opsx:verify -> /opsx:archive -> /opsx:changelog -> /opsx:docs -> commit` but says nothing about when to mark standard task checkboxes in `tasks.md`.
- **Tasks template** (`openspec/schemas/opsx-enhanced/templates/tasks.md`, lines 23-27): Defines section 4 with checkboxes 4.1 (archive), 4.2 (changelog), 4.3 (docs), 4.4 (commit and push).

The task-implementation spec (`openspec/specs/task-implementation/spec.md`) defines:
- "Standard Tasks Exclusion from Apply Scope" requirement: standard tasks are NOT executed by `/opsx:apply`, they remain unchecked after apply completes.
- No requirement specifies *when* or *how* standard tasks get marked during the post-apply workflow.

**The bug:** The schema's apply instruction tells the agent the post-apply sequence but never instructs it to mark the corresponding standard task checkboxes as it goes. In practice, agents mark them *after* committing, producing a commit where `tasks.md` still shows `- [ ]` for 4.1-4.4. An extra follow-up commit is needed just for the checkboxes.

Evidence: Archived tasks (e.g., `2026-03-25-bootstrap-standard-tasks-section/tasks.md`) show 4.1-4.4 as `[x]`, confirming they do get marked — just too late.

## 2. External Research

N/A — this is a workflow ordering issue internal to the schema instruction.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Mark-as-you-go** — Mark each standard task checkbox immediately after its step completes, 4.4 right before `git commit` | Per-step traceability | More verbose instruction; over-prescriptive |
| **B: Ensure-all-before-commit** — General rule: before committing, ensure all standard tasks (incl. the commit step itself) are marked complete in tasks.md | Simple, general, robust; agent decides the exact moment per step | Slightly less prescriptive about per-step timing |

**Recommended: Approach B** — a single general rule ("all standard tasks must be checked before commit, including the commit task") is simpler, less prescriptive, and covers edge cases naturally. By the time the agent commits, archive/changelog/docs have already run, so marking them is accurate.

## 4. Risks & Constraints

- **Low risk:** This is a text change to the schema instruction. No code, no CLI changes, no breaking changes.
- **Spec update needed:** The task-implementation spec's "Standard Tasks Exclusion from Apply Scope" requirement should gain a scenario that specifies standard tasks are marked *before* the commit, not after.
- **Backward compatibility:** Already-archived changes are unaffected. In-flight changes will pick up the new instruction on next apply.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Single instruction reorder in schema.yaml + spec scenario addition |
| Behavior | Clear | Mark checkboxes before commit, not after |
| Data Model | Clear | No data model changes — same tasks.md format |
| UX | Clear | Eliminates the extra "checkbox cleanup" commit |
| Integration | Clear | No CLI or tool changes needed |
| Edge Cases | Clear | Constitution extras (4.5+) remain unchecked if not executed; only 4.1-4.4 are marked by the post-apply sequence |
| Constraints | Clear | Must not change the post-apply step order itself, only when checkboxes are marked |
| Terminology | Clear | "Standard tasks" term is established |
| Non-Functional | Clear | No performance or security impact |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use ensure-all-before-commit (Approach B) | Simpler, general rule; agent marks all standard tasks (incl. commit step) before committing; accurate because all steps have already run by that point | Mark-as-you-go (more verbose, over-prescriptive) |
