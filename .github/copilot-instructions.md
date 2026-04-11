# Project Instructions

This is a Claude Code plugin built entirely from Markdown and YAML — there is no executable code. All changes go through the OpenSpec workflow.

## Architecture

Three-layer model:

1. **CONSTITUTION.md** (`openspec/CONSTITUTION.md`) — Global rules, conventions, and constraints
2. **WORKFLOW.md + Smart Templates** (`openspec/WORKFLOW.md`, `openspec/templates/`) — Artifact pipeline and inline actions
3. **Router skill** (`src/skills/workflow/SKILL.md`) — Single workflow skill with actions: `init`, `propose`, `apply`, `finalize`

Layers are independently modifiable. The router skill is generic plugin code shared across consumers and must not be modified for project-specific behavior.

## Workflow Rules

All changes MUST go through the OpenSpec flow:

- `/workflow propose` — Create a change with planning artifacts (research, proposal, design, tasks)
- `/workflow apply` — Implement tasks, verify with review.md, get approval
- `/workflow finalize` — Generate changelog, docs, bump version

Never edit specs, skills, templates, or docs directly. Always create a change first.

## Key Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`, `Add: ...`)
- **YAML:** 2-space indentation, `|` for multiline strings
- **Plugin source layout:** Plugin source lives in `src/` (skills, templates, plugin.json). Project files (docs, CI, specs, changelog) stay at the repo root.
- **Template sync:** Changes to `openspec/WORKFLOW.md` must also be reflected in `src/templates/workflow.md`
- **Copilot instructions sync:** When project rules in CONSTITUTION.md change, review this file for necessary updates

## Reference

See `openspec/CONSTITUTION.md` for the full set of project rules, constraints, and conventions.
