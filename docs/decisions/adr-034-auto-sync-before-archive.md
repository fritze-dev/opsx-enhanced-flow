# ADR-034: Auto-Sync Before Archive

## Status

Accepted (2026-03-30)

## Context

The `/opsx:archive` skill previously prompted users to choose between "Sync now (recommended)" and "Archive without syncing" whenever delta specs existed. This prompt added friction without value — the post-apply workflow is linear and deterministic (verify → archive → changelog → docs), and syncing before archive is always the correct choice. No valid use case existed for archiving without syncing, as unsynced delta specs would leave baseline specs permanently outdated.

## Decision

1. **Auto-sync with summary instead of prompting** — when delta specs exist during archive, the system automatically invokes sync and displays a summary of applied changes, rather than asking the user to choose. Preserves transparency while removing unnecessary friction.
2. **Keep sync summary output visible** — the user should see what was applied to baseline specs during auto-sync. Omitting the summary would make the operation opaque.

## Alternatives Considered

- **Silent sync (no summary)**: Less transparent — users would not know what changed in baseline specs.
- **Keep prompt with different default**: Still adds an interaction step for a decision that has only one valid outcome.

## Consequences

### Positive

- Eliminates one unnecessary user prompt per archive cycle
- Baseline specs are always kept in sync — no risk of forgetting to sync
- Workflow is faster and more predictable

### Negative

- Users can no longer archive without syncing. This is intentional — archiving without syncing was never a valid workflow step. If sync fails, archive is blocked (safe failure mode).

## References

- [Change: auto-sync-before-archive](../../openspec/changes/2026-03-30-auto-sync-before-archive/)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [ADR-033: Worktree-Based Change Lifecycle](adr-033-worktree-based-change-lifecycle.md)
