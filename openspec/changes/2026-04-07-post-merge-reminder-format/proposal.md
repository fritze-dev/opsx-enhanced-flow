## Why

Post-merge tasks use `- [ ]` checkbox format, making them count in progress totals and requiring special "remain unchecked" handling in the spec. Switching to plain bullets makes them visually distinct reminders that don't pollute progress tracking.

## What Changes

- Change constitution Post-Merge items from `- [ ]` to `- ` (plain bullet)
- Update task-implementation spec to reflect plain bullet format for post-merge reminders
- Update tasks template instruction to clarify post-merge items use plain bullet format

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `task-implementation`: Update post-merge task format from unchecked checkbox to plain bullet reminder

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed.

## Impact

- Constitution format change
- Spec text updates (no behavioral change to apply skill — plain bullets are already not parsed as tasks)
- Future tasks.md files will have plain bullets for post-merge items (via verbatim copy from constitution)

## Scope & Boundaries

**In scope:**
- Constitution Post-Merge section format
- task-implementation/spec.md references to post-merge format
- Tasks template instruction clarification

**Out of scope:**
- Pre-merge tasks (keep `- [ ]` checkbox format)
- Universal standard tasks in template body (keep `- [ ]`)
- Existing completed changes' tasks.md files
