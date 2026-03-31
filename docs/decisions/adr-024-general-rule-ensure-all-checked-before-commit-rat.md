# ADR-024: General Rule for Marking Standard Tasks Before Commit

## Status

Accepted (2026-03-25)

## Context

The post-apply workflow runs: `/opsx:archive` then `/opsx:changelog` then `/opsx:docs` then commit. Each step corresponds to a standard task checkbox (4.1-4.4) in `tasks.md`. The `apply.instruction` in `schema.yaml` did not instruct the agent to mark these checkboxes before committing. As a result, agents marked them after the commit, causing the committed `tasks.md` to show standard tasks as unchecked. This required an extra follow-up commit just for the checkbox updates, adding friction to every post-apply workflow.

## Decision

**Use a general rule ("ensure all standard tasks are checked before commit") rather than per-step marking** -- simpler, less prescriptive; the agent decides exact timing. This is accurate because all post-apply steps have completed by the time the commit happens. The alternative (mark each step individually as it completes) was more verbose and over-prescriptive.

## Alternatives Considered

- Per-step mark-as-you-go (more verbose, over-prescriptive for the agent)

## Consequences

### Positive

- Committed `tasks.md` reflects the fully-checked state, eliminating the extra follow-up commit
- Simple directive that is easy for agents to follow
- Testable via `/opsx:verify` and spec scenarios

### Negative

- If a post-apply step fails before commit, the agent must be careful to only mark completed steps. However, this is natural behavior -- the agent will not commit if a step fails.

## References

- [Change: fix-standard-tasks-commit-order](../../openspec/changes/2026-03-25-fix-standard-tasks-commit-order/)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [ADR-018: Standard Tasks Two-Layer Design](adr-018-standard-tasks-two-layer-design.md)
