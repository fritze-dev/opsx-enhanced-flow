---
title: "Task Implementation"
capability: "task-implementation"
description: "Systematic task execution with progress tracking and pause-on-blocker behavior"
order: 12
lastUpdated: "2026-03-04"
---

# Task Implementation

Run `/opsx:apply` to work through your task checklist systematically. The system implements each task in order, tracks progress, and pauses when it encounters blockers or ambiguity.

## Features

- Sequential implementation of tasks from the task checklist
- Automatic progress tracking with "N/M tasks complete" counts
- Resume from where you left off — completed tasks are skipped
- Pause on ambiguous tasks or design issues for your guidance
- Support for parallelizable task markers (`[P]`)

## Behavior

### Working Through Tasks

When you run `/opsx:apply`, the system reads all context files (proposal, specs, design, tasks), then works through each pending task in order. For each task, it reads the description, makes the required code changes, and marks the task as complete. It continues until all tasks are done or a blocker is hit.

### Resuming Partially Complete Work

If some tasks are already complete, the system skips them and begins from the first pending task, showing how many are already done (e.g., "3/7 tasks already complete, continuing from task 4").

### Progress Tracking

Progress is displayed as "N/M tasks complete" at the start of a session, after each task completion, and when pausing on a blocker. When all tasks are complete, a final summary lists everything that was completed in the current session and suggests archiving the change.

### Pausing on Blockers

The system pauses and asks for your guidance when:
- A task description is ambiguous or could be interpreted multiple ways
- Implementation reveals that the design approach will not work due to a technical constraint
- Any other blocker is encountered

It does not guess when requirements are unclear.

### Parallelizable Tasks

Tasks marked with `[P]` indicate they can be done in parallel. The marker is informational — progress counting still uses individual checkbox completion.

## Edge Cases

- If tasks.md exists but contains no checkbox items, the system reports "0/0 tasks" and suggests the file may need to be regenerated.
- If tasks.md contains checkbox-like items that do not follow the standard format exactly, they are ignored in the count and the discrepancy is noted.
- If you manually edit tasks.md between apply invocations (adding, removing, or reordering), the system re-reads the file and computes progress from the current state.
- If the tasks artifact does not exist, the system reports the missing artifact and suggests running the artifact pipeline.
- If completed tasks appear after pending tasks (out of order), the system still counts correctly and works on pending tasks regardless of position.
