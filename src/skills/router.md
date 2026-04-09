# Router

Shared orchestration logic for all `/opsx:*` commands. Each command stub reads this file.

## Step 1: Identify Command

Determine which command was invoked from the SKILL.md that loaded this router. The command name is in the skill's `name` frontmatter field.

## Step 2: Load WORKFLOW.md

Read `openspec/WORKFLOW.md`. Extract from YAML frontmatter:
- `templates_dir`, `pipeline`, `actions`, `worktree`, `auto_approve`, `automation`

Read from markdown body:
- `## Context` section — follow its instructions (typically: read CONSTITUTION.md)
- `## Post-Artifact Hook` section — used after artifact creation

If WORKFLOW.md is missing, tell the user to run `/opsx:init` first and stop.

## Step 3: Change Context Detection

**Skip for `init`** — init operates at project level, not change level.

For `propose`, `apply`, `finalize`:
1. Get current branch: `git rev-parse --abbrev-ref HEAD`
2. **Proposal frontmatter lookup**: Scan `openspec/changes/*/proposal.md` for a proposal whose YAML frontmatter `branch` field matches the current branch. If found, auto-select that change.
3. **Fallback — worktree convention**: If no matching proposal, check if inside a worktree (`git rev-parse --git-dir` contains `/worktrees/`), derive change name from branch, search for `openspec/changes/*-<branch-name>/`.
4. If detected: announce "Detected change context: using change '<name>'"
5. If not detected and command is `apply` or `finalize`: list active changes, use **AskUserQuestion** to let user select.
6. If not detected and command is `propose`: the user may be starting a new change — proceed to propose dispatch which handles workspace creation.

## Step 4: Dispatch

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
   - **review artifact**: The review step is the last pipeline step but is generated during apply, not during propose. If pipeline reaches review and tasks exist but review.md doesn't, stop and suggest `/opsx:apply`.

3. **Show status**: Display pipeline progress and next steps.

### `apply` — Sub-Agent Execution

1. Read `actions.apply` from WORKFLOW.md frontmatter
2. For each entry in `actions.apply.specs`, load the spec from `openspec/specs/<name>/spec.md` and note which requirements are listed. When building the sub-agent prompt, include only the listed requirements (not the full spec) so the agent has focused context.
3. Read all change artifacts (research, proposal, design, tasks, specs)
4. Spawn sub-agent via Agent tool with:
   - `actions.apply.instruction` as primary directive
   - The specific requirements from each spec as behavioral context
   - Change directory path and artifact paths
   - The sub-agent implements tasks, generates review.md, runs the QA loop

### `finalize` — Sub-Agent Execution

1. Read `actions.finalize` from WORKFLOW.md frontmatter
2. For each entry in `actions.finalize.specs`, load the spec and extract only the listed requirements
3. Read change artifacts for context (proposal, review.md)
4. Spawn sub-agent with instruction + specific requirements + change context

### `init` — Sub-Agent Execution

1. Read `actions.init` from WORKFLOW.md frontmatter (if WORKFLOW.md exists)
2. If WORKFLOW.md missing: this IS the fresh install — proceed with init action
3. For each entry in `actions.init.specs`, load the spec and extract only the listed requirements (if specs exist)
4. Spawn sub-agent with instruction + specific requirements

## Guardrails

- Always read WORKFLOW.md before dispatching
- Change context detection runs ONCE, shared across all commands
- Sub-agents receive bounded context — NOT the router's conversation history
- If WORKFLOW.md is missing and command is not `init`: stop and suggest `/opsx:init`
- For `propose`: do NOT create artifacts yet if the user hasn't confirmed what they want to build
- For `apply`: delete review.md at start of implementation to prevent stale reviews
