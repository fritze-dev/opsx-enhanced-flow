# ADR-045: Auto-Approve Full Flow

## Status
Accepted (2026-04-10)

## Context
When `auto_approve: true` was introduced (ADR-043), it only affected individual checkpoint behavior within a single action -- preflight warnings auto-continued and post-apply PASS skipped the user testing pause. However, the pipeline still paused at three additional points: the design review checkpoint during propose, the transition from propose to apply, and the transition from apply to finalize. This meant users had to intervene 3-4 times for routine changes where no genuine review was needed. The `auto_approve` flag should mean "run the full pipeline end-to-end, only stopping for real blockers (FAIL, BLOCKED, WARNING)." Achieving this required changes at the router level (cross-action dispatch), in the propose instruction (design checkpoint skip), and in the apply instruction (user testing gate bypass).

## Decision
Implement auto-dispatch in the router SKILL.md rather than only in action instructions -- instructions control sub-agent behavior within a single action, but chaining across actions (propose to apply to finalize) requires router-level logic that executes after a sub-agent returns. Auto-approve only triggers on a clean PASS verdict with no CRITICAL and no WARNING issues -- warnings may indicate genuine issues worth reviewing, so PASS WITH WARNINGS still pauses for human acknowledgment. Keep the design review checkpoint as the default pause point when `auto_approve` is false -- design review is the highest-value checkpoint where user alignment prevents wasted implementation effort, making it opt-out rather than opt-in.

## Alternatives Considered
- **Instruction-only approach (no router changes)**: Would work for intra-action checkpoints but cannot chain across actions -- a sub-agent finishing propose has no mechanism to invoke apply.
- **Auto-approve on PASS WITH WARNINGS too**: Would reduce pauses further but risks finalizing changes with genuine issues the user should review. The conservative approach (PASS only) is safer and can be relaxed later if needed.
- **Remove design checkpoint entirely**: Would simplify the flow but removes the highest-value feedback point. Users who want no pauses already get that with `auto_approve: true`; users who want pauses benefit most from the design checkpoint.

## Consequences

### Positive
- `auto_approve: true` now delivers on its promise: a single `/opsx:workflow propose` command runs the entire pipeline through finalize without intervention on success paths
- Routine changes that pass all quality gates complete in one unattended run
- FAIL/BLOCKED/WARNING paths still stop, preserving all safety nets
- No breaking changes -- `auto_approve: false` behavior is unchanged

### Negative
- Users who want auto-approve but also want to pause between propose and apply lose that granularity (all-or-nothing)
- Router logic is more complex with conditional dispatch after sub-agent completion
- If review.md generation has a false-positive PASS, the pipeline will auto-finalize without human review

## References
- Change: openspec/changes/2026-04-10-auto-approve-full-flow/
- Specs: openspec/specs/workflow-contract/spec.md, openspec/specs/human-approval-gate/spec.md
- Issue: #105
