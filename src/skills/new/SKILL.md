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

3. **Create the change workspace**

   Read `openspec/WORKFLOW.md` frontmatter for the `worktree` configuration.

   **If `worktree.enabled` is `true`:**
   1. Compute the worktree path by replacing `{change}` in `worktree.path_pattern` with the change name (default pattern: `.claude/worktrees/{change}`)
   2. Check if a worktree at that path already exists (`git worktree list`). If so, suggest switching to it instead and stop.
   3. Create the worktree: `git worktree add <path> -b <change-name>`
      - If the branch already exists, try: `git worktree add <path> <change-name>`
      - If the path already exists but is not a git worktree, fail with an error.
   4. Create the change directory inside the worktree:
      ```bash
      mkdir -p <worktree-path>/openspec/changes/<name>
      ```
   5. Report the worktree path and branch name. Instruct the user to switch their working directory to the worktree.

   **If `worktree.enabled` is absent, commented out, or `false`:**
   ```bash
   mkdir -p openspec/changes/<name>
   ```
   This creates the change workspace at `openspec/changes/<name>/` (existing behavior).

4. **Show the artifact status**

   Read `openspec/WORKFLOW.md` to get the pipeline configuration from its YAML frontmatter (`templates_dir` and `pipeline` array). For each artifact ID in `pipeline`, read the corresponding Smart Template at `<templates_dir>/<id>.md` to get its `generates` and `requires` fields.

   For each artifact:
   - Check if `openspec/changes/<name>/<generates>` exists (for glob patterns like `specs/**/*.md`, check if at least one matching file exists under `openspec/changes/<name>/specs/`)
   - **done**: output file exists
   - **ready**: not done, but all artifacts listed in `requires` are done
   - **blocked**: not done, and at least one artifact in `requires` is not done

   Display which artifacts need to be created and which are ready.

5. **Get instructions for the first artifact**

   Find the first artifact with status "ready". Read its Smart Template's `instruction` frontmatter field for content guidance and the template body for the output structure.

6. **STOP and wait for user direction**

**Output**

After completing the steps, summarize:
- Change name and location
- Artifact pipeline and its sequence
- Current status (0/N artifacts complete)
- The template for the first artifact
- Prompt: "Ready to create the first artifact? Just describe what this change is about and I'll draft it, or ask me to continue."

**Guardrails**
- Do NOT create any artifacts yet - just show the instructions
- Do NOT advance beyond showing the first artifact template
- If the name is invalid (not kebab-case), ask for a valid name
- If a change with that name already exists, suggest continuing that change instead
