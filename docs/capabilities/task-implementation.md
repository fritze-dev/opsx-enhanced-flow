---
title: "Task Implementation"
capability: "task-implementation"
description: "Handles working through task checklists in tasks.md, with sequential implementation, progress tracking, pause-on-blocker behavior, direct spec editing, standard tasks separation, and session-level progress reporting."
lastUpdated: "2026-04-07"
---

# Task Implementation

Works through your task checklist systematically, implementing each item, tracking progress with clear counts, and pausing whenever a blocker or ambiguity is encountered. Spec changes can be made directly during implementation when needed, and post-implementation standard tasks are tracked separately from apply execution.

## Purpose

Manually implementing a long task list is tedious and error-prone -- items get skipped, progress is hard to track across sessions, and blockers can go unnoticed until they cascade. Task Implementation automates the sequential execution of tasks, provides real-time progress counts, and stops immediately when something needs your attention, so you stay informed and in control.

## Rationale

Tasks are implemented sequentially in the order listed because the task list represents the recommended implementation sequence, and each task may depend on changes made by earlier ones. The system reads all context files (proposal, specs, design, tasks) from the change directory and the apply instruction from WORKFLOW.md before starting, ensuring every implementation decision is grounded in the approved design. Pause-on-blocker behavior is essential because guessing at unclear requirements leads to rework; instead, the system surfaces the issue and waits for your guidance. Specs can be edited directly during implementation, as the workflow uses direct spec editing rather than a separate sync step.

## Features

- **Sequential task execution** via `/opsx:apply` -- works through pending checkboxes in order, making code changes for each task.
- **Automatic progress tracking** -- displays "N/M tasks complete" at session start, after each task, and on pause or completion.
- **Resume from where you left off** -- skips already-completed tasks and starts from the first pending one.
- **Pause on blockers** -- stops and asks for clarification when a task is ambiguous, a design issue is discovered, or a technical constraint prevents progress.
- **Direct spec editing** -- specs at `openspec/specs/` can be modified during implementation when task requirements include spec changes.
- **Standard tasks separation** -- post-implementation steps (changelog, docs, version bump, push) are tracked as checkboxes in the task list but not executed by apply. Constitution-defined pre-merge extras are executed during the post-apply workflow; post-merge tasks remain unchecked as reminders.
- **Parallelizable task markers** -- tasks marked with `[P]` indicate they can be done in parallel. The marker is informational only and does not change progress counting logic.

## Behavior

### Implementing Tasks

When you run `/opsx:apply`, the system reads all context files from the change directory and the apply instruction from WORKFLOW.md, then works through each pending task. For each task, it reads the description, makes the required code changes, and marks the checkbox as complete. It continues to the next task until all are complete or a blocker is encountered.

### Resuming a Partial Session

If some tasks are already marked complete (from a previous session or manual work), the system skips them and picks up from the first pending task. It shows how many are already done so you know exactly where things stand.

### Pausing on Blockers

The system pauses immediately when it encounters:

- An **ambiguous task** that could be interpreted multiple ways -- it presents the ambiguity with specific questions.
- A **design issue** discovered during implementation (e.g., the approach is not technically feasible) -- it reports the issue and suggests which artifact to update.
- A **missing prerequisite** -- if tasks have not been generated yet, it suggests running the artifact pipeline first.

In all cases, the system does not guess or proceed with an uncertain approach. It waits for your input.

### Progress Tracking

Progress is displayed as "N/M tasks complete" at every key moment: when a session starts, after each task is finished, when a pause occurs, and in the final summary. When all tasks are done, the system displays the completion count and suggests archiving the change.

### Spec Edits During Implementation

Specs at `openspec/specs/` can be modified during implementation. When a task requires updating a spec, the agent edits the baseline spec directly and stages the changes. There is no separate sync step -- spec edits are committed alongside implementation changes.

### Standard Tasks (Post-Implementation)

Every task list includes a final section with post-implementation workflow steps (changelog, docs, version bump, commit and push). These standard tasks are checkboxes like any other task, but `/opsx:apply` does not execute them. They remain unchecked after apply completes, serving as an auditable checklist for the post-apply workflow. Standard tasks are included in progress counts -- after apply, you might see "5/9 tasks complete" reflecting that 4 standard tasks still need to be done manually. If you run `/opsx:archive` while standard tasks are unchecked, the system warns you that tasks remain incomplete. Projects can add project-specific extras to the standard tasks via the constitution's `## Standard Tasks` section.

During the post-apply workflow, universal standard task checkboxes and constitution-defined pre-merge extras (e.g., updating a PR to ready-for-review) are marked complete before creating the final commit. This ensures the committed tasks.md reflects the fully-checked state, eliminating the need for an extra follow-up commit just for checkboxes. Post-merge standard tasks (e.g., updating a plugin locally) remain unchecked as reminders for manual execution after the PR is merged.

### All Tasks Already Complete

If every checkbox is already marked done (including standard tasks), the system reports that all tasks are complete and suggests archiving the change.

## Known Limitations

- Changes that modify only specs and have no code implementation produce an empty task list. The QA loop alone is sufficient for these changes.

## Edge Cases

- If the task file exists but contains no checkbox items, the system reports "0/0 tasks" and suggests the file may need to be regenerated.
- If checkboxes do not follow the expected format, the system ignores them in the count and notes the discrepancy.
- If you manually edit the task file between sessions (adding, removing, or reordering tasks), the system re-reads the file and computes progress from the current state.
- If the tasks artifact does not exist at all, the system reports the missing file and suggests running the artifact pipeline to generate it.
- If completed tasks appear after pending tasks (out of order), the system still counts correctly and works on pending tasks regardless of their position.
- If a constitution extra fails during the post-apply workflow (e.g., `gh pr ready` fails due to network), the agent notes the failure, skips marking that task as complete, and continues with remaining extras. The failed task remains as `- [ ]` for manual resolution.
- If the post-apply workflow is interrupted (e.g., changelog fails), only the steps that actually completed are marked. The commit step is not marked if the commit does not happen.
