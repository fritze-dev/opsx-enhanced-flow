---
name: ff
description: Fast-forward through the OpenSpec pipeline. Use when the user wants to quickly create all artifacts and optionally execute the full pipeline (apply, verify, finalize) without stepping through each one individually.
disable-model-invocation: false
---

Fast-forward through the OpenSpec pipeline — generate artifacts and optionally execute the full lifecycle in one go.

**Input**: The user's request should include a change name (kebab-case) OR a description of what they want to build.

**Steps**

1. **If no clear input provided, check for existing changes first**

   **Change context detection** (runs first, before directory listing):
   If no explicit change name was provided as an argument:
   1. Get current branch: `git rev-parse --abbrev-ref HEAD`
   2. **Proposal frontmatter lookup**: Scan `openspec/changes/*/proposal.md` for a proposal whose YAML frontmatter `branch` field matches the current branch. If found, auto-select that change.
   3. **Fallback — worktree convention**: If no matching proposal frontmatter, check if inside a worktree (`git rev-parse --git-dir` contains `/worktrees/`), derive change name from branch, search for `openspec/changes/*-<branch-name>/`.
   4. If valid: auto-select and announce "Detected change context: using change '<name>'"
   5. If not valid: fall through to normal detection below

   List directories under `openspec/changes/`. Filter to **active changes** — those whose `proposal.md` has frontmatter `status: active` or has no `status` field. Fallback: `tasks.md` does not exist or contains at least one `- [ ]` item. If active changes exist, use the **AskUserQuestion tool** to let the user choose:
   - Present existing changes as options (top 3-4, most recently modified first, mark most recent as "(Recommended)")
   - Include an option to create a new change

   If no active changes exist, use **AskUserQuestion tool** (open-ended) to ask what they want to build.

   From their description, derive a kebab-case name (e.g., "add user authentication" → `add-user-auth`).

   **IMPORTANT**: Do NOT proceed without understanding what the user wants to build or which change to continue.

2. **Create the change directory** (if new)
   ```bash
   mkdir -p openspec/changes/YYYY-MM-DD-<name>
   ```

3. **Get the pipeline build order**

   Read `openspec/WORKFLOW.md` to get the pipeline configuration from its YAML frontmatter:
   - `templates_dir`: path to Smart Templates directory
   - `pipeline`: ordered array of step IDs (both artifact and action steps)
   - `apply`: object with `requires` list

   For each step ID in `pipeline`, read the corresponding Smart Template at `<templates_dir>/<id>.md` (for specs: `<templates_dir>/specs/spec.md`). From the template's YAML frontmatter, extract:
   - `type`: `artifact` (default if absent) or `action`
   - `generates`: output file path (artifact steps only)
   - `requires`: dependency step IDs
   - `instruction`: AI behavioral constraints

   Check step status:
   - **Artifact steps** (`type: artifact` or no `type` field): Check if `openspec/changes/<change-dir>/<generates>` exists (for glob patterns like `specs/**/*.md`, check if at least one matching file exists under `openspec/changes/<change-dir>/specs/`). Status: **done** if file exists, **ready** if dependencies done, **blocked** if dependencies missing.
   - **Action steps** (`type: action`): Always execute when dependencies are satisfied. The action itself handles idempotency.

   **Special handling for `specs` artifact**: The specs stage does NOT create files in the change directory. Instead, it edits specs directly at `openspec/specs/<capability>/spec.md`. To check if the specs stage is "done", verify that the proposal's Capabilities section lists capabilities and the corresponding spec files exist or have been recently modified.

   **Spec frontmatter tracking**: During the specs stage, when editing any spec file:
   1. **Collision check**: Before editing, read the spec's frontmatter. If `status: draft` and `change` references a different change directory, warn the user about the collision and ask for confirmation before proceeding.
   2. **Set tracking fields**: Update the spec's YAML frontmatter to set `status: draft`, `change: <change-directory-name>`, and `lastModified: <current-date-YYYY-MM-DD>`. For new specs, also set `version: 1`. For existing specs, preserve the current `version` value (version is only bumped during verify completion).

   **Proposal frontmatter**: When creating `proposal.md`, include YAML frontmatter before the `## Why` section:
   ```yaml
   ---
   status: active
   branch: <current-branch-name>
   worktree: <worktree-path>  # only if worktree mode is enabled
   capabilities:
     new: [<capability-names-from-New-Capabilities-section>]
     modified: [<capability-names-from-Modified-Capabilities-section>]
     removed: [<capability-names-from-Removed-Capabilities-section>]
   ---
   ```
   Populate `capabilities` from the proposal body's Capabilities section after writing it.

   **Design frontmatter**: When creating `design.md`, include YAML frontmatter before `# Technical Design`:
   ```yaml
   ---
   has_decisions: true  # or false if Decisions section has no entries
   ---
   ```

