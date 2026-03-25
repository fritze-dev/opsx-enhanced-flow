---
order: 6
category: change-workflow
---

## MODIFIED Requirements

### Requirement: Standalone Research with Q&A

The system SHALL run an interactive discovery session when the user invokes `/opsx:discover`. Discovery SHALL operate independently from the artifact pipeline -- it generates only the `research.md` artifact and then pauses for user answers. It SHALL NOT generate proposal, specs, design, or any downstream artifacts. The discovery process SHALL: (1) verify that `openspec/config.yaml` and `openspec/schemas/opsx-enhanced/schema.yaml` exist, (2) read the constitution for project rules, (3) read the current change directory and existing baseline specs, (4) check whether existing specs reflect the current codebase and note stale-spec risks, (5) read the research artifact's `instruction` field from schema.yaml and its template, (6) generate `research.md` with a coverage assessment rating each category as Clear, Partial, or Missing, and (7) generate targeted clarification questions only for Partial or Missing categories, limited to a maximum of 5 questions prioritized by Impact multiplied by Uncertainty. If all categories are Clear, the system SHALL state that and skip questions. After the user provides answers, the system SHALL record decisions with rationale in the Decisions section of research.md and then stop.

**User Story:** As a developer I want a dedicated interactive research phase with targeted questions, so that I can explore complex features thoroughly and ensure all ambiguities are resolved before the artifact pipeline generates specs and design.

#### Scenario: Prerequisite check fails

- **GIVEN** the project has not been set up with `/opsx:setup`
- **WHEN** the user invokes `/opsx:discover`
- **THEN** the system checks for `openspec/config.yaml` and `openspec/schemas/opsx-enhanced/schema.yaml`
- **AND** one or both files are missing
- **AND** the system tells the user to run `/opsx:setup` first and stops

## Edge Cases

- **Ambiguous change selection**: If multiple active changes exist and no name is provided, the system SHALL list directories under `openspec/changes/` (excluding `archive/`) and ask the user to select one.

## Assumptions

- The user has already created a change workspace via /opsx:new before invoking /opsx:discover. <!-- ASSUMPTION: Change workspace exists -->
No further assumptions beyond those marked above.
