# ADR-032: "Read before write" guardrail in SKILL.md

## Status
Accepted (2026-03-05)

## Context
The v1.0.7 docs regeneration introduced quality regressions where agents rewrote documentation from scratch, losing established tone, quality, and specific content. The root cause was that the SKILL.md had no guardrail preventing agents from ignoring existing documentation. Without a "read before write" rule, agents would generate fresh content based solely on source data, losing the accumulated quality of manually curated sections. Research showed that adding an explicit guardrail to SKILL.md is more effective than template-only guidance because the skill prompt is the primary instruction source agents read at runtime. The guardrail requires agents to read the existing document before generating a replacement.

## Decision
Add a "read before write" guardrail to SKILL.md that requires agents to read existing documentation before generating replacements.

## Rationale
Prevents quality regression by requiring agents to read existing docs before generating. Preserves established tone and content quality.

## Alternatives Considered
- Template-only guidance — too easy to miss; agents focus on SKILL.md instructions
- No guardrail — regression-prone; agents would overwrite curated content

## Consequences

### Positive
- Existing documentation quality is preserved across regeneration cycles
- Accumulated manual improvements survive automated regeneration

### Negative
- SKILL.md guidance is advisory, not enforced; accepted risk since agent compliance with well-written guidance is high

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
