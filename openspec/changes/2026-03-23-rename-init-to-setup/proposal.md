## Why

The `init` skill name conflicts with Claude Code's built-in `/init` command (which creates CLAUDE.md). This makes `/opsx:init` unavailable to users. Other `/opsx:*` skills work fine — only `init` is affected. Renaming to `setup` resolves the conflict immediately without waiting for an upstream fix.

## What Changes

- **BREAKING**: Rename `skills/init/` directory to `skills/setup/`
- Update skill frontmatter from `name: init` to `name: setup`
- Update all `/opsx:init` references to `/opsx:setup` in active files
- Update all `skills/init/` path references to `skills/setup/` in active files
- Leave archive files, CHANGELOG, and ADRs unchanged (historical records)

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `project-setup`: The skill name changes from `/opsx:init` to `/opsx:setup` throughout the spec — user stories, Gherkin scenarios, and requirement text all reference the command name.
- `three-layer-architecture`: References the `skills/init/SKILL.md` file path which changes to `skills/setup/SKILL.md`.
- `project-bootstrap`: References `/opsx:init` as a prerequisite command in error messages.
- `interactive-discovery`: References `/opsx:init` as a prerequisite command in error messages.
- `constitution-management`: References `/opsx:init` in config setup assumptions.
- `change-workspace`: References `/opsx:init` in CLI prerequisite assumptions.
- `release-workflow`: References `/opsx:init` in install/update workflow scenarios.
- `user-docs`: References `/opsx:init` in schema copy assumptions.

## Impact

- **Skills**: 6 skill files reference `/opsx:init` in error messages or prerequisites (bootstrap, docs, discover, preflight, changelog, and init itself)
- **Specs**: 8 baseline specs reference `/opsx:init` or the `skills/init/` path
- **Docs**: README, schema README, docs index, and 5 capability docs reference `/opsx:init`
- **Users**: Anyone using `/opsx:init` must switch to `/opsx:setup` — this is a breaking change in the command interface

## Scope & Boundaries

**In scope:**
- Rename the skill directory and frontmatter
- Update all references in active specs, skills, docs, and README
- Update internal SKILL.md heading and self-references

**Out of scope:**
- Archive files (`openspec/changes/archive/*`) — historical records
- CHANGELOG.md — historical release notes
- ADR documents (`docs/decisions/adr-*.md`) — historical decisions
- Any logic or behavior changes — this is purely a rename
