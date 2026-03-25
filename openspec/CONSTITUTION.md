# Project Constitution

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (WORKFLOW.md frontmatter, Smart Template frontmatter)
- **Shell:** Bash (skill command execution)
- **Platform:** Claude Code plugin system

## Architecture Rules

- **Three-layer architecture:** CONSTITUTION.md (global rules) → WORKFLOW.md + Smart Templates (artifact pipeline) → Skills (user commands)
- Layers are independently modifiable — WORKFLOW.md and Smart Templates do not embed skill logic, skills depend on them via direct file reads
- **Skill immutability:** Skills in `skills/` are generic plugin code shared across all consumers. They MUST NOT be modified for project-specific behavior. Project-specific workflows and conventions MUST be defined in this constitution.
- Plugin manifests live in `.claude-plugin/` (plugin.json, marketplace.json)
- Pipeline source of truth: `openspec/WORKFLOW.md` (orchestration) + `openspec/templates/` (Smart Templates)
- Baseline specs: `openspec/specs/<capability>/spec.md` (one directory per capability)
- Delta specs: `openspec/changes/<feature>/specs/<capability>/spec.md`
- Archives: `openspec/changes/archive/YYYY-MM-DD-<feature>/`

## Code Style

- **YAML:** 2-space indentation, `|` for multiline strings
- **Review markers:** `<!-- REVIEW -->` — transient markers for items needing user confirmation. Skills that write REVIEW markers (bootstrap, docs) must auto-resolve them: iterate each marker, ask the user, document the decision, and remove the marker. No REVIEW markers should persist in final output.

## Constraints

- Baseline specs use `## Purpose` + `## Requirements` (no ADDED/MODIFIED prefix)

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-archive version bump:** After `/opsx:archive` completes successfully, automatically increment the patch version in `.claude-plugin/plugin.json` (e.g., `1.0.3` → `1.0.4`) and sync the `version` field in `.claude-plugin/marketplace.json` to match. If versions are out of sync, use `plugin.json` as source of truth. Display the new version in the archive summary. For intentional minor/major releases, manually set the version in both files, create a git tag (`v<version>`), push the tag, and optionally create a GitHub Release via `gh release create`.
- **README accuracy:** When plugin behavior changes (skills, WORKFLOW.md, templates, constitution, architecture), update the README to reflect the new state. The README is the primary user-facing documentation and must stay consistent with the implementation.
- **Workflow friction:** When workflow execution reveals friction, capture it as a GitHub Issue with the `friction` label. Include: what happened, expected behavior, and suggested fix.
- **Design review checkpoint:** After creating specs + design artifacts, always pause for user alignment before proceeding to preflight/tasks. The design phase is the mandatory review checkpoint in every OpenSpec workflow.
- **No ADR references in specs:** Specs MUST NOT reference ADRs (e.g., "see ADR-019"). ADRs are generated after archiving — specs exist before ADRs do. Specs describe requirements; ADRs document the decisions that shaped them.

## Standard Tasks

<!-- Project-specific extras appended to the universal standard tasks in the schema template.
     These items are added after the universal steps (archive, changelog, docs, push) in every tasks.md.
     Pre-merge tasks are executed during post-apply workflow.
     Post-merge tasks are reminders — executed manually after the PR is merged. -->

### Pre-Merge
- [ ] Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)

### Post-Merge
- [ ] Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
