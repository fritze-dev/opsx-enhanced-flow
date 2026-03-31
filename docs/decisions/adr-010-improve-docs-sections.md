# ADR-010: Improve Docs Sections

## Status

Accepted — 2026-03-05

## Context

After the v1.0.7 docs regeneration (which implemented ADR-009's quality improvements), a detailed review of all 18 capability docs revealed content quality regressions and structural inconsistencies. Enriched docs used "Why This Exists" and "Background" headings while initial-spec-only docs used "Why This Exists" and "Design Rationale," creating an inconsistent reading experience. More critically, the SKILL.md prompt instructed agents to derive the "Why This Exists" section from archive proposal "Why" sections, which describe change motivation (e.g., "The init skill was broken") rather than capability purpose (e.g., "Without a single initialization command, you'd need to manually..."). This root cause led to Purpose regressions in 4 docs and Rationale regressions in 11 of 18 docs, where design reasoning was replaced with change-event descriptions. Additionally, there was no "Future Enhancements" section despite deferred Non-Goals and tracked GitHub Issues being available as enrichment sources, and no quality guardrail to prevent agents from rewriting docs from scratch.

## Decision

1. **Unified "Purpose" heading for all docs** — Replaces "Why This Exists" with a standard, unambiguous term that eliminates the inconsistency between enriched and spec-only docs.
2. **Unified "Rationale" heading for all docs** — Replaces both "Background" and "Design Rationale" with standard ADR terminology that covers both research-based and assumption-based design reasoning.
3. **Separate "Future Enhancements" from "Known Limitations"** — Limitations describe current constraints while enhancements describe actionable future ideas; conflating them confuses readers who have different needs for each.
4. **"Read before write" guardrail in SKILL.md** — Prevents quality regression by requiring the agent to read the existing doc before generating a replacement, preserving established tone and quality.
5. **Manual doc fixes with deferred regeneration** — Safer approach that preserves established quality and validates guardrails separately; full regeneration deferred to a separate friction issue (#18).

## Alternatives Considered

- Keep "Why This Exists" heading (rejected: informal, inconsistent connotation between enriched and spec-only docs)
- Use "Motivation" heading (rejected: too change-focused, encourages describing change events rather than capability purpose)
- Keep "Background" for enriched docs and "Design Rationale" for spec-only docs (rejected: inconsistent reader experience)
- Single "Limitations & Future" section (rejected: conflates distinct audiences and purposes)
- Embed future enhancements in Edge Cases (rejected: wrong section semantics)
- Add guidance only to template comments, not SKILL.md (rejected: too easy for agents to miss)
- No guardrail, rely on template alone (rejected: regression-prone without explicit read-before-write instruction)
- Regenerate all docs as part of this change (rejected: risks new regressions before guardrails are proven)
- Classify all Non-Goals into a single list (rejected: Non-Goals serve two distinct purposes — current constraints and deferred features)

## Consequences

### Positive

- All 18 capability docs use consistent "Purpose" and "Rationale" headings regardless of enrichment level
- Root cause of Purpose/Rationale regression is fixed in SKILL.md, preventing recurrence in future regenerations
- "Future Enhancements" section surfaces actionable deferred items that were previously invisible to readers
- "Read before write" guardrail protects established doc quality during agent-driven regeneration

### Negative

- Manual fixes of all 18 docs require careful systematic review to avoid missing edge cases (mitigated: systematic diff review of all docs)
- SKILL.md guidance is advisory, not enforced — agent compliance depends on well-written instructions (accepted risk: hard enforcement would require code changes outside scope)
- Current docs are manually curated rather than generated, creating potential drift until full regeneration occurs (mitigated: friction issue #18 tracks the regeneration pass)

## References

- [Change: improve-docs-sections](../../openspec/changes/2026-03-05-improve-docs-sections/)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-009: Improve Docs Output Quality](adr-009-improve-docs-output-quality.md)
