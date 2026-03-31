# ADR-008: Fix Docs Skill Regressions

## Status

Accepted — 2026-03-05

## Context

A full docs regeneration test (delete all docs, run `/opsx:docs`, diff against previous output) revealed 9 actionable regressions in the generated documentation, alongside 7 improvements that confirmed templates and guardrails fundamentally work. The regressions came from edge-case gaps in `skills/docs/SKILL.md`, the three doc templates (capability, ADR, README), and the three meta specs (`decision-docs`, `user-docs`, `architecture-docs`). Critical issues included a phantom ADR fabricated from an archive whose design.md had a prose-only Decisions section without a valid table, a manually-authored ADR (`adr-M001-init-model-invocable.md`) being lost during regeneration because the skill had no concept of non-archive ADRs, and non-deterministic ADR slugs producing different filenames across runs due to an underspecified slug algorithm. Additional medium and low severity regressions affected ADR reference link formatting, README capability description verbosity, Rationale section tense drift, behavior header formatting, and initial-spec fallback aggressiveness. Three approaches were evaluated: fixing only SKILL.md and templates (risking spec drift), fixing specs only (ineffective since the agent reads SKILL.md at runtime), or fixing all layers together. All fixes are additive guardrails and clarifications to markdown files with no runtime code changes.

## Decision

1. **Manual ADRs use `adr-MNNN-slug.md` naming in `docs/decisions/` (same directory)** — No extra directory is needed; the M prefix unambiguously distinguishes manual from generated `adr-NNN` files; a single glob location simplifies README discovery. The alternative of a separate `manual/` subdirectory was rejected as unnecessary complexity, and a preservation rule for unmatched ADRs was rejected due to fuzzy matching and numbering conflict risks.

2. **Deterministic slug algorithm: replace non-`[a-z0-9]` with hyphen** — Handles all special characters uniformly with no ambiguity about dots, parentheses, or slashes. The algorithm lowercases the string, replaces non-alphanumeric characters with hyphens, collapses consecutive hyphens, trims leading/trailing hyphens, and truncates to 50 characters. Keeping the current underspecified rule was rejected because it produced non-deterministic results across runs.

3. **Fix both specs AND SKILL.md/templates** — Specs define requirements while SKILL.md defines execution; both must agree to prevent future drift. Fixing only SKILL.md risks specs drifting from implementation, and fixing only specs is ineffective because the agent reads SKILL.md at runtime, not specs.

## Alternatives Considered

- Separate `manual/` subdirectory for manual ADRs — rejected as unnecessary complexity; naming convention alone distinguishes manual from generated ADRs
- Unnumbered slug-only naming for manual ADRs — rejected because it loses ordering capability
- `adr-000` range for manual ADRs — rejected due to collision risk with generated ADR numbering
- Preservation rule for unmatched ADRs during regeneration — rejected due to fuzzy matching complexity and numbering conflicts
- Keep current underspecified slug algorithm — rejected because it produces non-deterministic filenames across runs
- Add special-case rules per character type for slug generation — rejected as overly complex while still potentially ambiguous
- Fix SKILL.md and templates only, skip spec updates — rejected because specs would drift from implementation
- Fix specs only, let SKILL.md derive from specs — rejected because the agent reads SKILL.md at runtime, not specs directly

## Consequences

### Positive

- Archives with prose-only Decisions sections no longer produce phantom ADRs
- Manually-authored ADRs survive regeneration and appear in the README Key Design Decisions table
- ADR slugs are deterministic, producing consistent filenames across repeated runs
- ADR References use semantic link text (`[Spec: name](path)`) instead of raw file paths
- README capability descriptions are constrained to 80 characters / 15 words
- Rationale sections use present tense, avoiding change-history narration patterns
- All three documentation layers (specs, SKILL.md, templates) are aligned, preventing future drift

### Negative

- Slug change causes ADR file renames — the new deterministic algorithm produces different filenames for some existing ADRs. All README links regenerate to match so no broken links occur, but git shows renames as churn.
- Template comments increase file size — adding guardrail comments to templates makes them longer, though templates are only read by the agent at generation time with no user impact.
- Regeneration QA depends on agent behavior — the only reliable test is delete, regenerate, diff. No automated assertion is possible since output is LLM-generated. Mitigated by clear, specific SKILL.md instructions that reduce variance.

## References

- [Change: fix-docs-skill-regressions](../../openspec/changes/2026-03-05-fix-docs-skill-regressions/)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [ADR-007: Fix Docs Regeneration Quality](adr-007-fix-docs-regeneration-quality.md)
- [ADR-003: Documentation Ecosystem](adr-003-documentation-ecosystem.md)
