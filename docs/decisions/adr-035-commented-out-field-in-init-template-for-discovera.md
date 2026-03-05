# ADR-035: Commented-out field in init template for discoverability

## Status
Accepted (2026-03-05)

## Context
The `docs_language` configuration field needed to be discoverable by users setting up new projects via `/opsx:init`, but should not be active by default since most projects start in English. Research considered three approaches: an active field defaulting to English (unnecessary noise in every config.yaml), separate configuration documentation (not discoverable during setup), or a commented-out field in the init template (visible but inactive). The commented-out approach follows a common pattern in configuration files where optional features are documented but disabled by default. Users see the option during initialization and can uncomment it when needed. Existing projects are completely unaffected since the field does not exist in their config.yaml.

## Decision
Include `docs_language` as a commented-out field in the init skill's config template for discoverability.

## Rationale
Users discover the feature without it being active by default. Existing projects are unaffected.

## Alternatives Considered
- Active field defaulting to English — unnecessary noise in config for the majority of projects
- Separate config documentation — not discoverable during setup workflow

## Consequences

### Positive
- Feature is discoverable during project initialization
- No impact on existing projects or default behavior
- Common configuration pattern that users understand

### Negative
- No significant negative consequences identified

## References
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [ADR-034: Single docs_language field in config.yaml](adr-034-single-docs-language-field-in-config-yaml.md)
