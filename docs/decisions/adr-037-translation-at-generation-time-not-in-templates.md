# ADR-037: Translation at generation time, not in templates

## Status
Accepted (2026-03-05)

## Context
Documentation templates at `openspec/schemas/opsx-enhanced/templates/docs/` serve as structural guides for the docs skill, defining section headers, ordering, and format guidance. With the addition of multi-language support, the question arose whether templates should be translated per language or remain in English as structural guides. Research showed that maintaining per-language template sets would create a proliferation of template files (one set per supported language) and significant maintenance burden. Since the LLM generating documentation can translate headings and content during generation based on the `docs_language` config field, one set of English templates can serve all languages. YAML frontmatter keys remain English since they are machine-readable identifiers, with only user-facing values like `title` and `description` being translated.

## Decision
Keep documentation templates in English and apply translation at generation time, not in the templates themselves.

## Rationale
Templates are structural guides. Translation during generation allows one set of templates for all languages, avoiding template proliferation.

## Alternatives Considered
- Per-language template sets — template proliferation and significant maintenance burden

## Consequences

### Positive
- Single set of templates serves all languages
- No template maintenance burden per language
- YAML frontmatter keys remain stable machine-readable identifiers

### Negative
- Language change mid-project leaves mixed-language changelog entries; accepted as expected behavior since existing entries are preserved

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [ADR-034: Single docs_language field in config.yaml](adr-034-single-docs-language-field-in-config-yaml.md)
