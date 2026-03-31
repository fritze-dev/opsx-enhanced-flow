# ADR-019: Visible Assumptions and Review Auto-Resolution

## Status

Accepted (2026-03-24)

## Context

Assumption markers in specs used two patterns inconsistently: Pattern A places a visible list item alongside a hidden HTML tag (`- Visible text. <!-- ASSUMPTION: tag -->`), while Pattern B hides everything inside an HTML comment, making assumptions invisible in GitHub and IDE Markdown previews. With approximately 50+ occurrences across 18 baseline spec files using the invisible format, reviewers and preflight audits could not see assumptions without reading raw source. Three alternative visible formats were evaluated during research: blockquote (`> **ASSUMPTION:**`), list item (`- **ASSUMPTION:**`), and dedicated section-only approaches, each trading off visual distinctness against inline proximity and machine-parseability. Separately, `<!-- REVIEW -->` markers placed by bootstrap and docs skills were never actively resolved, persisting invisibly in committed files. The preflight audit covered only assumption markers, leaving review markers undetected. Addressing both issues together ensures that all transient markers are either visible to reviewers or actively resolved before a change completes.

## Decision

1. **Enforce Pattern A (`- Visible text. <!-- ASSUMPTION: tag -->`) as the standard assumption format** — preserves the machine-parseable tag for preflight auditing while making the assumption visible to reviewers in rendered Markdown.
2. **Keep REVIEW as an HTML comment but resolve it automatically during skill execution** — REVIEW is transient (exists only during an agent session), so visibility in final output is unnecessary; what matters is that skills actively iterate through markers, prompt the user, document decisions, and delete markers before finishing.
3. **Migrate all affected baseline specs via delta specs** — verify can check correctness and sync handles the merge, staying consistent with the project workflow rule that baseline edits go through the change pipeline rather than direct modification.
4. **Expand preflight Section F to "Marker Audit" covering both ASSUMPTION and REVIEW markers** — a single audit section avoids unnecessary complexity of separate marker-type sections, with REVIEW markers rated as always Blocking since they must be resolved before completion.

## Alternatives Considered

- Blockquote format (`> **ASSUMPTION:**`) for assumptions — visually distinct but loses the machine-parseable tag needed by preflight.
- Enforcing Pattern B only via preflight detection — would catch violations but does not fix existing invisible content.
- Making REVIEW markers visible too — unnecessary overhead since REVIEW markers should never persist in committed files.
- Direct edits to baseline specs during apply — violates the schema constraint on baseline edits, bypassing the change pipeline.
- Separate preflight sections for each marker type — adds unnecessary complexity for closely related concerns.
- Leaving old baseline specs as-is and only enforcing the new format going forward — creates format inconsistency across the codebase.

## Consequences

### Positive

- All assumptions are visible in Markdown preview, improving review quality and discoverability.
- Preflight audits can detect both malformed assumptions and lingering review markers in a single pass.
- REVIEW markers are guaranteed to be resolved before a skill run completes, eliminating invisible technical debt.
- Machine-parseable assumption tags are preserved, maintaining backward compatibility with preflight search patterns.
- Consistent assumption format across all baseline specs after migration.

### Negative

- Large number of delta specs (13) required for the migration, though all are mechanical format changes with minimal risk.
- Inline Pattern B assumptions moved to the Assumptions section lose proximity to their original context, trading locality for auditability.
- REVIEW auto-resolution adds interactive prompts to bootstrap and docs skill runs, potentially slowing execution.

## References

- [Change: visible-assumptions](../../openspec/changes/2026-03-24-visible-assumptions/)
- [Spec: spec-format](../../openspec/specs/spec-format/spec.md)
- [Spec: quality-gates](../../openspec/specs/quality-gates/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
