# ADR-007: Init generates minimal config template

## Status
Accepted (2026-03-02)

## Context
The `/opsx:init` skill sets up new consumer projects by generating an initial config.yaml. Previously, it copied the plugin's own project config, which contained project-specific rules and conventions that were inappropriate for consumer projects. With the config.yaml simplification (ADR-005), the init skill needed to generate a clean, minimal config template that provides only the bootstrap essentials: a schema reference and a constitution pointer. Research confirmed that the OpenSpec config.yaml customization surface supports this minimal approach, and consumer projects can add their own project-specific context as needed.

## Decision
Init generates a minimal config template instead of copying the plugin's own project config.

## Rationale
Prevents project-specific rules from leaking into consumer projects. Init should provide a clean starting point.

## Alternatives Considered
- Copy full project config — leaks project-specific content into consumer projects

## Consequences

### Positive
- Consumer projects start with a clean, minimal configuration
- No project-specific rules leak into new projects
- Consistent with the bootstrap-only role of config.yaml

### Negative
- No significant negative consequences identified

## References
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [ADR-005: Config as bootstrap-only](adr-005-config-as-bootstrap-only.md)
