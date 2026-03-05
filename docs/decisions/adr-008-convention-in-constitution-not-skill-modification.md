# ADR-008: Convention in constitution, not skill modification

## Status
Accepted (2026-03-04)

## Context
The plugin's update mechanism requires a version bump in `plugin.json` for `/plugin update` to detect changes. This bump was a manual convention that was regularly forgotten, causing consumers to miss updates. Additionally, `marketplace.json` was out of sync (1.0.0 vs 1.0.3). The solution needed to automate version bumping as part of the archive workflow, but skills are shared plugin code that must remain generic across all consumer projects. The skill immutability rule (established as a project architecture principle) prohibits modifying skills for project-specific behavior. Research confirmed that the constitution is loaded into every AI prompt via config.yaml, making constitution conventions authoritative for all agent actions.

## Decision
Define the post-archive auto-bump behavior as a convention in the constitution, not as a skill modification.

## Rationale
Skills are shared across consumers; project-specific behavior belongs in the constitution (Issue #10). The constitution is read at the start of every skill execution, so agents will follow the convention without skill code changes.

## Alternatives Considered
- Modify archive skill directly — violates skill immutability rule and creates a project-specific skill fork

## Consequences

### Positive
- Skill immutability is preserved; skills remain generic and shareable
- Constitution conventions are authoritative and always loaded
- Consumer projects can adopt or modify the convention independently

### Negative
- Convention compliance depends on agent reading and following the constitution; mitigated by constitution being injected into every prompt via config.yaml

## References
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-004: Schema owns workflow rules](adr-004-schema-owns-workflow-rules.md)
