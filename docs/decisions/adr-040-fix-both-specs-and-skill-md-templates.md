# ADR-040: Fix both specs AND SKILL.md/templates

## Status
Accepted (2026-03-05)

## Context
The docs regeneration test revealed 9 actionable regressions across SKILL.md, templates, and specs. The fix could target SKILL.md/templates only (the runtime instruction source), specs only (the requirement definitions), or both together. Research into the project's architecture showed that specs define WHAT should happen (requirements), while SKILL.md defines HOW to do it (execution instructions). At runtime, agents read SKILL.md directly — spec changes alone do not change agent behavior. Conversely, SKILL.md changes alone cause specs to drift from implementation, violating the project's spec-driven principle. Both must agree to prevent future drift and maintain the integrity of the spec-driven workflow.

## Decision
Fix both specs AND SKILL.md/templates together to maintain alignment between requirements and execution instructions.

## Rationale
Specs define requirements; SKILL.md defines execution. Both must agree to prevent future drift.

## Alternatives Considered
- SKILL.md-only — specs drift from implementation, violating spec-driven principle
- Specs-only — agent does not read specs at runtime, so behavior does not change

## Consequences

### Positive
- Specs and SKILL.md stay aligned, maintaining spec-driven workflow integrity
- Future regressions are prevented by consistent requirements and execution instructions

### Negative
- Larger change surface with more artifacts to review; accepted for the benefit of consistency

## References
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
