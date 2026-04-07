---
status: Accepted
date: 2026-04-07
---

# ADR-038: Commit Before Approval in apply.instruction

## Status

Accepted

## Context

After completing implementation and running `/opsx:verify`, the agent paused at the user testing step to ask for approval — but had not committed or pushed the changes. The user could not review a PR diff because no commit existed on the remote branch. This created friction every time the QA loop was reached. The project already had a `post_artifact` hook in WORKFLOW.md that commits after each planning artifact, establishing a pattern for WIP commits at workflow checkpoints.

## Decision

1. **Add commit instruction to WORKFLOW.md `apply.instruction` rather than the tasks template** — consistent with the `post_artifact` pattern where WORKFLOW.md owns commit behavior; the template stays clean and no renumbering is needed when steps change.
2. **Use `WIP: <change-name> — implementation` commit message format** — consistent with the `post_artifact` hook pattern (`WIP: <change-name> — <artifact-id>`); clearly marks the commit as non-final.
3. **Place commit step after verify, before user testing** — the user needs the diff to review; verify should pass before committing to avoid pushing broken code.

## Alternatives Considered

- Add as a template task step: visible in every tasks.md but couples the template to git concerns and requires renumbering whenever steps change.
- Use a generic "checkpoint" commit message: less informative than the structured format.
- Place commit before verify: would commit potentially broken code.
- Place commit after user testing: defeats the purpose since the user cannot review the diff.

## Consequences

### Positive

- PR diff is available for user review before the approval gate.
- Consistent with the existing `post_artifact` commit pattern — WORKFLOW.md owns all commit behavior.
- Tasks template stays clean — no git-specific steps, no renumbering needed for future changes.
- Graceful degradation: if push fails, local commit is created and the workflow continues.

### Negative

- Extra commit in git history per change. Acceptable because `post_artifact` already creates one commit per artifact — the implementation commit is one more checkpoint in the same pattern.
- `apply.instruction` is text-based guidance, not a hard enforcement mechanism. Consistent with all other enforcement in the system.

## References

- [Change: commit-before-approval](../../openspec/changes/2026-04-07-commit-before-approval/)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: human-approval-gate](../../openspec/specs/human-approval-gate/spec.md)
- [ADR-028: Post-artifact commit and PR integration](adr-028-post-artifact-commit-and-pr-integration.md)
