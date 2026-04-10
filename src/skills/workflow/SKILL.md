---
name: workflow
description: Central OpenSpec workflow command. Use with action argument: init (setup project), propose (create change + artifacts), apply (implement + verify), finalize (changelog + docs + version). Example: /opsx:workflow propose
disable-model-invocation: false
---

# Workflow

Central orchestration for the OpenSpec workflow. The first argument determines the action: `init`, `propose`, `apply`, or `finalize`.

**Input**: `/opsx:workflow <action> [arguments]`

## Step 1: Identify Action

Parse the first argument to determine which action to run. Read the `actions` array from WORKFLOW.md frontmatter to determine valid actions. If WORKFLOW.md is missing, fall back to built-in actions: `init`, `propose`, `apply`, `finalize`.

If no action provided or unrecognized: list available actions from the array and ask the user to choose.

## Step 2: Load WORKFLOW.md

Read `openspec/WORKFLOW.md`. Extract from YAML frontmatter:
- `templates_dir`, `pipeline`, `actions` (array of action names), `worktree`, `auto_approve`

Read from markdown body:
- `## Context` section — follow its instructions (typically: read CONSTITUTION.md)
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
- [Post-Artifact Commit and PR Integration](openspec/specs/artifact-pipeline/spec.md#requirement-post-artifact-commit-and-pr-integration)
- [Create Change Workspace](openspec/specs/change-workspace/spec.md#requirement-create-change-workspace)
- [Create Worktree-Based Workspace](openspec/specs/change-workspace/spec.md#requirement-create-worktree-based-workspace)
- [Lazy Worktree Cleanup at Change Creation](openspec/specs/change-workspace/spec.md#requirement-lazy-worktree-cleanup-at-change-creation)
- [Change Context Detection](openspec/specs/change-workspace/spec.md#requirement-change-context-detection)

### Action: apply — Requirements

- [Implement Tasks from Task List](openspec/specs/task-implementation/spec.md#requirement-implement-tasks-from-task-list)
- [Progress Tracking](openspec/specs/task-implementation/spec.md#requirement-progress-tracking)
- [Standard Tasks Exclusion from Apply Scope](openspec/specs/task-implementation/spec.md#requirement-standard-tasks-exclusion-from-apply-scope)
- [Spec Edits During Implementation](openspec/specs/task-implementation/spec.md#requirement-spec-edits-during-implementation)
- [Apply Gate](openspec/specs/artifact-pipeline/spec.md#requirement-apply-gate)
- [Post-Implementation Commit Before Approval](openspec/specs/artifact-pipeline/spec.md#requirement-post-implementation-commit-before-approval)
- [Post-Implementation Verification](openspec/specs/quality-gates/spec.md#requirement-post-implementation-verification)
- [QA Loop with Mandatory Approval](openspec/specs/human-approval-gate/spec.md#requirement-qa-loop-with-mandatory-approval)
- [Fix Loop](openspec/specs/human-approval-gate/spec.md#requirement-fix-loop)
- [Active vs Completed Change Detection](openspec/specs/change-workspace/spec.md#requirement-active-vs-completed-change-detection)

### Action: finalize — Requirements

- [Generate Changelog from Completed Changes](openspec/specs/release-workflow/spec.md#requirement-generate-changelog-from-completed-changes)
- [Completion Workflow Next Steps](openspec/specs/release-workflow/spec.md#requirement-completion-workflow-next-steps)
- [Auto Patch Version Bump](openspec/specs/release-workflow/spec.md#requirement-auto-patch-version-bump)
- [Version Sync Between Plugin Files](openspec/specs/release-workflow/spec.md#requirement-version-sync-between-plugin-files)
- [Generate Enriched Capability Documentation](openspec/specs/documentation/spec.md#requirement-generate-enriched-capability-documentation)
- [Incremental Capability Documentation Generation](openspec/specs/documentation/spec.md#requirement-incremental-capability-documentation-generation)
- [Generate Architecture Overview](openspec/specs/documentation/spec.md#requirement-generate-architecture-overview)
- [Generate Documentation Table of Contents](openspec/specs/documentation/spec.md#requirement-generate-documentation-table-of-contents)
- [ADR Generation from Change Decisions](openspec/specs/documentation/spec.md#requirement-adr-generation-from-change-decisions)
- [Post-Merge Worktree Cleanup](openspec/specs/change-workspace/spec.md#requirement-post-merge-worktree-cleanup)

### Action: init — Requirements

- [Install OpenSpec Workflow](openspec/specs/project-init/spec.md#requirement-install-openspec-workflow)
- [Template Merge on Re-Init](openspec/specs/project-init/spec.md#requirement-template-merge-on-re-init)
- [First-Run Codebase Scan](openspec/specs/project-init/spec.md#requirement-first-run-codebase-scan)
- [Constitution Generation](openspec/specs/project-init/spec.md#requirement-constitution-generation)
- [Documentation Drift Verification](openspec/specs/project-init/spec.md#requirement-documentation-drift-verification-health-check)
- [Recovery Mode](openspec/specs/project-init/spec.md#requirement-recovery-mode-spec-drift-detection)
- [Constitution Update](openspec/specs/constitution-management/spec.md#requirement-constitution-update)
- [Preflight Quality Check](openspec/specs/quality-gates/spec.md#requirement-preflight-quality-check)

## Step 5: Dispatch

### `propose` — Pipeline Traversal

1. Read all change artifacts (if change exists) and the propose instruction from WORKFLOW.md
2. For each step in `pipeline` array: read Smart Template at `<templates_dir>/<id>.md`, check artifact status, generate if ready
3. **After each artifact**, commit and push:
   - `git add openspec/changes/<change-dir>/ openspec/specs/`
   - `git commit -m "WIP: <change-name> — <artifact-id>"`
   - `git push`
   - On first push (no PR exists): `gh pr create --draft --title "<Change Name>" --body "WIP: <change-name>"`
   - Skip PR creation if `gh` unavailable. Continue on push failure.
4. Follow the instruction from `## Action: propose` for checkpoint behavior, workspace creation, and pipeline gates

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

### Custom Action — Direct Execution

For any action not listed above (propose, apply, finalize, init):
1. Read all change artifacts for context (all files in change directory)
2. Read the `## Action: <name>` instruction from WORKFLOW.md
3. If the `## Action: <name>` section is missing: report the error and stop
4. Execute the instruction directly with change directory context — the agent decides whether to handle inline or spawn a sub-agent based on the instruction content
5. No spec requirements are loaded (custom actions are self-contained via their instruction)

## Guardrails

- Always read WORKFLOW.md before dispatching
- Change context detection runs ONCE, shared across all actions
- Sub-agents receive bounded context — NOT the workflow skill's conversation history
- If WORKFLOW.md is missing and action is not `init`: stop and suggest `/opsx:workflow init`
- For `propose`: do NOT create artifacts yet if the user hasn't confirmed what they want to build
- For `apply`: delete review.md at start of implementation to prevent stale reviews
