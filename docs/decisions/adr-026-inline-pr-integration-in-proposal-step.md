# ADR-026: Inline PR Integration in Proposal Step

## Status

Superseded by [ADR-028](adr-028-post-artifact-commit-and-pr-integration.md) (2026-03-25)

## Context

The opsx-enhanced workflow lacked git branching and PR integration. Teams using GitHub need draft PRs for early visibility and review before implementation begins. The pipeline currently ends with "commit and push" after implementation, with no automated PR creation or management. Several approaches were considered: adding a new `pr-draft` artifact to the pipeline (which would break the 6-stage pipeline structure), creating a standalone `/opsx:pr` skill (not enforced by the pipeline), or inlining PR creation within the existing proposal step. The user expressed a clear preference for simplicity -- keeping the 6-stage pipeline intact while adding PR creation as part of the proposal workflow. PR finalization (marking the draft PR as ready for review) fits the constitution's standard tasks pattern, where project-specific post-implementation steps are tracked as checkboxes.

## Decision

1. **Inline PR creation in the proposal instruction, not as a new artifact** -- user preference for simplicity; preserves the 6-stage pipeline; no schema structural change. Alternatives: a new `pr-draft` artifact (rejected: heavier, changes pipeline structure) or a standalone skill (rejected: not enforced by the pipeline).
2. **Create the PR after proposal, not after research** -- proposal content (Why, What Changes, Impact) provides a meaningful PR body. After research alone, the PR body would be empty or insufficient.
3. **Use a constitution standard task for PR finalization** -- fits the existing pattern of project-specific post-implementation steps tracked in tasks.md. Not all projects use GitHub, so this should not be a universal template step. Alternatives: a universal template step (rejected: not all consumers use PRs) or a separate skill (rejected: not tracked in tasks.md).
4. **Execute constitution extras during post-apply workflow** -- makes constitution-defined standard tasks actionable rather than just documentation. Pre-merge extras (like updating a PR) are executed automatically; post-merge extras remain unchecked. Alternative: leave all extras unchecked (rejected: defeats the purpose of having executable standard tasks).
5. **Graceful degradation when `gh` CLI is unavailable** -- prevents blocking the pipeline on an external tool dependency. The branch is created and pushed, but PR creation is skipped with a note in `proposal.md`. Alternative: hard requirement on `gh` (rejected: limits portability).

## Alternatives Considered

- New `pr-draft` artifact (heavier, changes pipeline stage count, breaks 6-stage structure)
- Standalone `/opsx:pr` skill (not enforced by pipeline, user could forget)
- PR creation after research (insufficient content for PR body)
- Standard task only / post-apply PR creation (too late for early team visibility)
- Universal template step for PR finalization (not all projects use GitHub)
- Hard requirement on `gh` CLI (limits portability across environments)

## Consequences

### Positive

- Draft PRs provide early team visibility and enable review before implementation begins
- Pipeline structure (6 stages) is preserved with no schema structural changes
- Graceful degradation ensures non-GitHub projects continue to work
- Constitution standard task pattern is reused for PR finalization, maintaining consistency
- Pre-merge constitution extras are now executed automatically during post-apply, making them actionable

### Negative

- PR creation is a side effect of the proposal step, not independently trackable as a pipeline artifact
- Constitution extras execution is a behavior change: existing constitution extras (e.g., "Update plugin locally") that were previously manual-only are now auto-executed during post-apply
- Depends on `gh` CLI for full functionality; environments without it get a degraded experience (branch created but no PR)

## References

- [Change: add-pr-step](../../openspec/changes/2026-03-25-add-pr-step/)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [ADR-018: Standard Tasks Two-Layer Design](adr-018-standard-tasks-two-layer-design.md)
- [ADR-002: Workflow Rule Ownership](adr-002-workflow-rule-ownership.md)
