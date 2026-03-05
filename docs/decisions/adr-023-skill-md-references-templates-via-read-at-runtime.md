# ADR-023: SKILL.md references templates via Read at runtime

## Status
Accepted (2026-03-05)

## Context
The `/opsx:docs` skill prompt (SKILL.md) originally contained inline format definitions for all documentation types, making it hard to maintain and bloating the prompt. The v1.0.5 production run exposed 11 quality gaps, and fixing them required restructuring how the skill defines output formats. Research showed that pipeline artifact templates (research, proposal, design, etc.) already follow a pattern where SKILL.md references template files via Read instructions at runtime. Applying this same pattern to documentation templates would keep SKILL.md focused on logic while moving structural format to separate files. Format changes would not require prompt edits, establishing a single source of truth for document structure. Consumer projects would receive templates via `/opsx:init` schema copy.

## Decision
SKILL.md references documentation templates via Read at runtime, consistent with the existing pipeline artifact template pattern.

## Rationale
Consistent with pipeline artifact templates. Format changes do not require prompt edits. Single source of truth for document structure.

## Alternatives Considered
- Inline format in SKILL.md (the existing approach) — harder to maintain, bloats the prompt

## Consequences

### Positive
- Format changes only require editing the template file, not SKILL.md
- SKILL.md stays focused on generation logic
- Consistent pattern across all template types (pipeline and docs)

### Negative
- SKILL.md prompt effectiveness could be affected by more detailed instructions, but template extraction actually reduces SKILL.md length

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
