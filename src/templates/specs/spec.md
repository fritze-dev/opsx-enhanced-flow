---
id: specs
description: Requirements with Gherkin scenarios (BDD) and optional user stories
generates: "specs/**/*.md"
requires: [proposal]
instruction: |
  Edit spec files that define WHAT the system should do.

  Overlap Verification (before editing any spec files):
  1. Read the proposal's Consolidation Check section.
  2. For each new capability, scan existing specs in openspec/specs/ for overlapping
     requirements (same actor, same trigger, same data model).
  3. If overlap is found: STOP and note it. The capability should be reclassified as
     a Modified Capability on the existing spec, not a new spec. Update the proposal's
     Capabilities section to reflect this before proceeding.

  Edit or create one spec file per capability listed in the proposal's Capabilities section.
  - New capabilities: create openspec/specs/<capability>/spec.md using the exact
    kebab-case name from the proposal.
  - Modified capabilities: edit the existing file at openspec/specs/<capability>/spec.md
    in place. Add, modify, or remove requirements as described in the proposal.

  Format requirements (strict ordering):
  1. `### Requirement: <name>` header
  2. Normative description using SHALL/MUST (mandatory — this is the requirement)
  3. Optionally: `**User Story:** As a [role] I want [goal], so that [benefit]` — captures intent and motivation. Recommended for user-facing requirements, omit for purely technical or non-functional ones.
  4. `#### Scenario: <name>` with GIVEN/WHEN/THEN format
  - **IMPORTANT**: Description MUST come before User Story. The description is the normative requirement; the User Story is supplementary context.
  - **CRITICAL**: Scenarios MUST use exactly 4 hashtags (`####`). Using 3 hashtags or bullets will fail silently.
  - Scenarios use full Gherkin: GIVEN establishes preconditions, WHEN triggers, THEN asserts.
  - Every requirement MUST have at least one scenario.

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

## Purpose
<!-- Brief description of what this capability does -->

## Requirements

### Requirement: <!-- requirement name -->
<!-- requirement description — use SHALL/MUST for normative statements -->

<!-- Optional: **User Story:** As a [role] I want [goal], so that [benefit]. -->

#### Scenario: <!-- scenario name -->
- **GIVEN** <!-- initial state -->
- **WHEN** <!-- action / trigger -->
- **THEN** <!-- expected outcome -->

## Edge Cases
<!-- Boundary conditions, error states, empty states, concurrency -->

## Assumptions
<!-- Format: "- Visible assumption text. <!-- ASSUMPTION: short tag -->"
     If none: state "No assumptions made." -->
