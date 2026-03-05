## Why

The current project configuration is split across two files (`openspec/constitution.md` for prose rules and `openspec/config.yaml` for schema reference), with no structured settings, no machine-readable project metadata, and no prompt template mechanism. Inspired by OpenAI Symphony's `WORKFLOW.md` repository contract, this change introduces a single, version-controlled `WORKFLOW.md` file with YAML front matter for structured settings and a markdown body as the agent prompt template — giving teams one canonical place to define and evolve their AI workflow behavior.

## What Changes

- **NEW**: `WORKFLOW.md` file format — YAML front matter (project metadata, custom settings) + markdown body (agent prompt context/template) as the authoritative project workflow contract
- **NEW**: `/opsx:init` generates `WORKFLOW.md` in new projects; existing projects receive a migration path
- **MODIFIED**: Agent skills read `WORKFLOW.md` when present; fall back to `constitution.md` for backward compatibility
- **MODIFIED**: `openspec/config.yaml` is superseded by `WORKFLOW.md` for projects that adopt the new format
- **NEW**: WORKFLOW.md specification documenting the format, required/optional front matter fields, and prompt template variable syntax

## Capabilities

### New Capabilities
- `workflow-contract`: Defines the `WORKFLOW.md` format — YAML front matter schema for opsx settings (schema, project name, custom phases, agent behavior overrides) and markdown body as a Liquid-compatible prompt template. Covers file structure, parsing rules, field definitions, template variable syntax, and backward compatibility behavior.

### Modified Capabilities
- `project-setup`: Requirements change to reflect that `/opsx:init` now generates `WORKFLOW.md` instead of (or alongside) `config.yaml` and `constitution.md`.

## Impact

- **`openspec/config.yaml`**: Superseded for projects adopting `WORKFLOW.md`; retained for backward compatibility
- **`openspec/constitution.md`**: Superseded by `WORKFLOW.md` markdown body for projects adopting the new format; retained as fallback
- **Skills (`skills/`)**: Skills must read `WORKFLOW.md` when present. Per the constitution, skills are generic plugin code and MUST NOT be modified for project-specific behavior — however, the skill invocation preamble (reading project context) MAY reference `WORKFLOW.md` as the preferred context source.
- **`/opsx:init` skill**: Must scaffold `WORKFLOW.md` in new projects
- **Schema (`openspec/schemas/opsx-enhanced/schema.yaml`)**: `context` field should reference `WORKFLOW.md` when present
- **External dependency**: No new dependencies — `WORKFLOW.md` is plain markdown with YAML front matter, parseable by the agent natively

## Scope & Boundaries

**In scope:**
- `WORKFLOW.md` format specification (YAML front matter fields + markdown body template)
- Backward compatibility behavior (fallback to `constitution.md` when `WORKFLOW.md` absent)
- `/opsx:init` scaffolding `WORKFLOW.md` for new projects
- Updated `project-setup` spec reflecting the new init behavior
- Migration guidance for existing projects (documented in `WORKFLOW.md` spec)

**Out of scope:**
- Real-time file watching / dynamic reload (not applicable to a Claude Code plugin context)
- Full Liquid template engine (minimal `{{ variable }}` substitution only)
- Changes to the OpenSpec CLI (`@fission-ai/openspec`) — `WORKFLOW.md` is an agent-level convention, not a CLI feature
- Changes to existing skills files (skills remain generic per the constitution)
