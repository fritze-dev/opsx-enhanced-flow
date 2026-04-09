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
- `## Action: <name>` sections — each contains `### Requirements` (clickable links to spec requirements) and `### Instruction` (procedural guidance)

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

Read the `## Action: <action>` section from WORKFLOW.md body:
1. Parse `### Requirements` — each link has format `[Name](openspec/specs/<spec>/spec.md#requirement-<slug>)`. For each link, read the target spec file and extract only the referenced requirement section (the `### Requirement: <Name>` block including its scenarios).
2. Read `### Instruction` for the procedural directive.

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
