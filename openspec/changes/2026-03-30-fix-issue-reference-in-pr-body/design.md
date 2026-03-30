# Technical Design: Fix Issue Reference in PR Body

## Context

The constitution's pre-merge standard task updates the PR body with `gh pr edit --body "..."`, completely overwriting the initial content. With squash merges, GitHub only parses issue-closing keywords (`Closes #X`) from the PR body — not from individual commit messages. If the updated body doesn't include these keywords, linked issues stay open after merge.

## Architecture & Components

Single file affected: `openspec/CONSTITUTION.md` — pre-merge standard task wording.

Current wording:
```
- [ ] Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
```

New wording:
```
- [ ] Update PR: mark ready for review, update body with change summary and issue references (`gh pr ready && gh pr edit --body "... Closes #X"`)
```

## Goals & Success Metrics

- Constitution text explicitly mentions including issue references in PR body — PASS/FAIL
- Spec scenario covers the issue-closing keyword requirement — PASS/FAIL

## Non-Goals

- Automating issue detection (agent already knows issue context from conversation)
- Modifying the `post_artifact` hook
- Changing merge strategy

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Update constitution wording only | Convention-based; consistent with existing enforcement model | Add to post_artifact hook (gets overwritten), add to skills (violates immutability) |

## Risks & Trade-offs

- [Risk] Agent forgets to include `Closes #X` → Same enforcement model as all other conventions; mitigated by explicit wording

## Open Questions

No open questions.

## Assumptions

No assumptions made.
