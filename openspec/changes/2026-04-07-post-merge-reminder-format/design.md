# Technical Design: Post-Merge Reminder Format

## Context

Post-merge tasks in the constitution currently use `- [ ]` checkbox format. The task-implementation spec requires them to "remain unchecked as reminders." This creates unnecessary complexity — the apply skill must distinguish pre-merge (mark complete) from post-merge (leave unchecked), and progress counting includes items that can't be completed within the workflow.

## Architecture & Components

**Files to edit:**
1. `openspec/CONSTITUTION.md` — Change Post-Merge `- [ ]` to `- ` (1 item)
2. `openspec/specs/task-implementation/spec.md` — Update ~6 references to post-merge format
3. `openspec/templates/tasks.md` — Add clarification in instruction that post-merge items are plain bullets

## Goals & Success Metrics

- Constitution Post-Merge section uses `- ` not `- [ ]` — PASS if grep finds 0 checkboxes under Post-Merge
- task-implementation spec does not reference post-merge items as `- [ ]` — PASS if no "remain unchecked" or "remain as `- [ ]`" for post-merge

## Non-Goals

- Changing pre-merge task format
- Migrating existing completed changes' tasks.md files

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Plain bullet `- ` for post-merge | Not counted by checkbox parser; visually distinct; no special handling needed | Keep `- [ ]` with exclusion logic (more complex) |
| Template instruction clarification only | "Copy constitution items verbatim" already handles propagation; just add a note about the format distinction | Edit template body to add a post-merge section (over-prescriptive) |

## Risks & Trade-offs

- [Progress counts change] → Existing tasks.md files are immutable. Only new changes are affected. Progress totals will be lower (correct behavior).

## Open Questions

No open questions.

## Assumptions

No assumptions made.
