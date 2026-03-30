---
name: ff
description: Fast-forward through OpenSpec artifact creation. Use when the user wants to quickly create all artifacts needed for implementation without stepping through each one individually.
disable-model-invocation: false
---

Fast-forward through artifact creation - generate everything needed to start implementation in one go.

**Input**: The user's request should include a change name (kebab-case) OR a description of what they want to build.

**Steps**

1. **If no clear input provided, check for existing changes first**

   **Worktree context detection** (runs first, before directory listing):
   If no explicit change name was provided as an argument:
   1. Run: `git rev-parse --git-dir`
   2. If the result contains `/worktrees/`, derive change name from branch: `git rev-parse --abbrev-ref HEAD`
   3. Search for a directory matching `openspec/changes/*-<branch-name>/` in the current working tree
   4. If valid: auto-select this change and announce "Detected worktree context: using change '<name>'"
   5. If not valid: fall through to normal detection below

   List directories under `openspec/changes/`. Filter to **active changes** — those where `tasks.md` does not exist or contains at least one `- [ ]` item. If active changes exist, use the **AskUserQuestion tool** to let the user choose:
   - Present existing changes as options (top 3-4, most recently modified first, mark most recent as "(Recommended)")
   - Include an option to create a new change

   If no active changes exist, use **AskUserQuestion tool** (open-ended) to ask what they want to build.

   From their description, derive a kebab-case name (e.g., "add user authentication" → `add-user-auth`).

   **IMPORTANT**: Do NOT proceed without understanding what the user wants to build or which change to continue.

2. **Create the change directory** (if new)
   ```bash
   mkdir -p openspec/changes/YYYY-MM-DD-<name>
   ```

3. **Get the artifact build order**

   Read `openspec/WORKFLOW.md` to get the pipeline configuration from its YAML frontmatter:
   - `templates_dir`: path to Smart Templates directory
   - `pipeline`: ordered array of artifact IDs
   - `apply`: object with `requires` list

   For each artifact ID in `pipeline`, read the corresponding Smart Template at `<templates_dir>/<id>.md` (for specs: `<templates_dir>/specs/spec.md`). From the template's YAML frontmatter, extract:
   - `generates`: output file path relative to the change directory
   - `requires`: dependency artifact IDs
   - `instruction`: AI behavioral constraints

   Check artifact status:
   - Check if `openspec/changes/<change-dir>/<generates>` exists (for glob patterns like `specs/**/*.md`, check if at least one matching file exists under `openspec/changes/<change-dir>/specs/`)
   - **done**: output file exists
   - **ready**: not done, but all artifacts listed in `requires` are done
   - **blocked**: not done, and at least one artifact in `requires` is not done

   **Special handling for `specs` artifact**: The specs stage does NOT create files in the change directory. Instead, it edits baseline specs directly at `openspec/specs/<capability>/spec.md`. To check if the specs stage is "done", verify that the proposal's Capabilities section lists capabilities and the corresponding baseline spec files exist or have been recently modified.

4. **Create artifacts in sequence until apply-ready**

   Use the **TodoWrite tool** to track progress through the artifacts.

   Also read `openspec/WORKFLOW.md`'s `context:` field from its frontmatter for project-level context instructions (typically points to CONSTITUTION.md).

   Loop through artifacts in the `pipeline` order:

   a. **For each artifact that is "ready"**:
      - Read the Smart Template at `<templates_dir>/<id>.md`:
        - **instruction**: from YAML frontmatter `instruction:` field (content guidance)
        - **template body**: the markdown after the frontmatter (output structure)
        - **output path**: `openspec/changes/<change-dir>/<generates>`
      - Read any completed dependency files for context
      - **For the `specs` artifact**: Instead of creating delta spec files, edit baseline specs directly:
        - For new capabilities listed in the proposal: create `openspec/specs/<capability>/spec.md`
        - For modified capabilities: edit the existing `openspec/specs/<capability>/spec.md` in place
        - Use the spec template's instruction for format guidance (requirements with Gherkin scenarios)
        - Do NOT create files under `openspec/changes/<change-dir>/specs/`
      - **For all other artifacts**: Create the artifact file in the change directory using the template body as the structure
      - Apply the instruction as constraints — but do NOT copy it into the file
      - **Post-artifact hook**: Read `openspec/WORKFLOW.md`'s `post_artifact` field. If present, execute its instructions (commit, push, and on first push create a draft PR). If absent, skip silently.
      - Show brief progress: "Created <artifact-id>"

   b. **Continue until all apply-required artifacts are complete**
      - After creating each artifact, re-check file existence for all artifacts
      - Stop when all artifacts listed in `apply.requires` are done

   c. **If an artifact requires user input** (unclear context):
      - Use **AskUserQuestion tool** to clarify
      - Then continue with creation

5. **Show final status**

   Re-check file existence for all artifacts and display updated status.

**Output**

After completing all artifacts, summarize:
- Change name and location
- List of artifacts created with brief descriptions
- What's ready: "All artifacts created! Ready for implementation."
- Prompt: "Run `/opsx:apply` or ask me to implement to start working on the tasks."

**Artifact Creation Guidelines**

- Read each Smart Template's `instruction` frontmatter field for artifact-specific guidance
- Read dependency artifacts for context before creating new ones
- Use the template body (after frontmatter) as the structure for your output file — fill in its sections
- **IMPORTANT**: The `instruction` field and WORKFLOW.md `context` are constraints for YOU, not content for the file
  - Do NOT copy instruction blocks into the artifact
  - These guide what you write, but should never appear in the output
- **IMPORTANT**: The `specs` stage edits baseline specs directly at `openspec/specs/`. Do NOT create delta spec files with ADDED/MODIFIED/REMOVED sections. Edit the specs in place using the standard baseline format (`## Purpose`, `## Requirements`, `### Requirement:`, `#### Scenario:`).

**Checkpoint Model**

After generating the preflight artifact, check the verdict before proceeding to tasks:
- **PASS** — auto-continue to tasks without pausing
- **PASS WITH WARNINGS** — mandatory pause: present each warning to the user and require explicit acknowledgment before generating tasks. Do NOT auto-accept warnings.
- **BLOCKED** — stop: user must resolve blockers before tasks can be generated

The design review checkpoint is governed by the project constitution (pause after design for user alignment before preflight). If preflight already exists when ff resumes, skip the design checkpoint.

**Guardrails**
- Create ALL artifacts needed for implementation (as defined by WORKFLOW.md's `apply.requires`)
- Always read dependency artifacts before creating a new one
- If context is critically unclear, ask the user — but prefer making reasonable decisions to keep momentum
- If a change with that name already exists, suggest continuing that change instead
- Verify each artifact file exists after writing before proceeding to next
