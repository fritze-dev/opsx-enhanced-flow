---
status: active
branch: skill-consolidation
worktree: .claude/worktrees/skill-consolidation
capabilities:
  new: [project-init, documentation]
  modified: [workflow-contract, artifact-pipeline, task-implementation, quality-gates, three-layer-architecture, change-workspace, human-approval-gate]
  removed: [interactive-discovery, project-setup, project-bootstrap, artifact-generation, user-docs, architecture-docs, decision-docs]
---
## Why

Skills duplicate 60-70% of spec content (1,593 lines across 11 SKILL.md files). Shared logic like change context detection is copy-pasted across 6 skills. The specs already describe all behavior — skills are redundant procedural wrappers. Consolidating to 4 commands with a single router and inline actions eliminates duplication and makes specs the true single source of truth.

## What Changes

- **BREAKING**: Replace 11 SKILL.md files with 1 router SKILL.md (~80 lines)
- **BREAKING**: Reduce 13 commands to 4: `init`, `propose`, `apply`, `finalize`
- **BREAKING**: WORKFLOW.md template-version 1 → 3 with `actions:` section for inline action definitions
- Add `review.md` as pipeline artifact (replaces transient verify — PR-visible, not skippable)
- Pipeline expanded from 6 to 7 steps: `[research, proposal, specs, design, preflight, tasks, review]`
- Actions (init, apply, finalize) defined inline in WORKFLOW.md with `specs:` references and `instruction:` blocks
- Remove `type: action` Smart Template concept from PR #97 — actions live in WORKFLOW.md, not template files
- CI automation config (`automation.post_approval`) for finalize action
- GitHub Actions workflow (`.github/workflows/pipeline.yml`) that triggers finalize on PR approval
- `auto_approve` config in WORKFLOW.md — project-level setting that skips human approval gate after passing review, enables fully autonomous pipeline execution
- Spec merges: consolidate specs that map to the same command

## Capabilities

### New Capabilities

- `project-init`: Merges `project-setup` + `project-bootstrap`. Covers project initialization (template install, constitution generation, codebase scanning) and health checks (spec drift, docs drift).
- `documentation`: Merges `user-docs` + `architecture-docs` + `decision-docs`. Covers all generated documentation: capability docs, ADRs, README.

### Modified Capabilities

- `workflow-contract`: Add `actions:` section, `auto_approve` config, update skill reading pattern for router + sub-agent dispatch, add `review` to pipeline
- `artifact-pipeline`: Expand pipeline from 6 to 7 stages (add review), absorb `artifact-generation` (propose = pipeline traversal), update dependency gating
- `task-implementation`: Apply now generates review.md as QA output, eliminates QA-loop checkbox hacking
- `quality-gates`: Verify becomes review.md artifact template, preflight standalone absorbed into propose, docs-verify absorbed into init
- `three-layer-architecture`: Layer 3 changes from "Skills (11 commands)" to "Router + Actions (4 commands)"
- `change-workspace`: Workspace creation absorbed into propose, change context detection moves to router
- `human-approval-gate`: review.md verdict replaces transient verify as approval gate, auto_approve config support

### Removed Capabilities

- `interactive-discovery`: Discover eliminated. 0/49 usage. Q&A never adopted.
- `project-setup`: Merged into `project-init`
- `project-bootstrap`: Merged into `project-init`
- `artifact-generation`: Merged into `artifact-pipeline` (propose = pipeline traversal)
- `user-docs`: Merged into `documentation`
- `architecture-docs`: Merged into `documentation`
- `decision-docs`: Merged into `documentation`

### Consolidation Check

1. **Existing specs reviewed**: All 18 specs in `openspec/specs/`.
2. **Overlap assessment**: `project-setup` and `project-bootstrap` share the same actor (init), trigger (/opsx:init), and data model (WORKFLOW.md, constitution). `user-docs`, `architecture-docs`, `decision-docs` share the same actor (finalize), trigger (/opsx:finalize or /opsx:docs), and output directory (docs/). `artifact-generation` describes propose behavior already covered by `artifact-pipeline`.
3. **Merge assessment**: All three merges confirmed — shared actor/trigger/data per consolidation rules. New specs `project-init` (~250 lines) and `documentation` (~300 lines) within target range.

## Impact

- **WORKFLOW.md**: Gains `actions:` section (~30 lines), pipeline updated, template-version bumped to 3
- **Templates**: New `review.md` artifact template
- **Skills directory**: 11 SKILL.md files replaced by 1 router
- **Plugin manifests**: Updated command registration (4 commands instead of 13)
- **Constitution**: "Three-layer architecture" vocabulary updated
- **Consumer migration**: Consumers on template-version 1 need `/opsx:setup` to migrate

## Scope & Boundaries

**In scope:**
- Consolidate 11 SKILL.md files into 1 router
- Define 4 commands (init, propose, apply, finalize)
- Add review.md as pipeline artifact
- Add actions section to WORKFLOW.md
- Update all affected specs
- Remove interactive-discovery spec
- Update constitution and README

**Out of scope:**
- Consumer migration tooling (manual `/opsx:init` is sufficient)
- Closing PR #97 (done after this change lands)
