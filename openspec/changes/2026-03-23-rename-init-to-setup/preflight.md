# Pre-Flight Check: Rename init skill to setup

## A. Traceability Matrix

- [x] Install OpenSpec and Schema (modified) → Scenario: First-time init → `skills/setup/SKILL.md`
- [x] Install OpenSpec and Schema (modified) → Scenario: Idempotent re-init → `skills/setup/SKILL.md`
- [x] Install OpenSpec and Schema (modified) → Scenario: No duplicate skill creation → `skills/setup/SKILL.md`
- [x] Install OpenSpec and Schema (modified) → Scenario: Config generated from template → `skills/setup/SKILL.md`
- [x] Install OpenSpec and Schema (modified) → Scenario: Existing config preserved → `skills/setup/SKILL.md`
- [x] Install OpenSpec and Schema (modified) → Scenario: Config includes docs_language → `skills/setup/SKILL.md`
- [x] OpenSpec CLI Prerequisite Check (modified) → Scenario: CLI not installed → `skills/setup/SKILL.md`
- [x] OpenSpec CLI Prerequisite Check (modified) → Scenario: CLI already installed → `skills/setup/SKILL.md`
- [x] OpenSpec CLI Prerequisite Check (modified) → Scenario: npm not available → `skills/setup/SKILL.md`
- [x] OpenSpec CLI Prerequisite Check (modified) → Scenario: CLI incompatible version → `skills/setup/SKILL.md`
- [x] Skills Layer (modified) → Scenario: Setup is model-invocable → `skills/setup/SKILL.md`
- [x] Skills Layer (modified) → Scenario: All 13 skills present → `skills/*/SKILL.md`
- [x] End-to-End Install and Update Checklist (modified) → Scenario: Clean install flow → `README.md`, `docs/capabilities/release-workflow.md`
- [x] End-to-End Install and Update Checklist (modified) → Scenario: Update flow → `README.md`, `docs/capabilities/release-workflow.md`
- [x] Standalone Research with Q&A (modified) → Scenario: Prerequisite check fails → `skills/discover/SKILL.md`
- [x] Bootstrap edge case (modified) → Edge case: CLI not installed → `skills/bootstrap/SKILL.md`
- [x] Constitution management assumption (modified) → Assumption: config setup → `openspec/specs/constitution-management/spec.md`
- [x] Change workspace assumption (modified) → Assumption: CLI on PATH → `openspec/specs/change-workspace/spec.md`
- [x] User docs assumption (modified) → Assumption: schema copy → `openspec/specs/user-docs/spec.md`

## B. Gap Analysis

- **No gaps identified.** This is a pure text rename with no logic changes. All affected files are enumerated in the design's Architecture & Components table and validated by grep-based success metrics.

## C. Side-Effect Analysis

- **Plugin discovery**: Renaming the skill directory changes what Claude Code discovers. The new `skills/setup/` will be picked up automatically by the plugin system. The old `skills/init/` must be fully removed.
- **Cached plugins**: Users with cached plugin versions will still have the old `skills/init/`. After updating the plugin, the cache refreshes and the new `skills/setup/` takes effect. No migration needed — the old command wasn't working anyway (that's why we're fixing it).
- **Other skills referencing `/opsx:init` in error messages**: 5 skills (bootstrap, docs, discover, preflight, changelog) tell users to "run `/opsx:init` first" when the schema check fails. These must be updated to `/opsx:setup`.
- **No regression risk to existing functionality**: The skill behavior is unchanged; only the invocation name changes.

## D. Constitution Check

No constitution updates needed. This change introduces no new technologies, patterns, or architectural conventions. The constitution already references `/opsx:init` zero times (it uses generic terms like "skill immutability" and "post-archive version bump").

## E. Duplication & Consistency

- **No contradictions between delta specs**: All 8 delta specs consistently rename `/opsx:init` → `/opsx:setup` and `skills/init/` → `skills/setup/`.
- **No overlap with existing changes**: No other active changes touch the init skill or its references.
- **Consistency with baseline specs**: Each delta spec modifies only the references that exist in the corresponding baseline spec. No new requirements introduced.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | npm global install is correct for OpenSpec CLI | project-setup spec | Acceptable Risk | Inherited from baseline — unchanged by this rename |
| 2 | `^1.2.0` version constraint via npm semver | project-setup spec | Acceptable Risk | Inherited from baseline — unchanged by this rename |
| 3 | `openspec schema init` works without prior `openspec init` | project-setup spec | Acceptable Risk | Previously verified by testing — unchanged |
| 4 | OpenSpec CLI on PATH as ensured by setup | change-workspace spec | Acceptable Risk | Prerequisite chain unchanged, just the command name |
| 5 | Config.yaml rules configured during setup | constitution-management spec | Acceptable Risk | Setup skill behavior unchanged, only the name |
| 6 | Schema copy includes subdirectories | user-docs spec | Acceptable Risk | Copy mechanism unchanged, only the command name |

No assumptions rated as Needs Clarification or Blocking.
