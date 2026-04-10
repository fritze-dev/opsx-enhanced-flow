# ADR-043: Auto-Approve as Default

## Status

Accepted (2026-04-10)

## Context

The `auto_approve` field in WORKFLOW.md controls whether the pipeline pauses at checkpoints (preflight warnings acknowledgment, post-apply PASS). It was commented out in both `openspec/WORKFLOW.md` and the consumer template at `src/templates/workflow.md`, making the effective default `false` -- the pipeline paused at every checkpoint. In practice, experienced users review changes via the PR diff rather than inline during pipeline execution, making the inline pauses redundant friction. The design review checkpoint after the design artifact is a constitutional requirement that operates independently of `auto_approve` and always pauses. FAIL verdicts always stop regardless of `auto_approve`, preserving the core safety net. The change needed to update both WORKFLOW.md and the consumer template to maintain consistency per the constitution's template synchronization rule.

## Decision

1. **Uncomment `auto_approve: true` in both WORKFLOW.md and the consumer template** -- Consistency between the project and consumers is required by the constitution's template sync rule. Updating only the project file would leave consumers with the old default, and updating only the template would leave the project still paused.

2. **Update spec default language rather than add new scenarios** -- The behavioral contract is the same: `auto_approve` still controls checkpoint pausing. Only the default value flips from `false` to `true`. Existing scenarios already cover both the `true` and `false` behaviors, so adding new scenarios for "absent defaults to true" would be redundant.

## Alternatives Considered

- Uncomment only in the project WORKFLOW.md -- rejected because it violates the constitution's template synchronization rule, leaving consumers with an inconsistent default
- Uncomment only in the consumer template -- rejected because the project itself would still have paused checkpoints
- Add new spec scenarios for "absent defaults to true" -- rejected because existing scenarios already cover the `true` and `false` behaviors; only the default value changes

## Consequences

### Positive

- Pipeline traversal proceeds without unnecessary pauses on success paths, reducing end-to-end friction for the common case
- Consumer projects get auto-approve by default on next init/update, matching the project's own behavior
- All safety nets are preserved: FAIL verdicts always stop, design review checkpoint is constitutional and independent
- Opt-out is trivial: setting `auto_approve: false` restores the previous pause-at-every-checkpoint behavior

### Negative

- Consumer behavior change: projects that run `init` will get auto-approve without explicit opt-in; users who relied on inline checkpoint pauses must explicitly opt out
- Users who previously depended on the default pause behavior may be surprised by the change; mitigated by FAIL always stopping and design checkpoint being constitutional

## References

- [Change: 2026-04-10-auto-approve-default](../../openspec/changes/2026-04-10-auto-approve-default/)
- [Spec: workflow-contract](../../openspec/specs/workflow-contract/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
