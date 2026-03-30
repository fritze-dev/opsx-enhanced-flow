# Research: Fix Archive Unstaged Deletions

## 1. Current State

The archive skill ([SKILL.md:77](src/skills/archive/SKILL.md#L77)) uses plain `mv` to move the change directory to the archive:

```bash
mv openspec/changes/<name> openspec/changes/archive/YYYY-MM-DD-<name>
```

Git does not track `mv` — it sees file deletions at the old path and new files at the new path. The post-archive commit only stages the new archive path (`git add openspec/changes/archive/...`), leaving the old path deletions unstaged. This results in a dirty working tree after the archive commit.

**Affected files:**
- `src/skills/archive/SKILL.md` — step 5 (perform the archive), line 77

## 2. External Research

N/A — standard Git behavior.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A. Stage the old path after mv** — Add `git add openspec/changes/<name>/` after the `mv` to record deletions | Minimal change; explicit about what happens. | Two git add commands needed. |
| **B. Use `git mv`** — Replace `mv` with `git mv` which stages both sides atomically | Single command handles move + staging. Git recognizes it as a rename. | `git mv` requires both paths to be tracked; if files are untracked it fails. Also moves to a different directory structure (archive with date prefix) which may confuse `git mv`. |

**Recommended**: Approach A. It's simpler, more explicit, and works regardless of tracking state. The skill already has a `git add` step in post-artifact — adding one more `git add` for the old path is consistent.

## 4. Risks & Constraints

- **Low risk**: Single line addition to the archive skill.
- **No breaking changes**: Behavior is additive — previously unstaged deletions will now be staged.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add git staging for old path after mv |
| Behavior | Clear | Deletions must be staged alongside new archive files |
| Data Model | Clear | No changes |
| UX | Clear | No user-facing change — working tree will be clean after commit |
| Integration | Clear | Consistent with existing git add patterns in the skill |
| Edge Cases | Clear | Empty change directory, already-committed vs uncommitted files |
| Constraints | Clear | Skill immutability allows bug fixes |
| Terminology | Clear | No new terms |
| Non-Functional | Clear | No performance impact |

All categories Clear.

## 6. Open Questions

None.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Stage old path explicitly after mv | Simple, explicit, works regardless of tracking state. Consistent with existing git add pattern in the skill. | Use `git mv` (atomic but fails on untracked files and complex path transformations) |
