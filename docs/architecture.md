# Architecture

## System Architecture

The opsx-enhanced plugin uses a **three-layer architecture** where each layer has distinct responsibilities and can be modified independently:

1. **Constitution** (`openspec/constitution.md`) — Global project rules including Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Read before every AI action via config.yaml workflow rules. Serves as the single authoritative source for project-wide rules.

2. **Schema** (`openspec/schemas/opsx-enhanced/`) — Defines the 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks) with templates, instructions, and dependency ordering. Single source of truth for pipeline structure.

3. **Skills** (`skills/*/SKILL.md`) — 13 commands delivered as SKILL.md files within the Claude Code plugin system. Categorized as workflow (6: new, continue, ff, apply, verify, archive), governance (5: setup, bootstrap, discover, preflight, sync), and documentation (2: changelog, docs). All skills are model-invocable.

Layers are independently modifiable — the schema does not embed skill logic, skills depend on the schema via the OpenSpec CLI, and the constitution does not contain schema-specific artifact definitions.

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (schema.yaml, config.yaml)
- **Shell:** Bash (skill command execution)
- **Core dependency:** OpenSpec CLI (`@fission-ai/openspec@^1.2.0`)
- **Runtime:** Node.js + npm (required for OpenSpec CLI)
- **Platform:** Claude Code plugin system
- **Package manager:** npm (global installs only — no project-level package.json)

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-archive version bump:** After `/opsx:archive`, automatically increment patch version in `.claude-plugin/plugin.json` and sync `marketplace.json`. For minor/major releases, manually set versions, create a git tag, and push.
- **README accuracy:** When plugin behavior changes, update the README to reflect the new state.
- **Workflow friction:** Capture friction as GitHub Issues with the `friction` label.
- **Design review checkpoint:** After creating specs + design artifacts, always pause for user alignment before preflight/tasks.
- **No ADR references in specs:** Specs must not reference ADRs — ADRs are generated after archiving.
