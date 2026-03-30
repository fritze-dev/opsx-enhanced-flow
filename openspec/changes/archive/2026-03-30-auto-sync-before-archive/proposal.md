## Why

The `/opsx:archive` skill prompts users to choose between "Sync now (recommended)" and "Archive without syncing" every time delta specs exist. This prompt adds friction without value — the workflow is linear and syncing before archive is always the correct choice. Nobody should archive without syncing.

## What Changes

- Remove the sync/archive prompt from `/opsx:archive` Step 4
- Auto-sync delta specs when they exist (no user interaction needed)
- Keep the sync summary output so the user sees what was applied
- Update the spec scenario and capability doc to reflect the new behavior

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-workspace`: The "Archive Completed Change" requirement changes — the sync prompt is replaced by automatic sync behavior. The "Prompt for sync before archiving" scenario is replaced by an "Auto-sync before archiving" scenario.

### Consolidation Check

N/A — no new specs proposed. Existing `change-workspace` spec already owns the archive behavior including the sync prompt. This is a modification to that existing requirement.

## Impact

- `src/skills/archive/SKILL.md` — Step 4 rewritten to auto-sync instead of prompting
- `openspec/specs/change-workspace/spec.md` — Scenario updated
- `docs/capabilities/change-workspace.md` — Documentation updated

## Scope & Boundaries

**In scope:**
- Removing the sync prompt from archive
- Auto-syncing delta specs during archive
- Updating spec and docs to match

**Out of scope:**
- Changes to `/opsx:sync` itself (stays the same)
- Changes to any other prompts in `/opsx:archive` (incomplete artifacts/tasks warnings stay)
- The "already synced" case behavior (when no changes needed, sync is a no-op)
