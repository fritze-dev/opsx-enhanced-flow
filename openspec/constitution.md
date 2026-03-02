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
- All 13 commands are delivered as `skills/*/SKILL.md` files
- Skills split into: 6 workflow (new, continue, ff, apply, verify, archive), 5 governance (init, bootstrap, discover, preflight, sync), 2 documentation (changelog, docs)
- All skills are model-invocable (including `init` — idempotent one-time setup)
- Artifact pipeline: research → proposal → specs → design → preflight → tasks → apply
- Each pipeline stage produces a verifiable artifact that gates progression to the next
- Plugin manifests live in `.claude-plugin/` (plugin.json, marketplace.json)
- Schema source of truth: `openspec/schemas/opsx-enhanced/`
- Baseline specs: `openspec/specs/<capability>/spec.md` (one directory per capability)
- Delta specs: `openspec/changes/<feature>/specs/<capability>/spec.md`
- Archives: `openspec/changes/archive/YYYY-MM-DD-<feature>/`

## Code Style

- **Spec format (strict ordering):**
  1. `### Requirement: <name>` header
  2. Normative description using SHALL/MUST (mandatory)
  3. Optional: `**User Story:** As a [role] I want [goal], so that [benefit]`
  4. `#### Scenario: <name>` with GIVEN/WHEN/THEN (exactly 4 hashtags — 3 hashtags fail silently)
- **Markdown heading hierarchy:** `#` title → `##` section → `###` requirement → `####` scenario
- **Task format:** `- [ ]` checkboxes, `[P]` for parallelizable tasks, numbered section groups
- **YAML:** 2-space indentation, `|` for multiline strings
- **Assumptions:** `<!-- ASSUMPTION: [reason] -->` — audited in preflight
- **Review markers:** `<!-- REVIEW -->` — for items needing user confirmation
- **Capability names:** kebab-case (e.g., `three-layer-architecture`, `project-setup`)

## Constraints

- OpenSpec CLI version MUST be compatible with `^1.2.0`
- Pre-Flight check is mandatory before task creation
- Constitution MUST be read before any AI action (via config.yaml workflow rules)
- Verify findings are binding — critical/warning issues MUST be resolved before archiving
- No silent archiving — explicit human "Approved" required in QA loop
- Bidirectional feedback — when implementation reveals issues, update specs and design (not just code)
- Baseline specs use `## Purpose` + `## Requirements` (no ADDED/MODIFIED prefix)
- Delta specs use operation prefixes: `## ADDED Requirements`, `## MODIFIED Requirements`, etc.

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Archive naming:** `YYYY-MM-DD-<feature-name>`
- **Artifact files:** Fixed names (research.md, proposal.md, design.md, preflight.md, tasks.md)
- **Spec merging:** Agent-driven via `/opsx:sync` (intelligent merge, not programmatic)
- **Documentation:** One doc per capability under `docs/capabilities/`, user-facing language only
- **Changelog:** Keep a Changelog format, newest first, user perspective
- **Recovery:** Small drift → `/opsx:new hotfix-xyz`; large drift → `/opsx:bootstrap` re-run
