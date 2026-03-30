# Technical Design: Fix Archive Unstaged Deletions

## Context

The archive skill's step 5 uses `mv` to move the change directory to the archive. The subsequent commit stages the new archive path but not the old path deletions, leaving a dirty working tree. This is standard Git behavior — `mv` is a filesystem operation, not a Git operation.

## Architecture & Components

**Single file affected:** `src/skills/archive/SKILL.md` — step 5

Add one line after the `mv` command: `git add openspec/changes/<name>/` to stage the deletions. This follows the existing pattern in the skill where `git add` is used to stage specific paths.

## Goals & Success Metrics

* **Clean working tree**: After the archive commit, `git status` shows no unstaged changes related to the old change directory path — PASS/FAIL by running `git status` after archive.

## Non-Goals

- Switching to `git mv` (fails on untracked files and complex path transformations)
- Changing the commit strategy (single commit for archive is fine)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Add explicit `git add` for old path after mv | Simple, explicit, works regardless of file tracking state. Consistent with existing `git add` patterns in the skill. | Use `git mv` (atomic but fails on untracked files); use `git add -A` (too broad, could stage unrelated changes) |

## Risks & Trade-offs

- **[Minimal risk]**: The `git add` on a deleted path records deletions. If the path doesn't exist (already moved), Git handles this gracefully — it stages the deletions it finds in the index.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
