---
title: "Task Implementation"
capability: "task-implementation"
description: "Handles working through task checklists in tasks.md, with sequential implementation, progress tracking, pause-on-blocker behavior, and session-level progress reporting."
lastUpdated: "2026-03-05"
---

# Task Implementation

Works through your task checklist systematically, implementing each item, tracking progress with clear counts, and pausing whenever a blocker or ambiguity is encountered.

## Purpose

Manually implementing a long task list is tedious and error-prone -- items get skipped, progress is hard to track across sessions, and blockers can go unnoticed until they cascade. Task Implementation automates the sequential execution of tasks from `tasks.md`, provides real-time progress counts, and stops immediately when something needs your attention, so you stay informed and in control.

## Rationale

Tasks are implemented sequentially in the order listed in `tasks.md` because the task list represents the recommended implementation sequence, and each task may depend on changes made by earlier ones. The system reads all context files (proposal, specs, design, tasks) before starting, ensuring every implementation decision is grounded in the approved design. Pause-on-blocker behavior is essential because guessing at unclear requirements leads to rework; instead, the system surfaces the issue and waits for your guidance.

## Features

- **Sequential task execution** via `/opsx:apply` -- works through pending checkboxes in order, making code changes for each task.
- **Automatic progress tracking** -- displays "N/M tasks complete" at session start, after each task, and on pause or completion.
- **Resume from where you left off** -- skips already-completed tasks and starts from the first pending one.
- **Pause on blockers** -- stops and asks for clarification when a task is ambiguous, a design issue is discovered, or a technical constraint prevents progress.

## Behavior

### Implementing Tasks

When you run `/opsx:apply`, the system reads all context files for the change, then works through each pending task in `tasks.md`. For each task, it reads the description, makes the required code changes, and marks the checkbox from `- [ ]` to `- [x]`. It continues to the next task until all are complete or a blocker is encountered.

### Resuming a Partial Session

If some tasks are already marked complete (from a previous session or manual work), the system skips them and picks up from the first pending task. It shows how many are already done so you know exactly where things stand.

### Pausing on Blockers

The system pauses immediately when it encounters:

- An **ambiguous task** that could be interpreted multiple ways -- it presents the ambiguity with specific questions.
- A **design issue** discovered during implementation (e.g., the approach in design.md is not technically feasible) -- it reports the issue and suggests which artifact to update.
- A **missing prerequisite** -- if tasks.md has not been generated yet, it suggests running the artifact pipeline first.

In all cases, the system does not guess or proceed with an uncertain approach. It waits for your input.

### Progress Tracking

Progress is displayed as "N/M tasks complete" at every key moment: when a session starts, after each task is finished, when a pause occurs, and in the final summary. When all tasks are done, the system displays the completion count and suggests archiving the change.

### All Tasks Already Complete

If every checkbox in `tasks.md` is already marked done, the system reports that all tasks are complete and suggests archiving the change.

## Edge Cases

- If `tasks.md` exists but contains no checkbox items, the system reports "0/0 tasks" and suggests the file may need to be regenerated.
- If checkboxes do not follow the exact `- [ ]` / `- [x]` format, the system ignores them in the count and notes the discrepancy.
- If you manually edit `tasks.md` between sessions (adding, removing, or reordering tasks), the system re-reads the file and computes progress from the current state.
- If the tasks artifact does not exist at all, the system reports the missing file and suggests running the artifact pipeline to generate it.
- If completed tasks appear after pending tasks (out of order), the system still counts correctly and works on pending tasks regardless of their position.
