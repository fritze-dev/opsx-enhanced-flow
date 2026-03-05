# ADR-006: Remove constitution redundancies

## Status
Accepted (2026-03-02)

## Context
During the rule ownership audit triggered by the first dogfooding run, 12 rules in the constitution were found to duplicate rules already defined in schema instructions or templates. For example, the DoD rule appeared in both the constitution and the schema's tasks.instruction, and post-apply workflow steps were duplicated between the constitution and the schema's apply.instruction. Maintaining these duplicates created a maintenance burden and risked drift when one copy was updated but not the other. The constitution's role is to hold project-specific content: tech stack, architecture, paths, conventions, and constraints — not universal workflow rules.

## Decision
Remove 12 redundancies from the constitution where it duplicated schema-defined rules. Keep only project-specific content.

## Rationale
Single source of truth prevents drift and reduces constitution noise. Each rule lives in exactly one place.

## Alternatives Considered
- Keep redundancies as "defense in depth" — causes maintenance burden and drift when copies diverge

## Consequences

### Positive
- Constitution is focused on project-specific content only
- No risk of drift between duplicated rules
- Reduced noise makes the constitution easier to read and maintain

### Negative
- Reduced defense-in-depth; accepted because schema enforcement plus skill guardrails are sufficient

## References
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [ADR-004: Schema owns workflow rules](adr-004-schema-owns-workflow-rules.md)
