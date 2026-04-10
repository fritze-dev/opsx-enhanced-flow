---
title: "Task Implementation"
capability: "task-implementation"
description: "Sequential task execution with progress tracking, review.md generation, and standard tasks separation"
lastUpdated: "2026-04-10"
---

# Task Implementation

Works through your task checklist systematically via `/opsx:workflow apply`, implementing each item, tracking progress with clear counts, generating a review.md verification artifact, and pausing whenever a blocker or ambiguity is encountered.

## Purpose

Manually implementing a long task list is tedious and error-prone -- items get skipped, progress is hard to track across sessions, and blockers can go unnoticed until they cascade. Task Implementation automates the sequential execution of tasks, provides real-time progress counts, and stops immediately when something needs your attention, so you stay informed and in control.

## Rationale

Tasks are implemented sequentially in the order listed because the task list represents the recommended implementation sequence, and each task may depend on changes made by earlier ones. The system reads all context files (proposal, specs, design, tasks) from the change directory and the apply instruction from WORKFLOW.md before starting, ensuring every implementation decision is grounded in the approved design. After implementation, the QA loop's Metric Check and Auto-Verify steps run automatically without pausing, producing a `review.md` artifact in the change directory. This persistent artifact replaces the previous transient verify report, making verification results PR-visible and not skippable. The first human gate is User Testing.

## Features

- **Sequential task execution** via `/opsx:workflow apply` -- works through pending checkboxes in order, making code changes for each task
- **Automatic progress tracking** -- displays "N/M tasks complete" at session start, after each task, and on pause or completion
- **Resume from where you left off** -- skips already-completed tasks and starts from the first pending one
- **Pause on blockers** -- stops and asks for clarification when a task is ambiguous, a design issue is discovered, or a technical constraint prevents progress
- **Direct spec editing** -- specs at `openspec/specs/` can be modified during implementation when task requirements include spec changes
- **review.md generation** -- after all tasks complete, the QA loop automatically generates `review.md` in the change directory as a persistent verification artifact
- **Standard tasks separation** -- post-implementation steps (changelog, docs, version bump, push) are tracked as checkboxes but not executed by apply. Pre-merge extras run during the post-apply workflow. Post-merge reminders appear as plain bullets.
- **Parallelizable task markers** -- tasks marked with `[P]` indicate they can be done in parallel. The marker is informational only.
- **Automated QA steps** -- Metric Check and Auto-Verify run without pausing. The first human gate is User Testing.

## Behavior

### Implementing Tasks (`/opsx:workflow apply`)

When you run `/opsx:workflow apply`, the system reads all context files from the change directory and the apply instruction from WORKFLOW.md, then works through each pending task. For each task, it reads the description, makes the required code changes, and marks the checkbox as complete. It continues to the next task until all are complete or a blocker is encountered.

### Resuming a Partial Session

If some tasks are already marked complete (from a previous session or manual work), the system skips them and picks up from the first pending task. It shows how many are already done so you know exactly where things stand.

### Pausing on Blockers

The system pauses immediately when it encounters an ambiguous task (presenting the ambiguity with specific questions), a design issue discovered during implementation (suggesting which artifact to update), or a missing prerequisite (suggesting running the pipeline first).

### Progress Tracking

Progress is displayed as "N/M tasks complete" at every key moment: when a session starts, after each task is finished, when a pause occurs, and in the final summary. When all tasks are done, the system displays the completion count.

### QA Loop and review.md Generation

When all implementation tasks are complete, the QA Loop's Metric Check and Auto-Verify steps run automatically without pausing. The system generates `review.md` in the change directory using the review template -- this is a persistent, PR-visible verification artifact. The first point where the system stops and waits for your input is User Testing.

### Spec Edits During Implementation

Specs at `openspec/specs/` can be modified during implementation. When a task requires updating a spec, the agent edits the baseline spec directly. There is no separate sync step -- spec edits are committed alongside implementation changes.

### Standard Tasks (Post-Implementation)

Every task list includes a Standard Tasks section with post-implementation workflow steps (changelog, docs, version bump, commit and push). These checkboxes are not executed by apply. During the post-apply workflow, universal standard task checkboxes and constitution-defined pre-merge extras are marked complete before the final commit. Post-merge reminders appear in a separate section as plain bullets -- not counted in progress totals.

## Known Limitations

- Changes that modify only specs and have no code implementation produce an empty task list. The QA loop alone is sufficient for these changes.

## Edge Cases

- If the task file exists but contains no checkbox items, the system reports "0/0 tasks" and suggests regeneration.
- If checkboxes do not follow the expected format, the system ignores them in the count and notes the discrepancy.
- If you manually edit the task file between sessions, the system re-reads and computes progress from the current state.
- If the tasks artifact does not exist, the system reports the missing file and suggests running the pipeline.
- If a constitution extra fails during the post-apply workflow, the agent notes the failure, skips marking that task, and continues.
