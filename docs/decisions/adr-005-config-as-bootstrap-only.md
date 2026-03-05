# ADR-005: Config as bootstrap-only

## Status
Accepted (2026-03-02)

## Context
The config.yaml file originally contained 9 global workflow rules in its `context` field, duplicating rules that belonged in the schema or constitution. After establishing that schema owns universal workflow rules (ADR-004) and the constitution owns project-specific rules, the purpose of config.yaml needed to be redefined. OpenSpec documentation confirmed that config.yaml supports `context` (global), `rules` (per-artifact), and a schema reference — but per-project customization is its primary role. With rules moved to their authoritative sources, config.yaml only needed to point to the schema and the constitution.

## Decision
Reduce config.yaml to bootstrap-only: schema reference plus constitution pointer. Remove all workflow rules from config.yaml.

## Rationale
config.yaml's purpose is per-project customization. With rules in schema and project rules in constitution, config just needs to point to the constitution.

## Alternatives Considered
- Keep rules in config — creates redundancy with schema and constitution
- No config at all — loses the constitution pointer needed for project-specific rules

## Consequences

### Positive
- Clean separation of concerns across the three layers
- config.yaml is minimal and easy to understand for new projects
- No drift between config rules and their authoritative sources

### Negative
- No significant negative consequences identified

## References
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [ADR-004: Schema owns workflow rules](adr-004-schema-owns-workflow-rules.md)
