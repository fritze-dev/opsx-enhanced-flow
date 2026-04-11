---
id: claude
template-version: 2
description: AGENTS.md bootstrap template with standard agent directives
generates: AGENTS.md
requires: []
instruction: |
  Generate AGENTS.md with project-specific agent instructions.
  Always include the Workflow and Knowledge Management sections.
  Add project-specific rules discovered during codebase analysis.
  Use REVIEW markers for items needing user confirmation.
  After generating AGENTS.md, create a symlink: CLAUDE.md → AGENTS.md
---
# Project Rules

## Workflow

All changes to this project MUST go through the OpenSpec workflow skill (actions: propose, apply, finalize, init). Never edit specs, skills, templates, or docs directly — always create a change first.

## Knowledge Management

Do not use auto-memory for project knowledge (architecture decisions, conventions, design rationale, workflow patterns). Instead:
- **Rules/conventions** → propose a CONSTITUTION.md update via the workflow skill (propose action)
- **Decisions with rationale** → these emerge naturally as design.md artifacts and ADRs during the change flow
- **Requirements** → propose spec updates via the workflow skill (propose action)
- **Friction/bugs** → file a GitHub Issue

Auto-memory is appropriate only for user preferences and session-specific feedback that do not belong in project artifacts.
