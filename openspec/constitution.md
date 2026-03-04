# Project Constitution

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (schema.yaml, config.yaml)
- **Shell:** Bash (skill command execution)
- **Core dependency:** OpenSpec CLI (`@fission-ai/openspec@^1.2.0`)
- **Runtime:** Node.js + npm (required for OpenSpec CLI)
- **Platform:** Claude Code plugin system
- **Package manager:** npm (global installs only — no project-level package.json)

## Architecture Rules

- **Three-layer architecture:** Constitution (global rules) → Schema (artifact pipeline) → Skills (user commands)
- Layers are independently modifiable — schema does not embed skill logic, skills depend on schema via CLI
- **Skill immutability:** Skills in `skills/` are generic plugin code shared across all consumers. They MUST NOT be modified for project-specific behavior. Project-specific workflows and conventions MUST be defined in this constitution.
- Plugin manifests live in `.claude-plugin/` (plugin.json, marketplace.json)
- Schema source of truth: `openspec/schemas/opsx-enhanced/`
- Baseline specs: `openspec/specs/<capability>/spec.md` (one directory per capability)
- Delta specs: `openspec/changes/<feature>/specs/<capability>/spec.md`
- Archives: `openspec/changes/archive/YYYY-MM-DD-<feature>/`

## Code Style

- **YAML:** 2-space indentation, `|` for multiline strings
- **Review markers:** `<!-- REVIEW -->` — for items needing user confirmation

## Constraints

- Baseline specs use `## Purpose` + `## Requirements` (no ADDED/MODIFIED prefix)

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-archive version bump:** After `/opsx:archive` completes successfully, automatically increment the patch version in `.claude-plugin/plugin.json` (e.g., `1.0.3` → `1.0.4`) and sync the `version` field in `.claude-plugin/marketplace.json` to match. If versions are out of sync, use `plugin.json` as source of truth. Display the new version in the archive summary and show next steps: `/opsx:changelog` → push → update plugin (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`). For intentional minor/major releases, manually set the version in both files, create a git tag (`v<version>`), push the tag, and optionally create a GitHub Release via `gh release create`.
- **README accuracy:** When plugin behavior changes (skills, schema, config, constitution, architecture), update the README to reflect the new state. The README is the primary user-facing documentation and must stay consistent with the implementation.
- **Workflow friction:** When workflow execution reveals friction, capture it as a GitHub Issue with the `friction` label. Include: what happened, expected behavior, and suggested fix.
