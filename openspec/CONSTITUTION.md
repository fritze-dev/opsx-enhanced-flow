---
template-version: 1
---
# Project Constitution

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (WORKFLOW.md frontmatter, Smart Template frontmatter)
- **Shell:** Bash (skill command execution)
- **Platform:** Claude Code plugin system

## Testing

- **Framework:** None (plugin is Markdown/YAML artifacts, no executable tests)
- **Validation:** Gherkin scenarios verified via review.md during apply

## Architecture Rules

- **Three-layer architecture:** CONSTITUTION.md (global rules) → WORKFLOW.md + Smart Templates (artifact pipeline + inline actions) → Router (single workflow skill with 4 built-in actions (init, propose, apply, finalize) + consumer-defined custom actions)
- Layers are independently modifiable — WORKFLOW.md and Smart Templates do not embed router logic, the router depends on them via direct file reads
- **Router immutability:** The workflow skill (`skills/workflow/SKILL.md`) is generic plugin code shared across all consumers. They MUST NOT be modified for project-specific behavior. Project-specific workflows and conventions MUST be defined in this constitution.
- Plugin manifests live in `.claude-plugin/` (plugin.json, marketplace.json)
- Pipeline source of truth: `openspec/WORKFLOW.md` (orchestration + actions) + `openspec/templates/` (Smart Templates)
- Specs: `openspec/specs/<capability>/spec.md` (one directory per capability, edited directly during specs stage)
- Changes: `openspec/changes/YYYY-MM-DD-<feature>/` (date-prefixed at creation, contains planning artifacts + review.md)

## Code Style

- **YAML:** 2-space indentation, `|` for multiline strings
- **Review markers:** `<!-- REVIEW -->` — transient markers for items needing user confirmation. Skills that write REVIEW markers (bootstrap, docs) must auto-resolve them: iterate each marker, ask the user, document the decision, and remove the marker. No REVIEW markers should persist in final output.

## Constraints

- Specs use `## Purpose` + `## Requirements` — edited directly during the specs stage, no delta format

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-apply version bump:** During the post-apply workflow, automatically increment the patch version in `src/.claude-plugin/plugin.json` (e.g., `1.0.3` → `1.0.4`) and sync the `version` field in `.claude-plugin/marketplace.json` to match. If versions are out of sync, use `src/.claude-plugin/plugin.json` as source of truth. Display the new version. A GitHub Action automatically creates a git tag and GitHub Release when the version change is pushed to `main`. For intentional minor/major releases, manually set the version in both files and push — the Action handles tagging and release creation.
- **Plugin source layout:** Plugin source code lives in `src/` (skills, templates, plugin.json). Project files (docs, CI, specs, changelog) stay at the repo root. Consumer plugin caches contain only `src/` contents. The marketplace.json at `.claude-plugin/marketplace.json` uses `source: "./src"`.
- **Local development:** Developers register the local repo as marketplace via `claude plugin marketplace add <local-path> --scope user`. Skill changes reload via `/reload-plugins`. Version changes require `claude plugin update opsx@opsx-enhanced-flow`.
- **README accuracy:** When plugin behavior changes (skills, WORKFLOW.md, templates, constitution, architecture), update the README to reflect the new state. The README is the primary user-facing documentation and must stay consistent with the implementation.
- **Workflow friction:** When workflow execution reveals friction, capture it as a GitHub Issue with the `friction` label. Include: what happened, expected behavior, and suggested fix.
- **Knowledge transparency:** Project knowledge (architecture decisions, conventions, design rationale, workflow patterns) MUST live in version-controlled artifacts — constitution for rules, specs for requirements, ADRs for decisions, GitHub Issues for friction/bugs. Internal auto-memory files are opaque and non-shareable; project knowledge MUST NOT be stored there.
- **Design review checkpoint:** After creating specs + design artifacts, pause for user alignment before proceeding to preflight/tasks — unless `auto_approve` is true, in which case continue without pausing. When `auto_approve` is false, the design phase is the mandatory review checkpoint.
- **No ADR references in specs:** Specs MUST NOT reference ADRs (e.g., "see ADR-019"). ADRs are generated after implementation — specs exist before ADRs do. Specs describe requirements; ADRs document the decisions that shaped them.
- **Template synchronization:** Changes to `openspec/WORKFLOW.md` (actions, pipeline, body sections) must also be reflected in `src/templates/workflow.md`. The `worktree` config may intentionally differ between project and consumer template (e.g., `enabled: true` in project, commented out in consumer).

## Standard Tasks

<!-- Project-specific extras appended to the universal standard tasks in the schema template.
     These items are added after the universal steps (changelog, docs, version bump, push) in every tasks.md.
     Pre-merge tasks are executed during post-apply workflow.
     Post-merge tasks are reminders — executed manually after the PR is merged. -->

### Pre-Merge
- [ ] Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)

### Post-Merge
- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
