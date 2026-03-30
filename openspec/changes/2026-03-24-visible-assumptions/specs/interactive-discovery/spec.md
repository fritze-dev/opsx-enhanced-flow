## MODIFIED Requirements

### Requirement: Standalone Research with Q&A

The system SHALL run an interactive discovery session when the user invokes `/opsx:discover`. Discovery SHALL operate independently from the artifact pipeline -- it generates only the `research.md` artifact and then pauses for user answers. It SHALL NOT generate proposal, specs, design, or any downstream artifacts. The discovery process SHALL: (1) read the constitution for project rules, (2) read the current change directory and existing baseline specs, (3) check whether existing specs reflect the current codebase and note stale-spec risks, (4) generate `research.md` with a coverage assessment rating each category as Clear, Partial, or Missing, and (5) generate targeted clarification questions only for Partial or Missing categories, limited to a maximum of 5 questions prioritized by Impact multiplied by Uncertainty. If all categories are Clear, the system SHALL state that and skip questions. After the user provides answers, the system SHALL record decisions with rationale in the Decisions section of research.md and then stop.

**User Story:** As a developer I want a dedicated interactive research phase with targeted questions, so that I can explore complex features thoroughly and ensure all ambiguities are resolved before the artifact pipeline generates specs and design.

#### Scenario: Discovery with questions for partial categories

- **GIVEN** a change named "add-payment-gateway" has been created via `/opsx:new`
- **AND** the constitution and existing specs have been read
- **WHEN** the user invokes `/opsx:discover add-payment-gateway`
- **THEN** the system reads the constitution, change directory, and existing baseline specs
- **AND** generates research.md with findings about the payment gateway domain
- **AND** rates coverage categories (Scope: Clear, Behavior: Partial, Data Model: Missing, UX: Clear, Integration: Partial, Edge Cases: Partial, Constraints: Clear, Terminology: Clear, Non-Functional: Clear)
- **AND** presents 3 targeted questions for Behavior, Data Model, and Integration (the Partial/Missing categories)
- **AND** pauses and waits for the user to answer

#### Scenario: Discovery with all categories clear

- **GIVEN** a change named "fix-typo-in-docs" has been created
- **AND** the change is straightforward with no ambiguity
- **WHEN** the user invokes `/opsx:discover fix-typo-in-docs`
- **THEN** the system generates research.md with all categories rated as Clear
- **AND** states "All categories are Clear. No questions needed."
- **AND** saves research.md and stops
- **AND** suggests running `/opsx:ff` to generate remaining artifacts

## Assumptions

- The user has already created a change workspace via /opsx:new before invoking /opsx:discover. <!-- ASSUMPTION: Change workspace exists -->
- The user will answer discovery questions in the same session or a subsequent session before running /opsx:ff. <!-- ASSUMPTION: User answers before ff -->
- Stale-spec detection is heuristic (keyword-based) and may not catch all cases of code-spec drift. <!-- ASSUMPTION: Heuristic detection -->
- The 5-question limit is sufficient for most changes; exceptionally complex changes may require multiple discovery rounds. <!-- ASSUMPTION: Question limit sufficient -->
