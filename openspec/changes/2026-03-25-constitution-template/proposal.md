## Why

The constitution section structure (Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, Standard Tasks) is hardcoded inline in `skills/bootstrap/SKILL.md`. Every other generated artifact already has a dedicated template in `openspec/schemas/opsx-enhanced/templates/`. This inconsistency means the constitution structure cannot vary per schema and is harder to maintain.

## What Changes

- Add `openspec/schemas/opsx-enhanced/templates/constitution.md` containing the section headings and guidance comments currently hardcoded in the bootstrap skill
- Modify `skills/bootstrap/SKILL.md` to reference the schema template instead of defining sections inline

## Capabilities

### New Capabilities

(none — this is a refactoring of existing behavior, not a new capability)

### Modified Capabilities

- `constitution-management`: Add a requirement that the constitution section structure SHALL be defined by the schema's `templates/constitution.md` template, and the bootstrap skill SHALL read this template rather than defining sections inline.

### Consolidation Check

1. Existing specs reviewed: `constitution-management`, `project-bootstrap`, `project-setup`, `spec-format`, `artifact-generation`, `artifact-pipeline`
2. Overlap assessment: `constitution-management` already governs bootstrap-generated constitution (Requirement 1) and constitution structure (Requirement 4). The template extraction is a refinement of how the section structure is sourced — it belongs in this existing spec, not a new one.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- `skills/bootstrap/SKILL.md` — inline section list replaced with template reference
- `openspec/schemas/opsx-enhanced/templates/constitution.md` — new template file
- No downstream consumer impact — the generated `openspec/constitution.md` output is unchanged

## Scope & Boundaries

**In scope:**
- Creating the constitution template file
- Updating the bootstrap skill to reference it
- Adding a delta spec requirement to `constitution-management`

**Out of scope:**
- Changing the constitution's actual section content or order
- Supporting multiple schema variants (future work enabled by this change, not implemented here)
- Modifying how other skills read the constitution
