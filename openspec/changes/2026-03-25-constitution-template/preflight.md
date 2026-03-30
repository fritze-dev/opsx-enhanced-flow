# Pre-Flight Check: Constitution Template Extraction

## A. Traceability Matrix

- [x] Requirement: Constitution Structure Defined by Schema Template → Scenario: Bootstrap reads constitution template from schema → `templates/constitution.md` (new), `skills/bootstrap/SKILL.md` (modified)
- [x] Requirement: Constitution Structure Defined by Schema Template → Scenario: Template defines structure not content → `templates/constitution.md` (new)
- [x] Requirement: Constitution Structure Defined by Schema Template → Scenario: Section order preserved from template → `templates/constitution.md` (new), `skills/bootstrap/SKILL.md` (modified)
- [x] Requirement: Bootstrap-Generated Constitution (MODIFIED) → Scenario: Constitution generated from codebase scan → `skills/bootstrap/SKILL.md` (modified)
- [x] Requirement: Bootstrap-Generated Constitution (MODIFIED) → Scenario: Constitution covers standard sections → `templates/constitution.md` (new), `skills/bootstrap/SKILL.md` (modified)
- [x] All remaining Bootstrap-Generated Constitution scenarios (uncertain conventions, no invented rules, no REVIEW markers) → unchanged behavior, no new components

## B. Gap Analysis

No gaps identified:
- Edge case "template file missing" is covered in the spec (fallback to hardcoded defaults with warning)
- Edge case "empty template" is covered in the spec
- Edge case "custom sections" is covered in the spec
- Error handling: Bootstrap Step 0 already validates schema existence; template read failure is handled by the fallback

## C. Side-Effect Analysis

- **No regression risk**: The generated `openspec/constitution.md` output is structurally identical. Only the source of section definitions changes (template file vs inline).
- **No downstream impact**: Skills reading `openspec/constitution.md`, `schema.yaml` task generation, and `docs/readme.md` template references are all unchanged — they consume the generated output, not the bootstrap skill's internals.
- **Re-run mode (Steps 7-9)**: Not affected — re-run reads the existing constitution, not the template.

## D. Constitution Check

No constitution updates needed. This change does not introduce new technologies, patterns, or conventions — it refactors where existing section structure is stored.

## E. Duplication & Consistency

- **No duplication**: The inline block in `SKILL.md` is being removed, not duplicated. The template becomes the single source of truth.
- **Consistency with existing specs**: The `constitution-management` spec's Requirement 4 ("Constitution Contains Only Project-Specific Rules") lists the expected sections (Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, Standard Tasks). The template will define exactly these sections — consistent.
- **No contradictions** with `project-bootstrap`, `project-setup`, or other existing specs.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | Schema resolution happens in bootstrap Step 1 | spec.md | Acceptable Risk — Step 0 already runs `openspec schema which`, confirmed in `SKILL.md` line 17 |
| 2 | Consistent template directory structure (`templates/constitution.md`) | spec.md | Acceptable Risk — all existing templates follow this convention |
| 3 | Schema path resolution available in bootstrap | design.md | Acceptable Risk — already used in Step 0 |

All assumptions are Acceptable Risk. No items need clarification or are blocking.

## G. Review Marker Audit

Scanned all change artifacts (research.md, proposal.md, specs/constitution-management/spec.md, design.md):
- Zero `<!-- REVIEW -->` markers found.
- Zero `<!-- REVIEW: ... -->` markers found.

**Verdict: PASS**
