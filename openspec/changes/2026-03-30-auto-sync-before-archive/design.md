# Technical Design: Auto-Sync Before Archive

## Context

The `/opsx:archive` skill currently has a Step 4 that assesses delta spec sync state and prompts the user to choose between syncing and archiving. This prompt is unnecessary friction — the workflow is deterministic and syncing is always the correct action. The change removes the prompt and auto-syncs instead.

## Architecture & Components

Three files require changes:

1. **`src/skills/archive/SKILL.md`** — Step 4: Replace the prompt logic with automatic sync invocation. Keep the delta spec analysis and summary display. Remove `AskUserQuestion` usage for sync choice. The sync subagent invocation (Task tool) stays the same.

2. **`openspec/specs/change-workspace/spec.md`** — Update the "Archive Completed Change" requirement description and replace the "Prompt for sync before archiving" scenario with "Auto-sync before archiving". Applied via delta spec sync during this change's own archive.

3. **`docs/capabilities/change-workspace.md`** — Update the archive behavior description to reflect auto-sync instead of prompt. Applied via `/opsx:docs` post-archive.

## Goals & Success Metrics

* `/opsx:archive` with delta specs completes without any sync/archive prompt — PASS/FAIL
* Delta specs are synced to baseline automatically — PASS/FAIL
* Sync summary is displayed to the user — PASS/FAIL

## Non-Goals

- Changes to `/opsx:sync` itself
- Changes to incomplete artifact/task warnings (those prompts stay)
- Adding a "skip sync" flag or option

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Auto-sync with summary (no prompt) | Preserves transparency while removing friction | Silent sync (no summary — less transparent), keep prompt with different default |
| Keep sync summary output | User should see what was applied to baseline specs | Skip summary (faster but opaque) |

## Risks & Trade-offs

- **[No opt-out]** → Users can no longer archive without syncing. This is intentional — archiving without syncing was never a valid workflow step. If sync fails, archive is blocked (safe failure mode).

## Open Questions

No open questions.

## Assumptions

No assumptions made.
