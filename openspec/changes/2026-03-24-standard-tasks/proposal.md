## Why

Post-implementation workflow steps (archive, changelog, docs, push, plugin update) are defined as prose in the constitution's Conventions section. They are not tracked as checkboxes, forgettable in long sessions, and leave no audit trail of whether all steps were performed. Making them explicit, checkable tasks in every `tasks.md` solves all three problems.

## What Changes

- Add `## Standard Tasks` section to the constitution with literal checkbox items that get copied verbatim into every generated `tasks.md`
- Update the schema's task instruction to direct agents to include constitution-defined standard tasks as a final section after the QA Loop
- Update the schema's apply instruction to clarify that standard tasks are not part of the apply phase
- Add a section 4 placeholder to the tasks template
- Trim the post-archive convention prose (next-steps workflow now covered by standard tasks)

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `task-implementation`: Add requirement that standard tasks (post-implementation section) are excluded from apply scope. Apply processes only implementation and QA sections; standard tasks are tracked for auditability but executed separately after apply completes.
- `artifact-pipeline`: Add requirement that the task instruction includes a standard tasks directive — if the constitution defines `## Standard Tasks`, they are copied verbatim as a final numbered section after the QA Loop.

### Consolidation Check

**Existing specs reviewed:** task-implementation, artifact-pipeline, release-workflow, human-approval-gate, quality-gates, change-workspace, constitution-management, artifact-generation

**Overlap assessment:**
- No new capabilities proposed — N/A for new capability overlap.
- `task-implementation` is the correct home for apply-scope changes (it already governs task checkbox processing and baseline spec exclusion).
- `artifact-pipeline` is the correct home for task generation rules (it already governs "Schema Owns Workflow Rules" including what the tasks instruction contains).
- `release-workflow` was considered but its focus is post-archive version bumps and changelog generation — not task list structure. The constitution convention prose trimming is an implementation detail, not a spec-level change.
- `constitution-management` was considered but its focus is constitution lifecycle (bootstrap, updates). Adding a new section to the constitution is a project-level change, not a spec-level one.

**Merge assessment:** N/A — no new capabilities proposed.

## Impact

- **Constitution:** New `## Standard Tasks` section; trimmed post-archive convention prose
- **Schema:** Task instruction gains standard tasks directive; apply instruction gains scope clarification
- **Template:** New section 4 placeholder in `templates/tasks.md`
- **Skills:** No changes (skill immutability respected)
- **Existing archived changes:** Unaffected (historical records)
- **Future task lists:** All new `tasks.md` files will include standard tasks section

## Scope & Boundaries

**In scope:**
- Constitution `## Standard Tasks` section with literal checkbox items
- Schema task instruction update (standard tasks directive)
- Schema apply instruction update (scope clarification)
- Tasks template section 4 placeholder
- Post-archive convention prose trimming

**Out of scope:**
- Machine-readable task format (config.yaml `standardTasks` key) — overkill for current need
- Section-aware progress counting in apply — standard tasks counted in totals is desirable
- Consolidated Definition of Done checklist (#36) — separate, larger scope
- Auto GitHub Releases (#39) — separate concern
- Skill file modifications — prohibited by skill immutability rule
