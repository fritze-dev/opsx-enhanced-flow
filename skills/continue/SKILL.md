---
name: continue
description: Continue working on an OpenSpec change by creating the next artifact. Use when the user wants to progress their change, create the next artifact, or continue their workflow.
disable-model-invocation: false
---

Continue working on a change by creating the next artifact.

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **If no change name provided, prompt for selection**

   List directories under `openspec/changes/` (exclude `archive/`). Then use the **AskUserQuestion tool** to let the user select which change to work on.

   Present the top 3-4 most recently modified changes as options, showing:
   - Change name
   - How recently it was modified

   Mark the most recently modified change as "(Recommended)" since it's likely what the user wants to continue.

   **IMPORTANT**: Do NOT guess or auto-select a change. Always let the user choose.

2. **Check current status**

   Read `openspec/schemas/opsx-enhanced/schema.yaml` to get the artifact pipeline. For each artifact in the `artifacts:` list:
   - Check if `openspec/changes/<name>/<generates>` exists (for glob patterns like `specs/**/*.md`, check if at least one matching file exists under `openspec/changes/<name>/specs/`)
   - **done**: output file exists
   - **ready**: not done, but all artifacts listed in `requires` are done
   - **blocked**: not done, and at least one artifact in `requires` is not done

   The change is complete when all artifacts are done.

3. **Act based on status**:

   ---

   **If all artifacts are complete**:
   - Congratulate the user
   - Show final status
   - Suggest: "All artifacts created! You can now implement this change or archive it."
   - STOP

   ---

   **If artifacts are ready to create** (at least one has status "ready"):
   - Pick the FIRST artifact with status "ready"
   - In schema.yaml, find the artifact by `id`. Extract:
     - **instruction**: The `instruction:` field text (content guidance)
     - **template**: Read `openspec/schemas/opsx-enhanced/templates/<template>` for the output structure
     - **output path**: `openspec/changes/<name>/<generates>`
     - **dependencies**: The `requires:` list — read each completed dependency's output file for context
   - Also read `openspec/config.yaml`'s `context:` field for project-level context instructions.
   - **Create the artifact file**:
     - Read any completed dependency files for context
     - Use the template as the structure - fill in its sections
     - Apply the instruction as constraints when writing - but do NOT copy it into the file
     - Write to the output path
   - Show what was created and what's now unlocked
   - STOP after creating ONE artifact

   ---

   **If no artifacts are ready (all blocked)**:
   - This shouldn't happen with a valid schema
   - Show status and suggest checking for issues

4. **After creating an artifact, show progress**

   Re-check file existence for all artifacts and display updated status.

**Output**

After each invocation, show:
- Which artifact was created
- Current progress (N/M complete)
- What artifacts are now unlocked
- Prompt: "Want to continue? Just ask me to continue or tell me what to do next."

**Artifact Creation Guidelines**

Use the `instruction` field from schema.yaml to understand what to create.

Common artifact patterns:

- **proposal.md**: Ask user about the change if not clear. Fill in Why, What Changes, Capabilities, Impact.
  - The Capabilities section is critical - each capability listed will need a spec file.
- **specs/<capability>/spec.md**: Create one spec per capability listed in the proposal's Capabilities section. Before creating, verify the proposal's Consolidation Check confirms no overlap with existing specs.
- **design.md**: Document technical decisions, architecture, and implementation approach.
- **tasks.md**: Break down implementation into checkboxed tasks.

**Checkpoint Model**

After creating an artifact, check the transition type before stopping:
- **Auto-continue** (proceed immediately to next artifact without pausing): research→proposal, proposal→specs, specs→design, preflight(PASS)→tasks
- **Mandatory-pause** (stop and wait for user input):
  - After **design** — pause for user review before proceeding to preflight
  - After **preflight with PASS WITH WARNINGS** — pause, present each warning, require explicit user acknowledgment before proceeding to tasks
  - After **preflight with BLOCKED** — stop, user must resolve issues
- At auto-continue transitions, generate the next artifact immediately rather than stopping after one.

**Guardrails**
- Create artifacts until a mandatory-pause checkpoint or pipeline end is reached
- Always read dependency artifacts before creating a new one
- Never skip artifacts or create out of order
- If context is unclear, ask the user before creating
- Verify the artifact file exists after writing before marking progress
- Read schema.yaml for artifact definitions and templates — do not hardcode instruction content
- **IMPORTANT**: The `instruction` field and `config.yaml` context are constraints for YOU, not content for the file
  - Do NOT copy instruction blocks into the artifact
  - These guide what you write, but should never appear in the output
