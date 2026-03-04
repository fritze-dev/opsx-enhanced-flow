---
title: "Roadmap Tracking"
capability: "roadmap-tracking"
description: "Track planned improvements as GitHub Issues with a roadmap label and a single always-current view"
order: 15
lastUpdated: "2026-03-04"
---

# Roadmap Tracking

Planned improvements and future features are tracked as GitHub Issues with a `roadmap` label. The project README links to the filtered issue list, providing a single always-current view of planned work.

## Features

- Track planned improvements as GitHub Issues with the `roadmap` label
- Single always-current roadmap view via a filtered issue link in the README
- No manual README updates needed when new roadmap items are added
- Roadmap items can grow into full spec-driven changes for traceability

## Behavior

### Creating Roadmap Items

When you identify a concrete improvement — during development, review, retrospectives, or spec work — create a GitHub Issue with the `roadmap` label. Each issue should have a clear title, a description of the improvement, and enough context for a developer to understand the intent and scope.

### Always-Current README Link

The project README contains a Roadmap section with a link to the GitHub Issues filtered by the `roadmap` label. When new roadmap issues are created, they automatically appear in the filtered view without any README edits.

### Completing Roadmap Items

When a roadmap item is implemented and archived through the spec-driven workflow, the corresponding GitHub Issue is closed and no longer appears in the active roadmap view. If a roadmap item grows in scope, it can be developed as a full spec-driven change — the issue is referenced in the change's research or proposal for traceability.

### Capturing Ideas During Development

When working on a current change and you notice a potential improvement outside the current scope, create a roadmap issue to capture it without derailing your current work.

## Edge Cases

- If no roadmap issues exist, the README link shows an empty list — this is expected and the link remains valid.
- If an issue is created without the `roadmap` label, it does not appear in the filtered view. Unlabeled issues should be reviewed periodically to catch missed labels.
- If the `roadmap` label does not exist in the repository, it is created when the first roadmap issue is filed.
- If the roadmap grows to many issues, GitHub milestones or project boards can be used for grouping, but the `roadmap` label and README link remain the primary entry point.
- Roadmap issues that have been open for a long time without activity should be periodically reviewed and closed or updated to keep the roadmap meaningful.
