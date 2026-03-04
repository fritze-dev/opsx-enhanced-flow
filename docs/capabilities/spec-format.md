---
title: "Spec Format"
capability: "spec-format"
description: "Format rules for specifications including normative descriptions, User Stories, Gherkin scenarios, and delta operations"
order: 6
lastUpdated: "2026-03-04"
---

# Spec Format

Specifications follow a consistent format with normative descriptions using RFC 2119 keywords, optional User Stories, Gherkin scenarios, and structured delta operations for tracking changes.

## Features

- Normative descriptions with RFC 2119 keywords (SHALL, MUST, SHOULD, MAY) as the binding specification
- Optional User Stories in "As a [role] I want [goal], so that [benefit]" format
- Gherkin scenarios with GIVEN/WHEN/THEN clauses for testable behavior
- Delta spec operations (ADDED, MODIFIED, REMOVED, RENAMED) for change tracking
- Clean baseline format without change-tracking noise

## Behavior

### Normative Descriptions

Every requirement starts with a normative description placed immediately after the requirement header. This description uses RFC 2119 keywords to express obligation levels. An optional User Story may follow the description. The description always comes before the User Story — reversing this order is a format violation caught during preflight.

### Gherkin Scenarios

Every requirement has at least one scenario in Gherkin format. Scenarios use GIVEN (preconditions), WHEN (trigger/action), and THEN (expected outcome) clauses. Additional conditions use AND clauses after the relevant step. Scenarios must use the correct heading level (4 hashtags) — using 3 hashtags causes the scenario to be misinterpreted as a requirement-level heading, breaking automated parsing.

### Delta Spec Operations

Specs within a change workspace use operation-prefixed headers to indicate the type of change:
- **ADDED** — for new capabilities
- **MODIFIED** — for changes to existing capabilities (must include the full updated content, not partial diffs)
- **REMOVED** — for deprecated capabilities (must include a reason and migration path)
- **RENAMED** — for name-only changes (uses FROM/TO format)

### Baseline Spec Format

Baseline specs (the merged, current state) use a Purpose section followed by a Requirements section. They do not use operation prefixes — they represent the current state, not a set of changes. Each requirement follows the same format: header, normative description, optional User Story, and scenario blocks.

## Edge Cases

- If a delta spec contains both ADDED and MODIFIED sections, each operation is handled independently during sync.
- If a delta spec uses an unrecognized operation prefix (e.g., "UPDATED"), it is flagged as an error and the sync process refuses to merge.
- If a requirement has zero scenarios, the spec is considered invalid and flagged during preflight.
- If the same requirement name appears in both ADDED and MODIFIED sections of the same delta spec, it is treated as a conflict and flagged during preflight.
- If a RENAMED requirement's new name conflicts with an existing requirement in the baseline, the naming collision is flagged during sync.
