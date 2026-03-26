---
id: specs
description: Requirements with Gherkin scenarios (BDD) and optional user stories
generates: "specs/**/*.md"
requires: [proposal]
instruction: |
  Create specification files that define WHAT the system should do.

  Overlap Verification (before creating any spec files):
  1. Read the proposal's Consolidation Check section.
  2. For each new capability, scan existing specs in openspec/specs/ for overlapping
     requirements (same actor, same trigger, same data model).
  3. If overlap is found: STOP and note it. The capability should be reclassified as
     a Modified Capability on the existing spec, not a new spec. Update the proposal's
     Capabilities section to reflect this before proceeding.

  Create one spec file per capability listed in the proposal's Capabilities section.
  - New capabilities: use the exact kebab-case name from the proposal (specs/<capability>/spec.md).
  - Modified capabilities: use the existing spec folder name from openspec/specs/<capability>/.

  Delta operations (use ## headers):
  - **ADDED Requirements**: New capabilities
  - **MODIFIED Requirements**: Changed behavior — MUST include full updated content
  - **REMOVED Requirements**: Deprecated features — MUST include **Reason** and **Migration**
  - **RENAMED Requirements**: Name changes only — use FROM:/TO: format

  Format requirements (strict ordering):
  1. `### Requirement: <name>` header
  2. Normative description using SHALL/MUST (mandatory — this is the requirement)
  3. Optionally: `**User Story:** As a [role] I want [goal], so that [benefit]` — captures intent and motivation. Recommended for user-facing requirements, omit for purely technical or non-functional ones.
  4. `#### Scenario: <name>` with GIVEN/WHEN/THEN format
  - **IMPORTANT**: Description MUST come before User Story. The description is the normative requirement; the User Story is supplementary context.
  - **CRITICAL**: Scenarios MUST use exactly 4 hashtags (`####`). Using 3 hashtags or bullets will fail silently.
  - Scenarios use full Gherkin: GIVEN establishes preconditions, WHEN triggers, THEN asserts.
  - Every requirement MUST have at least one scenario.

  MODIFIED requirements workflow:
  1. Locate the existing requirement in openspec/specs/<capability>/spec.md
  2. Copy the ENTIRE requirement block (from `### Requirement:` through all scenarios)
  3. Paste under `## MODIFIED Requirements` and edit to reflect new behavior
  4. Ensure header text matches exactly (whitespace-insensitive)

  Common pitfall: Using MODIFIED with partial content loses detail at archive time.
  If adding new concerns without changing existing behavior, use ADDED instead.

  Include an "Edge Cases" section for boundary conditions and error states.
  Mark every assumption as: `- Visible assumption text. <!-- ASSUMPTION: short tag -->`.
  The visible text must be a complete readable statement; the HTML comment is a brief tag for preflight grep.
  If zero assumptions were made, state: "No assumptions made."
  Specs should be testable — each scenario is a potential test case.
---
<!-- Optional: YAML frontmatter for documentation ordering.
     Set order (integer) and category (kebab-case string) to control
     how this capability appears in generated docs.
     Define categories that match your project's workflow phases.
---
order: [number]
category: [category]
---
-->

## ADDED Requirements

### Requirement: <!-- requirement name -->
<!-- requirement description — use SHALL/MUST for normative statements -->

<!-- Optional: **User Story:** As a [role] I want [goal], so that [benefit]. -->

#### Scenario: <!-- scenario name -->
- **GIVEN** <!-- initial state -->
- **WHEN** <!-- action / trigger -->
- **THEN** <!-- expected outcome -->

## MODIFIED Requirements
<!-- Only for changes to existing capabilities. Remove section if not applicable.
     MUST include full updated content — partial content loses detail at archive. -->

## REMOVED Requirements
<!-- Only for removed capabilities. Remove section if not applicable.
     MUST include Reason and Migration path. -->

## Edge Cases
<!-- Boundary conditions, error states, empty states, concurrency -->

## Assumptions
<!-- Format: "- Visible assumption text. <!-- ASSUMPTION: short tag -->"
     If none: state "No assumptions made." -->
