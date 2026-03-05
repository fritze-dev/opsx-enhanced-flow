---
title: "Roadmap Tracking"
capability: "roadmap-tracking"
description: "Tracks planned improvements and future features as GitHub Issues with a roadmap label, providing a single always-current view of planned work via the project README."
lastUpdated: "2026-03-05"
---

# Roadmap Tracking

Tracks planned improvements and future features as GitHub Issues labeled `roadmap`, with a single link in the project README that always shows the current state of planned work.

## Purpose

Without a central, always-current view of planned work, improvement ideas get lost in chat threads, scattered documents, or forgotten notes. Contributors duplicate effort because they cannot see what is already planned, and project direction remains opaque. Roadmap Tracking solves this by using GitHub Issues as the single source of truth for future work, with the README providing a permanent entry point.

## Rationale

GitHub Issues are used rather than a static document because they stay current without manual synchronization -- when an issue is created, closed, or updated, the filtered view reflects it immediately. The README links to a label-filtered issue list (`roadmap` label) rather than duplicating issue content inline, so the roadmap never goes stale. Each roadmap issue is required to be actionable and self-contained, with enough context to start a new change from it, ensuring the roadmap is practical rather than aspirational.

## Features

- **GitHub Issues as roadmap items** -- each planned improvement is a labeled issue with clear title, description, and context.
- **README integration** -- a Roadmap section in the README links to the filtered issue view, always showing current planned work.
- **Zero-maintenance currency** -- adding or closing issues automatically updates the roadmap view without README edits.
- **Actionable entries** -- each issue contains enough context for a developer to understand the intent, scope, and value of the improvement.

## Behavior

### Creating Roadmap Items

When a team member identifies an improvement during development, review, retrospective, or spec work that falls outside the current change, they create a GitHub Issue with the `roadmap` label. The issue includes a clear title, a description of what the improvement would do and why it is valuable, and any known constraints.

### Viewing the Roadmap

The project README contains a Roadmap section with a link to the GitHub Issues list filtered by the `roadmap` label. Clicking this link always shows the current set of planned improvements. No manual updates to the README are needed when issues are added or closed.

### Completing Roadmap Items

When a roadmap item is implemented through the spec-driven workflow and the change is archived, the corresponding GitHub Issue is closed. It no longer appears in the active roadmap view. The issue can be referenced in the change's research or proposal for traceability.

### Capturing Ideas During Development

If you notice a potential improvement while working on a current change, you create a `roadmap`-labeled issue to capture it without interrupting your current work. This keeps the current change focused while ensuring the idea is not lost.

## Edge Cases

- If no roadmap issues exist, the README link shows an empty list. The link remains valid and populates as issues are created.
- If an issue is created without the `roadmap` label, it does not appear in the filtered view. Periodic review of unlabeled issues helps catch missed labels.
- If the `roadmap` label does not yet exist in the repository, it is created when the first roadmap issue is filed.
- If the roadmap grows to many issues, GitHub milestones or project boards can be used for grouping, but the label and README link remain the primary entry point.
- Roadmap issues that have been open for a long time without activity should be periodically reviewed and either updated or closed to keep the roadmap meaningful.
