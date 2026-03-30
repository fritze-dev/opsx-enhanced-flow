# Pre-Flight Check: Improve Docs Sections

## A. Traceability Matrix

- [x] Enriched Capability Documentation → Scenarios (single cap, normative language, Gherkin, impl details, enriched, spec-only, Purpose problem-framing, initial-spec Rationale, multi-command, edge cases, conciseness, template) → `skills/docs/SKILL.md`, `openspec/schemas/opsx-enhanced/templates/docs/capability.md`, `docs/capabilities/*.md`
- [x] Documentation Table of Contents → Scenarios (consolidated README, stale cleanup, category grouping, no-category, ADR links, trade-offs) → `docs/README.md` (no changes in this PR — already correct)

## B. Gap Analysis

- **No gaps identified.** All heading renames are mechanical. Future Enhancements sections are additive. SKILL.md guidance changes are self-contained.
- Edge case coverage is unchanged — existing edge cases in the spec remain valid.

## C. Side-Effect Analysis

- **Plugin SKILL.md**: Changed enrichment guidance affects all future `/opsx:docs` runs. This is the intended fix. Consumer projects using the plugin will get the updated guidance on next plugin update.
- **Existing docs**: Heading renames mean any external links referencing `#why-this-exists` or `#background` anchors will break. Acceptable — these are internal docs, not public API.
- **No regression risk to other skills**: Changes are isolated to `skills/docs/SKILL.md` and the doc template.

## D. Constitution Check

- No constitution changes needed. The changes respect skill immutability (SKILL.md changes are generic, not project-specific). No new technologies or patterns introduced.

## E. Duplication & Consistency

- **Consistency verified**: The three sources of truth (spec, SKILL.md, template) now use identical terminology: "Purpose", "Rationale", "Known Limitations", "Future Enhancements".
- **No duplication**: Each file has a distinct role — spec defines requirements, SKILL.md defines agent behavior, template defines output structure.
- **No contradictions** with other specs in `openspec/specs/`.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Schema copy includes subdirectories (templates/docs/) | spec.md | Acceptable Risk | Verified: `openspec schema init` copies full schema directory including templates |
| 2 | Agent compliance with SKILL.md guidance | design.md | Acceptable Risk | Well-written guidance with explicit BAD/GOOD examples has high compliance; hard enforcement would require code changes outside scope |
| 3 | Regeneration happens before docs drift significantly | design.md | Acceptable Risk | Tracked in friction issue #18; bootstrap recovery mode will handle this |
