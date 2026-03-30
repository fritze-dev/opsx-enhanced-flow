# Technical Design: Streamline ADR Format

## Context

The ADR template (`openspec/schemas/opsx-enhanced/templates/docs/adr.md`) defines a 7-section structure including a separate `## Rationale` section. The consolidation change (ADR-012, commit `4b94175`) introduced inline rationale in the Decision section for consolidated ADRs but never explicitly addressed the template's separate Rationale section. Since consolidation applies to nearly all archives, 14 of 15 ADRs now have no separate Rationale section — this is an unintentional side effect, not a deliberate design choice.

The template and the `decision-docs` spec are now inconsistent with actual practice, causing occasional agent confusion (ADR-015 has a separate Rationale; all others don't). Pre-consolidation, the separate Rationale sections were always 100% redundant copies of the Decision text anyway, so no information value was lost.

## Architecture & Components

Three files need updates:

1. **`openspec/schemas/opsx-enhanced/templates/docs/adr.md`** — Remove `## Rationale` section. Formalize the inline-rationale em-dash pattern in the `## Decision` section template.

2. **`skills/docs/SKILL.md`** (Step 4) — Update the ADR generation instructions to make inline-rationale the standard for ALL ADRs (not just consolidated ones). Remove any reference to a separate Rationale section. The consolidated format block already describes inline rationale — the change is to generalize this to all ADR types.

3. **`openspec/specs/decision-docs/spec.md`** — Updated via delta spec. The baseline gets the changes at archive time.

4. **`skills/docs/SKILL.md`** (Step 5) — Update README generation to source the Key Design Decisions table from ADR files instead of design.md archives. The agent reads all `docs/decisions/adr-*.md` files, extracts Decision/Rationale from the ADR content, and builds the table. design.md archives are no longer read for this purpose.

5. **`openspec/specs/architecture-docs/spec.md`** — Updated via delta spec. Changes the "Generate Architecture Overview" requirement to source the Key Design Decisions table from ADR files.

No constitution changes needed.

## Goals & Success Metrics

| # | Metric | Verification |
|---|--------|-------------|
| 1 | ADR template has no `## Rationale` section | Read `templates/docs/adr.md` — no heading containing "Rationale" |
| 2 | ADR template Decision section shows inline-rationale pattern | Template contains em-dash example or instruction |
| 3 | SKILL.md Step 4 describes inline-rationale for all ADR types | Grep for "inline" or "em-dash" in Step 4; no mention of separate Rationale section |
| 4 | Language-Aware ADR heading list excludes "Rationale" | SKILL.md Step 4 language reminder and spec language scenario list "Status, Context, Decision, Alternatives Considered, Consequences, References" (6 headings, not 7) |
| 5 | SKILL.md Step 5 sources Key Design Decisions table from ADR files, not design.md | Grep Step 5 — references `docs/decisions/adr-*.md` as source; no reference to `archive/*/design.md` for the table |

## Non-Goals

- Changing the Consequences section format (Positive/Negative split works well)
- Changing the Context minimum length (4-6 sentences produces good results)
- Modifying consolidation heuristics
- Regenerating ADRs as part of this change (happens automatically on next `/opsx:docs` run)
- Changing Manual ADR format (manual ADRs may retain a separate `## Rationale` if the author wishes)

## Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Remove `## Rationale` section from ADR template and replace with inline-rationale in Decision section | The section was always a redundant copy of the Decision text (verified across all pre-consolidation ADRs); the inline pattern is already the de facto standard in 14/15 ADRs | Keep Rationale as optional section (causes inconsistency); move Rationale into Context section (wrong semantic home) |
| 2 | Generalize the consolidated format's inline-rationale to all ADR types | Single-decision ADRs benefit from the same pattern; avoids having two different Decision section formats | Keep separate formats for consolidated vs. single-decision ADRs (complexity, inconsistency) |
| 3 | Update Language-Aware heading list to 6 headings (drop Rationale) | The translated heading list must match the actual template sections | Keep 7 headings including Rationale translation (template/heading mismatch) |
| 4 | README Key Design Decisions table sources data from ADR files instead of design.md archives | ADRs are the canonical output; reading from them eliminates the indirection through design.md and unifies extraction for generated and manual ADRs | Keep design.md as source (works but adds unnecessary indirection; two different extraction paths for generated vs. manual ADRs) |

## Risks & Trade-offs

- **Manual ADRs may have separate Rationale** → Accepted. Manual ADRs (`adr-M*.md`) are user-authored and may use any format. The README table extraction still looks for `## Rationale` in manual ADRs — this behavior is preserved.
- **One-time regeneration on next `/opsx:docs` run** → Expected. The template change triggers full regeneration. Only ADR-015 is expected to actually change content. The existing one-time regeneration mechanism (from ADR-012's consolidation detection) handles this.
- **Inline rationale extraction for README table** → The agent must parse the em-dash pattern from generated ADR Decision sections. For consolidated ADRs with multiple sub-decisions, it summarizes the overarching decision. This is a summarization task that LLM agents handle well — no structured parsing needed.

## Open Questions

No open questions.

## Assumptions

- The inline-rationale em-dash pattern (`**Decision** — rationale`) is well-understood by LLM agents when described in the template. <!-- ASSUMPTION: Pattern already successfully used by agents in 14/15 ADRs -->
- ADR files are always generated before README generation within a single `/opsx:docs` run (Step 4 before Step 5), so all ADRs are available when the README table is built. <!-- ASSUMPTION: SKILL.md step ordering guarantees this -->
