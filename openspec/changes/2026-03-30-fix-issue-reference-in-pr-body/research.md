# Research: Fix Issue Reference in PR Body

## 1. Current State

Two places interact with the PR body:

1. **`post_artifact` hook** (WORKFLOW.md line 42): Creates the initial draft PR with `gh pr create --draft --title "<Change Name>" --body "WIP: <change-name>"`. This is where `Closes #X` could be added initially but currently isn't.

2. **Constitution pre-merge standard task** (CONSTITUTION.md line 49): `gh pr ready && gh pr edit --body "..."` — completely overwrites the PR body with a change summary. Any `Closes #X` from the initial body is lost.

GitHub only auto-closes issues from PR body/title keywords during squash merges — commit message keywords are discarded during squash.

## 2. External Research

- GitHub keyword syntax: `Closes #X`, `Fixes #X`, `Resolves #X` (case-insensitive)
- GitHub processes these keywords in PR body and PR title when the PR is merged
- For squash merges, individual commit messages are not parsed for issue keywords

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Add `Closes #X` to initial PR body in `post_artifact` | Early linkage | Agent doesn't always know the issue number at first artifact; gets overwritten by standard task anyway |
| B: Constitution standard task must include issue references when updating PR body | Fixes the root cause; agent knows issue context by post-apply | Text-based convention, relies on agent compliance |
| C: Append `Closes #X` as footer in PR body template | Structural guarantee | Need a pattern the agent follows consistently |

**Recommended: Approach B+C combined.** Update the constitution pre-merge task wording to explicitly require preserving/including issue references (e.g., `Closes #X`) in the updated PR body. This is where the body gets its final content anyway.

## 4. Risks & Constraints

- **Agent compliance:** Text-based instruction — same enforcement model as all other conventions.
- **No issue linked:** Some changes don't originate from GitHub issues. The convention should say "if applicable."
- **Blast radius:** Constitution text only — no skill or template changes needed.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Constitution pre-merge standard task wording |
| Behavior | Clear | Include `Closes #X` in PR body when updating |
| Data Model | Clear | No data model changes |
| UX | Clear | No user-facing changes |
| Integration | Clear | GitHub keyword auto-close |
| Edge Cases | Clear | No issue linked, multiple issues |
| Constraints | Clear | No breaking changes |
| Terminology | Clear | Standard GitHub keywords |
| Non-Functional | Clear | No performance impact |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Update constitution pre-merge task to require issue references in PR body | This is where the final PR body is written; agent has full context at this point | Add to post_artifact hook (too early, gets overwritten) |
