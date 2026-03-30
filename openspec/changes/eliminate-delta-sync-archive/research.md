# Research: Eliminate Delta-Specs, Sync & Archive

## 1. Current State

The OpenSpec workflow uses a **three-layer spec modification pattern**:
1. **Delta specs** (`openspec/changes/<name>/specs/<cap>/spec.md`) — ADDED/MODIFIED/REMOVED format created during spec stage
2. **Sync** (`/opsx:sync`) — agent-driven merge of delta specs into baseline specs at `openspec/specs/`
3. **Archive** (`/opsx:archive`) — moves completed change to `openspec/changes/archive/YYYY-MM-DD-<name>/`

**Affected code & modules:**
- `src/skills/sync/SKILL.md` — 136 lines, agent-driven merging logic
- `src/skills/archive/SKILL.md` — 115 lines, auto-sync + move + worktree cleanup
- `src/templates/specs/spec.md` — defines delta format (ADDED/MODIFIED/REMOVED/RENAMED sections)
- `openspec/specs/change-workspace/spec.md` — 272 lines, defines workspace lifecycle including archive & sync requirements
- `openspec/specs/spec-sync/spec.md` — 95 lines, defines sync capability entirely
- `openspec/specs/artifact-pipeline/spec.md` — references sync/archive in post-apply workflow
- `openspec/WORKFLOW.md` — apply.instruction references verify → sync → archive sequence
- `openspec/CONSTITUTION.md` — references delta specs, archives, sync in Architecture Rules

**Downstream dependencies (skills reading archive):**
- `src/skills/changelog/SKILL.md` — globs `archive/*/`, reads proposal.md + specs from archives
- `src/skills/docs/SKILL.md` — globs `archive/*/`, reads proposal, research, design, preflight for enrichment + ADR generation; uses `archive/*/specs/<cap>/` for incremental detection
- `src/skills/docs-verify/SKILL.md` — globs `archive/*/design.md` for ADR verification

**Quantitative state:**
- 37 archived changes, 2.7 MB total archive (52% of working tree)
- 108 delta spec files across archives
- Recent sync-related fixes: v1.0.36 fixed background-sync-race-condition, PR #66 introduced auto-sync before archive

## 2. External Research

Not applicable — this is an internal workflow simplification. No external APIs, libraries, or reference implementations involved.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Edit main specs directly, eliminate sync entirely, replace archive with flat date-prefixed changes | One format, no sync, no move step, drastically simpler | Requires updating ~12 files, migration of 37 existing archives |
| B: Keep delta format but automate sync further | Preserves explicit change intent | Still 3 formats, still fragile sync, incremental improvement only |
| C: Keep archive but eliminate delta specs | Removes sync friction, keeps archive structure | Still requires move step, archive directory adds complexity |

**Selected: Approach A** — Maximum simplification. Eliminates 3 sources of friction (delta format, sync, archive move) in one coherent change.

## 4. Risks & Constraints

- **Self-referential change**: This change modifies the workflow it's being built with. The current change must follow the old workflow (delta specs + sync + archive). Future changes use the new workflow.
- **Backwards compatibility**: Changelog, docs, docs-verify skills must handle both old (`archive/YYYY-MM-DD-*`) and new (`changes/YYYY-MM-DD-*`) directory structures during migration.
- **Incremental detection**: Docs skill currently uses `archive/*/specs/<cap>/` directories for detecting which capabilities to regenerate. New mechanism needed (proposal.md Capabilities table + change date).
- **Squash merge dependency**: Archive was the only surviving copy of artifacts after squash merge. With flat changes, artifacts survive as committed files under `openspec/changes/YYYY-MM-DD-<name>/` — still committed to main, still survives squash merge.
- **Worktree cleanup**: Currently lives in archive skill. Must move to lazy cleanup at `/opsx:new`.
- **Skill immutability**: Skills in `src/skills/` are generic plugin code. Changes are permitted because we're modifying skill behavior, not adding project-specific logic.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three eliminations: delta-specs, sync, archive. Well-defined boundaries. |
| Behavior | Clear | All affected skills identified. Behavior changes documented per skill. |
| Data Model | Clear | Flat `changes/YYYY-MM-DD-<name>/` replaces `changes/<name>/` + `archive/YYYY-MM-DD-<name>/` |
| UX | Clear | Fewer commands, simpler mental model. `/opsx:sync` and `/opsx:archive` disappear. |
| Integration | Clear | Downstream skills (changelog, docs, docs-verify) update globs and data sources. |
| Edge Cases | Partial | Migration of 37 existing archives; backwards-compat period for old directory structure |
| Constraints | Clear | Skill immutability respected. Three-layer architecture maintained. |
| Terminology | Clear | "Archive" and "sync" terms removed from specs and workflow. |
| Non-Functional | Clear | Archive size reduction ~37%. No performance impact. |

## 6. Open Questions

| # | Question | Category | Impact |
|---|----------|----------|--------|
| 1 | Should old archives be migrated (moved from `archive/` to `changes/`) or should skills support both paths permanently? | Edge Cases | Medium |

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Migrate old archives: move `archive/*` to `changes/` in one commit | Clean break, single glob path for all skills, no legacy code | Dual-path support (more code, permanent complexity) |
| 2 | Use creation date in directory name (set at `/opsx:new` time) | No rename needed, name is stable from start | Completion date (requires rename = another move step) |
| 3 | Worktree cleanup via lazy detection at `/opsx:new` | Cleanup happens organically, no extra skill needed | Dedicated `/opsx:cleanup` skill (extra step), verify integration (wrong responsibility) |
| 4 | Keep tasks.md | Essential for `/opsx:apply` and session persistence, serves as active/complete signal | Remove tasks.md (loses session persistence, need alternative completion signal) |
