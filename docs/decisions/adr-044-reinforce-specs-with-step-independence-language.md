# ADR-044: Reinforce specs with step independence language

## Status
Accepted (2026-03-05)

## Context
The specs for `user-docs` and `decision-docs` already described the correct behavior (sections should be included when data exists, Context should be enriched from research), but SKILL.md contradicted or underspecified these requirements. While the SKILL.md fix addresses the immediate problem, the convention requires spec changes to go through the flow. Research showed that adding explicit "step independence" language to both specs prevents future drift between spec and skill — if someone later modifies SKILL.md, the spec clearly states the requirement. Skipping spec changes was rejected because the project's spec-driven principle requires specs and implementation to stay aligned, even when specs already describe the correct behavior.

## Decision
Reinforce specs with explicit step independence language, even though they already describe the correct behavior.

## Rationale
Keeps specs and skill explicitly aligned. Adding step independence language to specs prevents future drift between spec and skill.

## Alternatives Considered
- Skip spec changes since they already describe correct behavior — rejected because specs and skill should stay aligned per the project's conventions

## Consequences

### Positive
- Specs explicitly document the step independence requirement
- Future SKILL.md modifications have clear spec requirements to conform to
- Spec-driven principle is maintained

### Negative
- No significant negative consequences identified

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-043: Add step independence as a guardrail, not a structural change](adr-043-add-step-independence-as-a-guardrail-not-a-structu.md)
