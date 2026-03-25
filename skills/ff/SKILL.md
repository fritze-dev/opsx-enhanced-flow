---
name: ff
description: Fast-forward through OpenSpec artifact creation. Use when the user wants to quickly create all artifacts needed for implementation without stepping through each one individually.
disable-model-invocation: false
---

Fast-forward through artifact creation - generate everything needed to start implementation in one go.

**Input**: The user's request should include a change name (kebab-case) OR a description of what they want to build.

**Steps**

1. **If no clear input provided, ask what they want to build**

   Use the **AskUserQuestion tool** (open-ended, no preset options) to ask:
   > "What change do you want to work on? Describe what you want to build or fix."

   From their description, derive a kebab-case name (e.g., "add user authentication" → `add-user-auth`).

   **IMPORTANT**: Do NOT proceed without understanding what the user wants to build.

2. **Create the change directory**
   ```bash
   mkdir -p openspec/changes/<name>
   ```
   This creates the change workspace at `openspec/changes/<name>/`.

3. **Get the artifact build order**

   Read `openspec/schemas/opsx-enhanced/schema.yaml` to get the artifact pipeline. For each artifact in the `artifacts:` list:
   - Check if `openspec/changes/<name>/<generates>` exists (for glob patterns like `specs/**/*.md`, check if at least one matching file exists under `openspec/changes/<name>/specs/`)
   - **done**: output file exists
   - **ready**: not done, but all artifacts listed in `requires` are done
   - **blocked**: not done, and at least one artifact in `requires` is not done

   Also read the `apply:` section to determine which artifacts must be complete before implementation (the `requires` list, typically `[tasks]`).

4. **Create artifacts in sequence until apply-ready**

   Use the **TodoWrite tool** to track progress through the artifacts.

   Loop through artifacts in dependency order (artifacts with no pending dependencies first):

   a. **For each artifact that is "ready"**:
      - In schema.yaml, find the artifact by `id`. Extract:
        - **instruction**: The `instruction:` field text (content guidance)
        - **template**: Read `openspec/schemas/opsx-enhanced/templates/<template>` for the output structure
        - **output path**: `openspec/changes/<name>/<generates>`
        - **dependencies**: The `requires:` list — read each completed dependency's output file for context
      - Also read `openspec/config.yaml`'s `context:` field for project-level context instructions.
      - Read any completed dependency files for context
      - Create the artifact file using the template as the structure
      - Apply the instruction as constraints - but do NOT copy it into the file
      - **Post-artifact hook**: Check if schema.yaml contains a top-level `post_artifact` field. If present, read and execute its instructions (typically: commit, push, and on first push create a draft PR). If the field is absent, skip this step silently.
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

- Follow the `instruction` field from schema.yaml for each artifact type
- The schema defines what each artifact should contain - follow it
- Read dependency artifacts for context before creating new ones
- Use the template as the structure for your output file - fill in its sections
- **IMPORTANT**: The `instruction` field and `config.yaml` context are constraints for YOU, not content for the file
  - Do NOT copy instruction blocks into the artifact
  - These guide what you write, but should never appear in the output

**Checkpoint Model**

After generating the preflight artifact, check the verdict before proceeding to tasks:
- **PASS** — auto-continue to tasks without pausing
- **PASS WITH WARNINGS** — mandatory pause: present each warning to the user and require explicit acknowledgment before generating tasks. Do NOT auto-accept warnings.
- **BLOCKED** — stop: user must resolve blockers before tasks can be generated

The design review checkpoint is governed by the project constitution (pause after design for user alignment before preflight). If preflight already exists when ff resumes, skip the design checkpoint.

**Guardrails**
- Create ALL artifacts needed for implementation (as defined by schema's `apply.requires`)
- Always read dependency artifacts before creating a new one
- If context is critically unclear, ask the user - but prefer making reasonable decisions to keep momentum
- If a change with that name already exists, suggest continuing that change instead
- Verify each artifact file exists after writing before proceeding to next
