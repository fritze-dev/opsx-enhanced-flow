## Why

The opsx-enhanced workflow currently ends with "commit and push" — there is no automated PR creation or management. Teams using GitHub for code review need a pull request to review changes. Creating a draft PR early (at proposal time) enables team visibility and review before implementation begins, while finalizing the PR after implementation completes the review cycle.

## What Changes

- Extend the proposal artifact instruction in `schema.yaml` to include branch creation and draft PR after writing `proposal.md`
- Add a `## Pull Request` section to the proposal template for storing PR metadata
- Add a "Update PR" standard task to the constitution for marking the PR ready-for-review after implementation
- Update the `apply.instruction` post-apply workflow sequence to include the PR update step
- Add graceful degradation when `gh` CLI is unavailable

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `artifact-pipeline`: The proposal instruction gains PR creation steps (branch, commit, draft PR). The apply.instruction post-apply sequence gains a "update PR" step. A new requirement covers the PR creation behavior during proposal and PR finalization during post-apply.
- `task-implementation`: The standard tasks scope documentation is updated to reflect that constitution-defined extras (like PR update) appear after universal steps and are marked during post-apply workflow.

### Consolidation Check

1. Existing specs reviewed: artifact-pipeline, task-implementation, artifact-generation, change-workspace, release-workflow, constitution-management, quality-gates, human-approval-gate, spec-sync
2. Overlap assessment:
   - No new capabilities proposed. PR workflow behavior fits as a modification to `artifact-pipeline` (proposal instruction + apply.instruction) and `task-implementation` (standard task handling).
   - `release-workflow` covers version bumps and changelog — not PR management. Distinct domain.
   - `change-workspace` covers workspace creation/archiving — not git branching or PRs. Distinct domain.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- `openspec/schemas/opsx-enhanced/schema.yaml` — proposal `instruction` field, `apply.instruction` field
- `openspec/schemas/opsx-enhanced/templates/proposal.md` — new `## Pull Request` section
- `openspec/constitution.md` — new standard task entry
- Optional dependency on `gh` CLI (GitHub CLI) — not required, graceful degradation

## Scope & Boundaries

**In scope:**
- Draft PR creation as part of proposal step (branch + commit + PR)
- PR metadata section in proposal.md
- Standard task for PR finalization (mark ready, update body)
- Graceful degradation when `gh` is unavailable
- Spec updates to document the new behavior

**Out of scope:**
- Reviewer assignment or PR labels
- PR merge automation
- Branch protection rules or CI integration
- Multi-PR workflows or stacked PRs
- Changes to the pipeline stage count (stays at 6)
