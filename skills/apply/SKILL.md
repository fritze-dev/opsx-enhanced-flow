---
name: apply
description: Implement tasks from an OpenSpec change. Use when the user wants to start implementing, continue implementation, or work through tasks.
disable-model-invocation: false
---

Implement tasks from an OpenSpec change.

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **Select the change**

   If a name is provided, use it. Otherwise:
   - Infer from conversation context if the user mentioned a change
   - Auto-select if only one active change exists
   - If ambiguous, list directories under `openspec/changes/` (exclude `archive/`) and use the **AskUserQuestion tool** to let the user select

   Always announce: "Using change: <name>" and how to override (e.g., `/opsx:apply <other>`).

2. **Check status**

   Read `openspec/schemas/opsx-enhanced/schema.yaml` to get the artifact pipeline. For each artifact in the `artifacts:` list, check if `openspec/changes/<name>/<generates>` exists. Also check the `apply:` section — its `requires` field lists which artifacts must be complete before implementation. Its `tracks` field names the task file (typically `tasks.md`).

   **Handle states:**
   - If apply-required artifacts are missing: show message, suggest using `/opsx:continue` or `/opsx:ff`
   - If all tasks are already done: congratulate, suggest archive
   - Otherwise: proceed to implementation

3. **Read context files**

   Read the schema's `apply.instruction` field for apply guidance. Then read all completed artifact files in the change directory as context:
   - `openspec/changes/<name>/research.md`
   - `openspec/changes/<name>/proposal.md`
   - `openspec/changes/<name>/specs/*/spec.md`
   - `openspec/changes/<name>/design.md`
   - `openspec/changes/<name>/tasks.md`

   Also read `openspec/config.yaml`'s `context:` field for project-level context instructions.

4. **Show current progress**

   Display:
   - Progress: "N/M tasks complete"
   - Remaining tasks overview

5. **Implement tasks (loop until done or blocked)**

   For each pending task:
   - Show which task is being worked on
   - Make the code changes required
   - Keep changes minimal and focused
   - Mark task complete in the tasks file: `- [ ]` → `- [x]`
   - Continue to next task

   **Pause if:**
   - Task is unclear → ask for clarification
   - Implementation reveals a design issue → suggest updating artifacts
   - Error or blocker encountered → report and wait for guidance
   - User interrupts

6. **On completion or pause, show status**

   Display:
   - Tasks completed this session
   - Overall progress: "N/M tasks complete"
   - If all done: suggest archive
   - If paused: explain why and wait for guidance

**Guardrails**
- Keep going through tasks until done or blocked
- Always read context files before starting
- If task is ambiguous, pause and ask before implementing
- If implementation reveals issues, pause and suggest artifact updates
- Keep code changes minimal and scoped to each task
- Update task checkbox immediately after completing each task
- Pause on errors, blockers, or unclear requirements - don't guess
- Do not modify files under `openspec/specs/` during apply — spec changes flow through `/opsx:sync`

**Fluid Workflow Integration**

This skill supports the "actions on a change" model:

- **Can be invoked anytime**: Before all artifacts are done (if tasks exist), after partial implementation, interleaved with other actions
- **Allows artifact updates**: If implementation reveals design issues, suggest updating artifacts - not phase-locked, work fluidly
