## Why

All generated user-facing documentation (capability docs, ADRs, README, CHANGELOG) is produced exclusively in English. Non-English-speaking teams cannot use the documentation output in their preferred language. A configurable `docs_language` field in `openspec/config.yaml` enables teams to generate documentation in any language while keeping internal workflow artifacts in English.

## What Changes

- Add `docs_language` field (commented out, defaults to English) to the init skill's config template
- Add English-enforcement rule for workflow artifacts to the init skill's config `context` field
- Add "Step 0: Determine Documentation Language" to the docs skill (`/opsx:docs`)
- Add translation reminders to docs skill Steps 3 (capability docs), 4 (ADRs), 5 (README)
- Add "Step 0: Determine Documentation Language" to the changelog skill (`/opsx:changelog`)
- Add translation reminder to changelog skill Step 6 (entry generation)

## Capabilities

### New Capabilities

_None_

### Modified Capabilities

- `project-setup`: Add `docs_language` field and English-enforcement context to the config.yaml template in the init skill
- `user-docs`: Add language determination step and translation reminders for capability doc generation
- `architecture-docs`: Add translation reminders for architecture overview generation (part of docs skill Step 5)
- `decision-docs`: Add translation reminders for ADR generation (part of docs skill Step 4)
- `release-workflow`: Add language determination step and translation reminders for changelog generation

## Impact

- **Skills affected**: `skills/docs/SKILL.md`, `skills/changelog/SKILL.md`, `skills/init/SKILL.md`
- **Config surface**: New optional `docs_language` field in `openspec/config.yaml`
- **No breaking changes**: Missing field defaults to English — fully backward-compatible
- **No schema changes**: Language is a generation-time concern, not a pipeline concern

## Scope & Boundaries

**In scope:**
- `docs_language` config field via init skill template
- English enforcement for workflow artifacts via config `context`
- Translation logic in docs skill (capability docs, ADRs, README)
- Translation logic in changelog skill

**Out of scope:**
- Doc templates (`templates/docs/`) — remain English structural guides
- Schema (`schema.yaml`) — not affected
- Other skills (new, ff, apply, verify, archive, bootstrap, etc.) — not affected
- Workflow artifacts (research, proposal, specs, design, preflight, tasks) — always English
