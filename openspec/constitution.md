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
- **Version bump:** Every commit that changes plugin behavior (skills, schema, config, constitution) MUST bump the `version` field in `.claude-plugin/plugin.json`. Without a version bump, `/plugin update` won't detect changes in target projects.
- **Workflow friction:** When workflow execution reveals friction, capture it as a GitHub Issue with the `friction` label. Include: what happened, expected behavior, and suggested fix.
