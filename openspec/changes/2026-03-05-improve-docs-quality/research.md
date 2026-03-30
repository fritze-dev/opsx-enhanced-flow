# Research: Improve /opsx:docs Output Quality

## 1. Current State

The `/opsx:docs` skill (`skills/docs/SKILL.md`, 309 lines) generates user documentation from merged specs. The v1.0.5 run produced:
- 18 capability docs (`docs/capabilities/*.md`)
- 22 ADRs (`docs/decisions/adr-*.md`)
- 1 architecture overview (`docs/architecture-overview.md`)
- 2 index files (`docs/README.md`, `docs/decisions/README.md`)

**Key quality split:** 9 of 18 capabilities are enriched from post-bootstrap archives (fix-workflow-friction, final-verify-step, doc-ecosystem, release-workflow, design-review-checkpoint). The other 9 are initial-spec-only — they have no dedicated archive and derive content from the spec alone. This split is the root cause of several quality gaps.

**Affected files:**
- `skills/docs/SKILL.md` — the prompt controlling all doc generation
- `docs/README.md` — thin TOC (just 3 links)
- `docs/architecture-overview.md` — the actual architecture document
- `docs/decisions/README.md` — ADR index (duplicates overview's Key Design Decisions)
- `docs/capabilities/*.md` — 18 capability docs
- `docs/decisions/adr-*.md` — 22 ADRs
- `openspec/specs/user-docs/spec.md` — spec for capability doc generation
- `openspec/specs/architecture-docs/spec.md` — spec for architecture overview
- `openspec/specs/decision-docs/spec.md` — spec for ADR generation
- `openspec/schemas/opsx-enhanced/templates/` — pipeline templates (no doc templates yet)
- `README.md` — project root README (462 lines, overlaps with docs/)

**Stale-spec risk:** The three doc specs (user-docs, architecture-docs, decision-docs) accurately reflect the current SKILL.md behavior. No drift detected.

## 2. External Research

Not applicable — this change is entirely internal to the plugin's docs generation prompt and templates. No external APIs, libraries, or dependencies involved.

ADR format reference: The standard ADR template (as popularized by Michael Nygard) uses Status, Context, Decision, Consequences. Our format adds Alternatives Considered (good) but has flat Consequences (to be improved) and no References (to be added).

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: All 11 items in one change | Complete fix, single docs regeneration, coherent spec updates | Large change, longer review cycle |
| B: Split into 2-3 smaller changes | Easier to review individually | Multiple archive cycles, repeated docs regeneration, items are interdependent (e.g., #1 consolidation affects #5 trade-offs placement) |
| C: SKILL.md-only changes, skip spec updates | Faster to implement | Specs drift from actual behavior, violates the project's spec-driven principle |

**Chosen: Approach A** — The 11 items are highly interdependent (consolidation #1 changes where trade-offs #5 appear, templates #11 restructure how all other items are expressed). Splitting would create artificial boundaries.

## 4. Risks & Constraints

- **Prompt length:** Adding all 11 improvements could push SKILL.md beyond effective context. Mitigated by template extraction (#11) which *reduces* SKILL.md size by moving format definitions to separate files.
- **Consumer compatibility:** Consumer projects running `/opsx:docs` after plugin upgrade will get the new consolidated structure. Docs are fully regenerated each run, so no migration needed. But external links to `docs/architecture-overview.md` or `docs/decisions/README.md` will break.
- **Initial-spec research quality:** Design Rationale for spec-only docs (#8) depends on the initial-spec archive's `research.md` having useful content. If thin, the section may not add value.
- **README shortening is subjective:** Which sections to keep at what length requires judgment. The design review checkpoint is the right place to align.
- **Template reference paths:** SKILL.md references `openspec/schemas/opsx-enhanced/templates/docs/*.md`. In consumer projects, the schema is copied during `/opsx:init`, so paths must work relative to the project root. Consistent with how pipeline templates already work.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 11 items fully described in Issue #13 + comments |
| Behavior | Clear | Each item has a concrete Problem/Fix description |
| Data Model | Clear | No data model changes — only markdown file structure |
| UX | Clear | Output files change structure, user interaction unchanged |
| Integration | Clear | No external dependencies; template paths follow existing pattern |
| Edge Cases | Clear | Consumer compatibility, stale file cleanup, thin initial-spec data |
| Constraints | Clear | Skill immutability, template path conventions, constitution rules |
| Terminology | Clear | All terms established in existing specs |
| Non-Functional | Clear | No performance impact — docs are regenerated on demand |

All categories Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Implement all 11 items in a single change | Items are interdependent; splitting creates artificial boundaries and repeated docs regeneration | Split into 2-3 changes (rejected: overhead, interdependencies) |
| 2 | SKILL.md references templates at runtime via Read | Consistent with pipeline artifact templates; format changes don't require SKILL.md edits | Inline format in SKILL.md (rejected: current approach, harder to maintain) |
| 3 | Add cleanup step to SKILL.md for stale files | One-time transition from 3-file to 1-file docs structure needs automated cleanup | Manual deletion (rejected: fragile, consumers would miss it) |
| 4 | README shortening separate from docs regeneration | README is hand-written; changes are independent of the auto-generated docs structure | Include in same task list (rejected: clearer separation of concerns) |
| 5 | Ordering + grouping via `order` and `category` frontmatter in baseline specs | Project-specific, deterministic, set during spec creation; SKILL.md stays project-independent; follows data flow (specs → archive → docs read) | Hardcoded table in SKILL.md (rejected: violates skill immutability); Agent-determined at docs time (rejected: non-deterministic) |
