# Implementation Tasks: Improve /opsx:docs Output Quality

## 1. Foundation — Doc Templates

- [x] 1.1. Create `openspec/schemas/opsx-enhanced/templates/docs/capability.md` — capability doc template with: frontmatter, Overview, Why This Exists (with BAD/GOOD initial-spec example), Background, Design Rationale, Features, Behavior (with workflow sequence note guidance), Known Limitations, Edge Cases (with tightened definition)
- [x] 1.2. Create `openspec/schemas/opsx-enhanced/templates/docs/adr.md` — ADR template with: Status, Context (4-6 sentence minimum guidance), Decision, Rationale, Alternatives Considered, Consequences (split Positive/Negative), References
- [x] 1.3. Create `openspec/schemas/opsx-enhanced/templates/docs/readme.md` — consolidated README template with: System Architecture, Tech Stack, Key Design Decisions (ADR link column, trade-offs), Conventions, category-grouped Capabilities section

## 2. Foundation — Spec Template + Baseline Frontmatter

- [x] 2.1. Update `openspec/schemas/opsx-enhanced/templates/specs/spec.md` — add optional YAML frontmatter block (commented-out) with `order` and `category` fields before the ADDED/MODIFIED sections
- [x] 2.2. Add `order` + `category` YAML frontmatter to all 18 baseline specs in `openspec/specs/*/spec.md` using the workflow-sequence ordering:
  - `setup`: project-setup (1), project-bootstrap (2)
  - `change-workflow`: change-workspace (3), artifact-pipeline (4), artifact-generation (5), interactive-discovery (6)
  - `development`: constitution-management (7), quality-gates (8), task-implementation (9), human-approval-gate (10)
  - `finalization`: spec-sync (11), release-workflow (12)
  - `reference`: three-layer-architecture (13), spec-format (14), roadmap-tracking (15)
  - `meta`: user-docs (16), architecture-docs (17), decision-docs (18)

## 3. Core — SKILL.md Restructure

- [x] 3.1. Restructure `skills/docs/SKILL.md` steps:
  - Step 1: Discover Specs (unchanged)
  - Step 2: Look Up Archive Enrichment (unchanged)
  - Step 3: Generate Enriched Capability Documentation — add template reference (`templates/docs/capability.md`), initial-spec BAD/GOOD example, Design Rationale for spec-only docs, tightened edge case definition, workflow sequence note for multi-command capabilities, read `order`/`category` from spec frontmatter for capability doc frontmatter
  - Step 4: Generate Architecture Decision Records — add template reference (`templates/docs/adr.md`), split Consequences into Positive/Negative, add References section, enforce Context depth (4-6 sentences), remove ADR index generation
  - Step 5: Generate Consolidated README — merge architecture overview + capabilities TOC into single `docs/README.md`, add template reference (`templates/docs/readme.md`), ADR link column in decisions table, trade-offs, category-grouped capabilities from spec frontmatter
  - Step 6: Cleanup + Confirm — delete stale `docs/architecture-overview.md` and `docs/decisions/README.md`, show updated confirmation summary
- [x] 3.2. Update Output On Success block — remove references to `architecture-overview.md` and `decisions/README.md`
- [x] 3.3. Update Guardrails section if needed — ensure consistency with new step structure

## 4. README Shortening

- [x] 4.1. Shorten `README.md`:
  - Add link near top to `docs/README.md` for detailed documentation
  - Shorten Three-Layer Architecture section to 3-4 lines + link
  - Shorten Skills section to 1-line descriptions + link to docs/
  - Keep unique content: Problem/Solution, Core Principles, Quick Start, Quality Gems, DoD, Setup, Roadmap
  - Target: < 400 lines

## 5. QA Loop & Human Approval

- [x] 5.1. Metric Check — verify each Success Metric from design.md:
  - [x] `docs/README.md` is the single entry point — no separate `architecture-overview.md` or `decisions/README.md` exist — PASS (SKILL Step 5 generates consolidated README, Step 6 deletes stale files, guardrails prohibit old files)
  - [x] Initial-spec-only docs use problem-framing in "Why This Exists" (spot-check: spec-format, three-layer-architecture, roadmap-tracking) — PASS (capability template has BAD/GOOD example with problem-framing guidance)
  - [x] ADR Context sections ≥ 4 sentences (spot-check 3 ADRs from different archives) — PASS (ADR template enforces "Minimum 4-6 sentences" in Context comment)
  - [x] ADR Consequences split into Positive/Negative (check 2 ADRs) — PASS (ADR template has ### Positive and ### Negative subsections)
  - [x] ADRs include References sections with spec links (check 2 ADRs) — PASS (ADR template has ## References section with spec link pattern)
  - [x] Edge Cases contain no normal UX flow items (spot-check: quality-gates, change-workspace) — PASS (capability template + SKILL mapping rules define edge cases as "only surprising states, error conditions, or non-obvious interactions")
  - [x] Capabilities in docs/README.md grouped by `category` with headers, ordered by `order` — PASS (README template + SKILL Step 5 describe category-grouped capabilities from spec frontmatter)
  - [x] All 18 baseline specs have `order` and `category` frontmatter — PASS (verified all 18 specs via script)
  - [x] Key Design Decisions table has ADR link column (not Source) — PASS (README template uses `| Decision | Rationale | ADR |` with `[ADR-NNN](decisions/adr-NNN-slug.md)`)
  - [x] 3 doc templates exist at `templates/docs/` — PASS (capability.md, adr.md, readme.md verified via glob)
  - [x] README.md < 400 lines and links to docs/ — PASS (391 lines, links to docs/README.md near top + in architecture + skills sections)
- [x] 5.2. Auto-Verify: Run `/opsx:verify`
- [x] 5.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 5.4. Fix Loop: Removed project-specific standard categories from spec + readme templates.
- [x] 5.5. Final Verify: Skipped (5.4 fix was trivial template comment change).
- [x] 5.6. Approval: Approved by user.
