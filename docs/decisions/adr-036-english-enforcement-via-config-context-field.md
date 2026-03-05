# ADR-036: English enforcement via config context field

## Status
Accepted (2026-03-05)

## Context
While user-facing documentation should be translatable, internal workflow artifacts (research.md, proposal.md, specs, design.md, preflight.md, tasks.md) must remain in English because they feed into the artifact pipeline and are consumed by other skills. The enforcement mechanism needed to apply universally to all skills without per-skill duplication. Research into the OpenSpec config.yaml structure showed that the `context` field is passed to all skills automatically — it serves as a global instruction channel. Adding an English enforcement rule to the context field creates a single enforcement point that every skill reads at startup, eliminating the need to add language rules to each skill individually.

## Decision
Enforce English for internal workflow artifacts via the config.yaml `context` field, which is automatically passed to all skills.

## Rationale
Context is passed to all skills automatically — single enforcement point with no per-skill duplication needed.

## Alternatives Considered
- Per-skill instruction — requires updating every skill individually, creates duplication
- Schema-level rule — language is not a pipeline concern, mixes concerns

## Consequences

### Positive
- Single enforcement point for all skills
- No per-skill duplication needed
- Consistent enforcement across existing and future skills

### Negative
- No significant negative consequences identified

## References
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [ADR-034: Single docs_language field in config.yaml](adr-034-single-docs-language-field-in-config-yaml.md)
