# Pre-Flight Check: Documentation Ecosystem

## A. Traceability Matrix

- [x] `user-docs` — User Story "clear documentation + why it exists + limitations" → Scenarios: single capability, normative language, Gherkin conversion, implementation details excluded, enriched with archive, spec-only fallback, initial-spec fallback, conciseness guards → Component: `skills/docs/SKILL.md` Steps 1-3
- [x] `user-docs` — Requirement "Generate Documentation TOC" → Scenario: TOC includes all doc sections → Component: `skills/docs/SKILL.md` Step 6
- [x] `architecture-docs` — User Story "single document for system architecture" → Scenarios: architecture overview generated, overview without design artifacts → Component: `skills/docs/SKILL.md` Step 4
- [x] `decision-docs` — User Story "formal decision records" → Scenarios: ADRs from single archive, numbering across archives, context enriched with research, archive without design.md, ADR index → Component: `skills/docs/SKILL.md` Step 5
- [x] `release-workflow` (ADDED) — Requirement "Generate Changelog from Archives" → Scenarios: single archive, multiple archives ordered, existing preserved, no archives, internal refactoring → Component: `skills/changelog/SKILL.md` (unchanged behavior, spec moved)
- [x] `docs-generation` (REMOVED) — Requirements split into `user-docs` + `release-workflow`. Migration paths documented.

## B. Gap Analysis

- **No gaps identified.** All requirements have scenarios, all scenarios map to SKILL.md steps.
- Edge cases covered: missing archive artifacts, no archives, missing design.md, Decisions table format variants, initial-spec bootstrap handling, no constitution, no three-layer-architecture spec.
- The `docs-generation` REMOVED spec documents migration paths for both requirements.

## C. Side-Effect Analysis

- **Existing capability docs** will gain new sections (Why This Exists, Background, Known Limitations) — additive change, no sections removed.
- **`docs/README.md`** TOC structure changes — links to architecture overview and decisions added. Existing capability table preserved.
- **New directories** created: `docs/decisions/`. No impact on existing files.
- **Spec restructuring**: `docs-generation` baseline spec will be removed after sync. `user-docs`, `architecture-docs`, `decision-docs` baseline specs will be created. `release-workflow` baseline spec will gain changelog requirement. No impact on runtime behavior — specs are documentation, not code.
- **No risk to `/opsx:changelog`** — unchanged behavior, skill untouched, spec just moves to different capability.
- **Regression risk: low** — this modifies a skill prompt (SKILL.md), not code.

## D. Constitution Check

- No constitution updates needed. The post-archive workflow already calls `/opsx:docs`. The expanded output is transparent to the constitution.
- Skill immutability rule satisfied: this is a spec'd change to the skill itself, not project-specific customization.

## E. Duplication & Consistency

- **No duplication** between `user-docs` and `decision-docs`: capability docs get "Known Limitations" (from Non-Goals + Risks), ADRs get the full decision record. Different perspectives, no overlap.
- **Changelog requirement** moved cleanly: identical content from `docs-generation` to `release-workflow`. REMOVED spec documents migration.
- **No contradictions** between new specs and existing specs in `openspec/specs/`.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Docs generated after sync | user-docs spec | Acceptable Risk | Enforced by post-archive workflow sequence |
| 2 | Archive naming enforced by archive skill | user-docs + release-workflow specs | Acceptable Risk | Observed in all 5 existing archives |
| 3 | initial-spec is a bootstrap change | user-docs spec | Acceptable Risk | Verified: proposal "Why" describes spec creation |
| 4 | Constitution maintained by archive workflow | architecture-docs spec | Acceptable Risk | Constitution updated during design phase per schema |
| 5 | Artifacts follow schema templates | decision-docs spec | Acceptable Risk | All archives created by opsx-enhanced workflow |
| 6 | Keep a Changelog format convention | release-workflow spec | Acceptable Risk | Documented in constitution |
| 7 | SKILL.md is the only implementation file | design.md | Acceptable Risk | All behavior is prompt-driven, no code |
| 8 | Glob `archive/*/specs/<capability>/` reliably finds archives | design.md | Acceptable Risk | Archive structure consistent, enforced by archive skill |
| 9 | Decisions table format is consistent (3-col or 4-col) | design.md | Acceptable Risk | Verified across all 4 design.md files in archives |
