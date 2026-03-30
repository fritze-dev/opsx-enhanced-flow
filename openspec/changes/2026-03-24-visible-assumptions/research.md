# Research: Visible Assumptions

## 1. Current State

Assumptions are marked with `<!-- ASSUMPTION: [reason] -->` HTML comments throughout the project. These are invisible in GitHub and IDE Markdown previews.

**Affected locations:**

| Location | Occurrences | Role |
|----------|-------------|------|
| `schema.yaml` lines 142, 169 | 2 | Instructions telling agents to use HTML comment format |
| `templates/specs/spec.md` line 35 | 1 | Spec template guidance |
| `templates/design.md` line 31 | 1 | Design template guidance |
| `templates/preflight.md` line 20 | 1 | Preflight collects `<!-- ASSUMPTION -->` markers |
| `openspec/specs/` (18 spec files) | ~50+ | All existing baseline specs use HTML comment format |

The templates already define `## Assumptions` sections — but the content inside uses HTML comments, defeating the purpose.

## 2. External Research

Not applicable — this is an internal format convention change.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Blockquote `> **ASSUMPTION:** [reason]` | Visually distinct, easy to scan, renders everywhere | Slightly heavier markup; inline assumptions break paragraph flow |
| B: List item `- **ASSUMPTION:** [reason]` | Lightweight, integrates with existing list content | Less visually distinct from surrounding bullets |
| C: Dedicated `## Assumptions` section only (no inline) | Clean separation, easy to audit | Loses proximity to the context the assumption relates to |

**Recommendation:** Approach A (blockquote) for inline assumptions, keeping the existing `## Assumptions` sections as collection points. The blockquote format is the most visually distinct and scannable in GitHub/IDE preview.

## 4. Risks & Constraints

- **Migration scope:** ~50+ occurrences across 18 baseline spec files need updating. This is mechanical but touches many files.
- **Preflight search pattern:** Preflight currently looks for `<!-- ASSUMPTION -->` markers. Must update to search for `> **ASSUMPTION:**` instead.
- **No breaking change:** This is a format convention change — no code, no CLI behavior, no API changes.
- **Active changes:** Any in-progress changes using the old format would need manual alignment — but currently no active changes exist (clean git state).

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Replace HTML comment assumptions with visible blockquote format |
| Behavior | Clear | Format change only — no functional behavior changes |
| Data Model | Clear | No data model — purely Markdown convention |
| UX | Clear | Assumptions become visible in preview — direct improvement |
| Integration | Clear | Schema instructions, templates, preflight search, baseline specs |
| Edge Cases | Clear | Multi-line assumptions, assumptions with special chars, empty assumption sections |
| Constraints | Clear | Must stay parseable for preflight audit |
| Terminology | Clear | "ASSUMPTION" keyword stays the same |
| Non-Functional | Clear | No performance or security implications |

All categories are Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use blockquote format `> **ASSUMPTION:** [reason]` | Most visually distinct in Markdown renderers; easy to grep; keeps inline proximity to context | List items (less distinct), dedicated section only (loses proximity) |
| 2 | Update all existing baseline specs in same change | Consistent codebase — no mixed formats | Leave old specs as-is (creates inconsistency) |
| 3 | Keep `## Assumptions` sections in templates | Already exist, serve as collection point at end of document | Remove sections (loses structured overview) |
