## Why

Standard task checkboxes (4.1-4.4) in `tasks.md` are marked complete *after* the commit, so the committed file shows them unchecked. This requires an extra follow-up commit just for the checkboxes, adding friction to every post-apply workflow.

## What Changes

- Update the `apply.instruction` in `schema.yaml` to add a general rule: before committing, ensure all standard tasks in tasks.md are marked complete — including the commit step itself.
- Add a spec scenario to `task-implementation` that defines this behavior: all standard task checkboxes must be checked before the commit.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `task-implementation`: Add a scenario specifying that all standard task checkboxes (including the commit step) must be marked complete in tasks.md before the commit.

### Consolidation Check

Existing specs reviewed: task-implementation, artifact-pipeline, quality-gates, human-approval-gate, change-workspace, artifact-generation, spec-sync, release-workflow.

N/A -- no new specs proposed. The marking-order behavior belongs in `task-implementation` (which already owns "Standard Tasks Exclusion from Apply Scope"). `artifact-pipeline` needs no change — its existing scenario ("apply instruction contains post-apply sequence") remains accurate without modification.

## Impact

- `openspec/schemas/opsx-enhanced/schema.yaml` — apply instruction text change
- `openspec/specs/task-implementation/spec.md` — new scenario addition

No CLI changes, no breaking changes, no external dependencies affected.

## Scope & Boundaries

**In scope:**
- Schema apply instruction reorder (mark-before-commit)
- Spec scenarios for the new behavior

**Out of scope:**
- Changing the post-apply step order itself (archive → changelog → docs → commit stays the same)
- Modifying any skill files (archive, changelog, docs skills are unchanged)
- Handling constitution extras (4.5+) — those remain unchecked unless the user marks them manually
