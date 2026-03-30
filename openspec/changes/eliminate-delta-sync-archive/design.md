# Technical Design: Eliminate Delta-Specs, Sync & Archive

## Context

The OpenSpec workflow currently uses a three-step pattern for spec changes: create delta specs (ADDED/MODIFIED/REMOVED format) → sync to baseline via agent-driven merge → archive to date-prefixed directory. This creates friction through three spec formats, a non-deterministic sync step (with recent race condition bugs in v1.0.36), and an unnecessary directory move. The project has 37 archived changes (2.7 MB), 108 delta spec files, and 19 baseline specs. This change simplifies the flow by editing specs directly, eliminating sync entirely, and replacing the archive directory with flat date-prefixed change directories.

## Architecture & Components

**Skills removed (2 files deleted):**
- `src/skills/sync/SKILL.md` — entire file removed
- `src/skills/archive/SKILL.md` — entire file removed

**Skills modified (8 files edited):**
- `src/skills/new/SKILL.md` — date-prefixed directory creation (`YYYY-MM-DD-<name>`), lazy worktree cleanup before creation
- `src/skills/ff/SKILL.md` — specs stage: edit `openspec/specs/<cap>/spec.md` directly instead of creating `openspec/changes/<name>/specs/<cap>/spec.md`; post-artifact hook stages `openspec/specs/` alongside change artifacts
- `src/skills/apply/SKILL.md` — read baseline specs for context; change detection uses date-prefixed dirs; allow spec edits during implementation
- `src/skills/verify/SKILL.md` — verify against baseline specs; remove sync/archive references from output
- `src/skills/changelog/SKILL.md` — glob `openspec/changes/*/` instead of `archive/*/`; filter by completed status (all tasks checked); read proposal + current baseline specs for content
- `src/skills/docs/SKILL.md` — incremental detection: scan `openspec/changes/*/proposal.md` Capabilities sections instead of `archive/*/specs/<cap>/`; enrichment reads from change dirs instead of archive dirs
- `src/skills/docs-verify/SKILL.md` — glob `openspec/changes/*/design.md` instead of `archive/*/design.md`
- `src/skills/preflight/SKILL.md` — traceability checks baseline specs directly; use git diff or proposal Capabilities for identifying what changed

**Templates modified (1 file):**
- `src/templates/specs/spec.md` — remove ADDED/MODIFIED/REMOVED/RENAMED section headers and instructions; replace with "edit baseline specs directly" instruction

**Specs modified/removed:**
- `openspec/specs/spec-sync/spec.md` — deleted (capability eliminated)
- 8 baseline specs updated via delta specs in this change

**Config modified:**
- `openspec/WORKFLOW.md` — remove sync/archive from post-apply sequence; update `post_artifact` to stage spec edits
- `openspec/CONSTITUTION.md` — remove delta-spec, archive, sync references from Architecture Rules

**Interaction flow:**

```
Before: new → ff (create deltas) → apply → verify → sync (merge) → archive (move) → changelog → docs
After:  new → ff (edit specs)    → apply → verify →                  changelog → docs
```

The key architectural change: specs are edited in place during the specs stage of ff. No intermediate representation (delta specs) and no merge step (sync). The change directory (`openspec/changes/YYYY-MM-DD-<name>/`) stores only planning artifacts (research, proposal, design, preflight, tasks), not spec copies.

## Goals & Success Metrics

* `/opsx:ff` edits `openspec/specs/<cap>/spec.md` directly — no files created under `openspec/changes/<name>/specs/` — PASS/FAIL: check no `specs/` subdirectory in change dir after ff
* `/opsx:sync` and `/opsx:archive` skills no longer exist — PASS/FAIL: files deleted from `src/skills/`
* `/opsx:changelog` generates entries from `openspec/changes/*/` (not `archive/`) — PASS/FAIL: run changelog, verify it finds completed changes
* `/opsx:docs` incremental detection uses proposal Capabilities — PASS/FAIL: run docs, verify correct capabilities are regenerated
* All 37 existing archives migrated from `archive/` to `changes/` — PASS/FAIL: `ls openspec/changes/archive/` returns empty or nonexistent
* `/opsx:new` creates `openspec/changes/YYYY-MM-DD-<name>/` — PASS/FAIL: verify directory name format
* Lazy worktree cleanup at `/opsx:new` detects merged branches — PASS/FAIL: create stale worktree, run new, verify cleanup

## Non-Goals

