## Why

Draft PRs are created during the proposal artifact step, before the user has reviewed or approved the proposal content (Issue #51). Additionally, only the proposal step commits — all other artifacts remain uncommitted until post-apply. Moving to a schema-level `post_artifact` hook ensures every artifact is committed incrementally, with branch and draft PR created on the first commit.

## What Changes

- New `post_artifact` field in `schema.yaml` — commit+push after every artifact; create branch+PR on first commit
- `continue` skill reads and applies `post_artifact` after creating each artifact
- Proposal instruction loses PR creation block; replaced by the general `post_artifact` behavior
- `## Pull Request` section removed from proposal template (redundant — `gh pr view` derives PR from branch)
- Spec and ADR updated to reflect new approach
- **BREAKING**: Proposal artifacts will no longer contain a `## Pull Request` section

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `artifact-pipeline`: "Proposal PR Integration" requirement replaced by "Post-Artifact Commit and PR Integration" — commits happen after every artifact via schema-level `post_artifact` hook; branch+PR created on first commit; proposal instruction simplified
- `change-workspace`: No change needed — workspace creation stays as-is; branch creation moves to first artifact commit

### Consolidation Check

N/A — no new specs proposed. The modification targets `artifact-pipeline` which already owns PR integration behavior.

## Impact

- `openspec/schemas/opsx-enhanced/schema.yaml` — new `post_artifact` field; proposal instruction simplified
- `openspec/schemas/opsx-enhanced/templates/proposal.md` — `## Pull Request` section removed
- `skills/continue/SKILL.md` — reads and applies `post_artifact` from schema after each artifact
- `openspec/specs/artifact-pipeline/spec.md` — requirement rewritten
- `docs/decisions/adr-026-*.md` — superseded by new ADR

## Scope & Boundaries

**In scope:**
- Adding `post_artifact` schema field with commit+push+PR logic
- Updating continue skill to read and apply `post_artifact`
- Removing PR creation from proposal instruction
- Removing `## Pull Request` section from proposal template
- Updating specs and ADR

**Out of scope:**
- Changing `/opsx:new` skill (stays as-is)
- Changing PR finalization (constitution standard task stays as-is)
- Modifying `/opsx:ff` skill (follows same schema instructions as continue)
- Adding PR body update logic (PR body stays minimal WIP)
