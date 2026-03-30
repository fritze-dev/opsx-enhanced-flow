# Technical Design: Improve /opsx:docs Output Quality

## Context

The `/opsx:docs` skill generates user documentation from merged specs. The first production run (v1.0.5) exposed 11 quality gaps across three areas: docs structure (overlapping files), content quality (weak initial-spec docs, thin ADR context, missing trade-offs), and missing infrastructure (no standalone doc templates). The docs skill prompt (`skills/docs/SKILL.md`, 309 lines) controls all generation behavior and is the primary file to modify. Three specs (user-docs, architecture-docs, decision-docs) define the formal requirements.

The current docs output has 5 files serving as entry points or indexes (`docs/README.md`, `docs/architecture-overview.md`, `docs/decisions/README.md`) where 1 would suffice. Nine of 18 capability docs are initial-spec-only and produce noticeably weaker content. The project README (462 lines) duplicates content now available in auto-generated docs.

## Architecture & Components

**Files to create:**
- `openspec/schemas/opsx-enhanced/templates/docs/capability.md` — capability doc template
- `openspec/schemas/opsx-enhanced/templates/docs/adr.md` — ADR template
- `openspec/schemas/opsx-enhanced/templates/docs/readme.md` — consolidated README template (with category-grouped capabilities)

**Files to modify:**
- `skills/docs/SKILL.md` — restructure steps, add template references, improve prompt guidance
- `openspec/specs/user-docs/spec.md` — via delta spec sync
- `openspec/specs/architecture-docs/spec.md` — via delta spec sync
- `openspec/specs/decision-docs/spec.md` — via delta spec sync
- `openspec/specs/spec-format/spec.md` — via delta spec sync (frontmatter extension)
- `openspec/schemas/opsx-enhanced/templates/specs/spec.md` — add optional frontmatter to spec template
- `openspec/specs/*/spec.md` — all 18 baseline specs get `order` + `category` frontmatter
- `README.md` — shorten, add links to docs/

**Files to delete (by the improved `/opsx:docs` itself):**
- `docs/architecture-overview.md` — content merged into `docs/README.md`
- `docs/decisions/README.md` — replaced by inline ADR links in `docs/README.md`

**Files to regenerate (via `/opsx:docs` after archive):**
- `docs/README.md` — consolidated entry point
- `docs/capabilities/*.md` — 18 capability docs with improved quality
- `docs/decisions/adr-*.md` — 22+ ADRs with improved format

**Interaction pattern:** SKILL.md references templates via `Read openspec/schemas/opsx-enhanced/templates/docs/*.md`. This follows the same pattern as pipeline artifacts (research, proposal, etc.) which reference templates in the same directory. Consumer projects get templates via `/opsx:init` schema copy.

## Goals & Success Metrics

* `docs/README.md` is the single entry point — no separate `architecture-overview.md` or `decisions/README.md` exist after generation (PASS/FAIL)
* Initial-spec-only capability docs use problem-framing in "Why This Exists" — none restate the Purpose section verbatim (spot-check 3 of 9: spec-format, three-layer-architecture, roadmap-tracking)
* ADR Context sections are at least 4 sentences (spot-check 3 ADRs from different archives)
* ADR Consequences are split into Positive/Negative subsections (check any 2 ADRs)
* ADRs include References sections with spec links (check any 2 ADRs)
* Edge Cases sections contain no normal UX flow items (spot-check quality-gates and change-workspace)
* Capabilities in docs/README.md are grouped by `category` with group headers and ordered by `order` within groups
* All 18 baseline specs have `order` and `category` frontmatter
* Key Design Decisions table has ADR link column (not Source column)
* 3 doc templates exist at `templates/docs/` (capability.md, adr.md, readme.md)
* README.md is shorter than 400 lines and links to docs/ for detailed reference

## Non-Goals

- Changing other skills (new, ff, apply, verify, archive, etc.)
- Modifying schema.yaml or the artifact pipeline structure
- Changing constitution.md
- Modifying pipeline artifact templates (research, proposal, design, preflight, tasks) — except the spec template which gets frontmatter extension
- Adding automated validation of doc output against templates
- Adding incremental doc generation (docs remain fully regenerated each run)

## Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | SKILL.md references templates via Read at runtime | Consistent with pipeline artifact templates; format changes don't require prompt edits; single source of truth for doc structure | Inline format in SKILL.md (current approach — harder to maintain, bloats prompt) |
| 2 | Consolidated README replaces 3 separate files | Eliminates navigation hops; architecture overview IS the entry point; ADR index is just a table that fits in the overview | Keep separate files with better cross-linking (rejected: still 3 files to maintain) |
| 3 | Cleanup step in SKILL.md deletes stale files | Consumer projects need automated migration from old 3-file to new 1-file structure; manual deletion is fragile | Manual deletion only (rejected: consumers would miss it); Migration guide only (rejected: automation is simple) |
| 4 | ADR generation runs BEFORE README generation | README needs ADR file paths for inline links; reversing order would require a two-pass approach | Generate README first, then backfill ADR links (rejected: adds complexity) |
| 5 | Ordering + grouping via `order` and `category` YAML frontmatter in baseline specs | Project-specific, deterministic, set during spec creation (not docs generation); SKILL.md stays project-independent; follows data flow (specs → archive → docs read) | Hardcoded table in SKILL.md (rejected: violates skill immutability); Constitution section (rejected: data table, not a rule); Agent-determined at docs time (rejected: non-deterministic) |
| 6 | README shortening is a separate implementation task from docs regeneration | README is hand-written; changes are independent of auto-generated docs; allows separate review | Include in docs regeneration (rejected: mixes auto-generated and hand-written concerns) |

## Risks & Trade-offs

- **Breaking external links**: `docs/architecture-overview.md` and `docs/decisions/README.md` URLs will break → Mitigation: Document in changelog. Low impact — docs are internal to the repo.
- **SKILL.md prompt effectiveness**: More detailed instructions could cause the LLM to over-focus on formatting → Mitigation: Template extraction actually reduces SKILL.md length; critical logic stays in prompt, structural format moves to templates.
- **Initial-spec research.md may be thin**: Design Rationale for spec-only docs depends on initial-spec research quality → Mitigation: SKILL.md instructs to omit section if data is insufficient.
- **Consumer upgrade path**: Consumers running `/opsx:docs` after plugin update will get new structure without warning → Mitigation: Docs are fully regenerated each run; no state to migrate. Stale file cleanup handles the transition automatically.

## Open Questions

No open questions.

## Assumptions

- The `/opsx:init` schema copy includes subdirectories (so `templates/docs/` will be available in consumer projects). <!-- ASSUMPTION: Tested in existing pipeline template behavior -->
- The initial-spec archive's research.md contains enough useful data for at least some Design Rationale sections. <!-- ASSUMPTION: Based on initial-spec archive content — to be verified during implementation -->
