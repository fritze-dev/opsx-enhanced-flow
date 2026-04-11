# Project Rules

## Workflow

All changes to this project MUST go through the OpenSpec flow (`/workflow propose`, `/workflow apply`, etc.). Never edit specs, skills, templates, or docs directly — always create a change first.

## Knowledge Management

Do not use auto-memory for project knowledge (architecture decisions, conventions, design rationale, workflow patterns). Instead:
- **Rules/conventions** → propose a CONSTITUTION.md update via `/workflow propose`
- **Decisions with rationale** → these emerge naturally as design.md artifacts and ADRs during the change flow
- **Requirements** → propose spec updates via `/workflow propose`
- **Friction/bugs** → file a GitHub Issue

Auto-memory is appropriate only for user preferences and session-specific feedback that do not belong in project artifacts.
