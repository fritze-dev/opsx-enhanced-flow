## Why

The standard-tasks feature (#12) introduced a `## Standard Tasks` section in the constitution for project-specific post-implementation steps. However, the bootstrap template (First Run, Step 2) does not generate this section, so new projects don't know the feature exists or where to define project-specific steps.

## What Changes

- Add an empty `## Standard Tasks` section with an explanatory HTML comment to the bootstrap constitution template in `skills/bootstrap/SKILL.md`
- Update `constitution-management` spec to list Standard Tasks as a retained section

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `project-bootstrap`: Add `## Standard Tasks` section to the First Run constitution template
- `constitution-management`: Add Standard Tasks to the list of retained sections

### Consolidation Check

1. Existing specs reviewed: `project-bootstrap`, `constitution-management`, `task-implementation`, `artifact-pipeline`
2. Overlap assessment: `project-bootstrap` owns the First Run template — the template change belongs there. `constitution-management` defines retained sections — needs update for completeness.
3. Merge assessment: N/A — both are existing specs, no new capabilities proposed.

## Impact

- `skills/bootstrap/SKILL.md` — constitution template gains one additional section
- `openspec/specs/constitution-management/spec.md` — retained sections list updated
- No code changes, no breaking changes, no API impact

## Scope & Boundaries

**In scope:**
- Adding `## Standard Tasks` to the bootstrap template
- Updating the constitution-management spec to acknowledge the section

**Out of scope:**
- Backfilling the section into existing constitutions (manual or via re-run)
- Changing the standard-tasks schema/template behavior
- Modifying re-run mode (Steps 7–9)
