---
name: workflow
description: Central OpenSpec workflow command. Use with action argument: init (setup project), propose (create change + artifacts), apply (implement + verify), finalize (changelog + docs + version). Example: /opsx:workflow propose
disable-model-invocation: false
---

# Workflow

Central orchestration for the OpenSpec workflow. The first argument determines the action: `init`, `propose`, `apply`, or `finalize`.

**Input**: `/opsx:workflow <action> [arguments]`

## Step 1: Identify Action

Parse the first argument to determine which action to run. Valid actions: `init`, `propose`, `apply`, `finalize`.

If no action provided or unrecognized: list available actions and ask the user to choose.

## Step 2: Load WORKFLOW.md

Read `openspec/WORKFLOW.md`. Extract from YAML frontmatter:
- `templates_dir`, `pipeline`, `actions` (array of action names), `worktree`, `auto_approve`, `automation`

Read from markdown body:
- `## Context` section — follow its instructions (typically: read CONSTITUTION.md)
- `## Post-Artifact Hook` section — used after artifact creation
- `## Action: <name>` sections — each contains `### Instruction` (procedural guidance for the action)

If WORKFLOW.md is missing and action is not `init`, tell the user to run `/opsx:workflow init` first and stop.

## Step 3: Change Context Detection

**Skip for `init`** — init operates at project level, not change level.

For `propose`, `apply`, `finalize`:
1. Get current branch: `git rev-parse --abbrev-ref HEAD`
2. **Proposal frontmatter lookup**: Scan `openspec/changes/*/proposal.md` for a proposal whose YAML frontmatter `branch` field matches the current branch. If found, auto-select that change.
3. **Fallback — worktree convention**: If no matching proposal, check if inside a worktree (`git rev-parse --git-dir` contains `/worktrees/`), derive change name from branch, search for `openspec/changes/*-<branch-name>/`.
4. If detected: announce "Detected change context: using change '<name>'"
5. If not detected and action is `apply` or `finalize`: list active changes, use **AskUserQuestion** to let user select.
6. If not detected and action is `propose`: the user may be starting a new change — proceed to propose dispatch which handles workspace creation.

## Step 4: Load Action Context

1. Read the `## Action: <action>` section from WORKFLOW.md body for the `### Instruction`.
2. Load the spec requirements for the action from the mapping below. For each link, read the target spec file and extract the referenced requirement section (the `### Requirement: <Name>` block including its scenarios).

### Action: propose — Requirements

