## Why

The first `/opsx:docs` run (v1.0.5) revealed 11 quality gaps: overlapping doc files, weak initial-spec-only content, inconsistent ADR depth, missing trade-offs, and no standalone doc templates. Nine of 18 capabilities are initial-spec-only and produce noticeably weaker documentation than enriched docs. The docs structure also has three files with overlapping purpose (README, architecture overview, ADR index) and the project README duplicates content that now lives in auto-generated docs.

## What Changes

- Consolidate `docs/README.md`, `docs/architecture-overview.md`, and `docs/decisions/README.md` into a single `docs/README.md` entry point
- Add BAD/GOOD examples to the SKILL.md prompt for initial-spec "Why This Exists" fallback
- Add `order` and `category` YAML frontmatter to baseline specs for deterministic, project-specific TOC ordering
- Reorder capability TOC to follow the workflow sequence, grouped by category (Setup, Change Workflow, Development, Finalization, Reference, Meta)
- Enforce ADR Context sections of at least 4-6 sentences with motivation, investigation, constraints
- Surface notable trade-offs from ADR Consequences in the architecture overview
- Tighten the edge case definition to: surprising states, error conditions, or non-obvious interactions
- Add workflow sequence notes for multi-command capabilities (e.g., quality-gates)
- Derive Design Rationale for spec-only docs from initial-spec research.md
- Shorten project README and link to docs/ for detailed reference
- Split ADR Consequences into Positive/Negative subsections, add References section
- Create standalone doc templates (`templates/docs/capability.md`, `adr.md`, `readme.md`)

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `user-docs`: Add Design Rationale for spec-only docs, tighten edge case definition, add workflow sequence guidance, add initial-spec BAD/GOOD example. Update TOC requirement to reflect consolidated README structure.
- `architecture-docs`: Change target file from `docs/architecture-overview.md` to `docs/README.md`. Add trade-offs requirement. Add ADR links in design decisions table.
- `decision-docs`: Split Consequences into Positive/Negative. Add References section. Enforce Context depth. Remove ADR index generation.
- `spec-format`: Add optional YAML frontmatter with `order` (integer) and `category` (string) fields to baseline specs. Update spec template.

## Impact

- `skills/docs/SKILL.md` — restructured steps, template references, improved prompt guidance
- `openspec/schemas/opsx-enhanced/templates/docs/` — 3 new template files
- `openspec/specs/user-docs/spec.md` — modified requirements
- `openspec/specs/architecture-docs/spec.md` — modified requirements
- `openspec/specs/decision-docs/spec.md` — modified requirements
- `openspec/specs/spec-format/spec.md` — modified requirements (frontmatter extension)
- `openspec/schemas/opsx-enhanced/templates/specs/spec.md` — updated spec template with frontmatter
- `openspec/specs/*/spec.md` — all 19 baseline specs get `order` + `category` frontmatter
- `docs/` — fully regenerated with new structure (2 files deleted, 1 consolidated, category-grouped TOC)
- `README.md` — shortened with links to docs/
- Consumer projects: `/opsx:docs` will produce new consolidated structure on next run. External links to `docs/architecture-overview.md` or `docs/decisions/README.md` will break.

## Scope & Boundaries

**In scope:**
- SKILL.md prompt improvements (all 11 items from Issue #13)
- Doc template creation
- Spec updates for user-docs, architecture-docs, decision-docs, spec-format
- Docs regeneration with improved prompt
- README shortening

**Out of scope:**
- Changes to other skills (new, ff, apply, verify, archive, etc.)
- Schema.yaml changes
- Constitution changes
- Changes to pipeline artifact templates (research, proposal, design, preflight, tasks) — except spec template which gets frontmatter extension
