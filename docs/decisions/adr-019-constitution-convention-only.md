# ADR-019: Constitution convention only

## Status
Accepted (2026-03-05)

## Context
The `/opsx:ff` command generated all 6 pipeline artifacts without pausing, preventing users from reviewing specs and design before the system proceeded to preflight and tasks. Issue #9 reported that a user had to manually interrupt ff to discuss the approach. The fix needed to add a design review checkpoint, but the skill immutability rule (established in the project's three-layer architecture) prohibits modifying skill files for project-specific behavior. Three implementation approaches were evaluated: constitution convention only, constitution plus skill modification, and schema-level checkpoint. The constitution is loaded into every AI prompt via config.yaml, making conventions authoritative. No skill code changes or schema modifications were needed.

## Decision
Implement the design review checkpoint as a constitution convention only, without modifying any skill files or schema definitions.

## Rationale
Respects skill immutability. The constitution is always loaded and authoritative — agents read it at every step and are required to follow it.

## Alternatives Considered
- Skill modification — violates the skill immutability architecture rule
- Schema checkpoint — over-engineering; schema defines artifact order, not interaction pauses

## Consequences

### Positive
- Skill immutability is fully preserved
- Constitution is the single source of truth for this governance rule
- Consumer projects can adopt or customize the convention independently

### Negative
- Soft enforcement only; the convention relies on agent compliance, not hard code enforcement. Mitigated by constitution being injected into every prompt via config.yaml.

## References
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [ADR-008: Convention in constitution, not skill modification](adr-008-convention-in-constitution-not-skill-modification.md)