- [Propose as Single Entry Point for Pipeline Traversal](openspec/specs/artifact-pipeline/spec.md#requirement-propose-as-single-entry-point-for-pipeline-traversal)
- [Seven-Stage Pipeline](openspec/specs/artifact-pipeline/spec.md#requirement-seven-stage-pipeline)
- [Artifact Dependencies](openspec/specs/artifact-pipeline/spec.md#requirement-artifact-dependencies)
- [Change Workspace Creation](openspec/specs/change-workspace/spec.md#requirement-change-workspace-creation)
- [Worktree Isolation](openspec/specs/change-workspace/spec.md#requirement-worktree-isolation)
- [Lazy Worktree Cleanup](openspec/specs/change-workspace/spec.md#requirement-lazy-worktree-cleanup)

### Action: apply — Requirements

- [Implement Tasks from Task List](openspec/specs/task-implementation/spec.md#requirement-implement-tasks-from-task-list)
- [Progress Tracking](openspec/specs/task-implementation/spec.md#requirement-progress-tracking)
- [Standard Tasks Exclusion from Apply Scope](openspec/specs/task-implementation/spec.md#requirement-standard-tasks-exclusion-from-apply-scope)
- [Spec Edits During Implementation](openspec/specs/task-implementation/spec.md#requirement-spec-edits-during-implementation)
- [Post-Implementation Verification](openspec/specs/quality-gates/spec.md#requirement-post-implementation-verification)

### Action: finalize — Requirements

- [Changelog Generation](openspec/specs/release-workflow/spec.md#requirement-changelog-generation)
- [Version Bump Convention](openspec/specs/release-workflow/spec.md#requirement-version-bump-convention)
- [Generate Enriched Capability Documentation](openspec/specs/documentation/spec.md#requirement-generate-enriched-capability-documentation)
- [Incremental Generation](openspec/specs/documentation/spec.md#requirement-incremental-generation)
- [Generate Architecture Overview](openspec/specs/documentation/spec.md#requirement-generate-architecture-overview)
- [ADR Generation](openspec/specs/documentation/spec.md#requirement-adr-generation)

### Action: init — Requirements

- [Install OpenSpec Workflow](openspec/specs/project-init/spec.md#requirement-install-openspec-workflow)
- [Template Merge on Re-Init](openspec/specs/project-init/spec.md#requirement-template-merge-on-re-init)
- [First-Run Codebase Scan](openspec/specs/project-init/spec.md#requirement-first-run-codebase-scan)
- [Constitution Generation](openspec/specs/project-init/spec.md#requirement-constitution-generation)
- [Documentation Drift Verification](openspec/specs/project-init/spec.md#requirement-documentation-drift-verification)
- [Constitution Lifecycle](openspec/specs/constitution-management/spec.md#requirement-constitution-lifecycle)
- [Pre-Implementation Quality Checks](openspec/specs/quality-gates/spec.md#requirement-pre-implementation-quality-checks)

## Step 5: Dispatch

### `propose` — Pipeline Traversal

1. **If no change exists**: Ask the user what they want to build (if not provided as argument). Derive kebab-case name. Create workspace:
   - If `worktree.enabled`: fetch origin main, `git worktree add <path> -b <name> origin/main`, `mkdir -p <worktree>/openspec/changes/YYYY-MM-DD-<name>`
   - Otherwise: `mkdir -p openspec/changes/YYYY-MM-DD-<name>`
   - **Lazy worktree cleanup**: Before creating, check for stale worktrees (proposal `status: completed` or merged PRs) and clean them up.

2. **Traverse pipeline**: For each step in `pipeline` array:
   - Read Smart Template at `<templates_dir>/<id>.md` (for specs: `<templates_dir>/specs/spec.md`)
   - Check if artifact exists at `openspec/changes/<change-dir>/<generates>`
   - If done: skip. If ready (dependencies met): generate artifact using template instruction + body structure. Execute Post-Artifact Hook after each.
   - **Checkpoint model**: After preflight, check verdict. PASS → continue. PASS WITH WARNINGS → pause for acknowledgment. BLOCKED → stop.
   - **Design review checkpoint**: After design, pause for user alignment (constitutional requirement).
   - **review artifact**: The review step is the last pipeline step but is generated during apply, not during propose. If pipeline reaches review and tasks exist but review.md doesn't, stop and suggest `/opsx:workflow apply`.

3. **Show status**: Display pipeline progress and next steps.

### `apply` — Sub-Agent Execution

1. Read all change artifacts (research, proposal, design, tasks, specs)
2. Spawn sub-agent via Agent tool with:
   - The instruction text from `## Action: apply` as primary directive
   - The extracted requirement sections as behavioral context
   - Change directory path and artifact paths
   - The sub-agent implements tasks, generates review.md, runs the QA loop

### `finalize` — Sub-Agent Execution

1. Read change artifacts for context (proposal, review.md)
2. Spawn sub-agent with instruction + extracted requirements + change context

### `init` — Sub-Agent Execution

1. If WORKFLOW.md missing: this IS the fresh install — proceed with default init behavior
2. Spawn sub-agent with instruction + extracted requirements

## Guardrails

- Always read WORKFLOW.md before dispatching
- Change context detection runs ONCE, shared across all actions
- Sub-agents receive bounded context — NOT the workflow skill's conversation history
- If WORKFLOW.md is missing and action is not `init`: stop and suggest `/opsx:workflow init`
- For `propose`: do NOT create artifacts yet if the user hasn't confirmed what they want to build
- For `apply`: delete review.md at start of implementation to prevent stale reviews
