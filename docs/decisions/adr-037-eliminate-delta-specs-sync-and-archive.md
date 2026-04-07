# ADR-037: Eliminate Delta-Specs, Sync & Archive

## Status

Accepted (2026-03-30)

## Context

The OpenSpec workflow used a three-step pattern for spec changes: create delta specs (ADDED/MODIFIED/REMOVED format) during the specs stage, sync them to baseline via an agent-driven merge step (`/opsx:sync`), and archive completed changes by moving them to a date-prefixed subdirectory (`/opsx:archive`). This created significant friction through three spec formats to understand (baseline, delta, merged), a non-deterministic sync step that caused race condition bugs (fixed in v1.0.36), and an unnecessary directory move operation. The project had accumulated 37 archived changes (2.7 MB), 108 delta spec files, and 19 baseline specs. Investigation showed that editing specs directly eliminates the delta format entirely, removes the sync step, and makes the archive move unnecessary since completed changes can be identified by their tasks.md status instead of their directory location.

## Decision

1. **Edit baseline specs directly during the specs stage** — eliminates delta format (3→1 formats), eliminates sync step, simplifies mental model
2. **Date prefix at creation time (not completion)** — name is stable from start, no rename needed, git branch name stays consistent
3. **Lazy worktree cleanup at `/opsx:new`** — cleanup happens organically, no extra skill or step needed, merged PRs detected via `gh pr view`
4. **Flat `openspec/changes/` directory (no `archive/` subdirectory)** — one glob path for all skills, no move operation, completion detected via tasks.md status
5. **Migrate existing 37 archives to flat structure** — clean break, single glob path, no legacy code paths in skills
6. **Changelog reads proposal + current main specs** — proposal has motivation and scope, main specs have current user stories and scenarios, together they cover what changelog needs
7. **Incremental docs detection via proposal Capabilities section** — proposal already lists affected capabilities, no new artifact needed
8. **Remove spec-sync capability spec entirely** — the entire domain (delta spec merging) is eliminated, no partial removal makes sense

## Alternatives Considered

- **Keep delta format with automated sync**: Still fragile sync step, three formats to maintain, incremental improvement only
- **Keep archive but eliminate delta specs**: Removes sync friction but still requires a move step and archive directory
- **Completion date for directory names**: Would require renaming directories, breaking links and branch names
- **Dedicated `/opsx:cleanup` skill for worktrees**: Extra step that contradicts the simplification goal
- **Keep archive subdirectory but skip move**: Still two conceptual locations for changes, complexity in every skill
- **Dual-path support for old and new directory structures**: More code, permanent complexity in every skill
- **Store a "change summary" file for changelog**: Extra artifact to maintain
- **Keep spec-sync as deprecated stub**: Misleading since the entire domain is gone

## Consequences

### Positive

- Workflow reduced from 10 steps (new → ff → apply → verify → sync → archive → changelog → docs) to 8 steps (new → ff → apply → verify → changelog → docs)
- Single spec format instead of three (baseline, delta, merged)
- No more non-deterministic agent-driven merge step with its race condition risks
- All skills use one glob path (`openspec/changes/*/`) instead of switching between `changes/` and `archive/`
- Completed changes identified by state (tasks.md status) rather than location (directory)

### Negative

- Git merge conflicts possible when two parallel changes edit the same baseline spec (mitigated by worktree isolation for local changes)
- Changelog quality for old changes relies on proposal.md + current specs instead of preserved delta specs (existing entries are preserved unchanged)
- Incremental docs detection depends on author-curated proposal Capabilities section (mitigated by manual `/opsx:docs <capability>` override and preflight traceability)

## References

- [Change: eliminate-delta-sync-archive](../../openspec/changes/2026-03-30-eliminate-delta-sync-archive/)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: quality-gates](../../openspec/specs/quality-gates/spec.md)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: interactive-discovery](../../openspec/specs/interactive-discovery/spec.md)
- [ADR-034: Auto-Sync Before Archive](adr-034-auto-sync-before-archive.md)
- [ADR-036: Fix Sync Race Condition in Archive](adr-036-fix-sync-race-condition-in-archive.md)
