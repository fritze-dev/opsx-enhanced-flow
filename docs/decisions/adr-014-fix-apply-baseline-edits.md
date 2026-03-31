# ADR-014: Exclude Baseline Specs from Implementation Scope

## Status

Accepted (2026-03-23)

## Context

During the `rename-init-to-setup` change, the AI agent directly edited baseline specs in `openspec/specs/` during the apply phase, even though delta specs had been created during the specs artifact phase. This dual-write pattern made the subsequent `/opsx:sync` step redundant — baseline specs were already modified in place. The intended data flow is that spec changes go through delta specs first, then get merged to baselines via `/opsx:sync` at archive time. Without an explicit exclusion rule, nothing prevented task generation from including baseline spec edits, and nothing prevented the apply skill from executing them. Three approaches were considered: instruction-only (single point of failure), instruction plus apply guardrail (defense in depth), and the full approach adding a formal spec requirement for traceability.

## Decision

1. **Extend the existing IMPORTANT block in schema.yaml** to also exclude baseline spec edits from generated tasks, co-locating all exclusion rules (sync, archive, baseline specs).
2. **Add a guardrail to the apply skill** that prevents modifying files under `openspec/specs/` during implementation, providing defense in depth for cases where tasks.md was manually edited.
3. **Add a formal spec requirement** to the task-implementation spec, documenting the baseline-spec exclusion rule as a testable requirement with Gherkin scenarios.

## Rationale

Defense in depth with formal traceability. The instruction prevents bad tasks from being generated, the apply guardrail catches edge cases, and the spec documents the rule as a verifiable requirement. Co-locating the exclusion with existing sync/archive exclusions in the schema makes the rules discoverable.

## Alternatives Considered

- Instruction-only change in schema.yaml — minimal but single point of failure if the agent ignores the instruction
- Instruction plus guardrail without spec — defense in depth but no formal traceability
- Separate instruction paragraph instead of extending existing IMPORTANT block — less discoverable

## Consequences

### Positive

- Single authoritative path for spec updates (delta spec → sync → baseline) is now explicitly enforced
- Defense in depth across three layers reduces risk of accidental baseline edits
- Rule is formally documented as a testable requirement with scenarios

### Negative

- AI agents may still ignore text-based instructions — no hard runtime enforcement exists
- Three files to maintain for the same rule — though all are small, additive text edits

## References

- [Change: fix-apply-baseline-edits](../../openspec/changes/2026-03-23-fix-apply-baseline-edits/)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [Spec: spec-sync](../../openspec/specs/spec-sync/spec.md)
- [GitHub Issue #43](https://github.com/fritze-dev/opsx-enhanced-flow/issues/43)
