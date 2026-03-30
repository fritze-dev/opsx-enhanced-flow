## Why

The archive skill uses `mv` to move the change directory to the archive, but only stages the new archive path in Git. The old path deletions remain unstaged, leaving a dirty working tree after the archive commit. This was observed in #75.

## What Changes

- Add explicit `git add` for the old change directory path after the `mv` in the archive skill's step 5, so deletions are staged alongside the new archive files

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-workspace`: Add requirement that the archive step MUST stage both the new archive path and the old change directory deletions to ensure a clean working tree after commit.

### Consolidation Check

N/A — no new specs proposed. Reviewed `change-workspace` (covers archive behavior — correct target for this fix).

## Impact

- `src/skills/archive/SKILL.md` — step 5 (perform the archive)

## Scope & Boundaries

**In scope:**
- Add git staging for old path deletions after mv in archive skill

**Out of scope:**
- Switching to `git mv` (fails on untracked files and complex path transformations)
- Changes to other skills or the post-artifact hook
