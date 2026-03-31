# ADR-015: Smart Workflow Checkpoints

## Status

Accepted (2026-03-23)

## Context

The workflow had inconsistent pausing behavior across three dimensions. First, preflight warnings (PASS WITH WARNINGS verdicts) were auto-accepted without user review, causing issues to go unaddressed downstream. Second, `/opsx:continue` paused after every single artifact even when the next step was obvious and required no user decision, creating unnecessary friction. Third, `/opsx:sync` could run before `/opsx:verify`, modifying baseline specs before implementation was validated. These three problems shared a root cause: no defined checkpoint model distinguishing routine transitions from critical decision points. Research showed the workflow already had two enforcement mechanisms — hard gates via schema/CLI and soft gates via constitution conventions — but neither was applied systematically to all transitions.

## Decision

1. **Checkpoint model in skills** defining each transition as auto-continue or mandatory-pause. Auto-continue transitions (research→proposal, proposal→specs, specs→design, preflight PASS→tasks) proceed without user confirmation. Mandatory-pause transitions (after design for review, after preflight with warnings, discovery Q&A) require explicit user input.
2. **Auto-continue as default, mandatory-pause as exception** — only pause when user input is genuinely needed, reducing friction at obvious workflow steps.
3. **Verify-before-sync ordering** enforced in the apply instruction and constitution — `/opsx:verify` must run before `/opsx:sync` or `/opsx:archive` to prevent baseline spec modification before validation.
4. **Preflight warnings as mandatory pause** — PASS WITH WARNINGS requires explicit user acknowledgment of each warning before proceeding to task creation.

## Rationale

Reducing friction at routine transitions while increasing rigor at critical checkpoints. Auto-continue is the default because most transitions are obvious and don't benefit from a pause. Mandatory pauses are reserved for points where user judgment is needed — design alignment and warning acknowledgment. Verify-before-sync ensures baseline specs are only modified after implementation passes validation.

## Alternatives Considered

- Constitution-only approach — consistent with ADR-006 but agents may still ignore warnings without skill-level instructions
- Pause everywhere (status quo) — safe but creates unnecessary friction at every step
- Never pause — fast but unsafe, risks auto-accepting warnings and skipping reviews
- Hard gate in sync skill — would enforce ordering but violates skill immutability (ADR-006)
- Schema metadata for checkpoints — too rigid, schema should define artifacts not agent behavior

## Consequences

### Positive

- Reduced friction at routine transitions — `/opsx:continue` flows through obvious steps without stopping
- Preflight warnings can no longer be silently auto-accepted
- Verify-before-sync ordering prevents baseline spec modification before validation
- Clear, documented checkpoint model makes agent behavior predictable

### Negative

- Users accustomed to per-artifact pauses in `/opsx:continue` may be surprised by auto-continue behavior
- Text-based instructions in skills have no hard runtime enforcement — agents may still deviate

## References

- [Change: smart-workflow-checkpoints](../../openspec/changes/2026-03-23-smart-workflow-checkpoints/)
- [Spec: quality-gates](../../openspec/specs/quality-gates/spec.md)
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [ADR-006: Design Review Checkpoint](adr-006-design-review-checkpoint.md)
- [GitHub Issue #41](https://github.com/fritze-dev/opsx-enhanced-flow/issues/41)
- [GitHub Issue #16](https://github.com/fritze-dev/opsx-enhanced-flow/issues/16)
- [GitHub Issue #26](https://github.com/fritze-dev/opsx-enhanced-flow/issues/26)
- [GitHub Issue #40](https://github.com/fritze-dev/opsx-enhanced-flow/issues/40)