4. **Execute pipeline steps in sequence**

   Use the **TodoWrite tool** to track progress through the pipeline.

   Also read project-level context from `openspec/WORKFLOW.md`'s `## Context` body section (or `context` frontmatter field as fallback for template-version 1).

   Loop through steps in the `pipeline` order:

   a. **For each artifact step that is "ready"** (`type: artifact` or no `type`):
      - Read the Smart Template at `<templates_dir>/<id>.md`:
        - **instruction**: from YAML frontmatter `instruction:` field (content guidance)
        - **template body**: the markdown after the frontmatter (output structure)
        - **output path**: `openspec/changes/<change-dir>/<generates>`
      - Read any completed dependency files for context
      - Create the artifact file using the template body as the structure
      - Apply the instruction as constraints — but do NOT copy it into the file
      - **Post-artifact hook**: Read `openspec/WORKFLOW.md`'s `## Post-Artifact Hook` body section (or `post_artifact` frontmatter field as fallback for template-version 1). If present, execute its instructions (commit, push, and on first push create a draft PR). If absent, skip silently.
      - Show brief progress: "Created <artifact-id>"

   b. **For each action step whose dependencies are met** (`type: action`):
      - Read the Smart Template at `<templates_dir>/<id>.md` for its `instruction`
      - Spawn an **isolated sub-agent** via the Agent tool with:
        - The template's `instruction` as the primary directive
        - Paths to the dependency artifacts listed in `requires` (the sub-agent reads them from disk)
        - The `## Context` section from WORKFLOW.md
        - The change directory path and affected spec paths
      - The sub-agent receives only its required context — NOT the full conversation history
      - Wait for the sub-agent to complete, then show brief progress: "Completed <step-id>"

   c. **Continue through the entire pipeline**
      - After each step, re-check status for all steps
      - Process all steps in the `pipeline` array, not just up to `apply.requires`

   d. **If a step requires user input** (unclear context):
      - Use **AskUserQuestion tool** to clarify
      - Then continue with execution

5. **Show final status**

   Re-check file existence for all artifacts and display updated status.

**Output**

After completing the pipeline, summarize:
- Change name and location
- List of steps completed with brief descriptions
- If full pipeline completed: "All pipeline steps complete! Change is ready for merge."
- If stopped at human gate: "Pipeline paused at approval gate. Review the verification report and respond with 'Approved' to continue."
- If stopped at artifact phase only: "All artifacts created! Ready for implementation. Run `/opsx:apply` or ask me to implement."

**Artifact Creation Guidelines**

- Read each Smart Template's `instruction` frontmatter field for artifact-specific guidance
- Read dependency artifacts for context before creating new ones
- Use the template body (after frontmatter) as the structure for your output file — fill in its sections
- **IMPORTANT**: The `instruction` field and WORKFLOW.md `## Context` are constraints for YOU, not content for the file
  - Do NOT copy instruction blocks into the artifact
  - These guide what you write, but should never appear in the output

**Checkpoint Model**

After generating the preflight artifact, check the verdict before proceeding to tasks:
- **PASS** — auto-continue to tasks without pausing
- **PASS WITH WARNINGS** — mandatory pause: present each warning to the user and require explicit acknowledgment before generating tasks. Do NOT auto-accept warnings.
- **BLOCKED** — stop: user must resolve blockers before tasks can be generated

The design review checkpoint is governed by the project constitution (pause after design for user alignment before preflight). If preflight already exists when ff resumes, skip the design checkpoint.

**Human Approval Gate**

After the verify action step completes with no CRITICAL issues, ff SHALL pause and ask the user for explicit approval before proceeding to post-apply steps (changelog, docs, version-bump). This preserves the mandatory human gate from the QA loop.

**`--auto-approve` flag**: When provided, ff SHALL skip the human approval gate and proceed directly to post-apply steps after a passing verify. This enables fully autonomous pipeline execution for routine changes.

**Guardrails**
- Process ALL steps in the `pipeline` array from WORKFLOW.md
- Always read dependency artifacts before creating a new one
- If context is critically unclear, ask the user — but prefer making reasonable decisions to keep momentum
- If a change with that name already exists, suggest continuing that change instead
- Verify each artifact file exists after writing before proceeding to next
- Action steps are executed via sub-agents with bounded context — never pass the full conversation history