- Changing the 6-stage artifact pipeline structure (research → proposal → specs → design → preflight → tasks)
- Changing the Gherkin/BDD format within requirements
- Redesigning the three-layer architecture (constitution → workflow → skills)
- Changing the worktree feature beyond moving cleanup to `/opsx:new`
- Optimizing the docs/changelog generation algorithms (only data sources change)
- Changing how ADRs are generated from design.md Decisions tables

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Edit baseline specs directly during ff specs stage | Eliminates delta format (3→1 formats), eliminates sync step, simplifies mental model | Keep delta format with automated sync (still fragile), hybrid approach with direct edits + change tracking file |
| Date prefix at creation time (not completion) | Name is stable from start, no rename needed, git branch name consistent | Completion date (requires rename = another move step, breaks links) |
| Lazy worktree cleanup at `/opsx:new` | Cleanup happens organically, no extra skill/step, merged PRs detected via `gh pr view` | Dedicated `/opsx:cleanup` skill (extra step contradicts simplification goal), post-merge git hook (complex, platform-dependent) |
| Flat `openspec/changes/` directory (no `archive/` subdirectory) | One glob path for all skills, no move operation, completion detected via tasks.md status | Keep archive subdirectory but skip move (still two conceptual locations), tag-based approach (requires git archaeology) |
| Migrate existing 37 archives to flat structure | Clean break, single glob path, no legacy code paths in skills | Dual-path support forever (adds complexity to every skill), time-limited dual support (defers work) |
| Changelog reads proposal + current main specs | Proposal has motivation/scope, main specs have current user stories/scenarios — together they cover what changelog needs | Store a "change summary" in archive metadata (extra artifact to maintain), parse git diff (fragile) |
| Incremental detection via proposal Capabilities section | Proposal already lists affected capabilities — no new artifact needed | Add a `capabilities_affected.txt` file to change dirs (extra artifact), scan spec git history (slow) |
| Remove spec-sync capability spec entirely | The entire domain (delta spec merging) is eliminated — no partial removal makes sense | Keep as deprecated stub (misleading), rename to "spec-editing" (different concept) |

## Risks & Trade-offs

- [Risk: Changelog quality for old changes] The 37 migrated changes have delta specs but changelog now reads main specs. For already-documented changes this is irrelevant (entries exist). For undocumented old changes, proposal.md + current main specs provide sufficient context. → Mitigation: Existing changelog entries are preserved unchanged; only new entries use the new data source.

- [Risk: Incremental detection accuracy] Proposal Capabilities section is author-curated, not automatically derived. If a proposal omits a capability, docs won't regenerate for it. → Mitigation: `/opsx:docs <capability>` manual override always works; preflight traceability catches missing capability references.

- [Risk: Spec conflicts on shared branches] If two parallel changes edit the same baseline spec, git merge conflicts will occur. Previously, delta specs in separate change directories couldn't conflict. → Mitigation: Worktree isolation already prevents this for parallel local changes. For team scenarios, git merge conflict resolution applies (standard git workflow).

- [Risk: Self-referential change] This change uses the old workflow (delta specs + sync + archive) to eliminate that same workflow. If the change breaks something, the old workflow is still active for recovery. → Mitigation: This is the last change using the old workflow. After merge, new workflow applies.

## Migration Plan

**One-time migration (part of this change's implementation):**

1. Move all archived changes:
   ```bash
   mv openspec/changes/archive/* openspec/changes/
   rmdir openspec/changes/archive
   ```

2. Delete removed skill files:
   ```bash
   rm src/skills/sync/SKILL.md
   rm src/skills/archive/SKILL.md
   ```

3. Delete removed spec:
   ```bash
   rm -rf openspec/specs/spec-sync/
   ```

4. Update all modified skills, templates, specs, WORKFLOW.md, CONSTITUTION.md

5. Commit all changes as a single coherent commit

**Rollback:** Revert the merge commit. All old files are in git history.

## Open Questions

No open questions.

## Assumptions

- The 37 existing archived changes all have `proposal.md` files that list affected capabilities in their Capabilities section. <!-- ASSUMPTION: Proposal completeness in old archives -->
- Git merge conflict resolution for baseline specs is acceptable for this project's team size (single developer + AI). <!-- ASSUMPTION: Single-developer workflow -->
- The `gh pr view` command reliably returns PR merge status for lazy worktree cleanup. <!-- ASSUMPTION: gh CLI reliability -->
No further assumptions beyond those marked above.
