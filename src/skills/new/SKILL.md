---
name: new
description: Start a new OpenSpec change using the experimental artifact workflow. Use when the user wants to create a new feature, fix, or modification with a structured step-by-step approach.
disable-model-invocation: false
---

Start a new change using the experimental artifact-driven approach.

**Input**: The user's request should include a change name (kebab-case) OR a description of what they want to build.

**Steps**

1. **If no clear input provided, ask what they want to build**

   Use the **AskUserQuestion tool** (open-ended, no preset options) to ask:
   > "What change do you want to work on? Describe what you want to build or fix."

   From their description, derive a kebab-case name (e.g., "add user authentication" → `add-user-auth`).

   **IMPORTANT**: Do NOT proceed without understanding what the user wants to build.

2. **Verify setup**

   Check that `openspec/WORKFLOW.md` exists. If missing, tell the user to run `/opsx:setup` first and stop.

3. **Lazy worktree cleanup**

   Before creating a new change, check for stale worktrees:
   1. Run `git worktree list` to find all worktrees (excluding the main working tree).
   2. For each worktree, extract the branch name.
   3. **Proposal status check**: Find the change directory in the worktree or main tree matching the branch name (`openspec/changes/*-<branch>/proposal.md`). If the proposal has YAML frontmatter with `status: completed`, the change is done — clean up.
   4. **Fallback — PR status**: If no proposal status is available, check if the branch's PR was merged: `gh pr view <branch-name> --json state --jq '.state'`
      - If result is `MERGED`: clean up (remove worktree, delete local and remote branch). Report: "Cleaned up stale worktree: <branch-name> (completed)"
      - If `gh` is unavailable or no PR exists: fall back to `git branch -d <branch-name>`. If that succeeds (branch was merged), remove the worktree. If it fails (branch not merged), skip this worktree.
      - If result is `OPEN` or `CLOSED`: skip this worktree (still active or intentionally closed).
   5. If no stale worktrees found, proceed silently.

4. **Create the change workspace**

   Read `openspec/WORKFLOW.md` frontmatter for the `worktree` configuration.

   Determine the current date in `YYYY-MM-DD` format for the directory prefix.

   **If `worktree.enabled` is `true`:**
   1. Compute the worktree path by replacing `{change}` in `worktree.path_pattern` with the change name (default pattern: `.claude/worktrees/{change}`)
   2. Check if a worktree at that path already exists (`git worktree list`). If so, suggest switching to it instead and stop.
   3. Create the worktree: `git worktree add <path> -b <change-name>`
      - If the branch already exists, try: `git worktree add <path> <change-name>`
      - If the path already exists but is not a git worktree, fail with an error.
   4. Create the change directory inside the worktree with date prefix:
      ```bash
      mkdir -p <worktree-path>/openspec/changes/YYYY-MM-DD-<name>
      ```
   5. Report the worktree path and branch name. Instruct the user to switch their working directory to the worktree.

   **If `worktree.enabled` is absent, commented out, or `false`:**
   ```bash
   mkdir -p openspec/changes/YYYY-MM-DD-<name>
   ```

   **Check for existing change:** Before creating, check if a directory matching `openspec/changes/*-<name>` already exists (in worktree or main tree). If so, suggest continuing that change instead.

5. **Show the artifact status**

   Read `openspec/WORKFLOW.md` to get the pipeline configuration from its YAML frontmatter (`templates_dir` and `pipeline` array). For each artifact ID in `pipeline`, read the corresponding Smart Template at `<templates_dir>/<id>.md` to get its `generates` and `requires` fields.

   For each artifact:
   - Check if `openspec/changes/YYYY-MM-DD-<name>/<generates>` exists (for glob patterns like `specs/**/*.md`, check if at least one matching file exists under `openspec/changes/YYYY-MM-DD-<name>/specs/`)
   - **done**: output file exists
   - **ready**: not done, but all artifacts listed in `requires` are done
   - **blocked**: not done, and at least one artifact in `requires` is not done

   Display which artifacts need to be created and which are ready.

6. **Get instructions for the first artifact**

   Find the first artifact with status "ready". Read its Smart Template's `instruction` frontmatter field for content guidance and the template body for the output structure.

7. **STOP and wait for user direction**

**Output**

After completing the steps, summarize:
- Change name and location (including date prefix)
- Artifact pipeline and its sequence
- Current status (0/N artifacts complete)
- The template for the first artifact
- Prompt: "Ready to create the first artifact? Just describe what this change is about and I'll draft it, or ask me to continue."

**Guardrails**
- Do NOT create any artifacts yet - just show the instructions
- Do NOT advance beyond showing the first artifact template
- If the name is invalid (not kebab-case), ask for a valid name
- If a change with that name already exists (matching `*-<name>`), suggest continuing that change instead
